# Lab 4

## 基础知识

### 实验执行流程概述

kern\_init函数中，当完成虚拟内存的初始化工作后，就调用了proc\_init函数，这个函数完成了idleproc内核线程和initproc内核线程的创建或复制工作，这也是本次实验要完成的练习。idleproc内核线程的工作就是不停地查询，看是否有其他内核线程可以执行了，如果有，马上让调度器选择那个内核线程执行（请参考cpu\_idle函数的实现）。所以idleproc内核线程是在ucore操作系统没有其他内核线程可执行的情况下才会被调用。接着就是调用kernel\_thread函数来创建initproc内核线程。initproc内核线程的工作就是显示“Hello World”，表明自己存在且能正常工作了。

调度器会在特定的调度点上执行调度，完成进程切换。在lab4中，这个调度点就一处，即在cpu\_idle函数中，此函数如果发现当前进程（也就是idleproc）的need\_resched置为1（在初始化idleproc的进程控制块时就置为1了），则调用schedule函数，完成进程调度和进程切换。进程调度的过程其实比较简单，就是在进程控制块链表中查找到一个“合适”的内核线程，所谓“合适”就是指内核线程处于“PROC_RUNNABLE”状态。在接下来的switch_to函数(在后续有详细分析，有一定难度，需深入了解一下)完成具体的进程切换过程。一旦切换成功，那么initproc内核线程就可以通过显示字符串来表明本次实验成功。

接下来将主要介绍了进程创建所需的重要数据结构--进程控制块 proc\_struct，以及ucore创建并执行内核线程idleproc和initproc的两种不同方式，特别是创建initproc的方式将被延续到实验五中，扩展为创建用户进程的主要方式。另外，还初步涉及了进程调度（实验六涉及并会扩展）和进程切换内容。

### 关键数据结构 -- 进程控制块

```
struct proc_struct {
    enum proc_state state; // Process state
    int pid; // Process ID
    int runs; // the running times of Proces
    uintptr_t kstack; // Process kernel stack
    volatile bool need_resched; // need to be rescheduled to release CPU?
    struct proc_struct *parent; // the parent process
    struct mm_struct *mm; // Process's memory management field
    struct context context; // Switch here to run process
    struct trapframe *tf; // Trap frame for current interrupt
    uintptr_t cr3; // the base addr of Page Directroy Table(PDT)
    uint32_t flags; // Process flag
    char name[PROC_NAME_LEN + 1]; // Process name
    list_entry_t list_link; // Process link list
    list_entry_t hash_link; // Process hash list
};
```

- state：进程所处的状态，一共有四种状态`PROC_UNINIT`、`PROC_SLEEPING`、`PROC_RUNNABLE`、`PROC_ZOMBIE`，分别对应未初始化，已初始化但未运行即睡眠状态，可以运行状态、马上就要结束等待父进程回收

- pid：进程ID

- runs：进程运行的次数

