# Lab 2

## 基础知识

### 探测物理内存分布和大小的方法

当 ucore 被启动之后，最重要的事情就是知道还有多少内存可用，一般来说，获取内存大小的方法由 BIOS 中断调用和直接探测两种。但BIOS 中断调用方法是一般只能在实模式下完成，而直接探测方法必须在保护模式下完成。通过 BIOS 中断获取内存布局有三种方式，都是基于INT 15h中断，分别为88h e801h e820h。但是 并非在所有情况下这三种方式都能工作。在 Linux kernel 里，采用的方法是依次尝试这三种方法。而在本实验中，我们通过e820h中断获取内存信息。因为e820h中断必须在实模式下使用，所以我们在 bootloader 进入保护模式之前调用这个 BIOS 中断，并且把 e820 映射结构保存在物理地址0x8000处。

操作系统需要知道了解整个计算机系统中的物理内存如何分布的，哪些被可用，哪些不可用。其基本方法是通过BIOS中断调用来帮助完成的。其中BIOS中断调用必须在实模式下进行，所以在bootloader进入保护模式前完成这部分工作相对比较合适。这些部分由boot/bootasm.S中从probe_memory处到finish_probe处的代码部分完成完成。通过BIOS中断获取内存可调用参数为e820h的INT 15h BIOS中断。BIOS通过系统内存映射地址描述符（Address Range Descriptor）格式来表示系统物理内存布局，其具体表示如下：

```
Offset  Size    Description
00h    8字节   base address               #系统内存块基地址
08h    8字节   length in bytes            #系统内存大小
10h    4字节   type of address range     #内存类型
```

看下面的(Values for System Memory Map address type)

```
Values for System Memory Map address type:
01h    memory, available to OS
02h    reserved, not available (e.g. system ROM, memory-mapped device)
03h    ACPI Reclaim Memory (usable by OS after reading ACPI tables)
04h    ACPI NVS Memory (OS is required to save this memory between NVS sessions)
other  not defined yet -- treat as Reserved
```

INT15h BIOS中断的详细调用参数:

```
eax：e820h：INT 15的中断调用参数；
edx：534D4150h (即4个ASCII字符“SMAP”) ，这只是一个签名而已；
ebx：如果是第一次调用或内存区域扫描完毕，则为0。 如果不是，则存放上次调用之后的计数值；
ecx：保存地址范围描述符的内存大小,应该大于等于20字节；
es:di：指向保存地址范围描述符结构的缓冲区，BIOS把信息写入这个结构的起始地址。
```

此中断的返回值为:

```
cflags的CF位：若INT 15中断执行成功，则不置位，否则置位；

eax：534D4150h ('SMAP') ；

es:di：指向保存地址范围描述符的缓冲区,此时缓冲区内的数据已由BIOS填写完毕

ebx：下一个地址范围描述符的计数地址

ecx    ：返回BIOS往ES:DI处写的地址范围描述符的字节大小

ah：失败时保存出错代码
```

这样，我们通过调用INT 15h BIOS中断，递增di的值（20的倍数），让BIOS帮我们查找出一个一个的内存布局entry，并放入到一个保存地址范围描述符结构的缓冲区中，供后续的ucore进一步进行物理内存管理。这个缓冲区结构定义在memlayout.h中：

```
struct e820map {
                  int nr_map;
                  struct {
                                    long long addr;
                                    long long size;
                                    long type;
                  } map[E820MAX];
};
```

### 以页为单位管理物理内存

在获得可用物理内存范围后，系统需要建立相应的数据结构来管理以物理页（按4KB对齐，且大小为4KB的物理内存单元）为最小单位的整个物理内存，以配合后续涉及的分页管理机制。每个物理页可以用一个 Page数据结构来表示。由于一个物理页需要占用一个Page结构的空间，Page结构在设计时须尽可能小，以减少对内存的占用。Page的定义在kern/mm/memlayout.h中。以页为单位的物理内存分配管理的实现在kern/default_pmm.。

