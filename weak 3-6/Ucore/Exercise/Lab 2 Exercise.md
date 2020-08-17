# Lab 2 Exercise

## Exercise 1

**问题：**

**在实现first fit 内存分配算法的回收函数时，要考虑地址连续的空闲块之间的合并操作。提示:在建立空闲页块链表时，需要按照空闲页块起始地址来排序，形成一个有序的链表。可能会修改default_pmm.c中的default_init，default_init_memmap，default_alloc_pages， default_free_pages等相关函数。请仔细查看和理解default_pmm.c中的注释。**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

- **你的first fit算法是否有进一步的改进空间**

### 解：

**数据结构和宏**

```
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)


#define PG_reserved                 0       // if this bit=1: the Page is reserved for kernel, cannot be used in alloc/free_pages; otherwise, this bit=0 
#define PG_property                 1       // if this bit=1: the Page is the head page of a free memory block(contains some continuous_addrress pages), and can be used in alloc_pages; if this bit=0: if the Page is the the head page of a free memory block, then this Page and the memory block is alloced. Or this Page isn't the head page.


typedef struct {
    list_entry_t free_list;         // the list header
    unsigned int nr_free;           // # of free pages in this free list
} free_area_t;

struct Page {
    int ref;                        // page frame's reference counter
    uint32_t flags;                 // array of flags that describe the status of the page frame
    unsigned int property;          // the num of free block, used in first fit pm manager
    list_entry_t page_link;         // free list link
};
```

1. 7-8行，对应着后面的page结构中的flags的后两位，也就是bit0和bit1，其中如果bit0位，为1则代表该页是保留给内核的不允许被分配或者释放，为0则可以使用，如果bit1位，为1则代表该页是free的可以被分配，为0则代表已经被分配出去了，不可以再被分配
2. 11-14行，free_list是指向前后块的指针，nr_free记录的是当前空闲页的个数
3. 16-21行，ref记录的是这个页被引用的次数，flags对应的就是描述这个页的状态，主要就是利用后两位来确定是否为保留和分配或空闲，property是记录连续空闲页的个数，page_link就是来指向前后块的指针

**初始化空链表**

```
static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}
```

这个就很简单对应list_init实现的也就是让free_list的前后指针都指向自己，并且设置空闲页个数为0

**根据size n来初始化**

首先独立思考按size n初始化需要做什么工作，首先第一点循环是肯定的，然后就是设置每个空闲页的flags，property，ref这些值，设置好值之后就是把这些空闲页链表连接起来，最后还需要修改链表头的nr_free的值

```
static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = 0; 
        p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}
```

1. 3-9行，首先循环，一直循环到base+n，然后针对每一个page先要检查一下PG_reserved是不是为0如果为0则证明这个页是被内核保留的则不能使用并且设置为已分配的状态，都需要设置PG_reserved位和PG_property位为0，即不是保留的页。然后设置ref为0，也就是引用次数为0，然后循环结束。
2. 10-13行，起始的结点需要设置property即有多少个空闲页，然后设置起始结点的PG_property位为1，也就是空闲块，然后更新free_list的nr_free，即空闲页的个数，然后把这个链表，插入到free_list之后。

**alloc**

因为是first fit，所以说alloc就是按地址遍历，然后找到第一个比它大的就直接占用，然后剩余的部分直接切割掉。所以这里面一共涉及到的步骤就是找，然后切割，具体每个步骤都是还需要设置对应结构体中的值

```
static struct Page *
default_alloc_pages(size_t n) {
    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
        if (page->property > n) {
            struct Page *p = page + n;
            p->property = page->property - n;
            SetPageProperty(p);
            list_add(&(page->page_link), &(p->page_link));
        }
        list_del(&(page->page_link));
        nr_free -= n;
        ClearPageProperty(page);
    }
    return page;
}
```

1. 7-15，寻找合适的页，因为空闲块的链表是双向循环链表所以说可以直接以是否到达free_list头来作为循环是否结束的标准，然后就开始遍历，遇到大的就结束

