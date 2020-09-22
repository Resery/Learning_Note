# Lab 3 Exercise

## Exercise 1：

**问题：**

**完成do_pgfault（mm/vmm.c）函数，给未被映射的地址映射上物理页。设置访问权限的时候需要参考页面所在 VMA 的权限，同时需要注意映射物理页时需要操作内存控制结构所指定的页表，而不是内核的页表。注意：在LAB3 EXERCISE 1处填写代码。执行**

```
make　qemu
```

**后，如果通过check_pgfault函数的测试后，会有“check_pgfault() succeeded!”的输出，表示练习1基本正确。**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

- **请描述页目录项（Page Directory Entry）和页表项（Page Table Entry）中组成部分对ucore实现页替换算法的潜在用处。**
- **如果ucore的缺页服务例程在执行过程中访问内存，出现了页访问异常，请问硬件要做哪些事情？**

### 解：

```
if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) {
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    }
```

- get_pte：获取一个pte并为la返回该pte的内核虚拟地址，如果不存在该pte的PT内容，请为PT分配一个页面（注意第3个参数“ 1”，这里是lab2中练习实现的函数，就是检查对应的物理地址的PTE_P位，如果不存在就分配一个页）
- pgdir_alloc_page：调用alloc_page和page_insert函数来分配页大小的内存并设置具有线性地址la和PDT pgdir的地址映射pa <---> la

具体过程：

1. 尝试去寻找一个pte，然后判断这个pte的PT位是不是存在的，如果不存在就分配一个页
2. 如果物理地址不存在，那就分配一个页并且建立好物理地址到逻辑地址的映射

## Exercise 2：

**问题：**

**完成vmm.c中的do_pgfault函数，并且在实现FIFO算法的swap_fifo.c中完成map_swappable和swap_out_victim函数。通过对swap的测试。注意：在LAB3 EXERCISE 2处填写代码。执行**

```
make　qemu
```

**后，如果通过check_swap函数的测试后，会有“check_swap() succeeded!”的输出，表示练习2基本正确。**

**请在实验报告中简要说明你的设计实现过程。**

**请在实验报告中回答如下问题：**

- **如果要在ucore上实现"extended clock页替换算法"请给你的设计方案，现有的swap_manager框架是否足以支持在ucore中实现此算法？如果是，请给你的设计方案。如果不是，请给出你的新的扩展和基此扩展的设计方案。并需要回答如下问题**
  - **需要被换出的页的特征是什么？**
  - **在ucore中如何判断具有这样特征的页？**
  - **何时进行换入和换出操作？**

### 解：

vmm.c

```
if(swap_init_ok) {
            struct Page *page=NULL;
            //(1）According to the mm AND addr, try to load the content of right disk page
            //    into the memory which page managed.
            //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
            //(3) make the page swappable.
            if ((ret = swap_in(mm, addr, &page)) != 0) {
                cprintf("swap_in in do_pgfault failed\n");
                goto failed;
            }    
            page_insert(mm->pgdir, page, addr, perm);
            swap_map_swappable(mm, addr, page, 1);
            page->pra_vaddr = addr;
        }
        else {
            cprintf("no swap_init_ok but ptep is %x, failed\n",*ptep);
            goto failed;
        }
```

swap\_fifo.c

```
list_add(head,entry);

list_entry_t *le = head->prev;
     assert(head!=le);
     struct Page *p = le2page(le, pra_page_link);
     list_del(le);
     assert(p !=NULL);
     *ptr_page = p;
```

- swap\_in(mm, addr, &page)：分配一个内存页面，然后根据PTE中addr的交换条目，找到磁盘页面的addr，将磁盘页面的内容读入该内存页面，也就是换入
- page\_insert：使用线性加法器la构建页面的phy加法器的映射
- swap\_map\_swappable：设置页面可交换

具体过程：

