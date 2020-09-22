# Lab 6

## 基础知识

### 实验执行流程概述

实验五的scheduler实现中，ucore内核不断的遍历进程池，直到找到第一个runnable状态的 process，调用并执行它。也就是说，当系统没有进程可以执行的时候，它会把所有 cpu 时间用在搜索进程池，以实现 idle的目的。但是这样的设计不被大多数操作系统所采用，原因在于它将进程调度和 idle 进程两种不同的概念混在了一起，而且，当调度器比较复杂时，schedule 函数本身也会比较复杂，这样的设计结构很不清晰而且难免会出现错误。所以在此次实验中，ucore建立了一个单独的进程(kern/process/proc.c 中的 idleproc)作为 cpu 空闲时的 idle 进程，这个程序是通常一个死循环。你需要了解这个程序的实现。

实验六的大致执行过程，在init.c中的kern_init函数增加了对sched_init函数的调用。sched_init函数主要完成了对实现特定调度算法的调度类（sched_class）的绑定，使得ucore在后续的执行中，能够通过调度框架找到实现特定调度算法的调度类并完成进程调度相关工作。为了更好地理解实验六整个运行过程，这里需要关注的重点问题包括：

1. 何时或何事件发生后需要调度？

   当前进程时间片用完或发生中断

2. 何时或何事件发生后需要调整实现调度算法所涉及的参数？

   进程时间片用完需要重新分配时间片并把这个进程结点插入到runable队列

3. 如果基于调度框架设计具体的调度算法？

4. 如果灵活应用链表等数据结构管理进程调度？

   使用优先队列可以更好的下一个进程选择哪个，因为优先队列可以很轻松的找出最小或最大的结点，而分配算法（stride scheduing）最主要的就是要找出最小的stride指定它为下一个进程

### 进程状态

ucore中，runable状态的进程会存放在运行队列中，还有runable和running共用一个状态PROC_RUNNABLE，不过running状态的进程是不会放在运行队列中的，下面是一个进程的正常生命周期：

1. 进程首先在 cpu 初始化或者 sys_fork 的时候被创建，当为该进程分配了一个进程控制块之后，该进程进入 uninit态(在proc.c 中 alloc_proc)。
2. 当进程完全完成初始化之后，该进程转为runnable态。
3. 当到达调度点时，由调度器 sched_class 根据运行队列rq的内容来判断一个进程是否应该被运行，即把处于runnable态的进程转换成running状态，从而占用CPU执行。
4. running态的进程通过wait等系统调用被阻塞，进入sleeping态。
5. sleeping态的进程被wakeup变成runnable态的进程。
6. running态的进程主动 exit 变成zombie态，然后由其父进程完成对其资源的最后释放，子进程的进程控制块成为unused。
7. 所有从runnable态变成其他状态的进程都要出运行队列，反之，被放入某个运行队列中。

### 内核抢占点

| 编号 | 位置              | 原因                                                         |
| ---- | ----------------- | ------------------------------------------------------------ |
| 1    | proc.c::do_exit   | 用户线程执行结束，主动放弃CPU控制权。                        |
| 2    | proc.c::do_wait   | 用户线程等待子进程结束，主动放弃CPU控制权。                  |
| 3    | proc.c::init_main | 1. initproc内核线程等待所有用户进程结束，如果没有结束，就主动放弃CPU控制权; 2. initproc内核线程在所有用户进程结束后，让kswapd内核线程执行10次，用于回收空闲内存资源 |
| 4    | proc.c::cpu_idle  | idleproc内核线程的工作就是等待有处于就绪态的进程或线程，如果有就调用schedule函数 |
| 5    | sync.h::lock      | 在获取锁的过程中，如果无法得到锁，则主动放弃CPU控制权        |
| 6    | trap.c::trap      | 如果在当前进程在用户态被打断去，且当前进程控制块的成员变量need_resched设置为1，则当前线程会放弃CPU控制权 |

第1、2、5处的执行位置体现了由于获取某种资源一时等不到满足、进程要退出、进程要睡眠等原因而不得不主动放弃CPU。第3、4处的执行位置比较特殊，initproc内核线程等待用户进程结束而执行schedule函数；idle内核线程在没有进程处于就绪态时才执行，一旦有了就绪态的进程，它将执行schedule函数完成进程调度。这里只有第6处的位置比较特殊：

