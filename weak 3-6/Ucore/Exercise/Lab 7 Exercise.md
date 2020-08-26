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







## Extend Exercise 2

**问题：**

**参考Linux的RCU机制，在ucore中实现简化的RCU机制**

**在ucore 下实现下Linux的RCU同步互斥机制。可阅读相关Linux内核书籍或查询网上资料，可了解RCU的设计实现细节，然后简化实现在ucore中。 要求有实验报告说明你的设计思路，并提供测试用例。下面是一些参考资料：**

- **http://www.ibm.com/developerworks/cn/linux/l-rcu/**
- **http://www.diybl.com/course/6_system/linux/Linuxjs/20081117/151814.html**