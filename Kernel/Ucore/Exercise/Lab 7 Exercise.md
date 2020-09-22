# Lab 7 Exercise

## Exercise 1

**问题：**

**理解内核级信号量的实现和基于内核级信号量的哲学家就餐问题（不需要编码），完成练习0后，建议大家比较一下（可用meld等文件diff比较软件）个人完成的lab6和练习0完成后的刚修改的lab7之间的区别，分析了解lab7采用信号量的执行过程。执行`make grade`，大部分测试用例应该通过。**

**请在实验报告中给出内核级信号量的设计描述，并说明其大致执行流程。**

**请在实验报告中给出给用户态进程/线程提供信号量机制的设计方案，并比较说明给内核级提供信号量机制的异同。**

**代码：**

```
#include <stdio.h>
#include <proc.h>
#include <sem.h>
#include <monitor.h>
#include <assert.h>

#define N 5 /* 哲学家数目 */
#define LEFT (i-1+N)%N /* i的左邻号码 */
#define RIGHT (i+1)%N /* i的右邻号码 */
#define THINKING 0 /* 哲学家正在思考 */
#define HUNGRY 1 /* 哲学家想取得叉子 */
#define EATING 2 /* 哲学家正在吃面 */
#define TIMES  4 /* 吃4次饭 */
#define SLEEP_TIME 10

//---------- philosophers problem using semaphore ----------------------
int state_sema[N]; /* 记录每个人状态的数组 */
/* 信号量是一个特殊的整型变量 */
semaphore_t mutex; /* 临界区互斥 */
semaphore_t s[N]; /* 每个哲学家一个信号量 */

struct proc_struct *philosopher_proc_sema[N];

void phi_test_sema(i) /* i：哲学家号码从0到N-1 */
{ 
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
            &&state_sema[RIGHT]!=EATING)
    {
        state_sema[i]=EATING;
        up(&s[i]);
    }
}

void phi_take_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
        down(&mutex); /* 进入临界区 */
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
        phi_test_sema(i); /* 试图得到两只叉子 */
        up(&mutex); /* 离开临界区 */
        down(&s[i]); /* 如果得不到叉子就阻塞 */
}

void phi_put_forks_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
        down(&mutex); /* 进入临界区 */
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
        up(&mutex); /* 离开临界区 */
}

int philosopher_using_semaphore(void * arg) /* i：哲学家号码，从0到N-1 */
{
    int i, iter=0;
    i=(int)arg;
    cprintf("I am No.%d philosopher_sema\n",i);
    while(iter++<TIMES)
    { /* 无限循环 */
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
        do_sleep(SLEEP_TIME);
        phi_take_forks_sema(i); 
        /* 需要两只叉子，或者阻塞 */
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
        do_sleep(SLEEP_TIME);
        phi_put_forks_sema(i); 
        /* 把两把叉子同时放回桌子 */
    }
    cprintf("No.%d philosopher_sema quit\n",i);
    cprintf("\n");
    return 0;    
}

void check_sync(void){

    int i;

    sem_init(&mutex, 1);
    for(i=0;i<N;i++){
        sem_init(&s[i], 0);
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
        if (pid <= 0) {
            panic("create No.%d philosopher_using_semaphore failed.\n");
        }
        philosopher_proc_sema[i] = find_proc(pid);
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
    }

}

```

**输出：**

```
I am No.0 philosopher_sema
Iter 1, No.0 philosopher_sema is thinking
I am No.1 philosopher_sema
Iter 1, No.1 philosopher_sema is thinking
I am No.2 philosopher_sema
Iter 1, No.2 philosopher_sema is thinking
I am No.3 philosopher_sema
Iter 1, No.3 philosopher_sema is thinking
I am No.4 philosopher_sema
Iter 1, No.4 philosopher_sema is thinking
I am the child.
waitpid 8 ok.
exit pass.
Iter 1, No.0 philosopher_sema is eating
Iter 1, No.2 philosopher_sema is eating
Iter 2, No.2 philosopher_sema is thinking
Iter 1, No.3 philosopher_sema is eating
Iter 2, No.0 philosopher_sema is thinking
Iter 1, No.1 philosopher_sema is eating
Iter 2, No.1 philosopher_sema is thinking
Iter 2, No.0 philosopher_sema is eating
Iter 2, No.3 philosopher_sema is thinking
Iter 2, No.2 philosopher_sema is eating
Iter 3, No.0 philosopher_sema is thinking
Iter 1, No.4 philosopher_sema is eating
Iter 3, No.2 philosopher_sema is thinking
Iter 2, No.1 philosopher_sema is eating
Iter 2, No.4 philosopher_sema is thinking
Iter 2, No.3 philosopher_sema is eating
Iter 3, No.1 philosopher_sema is thinking
Iter 3, No.0 philosopher_sema is eating
Iter 3, No.3 philosopher_sema is thinking
Iter 3, No.2 philosopher_sema is eating
Iter 4, No.0 philosopher_sema is thinking
Iter 2, No.4 philosopher_sema is eating
Iter 4, No.2 philosopher_sema is thinking
Iter 3, No.1 philosopher_sema is eating
Iter 3, No.4 philosopher_sema is thinking
Iter 3, No.3 philosopher_sema is eating
Iter 4, No.1 philosopher_sema is thinking
Iter 4, No.0 philosopher_sema is eating
Iter 4, No.3 philosopher_sema is thinking
Iter 4, No.2 philosopher_sema is eating
No.0 philosopher_sema quit
Iter 3, No.4 philosopher_sema is eating
No.2 philosopher_sema quit
Iter 4, No.1 philosopher_sema is eating
Iter 4, No.4 philosopher_sema is thinking
Iter 4, No.3 philosopher_sema is eating
No.1 philosopher_sema quit
No.3 philosopher_sema quit
Iter 4, No.4 philosopher_sema is eating
No.4 philosopher_sema quit
```