2. 16-25，现再先判断一下是否找到了，找到了才开始执行if里面的内容，首先把这个页从空闲链表中删除，然后就是有切割，切割有两种情况一种就是这个页的大小比想要的大，那就需要切割，但是如果说是相等的就不需要切割。正常情况下切割的话，就是先让指针指向n个位置之后，图示就是这样

   ```
   ======================   <----------- page			--
   |          n         |								 |
   ======================   <----------- page + n		 ----> p（原本为整个，后来指向的是page+n）
   | page->property - n |								 |
   ======================								--
   ```

   然后就是对于原始的p就需要把包含的空闲页个数减掉n然后把这个剪掉之后的个数，再重新加回到free_list中，然后free_list头部的nr_free的值就需要减掉n，然后因为现再page已经是分配出去了的，所以说要设置page的PageProperty位为0，表示已分配

   其中这里需要修改一下，原版的alloc代码，原版的代码是先进行了del即删除结点，然后在if中在add添加结点，也就相当于在已经删除的结点后面添加结点所以就根本没有真正的添加到空闲链表上，而是和被删除的结点链接到了一起，所以需要修改一下，需要先把page替换成p，然后再删除p

**free**

```
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags=0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        le = list_next(le);
        if (base + base->property == p) {
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
}
```

1. 5-9行，是检测是不是保留页并且已经分配的，然后设置flag为1即空闲和ref为0
2. 10-27行，前向合并和后向合并
3. 29-37行，检测合并的是否正确

改进空间：

1. 由于每次都切割大块，当大块切割之后只剩很小的一部分，这部分就很难被利用到，就会造成内部碎片，多了的话就会浪费很大一部分内存
2. free算法，只有两种情况前向和后向和不合并，但是如果前后都是空闲即可以前后合并，算法中没有实现，想要实现也就是把else if修改成if即可

## Exercise 2

**问题：**

**通过设置页表和对应的页表项，可建立虚拟内存地址和物理内存地址的对应关系。其中的get_pte函数是设置页表项环节中的一个重要步骤。此函数找到一个虚地址对应的二级页表项的内核虚地址，如果此二级页表项不存在，则分配一个包含此项的二级页表。本练习需要补全get_pte函数 in kern/mm/pmm.c，实现其功能。请仔细查看和理解get_pte函数中的注释。**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

- **请描述页目录项（Pag Director Entry）和页表（Page Table Entry）中每个组成部分的含义和以及对ucore而言的潜在用处。**
- **如果ucore执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**

### 解：

```
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
#if 1
    pde_t *pdep = &pgdir[PDX(la)];
    if(!(*pdep & PTE_P)){
        struct Page *page;
        if(create == 1 && (page = alloc_page())){
            set_page_ref(page,1);
            uintptr_t pa = page2pa(page);
            memset(KADDR(pa), 0, PGSIZE);
            *pdep = pa | PTE_U | PTE_W | PTE_P;
        }
        else{
            return NULL;
        }

    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
#endif
```

- PDX(la)：虚拟地址la的页面目录条目的索引
- KADDR(pa) : 接受物理地址并返回相应的内核虚拟地址
- set_page_ref(page,1) : 设置页的引用次数，再释放页的时候有用
-  page2pa(page): 获取（struct Page *）页面管理的内存的物理地址
- struct Page * alloc_page() : 分配页
- memset(void *s, char c, size_t n) : 将s指向的存储区域的前n个字节设置为指定值c
- PTE_U：位3，表示用户态的软件可以读取对应地址的物理内存页内容
- PTE_W：位2，表示物理内存页内容可写
- PTE_P：位1，表示物理内存页存在

然后就是需要做的步骤了

1. 找到也目标表的地址，PDX返回页目录表的索引，pgdir[PDX(la)]就是指向对应的目录表项了
2. 然后检测对应的物理页是否存在
3. 检测crete参数的值，如果为0则返回null，不为0就要创建新的页
4. 设置页引用次数
5. 获取页的线性地址
6. 新的页需要是空的
7. 设置权限位
8. 返回对应页表项的地址

PTE和PDE结构如下：

```
PDE:
|<------ 31~12------>|<------ 11~0 --------->| 比特
                     |b a 9 8 7 6 5 4 3 2 1 0| 
|--------------------|-|-|-|-|-|-|-|-|-|-|-|-| 占位
|<-------index------>| AVL |G|P|0|A|P|P|U|R|P| 属性
                             |S|   |C|W|/|/|
                                   |D|T|S|W|
                                   

PTE:
|<------ 31~12------>|<------ 11~0 --------->| 比特
                     |b a 9 8 7 6 5 4 3 2 1 0|
|--------------------|-|-|-|-|-|-|-|-|-|-|-|-| 占位
|<-------index------>| AVL |G|P|D|A|P|P|U|R|P| 属性
                             |A|   |C|W|/|/|
                             |T|   |D|T|S|W|

```