- kstack：每个线程都有一个内核栈，并且位于内核地址空间的不同位置。对于内核线程，该栈就是运行时的程序使用的栈；而对于普通进程，该栈是发生特权级改变的时候使保存被打断的硬件信息用的栈。uCore在创建进程时分配了 2 个连续的物理页作为内核栈的空间。

  ```
  对应代码位于  memlayout.h
  
  #define KSTACKPAGE          2                           // # of pages in kernel stack
  #define KSTACKSIZE          (KSTACKPAGE * PGSIZE)       // sizeof kernel stack
  ```

  这个栈很小，所以内核中的代码应该尽可能的紧凑，并且避免在栈上分配大的数据结构，以免栈溢出，导致系统崩溃。kstack记录了分配给该进程/线程的内核栈的位置。主要作用有以下几点。首先，当内核准备从一个进程切换到另一个的时候，需要根据kstack 的值正确的设置好 tss （可以回顾一下在实验一中讲述的 tss 在中断处理过程中的作用），以便在进程切换以后再发生中断时能够使用正确的栈。其次，内核栈位于内核地址空间，并且是不共享的（每个线程都拥有自己的内核栈），因此不受到 mm 的管理，当进程退出的时候，内核能够根据 kstack 的值快速定位栈的位置并进行回收。uCore 的这种内核栈的设计借鉴的是 linux 的方法（但由于内存管理实现的差异，它实现的远不如 linux 的灵活），它使得每个线程的内核栈在不同的位置，这样从某种程度上方便调试，但同时也使得内核对栈溢出变得十分不敏感，因为一旦发生溢出，它极可能污染内核中其它的数据使得内核崩溃。如果能够通过页表，将所有进程的内核栈映射到固定的地址上去，能够避免这种问题，但又会使得进程切换过程中对栈的修改变得相当繁琐。

  为了管理系统中所有的进程控制块，uCore维护了如下全局变量（位于kern/process/proc.c）：

  ```
  // has list for process set based on pid
  static list_entry_t hash_list[HASH_LIST_SIZE];
  
  // idle proc
  struct proc_struct *idleproc = NULL;
  // init proc
  struct proc_struct *initproc = NULL;
  // current proc
  struct proc_struct *current = NULL;
  
  static int nr_process = 0;
  
  list_entry_t proc_list;
  ```

  - hash\_list：所有进程控制块的哈希表，proc_struct中的成员变量hash_link将基于pid链接入这个哈希表中。
  - idleproc：第0个内核线程
  - initproc：第1个内核线程
  - current：当前占用CPU且处于“运行”状态进程控制块指针。通常这个变量是只读的，只有在进程切换的时候才进行修改，并且整个切换和修改过程需要保证操作的原子性，目前至少需要屏蔽中断。
  - nr\_process：进程集合中的进程数量
  - proc\_list：所有进程控制块的双向线性列表，proc_struct中的成员变量list_link将链接入这个链表中。

- need_resched：值对应着是否需要重新计划以释放CPU

- parent：用户进程的父进程（创建它的进程）。在所有进程中，只有一个进程没有父进程，就是内核创建的第一个内核线程idleproc。内核根据这个父子关系建立一个树形结构，用于维护一些特殊的操作，例如确定某个进程是否可以对另外一个进程进行某种操作等等。

- mm：内存管理的信息，包括内存映射列表、页表指针等。mm成员变量在lab3中用于虚存管理。但在实际OS中，内核线程常驻内存，不需要考虑swap page问题，在lab5中涉及到了用户进程，才考虑进程用户内存空间的swap page问题，mm才会发挥作用。所以在lab4中mm对于内核线程就没有用了，这样内核线程的proc\_struct的成员变量\*mm=0是合理的。mm里有个很重要的项pgdir，记录的是该进程使用的一级页表的物理地址。由于\*mm=NULL，所以在proc_struct数据结构中需要有一个代替pgdir项来记录页表起始地址，这就是proc_struct数据结构中的cr3成员变量。

- context：进程的上下文，用于进程切换（参见代码分析中的switch.S）。在 uCore中，所有的进程在内核中也是相对独立的（例如独立的内核堆栈以及上下文等等）。使用 context 保存寄存器的目的就在于在内核态中能够进行上下文之间的切换。实际利用context进行上下文切换的函数是在kern/process/switch.S中定义switch_to。

- tf：中断帧的指针，总是指向内核栈的某个位置：当进程从用户空间跳到内核空间时，中断帧记录了进程在被中断前的状态。当内核需要跳回用户空间时，需要调整中断帧以恢复让进程继续执行的各寄存器值。除此之外，uCore内核允许嵌套中断。因此为了保证嵌套中断发生时tf 总是能够指向当前的trapframe，uCore 在内核栈上维护了 tf 的链，可以参考trap.c::trap函数做进一步的了解。

- cr3：cr3 保存页表的物理地址，目的就是进程切换的时候方便直接使用 lcr3实现页表切换，避免每次都根据 mm 来计算 cr3。mm数据结构是用来实现用户空间的虚存管理的，但是内核线程没有用户空间，它执行的只是内核中的一小段代码（通常是一小段函数），所以它没有mm 结构，也就是NULL。当某个进程是一个普通用户态进程的时候，PCB 中的 cr3 就是 mm 中页表（pgdir）的物理地址；而当它是内核线程的时候，cr3 等于boot_cr3。而boot_cr3指向了uCore启动时建立好的内核虚拟空间的页目录表首地址。