```
if (!in_kernel) {
    ……

    if (current->need_resched) {
        schedule();
    }
}
```

这里表明了只有当进程在用户态执行到“任意”某处用户代码位置时发生了中断，且当前进程控制块成员变量need_resched为1（表示需要调度了）时，才会执行shedule函数。这实际上体现了对用户进程的可抢占性。如果没有第一行的if语句，那么就可以体现对内核代码的可抢占性。但如果要把这一行if语句去掉，我们就不得不实现对ucore中的所有全局变量的互斥访问操作，以防止所谓的racecondition（竞争）现象，这样ucore的实现复杂度会增加不少。

### 进程切换过程

1. 当前执行进程A的用户代码，发生中断，即从A的用户态切换到内核态
2. 首先要保存好A的trapframe，然后内核中断处理程序发现需要进行进程切换时，ucore就要通过schedule函数选择下一个占用CPU的进程（进程B），然后调用proc_run函数，proc_run函数再进一步调用switch_to函数，切换到B的内核态
3. 继续B上一次在内核态的操作，并通过iret指令，最终讲执行权转交给进程B的用户空间
4. 当前执行进程B的用户代码，发生中断，即从B的用户态切换到内核态
5. 首先要保存好B的trapframe，然后内核中断处理程序发现需要进行进程切换时，发现下一个需要切换的进程为进程A，ucore就再通过上面的函数来切换到A的内核态
6. 会执行进程A上一次在内核调用schedule (具体还要跟踪到 switch_to 函数)函数返回后的下一行代码，中断处理程序处理完成时会返回到A的用户态去执行A的用户代码

需要强调的是：

**a)** 需要透彻理解在进程切换以后，程序是从哪里开始执行的？需要注意到虽然指令还是同一个cpu上执行，但是此时已经是另外一个进程在执行了，且使用的资源已经完全不同了。

**b)** 内核在第一个程序运行的时候，需要进行哪些操作？有了实验四和实验五的经验，可以确定，内核启动第一个用户进程的过程，实际上是从进程启动时的内核状态切换到该用户进程的内核状态的过程，而且该用户进程在用户态的起始入口应该是forkret。

#### 数据结构

在理解框架之前，需要先了解一下调度器框架所需要的数据结构。

- 通常的操作系统中，进程池是很大的（虽然在 ucore 中，MAX_PROCESS 很小）。在 ucore 中，调度器引入 run-queue（简称rq,即运行队列）的概念，通过链表结构管理进程。
- 由于目前 ucore 设计运行在单CPU上，其内部只有一个全局的运行队列，用来管理系统内全部的进程。
- 运行队列通过链表的形式进行组织。链表的每一个节点是一个list_entry_t,每个list_entry_t 又对应到了 struct proc_struct *,这其间的转换是通过宏 le2proc 来完成 的。具体来说，我们知道在 struct proc_struct 中有一个叫 run_link 的 list_entry_t，因此可以通过偏移量逆向找到对因某个 run_list的 struct proc_struct。即进程结构指针 proc = le2proc(链表节点指针, run_link)。
- 为了保证调度器接口的通用性，ucore调度框架定义了如下接口，该接口中，几乎全部成员变量均为函数指针。具体的功能会在后面的框架说明中介绍。