为了与以后的分页机制配合，我们首先需要建立对整个计算机的每一个物理页的属性用结构Page来表示，它包含了映射此物理页的虚拟页个数，描述物理页属性的flags和双向链接各个Page结构的page_link双向链表。

```
struct Page {
    int ref;        // page frame's reference counter
    uint32_t flags; // array of flags that describe the status of the page frame
    unsigned int property;// the num of free block, used in first fit pm manager
    list_entry_t page_link;// free list link
};
```

1. ref表示这样页被页表的引用记数

2. flags表示此物理页的状态标记，进一步查看kern/mm/memlayout.h中的定义，可以看到：

   ```
   /* Flags describing the status of a page frame */
   #define PG_reserved                 0       // the page descriptor is reserved for kernel or unusable
   #define PG_property                 1       // the member 'property' is valid
   ```

   - bit 0表示此页是否被保留（reserved），如果是被保留的页，则bit 0会设置为1，且不能放到空闲页链表中，即这样的页不是空闲页，不能动态分配与释放。
   - bit 1表示此页是否是free的，如果设置为1，表示这页是free的，可以被分配；如果设置为0，表示这页已经被分配出去了，不能被再二次分配。

3. property用来记录某连续内存空闲块的大小（即地址连续的空闲页的个数）。

4. page_link是把多个连续内存空闲块链接在一起的双向链表指针

   ```
   /* free_area_t - maintains a doubly linked list to record free (unused) pages */
   typedef struct {
               list_entry_t free_list;                                // the list header
               unsigned int nr_free;                                 // # of free pages in this free list
   } free_area_t;
   ```

   - free_list，list_entry结构的双向链表指针
   - nr_free，记录当前空闲页的个数的无符号整型变量

有了这两个数据结构，ucore就可以管理起来整个以页为单位的物理内存空间。接下来需要解决两个问题：

• 管理页级物理内存空间所需的Page结构的内存空间从哪里开始，占多大空间？ • 空闲内存空间的起始地址在哪里？

对于这两个问题，我们首先根据bootloader给出的内存布局信息找出最大的物理内存地址maxpa（定义在page_init函数中的局部变量），由于x86的起始物理内存地址为0，所以可以得知需要管理的物理页个数为

```
npage = maxpa / PGSIZE
```

这样，我们就可以预估出管理页级物理内存空间所需的Page结构的内存空间所需的内存大小为：

```
sizeof(struct Page) * npage)
```

由于bootloader加载ucore的结束地址（用全局指针变量end记录）以上的空间没有被使用，所以我们可以把end按页大小为边界去整后，作为管理页级物理内存空间所需的Page结构的内存空间，记为：

```
pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
```

为了简化起见，从地址0到地址pages+ sizeof(struct Page) * npage)结束的物理内存空间设定为已占用物理内存空间（起始0~640KB的空间是空闲的），地址pages+ sizeof(struct Page) * npage)以上的空间为空闲物理内存空间，这时的空闲空间起始地址为

```
uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
```

为此我们需要把这两部分空间给标识出来。首先，对于所有物理空间，通过如下语句即可实现占用标记：