- flags：进程的标志

- name：进程的名字

- list_link：进程链表

- hash_link：进程哈希表

### 创建第 0 个内核线程 idleproc

在init.c::kern_init函数调用了proc.c::proc_init函数。proc_init函数启动了创建内核线程的步骤。首先当前的执行上下文（从kern_init 启动至今）就可以看成是uCore内核（也可看做是内核进程）中的一个内核线程的上下文。为此，uCore通过给当前执行的上下文分配一个进程控制块以及对它进行相应初始化，将其打造成第0个内核线程 -- idleproc。具体步骤如下：

首先调用alloc_proc函数来通过kmalloc函数获得proc_struct结构的一块内存块-，作为第0个进程控制块。并把proc进行初步初始化（即把proc_struct中的各个成员变量清零）。但有些成员变量设置了特殊的值，比如：

```
 proc->state = PROC_UNINIT;  设置进程为“初始”态
 proc->pid = -1;             设置进程pid的未初始化值
 proc->cr3 = boot_cr3;       使用内核页目录表的基址
 ...
```

上述三条语句中,第一条设置了进程的状态为“初始”态，这表示进程已经 “出生”了，正在获取资源茁壮成长中；第二条语句设置了进程的pid为-1，这表示进程的“身份证号”还没有办好；第三条语句表明由于该内核线程在内核中运行，故采用为uCore内核已经建立的页表，即设置为在uCore内核页表的起始地址boot_cr3。后续实验中可进一步看出所有内核线程的内核虚地址空间（也包括物理地址空间）是相同的。既然内核线程共用一个映射内核空间的页表，这表示内核空间对所有内核线程都是“可见”的，所以更精确地说，这些内核线程都应该是从属于同一个唯一的“大内核进程”—uCore内核。

接下来，proc_init函数对idleproc内核线程进行进一步初始化：

```
idleproc->pid = 0;
idleproc->state = PROC_RUNNABLE;
idleproc->kstack = (uintptr_t)bootstack;
idleproc->need_resched = 1;
set_proc_name(idleproc, "idle");
```

需要注意前4条语句。第一条语句给了idleproc合法的身份证号--0，这名正言顺地表明了idleproc是第0个内核线程。通常可以通过pid的赋值来表示线程的创建和身份确定。“0”是第一个的表示方法是计算机领域所特有的，比如C语言定义的第一个数组元素的小标也是“0”。第二条语句改变了idleproc的状态，使得它从“出生”转到了“准备工作”，就差uCore调度它执行了。第三条语句设置了idleproc所使用的内核栈的起始地址。需要注意以后的其他线程的内核栈都需要通过分配获得，因为uCore启动时设置的内核栈直接分配给idleproc使用了。第四条很重要，因为uCore希望当前CPU应该做更有用的工作，而不是运行idleproc这个“无所事事”的内核线程，所以把idleproc->need_resched设置为“1”，结合idleproc的执行主体--cpu_idle函数的实现，可以清楚看出如果当前idleproc在执行，则只要此标志为1，马上就调用schedule函数要求调度器切换其他进程执行。

### 创建第 1 个内核线程 initproc

第0个内核线程主要工作是完成内核中各个子系统的初始化，然后就通过执行cpu_idle函数开始过退休生活了。所以uCore接下来还需创建其他进程来完成各种工作，但idleproc内核子线程自己不想做，于是就通过调用kernel_thread函数创建了一个内核线程init_main。在实验四中，这个子内核线程的工作就是输出一些字符串，然后就返回了（参看init_main函数）。但在后续的实验中，init_main的工作就是创建特定的其他内核线程或用户进程（实验五涉及）。下面我们来分析一下创建内核线程的函数kernel_thread：

