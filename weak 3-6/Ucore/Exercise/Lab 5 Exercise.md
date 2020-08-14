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

## Exetend Exercise 1

**问题：**

**实现 Copy on Write （COW）机制给出实现源码,测试用例和设计报告（包括在cow情况下的各种状态转换（类似有限状态自动机）的说明）。**

**这个扩展练习涉及到本实验和上一个实验“虚拟内存管理”。在ucore操作系统中，当一个用户父进程创建自己的子进程时，父进程会把其申请的用户空间设置为只读，子进程可共享父进程占用的用户内存空间中的页面（这就是一个共享的资源）。当其中任何一个进程修改此用户内存空间中的某页面时，ucore会通过page fault异常获知该操作，并完成拷贝内存页面，使得两个进程都有各自的内存页面。这样一个进程所做的修改不会被另外一个进程可见了。请在ucore中实现这样的COW机制。**

**由于COW实现比较复杂，容易引入bug，请参考 https://dirtycow.ninja/ 看看能否在ucore的COW实现中模拟这个错误和解决方案。需要有解释。**

**这是一个big challenge.**

### 解：