**注：**

**P(sv)：如果sv的值大于零，就给它减1；如果它的值为零，就挂起该进程的执行**

**V(sv)：如果有其他进程因等待sv而被挂起，就让它恢复运行，如果没有进程因等待sv而挂起，就给它加1**

**拿起成功会执行一次v和一次p并且v是先执行的，拿起失败会执行一次p，value的初始值为0**

**要使用Strdie调度算法不能使用RR调度算法，因为RR调度算法是吧就绪状态的进程放在队列最后，然后取出来队列头的进程继续运行，然后我们这里运用了计时器，如果说计时器计时结束在进程唤醒之前，当哲学家放下叉子尝试左右能否拿起的时候，虽然也会唤醒左右的哲学家，但是在这之前计时器提前把另一个进程放进了就绪队列中，就会导致先去执行计时器放进去的进程而不是放下叉子后尝试唤醒的哲学家**

这部分代码直接对应着输出写具体的流程了：

1. 首先是输出五个这样的内容，然后都会依次调用sleep，让当前进程睡眠然后调度新的进程

   ```
   I am No.X philosopher_sema
   Iter 1, No.X philosopher_sema is thinking
   ```

2. 5次输出结束之后就又会进程调度执行NO.0之后的代码，此时0左右的哲学家都处于思考状态，所以0可以拿起叉子进入吃饭状态，然后又进入睡眠1，再去调度执行NO.1之后的代码，此时1左面的0处于吃饭状态，所以1拿不起来，处于饥饿状态，然后是2，之后就简单的写了括号中的对应的是P、V操作之后对应的value值的变化

   ```
   0尝试拿起成功处于吃饭状态（+1 -1 0）  1尝试拿起失败处于饥饿状态（0 挂起）  2尝试拿起成功处于吃饭状态（+1 -1 0）  3尝试拿起失败处于饥饿状态（0 挂起）  4尝试拿起失败处于饥饿状态（0 挂起）
   ```

3. ```
   0尝试放下成功处于思考状态（0）  1尝试拿起失败处于饥饿状态  2尝试拿起成功处于吃饭状态  3尝试拿起失败处于饥饿状态（0 挂起）  4尝试拿起成功处于吃饭状态（0 唤醒）
   ```

4. ```
   0尝试放下成功处于思考状态（0）  1尝试拿起成功处于吃饭状态（0 唤醒） 2尝试放下成功处于思考状态（0）  3尝试拿起失败处于饥饿状态（0 挂起）  4尝试拿起成功处于吃饭状态（0 唤醒）
   ```

5. ```
   0尝试拿起成功处于吃饭状态  1尝试放下成功处于思考状态  2尝试拿起失败处于饥饿状态（0 挂起）  3尝试放下成功处于思考状态  4尝试拿起失败处于饥饿状态（0 挂起）
   ```

6. ```
   0尝试放下成功处于思考状态  1尝试拿起失败处于饥饿状态（0 挂起）  2尝试拿起成功处于吃饭状态（0 唤醒）  3尝试放下成功处于思考状态  4尝试拿起成功处于吃饭状态（0 唤醒）
   ```

7. ```
   0尝试放下成功处于思考状态  1尝试拿起成功处于吃饭状态（0 唤醒）  2尝试放下成功处于思考状态  3尝试拿起成功处于吃饭状态（0 唤醒）  4尝试放下成功处于思考状态
   ```

8. ```
   0尝试拿起成功处于吃饭状态（0 唤醒）  1尝试放下成功处于思考状态  2尝试拿起成功处于吃饭状态（0 唤醒）  3尝试放下成功处于思考状态  4尝试拿起失败处于饥饿状态（0 挂起）
   ```

9. ```
   0尝试放下成功处于思考状态  1尝试拿起成功处于吃饭状态（0 唤醒）  2尝试放下成功处于思考状态  3尝试拿起失败处于饥饿状态（0 挂起）  4尝试拿起成功处于吃饭状态（0 唤醒）
   ```

10. ```
    0尝试拿起成功处于吃饭状态（0 唤醒）  1尝试放下成功处于思考状态  2尝试拿起失败处于饥饿状态（0 挂起）  3尝试拿起成功处于吃饭状态（0 唤醒）  4尝试放下成功处于思考状态
    ```