```
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags)
{
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.tf_cs = KERNEL_CS;
    tf.tf_ds = tf_struct.tf_es = tf_struct.tf_ss = KERNEL_DS;
    tf.tf_regs.reg_ebx = (uint32_t)fn;
    tf.tf_regs.reg_edx = (uint32_t)arg;
    tf.tf_eip = (uint32_t)kernel_thread_entry;
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
}
```

注意，kernel_thread函数采用了局部变量tf来放置保存内核线程的临时中断帧，并把中断帧的指针传递给do_fork函数，而do_fork函数会调用copy_thread函数来在新创建的进程内核栈上专门给进程的中断帧分配一块空间。

给中断帧分配完空间后，就需要构造新进程的中断帧，具体过程是：首先给tf进行清零初始化，并设置中断帧的代码段（tf.tf_cs）和数据段(tf.tf_ds/tf_es/tf_ss)为内核空间的段（KERNEL_CS/KERNEL_DS），这实际上也说明了initproc内核线程在内核空间中执行。而initproc内核线程从哪里开始执行呢？tf.tf_eip的指出了是kernel_thread_entry（位于kern/process/entry.S中），kernel_thread_entry是entry.S中实现的汇编函数，它做的事情很简单：

```
kernel_thread_entry: # void kernel_thread(void)
pushl %edx # push arg
call *%ebx # call fn
pushl %eax # save the return value of fn(arg)
call do_exit # call do_exit to terminate current thread
```

从上可以看出，kernel_thread_entry函数主要为内核线程的主体fn函数做了一个准备开始和结束运行的“壳”，并把函数fn的参数arg（保存在edx寄存器中）压栈，然后调用fn函数，把函数返回值eax寄存器内容压栈，调用do_exit函数退出线程执行。

do_fork是创建线程的主要函数。kernel_thread函数通过调用do_fork函数最终完成了内核线程的创建工作。下面我们来分析一下do_fork函数的实现（练习2）。do_fork函数主要做了以下6件事情：

1. 分配并初始化进程控制块（alloc_proc函数）；
2. 分配并初始化内核栈（setup_stack函数）；
3. 根据clone_flag标志复制或共享进程内存管理结构（copy_mm函数）；
4. 设置进程在内核（将来也包括用户态）正常运行和调度所需的中断帧和执行上下文（copy_thread函数）；
5. 把设置好的进程控制块放入hash_list和proc_list两个全局进程链表中；
6. 自此，进程已经准备好执行了，把进程状态设置为“就绪”态；
7. 设置返回码为子进程的id号。

这里需要注意的是，如果上述前3步执行没有成功，则需要做对应的出错处理，把相关已经占有的内存释放掉。copy_mm函数目前只是把current->mm设置为NULL，这是由于目前在实验四中只能创建内核线程，proc->mm描述的是进程用户态空间的情况，所以目前mm还用不上。copy_thread函数做的事情比较多，代码如下：

```
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    //在内核堆栈的顶部设置中断帧大小的一块栈空间
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
    *(proc->tf) = *tf; //拷贝在kernel_thread函数建立的临时中断帧的初始值
    proc->tf->tf_regs.reg_eax = 0;
    //设置子进程/线程执行完do_fork后的返回值
    proc->tf->tf_esp = esp; //设置中断帧中的栈指针esp
    proc->tf->tf_eflags |= FL_IF; //使能中断
    proc->context.eip = (uintptr_t)forkret;
    proc->context.esp = (uintptr_t)(proc->tf);
}
```

此函数首先在内核堆栈的顶部设置中断帧大小的一块栈空间，并在此空间中拷贝在kernel_thread函数建立的临时中断帧的初始值，并进一步设置中断帧中的栈指针esp和标志寄存器eflags，特别是eflags设置了FL_IF标志，这表示此内核线程在执行过程中，能响应中断，打断当前的执行。执行到这步后，此进程的中断帧就建立好了，对于initproc而言，它的中断帧如下所示：

