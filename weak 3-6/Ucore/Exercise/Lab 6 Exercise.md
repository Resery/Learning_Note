# Lab 6 Exercise

## Exercise 1

**问题：**

**使用 Round Robin 调度算法（不需要编码）完成练习0后，建议大家比较一下（可用kdiff3等文件比较软件）个人完成的lab5和练习0完成后的刚修改的lab6之间的区别，分析了解lab6采用RR调度算法后的执行过程。执行make grade，大部分测试用例应该通过。但执行priority.c应该过不去。**

**请在实验报告中完成：**

- **请理解并分析sched_class中各个函数指针的用法，并结合Round Robin 调度算法描述ucore的调度执行过程**
- **请在实验报告中简要说明如何设计实现”多级反馈队列调度算法“，给出概要设计，鼓励给出详细设计**

### 解：

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

ucore调度的执行过程，首先就是初始化一个空的运行列表，然后把runable状态的进程添加到列表中，然后等待running状态的进程的时间片用完（这里就是用的RR调度算法中的proc_tick，则time_silce减一，一直减到0位置），然后就把这个结点添加到列表中并设置好对应的属性，然后再取出下一个运行的进程，之后就继续等待下去，循环做这些事情。

------

[出处](https://www.jianshu.com/p/fd1a1a7d4892) 

在proc_struct中添加总共N个多级反馈队列的入口，每个队列都有着各自的优先级，编号越大的队列优先级约低，并且优先级越低的队列上时间片的长度越大，为其上一个优先级队列的两倍；并且在PCB中记录当前进程所处的队列的优先级；

处理调度算法初始化的时候需要同时对N个队列进行初始化；

在处理将进程加入到就绪进程集合的时候，观察这个进程的时间片有没有使用完，如果使用完了，就将所在队列的优先级调低，加入到优先级低1级的队列中去，如果没有使用完时间片，则加入到当前优先级的队列中去；

在同一个优先级的队列内使用时间片轮转算法；

在选择下一个执行的进程的时候，有限考虑高优先级的队列中是否存在任务，如果不存在才转而寻找较低优先级的队列；（有可能导致饥饿）

从就绪进程集合中删除某一个进程就只需要在对应队列中删除即可；

处理时间中断的函数不需要改变；

至此完成了多级反馈队列调度算法的具体设计；

## Exercise 2

**问题：**

**实现 Stride Scheduling 调度算法（需要编码）首先需要换掉RR调度器的实现，即用default_sched_stride_c覆盖default_sched.c。然后根据此文件和后续文档对Stride度器的相关描述，完成Stride调度算法的实现。**

**后面的实验文档部分给出了Stride调度算法的大体描述。这里给出Stride调度算法的一些相关的资料（目前网上中文的资料比较欠缺）。**

- **[strid-shed paper location1](http://wwwagss.informatik.uni-kl.de/Projekte/Squirrel/stride/node3.html)**
- **[strid-shed paper location2](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.138.3502&rank=1)**
- **也可GOOGLE “Stride Scheduling” 来查找相关资料**

**执行：make grade。如果所显示的应用程序检测都输出ok，则基本正确。如果只是priority.c过不去，可执行 make run-priority 命令来单独调试它。大致执行结果可看附录。（ 使用的是 qemu-1.0.1 ）。**

### 解：

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

## Extend Exercise 1

**问题：**

**实现 Linux 的 CFS 调度算法在ucore的调度器框架下实现下Linux的CFS调度算法。可阅读相关Linux内核书籍或查询网上资料，可了解CFS的细节，然后大致实现在ucore中。**

### 解：

### CFS调度算法原理

[文章来源](https://blog.csdn.net/XD_hebuters/article/details/79623130)

调度算法最核心的两点即为调度哪个进程执行、被调度进程执行的时间多久。前者称为**调度策略**，后者为**执行时间**。

#### 调度策略

cfs定义一种新的模型，它给cfs_rq（cfs的run queue）中的每一个进程安排一个虚拟时钟，vruntime。如果一个进程得以执行，随着时间的增长（即一个个tick的到来），其vruntime将不断增大。没有得到执行的进程vruntime不变。
**调度器总是选择vruntime值最低的进程执行**。这就是所谓的“**完全公平**”。对于不同进程，优先级高的进程vruntime增长慢，以至于它能得到更多的运行时间。

**公平的体现：机会平等，时间差异**
公平体现在vruntime (virtual runtime， 虚拟运行时间)上面，它记录着进程已经运行的时间，其大小与进程的权重、运行时间存在一个定量计算关系。

> **vruntime = 实际运行时间 \* 1024 / 进程权重**

实际上1024等于nice为0的进程的权重，代码中是NICE_0_LOAD，也就是说，所有进程都以nice值为0的权重1024作为基准，计算自己的vruntime增加速度。结合分配给进程实际运行的时间，可得如下换算关系：

> **分配给进程的时间 = 调度周期 \* 进程权重 / 全部进程权重之和**
> **vruntime = 实际运行时间 \* 1024 / 进程权重**
> **vruntime = （调度周期 \* 进程权重 / 全部进程权重之和） \* 1024 / 进程权重**
> **vruntime = （调度周期 / 全部进程权重之和） \* 1024**

可以看到进程在一个调度周期内的vruntime值大小与进程权重无关，所有进程的vruntime值在一个周期内增长是一致的。vruntime值较小的进程，说明它以前占用cpu的时间较短，受到了不公平对待，因此选择作为下一次运行的进程。
这样既能公平选择进程，又能保证高优先级进程获得较多运行时间，就是cfs的主要思想了。其可以简单概括为：**机会平等、时间差异**。

#### 执行时间

cfs采用当前系统中全部可调度进程优先级的比重确定每一个进程执行的时间片，即：

> **分配给进程的时间 = 调度周期 \* 进程权重 / 全部进程之和。**

假如有三个可调度进程A、B、C，它们的优先级分别为5,10,15，调度周期为60ms, 则它们的时间片分别为：60ms * 5 / 30 = 10ms、60ms * 10 / 30 = 20ms、60ms * 15 / 30 = 30ms

#### 骨架—红黑树

cfs调度算法使用红黑树来实现，其详细内容可以参考维基百科[红黑树的介绍](https://zh.wikipedia.org/wiki/红黑树)。这里简单讲一下cfs的结构。第一个是调度实体sched_entity，它代表一个调度单位，在组调度关闭的时候可以把他等同为进程。每一个task_struct中都有一个sched_entity，进程的vruntime和权重都保存在这个结构中。
sched_entity通过红黑树组织在一起，所有的sched_entity以vruntime为key(实际上是以vruntime-min_vruntime为key，是为了防止溢出)插入到红黑树中，同时缓存树的最左侧节点，也就是vruntime最小的节点，这样可以迅速选中vruntime最小的进程。

> 仅处于就绪态的进程在这棵树上，睡眠进程和正在运行的进程都不在树上。

![]()

#### nice值与权重的关系

每一个进程都有一个nice值，代表其静态优先级。可以参考[ Linux nice及renice命令使用](http://blog.csdn.net/XD_hebuters/article/details/79619213)。nice值和进程的权重的关系存储在数组prio_to_weight中，如下所示：

```
/*prio_to_weight数组反应的是nice值与权重的对应关系*/
static const int prio_to_weight[40] = {
     /* -20 */     88761,     71755,     56483,     46273,     36291,
     /* -15 */     29154,     23254,     18705,     14949,     11916,
     /* -10 */      9548,      7620,      6100,      4904,      3906,
     /*  -5 */      3121,      2501,      1991,      1586,      1277,
     /*   0 */      1024,       820,       655,       526,       423,
     /*   5 */       335,       272,       215,       172,       137,
     /*  10 */       110,        87,        70,        56,        45,
     /*  15 */        36,        29,        23,        18,        15,
     };
```

可以看到，nice值越小，进程的权重越大。CFS调度器的一个调度周期是固定的,由sysctl_sched_latency变量保存。

#### 两个重要的结构体

**完全公平队列cfs_rq：**描述运行在一个cpu上的处于TASK_RUNNING状态的普通进程的各种运行信息：

```
struct cfs_rq {
    struct load_weight load;  //运行队列总的进程权重
    unsigned int nr_running, h_nr_running; //进程的个数

    u64 exec_clock;  //运行的时钟
    u64 min_vruntime; //该cpu运行队列的vruntime推进值, 一般是红黑树中最小的vruntime值

    struct rb_root tasks_timeline; //红黑树的根结点
    struct rb_node *rb_leftmost;  //指向vruntime值最小的结点
    //当前运行进程, 下一个将要调度的进程, 马上要抢占的进程, 
    struct sched_entity *curr, *next, *last, *skip;

    struct rq *rq; //系统中有普通进程的运行队列, 实时进程的运行队列, 这些队列都包含在rq运行队列中  
    ...
    };
```

**调度实体sched_entity:**记录一个进程的运行状态信息

```
struct sched_entity {
    struct load_weight  load; //进程的权重
    struct rb_node      run_node; //运行队列中的红黑树结点
    struct list_head    group_node; //与组调度有关
    unsigned int        on_rq; //进程现在是否处于TASK_RUNNING状态

    u64         exec_start; //一个调度tick的开始时间
    u64         sum_exec_runtime; //进程从出生开始, 已经运行的实际时间
    u64         vruntime; //虚拟运行时间
    u64         prev_sum_exec_runtime; //本次调度之前, 进程已经运行的实际时间
    struct sched_entity *parent; //组调度中的父进程
    struct cfs_rq       *cfs_rq; //进程此时在哪个运行队列中
};
```

#### 几个与cfs有关的过程：

**1)、创建新进程：**需要设置新进程的vruntime值及将新进程加入红黑树中，并判断是否需要抢占当前进程。
**2)、进程唤醒：**需要调整睡眠进程的vruntime值, 并且将睡眠进程加入红黑树中. 并判断是否需要抢占当前进程
**3)、进程调度：**需要把当前进程加入红黑树中, 还要从红黑树中挑选出下一个要运行的进程.
**4)、时钟周期中断：**在时钟中断周期函数中, 需要更新当前运行进程的vruntime值, 并判断是否需要抢占当前进程
**这里详细的代码实现，可以参考：**[Linux的CFS(完全公平调度)算法](http://blog.csdn.net/liuxiaowu19911121/article/details/47070111),代码解释非常详实。

#### ucore中的实现

实现的并不是特别完整的CFS算法，只是部分思想是一致的，然后大部分都是改的Stride算法的，因为Stride算法也有一个表示优先级的链表可以把它当成哪个红黑树，然后步长stride就可以当成vruntime。所以这个cfs属于阉割版，只有对应思想，但是并没有关于红黑树的操作和具体vruntime的计算，代码如下：

```
#include <defs.h>
#include <list.h>
#include <proc.h>
#include <assert.h>
#include <default_sched.h>

#define NICE_0_LOAD 1024

static int
proc_cfs_comp_f(void *a, void *b)
{
     struct proc_struct *p = le2proc(a, lab6_run_pool);
     struct proc_struct *q = le2proc(b, lab6_run_pool);
     int32_t c = p->lab6_stride - q->lab6_stride;
     if (c > 0) return 1;
     else if (c == 0) return 0;
     else return -1;
}


static void
cfs_init(struct run_queue *rq) {
    list_init(&rq->run_list);
    rq->lab6_run_pool = NULL;
    rq->proc_num = 0;
}

static void
cfs_enqueue(struct run_queue *rq, struct proc_struct *proc) {
    rq->lab6_run_pool = skew_heap_insert(rq->lab6_run_pool, &(proc->lab6_run_pool), proc_cfs_comp_f);
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
      proc->time_slice = rq->max_time_slice;
    }
    if (proc->lab6_priority == 0) {
        proc->lab6_priority = 1;
    }
    proc->rq = rq;
    rq->proc_num ++;
}

static void
cfs_dequeue(struct run_queue *rq, struct proc_struct *proc) {
    rq->lab6_run_pool = skew_heap_remove(rq->lab6_run_pool,&(proc->lab6_run_pool),proc_cfs_comp_f);
    rq->proc_num --;
}

static struct proc_struct *
cfs_pick_next(struct run_queue *rq) {
    if (rq->lab6_run_pool == NULL) return NULL;
  struct proc_struct* min_proc = le2proc(rq->lab6_run_pool, lab6_run_pool);

  if (min_proc->lab6_priority == 0) {
    min_proc->lab6_stride += NICE_0_LOAD;
  }
  else if (min_proc->lab6_priority > NICE_0_LOAD) {
    min_proc->lab6_stride += 1;
  }
  else {
    min_proc->lab6_stride += NICE_0_LOAD / min_proc->lab6_priority;
  }
  return min_proc;
}


static void
cfs_proc_tick(struct run_queue *rq, struct proc_struct *proc) {
    if(proc->time_slice > 0) proc->time_slice--;
    if(proc->time_slice == 0) proc->need_resched = 1;
}

struct sched_class default_sched_class = {
     .name = "cfs_scheduler",
     .init = cfs_init,
     .enqueue = cfs_enqueue,
     .dequeue = cfs_dequeue,
     .pick_next = cfs_pick_next,
     .proc_tick = cfs_proc_tick,
};
```

运行也可以成功，最后会得到这样的输出（第一行）：

```
sched class: cfs_scheduler
ide 0:      10000(sectors), 'QEMU HARDDISK'.
ide 1:     262144(sectors), 'QEMU HARDDISK'.
SWAP: manager = fifo swap manager
BEGIN check_swap: count 1, total 31815
setup Page Table for vaddr 0X1000, so alloc a page
setup Page Table vaddr 0~4MB OVER!
set up init env for check_swap begin!
page fault at 0x00001000: K/W [no page found].
page fault at 0x00002000: K/W [no page found].
page fault at 0x00003000: K/W [no page found].
page fault at 0x00004000: K/W [no page found].
set up init env for check_swap over!
write Virt Page c in fifo_check_swap
write Virt Page a in fifo_check_swap
write Virt Page d in fifo_check_swap
write Virt Page b in fifo_check_swap
write Virt Page e in fifo_check_swap
page fault at 0x00005000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
write Virt Page b in fifo_check_swap
write Virt Page a in fifo_check_swap
page fault at 0x00001000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
write Virt Page b in fifo_check_swap
page fault at 0x00002000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x3000 to disk swap entry 4
swap_in: load disk swap entry 3 with swap_page in vadr 0x2000
write Virt Page c in fifo_check_swap
page fault at 0x00003000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
swap_in: load disk swap entry 4 with swap_page in vadr 0x3000
write Virt Page d in fifo_check_swap
page fault at 0x00004000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x5000 to disk swap entry 6
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
write Virt Page e in fifo_check_swap
page fault at 0x00005000: K/W [no page found].
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
swap_in: load disk swap entry 6 with swap_page in vadr 0x5000
write Virt Page a in fifo_check_swap
page fault at 0x00001000: K/R [no page found].
swap_out: i 0, store page in vaddr 0x2000 to disk swap entry 3
swap_in: load disk swap entry 2 with swap_page in vadr 0x1000
count is 0, total is 5
check_swap() succeeded!
++ setup timer interrupts
kernel_execve: pid = 2, name = "priority".
main: fork ok,now need to wait pids.
child pid 7, acc 1888000, time 1001
child pid 5, acc 1112000, time 1001
child pid 3, acc 384000, time 1002
main: pid 3, acc 384000, time 1002
child pid 6, acc 1468000, time 1003
child pid 4, acc 760000, time 1003
main: pid 4, acc 760000, time 1004
main: pid 5, acc 1112000, time 1004
main: pid 6, acc 1468000, time 1004
main: pid 7, acc 1888000, time 1004
main: wait pids over
stride sched correct result: 1 2 3 4 5
all user-mode processes have quit.
init check memory pass.
kernel panic at kern/process/proc.c:489:
    initproc exit.

stack trackback:
ebp:0xc0398f88 eip:0xc0100bb8 args:0xc010ce88 0xc0398fcc 0x000001e9 0xc0398fb8
    kern/debug/kdebug.c:351: print_stackframe+22
ebp:0xc0398fb8 eip:0xc0100478 args:0xc010ee90 0x000001e9 0xc010eee2 0x00000000
    kern/debug/panic.c:27: __panic+104
ebp:0xc0398fe8 eip:0xc010a4e3 args:0x00000000 0x00000000 0x00000000 0x00000010
    kern/process/proc.c:492: do_exit+92
Welcome to the kernel debug monitor!!
Type 'help' for a list of commands.
K> #
```