属性的含义

- P：有效位。0 表示当前表项无效。
- R/W: 0 表示只读。1表示可读写。
- U/S: 0是高特权级（只能由0，1，2层访问） 1是用户级（0，1，2，3层访问）
- A: 0 表示该页未被访问，1表示已被访问。
- D: 脏位。0表示该页未写过，1表示该页被写过。
- PS: 只存在于页目录表。0表示这是4KB页，指向一个页表。1表示这是4MB大页，直接指向物理页。

对于ucore来说就是可以保护物理页，通过对权限的控制可以方指物理页被更改

发生也访问异常后做的操作：

- 进行换页操作 首先 CPU 将产生页访问异常的线性地址 放到 cr2 寄存器中 
- 然后就是和普通的中断一样 保护现场 将寄存器的值压入栈中 
- 然后压入 error_code 中断服务例程将外存的数据换到内存中来 
- 最后 退出中断 回到进入中断前的状态

## Exercise 3

**问题：**

**当释放一个包含某虚地址的物理内存页时，需要让对应此物理内存页的管理数据结构Page做相关的清除处理，使得此物理内存页成为空闲；另外还需把表示虚地址与物理地址对应关系的二级页表项清除。请仔细查看和理解page_remove_pte函数中的注释。为此，需要补全在 kern/mm/pmm.c中的page_remove_pte函数。**

请在实验报告中简要说明你的设计实现过程。请回答如下问题：

- 数据结构Page的全局变量（其实是一个数组）的每一项与页表中的页目录项和页表项有无对应关系？如果有，其对应关系是啥？
- 如果希望虚拟地址与物理地址相等，则需要如何修改lab2，完成此事？ **鼓励通过编程来具体完成这个问题**

### 解：

```
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
#if 1
    if(*ptep & PTE_P){
        struct Page *page = pte2page(*ptep);
        if(page_ref_dec(page) == 0){
            free_page(page);
        }
        *ptep = NULL;
        tlb_invalidate(pgdir, la);
    }
#endif
}
```

- struct Page \*page pte2page(\*ptep): 从ptep的值获取相应的页面
- free_page : 释放一个页
- page_ref_dec(page) : page->ref减一，然后当ref=0的时候就意味着这个页应该被释放了
- tlb_invalidate(pde_t *pgdir, uintptr_t la) : 使TLB条目无效，但是仅在要编辑的页表是处理器当前正在使用的页表中

过程如下：

1. 检测页表项是不是对应的PTE_P是不是1
2. 找到对应的页面
3. ref减一
4. 检测ref是否等于0
5. 等于0释放这个页，并且把这个页表项和特目录表项中的内容删除掉

对应关系：

比如 PG_reserved 这个表示的这个页是否被内核保留 与 页表项的 PTE_U 这个参数有关系

如何修改：

修改虚拟地址基址 减去一个 0xC0000000 就等于物理地址了，也就是修改memlayout.h中的`#define KERNBASE 0xC0000000`为`#define KERNBASE 0x0`

## Extend Exercise

**问题：**

**实现buddy system（伙伴系统）分配算法，Buddy System算法把系统中的可用存储空间划分为存储块(Block)来进行管理, 每个存储块的大小必须是2的n次幂(Pow(2, n)), 即1, 2, 4, 8, 16, 32, 64, 128...**

- **参考[伙伴分配器的一个极简实现](http://coolshell.cn/articles/10427.html)， 在ucore中实现buddy system分配算法，要求有比较充分的测试用例说明实现的正确性，需要有设计文档。**

**buddy system算法介绍**

伙伴分配的实质就是一种特殊的**“分离适配”**，即将内存按2的幂进行划分，相当于分离出若干个块大小一致的空闲链表，搜索该链表并给出同需求最佳匹配的大小。其优点是快速搜索合并（O(logN)时间复杂度）以及低外部碎片（最佳适配best-fit）；其缺点是内部碎片，因为按2的幂划分块，如果碰上66单位大小，那么必须划分128单位大小的块。但若需求本身就按2的幂分配，比如可以先分配若干个内存池。

**分配内存对应的操作：**

1. 寻找大小合适的内存块（大于等于所需大小并且最接近2的幂，比如需要27，实际分配32）
   - 如果找到了，分配给应用程序
   - 如果没找到，分出合适的内存块
     - 对半分离出高于所需大小的空闲内存块
     - 如果分到最低限度，分配这个大小
     - 回溯到步骤1（寻找合适大小的块）
     - 重复该步骤直到一个合适的块

**释放内存对应的操作：**

1. 释放该内存块
   - 寻找相邻的块，看其是否释放了
   - 如果相邻块也释放了，合并这两个块，重复上述步骤直到遇上未释放的相邻块，或者达到最高上限（即所有内存都释放了）

利用这个图就可以很好的理解上面的两个操作，如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-17_22-00-59.png)

