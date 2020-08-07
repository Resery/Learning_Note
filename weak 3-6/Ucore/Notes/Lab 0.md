# Lab 0

## 调试方法

这里我使用了tmux分屏软件，一个终端分成了两块，然后左面使用qemu模拟器运行代码，右面使用gdb调试。

主要的步骤就是

1. qemu启动程序
2. gdb remote上去

qemu：启动程序的命令是 `qemu-system-i386 -S -s -hda ./bin/ucore.img -monitor stdio`

gdb：gdb就是使用`gdb -tui -x tools/gdbinit`

不过gdb那条命令需要事先在tools目录下修改gdbinit的内容为

```
target remote 127.0.0.1:1234
file bin/kernel
break kern_init
continue 
```

然后我在使用这个命令的时候发现它会和gdb插件有冲突，会产生乱码，就需要把gdb切换回原版，这是一个gdb切换的小脚本，给他放在/usr/local/sbin/目录下面就可以直接任意位置执行了

```
#!/bin/bash
function Mode_change {
    name=$1
 
    if [ $name -eq "1" ];then
	sed -i "1a source /home/resery/ctf-tools/peda/peda.py" ~/.gdbinit
	sed -i "1d" ~/.gdbinit
        echo -e "Please enjoy the peda!\n"
    elif [ $name -eq "2" ];then
        sed -i  "1a source /home/resery/ctf-tools/.gdbinit-gef.py" ~/.gdbinit
	sed -i "1d" ~/.gdbinit
        echo -e "Please enjoy the gef!\n"
    elif [ $name -eq "3" ];then
        sed -i  "1a source /home/resery/ctf-tools/pwndbg/gdbinit.py" ~/.gdbinit 
	sed -i "1d" ~/.gdbinit
        echo -e "Please enjoy the pwndbg!\n"
    else
        sed -i  "1a" ~/.gdbinit 
	sed -i "1d" ~/.gdbinit
        echo -e "Please enjoy the gdb!\n"
    fi
}
 
echo -e "Please choose one mode of GDB?\n1.peda    2.gef    3.pwndbg    4.gdb"
 
read -p "Input your choice:" num
 
if [ $num -eq "1" ];then
    Mode_change $num
elif [ $num -eq "2" ];then
    Mode_change $num
elif [ $num -eq "3" ];then
    Mode_change $num
elif [ $num -eq "4" ];then
    Mode_change $num
else
    echo -e "Error!\nPleasse input right number!"
fi
 
gdb $1 $2 $3 $4 $5 $6 $7 $8 $9
```

然后使用的上面的命令的时候直接使用这条命令就可以了

`gdb.sh -tui -x tools/gdbinit`

**然后关于IDE**

IDE就使用的Clion了，使用的版本是2019.3.3，这里附上破解教程，linux下也可以这样使用