```
//所在地址位置
initproc->tf= (proc->kstack+KSTACKSIZE) – sizeof (struct trapframe);
//具体内容
initproc->tf.tf_cs = KERNEL_CS;
initproc->tf.tf_ds = initproc->tf.tf_es = initproc->tf.tf_ss = KERNEL_DS;
initproc->tf.tf_regs.reg_ebx = (uint32_t)init_main;
initproc->tf.tf_regs.reg_edx = (uint32_t) ADDRESS of "Helloworld!!";
initproc->tf.tf_eip = (uint32_t)kernel_thread_entry;
initproc->tf.tf_regs.reg_eax = 0;
initproc->tf.tf_esp = esp;
initproc->tf.tf_eflags |= FL_IF;
```

设置好中断帧后，最后就是设置initproc的进程上下文，（process context，也称执行现场）了。只有设置好执行现场后，一旦uCore调度器选择了initproc执行，就需要根据initproc->context中保存的执行现场来恢复initproc的执行。这里设置了initproc的执行现场中主要的两个信息：上次停止执行时的下一条指令地址context.eip和上次停止执行时的堆栈地址context.esp。其实initproc还没有执行过，所以这其实就是initproc实际执行的第一条指令地址和堆栈指针。可以看出，由于initproc的中断帧占用了实际给initproc分配的栈空间的顶部，所以initproc就只能把栈顶指针context.esp设置在initproc的中断帧的起始位置。根据context.eip的赋值，可以知道initproc实际开始执行的地方在forkret函数（主要完成do_fork函数返回的处理工作）处。至此，initproc内核线程已经做好准备执行了。

### 调度并执行内核线程 initproc

在uCore执行完proc_init函数后，就创建好了两个内核线程：idleproc和initproc，这时uCore当前的执行现场就是idleproc，等到执行到init函数的最后一个函数cpu_idle之前，uCore的所有初始化工作就结束了，idleproc将通过执行cpu_idle函数让出CPU，给其它内核线程执行，具体过程如下：

```
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
            ……
```

首先，判断当前内核线程idleproc的need_resched是否不为0，回顾前面“创建第一个内核线程idleproc”中的描述，proc_init函数在初始化idleproc中，就把idleproc->need_resched置为1了，所以会马上调用schedule函数找其他处于“就绪”态的进程执行。

uCore在实验四中只实现了一个最简单的FIFO调度器，其核心就是schedule函数。它的执行逻辑很简单：

1. 设置当前内核线程current->need\_resched为0； 
2. 在proc_list队列中查找下一个处于“就绪”态的线程或进程next； 
3. 找到这样的进程后，就调用proc\_run函数，保存当前进程current的执行现场（进程上下文），恢复新进程的执行现场，完成进程切换。

至此，新的进程next就开始执行了。由于在proc中只有两个内核线程，且idleproc要让出CPU给initproc执行，我们可以看到schedule函数通过查找proc_list进程队列，只能找到一个处于“就绪”态的initproc内核线程。并通过proc_run和进一步的switch_to函数完成两个执行现场的切换，具体流程如下：

1. 让current指向next内核线程initproc；
2. 设置任务状态段ts中特权态0下的栈顶指针esp0为next内核线程initproc的内核栈的栈顶，即next->kstack + KSTACKSIZE ；
3. 设置CR3寄存器的值为next内核线程initproc的页目录表起始地址next->cr3，这实际上是完成进程间的页表切换；
4. 由switch_to函数完成具体的两个线程的执行现场切换，即切换各个寄存器，当switch_to函数执行完“ret”指令后，就切换到initproc执行了。

注意，在第二步设置任务状态段ts中特权态0下的栈顶指针esp0的目的是建立好内核线程或将来用户线程在执行特权态切换（从特权态0<-->特权态3，或从特权态3<-->特权态3）时能够正确定位处于特权态0时进程的内核栈的栈顶，而这个栈顶其实放了一个trapframe结构的内存空间。如果是在特权态3发生了中断/异常/系统调用，则CPU会从特权态3-->特权态0，且CPU从此栈顶（当前被打断进程的内核栈顶）开始压栈来保存被中断/异常/系统调用打断的用户态执行现场；如果是在特权态0发生了中断/异常/系统调用，则CPU会从从当前内核栈指针esp所指的位置开始压栈保存被中断/异常/系统调用打断的内核态执行现场。反之，当执行完对中断/异常/系统调用打断的处理后，最后会执行一个“iret”指令。在执行此指令之前，CPU的当前栈指针esp一定指向上次产生中断/异常/系统调用时CPU保存的被打断的指令地址CS和EIP，“iret”指令会根据ESP所指的保存的址CS和EIP恢复到上次被打断的地方继续执行。

