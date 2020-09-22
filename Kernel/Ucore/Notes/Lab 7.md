---
title: Ucore Lab 7
# Lab 7

## 基础知识

### 同步互斥

互斥：互斥是指散布在不同进程之间的若干程序片断，当某个进程运行其中一个程序片段时，其它进程就不能运行它们之中的任一程序片段，只能等到该进程运行完这个程序片段后才可以运行（无序），唯一性和排他性

同步：同步是指散布在不同进程之间的若干程序片断，它们的运行必须严格按照规定的某种先后次序来运行，这种先后次序依赖于要完成的特定的任务（有序），这种先后次序取决于要系统完成的任务需求

同步属于更高级的互斥，就是有序的互斥

**在进程写资源情况下，进程间要求满足互斥条件。在进程读资源情况下，可允许多个进程同时访问资源。**

**五个哲学家问题：**假设有五位哲学家围坐在一张圆形餐桌旁，做以下两件事情之一：吃饭，或者思考。吃东西的时候，他们就停止思考，思考的时候也停止吃东西。餐桌中间有一大碗意大利面，每位哲学家之间各有一只餐叉。因为用一只餐叉很难吃到意大利面，所以假设哲学家必须用两只餐叉吃东西。他们只能使用自己左右手边的那两只餐叉。哲学家从来不交谈，这就很危险，可能产生死锁，每个哲学家都拿着左手的餐叉，永远都在等右边的餐叉（或者相反）。即使没有死锁，也有可能发生资源耗尽。例如，假设规定当哲学家等待另一只餐叉超过五分钟后就放下自己手里的那一只餐叉，并且再等五分钟后进行下一次尝试。这个策略消除了死锁（系统总会进入到下一个状态），但仍然有可能发生“活锁”。如果五位哲学家在完全相同的时刻进入餐厅，并同时拿起左边的餐叉，那么这些哲学家就会等待五分钟，同时放下手中的餐叉，再等五分钟，又同时拿起这些餐叉。

在实际的计算机问题中，缺乏餐叉可以类比为缺乏共享资源。一种常用的计算机技术是资源加锁，用来保证在某个时刻，资源只能被一个程序或一段代码访问。当一个程序想要使用的资源已经被另一个程序锁定，它就等待资源解锁。当多个程序涉及到加锁的资源时，在某些情况下就有可能发生死锁。例如，某个程序需要访问两个文件，当两个这样的程序各锁了一个文件，那它们都在等待对方解锁另一个文件，而解锁永远不会发生。

### 定时器

在传统的操作系统中，定时器是其中一个基础而重要的功能.它提供了基于时间事件的调度机制。在ucore 中，时钟（timer）中断给操作系统提供了有一定间隔的时间事件，操作系统将其作为基本的调度和计时单位（我们记两次时间中断之间的时间间隔为一个时间片，timer splice）。

基于此时间单位，操作系统得以向上提供基于时间点的事件，并实现基于时间长度的睡眠等待和唤醒机制。在每个时钟中断发生时，操作系统产生对应的时间事件。应用程序或者操作系统的其他组件可以以此来构建更复杂和高级的进程管理和调度算法。

- 数据结构：

  ```
  typedef struct {
      unsigned int expires;       //the expire time
      struct proc_struct *proc;   //the proc wait in this timer. If the expire time is end, then this proc will be scheduled
      list_entry_t timer_link;    //the timer list
  } timer_t;
  ```

  expires：记录时间片

  proc：过了expires时间片之后唤醒的进程

  timer_link：计时器链表

- 计时器初始化：

  ```
  static inline timer_t *
  timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
      timer->expires = expires;
      timer->proc = proc;
      list_init(&(timer->timer_link));
      return timer;
  }
  ```