```
for (i = 0; i < npage; i ++) {
SetPageReserved(pages + i);
}
`
```

然后，根据探测到的空闲物理空间，通过如下语句即可实现空闲标记：

```
//获得空闲空间的起始地址begin和结束地址end
……
init_memmap(pa2page(begin), (end - begin) / PGSIZE);
```

其实SetPageReserved只需把物理地址对应的Page结构中的flags标志设置为PG_reserved ，表示这些页已经被使用了，将来不能被用于分配。而init_memmap函数则是把空闲物理页对应的Page结构中的flags和引用计数ref清零，并加到free_area.free_list指向的双向列表中，为将来的空闲页管理做好初始化准备工作。

关于内存分配的操作系统原理方面的知识有很多，但在本实验中只实现了最简单的内存页分配算法。相应的实现在default_pmm.c中的default_alloc_pages函数和default_free_pages函数，相关实现很简单，这里就不具体分析了，直接看源码，应该很好理解。

其实实验二在内存分配和释放方面最主要的作用是建立了一个物理内存页管理器框架，这实际上是一个函数指针列表，定义如下：

```
struct pmm_manager {
            const char *name; //物理内存页管理器的名字
            void (*init)(void); //初始化内存管理器
            void (*init_memmap)(struct Page *base, size_t n); //初始化管理空闲内存页的数据结构
            struct Page *(*alloc_pages)(size_t n); //分配n个物理内存页
            void (*free_pages)(struct Page *base, size_t n); //释放n个物理内存页
            size_t (*nr_free_pages)(void); //返回当前剩余的空闲页数
            void (*check)(void); //用于检测分配/释放实现是否正确的辅助函数
};
```

### 段页式管理基本概念

如图4在保护模式中，x86 体系结构将内存地址分成三种：逻辑地址（也称虚地址）、线性地址和物理地址。逻辑地址即是程序指令中使用的地址，物理地址是实际访问内存的地址。逻 辑地址通过段式管理的地址映射可以得到线性地址，线性地址通过页式管理的地址映射得到物理地址。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-11_19-02-41.png)

页式管理将线性地址分成三部分（图中的 Linear Address 的 Directory 部分、 Table 部分和 Offset 部分）。ucore 的页式管理通过一个二级的页表实现。一级页表的起始物理地址存放在 cr3 寄存器中，这个地址必须是一个页对齐的地址，也就是低 12 位必须为 0。目前，ucore 用boot_cr3（mm/pmm.c）记录这个值。

这个看图就能明白，看过csapp就很容易弄懂

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-11_19-12-04.png)

### 建立段页式管理中需要考虑的关键问题

为了实现分页机制，需要建立好虚拟内存和物理内存的页映射关系，即正确建立二级页表。此过程涉及硬件细节，不同的地址映射关系组合，相对比较复杂。总体而言，我们需要思考如下问题：

- 如何在建立页表的过程中维护全局段描述符表（GDT）和页表的关系，确保ucore能够在各个时间段上都能正常寻址？
- 对于哪些物理内存空间需要建立页映射关系？
- 具体的页映射关系是什么？
- 页目录表的起始地址设置在哪里？
- 页表的起始地址设置在哪里，需要多大空间？
- 如何设置页目录表项的内容？
- 如何设置页表项的内容？

### 系统执行中地址映射的四个阶段

lab2中，为了建立正确的地址映射关系，ld在链接阶段生成了ucore OS执行代码的虚拟地址，而bootloader与ucore OS协同工作，通过在运行时对地址映射的一系列“腾挪转移”，从计算机加电，启动段式管理机制，启动段页式管理机制，在段页式管理机制下运行这整个过程中，虚地址到物理地址的映射产生了多次变化，实现了最终的段页式映射关系：

```
 virt addr = linear addr = phy addr + 0xC0000000