11. ```
    0吃够4次  1尝试拿起成功处于吃饭状态（0 唤醒）  2吃够4次  3尝试拿起失败处于饥饿状态（0 挂起）  4尝试放下成功处于思考状态
    ```

12. ```
    0吃够4次  1吃够4次  2吃够4次  3尝试拿起成功处于吃饭状态（0 唤醒）  4尝试拿起成功处于吃饭状态
    ```

13. ```
    0吃够4次  1吃够4次  2吃够4次  3吃够4次 4吃够4次
    ```

然后对应着up和down操作：

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

## Exercise 2

**问题：**

**完成内核级条件变量和基于内核级条件变量的哲学家就餐问题（需要编码）**

**首先掌握管程机制，然后基于信号量实现完成条件变量实现，然后用管程机制实现哲学家就餐问题的解决方案（基于条件变量）。**

**执行：`make grade` 。如果所显示的应用程序检测都输出ok，则基本正确。如果只是某程序过不去，比如matrix.c，则可执行**

```
make run-matrix
```

**命令来单独调试它。大致执行结果可看附录。**

**请在实验报告中给出内核级条件变量的设计描述，并说明其大致执行流程。**

**请在实验报告中给出给用户态进程/线程提供条件变量机制的设计方案，并比较说明给内核级提供条件变量机制的异同。**

**请在实验报告中回答：能否不用基于信号量机制来完成条件变量？如果不能，请给出理由，如果能，请给出设计说明和具体实现。**

这部分ucore中给了很详细的注释，根据注释的伪代码就可以完成对应的内容，不过其中最开始的管程出入口依旧使用的是信号量而不是管程的wait和signal

虽然说注释很详细，但是也需要详细的了解一下为什么要这么写，其中wait和signal的代码如下：

wait：

```
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE1: YOUR CODE
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
   /*
    *         cv.count ++;
    *         if(mt.next_count>0)
    *            signal(mt.next)
    *         else
    *            signal(mt.mutex);
    *         wait(cv.sem);
    *         cv.count --;
    */
    cvp->count++;
    if(cvp->owner->next_count>0)
      up(&(cvp->owner->next));
    else
      up(&(cvp->owner->mutex));
    down(&cvp->sem);
    cvp->count --;
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}
```

wait原本的工作就是让进程挂在这个条件变量上，所以对应着下面这些语句就可以解释了，因为有新的进程挂在了条件变量上所以说对应条件变量结构中的成员变量count需要加1，然后检测管程中是否还有别的因为wait而睡眠的进程，如果有的话就唤醒它并且需要等待唤醒的进程结束之后再能返回来继续执行当前的进程（这里就是让当前进程睡在了sem上）对应的count数也减1，如果没有的话就唤醒因为互斥被阻塞的进程，同样唤醒之后需要等待唤醒的进程结束之后才能返回来继续执行当前进程（也是让进程睡在了sem上）对应的count数也减1

signal：

```
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE1: YOUR CODE
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
  /*
   *      cond_signal(cv) {
   *          if(cv.count>0) {
   *             mt.next_count ++;
   *             signal(cv.sem);
   *             wait(mt.next);
   *             mt.next_count--;
   *          }
   *       }
   */
    if(cvp->count > 0){
      cvp->owner->next_count++;
      up(&(cvp->sem));
      down(&(cvp->owner->next));
      cvp->owner->next_count--;
    }
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
}
```

signal的工作是唤醒因为wait水面的进程，首先他就检测挂在当前条件变量上的进程数是不是大于0的，如果说是不是大于0的那就代表没有就什么操作都不做，如果说是大于0的也就代表有，因为管程中只让有一个进程运行，所以说如果唤醒了睡眠的进程，自己就需要进入睡眠状态，从而需要让next_count加1，然后唤醒对应睡在sem上的进程，并且让自己睡在next上，其实这里也对应着上面的down操作（进程睡在sem上）

init：

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

初始化操作，这部分是ucore代码里就有的不需要自行编写，来分析一下，主要就是初始化管程的数据结构和条件变量的数据结构，例如管程的有些成员变量设置为0，然后初始化对应的链表，循环初始化每个条件变量对应的数据结构

test：

```
void phi_test_condvar (i) { 
    if(state_condvar[i]==HUNGRY && state_condvar[LEFT]!=EATING && state_condvar[RIGHT]!=EATING) {
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
        state_condvar[i] = EATING ;
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
        cond_signal(&mtp->cv[i]) ;
    }
}
```

这是对应的尝试拿起操作

take：

```
void phi_take_forks_condvar(int i) {
     down(&(mtp->mutex));
//--------into routine in monitor--------------
     // LAB7 EXERCISE1: YOUR CODE
     // I am hungry
     // try to get fork
//--------leave routine in monitor--------------

     //what asp net
    state_condvar[i] = HUNGRY;
    phi_test_condvar(i);
    while(state_condvar[i] != EATING){
      cond_wait(&(mtp->cv[i]));
    }

    if(mtp->next_count>0)
       up(&(mtp->next));
    else
       up(&(mtp->mutex));
}
```