- 添加计时器：

  ```
  void
  add_timer(timer_t *timer) {
      bool intr_flag;
      local_intr_save(intr_flag);
      {
          assert(timer->expires > 0 && timer->proc != NULL);
          assert(list_empty(&(timer->timer_link)));
          list_entry_t *le = list_next(&timer_list);
          while (le != &timer_list) {
              timer_t *next = le2timer(le, timer_link);
              if (timer->expires < next->expires) {
                  next->expires -= timer->expires;
                  break;
              }
              timer->expires -= next->expires;
              le = list_next(le);
          }
          list_add_before(le, &(timer->timer_link));
      }
      local_intr_restore(intr_flag);
  }
  ```

  首先就是在计时器链表中找到当前结点比下一个结点expires小的结点，然后下一个结点的expires减掉当前结点的expires，如果说没有找到，就会在每轮循环中让当前节点减掉下一个结点expires，循环结束之后把这个结点插入到计时器中

- 删除计时器：

  ```
  void
  del_timer(timer_t *timer) {
      bool intr_flag;
      local_intr_save(intr_flag);
      {
          if (!list_empty(&(timer->timer_link))) {
              if (timer->expires != 0) {
                  list_entry_t *le = list_next(&(timer->timer_link));
                  if (le != &timer_list) {
                      timer_t *next = le2timer(le, timer_link);
                      next->expires += timer->expires;
                  }
              }
              list_del_init(&(timer->timer_link));
          }
      }
      local_intr_restore(intr_flag);
  }
  ```

  首先检测当前要删除的结点的下一个结点是否为计时器链表的头节点，如果是的话就要把当前结点的expires全部加给头节点的expires，然后删除这个节点就可以，如果不是就直接删除

- 更新当前系统时间点

  ```
  void
  run_timer_list(void) {
      bool intr_flag;
      local_intr_save(intr_flag);
      {
          list_entry_t *le = list_next(&timer_list);
          if (le != &timer_list) {
              timer_t *timer = le2timer(le, timer_link);
              assert(timer->expires != 0);
              timer->expires --;
              while (timer->expires == 0) {
                  le = list_next(le);
                  struct proc_struct *proc = timer->proc;
                  if (proc->wait_state != 0) {
                      assert(proc->wait_state & WT_INTERRUPTED);
                  }
                  else {
                      warn("process %d's wait_state == 0.\n", proc->pid);
                  }
                  wakeup_proc(proc);
                  del_timer(timer);
                  if (le == &timer_list) {
                      break;
                  }
                  timer = le2timer(le, timer_link);
              }
          }
          sched_class_proc_tick(current);
      }
      local_intr_restore(intr_flag);
  }
  ```

  循环遍历计时器链表找到expires值为0的结点然后更新他的状态为RUNABLE状态，然后把他从计时器链表中删除出去，然后调度执行这个proc

### 屏蔽与使能中断

屏蔽与使能中断可以很好的实现互斥，比如内核区的代码正在运行但是被中断打断去执行了中断处理程序，就违反了互斥的原则即运行一个进程其它进程不可以运行，所以说当我们屏蔽了中断之后，内核区的代码就不会被中断打断就会一直处理到当前进程的时间片用完

```
intr_enable(void) {
    sti();
}

void
intr_disable(void) {
    cli();
}

static inline bool
__intr_save(void) {
    if (read_eflags() & FL_IF) {
        intr_disable();
        return 1;
    }
    return 0;
}

static inline void
__intr_restore(bool flag) {
    if (flag) {
        intr_enable();
    }
}

#define local_intr_save(x)      do { x = __intr_save(); } while (0)
#define local_intr_restore(x)   __intr_restore(x);
```

其中这两个函数最后调用的也就是cli和sti

### 等待队列

进程可以进入等待状态来等待特定事件（比如睡眠，等待子进程结束，等待信号量等）的发生来唤醒它，处于等待状态的进程插入到等待链表中等待特定事件发生，事件发生了就开始循环遍历等待队列唤醒对应的进程，设置其状态为RUNABLE，然后从队列中清除掉它

**数据结构**

```
typedef struct {
    list_entry_t wait_head;
} wait_queue_t;

struct proc_struct;

typedef struct {
    struct proc_struct *proc;
    uint32_t wakeup_flags;
    wait_queue_t *wait_queue;
    list_entry_t wait_link;
} wait_t;
```

- proc：等待进程的指针
- wakeup_flags：进程被放进等待队列的原因
- wait_queue：指向此wait结构所属的wair_queue
- wait_link：用来组织wait_queue中wait节点的连接
- wait_head：等待队列头