**整体思想**

分配器的整体思想是，通过一个数组形式的完全二叉树来监控管理内存，二叉树的节点用于标记相应内存块的使用状态，高层节点对应大的块，低层节点对应小的块，在分配和释放中我们就通过这些节点的标记属性来进行块的分离合并。如图所示，假设总大小为16单位的内存，我们就建立一个深度为5的满二叉树，根节点从数组下标[0]开始，监控大小16的块；它的左右孩子节点下标[1~2]，监控大小8的块；第三层节点下标[3~6]监控大小4的块……依此类推。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-17_22-02-03.png)

在分配阶段，首先要搜索大小适配的块，假设第一次分配3，转换成2的幂是4，我们先要对整个内存进行对半切割，从16切割到4需要两步，那么从下标[0]节点开始深度搜索到下标[3]的节点并将其标记为已分配。第二次再分配3那么就标记下标[4]的节点。第三次分配6，即大小为8，那么搜索下标[2]的节点，因为下标[1]所对应的块被下标[3~4]占用了。

在释放阶段，我们依次释放上述第一次和第二次分配的块，即先释放[3]再释放[4]，当释放下标[4]节点后，我们发现之前释放的[3]是相邻的，于是我们立马将这两个节点进行合并，这样一来下次分配大小8的时候，我们就可以搜索到下标[1]适配了。若进一步释放下标[2]，同[1]合并后整个内存就回归到初始状态。

**代码实现**

1. **宏和数据结构**，在上面的整体思想中，即我们在搜索合适的结点的时候就需要判断该节点是否已经被分配了在被分配了的情况下还剩多少可以用的空间，还需要设置一个表明管理内存的总单元数目，其次就是也需要一个记录已经分配的块的信息的结构，记录着存储已分配块的链表头和自己在二叉树中的位置，以及自己的大小，数据结构就差不多了。然后就是宏，宏对应着就是几个操作，分配的时候会自动把要分配的size扩展成2的整数次方的倍数例如66->128，所以就需要两个宏，一个是检测是不是2的整数次方的倍数，一个是把他扩充成2的整数次方的倍数，在之后搜索适配的块的时候假如当前节点是大于size的但是有可能他的左子结点和右子结点也大于size，所以就需要再和左子结点和右子结点做对比，同时如果找到了要分配的结点，还需要对其父节点进行更新，所以就需要4个宏定义，取左子结点的值，取右子结点的值，取父结点的值，比较大小的MAX。同时为了方便寻找出size对应的大于size的最小的2的整数次方和小于size的最大的2的整数次方，也需要对应设置两个宏。还有两个就是free链表和nr_free，之前的分配算法就已经定义好了的。定义的宏和数据结构如下：

   ```
   //取左子结点的值
   #define LEFT_LEAF(index) ((index) * 2 + 1)
   //取右子结点的值
   #define RIGHT_LEAF(index) ((index) * 2 + 2)
   //取父结点的值
   #define PARENT(index) ( ((index) + 1) / 2 - 1)
   
   //判断是否为2的整数次幂
   #define IS_POWER_OF_2(x) (!((x)&((x)-1)))
   //判断出最大的
   #define MAX(a, b) ((a) > (b) ? (a) : (b))
   
   //右移n位
   #define UINT32_SHR_OR(a,n)      ((a)|((a)>>(n)))
   //大于a的一个最小的2^k
   #define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
   
   //检测大于a的最小的2^(k-1)是否小于等于a
   #define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
   //小于a的最大的2^k
   #define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))
   
   //扩展size为2的整数次方
   static unsigned fixsize(unsigned size) {
     size |= size >> 1;
     size |= size >> 2;
     size |= size >> 4;
     size |= size >> 8;
     size |= size >> 16;
     return size+1;
   }
   
   
   struct buddy2 {
     //表明管理内存
     unsigned size;
     //记录对应的内存块的空闲单位
     unsigned longest; 
   };
   
   //存放二叉树的数组，用于内存分配
   struct buddy2 root[80000];
   
   /记录分配块的信息
   struct allocRecord/
   {
    struct Page* base;
    int offset;
    size_t nr;//块大小
   };
   
   //存放偏移量的数组
   struct allocRecord rec[80000];
   //已分配的块数
   int nr_block;
   ```

