/*
* @Author: resery
* @Date:   2020-09-04 11:33:02
* @Last Modified by:   resery
* @Last Modified time: 2020-09-04 16:11:08
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
	cprintf("----------------------------------------------------------\n\n");
}