[破解教程](https://www.techgrow.cn/posts/c0477083.html)

环境就差不多可以了，能达到调试的目的了

## 了解处理器硬件

80386处理器有四种运行模式：实模式、保护模式、SMM模式和虚拟8086模式。这里对涉及ucore的实模式、保护模式做一个简要介绍。

实模式：这是个人计算机早期的8086处理器采用的一种简单运行模式，当时微软的MS-DOS操作系统主要就是运行在8086的实模式下。80386加电启动后处于实模式运行状态，在这种状态下软件可访问的物理内存空间不能超过1MB（也就是只有16位，不过cs需要左移4位之后加上ip才是真正的地址，所以说就是表示的范围就是0到2^20），且无法发挥Intel 80386以上级别的32位CPU的4GB内存管理能力。实模式将整个物理内存看成分段的区域，程序代码和数据位于不同区域，操作系统和用户程序并没有区别对待，而且每一个指针都是指向实际的物理地址。这样用户程序的一个指针如果指向了操作系统区域或其他用户程序区域，并修改了内容，那么其后果就很可能是灾难性的。

保护模式：保护模式的一个主要目标是确保应用程序无法对操作系统进行破坏。实际上，80386就是通过在实模式下初始化控制寄存器（如GDTR，LDTR，IDTR与TR等管理寄存器）以及页表，然后再通过设置CR0寄存器使其中的保护模式使能位置位，从而进入到80386的保护模式。当80386工作在保护模式下的时候，其所有的32根地址线都可供寻址，物理寻址空间高达4GB。在保护模式下，支持内存分页机制，提供了对虚拟内存的良好支持。保护模式下80386支持多任务，还支持优先级机制，不同的程序可以运行在不同的特权级上。特权级一共分0～3四个级别，操作系统运行在最高的特权级0上，应用程序则运行在比较低的级别上；配合良好的检查机制后，既可以在任务间实现数据的安全共享也可以很好地隔离各个任务。

80386是32位的处理器，即可以寻址的物理内存地址空间为2^32=4G字节。为更好理解面向80386处理器的ucore操作系统，需要用到三个地址空间的概念：物理地址、线性地址和逻辑地址。物理内存地址空间是处理器提交到总线上用于访问计算机系统中的内存和外设的最终地址。一个计算机系统中只有一个物理地址空间。线性地址空间是80386处理器通过段（Segment）机制控制下的形成的地址空间。在操作系统的管理下，每个运行的应用程序有相对独立的一个或多个内存空间段，每个段有各自的起始地址和长度属性，大小不固定，这样可让多个运行的应用程序之间相互隔离，实现对地址空间的保护。

在操作系统完成对80386处理器段机制的初始化和配置（主要是需要操作系统通过特定的指令和操作建立全局描述符表，完成虚拟地址与线性地址的映射关系）后，80386处理器的段管理功能单元负责把虚拟地址转换成线性地址，在没有下面介绍的页机制启动的情况下，这个线性地址就是物理地址。

相对而言，段机制对大量应用程序分散地使用大内存的支持能力较弱。所以Intel公司又加入了页机制，每个页的大小是固定的（一般为4KB），也可完成对内存单元的安全保护，隔离，且可有效支持大量应用程序分散地使用大内存的情况。

在操作系统完成对80386处理器页机制的初始化和配置（主要是需要操作系统通过特定的指令和操作建立页表，完成虚拟地址与线性地址的映射关系）后，应用程序看到的逻辑地址先被处理器中的段管理功能单元转换为线性地址，然后再通过80386处理器中的页管理功能单元把线性地址转换成物理地址。

上述三种地址的关系如下：

- 分段机制启动、分页机制未启动：逻辑地址--->**段机制处理**--->线性地址=物理地址
- 分段机制和分页机制都启动：逻辑地址--->**段机制处理**--->线性地址--->**页机制处理**--->物理地址

ELAGS

```
CF(Carry Flag)：进位标志位；
PF(Parity Flag)：奇偶标志位；
AF(Assistant Flag)：辅助进位标志位；
ZF(Zero Flag)：零标志位；
SF(Singal Flag)：符号标志位；
IF(Interrupt Flag)：中断允许标志位,由CLI，STI两条指令来控制；设置IF位使CPU可识别外部（可屏蔽）中断请求，复位IF位则禁止中断，IF位对不可屏蔽外部中断和故障中断的识别没有任何作用；
DF(Direction Flag)：向量标志位，由CLD，STD两条指令来控制；
OF(Overflow Flag)：溢出标志位；
IOPL(I/O Privilege Level)：I/O特权级字段，它的宽度为2位,它指定了I/O指令的特权级。如果当前的特权级别在数值上小于或等于IOPL，那么I/O指令可执行。否则，将发生一个保护性故障中断；
NT(Nested Task)：控制中断返回指令IRET，它宽度为1位。若NT=0，则用堆栈中保存的值恢复EFLAGS，CS和EIP从而实现中断返回；若NT=1，则通过任务切换实现中断返回。在ucore中，设置NT为0。
```

## AT&T汇编基本语法

Ucore中用到的是AT&T格式的汇编，与Intel格式的汇编有一些不同。二者语法上主要有以下几个不同：

```
    * 寄存器命名原则
        AT&T: %eax                      Intel: eax
    * 源/目的操作数顺序 
        AT&T: movl %eax, %ebx           Intel: mov ebx, eax
    * 常数/立即数的格式　
        AT&T: movl $_value, %ebx        Intel: mov eax, _value
      把value的地址放入eax寄存器
        AT&T: movl $0xd00d, %ebx        Intel: mov ebx, 0xd00d
    * 操作数长度标识 
        AT&T: movw %ax, %bx             Intel: mov bx, ax
    * 寻址方式 
        AT&T:   immed32(basepointer, indexpointer, indexscale)
        Intel:  [basepointer + indexpointer × indexscale + imm32)
```

如果操作系统工作于保护模式下，用的是32位线性地址，所以在计算地址时不用考虑segment:offset的问题。上式中的地址应为：

```
    imm32 + basepointer + indexpointer × indexscale
```

下面是一些例子：

```
    * 直接寻址 
            AT&T:  foo                         Intel: [foo]
            foo是一个全局变量。注意加上$是表示地址引用，不加是表示值引用。对于局部变量，可以通过堆栈指针引用。

    * 寄存器间接寻址 
            AT&T: (%eax)                        Intel: [eax]

    * 变址寻址 
            AT&T: _variable(%eax)               Intel: [eax + _variable]
            AT&T: _array( ,%eax, 4)             Intel: [eax × 4 + _array]
            AT&T: _array(%ebx, %eax,8)          Intel: [ebx + eax × 8 + _array]
```

## 通用数据结构双向链表

Core的双向链表结构定义为：

```
struct list_entry {
    struct list_entry *prev, *next;
};
```

需要注意uCore内核的链表节点list_entry没有包含传统的data数据域，，而是在具体的数据结构中包含链表节点。以lab2中的空闲内存块列表为例，空闲块链表的头指针定义（位于lab2/kern/mm/memlayout.h中）为：

```
/* free_area_t - maintains a doubly linked list to record free (unused) pages */
typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;
```

而每一个空闲块链表节点定义（位于lab2/kern/mm/memlayout）为：

```
/* *
 * struct Page - Page descriptor structures. Each Page describes one
 * physical page. In kern/mm/pmm.h, you can find lots of useful functions
 * that convert Page to other data types, such as phyical address.
 * */
struct Page {
    atomic_t ref;          // page frame's reference counter
    ……
    list_entry_t page_link;         // free list link
};
```

这样以free_area_t结构的数据为双向循环链表的链表头指针，以Page结构的数据为双向循环链表的链表节点，就可以形成一个完整的双向循环链表，如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_16-30-35.png)

