# Lab 5 Exercise

## Exercise 1

**问题：**

**do_execv函数调用load_icode（位于kern/process/proc.c中）来加载并解析一个处于内存中的ELF执行文件格式的应用程序，建立相应的用户内存空间来放置应用程序的代码段、数据段等，且要设置好proc_struct结构中的成员变量trapframe中的内容，确保在执行此进程后，能够从应用程序设定的起始执行地址开始执行。需设置正确的trapframe内容。描述当创建一个用户态进程并加载了应用程序后，CPU是如何让这个应用程序最终在用户态执行起来的。即这个用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过。**

### 解：

```
	tf->tf_cs =  USER_CS;
    tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
    tf->tf_esp = USTACKTOP;
    tf->tf_eip = elf->e_entry;
    tf->tf_eflags = 0x00000002 | FL_IF;
    ret = 0;
```

这个就很容易理解基本就是lab1中的知识，切换cs，ds等段寄存器为用户态下的，然后更新eip，esp都为用户态下的，然后对于eflags	应当初始化为中断使能，并且需要注意eflags的第1位是恒为1的；

用户态进程被ucore选择占用CPU执行（RUNNING态）到具体执行应用程序第一条指令的整个经过过程：

执行的函数流程图如下：

```
vector128(vectors.S) --> __alltraps(trapentry.S) --> trap(trap.c) --> trap_dispatch(trap.c)-->syscall(syscall.c) --> sys_exec(syscall.c) --> do_execve(proc.c)
```

1. 一直到调用do_execve之前都是在设置中断帧，和执行的用户程序的name、len、binary、size等初始化，然后直接转去调用do_execve
2. do_execve主要做的就是先清空用户态的内存空间，然后读取ELF格式的程序文件，申请内存空间，建立用户态虚拟空间，加载程序执行代码
3. 其中加载程序代码的时候需要为各个块初始化虚拟空间，并且建立vma链表来管理，还要分配对应的用户空间栈
4. 最后需要把当前mm结构的pgdir赋值给cr3寄存器也就是更新用户进程的虚拟内存空间，然后更新中断帧，以让执行中断返回指令iret之后就可以从内核态转到用户态同时还会会将堆栈切换到用户的栈，并且跳转到要求的应用程序的入口处



## Exercise 2

**问题：**

**创建子进程的函数do_fork在执行中将拷贝当前进程（即父进程）的用户内存地址空间中的合法内容到新进程中（子进程），完成内存资源的复制。具体是通过copy_range函数（位于kern/mm/pmm.c中）实现的，请补充copy_range的实现，确保能够正确执行。**

### 解：

```
char *src_kvaddr = page2kva(page);
        char *dst_kvaddr = page2kva(npage);
        memcpy(dst_kvaddr,src_kvaddr,PGSIZE);
        ret = page_insert(to, npage, start, perm);
        assert(ret == 0);
```

- page2kva：返回页面管理的内存的内核虚拟地址（SEE pmm.h）

- page_insert：用线性地址构建物理地址的映射

- memcpy：内存赋值

具体过程：

1. 找到page的内核虚拟地址
2. 找到npage的内核虚拟地址
3. 以page为source，npage为destin，进行内存赋值
4. 然后建立物理地址与线性地址的映射


## Exercise 3

**问题：**

**请在实验报告中简要说明你对 fork/exec/wait/exit函数的分析。并回答如下问题：**

- **请分析fork/exec/wait/exit在实现中是如何影响进程的执行状态的？**
- **请给出ucore中一个用户态进程的执行状态生命周期图（包执行状态，执行状态之间的变换关系，以及产生变换的事件或函数调用）。（字符方式画即可）**

### 解：

fork：在执行了fork系统调用之后，会执行正常的中断处理流程，最终将控制权转移给syscall，之后根据系统调用号执行sys_fork函数，进一步执行do_fork函数，完成新的进程的进程控制块的初始化、设置、以及将父进程内存中的内容到子进程的内存的复制工作，然后将新创建的进程放入可执行队列（runnable），这样的话在之后就有可能由调度器将子进程运行起来了；

