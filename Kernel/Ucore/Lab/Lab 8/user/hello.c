#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("Hello world!!.\n");
    cprintf("I am process %d.\n", getpid());
    cprintf("Ucore Lab Is Over!!.\n");
    cprintf("hello pass.");
    return 0;
}