take操作就是和信号量的操作没啥大区别，只不过就是把后一部分的up操作改成了cond_wait，但其实原理也是差不多的，也就是如果说尝试拿起失败的话，就让他睡在条件变量上

put：

```
void phi_put_forks_condvar(int i) {
     down(&(mtp->mutex));

//--------into routine in monitor--------------
     // LAB7 EXERCISE1: YOUR CODE
     // I ate over
     // test left and right neighbors
//--------leave routine in monitor--------------
     state_condvar[i] = THINKING;
     phi_test_condvar(LEFT);
     phi_test_condvar(RIGHT);

     if(mtp->next_count>0)
        up(&(mtp->next));
     else
        up(&(mtp->mutex));
}
```

put操作也是和信号量的操作没啥区别，只需要把设置状态的语句改掉就可以了，即放下设置自己为思考状态，然后看看自己左右的哲学家能否吃饭

输出结果：

```
I am No.0 philosopher_condvar
Iter 1, No.0 philosopher_condvar is thinking
I am No.1 philosopher_condvar
Iter 1, No.1 philosopher_condvar is thinking
I am No.2 philosopher_condvar
Iter 1, No.2 philosopher_condvar is thinking
I am No.3 philosopher_condvar
Iter 1, No.3 philosopher_condvar is thinking
I am No.4 philosopher_condvar
Iter 1, No.4 philosopher_condvar is thinking
I am the child.
waitpid 8 ok.
exit pass.
Iter 1, No.0 philosopher_condvar is eating
Iter 1, No.2 philosopher_condvar is eating
Iter 1, No.4 philosopher_condvar is eating
Iter 2, No.0 philosopher_condvar is thinking
Iter 1, No.1 philosopher_condvar is eating
Iter 2, No.2 philosopher_condvar is thinking
Iter 1, No.3 philosopher_condvar is eating
Iter 2, No.4 philosopher_condvar is thinking
Iter 2, No.0 philosopher_condvar is eating
Iter 2, No.1 philosopher_condvar is thinking
Iter 2, No.2 philosopher_condvar is eating
Iter 2, No.3 philosopher_condvar is thinking
Iter 2, No.4 philosopher_condvar is eating
Iter 3, No.0 philosopher_condvar is thinking
Iter 2, No.1 philosopher_condvar is eating
Iter 3, No.2 philosopher_condvar is thinking
Iter 2, No.3 philosopher_condvar is eating
Iter 3, No.4 philosopher_condvar is thinking
Iter 3, No.0 philosopher_condvar is eating
Iter 3, No.1 philosopher_condvar is thinking
Iter 3, No.2 philosopher_condvar is eating
Iter 3, No.3 philosopher_condvar is thinking
Iter 3, No.4 philosopher_condvar is eating
Iter 4, No.0 philosopher_condvar is thinking
Iter 3, No.1 philosopher_condvar is eating
Iter 4, No.2 philosopher_condvar is thinking
Iter 3, No.3 philosopher_condvar is eating
Iter 4, No.4 philosopher_condvar is thinking
Iter 4, No.0 philosopher_condvar is eating
Iter 4, No.1 philosopher_condvar is thinking
Iter 4, No.2 philosopher_condvar is eating
Iter 4, No.3 philosopher_condvar is thinking
Iter 4, No.4 philosopher_condvar is eating
No.0 philosopher_condvar quit
Iter 4, No.1 philosopher_condvar is eating
No.2 philosopher_condvar quit
Iter 4, No.3 philosopher_condvar is eating
No.4 philosopher_condvar quit
No.1 philosopher_condvar quit
No.3 philosopher_condvar quit
```

可以看到这里与信号量的不太相同了，最开始有3个eating而信号量是有两个eating，一开始以为是代码错误，但是后来仔细看了以下代码，发现并不是错误，而是正确的结果

然后对具体的再分析一下：

1. 0吃饭，1饥饿挂起，2吃饭，3饥饿挂起，4饥饿挂起

2. 然后就是0放下了，放下的时候先设置本身为思考，然后看左右能否拿起，如果能拿起就唤醒对应的进程然后让自己睡眠，等待唤醒的进程执行完毕，所以说就会先输出4eating，然后才是0思考，所以按变化的顺序来看到话，应该是这样的：

   4吃饭，0思考，1吃饭，2思考，3饥饿挂起

3. 3吃饭，4思考，0吃饭，1思考，2饥饿挂起

4. 2吃饭，3思考，4吃饭，0思考，1饥饿挂起

5. 1吃饭，2思考，3吃饭，4思考，0饥饿挂起

6. 0吃饭，1思考，2吃饭，3思考，4饥饿挂起

7. 4吃饭，0思考，1吃饭，2思考，3饥饿挂起

8. 3吃饭，4思考，0吃饭，1思考，2饥饿挂起

9. 2吃饭，3思考，4吃饭，0思考，1饥饿挂起

10. 1吃饭，2思考，3吃饭，4思考，0饥饿挂起

11. 0吃饭，1思考，2吃饭，3思考，4饥饿挂起

12. 4吃饭，0思考，1吃饭，2思考，3饥饿挂起