exec：在执行了exec系统调用之后，会执行正常的中断处理流程，最终将控制权转移给syscall，之后根据系统调用号执行sys_exec函数，进一步执行do_execve函数，在该函数中，会对内存空间进行清空，然后将新的要执行的程序加载到内存中，然后设置好中断帧，使得最终中断返回之后可以跳转到指定的应用程序的入口处，就可以正确执行了；

wait：在执行了wait系统调用之后，会执行正常的中断处理流程，最终将控制权转移给syscall，之后根据系统调用号执行sys_wait函数，进一步执行do_wait函数，在这个函数中，将搜索是否指定进程存在着处于ZOMBIE态的子进程，如果有的话直接将其占用的资源释放掉即可；如果找不到这种子进程，则将当前进程的状态改成SLEEPING态，并且标记为等待ZOMBIE态的子进程，然后调用schedule函数将其当前线程从CPU占用中切换出去，直到有对应的子进程结束来唤醒这个进程为止；

exit：在执行了exit系统调用之后，会执行正常的中断处理流程，最终将控制权转移给syscall，之后根据系统调用号执行sys_exit函数，进一步执行do_exit函数，首先将释放当前进程的大多数资源，然后将其标记为ZOMBIE态，然后调用wakeup_proc函数将其父进程唤醒（如果父进程执行了wait进入SLEEPING态的话），然后调用schedule函数，让出CPU资源，等待父进程进一步完成其所有资源的回收；

```
                                                                       |---> (exit，kill系统调用) --> (ZOMBIE)
                                                                       |
                                                                       |
(新创建的子进程) --> (RUNABLE，等待运行) ---------(调度器调度)---------> [正在运行] ---------> (时间片用完，yield系统调用)
                     ↑                                                  |
                     |                                                  |(wait系统调用，且没有ZOMBIE子进程)
                     | --- (子进程唤醒，exit系统调用) <--- [sleeping]  <---|
```

## Exetend Exercise

**问题：**

**实现 Copy on Write （COW）机制给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。**

**这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。**

**由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。**

**这是一个big challenge.**

### 解：