**初始化**

```
void
wait_init(wait_t *wait, struct proc_struct *proc) {
    wait->proc = proc;
    wait->wakeup_flags = WT_INTERRUPTED;
    list_init(&(wait->wait_link));
}

void
wait_queue_init(wait_queue_t *queue) {
    list_init(&(queue->wait_head));
}
```

第一个为初始化wait结构，第二个为初始化等待队列

**添加和删除**

```
void
wait_queue_add(wait_queue_t *queue, wait_t *wait) {
    assert(list_empty(&(wait->wait_link)) && wait->proc != NULL);
    wait->wait_queue = queue;
    list_add_before(&(queue->wait_head), &(wait->wait_link));
}

void
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
    list_del_init(&(wait->wait_link));
}
```

添加：首先检测等待队列是否为空并且等待的进程是否为空，不为空直接添加进去

删除：也是先检测等待队列是否为空，然后再检查当前等待进程是否指，对应的等待队列，检测符合条件就会删除这个结点

**获取位置**

```
wait_t *
wait_queue_next(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
    list_entry_t *le = list_next(&(wait->wait_link));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}

wait_t *
wait_queue_prev(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
    list_entry_t *le = list_prev(&(wait->wait_link));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}

wait_t *
wait_queue_first(wait_queue_t *queue) {
    list_entry_t *le = list_next(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}

wait_t *
wait_queue_last(wait_queue_t *queue) {
    list_entry_t *le = list_prev(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
        return le2wait(le, wait_link);
    }
    return NULL;
}

bool
wait_queue_empty(wait_queue_t *queue) {
    return list_empty(&(queue->wait_head));
}

bool
wait_in_queue(wait_t *wait) {
    return !list_empty(&(wait->wait_link));
}
```

- wait_queue_next：返回当前等待进程在等待队列中的下一个等待进程
- wait_queue_prev：返回当前等待进程在等待队列中的上一个等待进程
- wait_queue_first：返回当前等待队列中的第一个等待进程
- wait_queue_last：返回当前等待队列中的最后一个等待进程
- wait_queue_empty：检测等待队列是否为空
- wait_in_queue：检测当前等待进程是否在等待队列中

**唤醒与等待**

```
void
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
    if (del) {
        wait_queue_del(queue, wait);
    }
    wait->wakeup_flags = wakeup_flags;
    wakeup_proc(wait->proc);
}

void
wakeup_first(wait_queue_t *queue, uint32_t wakeup_flags, bool del) {
    wait_t *wait;
    if ((wait = wait_queue_first(queue)) != NULL) {
        wakeup_wait(queue, wait, wakeup_flags, del);
    }
}

void
wakeup_queue(wait_queue_t *queue, uint32_t wakeup_flags, bool del) {
    wait_t *wait;
    if ((wait = wait_queue_first(queue)) != NULL) {
        if (del) {
            do {
                wakeup_wait(queue, wait, wakeup_flags, 1);
            } while ((wait = wait_queue_first(queue)) != NULL);
        }
        else {
            do {
                wakeup_wait(queue, wait, wakeup_flags, 0);
            } while ((wait = wait_queue_next(queue, wait)) != NULL);
        }
    }
}

void
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
    assert(current != NULL);
    wait_init(wait, current);
    current->state = PROC_SLEEPING;
    current->wait_state = wait_state;
    wait_queue_add(queue, wait);
}
```

- wakeup_wait：唤醒当前进程
- wakeup_first：唤醒等待队列中的第一个进程
- wakeup_queue：唤醒等待队列中的全部进程
- wait_current_set：当前进程初始化wait结构，然后设置当前进程的状态为SLEEPING然后把当前进程插入到等待队列中

### 记录型信号量

由于信号量只能进行两种操作等待和发送信号，即P(sv)和V(sv),他们的行为是这样的：

P(sv)：如果sv的值大于零，就给它减1；如果它的值为零，就挂起该进程的执行

V(sv)：如果有其他进程因等待sv而被挂起，就让它恢复运行，如果没有进程因等待sv而挂起，就给它加1.

