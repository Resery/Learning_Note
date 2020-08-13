#include <memlayout.h>

# vectors.S sends all traps here.
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
    pushl %es
    pushl %fs
    pushl %gs
    pushal

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
    movw %ax, %ds
    movw %ax, %es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp

    # call trap(tf), where tf=%esp
    call trap

    # pop the pushed stack pointer
    popl %esp

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal

    # restore %ds, %es, %fs and %gs
    popl %gs
    popl %fs
    popl %es
    popl %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
    iret

.globl __move_down_stack2 
# this function aims to move down the whole stack frame by 2 bytes so that we can insert our fake esp and ss into the trapframe
__move_down_stack2:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx
    pushl %esi
    pushl %edi

    movl 8(%ebp), %ebx # ebx store the end (higher boundary) of current trapframe
    movl 12(%ebp), %edi
    subl $8, -4(%edi) # fix esp which __alltraps store on stack
    movl %esp, %eax

    cmpl %eax, %ebx
    jle loop_end

loop_start:
    movb (%eax), %cl
    movb %cl, -8(%eax)
    addl $1, %eax
    cmpl %eax, %ebx
    jg loop_start

loop_end: 
    subl $8, %esp 
    subl $8, %ebp # remember, it is critical to correct all the base pointer store in stack area which is affected by our operations above
    
    movl %ebp, %eax
    cmpl %eax, %ebx
    jle ebp_loop_end

ebp_loop_begin:
    movl (%eax), %ecx

    cmpl $0, %ecx
    je ebp_loop_end
    cmpl %ecx, %ebx
    jle ebp_loop_end
    subl $8, %ecx
    movl %ecx, (%eax)
    movl %ecx, %eax
    jmp ebp_loop_begin

ebp_loop_end:

    popl %edi
    popl %esi
    popl %ebx

    popl %ebp
    ret 

.globl __move_up_stack2
# this function aims to move the trapframe along with all stack frames below up by 2 bytes
# arg1 tf_end 
# arg2 tf
# arg3 user esp
__move_up_stack2:
    pushl %ebp 
    movl %esp, %ebp

    pushl %ebx
    pushl %edi
    pushl %esi

# first of all, copy every below tf_end to user stack
    movl 8(%ebp), %eax
    subl $1, %eax
    movl 16(%ebp), %ebx # ebx store the user stack pointer 
    
    cmpl %eax, %esp
    jg copy_loop_end

copy_loop_begin:
    subl $1, %ebx
    movb (%eax), %cl
    movb %cl, (%ebx)

    subl $1, %eax
    cmpl %eax, %esp
    jle copy_loop_begin

copy_loop_end:

# now we have to fix all ebp on user stack, note that we can calculate the true ebp using their address displacement
    movl %ebp, %eax
    cmpl %eax, 8(%ebp)
    jle fix_ebp_loop_end

fix_ebp_loop_begin:
    movl %eax, %edi
    subl 8(%ebp), %edi
    addl 16(%ebp), %edi # edi <=> eax

    cmpl (%eax), %esp 
    jle normal_condition
    movl (%eax), %esi
    movl %esi, (%edi)
    jmp fix_ebp_loop_end

normal_condition:
    movl (%eax), %esi
    subl 8(%ebp), %esi
    addl 16(%ebp), %esi
    movl %esi, (%edi)
    movl (%eax), %eax
    jmp fix_ebp_loop_begin

fix_ebp_loop_end:

# fix the esp which __alltraps store on stack
    movl 12(%ebp), %eax
    subl $4, %eax

    movl %eax, %edi
    subl 8(%ebp), %edi
    addl 16(%ebp), %edi

    movl (%eax), %esi
    subl 8(%ebp), %esi
    addl 16(%ebp), %esi

    movl %esi, (%edi)

    movl 12(%ebp), %eax
    subl 8(%ebp), %eax
    addl 16(%ebp), %eax

# switch to user stack
    movl %ebx, %esp
    movl %ebp, %esi
    subl 8(%ebp), %esi
    addl 16(%ebp), %esi
    movl %esi, %ebp

    popl %esi
    popl %edi
    popl %ebx

    popl %ebp
    ret