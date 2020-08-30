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