举个例子，就是两个进程共享信号量sv，一旦其中一个进程执行了P(sv)操作，它将得到信号量，并可以进入临界区，使sv减1。而第二个进程将被阻止进入临界区，因为当它试图执行P(sv)时，sv为0，它会被挂起以等待第一个进程离开临界区域并执行V(sv)释放信号量，这时第二个进程就可以恢复执行。

来源：https://blog.csdn.net/ljianhui/article/details/10243617

每个信号量s除一个整数值value（计数）外，还有一个等待队列List，其中是阻塞在该信号量的各个线程的标识。当信号量被释放一个，值被加一后，系统自动从等待队列中唤醒一个等待中的线程，让其获得信号量，同时信号量再减一。

信号量通过一个计数器控制对共享资源的访问，信号量的值是一个非负整数，所有通过它的线程都会将该整数减一。如果计数器大于0，则访问被允许，计数器减1；如果为0，则访问被禁止，所有试图通过它的线程都将处于等待状态。

计数器计算的结果是允许访问共享资源的通行证。因此，为了访问共享资源，线程必须从信号量得到通行证， 如果该信号量的计数大于0，则此线程获得一个通行证，这将导致信号量的计数递减，否则，此线程将阻塞直到获得一个通行证为止。当此线程不再需要访问共享资源时，它释放该通行证，这导致信号量的计数递增，如果另一个线程等待通行证，则那个线程将在那时获得通行证。

**临界区段**（Critical section）指的是一个访问共享资源（例如：共享设备或是共享存储器）的程序片段

对应着ucore中的代码为down对应P操作，up对应V操作，然后down更底层调用的是__down，up更底层调用的是\_\_up，对应的代码如下：

**__down：**

```
static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
        sem->value --;
        local_intr_restore(intr_flag);
        return 0;
    }
    wait_t __wait, *wait = &__wait;
    wait_current_set(&(sem->wait_queue), wait, wait_state);
    local_intr_restore(intr_flag);

    schedule();

    local_intr_save(intr_flag);
    wait_current_del(&(sem->wait_queue), wait);
    local_intr_restore(intr_flag);

    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}

void
down(semaphore_t *sem) {
    uint32_t flags = __down(sem, WT_KSEM);
    assert(flags == 0);
}
```

对应着上面介绍的操作，先检测value是不是大于0，大于0减一，然后直接返回也就代表说这个进程允许访问，但是如果value不大于0的时候就会建立一个wait结构然后把他插入到等待队列中然后调用调度函数去执行另一个进程，如果被V操作唤醒就会执行后面的把对应的结点从等待队列中删除出去，然后再检测一下当前这个wait结构进入等待队列的原因和参数wait_state是否一致

**__up：**

```
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        wait_t *wait;
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
            sem->value ++;
        }
        else {
            assert(wait->proc->wait_state == wait_state);
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
        }
    }
    local_intr_restore(intr_flag);
}

void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
}
```

对应上面介绍的操作，up需要让因P操作挂机的进程重新被激活，首先检测等待队列中是否有等待的进程如果没有则value加1，如果说有就先判断一下挂机的原因是不是因为P操作如果是的话就唤醒这个进程

对照信号量的原理性描述和具体实现，可以发现二者在流程上基本一致，只是具体实现采用了关中断的方式保证了对共享资源的互斥访问，通过等待队列让无法获得信号量的进程睡眠等待。另外，我们可以看出信号量的计数器value具有有如下性质：

- value>0，表示共享资源的空闲数
- vlaue<0，表示该信号量的等待队列里的进程数
- value=0，表示等待队列为空

### 管程

**管程（monitor）** 类型提供了一组由程序员定义的、在管程内互斥的操作。管程内定义的子程序只能访问位于管程内的局部变量和形式参数，管程内的局部变量也只能被管程内部的局部子程序访问。 **管程结构确保了同时只能有一个进程在管程内活动** 。

Hansan为管程所下的定义：“一个管程定义了一个数据结构和能为并发进程所执行（在该数据结构上）的一组操作，这组操作能同步进程和改变管程中的数据”。有上述定义可知，管程由四部分组成：

