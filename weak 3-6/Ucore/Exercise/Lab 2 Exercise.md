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

## Extend Exercise 1

## Extend Exercise 2