2. **init**，初始化分为两个free链表的初始化这个初始化和原本算法的一样，其次就是对应内存映射的初始化，内存映射的初始化会提供一个size，前面做的操作和原本的算法一样，不过后面需要多一步对二叉树内容的更新即设置根的size成员变量为提供的size，然后更新每个结点对应的longest的值。对应代码如下：

   ```
   static void
   buddy_init()
   {
       list_init(&free_list);
       nr_free=0;
   }
   
   //初始化二叉树上的节点
   void
   buddy2_new( int size ) {
   unsigned node_size;
    int i;
    nr_block=0;
    if (size < 1 || !IS_POWER_OF_2(size))
            return;
   
    root[0].size = size;
    node_size = size * 2;
    for (i = 0; i < 2 * size - 1; ++i) {
        if (IS_POWER_OF_2(i+1))
        node_size /= 2;
            root[i].longest = node_size;
    }
    return;
   }
   
   //初始化内存映射关系
   static void
   buddy_init_memmap(struct Page *base, size_t n)
   {
       assert(n>0);
       struct Page* p=base;
       for(;p!=base + n;p++)
       {
           assert(PageReserved(p));
           p->flags = 0;
           p->property = 1;
           set_page_ref(p, 0);   
           SetPageProperty(p);
           list_add_before(&free_list,&(p->page_link));     
       }
       nr_free += n;
       int allocpages=UINT32_ROUND_DOWN(n);
       buddy2_new(allocpages);
   }
   ```

3. **alloc**，对应着就是在二叉树中找到合适的结点然后更新其longest值，再回溯其父节点，再更新其父节点的值，更详细一点的就是先检测输入的size是不是合法的，然后再检测size是不是2的整数次方不是的话就需要把它扩展为2的整数次方，然后就是去寻找合适的结点了，也就是比较longest和size的大小，选择出合适的结点，然后设置该结点的longest为0，然后再向上回溯修改它祖先结点的longest，最后返回合适的结点的位置。知道了位置之后就需要开始设置已分配的页的链表了，这部分的核心内容和原本的几乎无差别，只是增加了一些对于size的检测，代码如下：

   ```
   //内存分配
   int
   buddy2_alloc(struct buddy2* self, int size) {
     unsigned index = 0;//节点的标号
     unsigned node_size;
     unsigned offset = 0;
   
     if (self==NULL)//无法分配
       return -1;
   
     if (size <= 0)//分配不合理
       size = 1;
     else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
       size = fixsize(size);
   
     if (self[index].longest < size)//可分配内存不足
       return -1;
   
     for(node_size = self->size; node_size != size; node_size /= 2 ) {
       if (self[LEFT_LEAF(index)].longest >= size)
       {
          if(self[RIGHT_LEAF(index)].longest>=size)
           {
              index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
            //找到两个相符合的节点中内存较小的结点
           }
          else
          {
            index=LEFT_LEAF(index);
          }  
       }
       else
         index = RIGHT_LEAF(index);
     }
   
     self[index].longest = 0;//标记节点为已使用
     offset = (index + 1) * node_size - self->size;
     while (index) {
       index = PARENT(index);
       self[index].longest = 
         MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
     }
   //向上刷新，修改先祖结点的数值
     return offset;
   }
   
   static struct Page*
   buddy_alloc_pages(size_t n){
    assert(n>0);
    if(n>nr_free)
        return NULL;
   
    struct Page* page = NULL;
    struct Page* p;
    int allocpages;
    list_entry_t *le = &free_list;
    list_entry_t *len;
    rec[nr_block].offset = buddy2_alloc(root,n);//记录偏移量
   
    for(int i = 0;i < rec[nr_block].offset + 1;i++)
            le = list_next(le);
    page = le2page(le,page_link);
    
    if(!IS_POWER_OF_2(n))
            allocpages = fixsize(n);
    else
            allocpages = n;
   
    //根据需求n得到块大小
    rec[nr_block].base = page;//记录分配块首页
    rec[nr_block].nr = allocpages;//记录分配的页数
    nr_block++;
        for(int i = 0;i < allocpages;i++)
        {
        len = list_next(le);
        p = le2page(le,page_link);
        ClearPageProperty(p);
        le = len;
        }//修改每一页的状态
        nr_free -= allocpages;//减去已被分配的页数
        page->property = n;
        return page;
   }
   
   ```