- 管程内部的共享变量
- 管程内部的条件变量
- 管程内部并发执行的进程
- 对局部于管程内部的共享数据设置初始值的语句

管程内部可定义条件变量（Condition Variables，简称CV）。一个条件变量CV可理解为一个进程的等待队列，队列中的进程正等待某个条件Cond变为真。每个条件变量关联着一个条件，如果条件Cond不为真，则进程需要等待，如果条件Cond为真，则进程可以进一步在管程中执行。

需要注意当一个进程等待一个条件变量CV（即等待Cond为真），该进程需要退出管程，这样才能让其它进程可以进入该管程执行，并进行相关操作，比如设置条件Cond为真，改变条件变量的状态，并唤醒等待在此条件变量CV上的进程。因此对条件变量CV有两种主要操作：

- wait_cv：将进程挂在对应的条件变量上等待，等待时不被认为是占用了管程。
- signal_cv：将挂在条件变量上的进程唤醒，如果没有进程挂在条件变量上则不做操作

**"哲学家就餐"实例**

**数据结构：**

1. 管程的数据结构：

   ```
   typedef struct monitor{
       semaphore_t mutex;      // the mutex lock for going into the routines in monitor, should be initialized to 1
       semaphore_t next;       // the next semaphore is used to down the signaling proc itself, and the other OR wakeuped waiting proc should wake up the sleeped signaling proc.
       int next_count;         // the number of of sleeped signaling proc
       condvar_t *cv;          // the condvars in monitor
   } monitor_t;
   ```

   - mutex：确保互斥，即一个管程中只有一个进程运行
   - next：等待队列
   - next_count：等待队列中的数量
   - cv：条件变量

2. 条件变量的数据结构：

   ```
   typedef struct condvar{
       semaphore_t sem;        // the sem semaphore  is used to down the waiting proc, and the signaling proc should up the waiting proc
       int count;              // the number of waiters on condvar
       monitor_t * owner;      // the owner(monitor) of this condvar
   } condvar_t;
   ```

   - sem：让使用wait等待的条件的进程睡眠
   - count：这个条件变量上睡眠的进程数量
   - owner：此条件变量的宿主是哪个进程

**init：**

```
void     
monitor_init (monitor_t * mtp, size_t num_cv) {
    int i;
    assert(num_cv>0);
    mtp->next_count = 0;
    mtp->cv = NULL;
    sem_init(&(mtp->mutex), 1); //unlocked
    sem_init(&(mtp->next), 0);
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
    assert(mtp->cv!=NULL);
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
        sem_init(&(mtp->cv[i].sem),0);
        mtp->cv[i].owner=mtp;
    }
}
```

初始化函数，主要的功能就是初始化管程中的成员变量，初始化等待队列，将等待队列中的等待进程数量设置为0，条件变量设置为空，设置互斥，然后初始化条件变量中的成员变量，每个条件变量都需要设置对应的挂在此条件变量上的进程数为0，然后初始化sem，然后设置该条件变量的owner为对应的管程

**wait：**

```
void
cond_wait (condvar_t *cvp) {
   /*
    *         cv.count ++;
    *         if(mt.next_count>0)
    *            signal(mt.next)
    *         else
    *            signal(mt.mutex);
    *         wait(cv.sem);
    *         cv.count --;
    */
}

```

因为wait是把进程挂在条件变量上，所以条件变量对应的数据结构中的属性count需要加1，然后检测管程中的等待进程的数量是否是大于0的，如果大于0就说明还有进程在等待，那就去唤醒等待队列中的进程，然后让当前进程挂在cv.sem上然后等到又唤醒了当前进程就把cv.count减一；对应的小于0也就代表等待队列中没有进程，就唤醒因为互斥被阻塞的进程，然后让当前进程挂在cv.sem上并且让cv.count减一，代表挂在条件变量上的进程减少了

> 对应着有一个隐含的现象就是进程a时间上先执行了cond_signal，进程b后执行了cong_wait，因为先执行的a所以当前等待队列中并没有等待的进程所以a就相当于什么都没做，而b后执行了wait就被挂在条件变量上了进入了睡眠状态，就会导致a并没有能唤醒b