参考资料：[https://github.com/PKUanonym/REKCARC-TSC-UHT/blob/master/%E5%A4%A7%E4%B8%89%E4%B8%8B/%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F/hw/2017/2014011330_738795_163902674_lab5-2014011330/lab5-challenge-2014011330.md](https://github.com/PKUanonym/REKCARC-TSC-UHT/blob/master/大三下/操作系统/hw/2017/2014011330_738795_163902674_lab5-2014011330/lab5-challenge-2014011330.md)

COW(写时复制)：是为了增加效率所做的操作，如果说没有COW那么在fork进程的时候，子进程会复制父进程的代码段数据段等内容，占用新的内存。如果说使用上面的方法那么假如fork了很多个进程那么内存时远远不够用的，所以COW的思想就是fork出来的子进程和父进程共享一个物理内存，但是如果这个子进程要修改某处的内容，这时候才进行复制，复制出一个新的段（比如说修改了代码段就复制代码段，其余的数据段等不会复制），这样就会大大的增加了效率也减少了内存开销。

对应着我们的代码实现，由于需要实现COW这个异常的处理，那就需要在fork进程的时候将新进程和旧进程指向的物理内存对应的页表项设置为只读，如果说我们写了只读的内存就会触发缺页异常，进而处理这个异常。现在是可以触发这个异常，但是还是没办法识别这个异常，想要识别这个异常就需要设置一个判断，即检测对应的页表项的只读位是否为1，为1则代表时COW异常，否则就是别的原因引起的缺页异常。到现在为止，触发和识别都已经做好了，剩下的就是实现COW了，首先我们会判断ref是否为1，判断ref是否为1就是判断有几个虚拟页映射到了这个物理内存，如果说只有父进程没有子进程就是为1，也就代表不需要再保护父进程的内存空间为只读的了就恢复父进程的内存空间为可读可写，如果说ref不为1也就代表现在是有子进程的并且写了只读的内存空间，就需要进行复制了，然后设置复制的子进程是可读可写的，具体代码如下：

```
pmm.c:
uint32_t perm = (*ptep & (PTE_U | PTE_P));
struct Page *page = pte2page(*ptep);
assert(page != NULL);
// Set the new mm to be readonly.
page_insert(to, page, start, perm);
// Set the old mm to be readonly
page_insert(from, page, start, perm);

vmm.c:
else {
    /*LAB3 EXERCISE 2: YOUR CODE
    * Now we think this pte is a  swap entry, we should load data from disk to a page with phy addr,
    * and map the phy addr with logical addr, trigger swap manager to record the access situation of this page.
    *
    *  Some Useful MACROs and DEFINEs, you can use them in below implementation.
    *  MACROs or Functions:
    *    swap_in(mm, addr, &page) : alloc a memory page, then according to the swap entry in PTE for addr,
    *                               find the addr of disk page, read the content of disk page into this memroy page
    *    page_insert ： build the map of phy addr of an Page with the linear addr la
    *    swap_map_swappable ： set the page swappable
    */
    /*
     * LAB5 CHALLENGE ( the implmentation Copy on Write)
        There are 2 situlations when code comes here.
          1) *ptep & PTE_P == 1, it means one process try to write a readonly page. 
             If the vma includes this addr is writable, then we can set the page writable by rewrite the *ptep.
             This method could be used to implement the Copy on Write (COW) thchnology(a fast fork process method).
          2) *ptep & PTE_P == 0 & but *ptep!=0, it means this pte is a  swap entry.
             We should add the LAB3's results here.
     */
        if (*ptep & PTE_P) {
            // Read-only possibly caused by COW.
            if (vma->vm_flags & VM_WRITE) {
                // If ref of pages == 1, it is not shared, just make pte writable.
                // else, alloc a new page, copy content and reset pte.
                // also, remember to decrease ref of that page!
                struct Page* p = pte2page(*ptep);
                assert(p != NULL);
                assert(p->ref > 0);
                if (p->ref > 1) {
                    struct Page *npage = alloc_page();
                    assert(npage != NULL);
                    void * src_kvaddr = page2kva(p);
                    void * dst_kvaddr = page2kva(npage);
                    memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
                    // addr already ROUND down.
                    page_insert(mm->pgdir, npage, addr, ((*ptep) & PTE_USER) | PTE_W);
                    // page_ref_dec(p);
                    cprintf("Handled one COW fault at %x: copied\n", addr);
                }
                else {
                    page_insert(mm->pgdir, p, addr, ((*ptep) & PTE_USER) | PTE_W);
                    cprintf("Handled one COW fault: reused\n");
                }
            }
        }
        else{
            if(swap_init_ok) {
                struct Page *page=NULL;
                //(1）According to the mm AND addr, try to load the content of right disk page
                //    into the memory which page managed.
                //(2) According to the mm, addr AND page, setup the map of phy addr <---> logical addr
                //(3) make the page swappable.
                //(4) [NOTICE]: you myabe need to update your lab3's implementation for LAB5's normal execution.

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
        }    
    }
```

测试结果如下：

测试运行命令 `make run-dirtycow`

```
Handled one COW fault at affff000: copied
Handled one COW fault at affff000: copied
Handled one COW fault at affff000: copied
Handled one COW fault at affff000: copied
Handled one COW fault at affff000: copied
Handled one COW fault: reused                                                                        
I am child 4
Handled one COW fault: reused
I am child 3
Handled one COW fault: reused
I am child 2
Handled one COW fault: reused
I am child 1
Handled one COW fault: reused
I am child 0
forktest pass.
all user-mode processes have quit.
init check memory pass. 
```

另外会在博客里写一篇关于CVE-2016-5195漏洞的分析与复现，这个漏洞是著名的脏牛漏洞，DirtyCow，它主要的利用是竞争，同时也正好利用到了lab5包括之前的知识，包括对页异常的处理等。博客地址：www.resery.top