```

其具体实现过程写在了代码分析部分，不过先提前说一下lab2与lab1中的ld脚本的不同之处

- lab1：lab1中通过ld工具形成的ucore的起始虚拟地址从0x100000开始，注意：这个地址是虚拟地址。由于lab1中建立的段地址映射关系为对等关系，所以ucore的物理地址也是0x100000，lab1中虚拟地址，线性地址以及物理地址之间的映射关系如下：

  ```
   lab1： virt addr = linear addr = phy addr
  ```

- lab2：lab2中通过ld工具形成的ucore的起始虚拟地址从0xC0100000开始，注意：这个地址也是虚拟地址。入口函数为kern_entry函数（在kern/init/entry.S中）。这与lab1有很大差别。但其实在lab1和lab2中，bootloader把ucore都放在了起始物理地址为0x100000的物理内存空间。这实际上说明了ucore在lab1和lab2中采用的地址映射不同。lab2在不同阶段有不同的虚拟地址，线性地址以及物理地址之间的映射关系。

在lab2中对应着有四个阶段，分别是**bootloader阶段**（最开始的实模式转换保护模式的那个阶段）、**执行内核代码阶段**（也就是从bootloader开始跳转到执行kern_entry的那个步骤就开始是第二个阶段一直到打开页机制，所以就证明此时采用的寻址方式机制是分段机制），**打开页机制阶段**（启动了页机制，但是还没有更新映射机制），**更新段映射为段页映射**（这里是因为上一阶段中虽然启动了页机制，但是段到页的映射还没有修改，所以说需要进行更新段到页的映射之后，才算真正的达到了段页映射机制）

对应着每个阶段都有着不同的映射关系，如下

- **bootloader阶段**：

  ```
  lab2 stage 1： virt addr = linear addr = phy addr
  ```

- **执行内核代码阶段**：

  ```
   lab2 stage 2： virt addr - 0xC0000000 = linear addr = phy addr
  ```

- **打开页机制阶段**：

  ```
   lab2 stage 3:  virt addr - 0xC0000000 = linear addr  = phy addr + 0xC0000000 # 物理地址在0~4MB之外的三者映射关系
                  virt addr - 0xC0000000 = linear addr  = phy addr # 物理地址在0~4MB之内的三者映射关系
  ```

  请注意`pmm_init`函数中的一条语句：

  ```
   boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
  ```

  就是用来建立物理地址在0~4MB之内的三个地址间的临时映射关系`virt addr - 0xC0000000 = linear addr = phy addr`。

- **更新段映射为段页映射**：

  ```
   lab2 stage 4： virt addr = linear addr = phy addr + 0xC0000000
  ```

### 建立虚拟页和物理页帧的地址映射关系

**页目录表**、**页表**、**物理页**都是占4KB空间，**页目录项**、**页表项**都是占4B空间

整个页目录表和页表所占空间大小取决与二级页表要管理和映射的物理页数。

以0~16mb举例，一个物理页是4kb所以说一共需要(16\*1024)kb/4=4096个物理页，对应4096个物理页就需要有4096个页表项来存储，也就是需要使用(4096\*4)b空间，对应着一个页表是占4kb空间的，所以说就需要(4096\*4)b/(4*1024)b=4个页表来存储，然后对应页目录表，一共有4个页表所以说也就是需要4个页目录项来存储，4个页目录项没有沾满一个页目录表但是页还是需要用一个页目录表来存储，所以对16MB物理页建立一一映射的16MB虚拟页，需要5个物理页（4个页表，1个页目录表），即20KB的空间来形成二级页表。

为把0~KERNSIZE（明确ucore设定实际物理内存不能超过KERNSIZE值，即0x38000000字节，896MB，3670016个物理页）的物理地址一一映射到页目录项和页表项的内容，其大致流程如下：

1. 先通过alloc_page获得一个空闲物理页，用于页目录表；

2. 调用boot_map_segment函数建立一一映射关系，具体处理过程以页为单位进行设置，即

   ```
   virt addr = phy addr + 0xC0000000
   ```

   设一个32bit线性地址la有一个对应的32bit物理地址pa，如果在以la的高10位为索引值的页目录项中的存在位（PTE_P）为0，表示缺少对应的页表空间，则可通过alloc_page获得一个空闲物理页给页表，页表起始物理地址是按4096字节对齐的，这样填写页目录项的内容为

   ```
   页目录项内容 = (页表起始物理地址 &0x0FFF) | PTE_U | PTE_W | PTE_P
   ```

   进一步对于页表中以线性地址la的中10位为索引值对应页表项的内容为

   ```
   页表项内容 = (pa & ~0x0FFF) | PTE_P | PTE_W
   ```

3. PTE_U：位3，表示用户态的软件可以读取对应地址的物理内存页内容

4. PTE_W：位2，表示物理内存页内容可写

5. PTE_P：位1，表示物理内存页存在

ucore 的内存管理经常需要查找页表：给定一个虚拟地址，找出这个虚拟地址在二级页表中对应的项。通过更改此项的值可以方便地将虚拟地址映射到另外的页上。可完成此功能的这个函数是get_pte函数。它的原型为

```
pte_t  *get_pte (pde_t *pgdir,  uintptr_t la, bool  create)
```

下面的调用关系图可以比较好地看出get_pte在实现上诉流程中的位置：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-12_12-47-53.png)

对应上面的函数出现的几种类型和参数做一下介绍

- pde_t：unsigned int类型，全称为 page directory entry，也就是一级页表的表项
- pte_t：unsigned int类型，全称为 page table entry，也就是二级页表的表项
- uintptr_t：unsigned int类型，表示为线性地址，由于段式管理只做直接映射，所以它也是逻辑地址
- pgdir：页表起始地址
- create：如果create参数为0，则get_pte返回NULL；如果create参数不为0，则get_pte需要申请一个新的物理页（通过alloc_page来实现，可在mm/pmm.h中找到它的定义），再在一级页表中添加页目录项指向表示二级页表的新物理页。注意，新申请的页必须全部设定为零，因为这个页所代表的虚拟地址都没有被映射。

当建立从一级页表到二级页表的映射时，需要注意设置控制位。这里应该设置同时设置 上PTE_U、PTE_W和PTE_P（定义可在mm/mmu.h）。如果原来就有二级页表，或者新建立了页表，则只需返回对应项的地址即可。

虚拟地址只有映射上了物理页才可以正常的读写。在完成映射物理页的过程中，除了要象上面那样在页表的对应表项上填上相应的物理地址外，还要设置正确的控制位。

**回收物理页**

这是通过查找管理该物理页的Page数据结构的成员变量ref（用来表示虚拟页到物理页的映射关系的个数）来实现的，如果ref为0了，表示没有虚拟页到物理页的映射关系了，就可以把这个物理页给回收了，从而这个物理页是free的了，可以再被分配。page_insert函数将物理页映射在了页表上。可参看page_insert函数的实现来了解ucore内核是如何维护这个变量的。当不需要再访问这块虚拟地址时，可以把这块物理页回收并在将来用在其他地方。取消映射由page_remove来做，这其实是page insert的逆操作。

建立好一一映射的二级页表结构后，接下来就要使能分页机制了，这主要是通过enable_paging函数实现的，这个函数主要做了两件事：

1. 通过lcr3指令把页目录表的起始地址存入CR3寄存器中；
2. 通过lcr0指令把cr0中的CR0_PG标志位设置上。

执行完enable_paging函数后，计算机系统进入了分页模式！但到这一步还没建立好完整的段页式映射。还记得ucore在最开始通过kern_entry函数设置了临时的新段映射机制吗？这个临时的新段映射不是最简单的对等映射，导致虚拟地址和线性地址不相等。这里需要注意：刚进入分页模式的时刻是一个过渡过程。在这个过渡过程中，虚拟地址，线性地址以及物理地址之间的映射关系为：

```
virt addr = linear addr + 0xC0000000 = phy addr + 2 * 0xC0000000
```

而我们希望的段页式映射的最终映射关系为：

```
 virt addr = linear addr = phy addr + 0xC0000000