在页表设置方面，由于idleproc和initproc都是共用一个内核页表boot_cr3，所以此时第三步其实没用，但考虑到以后的进程有各自的页表，其起始地址各不相同，只有完成页表切换，才能确保新的进程能够正常执行。

第四步proc_run函数调用switch_to函数，参数是前一个进程和后一个进程的执行现场：process context。在上一节“设计进程控制块”中，描述了context结构包含的要保存和恢复的寄存器。我们再看看switch.S中的switch_to函数的执行流程：

```
.text
.globl switch_to
switch_to:                      # switch_to(from, to)

    # save from's registers
    movl 4(%esp), %eax          # eax points to from
    popl 0(%eax)                # save eip !popl
    movl %esp, 4(%eax)          # save esp::context of from
    movl %ebx, 8(%eax)          # save ebx::context of from
    movl %ecx, 12(%eax)         # save ecx::context of from
    movl %edx, 16(%eax)         # save edx::context of from
    movl %esi, 20(%eax)         # save esi::context of from
    movl %edi, 24(%eax)         # save edi::context of from
    movl %ebp, 28(%eax)         # save ebp::context of from

    # restore to's registers
    movl 4(%esp), %eax          # not 8(%esp): popped return address already
                                # eax now points to to
    movl 28(%eax), %ebp         # restore ebp::context of to
    movl 24(%eax), %edi         # restore edi::context of to
    movl 20(%eax), %esi         # restore esi::context of to
    movl 16(%eax), %edx         # restore edx::context of to
    movl 12(%eax), %ecx         # restore ecx::context of to
    movl 8(%eax), %ebx          # restore ebx::context of to
    movl 4(%eax), %esp          # restore esp::context of to

    pushl 0(%eax)               # push eip

    ret
```

首先，保存前一个进程的执行现场，前两条汇编指令（如下所示）保存了进程在返回switch_to函数后的指令地址到context.eip中

```
    # save from's registers
    movl 4(%esp), %eax          # eax points to from
    popl 0(%eax)                # save eip !popl
```

在接下来的7条汇编指令完成了保存前一个进程的其他7个寄存器到context中的相应成员变量中。至此前一个进程的执行现场保存完毕。再往后是恢复后一个进程的执行现场，这其实就是上述保存过程的逆执行过程，即从context的高地址的成员变量ebp开始，逐一把相关成员变量的值赋值给对应的寄存器，倒数第二条汇编指令“pushl 0(%eax)”其实把context中保存的下一个进程要执行的指令地址context.eip放到了堆栈顶，这样接下来执行最后一条指令“ret”时，会把栈顶的内容赋值给EIP寄存器，这样就切换到下一个进程执行了，即当前进程已经是下一个进程了。uCore会执行进程切换，让initproc执行。在对initproc进行初始化时，设置了initproc->context.eip = (uintptr_t)forkret，这样，当执行switch_to函数并返回后，initproc将执行其实际上的执行入口地址forkret。而forkret会调用位于kern/trap/trapentry.S中的forkrets函数执行，具体代码如下：

```
.globl __trapret
__trapret:
    # restore registers from stack
    popal

    # restore %ds, %es, %fs and %gs
    popl %gs
    popl %fs
    popl %es
    popl %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
    iret

.globl forkrets
forkrets:
    # set stack to this new process's trapframe
    movl 4(%esp), %esp
    jmp __trapret
```