13. 3吃饭，4思考，0吃饭，1思考，2饥饿挂起

14. 2吃饭，3思考，4吃饭，0思考，1饥饿挂起

15. 1吃饭，2思考，3吃饭，4思考，0饥饿挂起

16. 0吃饭，1思考，2吃饭，3思考，4饥饿挂起

17. 4吃饭，0吃够四次（思考），1吃饭，2吃够四次（思考），3，饥饿挂起

18. 3吃饭，4吃够四次（思考），0吃够四次（思考），1吃够四次（思考），2吃够四次（思考）

19. 3吃够四次（思考），4吃够四次（思考），0吃够四次（思考），1吃够四次（思考），2吃够四次（思考）

总体步骤应该是这样的

**用户态条件变量机制设计方案**

根据上面的分析，`cond_signal`和`cond_wait`导致的进程阻塞与唤醒都可以由信号量的相关接口进行完成，因此可以考虑设计用户态的管程机制，由语言内部维护（例如JAVA）或是用户手动维护这两个必要函数的运作，通过系统调用完成对信号量的PV操作。

**基于信号量完成条件变量**

信号量和条件变量虽然在结构上均为一个整形变量加一个等待队列，但是其概念不一样，对于整形数的解释也不一样，不能一概而论。条件变量中，整形值`numWaiting`表示正在等待队列中等待该条件变量`signal`的进程个数；而信号量中，整形值`value`表示资源的剩余数目，不直接反映等待队列中的进程数目。如果一个进程执行了信号量的`V()`操作，下次执行`P()`操作的时候就能无阻塞执行；而条件变量在执行`signal()`操作之后，如果等待队列中没有等待项目，则这条语句实际上被忽略。

但是，在uCore中为了统一灵活实现，的确使用了信号量`semaphore_t`作为条件变量`condvar_t`的组成部分：

```
typedef struct condvar{
    semaphore_t sem;        // 用于阻塞wait进程
    int count;              // 被阻塞进程的数目
    ...
} condvar_t;
```

在执行`signal`或是`wait`操作的时候，`sem`即用于唤醒和阻塞进程，可以直接通过调用其`up`和`down`接口来实现这些功能，使得程序设计更加灵活

## Extend Exercise 1

**问题：**

**在ucore中实现简化的死锁和重入探测机制**

**在ucore下实现一种探测机制，能够在多进程/线程运行同步互斥问题时，动态判断当前系统是否出现了死锁产生的必要条件，是否产生了多个进程进入临界区的情况。 如果发现，让系统进入monitor状态，打印出你的探测信息。**

**死锁**
死锁可以用一个简单的例子来解释，比如有两个进程A和B，然后现再有两份资源C和D，A现再占用着C，B占用着D，但是A同时需要C和D才可以完成工作但是D在B那里A就需要等待B释放D，与此同时B也同时需要C和D才可以完成工作并且B也在等A释放D，这样就会导致，A和B互相等待谁也不会释放手中的资源，这样就会导致死锁。**官方一点的解释就是：多个并发进程因争夺系统资源而产生相互等待的现象。**

**死锁产生的原因：**

1. 系统资源有限
2. 进程推进顺序不合理

**死锁产生的4个必要条件**

  1、互斥：某种资源一次只允许一个进程访问，即该资源一旦分配给某个进程，其他进程就不能再访问，直到该进程访问结束。

  2、占有且等待：一个进程本身占有资源（一种或多种），同时还有资源未得到满足，正在等待其他进程释放该资源。

  3、不可抢占：别人已经占有了某项资源，你不能因为自己也需要该资源，就去把别人的资源抢过来。

  4、循环等待：存在一个进程链，使得每个进程都占有下一个进程所需的至少一种资源。

这四个必要条件和上面的例子正好对应，互斥：A拿了C，B就不能拿，占有且等待：A在等B释放D，不可抢占：A只能等B释放D，不可以抢过来，循环等待：A在等B，B在等A

**注：这里我看了对应文章的评论有一个我觉着比较重要的一个点，就是这个四个条件与死锁的必要不充分关系，简单点说就是这四个条件产生了不一定会产生死锁，但是死锁产生了就一定会产生这四个条件**

**此时我就发现了一个问题，这个练习让检测是否产生了死锁的必要条件，但是即使4个条件都产生了也不一定会产生死锁，一旦误判成了死锁做了对应的操作会产生什么样的后果，不过不知道后面加一个检测是否有多个进程在临界区会不会解决这个问题**

**实现死锁：**

我实现的这个死锁，只是思想上有这个思想但是实际上并没有实现的特别好，我原本的想法是让父进程和子进程互相等待，做法就是创建一个数据结构定义3个成员变量a、b、c，然后父进程读a，子进程读b，然后父进程和子进程都需要计算c = a + b 然后因为父进程占有a，子进程占有b，就会导致两个进程互相等待，然后遇到一个问题就是父进程读a怎么能让子进程无法访问a和使用a，我都解决办法就是加了一个flag变量，其中最低位置1代表a被占有，倒数第二位代表b被占有，只有当flag为0的时候才证明a和b没有被父进程和子进程同时占有，代码如下：