从上图中我们可以看到，这种通用的双向循环链表结构避免了为每个特定数据结构类型定义针对这个数据结构的特定链表的麻烦，而可以让所有的特定数据结构共享通用的链表操作函数。在实现对空闲块链表的管理过程（参见lab2/kern/mm/default_pmm.c）中，就大量使用了通用的链表插入，链表删除等操作函数。有关这些链表操作函数的定义如下。

(1) 初始化

uCore只定义了链表节点，并没有专门定义链表头，那么一个双向循环链表是如何建立起来的呢？让我们来看看list_init这个内联函数（inline funciton）：

```
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
}
```

参看文件default_pmm.c的函数default_init，当我们调用list_init(&(free_area.free_list))时，就声明一个名为free_area.free_list的链表头时，它的next、prev指针都初始化为指向自己，这样，我们就有了一个表示空闲内存块链的空链表。而且我们可以用头指针的next是否指向自己来判断此链表是否为空，而这就是内联函数list_empty的实现。

(2) 插入

对链表的插入有两种操作，即在表头插入（list_add_after）或在表尾插入（list_add_before）。因为双向循环链表的链表头的next、prev分别指向链表中的第一个和最后一个节点，所以，list_add_after和list_add_before的实现区别并不大，实际上uCore分别用**list_add(elm, listelm, listelm->next)和**list_add(elm, listelm->prev, listelm)来实现在表头插入和在表尾插入。而__list_add的实现如下：