可以看出，forkrets函数首先把esp指向当前进程的中断帧，从_trapret开始执行到iret前，esp指向了current->tf.tf_eip，而如果此时执行的是initproc，则current->tf.tf_eip=kernel_thread_entry，initproc->tf.tf_cs = KERNEL_CS，所以当执行完iret后，就开始在内核中执行kernel_thread_entry函数了，而initproc->tf.tf_regs.reg_ebx = init_main，所以在kernl_thread_entry中执行“call %ebx”后，就开始执行initproc的主体了。Initprocde的主体函数很简单就是输出一段字符串，然后就返回到kernel_tread_entry函数，并进一步调用do_exit执行退出操作了。本来do_exit应该完成一些资源回收工作等，但这些不是实验四涉及的，而是由后续的实验来完成。至此，实验四中的主要工作描述完毕。

## 项目组成

```
├── boot   
├── kern  
│ ├── debug  
│ ├── driver  
│ ├── fs   
│ ├── init  
│ │ ├── init.c   
│ │ └── ...  
│ ├── libs  
│ │ ├── rb\_tree.c  
│ │ ├── rb\_tree.h  
│ │ └── ...   
│ ├── mm   
│ │ ├── kmalloc.c   
│ │ ├── kmalloc.h   
│ │ ├── memlayout.h   
│ │ ├── pmm.c   
│ │ ├── pmm.h   
│ │ ├── swap.c   
│ │ ├── vmm.c   
│ │ └── ...   
│ ├── process  
│ │ ├── entry.S  
│ │ ├── proc.c   
│ │ ├── proc.h  
│ │ └── switch.S  
│ ├── schedule  
│ │ ├── sched.c  
│ │ └── sched.h  
│ ├── sync  
│ │ └── sync.h  
│ └── trap  
│ ├── trapentry.S  
│ └── ...  
├── libs  
│ ├── hash.c   
│ ├── stdlib.h  
│ ├── unistd.h   
│ └── ...  
├── Makefile  
└── tools
```

相对与实验三，实验四中主要改动如下：

- kern/process/ （新增进程管理相关文件）
  - proc.[ch]：新增：实现进程、线程相关功能，包括：创建进程/线程，初始化进程/线程，处理进程/线程退出等功能
  - entry.S：新增：内核线程入口函数kernel_thread_entry的实现
  - switch.S：新增：上下文切换，利用堆栈保存、恢复进程上下文
- kern/init/
  - init.c：修改：完成进程系统初始化，并在内核初始化后切入idle进程
- kern/mm/ （基本上与本次实验没有太直接的联系，了解kmalloc和kfree如何使用即可）
  - kmalloc.[ch]：新增：定义和实现了新的kmalloc/kfree函数。具体实现是基于slab分配的简化算法 （只要求会调用这两个函数即可）
  - memlayout.h：增加slab物理内存分配相关的定义与宏 （可不用理会）。
  - pmm.[ch]：修改：在pmm.c中添加了调用kmalloc_init函数,取消了老的kmalloc/kfree的实现；在pmm.h中取消了老的kmalloc/kfree的定义
  - swap.c：修改：取消了用于check的Line 185的执行
  - vmm.c：修改：调用新的kmalloc/kfree
- kern/trap/
  - trapentry.S：增加了汇编写的函数forkrets，用于do_fork调用的返回处理。
- kern/schedule/
  - sched.[ch]：新增：实现FIFO策略的进程调度
- kern/libs
  - rb_tree.[ch]：新增：实现红黑树，被slab分配的简化算法使用（可不用理会）

**编译执行**

编译并运行代码的命令如下：

```
make
make qemu
```

则可以得到如下的显示内容（仅供参考，不是标准答案输出）

```
(THU.CST) os is loading ...

Special kernel symbols:
  entry  0xc010002a (phys)
  etext  0xc010a708 (phys)
  edata  0xc0127ae0 (phys)
  end    0xc012ad58 (phys)

...

++ setup timer interrupts
this initproc, pid = 1, name = "init"
To U: "Hello world!!".
To U: "en.., Bye, Bye. :)"
kernel panic at kern/process/proc.c:354:
    process exit!!.

Welcome to the kernel debug monitor!!
Type 'help' for a list of commands.
K> qemu: terminating on signal 2
```