4. **free**，在内存释放的free接口，我们只要传入之前分配的内存地址索引，并确保它是有效值。之后就跟alloc做反向回溯，从最后的节点开始一直往上找到longest为0的节点，即当初分配块所适配的大小和位置。**我们将longest恢复到原来满状态的值。继续向上回溯，检查是否存在合并的块，依据就是左右子树longest的值相加是否等于原空闲块满状态的大小，如果能够合并，就将父节点longest标记为相加的和**，同时还涉及已经分配的页的回收，更新一些属性，不过大致思想就是这样的，代码如下：

   ```
   void
   buddy_free_pages(struct Page* base, size_t n) {
     unsigned node_size, index = 0;
     unsigned left_longest, right_longest;
     struct buddy2* self = root;
     
     list_entry_t *le = list_next(&free_list);
     int i = 0;
     for(i = 0;i < nr_block;i++)//找到块
     {
       if(rec[i].base == base)
        break;
     }
     int offset = rec[i].offset;
     int pos = i;//暂存i
     i = 0;
     while(i < offset)
     {
       le = list_next(le);
       i++;
     }
     int allocpages;
     if(!IS_POWER_OF_2(n))
      allocpages = fixsize(n);
     else
     {
        allocpages = n;
     }
     assert(self && offset >= 0 && offset < self->size);//是否合法
     node_size = 1;
     index = offset + self->size - 1;
     nr_free += allocpages;//更新空闲页的数量
     struct Page* p;
     self[index].longest = allocpages;
     for(i = 0;i < allocpages;i++)//回收已分配的页
     {
        p = le2page(le,page_link);
        p->flags = 0;
        p->property = 1;
        SetPageProperty(p);
        le = list_next(le);
     }
     while (index) {//向上合并，修改先祖节点的记录值
       index = PARENT(index);
       node_size *= 2;
   
       left_longest = self[LEFT_LEAF(index)].longest;
       right_longest = self[RIGHT_LEAF(index)].longest;
       
       if (left_longest + right_longest == node_size) 
         self[index].longest = node_size;
       else
         self[index].longest = MAX(left_longest, right_longest);
     }
     for(i = pos;i < nr_block-1;i++)//清除此次的分配记录
     {
       rec[i] = rec[i+1];
     }
     nr_block--;//更新分配块数的值
   }
   ```

注：这里如果想要使用make qemu进行测试就需要修改一些内容，比如把default_pmm_manager重新设置一下，设置成如下形式

```
const struct pmm_manager default_pmm_manager = {
    .name = "buddy_system",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
```

然后注释掉原来的算法的default_pmm_manager然后再make qemu即可

全部代码（包含buddy.c和buddy.h）：

