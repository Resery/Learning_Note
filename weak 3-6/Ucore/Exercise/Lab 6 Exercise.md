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

