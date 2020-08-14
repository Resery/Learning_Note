# Lab 4 Exercise

## Exercise 1：

**问题：**

**alloc_proc函数（位于kern/process/proc.c中）负责分配并返回一个新的struct proc_struct结构，用于存储新建立的内核线程的管理信息。ucore需要对这个结构进行最基本的初始化，你需要完成这个初始化过程。**

> **【提示】在alloc_proc函数的实现中，需要初始化的proc_struct结构中的成员变量至少包括：state/pid/runs/kstack/need_resched/parent/mm/context/tf/cr3/flags/name。**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

- **请说明proc_struct中`struct context context`和`struct trapframe *tf`成员变量含义和在本实验中的作用是啥？（提示通过看代码和编程调试可以判断出来）**

### 解：

```
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
    if (proc != NULL) {
      proc->state = PROC_UNINIT;
      proc->pid = -1;
      proc->runs = 0;                                  
      proc->kstack = 0;
      proc->need_resched = 0;
      proc->parent = NULL;
      proc->mm = NULL;
      memset(&(proc->context),0,sizeof(struct context));
      proc->tf = NULL;
      proc->cr3 = boot_cr3;
      proc->flags = 0;
      memset(&(proc->name),0,PROC_NAME_LEN);
    }
    return proc;
}
```

1. 设置状态为未初始化状态，即刚刚创建还没成长
2. 设置pid为-1，也就是对应着进程是刚初始化还没有张完全
3. 设置cr3为boot_cr3指向内核页表的起始地址，因为内核线程是在内核中运行的所以页表就指向了内核的起始页表
4. 其余的都初始化为0即可

`struct context context`和`struct trapframe *tf`的作用：

tf是用来放置保存内核线程的临时中断帧用来指向栈中保存上下文的地方，context是在进程切换到时候保存上下文用的。

## Exercise 2：

**问题：**

**创建一个内核线程需要分配和设置好很多资源。kernel_thread函数通过调用do_fork函数完成具体内核线程的创建工作。do_kernel函数会调用alloc_proc函数来分配并初始化一个进程控制块，但alloc_proc只是找到了一小块内存用以记录进程的必要信息，并没有实际分配这些资源。ucore一般通过do_fork实际创建新的内核线程。do_fork的作用是，创建当前内核线程的一个副本，它们的执行上下文、代码、数据都一样，但是存储位置不同。在这个过程中，需要给新内核线程分配资源，并且复制原进程的状态。你需要完成在kern/process/proc.c中的do_fork函数中的处理过程。它的大致执行步骤包括：**

- **调用alloc_proc，首先获得一块用户信息块。**
- **为进程分配一个内核栈。**
- **复制原进程的内存管理信息到新进程（但内核线程不必做此事）**
- **复制原进程上下文到新进程**
- **将新进程添加到进程列表**
- **唤醒新进程**
- **返回新进程号**

**请在实验报告中简要说明你的设计实现过程。请回答如下问题：**

- **请说明ucore是否做到给每个新fork的线程一个唯一的id？请说明你的分析和理由。**

### 解：

```
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    
    if((initproc = alloc_proc()) == NULL){
      goto fork_out;
    }

    initproc->parent = current;

    if(setup_kstack(initproc) != 0){
      goto bad_fork_cleanup_proc;
    }
    
    if(copy_mm(clone_flags,initproc) != 0){
      goto bad_fork_cleanup_kstack;
    }
    
    copy_thread(initproc,stack,tf);

    bool intr_flag;
    local_intr_save(intr_flag);

    initproc->pid = get_pid();
    hash_proc(initproc);
    list_add(&proc_list, &(initproc->list_link));

    local_intr_restore(intr_flag);

    wakeup_proc(initproc);

    nr_process++;

    ret = initproc->pid;

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(initproc);
bad_fork_cleanup_proc:
    kfree(initproc);
    goto fork_out;
}
```

- alloc_proc：创建一个prco数据结构并初始化
- setup_kstack：创建一个kstackpage作为内核栈，大小就是两个物理页大小即2*4k，8k
- copy_mm：proc复制当前进程的mm或根据clone_flags共享进程当前的mm，如果（clone_flags & CLONE_VM）成立则共享否则复制
- copy_thread：在内核栈顶设置中断帧并且设置内核的入口点和进程栈
- hash_proc：添加进程到哈希表中
- get_pid：获取进程pid
- wakeup_proc：设置进程的状态为PROC_RUNABLE

具体过程

1. 创建一个proc数据结构并初始化
2. 调用setup_kstack来为子进程创建一个内核栈
3. 调用copy_mm并通过clone_flag来复制或共享mm
4. 调用copy_thread来在proc结构中设置tf和上下文
5. 把proc添加到哈希表和链表中
6. 调用wakeup_proc来设置进程的状态为PROC_RUNABLE
7. 设置返回值为子进程的pid

其中需要注意一些问题，即需要屏蔽中断和恢复中断，自己一开始没有考虑这个问题，最后看了答案发现答案中涉及到了这一步。

## Exercise 3：

**问题：**

**请在实验报告中简要说明你对proc_run函数的分析。并回答如下问题：**

- **在本实验的执行过程中，创建且运行了几个内核线程？**
- **语句`local_intr_save(intr_flag);....local_intr_restore(intr_flag);`在这里有何作用?请说明理由**

### 解：

两个内核线程，idleproc和initproc

他们的作用是来屏蔽中断和恢复中断，在进程切换的时候如果被另一个中断打断了，就会导致进程切换未完成，就可能会导致内核在处理完中断之后，转而去执行的就不是预想的地方，而是某些不可执行的地方，导致崩溃。

## Extend Exercise 1：

**问题：**

**实现支持任意大小的内存分配算法**

