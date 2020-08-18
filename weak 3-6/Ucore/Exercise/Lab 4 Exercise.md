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

## Extend Exercise：

**问题：**

**实现支持任意大小的内存分配算法**

**这不是本实验的内容，其实是上一次实验内存的扩展，但考虑到现在的slab算法比较复杂，有必要实现一个比较简单的任意大小内存分配算法。可参考本实验中的slab如何调用基于页的内存分配算法（注意，不是要你关注slab的具体实现）来实现first-fit/best-fit/worst-fit/buddy等支持任意大小的内存分配算法。。**

**【注意】下面是相关的Linux实现文档，供参考**

**SLOB**

**http://en.wikipedia.org/wiki/SLOB http://lwn.net/Articles/157944/**

**SLAB**

**https://www.ibm.com/developerworks/cn/linux/l-linux-slab-allocator/**

### 解：

内容来自：[https://github.com/PKUanonym/REKCARC-TSC-UHT/blob/master/%E5%A4%A7%E4%B8%89%E4%B8%8B/%E6%93%8D%E4%BD%9C%E7%B3%BB%E7%BB%9F/hw/2017/2014011330_738793_537703740_lab4-2014011330/lab4-challenge-2014011330.md](https://github.com/PKUanonym/REKCARC-TSC-UHT/blob/master/大三下/操作系统/hw/2017/2014011330_738793_537703740_lab4-2014011330/lab4-challenge-2014011330.md)

稍加修改

实现思路：

首先确定所实现`kmalloc`在uCore内存管理中所处的地位，才能更好地理解函数调用关系。

在内核中，uCore的内存管理分为物理内存管理`pmm`和虚拟内存管理`vmm`。虚拟内存管理模块只负责管理页式地址映射关系，不负责具体的内存分配。而物理内存管理模块`pmm`不仅要管理连续的物理内存，还要能够向上提供分配内存的接口`alloc_pages`，分配出的物理内存区域可以转换为内核态可访问的区域（只要偏移`KERNBASE`）即可；也可以做地址映射转换给用户态程序使用。

但是，`alloc_pages`仅仅提供以页为粒度的物理内存分配，在uCore内核中，会频繁分配小型动态的数据结构（诸如`vma_struct`和`proc_struct`），这样以页为粒度进行分配既不节省空间，速度还慢，需要有一个接口能够提供更加细粒度的内存分配与释放工作，这就是slab和slob出现的原因：他们是一个中间件，底层调用`alloc_pages`接口，上层提供`kmalloc`接口，内部通过一系列机制管理页和内存小块的关系。需要注意的一点是：用户态的`libc`提供的`malloc`接口并不是利用了与`kmalloc`相同的机制，而是由`libc`自己管理的一套小型内存分配机制。（回忆汇编课程上讲过使用`brk`系统调用完成的内存申请实际上是以页为粒度的）

仔细阅读Lab4中原有的slob代码，在每个小块内存的头部都存放了该块的大小和下一个空闲块的地址。`kmalloc`函数会首先判断需要分配的空间是否跨页，如果是则直接调用`alloc_pages`进行分配，否则就调用`slob_alloc`进行分配。巧妙的一点是，为了管理所有申请的连续物理空间页，Lab4建立了`bigblock`这一数据结构，而这个数据结构自身所占的内存空间如何分配呢？结论是`slob_alloc`！Lab4就这样将二者耦合到了一起。

具体到`Best-Fit`算法的实现，实际很简单，仅仅需要在扫描空闲链表的时候动态记录与更新最好的块的地址即可（这里是因为best-fit管理的空闲链表是按大小顺序排的，所以说只需要更新最好的块的地址即可），扫描完成之后，再选出刚刚找到的最合适的空间进行分配即可。无论是`First-Fit`、`Best-Fit`还是`Worst-Fit`，其释放的合并策略都是相同的，因此只需要修改`slob_alloc`函数即可。

Best-Fit算法的更具体一点的内容就是，他对应的空闲链表是按大小顺序排的，而first-fit是按地址排的，best-fit会在链表中找到空闲块大小是大于分配块的大小的所有快中最小的哪一个块，这样就可以避免内部碎片的麻烦，同时在释放的时候也会进行合并来保证当有大的块申请的时候也会有大的块与之对应。

下面的代码主要是分成了两种情况，一种是正好有大小为分配的size的空闲块，一种是大小比要分配的size的大一点的空闲块，针对两种情况做出不同的反应，第一种情况就会直接返回这个块的地址意思就是这个块被分配了，第二种情况就会继续在链表中寻找，寻找出比size大的空闲块中的最小的块，一直找到链表尾部，然后检测是否找到了如果说找到了就需要对这个块进行切割，切割完成之后就返回这个块，如果说没有找到合适的块，就会先检测一下是不是size过大，比如说size是4k（一个页的大小）那就直接返回0，如果不是因为过大，就去调用默认的分配算法如果说默认的分配算法返回的还是null那就证明没有大于size的内存块了，如果说调用默认的分配算法返回的不是空那就代表还是有的，就看看可不可以把空闲块合并一下

代码如下：

```
static void *best_fit_alloc(size_t size, gfp_t gfp, int align)
{
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
  // This best fit allocator does not consider situations where align != 0
  assert(align == 0);
  int units = SLOB_UNITS(size);

  unsigned long flags;
  spin_lock_irqsave(&slob_lock, flags);

  slob_t *prev = slobfree, *cur = slobfree->next;
  int find_available = 0;
  int best_frag_units = 100000;
  slob_t *best_slob = NULL;
  slob_t *best_slob_prev = NULL;

  for (; ; prev = cur, cur = cur->next) {
    if (cur->units >= units) {
      // Find available one.
      if (cur->units == units) {
        // If found a perfect one...
        prev->next = cur->next;
        slobfree = prev;
        spin_unlock_irqrestore(&slob_lock, flags);
        // That's it!
        return cur;
      }
      else {
        // This is not a prefect one.
        if (cur->units - units < best_frag_units) {
          // This seems to be better than previous one.
          best_frag_units = cur->units - units;
          best_slob = cur;
          best_slob_prev = prev;
          find_available = 1;
        }
      }

    }

    // Get to the end of iteration.
    if (cur == slobfree) {
      if (find_available) {
        // use the found best fit.
        best_slob_prev->next = best_slob + units;
        best_slob_prev->next->units = best_frag_units;
        best_slob_prev->next->next = best_slob->next;
        best_slob->units = units;
        slobfree = best_slob_prev;
        spin_unlock_irqrestore(&slob_lock, flags);
        // That's it!
        return best_slob;
      }
      // Initially, there's no available arena. So get some.
      spin_unlock_irqrestore(&slob_lock, flags);
      if (size == PAGE_SIZE) return 0;

      cur = (slob_t *)__slob_get_free_page(gfp);
      if (!cur) return 0;

      slob_free(cur, PAGE_SIZE);
      spin_lock_irqsave(&slob_lock, flags);
      cur = slobfree;
    }
  }
}
```