```
#include <stdio.h>
#include <ulib.h>

int sign_father = 1;
int sign_son = 1;
int sign = 1;

struct all{
    int a;
    int b;
    int c;
}test;

int flag = 1;

int main() {   
    
    int pid = 0;

    pid = fork();
    if(pid != 0){
        cprintf("father catch the a\n\n");
        test.a=1;
        flag |= 1;
    }
    else{
        cprintf("son catch the b\n\n");
        test.b=1;
        flag |= 2;
    }

    int d = 0;

    TEST:

      if(flag != 0){
            if(pid != 0){
                cprintf("I am the father and I want to catch a and b but failed\n\n");
                yield();
            }
            else{
                cprintf("I am the son and I want to catch a and b but failed\n\n");
                yield();
            }
            goto TEST;
      }
      else{
          cprintf("catch the c\n\n");
        d = 1;
          test.c = 1;
            flag = 4;
      }

    return 0;
}
```

输出的结果就会是这样的，一直循环下去：

```
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
I am the son and I want to catch a and b but falied
I am the father and I want to catch a and b but falied
```

**探测机制：**

探测机制就可以对应着上面的判断来设计，5部分，一部分检测是不是互斥状态，一部分检测是不是正在等待别人释放，一部分检测是不是别人占有的自己不能抢占，一部分检测是不是有两个进程在互相等待，一部分检测临界区是不是有多个进程

对应上面简易的死锁，所以探测机制也只能是简易的了，比如5部分，应该只能完成第2、3、4部分

对应代码（以死锁代码为基础修改的）：

```
#include <stdio.h>
#include <ulib.h>

int sign_father = 1;
int sign_son = 1;
int sign = 1;

struct all{
    int a;
    int b;
    int c;
}test;

int check(int pid,struct all test,int flag){
    if(pid != 0 && (flag & 1 == 1))
    {
        sign_father = 2;
        sign++;
    }
    else if(pid == 0 && (flag & 2 == 2))
    {
        sign_son = 2;
        sign++;
    }

    if((sign_father + sign_son == 3) && sign == 3){
        cprintf("Deadlock\n\n");
        flag = 0;
    }
    return flag;
}

int flag = 1;

int main() {   
    
    int pid = 0;

    pid = fork();
    if(pid != 0){
        cprintf("father catch the a\n\n");
        test.a=1;
        flag |= 1;
    }
    else{
        cprintf("son catch the b\n\n");
        test.b=1;
        flag |= 2;
    }

    int d = 0;

    TEST:

      if(flag != 0){
            if(pid != 0){
                cprintf("I am the father and I want to catch a and b but failed\n\n");
                flag = check(pid,test,flag);
                yield();
            }
            else{
                cprintf("I am the son and I want to catch a and b but failed\n\n");
                flag = check(pid,test,flag);
                yield();
            }
            goto TEST;
      }
      else{
          cprintf("catch the c\n\n");
        d = 1;
          test.c = 1;
            flag = 4;
      }

    return 0;
}
```

输出结果如下：

```
father catch the a

I am the father and I want to catch a and b but failed

son catch the b

I am the son and I want to catch a and b but failed

I am the son and I want to catch a and b but failed

Deadlock

I am the father and I want to catch a and b but failed

Deadlock

catch the c

catch the c
```

## Extend Exercise 2

**问题：**

**参考Linux的RCU机制，在ucore中实现简化的RCU机制**

**在ucore 下实现下Linux的RCU同步互斥机制。可阅读相关Linux内核书籍或查询网上资料，可了解RCU的设计实现细节，然后简化实现在ucore中。 要求有实验报告说明你的设计思路，并提供测试用例。下面是一些参考资料：**

- **http://www.ibm.com/developerworks/cn/linux/l-rcu/**
- **http://www.diybl.com/course/6_system/linux/Linuxjs/20081117/151814.html**

参考链接：

https://blog.csdn.net/xabc3000/article/details/15335131

https://thinkycx.me/2018-07-23-take-a-look-at-linux-kernel-RCU.html

https://www.ibm.com/developerworks/cn/linux/l-rcu/

**RCU机制：**

RCU全称read only update，是Linux内核中的一种同步机制。RCU的原理可以简述如下：RCU记录了所有对共享数据的使用者。当内核线程需要write某个数据时，先创建一个副本，在副本中修改。当所有读线程都离开临界区后，新的数据才被更新。

相对于其它的同步机制，由于RCU的写时复制，因此如果对于读数据的线程，开销是很小的。只有修改数据时，才会带来额外的开销。

> RCU主要针对的数据对象是链表，目的是提高遍历读取数据的效率，为了达到目的使用RCU机制读取数据的时候不对链表进行耗时的加锁操作。这样在同一时间可以有多个线程同时读取该链表，并且允许一个线程对链表进行修改（修改的时候，需要加锁）。RCU适用于需要频繁的读取数据，而相应修改数据并不多的情景，例如在文件系统中，经常需要查找定位目录，而对目录的修改相对来说并不多，这就是RCU发挥作用的最佳场景。