**signal：**

```
void 
cond_signal (condvar_t *cvp) {
  /*
   *          if(cv.count>0) {
   *             mt.next_count ++;
   *             signal(cv.sem);
   *             wait(mt.next);
   *             mt.next_count--;
   *          }
   */
}
```

signal是唤醒挂在条件变量上的进程，首先检测有多少个进程挂在条件变量上，如果说数量是大于0的就代表有进程挂在条件变量上，然后就需要先唤醒之前挂在条件变量上的进程，因为互斥一个管程只能有一个进程，所以当前进程就需要被挂在条件变量（挂在next等待队列上）然后等待唤醒，并且因为进入了等待队列所以对应的next_count需要加一，唤醒当前进程之后next_count减一

**出入口：**

为了让整个管程正常运行，还需在管程中的每个函数的入口和出口增加相关操作，即：

```
function_in_monitor （…）
{
  sem.wait(monitor.mutex);
//-----------------------------
  the real body of function;
//-----------------------------
  if(monitor.next_count > 0)
     sem_signal(monitor.next);
  else
     sem_signal(monitor.mutex);
}
```

这样带来的作用有两个

1. 只有一个进程在执行管程中的函数（对应第3行的哪个函数调用）
2. 避免由于执行了cond_signal函数而睡眠的进程无法被唤醒。对于第二点，如果进程A由于执行了cond_signal函数而睡眠（这会让monitor.next_count大于0，且执行sem_wait(monitor.next)），则其他进程在执行管程中的函数的出口，会判断monitor.next_count是否大于0，如果大于0，则执行sem_signal(monitor.next)，从而执行了cond_signal函数而睡眠的进程被唤醒。上诉措施将使得管程正常执行（对应第7-10行的分支）

**实例：**

```
monitor dp
{
    enum {THINKING, HUNGRY, EATING} state[5];
    condition self[5];

    void pickup(int i) {
        state[i] = HUNGRY;
        test(i);
        if (state[i] != EATING)
            self[i].wait_cv();
    }

    void putdown(int i) {
        state[i] = THINKING;
        test((i + 4) % 5);
        test((i + 1) % 5);
    }

    void test(int i) {
        if ((state[(i + 4) % 5] != EATING) &&
           (state[i] == HUNGRY) &&
           (state[(i + 1) % 5] != EATING)) {
              state[i] = EATING;
              self[i].signal_cv();
        }
    }

    initialization code() {
        for (int i = 0; i < 5; i++)
        state[i] = THINKING;
        }
}
```

看一下对应的代码，首先对哲学家设置了三种状态，分别是思考，饥饿，吃饭；初始状态所有哲学家都处于思考状态，然后test会首先检测当前的哲学家是否为饥饿并且左右的两位哲学家是否是在不饥饿的状态，如果说是这样的状态的话，就代表当前的哲学家可以吃东西，然后调用signal_cv来将挂在条件变量上的进程唤醒；然后对应pickup拿起叉子，拿起叉子就代表自己处于饥饿状态，然后使用test检测左右两人是否不处于吃饭状态，如果说调用test结束之后，状态没有改变程吃饭状态，那他就需要进行等待，等待左右不处于吃饭状态；再之后就是putdown放下叉子，首先就是会设置当前状态为思考，因为放下了叉子就要思考了，然后试试看自己放下叉子之后，左右两人是否能吃饭。

但是对应这个方法有可能会导致某个哲学家饥饿致死，因为这个方法要求左右两个哲学家都不能处于吃饭的状态，比如左面的哲学家吃饭，中间的就不能吃，然后轮到右面的哲学家吃饭，中间的又不能吃，这样两个哲学家循环着吃饭，中间的哲学家就会一直吃不到饭，就会导致中间的哲学家饥饿致死