```
---------------------------------------------------------------------------------
	数据结构 struct sched_class 定义了下面这些接口
	struct sched_class {
       // 调度器的名字
       const char *name;
       // 初始化运行队列
       void (*init) (struct run_queue *rq);
       // 将进程 p 插入队列 rq
       void (*enqueue) (struct run_queue *rq, struct proc_struct *p);
       // 将进程 p 从队列 rq 中删除
       void (*dequeue) (struct run_queue *rq, struct proc_struct *p);
        // 返回 运行队列 中下一个可执行的进程
        struct proc_struct* (*pick_next) (struct run_queue *rq);
        // timetick 处理函数
        void (*proc_tick)(struct  run_queue* rq, struct proc_struct* p);
    };
    
---------------------------------------------------------------------------------
	数据结构 struct proc_struct 中也记录了一些调度相关的信息，是更新lab5中的内容也就是添加了下面这写内容同时也就需要对这些内容进行初始化
	struct proc_struct {
       // . . .
       // 该进程是否需要调度，只对当前进程有效
       volatile bool need_resched;
       // 该进程的调度链表结构，该结构内部的连接组成了 运行队列 列表
       list_entry_t run_link;
       // 该进程剩余的时间片，只对当前进程有效
       int time_slice;
       // round-robin 调度器并不会用到以下成员
        // 该进程在优先队列中的节点，仅在 LAB6 使用
        skew_heap_entry_t  lab6_run_pool;
        // 该进程的调度优先级，仅在 LAB6 使用
        uint32_t lab6_priority;
        // 该进程的调度步进值，仅在 LAB6 使用
        uint32_t lab6_stride;
    };
    
---------------------------------------------------------------------------------
   数据结构 struct run_queue 来描述完整的 run_queue（运行队列）
   struct run_queue {
       //其运行队列的哨兵结构，可以看作是队列头和尾
       list_entry_t run_list;
       //优先队列形式的进程容器，只在 LAB6 中使用
       skew_heap_entry_t  *lab6_run_pool;
       //表示其内部的进程总数
       unsigned int proc_num;
       //每个进程一轮占用的最多时间片
       int max_time_slice;
    };
```

### 调度点的相关关键函数

虽然进程各种状态变化的原因和导致的调度处理各异，但其实仔细观察各个流程的共性部分，会发现其中只涉及了三个关键调度相关函数：wakup_proc、shedule、run_timer_list。如果我们能够让这三个调度相关函数的实现与具体调度算法无关，那么就可以认为ucore实现了一个与调度算法无关的调度框架。

- wakeup_proc函数其实完成了把一个就绪进程放入到就绪进程队列中的工作，为此还调用了一个调度类接口函数sched_class_enqueue，这使得wakeup_proc的实现与具体调度算法无关。
- schedule函数完成了与调度框架和调度算法相关三件事情:把当前继续占用CPU执行的运行进程放放入到就绪进程队列中，从就绪进程队列中选择一个“合适”就绪进程，把这个“合适”的就绪进程从就绪进程队列中摘除。通过调用三个调度类接口函数sched_class_enqueue、sched_class_pick_next、sched_class_enqueue来使得完成这三件事情与具体的调度算法无关。
- run_timer_list函数在每次timer中断处理过程中被调用，从而可用来调用调度算法所需的timer时间事件感知操作，调整相关进程的进程调度相关的属性值。通过调用调度类接口函数sched_class_proc_tick使得此操作与具体调度算法无关。

这里涉及了一系列调度类接口函数：

- sched_class_enqueue
- sched_class_dequeue
- sched_class_pick_next
- sched_class_proc_tick

这4个函数的实现其实就是调用某基于sched_class数据结构的特定调度算法实现的4个指针函数。采用这样的调度类框架后，如果我们需要实现一个新的调度算法，则我们需要定义一个针对此算法的调度类的实例，一个就绪进程队列的组织结构描述就行了，其他的事情都可交给调度类框架来完成。

### RR 调度算法实现

首先需要说一下RR调度算法具体是怎么一回事，然后就是分析代码了

RR调度算法：简单点说做的工作主要就是三个，检测当前进程时间片，当前进程时间片用完，插入到运行队列队尾，从队头取新结点调度。更具体点RR调度算法在结构体中增加了一个新的成员变量time_slice，用来记录进程当前的可运行时间片，然后会运行一个递减程序递减当前程序的time_slice然后当time_slice为0的时候就代表说这个进程运行一段时间了该换别的进程运行了，然后就会把他插入到运行队列队尾，从队头取出新的应该运行的进程，并且还需要把移出的进程的time_slice的值重置为max_time_slice，其中还有一个问题，就是假如一开始程序的time_slice就大于max_time_slice那就需要重置time_slice为max_time_slice。

分析代码：