**内核中关于RCU的常见接口如下：**

1. **rcu_read_lock()/ rcu_read_unlock()** RCU临界区

2. **read_newptr = rcu_dereference(ptr)** 内核线程读取数据时，获取被RCU保护的指针，进行读操作时，用newptr来读。

3. **rcu_assign_pointer(ptr, newptr)**

   修改原来的指针，指向被复制并被修改后的数据。步骤可以简述如下：

   1. 在写之前，ptr指向旧的数据，创建一个oldptr和newptr，其中oldptr指向原来的数据，newptr需要malloc之后复制时需要的空间。
   2. 用oldptr复制数据给newptr后，使用newptr更新数据。
   3. 更新数据完成后，修改原来的指针时，就需要调用本接口rcu_assign_pointer(ptr, newptr) 来实现更新原有的数据。
   4. 通常在此时候会用4中的回调函数来删除oldptr。

4. **call_rcu()** 注册回调函数，一般是在写的线程中，当所有的读线程离开临界区后，删除旧数据。

下面是一个使用RCU的例子，代码如下：

```
struct foo{
  int a;
  struct rcu_head rcu;
};

static struct foo *g_ptr;

static void myrcu_reader_thread(void *data){
  struct foo *p = NULL;
  while(1){
    msleep(200);
    rcu_read_lock();
    p = rcu_dereference(g_ptr);
    if(p)
      printf("%s: read a=%d\n",__func__,p->a);
    rcu_read_unlock();
  }
}

static void myrcu_writer_thread(void *p){
  struct foo *new;
  struct foo *old;
  int value = (unsigned long)p;
  
  while(1){
    msleep(400);
    struct foo *new_ptr = kmalloc(sizeof (struct foo),GFP_KERNEL);
    old = g_ptr;
    printf("%s: write to new %d\n",__func__,value);
    *new_ptr = *old;
    new_ptr->a = value;
    rcu_assign_pointer(g_ptr,new_ptr);
    call_rcu(&old->rcu,myrcu_del);
  }
}
```

在该例子中，需要同步的数据结构为struct foo，并创建了结构体指针g_ptr。

**读线程**使用`rcu_read_lock()`和`rcu_read_unlock()`创建临界区后，使用`p= rcu_dereference(g_ptr)`来获取被保护的指针，后续使用p来读数据。

**写线程**创建了`old`和`new_ptr`结构体指针，`new_ptr`调用`kmalloc`申请了需要复制的结构体的大小，并把`old`数据复制给`new_ptr`，之后使用`new_ptr`修改数据完成后，调用`rcu_assign_pointer(g_ptr, new_ptr)`来修改原始的`g_ptr`，并调用`call_rcu`注册回调函数用户删除`old`数据。

**宽限期GP**，在读取过程中，另外一个线程删除了一个节点。删除线程可以把这个节点从链表中移除，但它不能直接销毁这个节点，必须等到所有的读取线程读取完成以后，才进行销毁操作。RCU中把这个过程称为宽限期（Grace period）。

关于宽限期可以用一个图来解释，不过这个图需要配合文字来解释才容易理解，不配合文字只看图片还是会一头雾水

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-09-04_10-41-22.png)

对应着图片可以看到应该是有7个线程（这时候应该是会产生疑问了，就是明明图中只有6个线程，多出来的那一个线程是在哪里的，多出来的那个进程对应的其实是最后一行的删除），然后根据图中可以看到线程7开始执行完删除操作就进入了宽限区，然后在线程2结束读之后离开了宽限区，离开之后就销毁了删除的线程。

然后我就产生了一些问题，为什么不等待宽限区中所有的线程都结束读操作之后再离开宽限区，还有就是线程5为什么不在宽限区内

现在就是解决我自己的问题：首先根据定义线程7删除一个结点只是把他从链表中删除而没有直接删除（意思就是这个节点还在其余线程还是可以对这个节点进行读的，只有销毁了才不能再继续访问），所以说在线程7开始到结束的这个过程中其余的线程都有可能会对这个节点进行访问，对应的就是1和2线程是在线程7开始到结束存在的线程所以说1和2就是会有可能对删除的节点进行访问就需要等到1和2都结束之后才能进行销毁，然后其余的3、4、6这三个线程由于他们是在线程7之后才开始的因为线程7已经把节点从链表中删除出去了所以3、4、6线程也不可能访问到这个删除的节点也就不用等待这3个线程都结束之后再离开宽限区，第一个问题就已经解决了，第二个问题就更容易一些了，线程5结束是在线程7开始之前就已经结束了对任何节点的访问，所以线程7删除的节点线程5是肯定不会访问的，所以线程5就不需要进入到宽限区

**关于实现：**

和以前一样只能实现一个简易的RCU，对应着上面实现的代码中可以仿照他做一下，不过就是没有更新指针的那个步骤，对应的也就是实现了`rcu_read_lock()`函数、`rcu_read_unlock()`函数和一个`rcu_check_gp()`函数