```
.c:
/*
* @Author: resery
* @Date:   2020-08-17 19:42:14
* @Last Modified by:   resery
* @Last Modified time: 2020-08-17 22:31:43
*/
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>
#include <buddy.h>
//来自参考资料的一些宏定义
#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define UINT32_SHR_OR(a,n)      ((a)|((a)>>(n)))//右移n位  

#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) {
    size |= size >> 1;
    size |= size >> 2;
    size |= size >> 4;
    size |= size >> 8;
    size |= size >> 16;
    return size+1;
}

struct buddy2 {
    unsigned size;//表明管理内存
    unsigned longest; 
};
struct buddy2 root[80000];//存放二叉树的数组，用于内存分配

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
  
struct allocRecord//记录分配块的信息
{
    struct Page* base;
    int offset;
    size_t nr;//块大小
};
struct allocRecord rec[80000];//存放偏移量的数组
int nr_block;//已分配的块数

static void
buddy_init()
{
    list_init(&free_list);
    nr_free=0;
}

//初始化二叉树上的节点
void
buddy2_new( int size ) {
unsigned node_size;
    int i;
    nr_block=0;
    if (size < 1 || !IS_POWER_OF_2(size))
        return;

    root[0].size = size;
    node_size = size * 2;
    for (i = 0; i < 2 * size - 1; ++i) {
    if (IS_POWER_OF_2(i+1))
        node_size /= 2;
        root[i].longest = node_size;
    }
    return;
}

//初始化内存映射关系
static void
buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n>0);
    struct Page* p=base;
    for(;p!=base + n;p++)
    {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 1;
        set_page_ref(p, 0);   
        SetPageProperty(p);
        list_add_before(&free_list,&(p->page_link));     
    }
    nr_free += n;
    int allocpages=UINT32_ROUND_DOWN(n);
    buddy2_new(allocpages);
}

//内存分配
int
buddy2_alloc(struct buddy2* self, int size) {
  unsigned index = 0;//节点的标号
  unsigned node_size;
  unsigned offset = 0;

  if (self==NULL)//无法分配
    return -1;

  if (size <= 0)//分配不合理
    size = 1;
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
    size = fixsize(size);

  if (self[index].longest < size)//可分配内存不足
    return -1;

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
    if (self[LEFT_LEAF(index)].longest >= size)
    {
       if(self[RIGHT_LEAF(index)].longest>=size)
        {
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
         //找到两个相符合的节点中内存较小的结点
        }
       else
       {
         index=LEFT_LEAF(index);
       }  
    }
    else
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;
  while (index) {
    index = PARENT(index);
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  }
//向上刷新，修改先祖结点的数值
  return offset;
}

static struct Page*
buddy_alloc_pages(size_t n){
    assert(n>0);
    if(n>nr_free)
        return NULL;

    struct Page* page = NULL;
    struct Page* p;
    int allocpages;
    list_entry_t *le = &free_list;
    list_entry_t *len;
    rec[nr_block].offset = buddy2_alloc(root,n);//记录偏移量

    for(int i = 0;i < rec[nr_block].offset + 1;i++)
        le = list_next(le);
    page = le2page(le,page_link);
    
    if(!IS_POWER_OF_2(n))
        allocpages = fixsize(n);
    else
        allocpages = n;

    //根据需求n得到块大小
    rec[nr_block].base = page;//记录分配块首页
    rec[nr_block].nr = allocpages;//记录分配的页数
    nr_block++;
    for(int i = 0;i < allocpages;i++)
    {
        len = list_next(le);
        p = le2page(le,page_link);
        ClearPageProperty(p);
        le = len;
    }//修改每一页的状态
    nr_free -= allocpages;//减去已被分配的页数
    page->property = n;
    return page;
}

void
buddy_free_pages(struct Page* base, size_t n) {
  unsigned node_size, index = 0;
  unsigned left_longest, right_longest;
  struct buddy2* self = root;
  
  list_entry_t *le = list_next(&free_list);
  int i = 0;
  for(i = 0;i < nr_block;i++)//找到块
  {
    if(rec[i].base == base)
     break;
  }
  int offset = rec[i].offset;
  int pos = i;//暂存i
  i = 0;
  while(i < offset)
  {
    le = list_next(le);
    i++;
  }
  int allocpages;
  if(!IS_POWER_OF_2(n))
   allocpages = fixsize(n);
  else
  {
     allocpages = n;
  }
  assert(self && offset >= 0 && offset < self->size);//是否合法
  node_size = 1;
  index = offset + self->size - 1;
  nr_free += allocpages;//更新空闲页的数量
  struct Page* p;
  self[index].longest = allocpages;
  for(i = 0;i < allocpages;i++)//回收已分配的页
  {
     p = le2page(le,page_link);
     p->flags = 0;
     p->property = 1;
     SetPageProperty(p);
     le = list_next(le);
  }
  while (index) {//向上合并，修改先祖节点的记录值
    index = PARENT(index);
    node_size *= 2;

    left_longest = self[LEFT_LEAF(index)].longest;
    right_longest = self[RIGHT_LEAF(index)].longest;
    
    if (left_longest + right_longest == node_size) 
      self[index].longest = node_size;
    else
      self[index].longest = MAX(left_longest, right_longest);
  }
  for(i = pos;i < nr_block-1;i++)//清除此次的分配记录
  {
    rec[i] = rec[i+1];
  }
  nr_block--;//更新分配块数的值
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {
    struct Page *p0, *A, *B,*C,*D;
    p0 = A = B = C = D =NULL;

    assert((p0 = alloc_page()) != NULL);
    assert((A = alloc_page()) != NULL);
    assert((B = alloc_page()) != NULL);

    assert(p0 != A && p0 != B && A != B);
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
    free_page(p0);
    free_page(A);
    free_page(B);
    
    A=alloc_pages(500);
    B=alloc_pages(500);
    cprintf("A %p\n",A);
    cprintf("B %p\n",B);
    free_pages(A,250);
    free_pages(B,500);
    free_pages(A+250,250);
    
    p0=alloc_pages(1024);
    cprintf("p0 %p\n",p0);
    assert(p0 == A);
    //以下是根据链接中的样例测试编写的
    A=alloc_pages(70);  
    B=alloc_pages(35);
    assert(A+128==B);//检查是否相邻
    cprintf("A %p\n",A);
    cprintf("B %p\n",B);
    C=alloc_pages(80);
    assert(A+256==C);//检查C有没有和A重叠
    cprintf("C %p\n",C);
    free_pages(A,70);//释放A
    cprintf("B %p\n",B);
    D=alloc_pages(60);
    cprintf("D %p\n",D);
    assert(B+64==D);//检查B，D是否相邻
    free_pages(B,35);
    cprintf("D %p\n",D);
    free_pages(D,60);
    cprintf("C %p\n",C);
    free_pages(C,80);
    free_pages(p0,1000);//全部释放
}

const struct pmm_manager default_pmm_manager = {
    .name = "buddy_system",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};

-------------------------------------------------------------------------------------------------
.h:
#ifndef __KERN_MM_DEFAULT_PMM_H__
#define  __KERN_MM_DEFAULT_PMM_H__

#include <pmm.h>

extern const struct pmm_manager default_pmm_manager;

#endif /* ! __KERN_MM_DEFAULT_PMM_H__ */
```