**一个改进版的 Monitor 解决方案如下。筷子本身并不属于 monitor 的一部分，否则同时只能有一个哲学家在进餐。代码中 `NUM_PHILS` 是哲学家数目。此代码解决了哲学家饥饿问题，来自[西弗吉尼亚大学](http://www.csee.wvu.edu/~jdm/classes/cs550/notes/tech/mutex/dp-mon.html)。**

```
monitor dp{
    condition self[NUM_PHILS];
    enum states {THINKING, HUNGRY, EATING} state[NUM_PHILS-1];
    int index;
    initialization_code(){
        for (index=0; index<NUM_PHILS; index++)
            flags[index] = THINKING;
    }
    void pickup(int i) {
        state[i] = HUNGRY;
        if ((state[(i-1)%NUM_PHILS] != EATING) &&
            (state[(i+1)%NUM_PHILS] != EATING))
            state[i] = EATING;
        else {
            // 挂起，等待相邻哲学家改变状态时唤醒
            self[i].wait;
            // wait 操作被唤醒后可以改变状态为 EATING
            state[i] = EATING;
        }
    }
    void putdown(int i) {
        state[i] = THINKING;
        // 唤醒左侧哲学家
        if ((state [(i-1)%NUM_PHILS] == HUNGRY) &&
            (state [(i-2)%NUM_PHILS] != EATING))
            self[(i-1)%NUM_PHILS].signal;
        // 唤醒右侧哲学家
        if ((state [(i+1)%NUM_PHILS] == HUNGRY) &&
            (state [(i+2)%NUM_PHILS] != EATING))
            self[(i+1)%NUM_PHILS].signal;
    }
}
```

这个方法虽然也是必须左右两个哲学家都必须不处于吃饭状态但是他会在放下的时候会首先尝试唤醒左右的哲学家，如果能唤醒就不会有中间的哲学家吃不上饭的情况了

## 项目组成

此次实验中，主要有如下一些需要关注的文件：

```
.  
├── boot  
├── kern   
│ ├── driver   
│ ├── fs   
│ ├── init  
│ ├── libs   
│ ├── mm   
│ │ ├── ......   
│ │ ├── vmm.c  
│ │ └── vmm.h   
│ ├── process   
│ │ ├── proc.c   
│ │ ├── proc.h  
│ │ └──......   
│ ├── schedule     
│ ├── sync  
│ │ ├── check\_sync.c  
│ │ ├── monitor.c   
│ │ ├── monitor.h    
│ │ ├── sem.c   
│ │ ├── sem.h   
│ │ ├── sync.h  
│ │ ├── wait.c   
│ │ └── wait.h   
│ ├── syscall   
│ │ ├── syscall.c    
│ │ └──......    
│ └── trap   
├── libs   
└── user   
├── forktree.c  
├── libs  
│ ├── syscall.c   
│ ├── syscall.h   
│ ├── ulib.c   
│ ├── ulib.h  
│ └── ......  
├── priority.c  
├── sleep.c  
├── sleepkill.c      
├── softint.c  
├── spin.c  
└── ......
```

简单说明如下：

- kern/schedule/{sched.h,sched.c}: 增加了定时器（timer）机制，用于进程/线程的do_sleep功能。
- kern/sync/sync.h: 去除了lock实现（这对于不抢占内核没用）。
- kern/sync/wait.[ch]: 定义了等待队列wait_queue结构和等待entry的wait结构以及在此之上的函数，这是ucore中的信号量semophore机制和条件变量机制的基础，在本次实验中你需要了解其实现。
- kern/sync/sem.[ch]:定义并实现了ucore中内核级信号量相关的数据结构和函数，本次试验中你需要了解其中的实现，并基于此完成内核级条件变量的设计与实现。
- user/ libs/ {syscall.[ch],ulib.[ch] }与kern/sync/syscall.c：实现了进程sleep相关的系统调用的参数传递和调用关系。
- user/{ sleep.c,sleepkill.c}: 进程睡眠相关的一些测试用户程序。
- kern/sync/monitor.[ch]:基于管程的条件变量的实现程序，在本次实验中是练习的一部分，要求完成。
- kern/sync/check_sync.c：实现了基于管程的哲学家就餐问题，在本次实验中是练习的一部分，要求完成基于管程的哲学家就餐问题。
- kern/mm/vmm.[ch]：用信号量mm_sem取代mm_struct中原有的mm_lock。（本次实验不用管）