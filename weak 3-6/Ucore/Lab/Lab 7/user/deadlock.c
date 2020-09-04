/*
* @Author: resery
* @Date:   2020-09-03 20:05:17
* @Last Modified by:   resery
* @Last Modified time: 2020-09-04 08:20:11
*/
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