```

这里最终的段映射是简单的段对等映射（virt addr = linear addr）。所以我们需要进一步调整段映射关系，即重新设置新的GDT，建立对等段映射。在这个特殊的阶段，如果不把段映射关系改为virt addr = linear addr，则通过段页式两次地址转换后，无法得到正确的物理地址。为此我们需要进一步调用gdt_init函数，根据新的gdt全局段描述符表内容（gdt定义位于pmm.c中），恢复简单的段对等映射关系，即使得virt addr = linear addr。这样在执行完gdt_init后，通过的段机制和页机制实现的地址映射关系为：

```
virt addr=linear addr = phy addr +0xC0000000
```

这里存在的一个问题是，在调用enable_page函数到执行gdt_init函数之前，内核使用的还是旧的段表映射，即：

```
virt addr = linear addr + 0xC0000000 = phy addr + 2 * 0xC0000000
```

如何保证此时内核依然能够正常工作呢？其实只需让index为0的页目录项的内容等于以索引值为(KERNBASE>>22)的目录表项的内容即可。目前内核大小不超过 4M （实际上是3M，因为内核从 0x100000开始编址），这样就只需要让页表在0~4MB的线性地址与KERNBASE ~ KERNBASE+4MB的线性地址获得相同的映射即可，都映射到 0~4MB的物理地址空间，具体实现在pmm.c中pmm_init函数的语句：

```
boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];
```

实际上这种映射也限制了内核的大小。当内核大小超过预期的3MB 就可能导致打开分页之后内核crash，在后面的试验中，也的确出现了这种情况。解决方法同样简单，就是拷贝更多的高地址对应的页目录项内容到低地址对应的页目录项中即可。

当执行完毕gdt_init函数后，新的段页式映射已经建立好了，上面的0~4MB的线性地址与0~4MB的物理地址一一映射关系已经没有用了。 所以可以通过如下语句解除这个老的映射关系。

```
boot_pgdir[0] = 0;
```

在page_init函数建立完实现物理内存一一映射和页目录表自映射的页目录表和页表后，一旦使能分页机制，则ucore看到的内核虚拟地址空间如下图所示：

```
Virtual memory map:                                           Permissions
                                                              kernel/user

     4G ------------------> +---------------------------------+
                            |                                 |
                            |         Empty Memory (*)        |
                            |                                 |
                            +---------------------------------+ 0xFB000000
                            |   Cur. Page Table (Kern, RW)    | RW/-- PTSIZE
     VPT -----------------> +---------------------------------+ 0xFAC00000
                            |        Invalid Memory (*)       | --/--
     KERNTOP -------------> +---------------------------------+ 0xF8000000
                            |                                 |
                            |    Remapped Physical Memory     | RW/-- KMEMSIZE
                            |                                 |
     KERNBASE ------------> +---------------------------------+ 0xC0000000
                            |                                 |
                            |                                 |
                            |                                 |
                            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