测试结果：

```
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0xc0100036 (phys)
  etext  0xc010721c (phys)
  edata  0xc011d000 (phys)
  end    0xc02a49e0 (phys)
Kernel executable memory footprint: 1683KB
ebp:0xc0119f38 eip:0xc0100aa4 args:0x00010094 0x00010094 0xc0119f68 0xc01000c8
    kern/debug/kdebug.c:309: print_stackframe+22
ebp:0xc0119f48 eip:0xc0100da9 args:0x00000000 0x00000000 0x00000000 0xc0119fb8
    kern/debug/kmonitor.c:130: mon_backtrace+11
ebp:0xc0119f68 eip:0xc01000c8 args:0x00000000 0xc0119f90 0xffff0000 0xc0119f94
    kern/init/init.c:50: grade_backtrace2+34
ebp:0xc0119f88 eip:0xc01000f2 args:0x00000000 0xffff0000 0xc0119fb4 0x0000002b
    kern/init/init.c:55: grade_backtrace1+39
ebp:0xc0119fa8 eip:0xc0100111 args:0x00000000 0xc0100036 0xffff0000 0x0000001d
    kern/init/init.c:60: grade_backtrace0+24
ebp:0xc0119fc8 eip:0xc0100137 args:0xc010723c 0xc0107220 0x001879e0 0x00000000
    kern/init/init.c:65: grade_backtrace+35
ebp:0xc0119ff8 eip:0xc010008b args:0xc0107430 0xc0107438 0xc0100d31 0xc0107457
    kern/init/init.c:31: kern_init+85
memory management: buddy_system
e820map:
  memory: 0009fc00, [00000000, 0009fbff], type = 1.可以使用的物理内存空间
  memory: 00000400, [0009fc00, 0009ffff], type = 2.不能使用的物理内存空间
  memory: 00010000, [000f0000, 000fffff], type = 2.不能使用的物理内存空间
  memory: 07ee0000, [00100000, 07fdffff], type = 1.可以使用的物理内存空间
  memory: 00020000, [07fe0000, 07ffffff], type = 2.不能使用的物理内存空间
  memory: 00040000, [fffc0000, ffffffff], type = 2.不能使用的物理内存空间
A 0xc02a9164
B 0xc02ab964
p0 0xc02a9164
A 0xc02ae164
B 0xc02aeb64
C 0xc02af564
B 0xc02aeb64
D 0xc02af064
D 0xc02af064
C 0xc02af564
```