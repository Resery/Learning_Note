/*
* @Author: resery
* @Date:   2020-08-19 21:04:58
* @Last Modified by:   resery
* @Last Modified time: 2020-08-19 21:43:17
*/
#include <stdio.h>
#include <ulib.h>
#include <string.h>

const int max_child = 5;

int
main(void) {
	cprintf("\n");
	cprintf("\n");
	cprintf("\n");
    cprintf("dirty cow test\n");
    cprintf("\n");
    cprintf("\n");
    cprintf("\n");

    int n, pid;
    for (n = 0; n < max_child; n ++) {
        if ((pid = fork()) == 0) {
            cprintf("I am child %d\n", n);
            exit(0);
        }
        assert(pid > 0);
    }

    if (n > max_child) {
        panic("fork claimed to work %d times!\n", n);
    }

    for (; n > 0; n --) {
        if (wait() != 0) {
            panic("wait stopped early\n");
        }
    }

    if (wait() == 0) {
        panic("wait got too many\n");
    }

    cprintf("forktest pass.\n");
    return 0;
}