## 代码分析

### bootasm.S

```
probe_memory:
    movl $0, 0x8000
    xorl %ebx, %ebx
    movw $0x8004, %di
start_probe:
    movl $0xE820, %eax
    movl $20, %ecx
    movl $SMAP, %edx
    int $0x15
    jnc cont
    movw $12345, 0x8000
    jmp finish_probe
cont:
    addw $20, %di
    incl 0x8000
    cmpl $0, %ebx
    jnz start_probe
finish_probe:

    lgdt gdtdesc
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg
```

这部分就是来探测物理内存分布和大小的

首先再梳理一下，对应的过程，第一步应该是先把0x8000处的内容清空也就是把e820map结构中的nr_map置0然后在0x8004处开始存地址范围描述符，第二部然后是设置各个寄存器的值，第三步调用int 15中断，第四步根据返回值判断时候下一轮循环，第五步继续循环直到ebx的值为0即没有下一个地址范围描述符的地址了

1. 2-3，清空0x8000处的内容，置ebx为0。
2. 4-8，设置各个寄存器的值，eax=e820h，edx=534D4150h（"SMAP"） ，ebx=0（因为第一次调用，还有扫描完毕的时候也会是0），ecx=20（大于等于20），di=0x8004
3. 9，执行中断
4. 10，14-16，检查返回值，如果中断成功执行则cf=1，通过jnc就可以直到是否终端成功，然后14行增加偏移寻找下一个内存布局，然后0x8000加1计数，也就是存储着有多少个内存布局，16行判断是否扫描完毕，没有完毕就继续循环

### kern_init.c

