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



## Extend Exercise 1：

**问题：**

**实现识别dirty bit的 extended clock页替换算法（需要编程）**

### 解：



## Extend Exercise 2：

**问题：**

**实现不考虑实现开销和效率的LRU页替换算法（需要编程）**

### 解：