- **RR_init**

  ```
  static void
  RR_init(struct run_queue *rq) {
      list_init(&(rq->run_list));
      rq->proc_num = 0;
  }
  ```

  首先就是初始化，初始化运行队列，并且设置运行队列链表的初始个数为0

- **RR_enqueue**

  ```
  static void
  RR_enqueue(struct run_queue *rq, struct proc_struct *proc) {
      assert(list_empty(&(proc->run_link)));
      list_add_before(&(rq->run_list), &(proc->run_link));
      if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
          proc->time_slice = rq->max_time_slice;
      }
      proc->rq = rq;
      rq->proc_num ++;
  }
  ```

  把进程结点插入到运行队列队尾，首先就是第一步直接插入了，插入之后就需要重置time_slice，然后让进程结点的属性rq指向运行队列，然后运行队列中的结点数量加1

- **RR_dequeue**

  ```
  static void
  RR_dequeue(struct run_queue *rq, struct proc_struct *proc) {
      assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
      list_del_init(&(proc->run_link));
      rq->proc_num --;
  }
  ```

  删除结点，也就是取出第一个结点，首先就是检查一下要删除的结点是不是头节点并且运行队列不为空，然后就是直接删除对应的结点，运行队列中的结点数量减1

- **RR_pick_next**

  ```
  static struct proc_struct *
  RR_pick_next(struct run_queue *rq) {
      list_entry_t *le = list_next(&(rq->run_list));
      if (le != &(rq->run_list)) {
          return le2proc(le, run_link);
      }
      return NULL;
  }
  ```

  这个就是选择队头节点

- **RR_proc_tick**

  ```
  static void
  RR_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
      if (proc->time_slice > 0) {
          proc->time_slice --;
      }
      if (proc->time_slice == 0) {
          proc->need_resched = 1;
      }
  }
  ```

  这里就是每个进程会逐次减一，然后直到减到0为止，然后就需要设置need_reshed=1表示需要调度，然后再下一次循环中就会调用trap函数来把这个进程放进运行队列的队尾取出队头然后继续运行队头对应的进程

### Stride Scheduling 调度算法实现

Stride Scheduling算法的简要说明：Stride Scheduling主要的思想就是通过一个stride（可以理解为优先级），和一个pass（步长）来决定应该怎么调度，首先会在队列中找到最小的stride，然后增加对应的pass（pass的值是由BIG_STRIDE/P->priority得到的，BIG_STRIDE是进程所能申请的最大的stride，priority是进程对应的优先级）长，然后继续寻找最小的，再增加，这样循环下去，用下面的图就很好理解这个过程了（图片取自CSDN）

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-16_15-01-32.png)

所以对应的我们也就需要设计出和RR调度算法差不多一样的几个函数，stride_init函数，stride_enqueue函数，stride_dequeue函数，stride_pick_next函数，stride_proc_tick函数和proc_stride_comp_f函数

- **stride_init**

  需要做两个工作，一个就是初始化一个空的运行列表，另一个就是需要初始化调度器信息，即新的运行列表中的进程数量为0

  对应的伪代码就是

  ```
  Initialize rq->run_list
  set rq->lab6_run_pool = NULL
  set rq->proc_num = 0
  ```

- **stride_enqueue**

  需要做的就是把对应的proc插入到运行队列中，然后更新time_slice的值和proc_num的值，并且让新插入的proc的rq指向运行队列对应的伪代码就是

  ```
  Initialize proc->time_slice
  Insert proc->lab6_run_pool into rq->lab6_run_pool
  rq->proc_num ++
  proc->rq = rq
  ```

- **stride_dequeue**

  需要做的就是删除rq中对应的proc，取出之后更新proc_num的值就可以了，对应的伪代码就是

  ```
  Delete proc->lab6_run_pool from rq->lab6_run_pool
  rq->proc_num--
  ```

- **stride_pick_next**

  选择运行队列中stride最小的进程，然后更新对应的stride，对应的伪代码就是

  ```
  If rq->lab6_run_pool == NULL, return NULL
  Find the proc corresponding to the pointer rq->lab6_run_pool
  proc->lab6_stride += BIG_STRIDE / proc->lab6_priority
  Return proc
  ```