```
int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);

    cons_init();                // init the console

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);

    print_kerninfo();

    grade_backtrace();

    pmm_init();                 // init physical memory management

    pic_init();                 // init interrupt controller
    idt_init();                 // init interrupt descriptor table

    clock_init();               // init clock interrupt
    intr_enable();              // enable irq interrupt

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
}
```

可以从15行看到，显示输出一些东西之后，就开始调用pmm_init函数

### pmm_init

```
void
pmm_init(void) {
    boot_cr3 = PADDR(boot_pgdir);

    init_pmm_manager();

    page_init();

    check_alloc_page();

    check_pgdir();

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;

    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);

    gdt_init();

    check_boot_pgdir();

    print_pgdir();

}
```

1. 第3行，对应的就是取出cr3寄存器中的值，因为一级页表的起始物理地址是存储在cr3寄存器中的
2. 第5行，初始化一个物理内存管理器，基于练习中设置的
3. 第7行，检测物理内存然后创建空闲页链表
4. 第9-11行，检测alloc/free是否正确
5. 第13-17行，建立2级页表并且设置好对应的映射关系
6. 第19行，重新设置新的GDT

### kernel.ld

```
/* Simple linker script for the ucore kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(kern_entry)

SECTIONS {
    /* Load the kernel at this address: "." means the current address */
    . = 0xC0100000;

    .text : {
        *(.text .stub .text.* .gnu.linkonce.t.*)
    }

    PROVIDE(etext = .); /* Define the 'etext' symbol to this value */

    .rodata : {
        *(.rodata .rodata.* .gnu.linkonce.r.*)
    }

    /* Include debugging information in kernel memory */
    .stab : {
        PROVIDE(__STAB_BEGIN__ = .);
        *(.stab);
        PROVIDE(__STAB_END__ = .);
        BYTE(0)     /* Force the linker to allocate space
                   for this section */
    }

    .stabstr : {
        PROVIDE(__STABSTR_BEGIN__ = .);
        *(.stabstr);
        PROVIDE(__STABSTR_END__ = .);
        BYTE(0)     /* Force the linker to allocate space
                   for this section */
    }

    /* Adjust the address for the data segment to the next page */
    . = ALIGN(0x1000);

    /* The data segment */
    .data : {
        *(.data)
    }

    . = ALIGN(0x1000);
    .data.pgdir : {
        *(.data.pgdir)
    }

    PROVIDE(edata = .);

    .bss : {
        *(.bss)
    }

    PROVIDE(end = .);

    /DISCARD/ : {
        *(.eh_frame .note.GNU-stack)
    }
}
```

1. 从前十行代码就可以看出，内核加载的地址是0xC0100000（虚拟地址，也就是说text段的起始地址为0xC0100000），然后入口的代码为kern_entry函数，然后CPU机器类型是i386类型的

2. ucore内核的链接地址==ucore内核的虚拟地址；bootloader加载ucore内核用到的加载地址==ucore内核的物理地址。

3. 其中12行之后就是定义每个段的起始地址和结束的地址，以text段举例

   ```
       .text : {
           *(.text .stub .text.* .gnu.linkonce.t.*)
       }
   
       PROVIDE(etext = .);
   ```

   - **.**：这个字符的含义是当前地址
   - **.text**：就是代码段的起始地址
   - \*(.text .stub .text.\* .gnu.linkonce.t.\*)：这段是指输出到可执行程序的段中包含什么，意思就是他应该包含目标文件中的text段stub段和gnu.linkonce.t段

   然后是ALIGN(0x1000)命令：命令的意思就是返回位置指针之后的第一个满足边界对齐字节数 0x1000 的地址值

   PROVIDE(etext = .)命令：如果你的程式已经有这个etext （函数或者变数），就用你的；否则就使用我提供的etext 。

## 项目组成

表1： 实验二文件列表