然后我们设计了5个进程，1个进程是写，4个进程是读，执行的顺序是r1-r2-w1-r3-r4，因为是简易版本所以就设计了一个资源，所有进程都是读它写它。进程r1-r2在读还没有结束，w1要开始写就需要等待r1和r2结束，结束后w1开始写，写完之后r3-r4读出来的内容就是w1写过的内容了，通过输出资源的值就可以检测出w1是不是等到r1和r2结束了才开始写的

`rcu_read_lock()`函数执行的功能是检测当前是不是还在读没有更新过的资源如果是就增加宽限区长度，这里也就是r1开始就增加宽限区长度，但是这和之前说的概念是有些出入的，原先的概念是删除开始到结束之后在开始增加宽限区长度，不过因为我实现的是简易版的所以说就需要在r1开始就增加宽限区长度

`rcu_read_unlock()`函数与`rcu_read_lock()`函数功能正好相反，同样先检测当前是不是在读没有更新过的资源不过符合这种情况的话就减少宽限区长度

`rcu_check_gp()`函数顾名思义就是检测gp长度的，只有当gp长度为0才能进行写操作

主要就是这三个函数，然后就是上面示例代码中的read和update了，实现这5个函数基本就可以完成操作了

代码如下：

```
/*
* @Author: resery
* @Date:   2020-09-04 11:33:02
* @Last Modified by:   resery
* @Last Modified time: 2020-09-04 16:09:57
*/
#include <stdio.h>
#include <sync.h>

typedef struct{
  int num;
  char flag; 
}resources;

resources* old_ptr = NULL;
resources* new_ptr = NULL;
resources* glb_ptr = NULL;

int r1,r2,w1,r3,r4;

int gp_count = 0;

static void rcu_read_lock(resources* ptr) {
  if (ptr == old_ptr) {
    gp_count += 1;
  }
}

static void rcu_read_unlock(resources* ptr) {
  if (ptr == old_ptr) {
    gp_count -= 1;
  }
}

static int rcu_check_gp() {
  return (gp_count != 0);
}

static void rcu_read(int id) {
  cprintf("----------------------------------------------------------\n\n");
  if(id >= 4){
    cprintf("R%d begin\n\n",id-1);
  }
  else{
    cprintf("R%d begin\n\n",id);
  }
  
  rcu_read_lock(glb_ptr);

  resources* p = glb_ptr;

  if (p != NULL) {

    do_sleep(4);
    cprintf("----------------------------------------------------------\n\n");

    if(id >= 4)
      cprintf("Now R%d's num = %d and flag = %c\n\n", id-1, p->num, p->flag);
    else
      cprintf("Now R%d's num = %d and flag = %c\n\n", id, p->num, p->flag);
  }
  else {
    panic("old_ptr is null");
  }

  rcu_read_unlock(p);

  if(id >= 4){
    cprintf("R%d ends\n\n",id-1);
  }
  else{
    cprintf("R%d ends\n\n",id);
  }

}

static void rcu_update(int id) {
  cprintf("----------------------------------------------------------\n\n");
  cprintf("W1 begin and gp_count is %d so W1 need to wait R1 and R2\n\n", gp_count);

  resources* old = glb_ptr;
  glb_ptr = new_ptr;

  while (rcu_check_gp()){
    do_sleep(4);
  } 

  kfree(old);
  cprintf("----------------------------------------------------------\n\n");
  cprintf("W1 ends.\n\n");
}


void check_rcu(){

  //---------------------------------------------------
  old_ptr = (resources*) kmalloc(sizeof(resources));
  old_ptr->num = 0;
  old_ptr->flag = 'N';
  new_ptr = (resources*) kmalloc(sizeof(resources));
  new_ptr->num = 9;
  new_ptr->flag = 'Y';
  //---------------------------------------------------

  glb_ptr = old_ptr; 

  r1 = kernel_thread(rcu_read,(void *)1, 0);
  r2 = kernel_thread(rcu_read,(void *)2, 0);
  w1 = kernel_thread(rcu_update,(void *)3, 0);
  r3 = kernel_thread(rcu_read,(void *)4, 0);
  r4 = kernel_thread(rcu_read,(void *)5, 0);

  do_wait(r1, NULL);
  do_wait(r2, NULL);
  do_wait(w1, NULL);
  do_wait(r3, NULL);
  do_wait(r4, NULL);

  cprintf("----------------------------------------------------------\n\n");
  cprintf("check_rcu passed!\n\n");
}
```

输出结果：

```
----------------------------------------------------------

R1 begin

----------------------------------------------------------

R2 begin

----------------------------------------------------------

W1 begin and gp_count is 2 so W1 need to wait R1 and R2

----------------------------------------------------------

R3 begin

----------------------------------------------------------

R4 begin

----------------------------------------------------------

Now R1's num = 0 and flag = N

R1 ends

----------------------------------------------------------

Now R2's num = 0 and flag = N

R2 ends

----------------------------------------------------------

W1 ends.

----------------------------------------------------------

Now R3's num = 9 and flag = Y

R3 ends

----------------------------------------------------------

Now R4's num = 9 and flag = Y

R4 ends

----------------------------------------------------------

check_rcu passed!

----------------------------------------------------------
```