- **stride_proc_tick**

  做的就是更新time_slice的值了，即每一次time_slice的值都减一然后当time_slice减到0后就设置need_resched=1，表示需要调度对应的伪代码就是

  ```
  If proc->time_slice > 0, proc->time_slice --
  If proc->time_slice == 0, set the flag proc->need_resched
  ```

- **proc_stride_comp_f**

  这个函数就是比较两个结点的stride了，这个函数的实现给了具体代码，代码如下

  ```
  static int
  proc_stride_comp_f(void *a, void *b)
  {
       struct proc_struct *p = le2proc(a, lab6_run_pool);
       struct proc_struct *q = le2proc(b, lab6_run_pool);
       int32_t c = p->lab6_stride - q->lab6_stride;
       if (c > 0) return 1;
       else if (c == 0) return 0;
       else return -1;
  }
  ```

Stride Scheduling算法为了加快效率就使用了优先队列，优先队列可以很容易的就找到队列中的最小或者最大的元素，对应的数据结构和含义如下

```
// 优先队列节点的结构
typedef struct skew_heap_entry  skew_heap_entry_t;
// 初始化一个队列节点
void skew_heap_init(skew_heap_entry_t *a);
// 将节点 b 插入至以节点 a 为队列头的队列中去，返回插入后的队列
skew_heap_entry_t  *skew_heap_insert(skew_heap_entry_t  *a,
                                     skew_heap_entry_t  *b,
                                     compare_f comp);
// 将节点 b 插入从以节点 a 为队列头的队列中去，返回删除后的队列
skew_heap_entry_t  *skew_heap_remove(skew_heap_entry_t  *a,
                                     skew_heap_entry_t  *b,
                                     compare_f comp);
```

- struct run_queue中的lab6_run_pool指针，在使用优先队列的实现中表示当前优先队列的头元素，如果优先队列为空，则其指向空指针（NULL）。
- struct proc_struct中的lab6_run_pool结构，表示当前进程对应的优先队列节点。

## 项目组成

```
├── boot  
├── kern  
│ ├── debug  
│ ├── driver  
│ ├── fs  
│ ├── init  
│ ├── libs  
│ ├── mm  
│ ├── process  
│ │ ├── .....  
│ │ ├── proc.c  
│ │ ├── proc.h   
│ │ └── switch.S  
│ ├── schedule  
│ │ ├── default\_sched.c  
│ │ ├── default\_sched.h  
│ │ ├── default\_sched\_stride\_c  
│ │ ├── sched.c  
│ │ └── sched.h   
│ ├── syscall   
│ │ ├── syscall.c   
│ │ └── syscall.h  
…
```

相对与实验五，实验六主要增加的文件如上表红色部分所示，主要修改的文件如上表紫色部分所示。主要改动如下： 简单说明如下：

- libs/skew_heap.h: 提供了基本的优先队列数据结构，为本次实验提供了抽象数据结构方面的支持。
- kern/process/proc.[ch]：proc.h中扩展了proc_struct的成员变量，用于RR和stride调度算法。proc.c中实现了lab6_set_priority，用于设置进程的优先级。
- kern/schedule/{sched.h,sched.c}: 定义了 ucore 的调度器框架，其中包括相关的数据结构（包括调度器的接口和运行队列的结构），和具体的运行时机制。
- kern/schedule/{default_sched.h,default_sched.c}: 具体的 round-robin 算法，在本次实验中你需要了解其实现。
- kern/schedule/default_sched_stride_c: Stride Scheduling调度器的基本框架，在此次实验中你需要填充其中的空白部分以实现一个完整的 Stride 调度器。
- kern/syscall/syscall.[ch]: 增加了sys_gettime系统调用，便于用户进程获取当前时钟值；增加了sys_lab6_set_priority系统调用，便于用户进程设置进程优先级（给priority.c用）
- user/{matrix.c,priority.c,. . . }: 相关的一些测试用户程序，测试调度算法的正确性，user目录下包含但不限于这些程序。在完成实验过程中，建议阅读这些测试程序，以了解这些程序的行为，便于进行调试。