```
bash
|-- boot
| |-- asm.h
| |-- bootasm.S
| \`-- bootmain.c
|-- kern
| |-- init
| | |-- entry.S
| | \`-- init.c
| |-- mm
| | |-- default\_pmm.c
| | |-- default\_pmm.h
| | |-- memlayout.h
| | |-- mmu.h
| | |-- pmm.c
| | \`-- pmm.h
| |-- sync
| | \`-- sync.h
| \`-- trap
| |-- trap.c
| |-- trapentry.S
| |-- trap.h
| \`-- vectors.S
|-- libs
| |-- atomic.h
| |-- list.h
\`-- tools
|-- kernel.ld
```

相对与实验一，实验二主要增加和修改的文件如上表所示。主要改动如下：

- boot/bootasm.S：增加了对计算机系统中物理内存布局的探测功能；
- kern/init/entry.S：根据临时段表重新暂时建立好新的段空间，为进行分页做好准备。
- kern/mm/default_pmm.[ch]：提供基本的基于链表方法的物理内存管理（分配单位为页，即4096字节）；
- kern/mm/pmm.[ch]：pmm.h定义物理内存管理类框架struct pmm_manager，基于此通用框架可以实现不同的物理内存管理策略和算法(default_pmm.[ch] 实现了一个基于此框架的简单物理内存管理策略)； pmm.c包含了对此物理内存管理类框架的访问，以及与建立、修改、访问页表相关的各种函数实现。
- kern/sync/sync.h：为确保内存管理修改相关数据时不被中断打断，提供两个功能，一个是保存eflag寄存器中的中断屏蔽位信息并屏蔽中断的功能，另一个是根据保存的中断屏蔽位信息来使能中断的功能；（可不用细看）
- libs/list.h：定义了通用双向链表结构以及相关的查找、插入等基本操作，这是建立基于链表方法的物理内存管理（以及其他内核功能）的基础。其他有类似双向链表需求的内核功能模块可直接使用list.h中定义的函数。
- libs/atomic.h：定义了对一个变量进行读写的原子操作，确保相关操作不被中断打断。（可不用细看）
- tools/kernel.ld：ld形成执行文件的地址所用到的链接脚本。修改了ucore的起始入口和代码段的起始地址。相关细节可参看附录C。

**编译方法**

编译并运行代码的命令如下：

```bash
make

make qemu
```

则可以得到如下显示界面（仅供参考）

```bash
chenyu$ make qemu
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0xc010002c (phys)
  etext  0xc010537f (phys)
  edata  0xc01169b8 (phys)
  end    0xc01178dc (phys)
Kernel executable memory footprint: 95KB
memory managment: default_pmm_manager
e820map:
  memory: 0009f400, [00000000, 0009f3ff], type = 1.
  memory: 00000c00, [0009f400, 0009ffff], type = 2.
  memory: 00010000, [000f0000, 000fffff], type = 2.
  memory: 07efd000, [00100000, 07ffcfff], type = 1.
  memory: 00003000, [07ffd000, 07ffffff], type = 2.
  memory: 00040000, [fffc0000, ffffffff], type = 2.
check_alloc_page() succeeded!
check_pgdir() succeeded!
check_boot_pgdir() succeeded!
-------------------- BEGIN --------------------
PDE(0e0) c0000000-f8000000 38000000 urw
  |-- PTE(38000) c0000000-f8000000 38000000 -rw
PDE(001) fac00000-fb000000 00400000 -rw
  |-- PTE(000e0) faf00000-fafe0000 000e0000 urw
  |-- PTE(00001) fafeb000-fafec000 00001000 -rw
--------------------- END ---------------------
++ setup timer interrupts
100 ticks
100 ticks
……
```

通过上图，我们可以看到ucore在显示其entry（入口地址）、etext（代码段截止处地址）、edata（数据段截止处地址）、和end（ucore截止处地址）的值后，探测出计算机系统中的物理内存的布局（e820map下的显示内容）。接下来ucore会以页为最小分配单位实现一个简单的内存分配管理，完成二级页表的建立，进入分页模式，执行各种我们设置的检查，最后显示ucore建立好的二级页表内容，并在分页模式下响应时钟中断。