```
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
    elm->next = next;
    elm->prev = prev;
}
```

从上述实现可以看出在表头插入是插入在listelm之后，即插在链表的最前位置。而在表尾插入是插入在listelm->prev之后，即插在链表的最后位置。注：list_add等于list_add_after。

(3) 删除

当需要删除空闲块链表中的Page结构的链表节点时，可调用内联函数list_del，而list_del进一步调用了__list_del来完成具体的删除操作。其实现为：

```
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
}
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
    next->prev = prev;
}
```

如果要确保被删除的节点listelm不再指向链表中的其他节点，这可以通过调用list_init函数来把listelm的prev、next指针分别自身，即将节点置为空链状态。这可以通过list_del_init函数来完成。

(4) 访问链表节点所在的宿主数据结构

通过上面的描述可知，list_entry_t通用双向循环链表中仅保存了某特定数据结构中链表节点成员变量的地址，那么如何通过这个链表节点成员变量访问到它的所有者（即某特定数据结构的变量）呢？Linux为此提供了针对数据结构XXX的le2XXX(le, member)的宏，其中le，即list entry的简称，是指向数据结构XXX中list_entry_t成员变量的指针，也就是存储在双向循环链表中的节点地址值， member则是XXX数据类型中包含的链表节点的成员变量。例如，我们要遍历访问空闲块链表中所有节点所在的基于Page数据结构的变量，则可以采用如下编程方式（基于lab2/kern/mm/default_pmm.c）：

```
//free_area是空闲块管理结构，free_area.free_list是空闲块链表头
free_area_t free_area;
list_entry_t * le = &free_area.free_list;  //le是空闲块链表头指针
while((le=list_next(le)) != &free_area.free_list) { //从第一个节点开始遍历
    struct Page *p = le2page(le, page_link); //获取节点所在基于Page数据结构的变量
    ……
}
```

le2page宏（定义位于lab2/kern/mm/memlayout.h）的使用相当简单：

```
// convert list entry to page
#define le2page(le, member)                 \
to_struct((le), struct Page, member)
```

而相比之下，它的实现用到的to_struct宏和offsetof宏（定义位于lab2/libs/defs.h）则有一些难懂：

```
/* Return the offset of 'member' relative to the beginning of a struct type */
#define offsetof(type, member)                                      \
((size_t)(&((type *)0)->member))

/* *
 * to_struct - get the struct from a ptr
 * @ptr:    a struct pointer of member
 * @type:   the type of the struct this is embedded in
 * @member: the name of the member within the struct
 * */
#define to_struct(ptr, type, member)                               \
((type *)((char *)(ptr) - offsetof(type, member)))
```

这里采用了一个利用gcc编译器技术的技巧，即先求得数据结构的成员变量在本宿主数据结构中的偏移量，然后根据成员变量的地址反过来得出属主数据结构的变量的地址。

我们首先来看offsetof宏，size_t最终定义与CPU体系结构相关，本实验都采用Intel X86-32 CPU，顾szie_t等价于 unsigned int。 ((type *)0)->member的设计含义是什么？其实这是为了求得数据结构的成员变量在本宿主数据结构中的偏移量。为了达到这个目标，首先将0地址强制"转换"为type数据结构（比如struct Page）的指针，再访问到type数据结构中的member成员（比如page_link）的地址，即是type数据结构中member成员相对于数据结构变量的偏移量。在offsetof宏中，这个member成员的地址（即“&((type *)0)->member)”）实际上就是type数据结构中member成员相对于数据结构变量的偏移量。对于给定一个结构，offsetof(type,member)是一个常量，to_struct宏正是利用这个不变的偏移量来求得链表数据项的变量地址。接下来再分析一下to_struct宏，可以发现 to_struct宏中用到的ptr变量是链表节点的地址，把它减去offsetof宏所获得的数据结构内偏移量，即就得到了包含链表节点的属主数据结构的变量的地址。