1. 通过mm和addr尝试去加载一个正确的磁盘页到物理内存
2. 通过mm，addr和page设置物理地址和逻辑地址的映射
3. 设置页面可交换
4. 把最近访问的页添加到pra_list_head队列中
5. unlike掉最早到达的页，也就是队列中的最后一个结点
6. 将*ptr_page的值分配给此页面的地址



## Extend Exercise ：

**问题：**

**实现识别dirty bit的 extended clock页替换算法（需要编程）**

### 解：

extended clock页替换算法介绍：

extended是属于clock时钟页替换算法的升级版，clock时钟页替换算法，主要的思想是利用硬件设置一个访问位，如果说访问位是1，则代表这个页最近使用过不能淘汰，如果说访问位是0，则代表这个也最近没有使用过，则淘汰这个页，更具体一点就是，时钟页替换算法把各个页面组织成环形链表的形式，类似于一个钟的表面。然后把一个指针（简称当前指针）指向最老的那个页面，即最先进来的那个页面。另外，时钟算法需要在页表项（PTE）中设置了一位访问位来表示此页表项对应的页当前是否被访问过。当该页被访问时，CPU中的MMU硬件将把访问位置“1”。当操作系统需要淘汰页时，对当前指针指向的页所对应的页表项进行查询，如果访问位为“0”，则淘汰该页，如果该页被写过，则还要把它换出到硬盘上；如果访问位为“1”，则将该页表项的此位置“0”，继续访问下一个页。有一点需要注意虽然前面说了如果访问位为0并且该页被写过的话，就需要把这个页换到磁盘上，但是时钟页替换算法里并没有实现这个功能它只是0淘汰1留下这样的；随之就会有问题出现即如果说当前要淘汰的页是访问位为0但是被修改过的就需要进行替换，但是内存中还有访问位为0并且没被修改过的页，如果说淘汰后一种情况的页就会减少I/O的操作从而增加效率（因为I/O到内存之间的速度并不是特别快），所以就有了**extended clock页替换算法**，extended clock页替换算法增加了一位修改位，即对应着四种情况

1. 最近未访问，并且没被修改过：访问位为0，修改位为0
2. 最近未访问，但是修改过：访问位为0，修改位为1
3. 最近访问过，但是没修改过：访问位为1，修改位为0
4. 最近访问过，并且也修改过：访问位为1，修改位为1

这四种情况也正好对应着淘汰的优先级，1>2>3>4，最好情况1，差一点2，再差一点3，最差就只能是4了，extended clock页替换算法还有一个需要注意的就是每次指针经过时，会将访问位置0，如果访问位已经为0，则将Dirty Bit置0。如果dirty bit已经为0，则直接置换该页。尽可能的让脏页在一次时钟中保留，也就是尽可能置换只读的页。

所以对应着我们的extended clock页替换算法实现也就要对应着上面的步骤，做三次循环

1. 寻找最近未访问且未被修改过的页，同时将访问过的页的访问位清零
2. 继续寻找最近未访问且未被修改过的页，同时将被修改过的页的修改位清零
3. 还是寻找最近未访问且未被修改过的页，这时因为1，2循环已经将访问位和修改位全部清零了，所以说就一定会有访问位为0并且修改位为0的页，然后淘汰这个页

代码如下：

```
static int 
_fifo_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick) {
    list_entry_t *head = (list_entry_t*)mm->sm_priv;
    assert(head != NULL);
    assert(in_tick == 0);
    list_entry_t *le = head->prev;
    assert(head != le);

    int i;
    for (i = 0; i < 2; i++) {
        while (le != head) {
            struct Page *page = le2page(le, pra_page_link);            
            pte_t *ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);

            if (!(*ptep & PTE_A) && !(*ptep & PTE_D)) {
                list_del(le);
                *ptr_page = page;
                return 0;
            }
            if (i == 0) {
                *ptep &= 0xFFFFFFDF;
            } else if (i == 1) {
                *ptep &= 0xFFFFFFBF;
            }
            le = le->prev;
        }
        le = le->prev;
    }
}
```
