# Lab 5

## 基础知识

### 实验执行流程概述

在内存管理部分，与lab4最大的区别就是增加用户态虚拟内存的管理。为了管理用户态的虚拟内存，需要对页表的内容进行扩展，能够把部分物理内存映射为用户态虚拟内存。如果某进程执行过程中，CPU在用户态下执行（在CS段寄存器最低两位包含有一个2位的优先级域，如果为0，表示CPU运行在特权态；如果为3，表示CPU运行在用户态。），则可以访问本进程页表描述的用户态虚拟内存，但由于权限不够，不能访问内核态虚拟内存。另一方面，不同的进程有各自的页表，所以即使不同进程的用户态虚拟地址相同，但由于页表把虚拟页映射到了不同的物理页帧，所以不同进程的虚拟内存空间是被隔离开的，相互之间无法直接访问。在用户态内存空间和内核态内核空间之间需要拷贝数据，让CPU处在内核态才能完成对用户空间的读或写，为此需要设计专门的拷贝函数（copy_from_user和copy_to_user）完成。但反之则会导致违反CPU的权限管理，导致内存访问异常。

在进程管理方面，主要涉及到的是进程控制块中与内存管理相关的部分，包括建立进程的页表和维护进程可访问空间（可能还没有建立虚实映射关系）的信息；加载一个ELF格式的程序到进程控制块管理的内存中的方法；在进程复制（fork）过程中，把父进程的内存空间拷贝到子进程内存空间的技术。另外一部分与用户态进程生命周期管理相关，包括让进程放弃CPU而睡眠等待某事件；让父进程等待子进程结束；一个进程杀死另一个进程；给进程发消息；建立进程的血缘关系链表。

当实现了上述内存管理和进程管理的需求后，接下来ucore的用户进程管理工作就比较简单了。首先，“硬”构造出第一个进程（lab4中已有描述），它是后续所有进程的祖先；然后，在proc_init函数中，通过alloc把当前ucore的执行环境转变成idle内核线程的执行现场；然后调用kernl_thread来创建第二个内核线程init_main，而init_main内核线程又创建了user_main内核线程.。到此，内核线程创建完毕，应该开始用户进程的创建过程，这第一步实际上是通过user_main函数调用kernel_tread创建子进程，通过kernel_execve调用来把某一具体程序的执行内容放入内存。具体的放置方式是根据ld在此文件上的地址分配为基本原则，把程序的不同部分放到某进程的用户空间中，从而通过此进程来完成程序描述的任务。一旦执行了这一程序对应的进程，就会从内核态切换到用户态继续执行。以此类推，CPU在用户空间执行的用户进程，其地址空间不会被其他用户的进程影响，但由于系统调用（用户进程直接获得操作系统服务的唯一通道）、外设中断和异常中断的会随时产生，从而间接推动了用户进程实现用户态到到内核态的切换工作。ucore对CPU内核态与用户态的切换过程需要比较仔细地分析（这其实是实验一的扩展练习）。当进程执行结束后，需回收进程占用和没消耗完毕的设备整个过程，且为新的创建进程请求提供服务。在本实验中，当系统中存在多个进程或内核线程时，ucore采用了一种FIFO的很简单的调度方法来管理每个进程占用CPU的时间和频度等。在ucore运行过程中，由于调度、时间中断、系统调用等原因，使得进程会进行切换、创建、睡眠、等待、发消息等各种不同的操作，周而复始，生生不息。

### 创建用户进程

#### 1. 应用程序的组成和编译

我们首先来看一个应用程序，这里我们假定是hello应用程序，在user/hello.c中实现，代码如下：

```
#include <stdio.h>
#include <ulib.h>

int main(void) {
    cprintf("Hello world!!.\n");
    cprintf("I am process %d.\n", getpid());
    cprintf("hello pass.\n");
    return 0;
}
```

hello应用程序只是输出一些字符串，并通过系统调用sys_getpid（在getpid函数中调用）输出代表hello应用程序执行的用户进程的进程标识--pid。

首先，我们需要了解ucore操作系统如何能够找到hello应用程序。这需要分析ucore和hello是如何编译的。修改Makefile，把第六行注释掉。然后在本实验源码目录下执行make，可得到如下输出：

```
……
+ cc user/hello.c

gcc -Iuser/ -fno-builtin -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Iuser/include/ -Iuser/libs/ -c user/hello.c -o obj/user/hello.o

ld -m    elf_i386 -nostdlib -T tools/user.ld -o obj/__user_hello.out  obj/user/libs/initcode.o obj/user/libs/panic.o obj/user/libs/stdio.o obj/user/libs/syscall.o obj/user/libs/ulib.o obj/user/libs/umain.o  obj/libs/hash.o obj/libs/printfmt.o obj/libs/rand.o obj/libs/string.o obj/user/hello.o
……
ld -m    elf_i386 -nostdlib -T tools/kernel.ld -o bin/kernel  obj/kern/init/entry.o obj/kern/init/init.o …… -b binary …… obj/__user_hello.out
……
```

从中可以看出，hello应用程序不仅仅是hello.c，还包含了支持hello应用程序的用户态库：

- user/libs/initcode.S：所有应用程序的起始用户态执行地址“_start”，调整了EBP和ESP后，调用umain函数。

  ```
  .text
  .globl _start
  _start:
      # set ebp for backtrace
      movl $0x0, %ebp
  
      # move down the esp register
      # since it may cause page fault in backtrace
      subl $0x20, %esp
  
      # call user-program function
      call umain
  1:  jmp 1b
  ```

- user/libs/umain.c：实现了umain函数，这是所有应用程序执行的第一个C函数，它将调用应用程序的main函数，并在main函数结束后调用exit函数，而exit函数最终将调用sys_exit系统调用，让操作系统回收进程资源。

  ```
  #include <ulib.h>
  
  int main(void);
  
  void
  umain(void) {
      int ret = main();
      exit(ret);
  }
  ```

- user/libs/ulib.[ch]：实现了最小的C函数库，除了一些与系统调用无关的函数，其他函数是对访问系统调用的包装。

  ```
  .c:
  #include <defs.h>
  #include <syscall.h>
  #include <stdio.h>
  #include <ulib.h>
  
  void
  exit(int error_code) {
      sys_exit(error_code);
      cprintf("BUG: exit failed.\n");
      while (1);
  }
  
  int
  fork(void) {
      return sys_fork();
  }
  
  int
  wait(void) {
      return sys_wait(0, NULL);
  }
  
  int
  waitpid(int pid, int *store) {
      return sys_wait(pid, store);
  }
  
  void
  yield(void) {
      sys_yield();
  }
  
  int
  kill(int pid) {
      return sys_kill(pid);
  }
  
  int
  getpid(void) {
      return sys_getpid();
  }
  
  //print_pgdir - print the PDT&PT
  void
  print_pgdir(void) {
      sys_pgdir();
  }
  
  
  .h:
  #ifndef __USER_LIBS_ULIB_H__
  #define __USER_LIBS_ULIB_H__
  
  #include <defs.h>
  
  void __warn(const char *file, int line, const char *fmt, ...);
  void __noreturn __panic(const char *file, int line, const char *fmt, ...);
  
  #define warn(...)                                       \
      __warn(__FILE__, __LINE__, __VA_ARGS__)
  
  #define panic(...)                                      \
      __panic(__FILE__, __LINE__, __VA_ARGS__)
  
  #define assert(x)                                       \
      do {                                                \
          if (!(x)) {                                     \
              panic("assertion failed: %s", #x);          \
          }                                               \
      } while (0)
  
  // static_assert(x) will generate a compile-time error if 'x' is false.
  #define static_assert(x)                                \
      switch (x) { case 0: case (x): ; }
  
  void __noreturn exit(int error_code);
  int fork(void);
  int wait(void);
  int waitpid(int pid, int *store);
  void yield(void);
  int kill(int pid);
  int getpid(void);
  void print_pgdir(void);
  
  #endif /* !__USER_LIBS_ULIB_H__ */
  ```

- user/libs/syscall.[ch]：用户层发出系统调用的具体实现。

  ```
  .c:
  #include <defs.h>
  #include <unistd.h>
  #include <stdarg.h>
  #include <syscall.h>
  
  #define MAX_ARGS            5
  
  static inline int
  syscall(int num, ...) {
      va_list ap;
      va_start(ap, num);
      uint32_t a[MAX_ARGS];
      int i, ret;
      for (i = 0; i < MAX_ARGS; i ++) {
          a[i] = va_arg(ap, uint32_t);
      }
      va_end(ap);
  
      asm volatile (
          "int %1;"
          : "=a" (ret)
          : "i" (T_SYSCALL),
            "a" (num),
            "d" (a[0]),
            "c" (a[1]),
            "b" (a[2]),
            "D" (a[3]),
            "S" (a[4])
          : "cc", "memory");
      return ret;
  }
  
  int
  sys_exit(int error_code) {
      return syscall(SYS_exit, error_code);
  }
  
  int
  sys_fork(void) {
      return syscall(SYS_fork);
  }
  
  int
  sys_wait(int pid, int *store) {
      return syscall(SYS_wait, pid, store);
  }
  
  int
  sys_yield(void) {
      return syscall(SYS_yield);
  }
  
  int
  sys_kill(int pid) {
      return syscall(SYS_kill, pid);
  }
  
  int
  sys_getpid(void) {
      return syscall(SYS_getpid);
  }
  
  int
  sys_putc(int c) {
      return syscall(SYS_putc, c);
  }
  
  int
  sys_pgdir(void) {
      return syscall(SYS_pgdir);
  }
  
  .h:
  #ifndef __USER_LIBS_SYSCALL_H__
  #define __USER_LIBS_SYSCALL_H__
  
  int sys_exit(int error_code);
  int sys_fork(void);
  int sys_wait(int pid, int *store);
  int sys_yield(void);
  int sys_kill(int pid);
  int sys_getpid(void);
  int sys_putc(int c);
  int sys_pgdir(void);
  
  #endif /* !__USER_LIBS_SYSCALL_H__ */
  ```

- user/libs/stdio.c：实现cprintf函数，通过系统调用sys_putc来完成字符输出。

  ```
  #include <defs.h>
  #include <stdio.h>
  #include <syscall.h>
  
  /* *
   * cputch - writes a single character @c to stdout, and it will
   * increace the value of counter pointed by @cnt.
   * */
  static void
  cputch(int c, int *cnt) {
      sys_putc(c);
      (*cnt) ++;
  }
  
  /* *
   * vcprintf - format a string and writes it to stdout
   *
   * The return value is the number of characters which would be
   * written to stdout.
   *
   * Call this function if you are already dealing with a va_list.
   * Or you probably want cprintf() instead.
   * */
  int
  vcprintf(const char *fmt, va_list ap) {
      int cnt = 0;
      vprintfmt((void*)cputch, &cnt, fmt, ap);
      return cnt;
  }
  
  /* *
   * cprintf - formats a string and writes it to stdout
   *
   * The return value is the number of characters which would be
   * written to stdout.
   * */
  int
  cprintf(const char *fmt, ...) {
      va_list ap;
  
      va_start(ap, fmt);
      int cnt = vcprintf(fmt, ap);
      va_end(ap);
  
      return cnt;
  }
  
  /* *
   * cputs- writes the string pointed by @str to stdout and
   * appends a newline character.
   * */
  int
  cputs(const char *str) {
      int cnt = 0;
      char c;
      while ((c = *str ++) != '\0') {
          cputch(c, &cnt);
      }
      cputch('\n', &cnt);
      return cnt;
  }
  ```

- user/libs/panic.c：实现\_\_panic/\_\_warn函数，通过系统调用sys_exit完成用户进程退出。

  ```
  #include <defs.h>
  #include <stdarg.h>
  #include <stdio.h>
  #include <ulib.h>
  #include <error.h>
  
  void
  __panic(const char *file, int line, const char *fmt, ...) {
      // print the 'message'
      va_list ap;
      va_start(ap, fmt);
      cprintf("user panic at %s:%d:\n    ", file, line);
      vcprintf(fmt, ap);
      cprintf("\n");
      va_end(ap);
      exit(-E_PANIC);
  }
  
  void
  __warn(const char *file, int line, const char *fmt, ...) {
      va_list ap;
      va_start(ap, fmt);
      cprintf("user warning at %s:%d:\n    ", file, line);
      vcprintf(fmt, ap);
      cprintf("\n");
      va_end(ap);
  }
  ```

除了这些用户态库函数实现外，还有一些libs/\*.[ch]是操作系统内核和应用程序共用的函数实现。这些用户库函数其实在本质上与UNIX系统中的标准libc没有区别，只是实现得很简单，但hello应用程序的正确执行离不开这些库函数。

【注意】libs/\*.[ch]、user/libs/\*.[ch]、user/\*.[ch]的源码中没有任何特权指令。

在make的最后一步执行了一个ld命令，把hello应用程序的执行码obj/\_\_user\_hello.out连接在了ucore kernel的末尾。且ld命令会在kernel中会把\_\_user\_hello.out的位置和大小记录在全局变量\_binary\_obj\_\_\_user\_hello\_out\_start和\_binary\_obj\_\_\_user\_hello\_out\_size中，这样这个hello用户程序就能够和ucore内核一起被 bootloader 加载到内存里中，并且通过这两个全局变量定位hello用户程序执行码的起始位置和大小。而到了与文件系统相关的实验后，ucore会提供一个简单的文件系统，那时所有的用户程序就都不再用这种方法进行加载了，而可以用大家熟悉的文件方式进行加载了。

#### 2. 用户进程的虚拟地址空间

在tools/user.ld描述了用户程序的用户虚拟空间的执行入口虚拟地址：

```
SECTIONS {
    /* Load programs at this address: "." means the current address */
    . = 0x800020;
```

在tools/kernel.ld描述了操作系统的内核虚拟空间的起始入口虚拟地址：

```
SECTIONS {
    /* Load the kernel at this address: "." means the current address */
    . = 0xC0100000;
```

这样ucore把用户进程的虚拟地址空间分了两块，一块与内核线程一样，是所有用户进程都共享的内核虚拟地址空间，映射到同样的物理内存空间中，这样在物理内存中只需放置一份内核代码，使得用户进程从用户态进入核心态时，内核代码可以统一应对不同的内核程序；另外一块是用户虚拟地址空间，虽然虚拟地址范围一样，但映射到不同且没有交集的物理内存空间中。这样当ucore把用户进程的执行代码（即应用程序的执行代码）和数据（即应用程序的全局变量等）放到用户虚拟地址空间中时，确保了各个进程不会“非法”访问到其他进程的物理内存空间。

这样ucore给一个用户进程具体设定的虚拟内存空间（kern/mm/memlayout.h）如下所示：

```
*
Virtual memory map:                                          Permissions
                                                             kernel/user
                                                             
    4G ------------------> +---------------------------------+
                           |                                 |
                           |         Empty Memory (*)        |
                           |                                 |
                           +---------------------------------+ 0xFB000000
                           |   Cur. Page Table (Kern, RW)    | RW/-- PTSIZE
    VPT -----------------> +---------------------------------+ 0xFAC00000
                           |        Invalid Memory (*)       | --/--
    KERNTOP -------------> +---------------------------------+ 0xF8000000
                           |                                 |
                           |    Remapped Physical Memory     | RW/-- KMEMSIZE
                           |                                 |
    KERNBASE ------------> +---------------------------------+ 0xC0000000
                           |        Invalid Memory (*)       | --/--
    USERTOP -------------> +---------------------------------+ 0xB0000000
                           |           User stack            |
                           +---------------------------------+
                           |                                 |
                           :                                 :
                           |         ~~~~~~~~~~~~~~~~        |
                           :                                 :
                           |                                 |
                           ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                           |       User Program & Heap       |
    UTEXT ---------------> +---------------------------------+ 0x00800000
                           |        Invalid Memory (*)       | --/--
                           |  - - - - - - - - - - - - - - -  |
                           |    User STAB Data (optional)    |
    USERBASE, USTAB------> +---------------------------------+ 0x00200000
                           |        Invalid Memory (*)       | --/--
    0 -------------------> +---------------------------------+ 0x00000000
    
(*) Note: The kernel ensures that "Invalid Memory" is *never* mapped.
    "Empty Memory" is normally unmapped, but user programs may map pages
    there if desired.

```

#### 3. 创建并执行用户进程

在确定了用户进程的执行代码和数据，以及用户进程的虚拟空间布局后，我们可以来创建用户进程了。在本实验中第一个用户进程是由第二个内核线程initproc通过把hello应用程序执行码覆盖到initproc的用户虚拟内存空间来创建的，相关代码如下所示：

```
static int
kernel_execve(const char *name, unsigned char *binary, size_t size) {
    int ret, len = strlen(name);
    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL), "0" (SYS_exec), "d" (name), "c" (len), "b" (binary), "D" (size)
        : "memory");
    return ret;
}

#define __KERNEL_EXECVE(name, binary, size) ({                          \
            cprintf("kernel_execve: pid = %d, name = \"%s\".\n",        \
                    current->pid, name);                                \
            kernel_execve(name, binary, (size_t)(size));                \
        })

#define KERNEL_EXECVE(x) ({                                             \
            extern unsigned char _binary_obj___user_##x##_out_start[],  \
                _binary_obj___user_##x##_out_size[];                    \
            __KERNEL_EXECVE(#x, _binary_obj___user_##x##_out_start,     \
                            _binary_obj___user_##x##_out_size);         \
        })

#define __KERNEL_EXECVE2(x, xstart, xsize) ({                           \
            extern unsigned char xstart[], xsize[];                     \
            __KERNEL_EXECVE(#x, xstart, (size_t)xsize);                 \
        })

#define KERNEL_EXECVE2(x, xstart, xsize)        __KERNEL_EXECVE2(x, xstart, xsize)

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
    size_t nr_free_pages_store = nr_free_pages();
    size_t kernel_allocated_store = kallocated();

    int pid = kernel_thread(user_main, NULL, 0);
    if (pid <= 0) {
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
    }

    cprintf("all user-mode processes have quit.\n");
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
    assert(nr_process == 2);
    assert(list_next(&proc_list) == &(initproc->list_link));
    assert(list_prev(&proc_list) == &(initproc->list_link));

    cprintf("init check memory pass.\n");
    return 0;
}
```

对于上述代码，我们需要从后向前按照函数/宏的实现一个一个来分析。Initproc的执行主体是init\_main函数，这个函数在缺省情况下是执行宏KERNEL_EXECVE(hello)，而这个宏最终是调用kernel\_execve函数来调用SYS_exec系统调用，由于ld在链接hello应用程序执行码时定义了两全局变量：

- \_binary\_obj\_\_\_user\_hello\_out\_start：hello执行码的起始位置
- \_binary\_obj\_\_\_user\_hello\_out\_size中：hello执行码的大小

kernel_execve把这两个变量作为SYS_exec系统调用的参数，让ucore来创建此用户进程。当ucore收到此系统调用后，将依次调用如下函数：

```
vector128(vectors.S) --> __alltraps(trapentry.S) --> trap(trap.c) --> trap_dispatch(trap.c)-->
syscall(syscall.c) --> sys_exec(syscall.c) --> do_execve(proc.c)
```

具体跟踪一下流程：

1. ```
   .globl vector128
   vector128:
     pushl $0
     pushl $128
     jmp __alltraps
   ```

   **压入两个值128和0然后跳到执行__alltraps，128代表系统调用**

2. ```
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
   ```

   **设置中断帧，然后更新ds和es为内核的ds和es，把esp压栈作为trap的参数，然后调用trap**

3. ```
   static void
   trap_dispatch(struct trapframe *tf) {
       char c;
   
       int ret=0;
   
       switch (tf->tf_trapno) {
       case T_PGFLT:  //page fault
           if ((ret = pgfault_handler(tf)) != 0) {
               print_trapframe(tf);
               if (current == NULL) {
                   panic("handle pgfault failed. ret=%d\n", ret);
               }
               else {
                   if (trap_in_kernel(tf)) {
                       panic("handle pgfault failed in kernel mode. ret=%d\n", ret);
                   }
                   cprintf("killed by kernel.\n");
                   panic("handle user mode pgfault failed. ret=%d\n", ret); 
                   do_exit(-E_KILLED);
               }
           }
           break;
       case T_SYSCALL:
           syscall();
           break;
           
           .....................................
           
   }
   ```

   **发现是系统调用转去调用syscall**

4. ```
   void
   syscall(void) {
       struct trapframe *tf = current->tf;
       uint32_t arg[5];
       int num = tf->tf_regs.reg_eax;
       if (num >= 0 && num < NUM_SYSCALLS) {
           if (syscalls[num] != NULL) {
               arg[0] = tf->tf_regs.reg_edx;
               arg[1] = tf->tf_regs.reg_ecx;
               arg[2] = tf->tf_regs.reg_ebx;
               arg[3] = tf->tf_regs.reg_edi;
               arg[4] = tf->tf_regs.reg_esi;
               tf->tf_regs.reg_eax = syscalls[num](arg);
               return ;
           }
       }
       print_trapframe(tf);
       panic("undefined syscall %d, pid = %d, name = %s.\n",
               num, current->pid, current->name);
   }
   ```

   **更新中断帧为current指向的线程的中断帧，并且把中断帧中断edx，ecx，ebx，edi，esi，作为参数，这里因为num是3所以之后调用sys\_exec**

5. ```
   static int
   sys_exec(uint32_t arg[]) {
       const char *name = (const char *)arg[0];
       size_t len = (size_t)arg[1];
       unsigned char *binary = (unsigned char *)arg[2];
       size_t size = (size_t)arg[3];
       return do_execve(name, len, binary, size);
   }
   ```

   **设置name，len，binary，size几个变量然后调用do\_execve**

6. ```
   int
   do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
       struct mm_struct *mm = current->mm;
       if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
           return -E_INVAL;
       }
       if (len > PROC_NAME_LEN) {
           len = PROC_NAME_LEN;
       }
   
       char local_name[PROC_NAME_LEN + 1];
       memset(local_name, 0, sizeof(local_name));
       memcpy(local_name, name, len);
   
       if (mm != NULL) {
           lcr3(boot_cr3);
           if (mm_count_dec(mm) == 0) {
               exit_mmap(mm);
               put_pgdir(mm);
               mm_destroy(mm);
           }
           current->mm = NULL;
       }
       int ret;
       if ((ret = load_icode(binary, size)) != 0) {
           goto execve_exit;
       }
       set_proc_name(current, local_name);
       return 0;
   
   execve_exit:
       do_exit(ret);
       panic("already exit: %e.\n", ret);
   }
   ```

   **最终通过do\_execve函数来完成用户进程的创建工作。此函数的主要工作流程如下：**

   - **首先为加载新的执行码做好用户态内存空间清空准备。如果mm不为NULL，则设置页表为内核空间页表，且进一步判断mm的引用计数减1后是否为0，如果为0，则表明没有进程再需要此进程所占用的内存空间，为此将根据mm中的记录，释放进程所占用户空间内存和进程页表本身所占空间。最后把当前进程的mm内存管理指针为空。由于此处的initproc是内核线程，所以mm为NULL，整个处理都不会做。**
   - **接下来的一步是加载应用程序执行码到当前进程的新创建的用户态虚拟空间中。这里涉及到读ELF格式的文件，申请内存空间，建立用户态虚存空间，加载应用程序执行码等。load\_icode函数完成了整个复杂的工作。**

   **load_icode函数的主要工作就是给用户进程建立一个能够让用户进程正常运行的用户环境。此函数有一百多行，完成了如下重要工作：**

   ```
   static int
   load_icode(unsigned char *binary, size_t size) {
       if (current->mm != NULL) {
           panic("load_icode: current->mm must be empty.\n");
       }
   
       int ret = -E_NO_MEM;
       struct mm_struct *mm;
       //(1) create a new mm for current process
       if ((mm = mm_create()) == NULL) {
           goto bad_mm;
       }
       //(2) create a new PDT, and mm->pgdir= kernel virtual addr of PDT
       if (setup_pgdir(mm) != 0) {
           goto bad_pgdir_cleanup_mm;
       }
       //(3) copy TEXT/DATA section, build BSS parts in binary to memory space of process
       struct Page *page;
       //(3.1) get the file header of the bianry program (ELF format)
       struct elfhdr *elf = (struct elfhdr *)binary;
       //(3.2) get the entry of the program section headers of the bianry program (ELF format)
       struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
       //(3.3) This program is valid?
       if (elf->e_magic != ELF_MAGIC) {
           ret = -E_INVAL_ELF;
           goto bad_elf_cleanup_pgdir;
       }
   
       uint32_t vm_flags, perm;
       struct proghdr *ph_end = ph + elf->e_phnum;
       for (; ph < ph_end; ph ++) {
       //(3.4) find every program section headers
           if (ph->p_type != ELF_PT_LOAD) {
               continue ;
           }
           if (ph->p_filesz > ph->p_memsz) {
               ret = -E_INVAL_ELF;
               goto bad_cleanup_mmap;
           }
           if (ph->p_filesz == 0) {
               continue ;
           }
       //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
           vm_flags = 0, perm = PTE_U;
           if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
           if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
           if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
           if (vm_flags & VM_WRITE) perm |= PTE_W;
           if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
               goto bad_cleanup_mmap;
           }
           unsigned char *from = binary + ph->p_offset;
           size_t off, size;
           uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
   
           ret = -E_NO_MEM;
   
        //(3.6) alloc memory, and  copy the contents of every program section (from, from+end) to process's memory (la, la+end)
           end = ph->p_va + ph->p_filesz;
        //(3.6.1) copy TEXT/DATA section of bianry program
           while (start < end) {
               if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                   goto bad_cleanup_mmap;
               }
               off = start - la, size = PGSIZE - off, la += PGSIZE;
               if (end < la) {
                   size -= la - end;
               }
               memcpy(page2kva(page) + off, from, size);
               start += size, from += size;
           }
   
         //(3.6.2) build BSS section of binary program
           end = ph->p_va + ph->p_memsz;
           if (start < la) {
               /* ph->p_memsz == ph->p_filesz */
               if (start == end) {
                   continue ;
               }
               off = start + PGSIZE - la, size = PGSIZE - off;
               if (end < la) {
                   size -= la - end;
               }
               memset(page2kva(page) + off, 0, size);
               start += size;
               assert((end < la && start == end) || (end >= la && start == la));
           }
           while (start < end) {
               if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                   goto bad_cleanup_mmap;
               }
               off = start - la, size = PGSIZE - off, la += PGSIZE;
               if (end < la) {
                   size -= la - end;
               }
               memset(page2kva(page) + off, 0, size);
               start += size;
           }
       }
       //(4) build user stack memory
       vm_flags = VM_READ | VM_WRITE | VM_STACK;
       if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
           goto bad_cleanup_mmap;
       }
       assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
       assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
       assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
       assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
       
       //(5) set current process's mm, sr3, and set CR3 reg = physical addr of Page Directory
       mm_count_inc(mm);
       current->mm = mm;
       current->cr3 = PADDR(mm->pgdir);
       lcr3(PADDR(mm->pgdir));
   
       //(6) setup trapframe for user environment
       struct trapframe *tf = current->tf;
       memset(tf, 0, sizeof(struct trapframe));
       /* LAB5:EXERCISE1 YOUR CODE
        * should set tf_cs,tf_ds,tf_es,tf_ss,tf_esp,tf_eip,tf_eflags
        * NOTICE: If we set trapframe correctly, then the user level process can return to USER MODE from kernel. So
        *          tf_cs should be USER_CS segment (see memlayout.h)
        *          tf_ds=tf_es=tf_ss should be USER_DS segment
        *          tf_esp should be the top addr of user stack (USTACKTOP)
        *          tf_eip should be the entry point of this binary program (elf->e_entry)
        *          tf_eflags should be set to enable computer to produce Interrupt
        */
       tf->tf_cs =  USER_CS;
       tf->tf_ds = tf->tf_es = tf->tf_ss = USER_DS;
       tf->tf_esp = USTACKTOP;
       tf->tf_eip = elf->e_entry;
       tf->tf_eflags = 0x00000002 | FL_IF;
       ret = 0;
   out:
       return ret;
   bad_cleanup_mmap:
       exit_mmap(mm);
   bad_elf_cleanup_pgdir:
       put_pgdir(mm);
   bad_pgdir_cleanup_mm:
       mm_destroy(mm);
   bad_mm:
       goto out;
   }
   ```

   1. 10-12行，调用mm_create函数来申请进程的内存管理数据结构mm所需内存空间，并对mm进行初始化，mm_create函数代码如下，3行为申请内存，5-13就是初始化mm：

      ```
      struct mm_struct *
      mm_create(void) {
          struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
      
          if (mm != NULL) {
              list_init(&(mm->mmap_list));
              mm->mmap_cache = NULL;
              mm->pgdir = NULL;
              mm->map_count = 0;
      
              if (swap_init_ok) swap_init_mm(mm);
              else mm->sm_priv = NULL;
          }
          return mm;
      }
      ```

   2. 14-16行，调用setup\_pgdir来申请一个页目录表所需的一个页大小的内存空间，并把描述ucore内核虚空间映射的内核页表（boot_pgdir所指）的内容拷贝到此新目录表中，最后让mm->pgdir指向此页目录表，这就是进程新的页目录表了，且能够正确映射内核虚空间，setup_pgdir代码如下，4-6行，申请空间，8行拷贝描述ucore内核需空间映射的内核页表的内容到此新目录也中，9行更新属性，10行让mm->pgdir指向这个页目录表：

      ```
      static int
      setup_pgdir(struct mm_struct *mm) {
          struct Page *page;
          if ((page = alloc_page()) == NULL) {
              return -E_NO_MEM;
          }
          pde_t *pgdir = page2kva(page);
          memcpy(pgdir, boot_pgdir, PGSIZE);
          pgdir[PDX(VPT)] = PADDR(pgdir) | PTE_P | PTE_W;
          mm->pgdir = pgdir;
          return 0;
      }
      ```

   3. 18-54行，根据应用程序执行码的起始位置来解析此ELF格式的执行程序，并调用mm_map函数根据ELF格式的执行程序说明的各个段（代码段、数据段、BSS段等）的起始位置和大小建立对应的vma结构，并把vma插入到mm结构中，从而表明了用户进程的合法用户态虚拟地址空间。具体就是这段代码，前5行是根据elf结构获取到了程序头节表（记录各个段的起始位置），然后7-9行检测这是不是有效的elf文件，之后就是开始获取各个段的头获取到头之后根据elf格式来检测是否符合要求符合的话就开始利用mm_map函数来给各个段建立对应的vma结构，这些操作对应着12-37行，注意这里代码还有结束后面还有一部分：

      ```
      	struct Page *page;
          //(3.1) get the file header of the bianry program (ELF format)
          struct elfhdr *elf = (struct elfhdr *)binary;
          //(3.2) get the entry of the program section headers of the bianry program (ELF format)
          struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
          //(3.3) This program is valid?
          if (elf->e_magic != ELF_MAGIC) {
              ret = -E_INVAL_ELF;
              goto bad_elf_cleanup_pgdir;
          }
      
          uint32_t vm_flags, perm;
          struct proghdr *ph_end = ph + elf->e_phnum;
          for (; ph < ph_end; ph ++) {
          //(3.4) find every program section headers
              if (ph->p_type != ELF_PT_LOAD) {
                  continue ;
              }
              if (ph->p_filesz > ph->p_memsz) {
                  ret = -E_INVAL_ELF;
                  goto bad_cleanup_mmap;
              }
              if (ph->p_filesz == 0) {
                  continue ;
              }
          //(3.5) call mm_map fun to setup the new vma ( ph->p_va, ph->p_memsz)
              vm_flags = 0, perm = PTE_U;
              if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
              if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
              if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
              if (vm_flags & VM_WRITE) perm |= PTE_W;
              if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
                  goto bad_cleanup_mmap;
              }
              unsigned char *from = binary + ph->p_offset;
              size_t off, size;
              uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
      ```

   4. 56-99行，调用根据执行程序各个段的大小分配物理内存空间，并根据执行程序各个段的起始位置确定虚拟地址，并在页表中建立好物理地址和虚拟地址的映射关系，然后把执行程序各个段的内容拷贝到相应的内核虚拟地址中，至此应用程序执行码和数据已经根据编译时设定地址放置到虚拟内存中了，具体代码如下，其中3-43都是在做拷贝各个段的内容到相应的内核虚拟地址中去：

      ```
      	接上段代码。。。。。。
      	
      	end = ph->p_va + ph->p_filesz;
           //(3.6.1) copy TEXT/DATA section of bianry program
              while (start < end) {
                  if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                      goto bad_cleanup_mmap;
                  }
                  off = start - la, size = PGSIZE - off, la += PGSIZE;
                  if (end < la) {
                      size -= la - end;
                  }
                  memcpy(page2kva(page) + off, from, size);
                  start += size, from += size;
              }
      
            //(3.6.2) build BSS section of binary program
              end = ph->p_va + ph->p_memsz;
              if (start < la) {
                  /* ph->p_memsz == ph->p_filesz */
                  if (start == end) {
                      continue ;
                  }
                  off = start + PGSIZE - la, size = PGSIZE - off;
                  if (end < la) {
                      size -= la - end;
                  }
                  memset(page2kva(page) + off, 0, size);
                  start += size;
                  assert((end < la && start == end) || (end >= la && start == la));
              }
              while (start < end) {
                  if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
                      goto bad_cleanup_mmap;
                  }
                  off = start - la, size = PGSIZE - off, la += PGSIZE;
                  if (end < la) {
                      size -= la - end;
                  }
                  memset(page2kva(page) + off, 0, size);
                  start += size;
              }
          }
      ```

   5. 101-108行，需要给用户进程设置用户栈，为此调用mm_mmap函数建立用户栈的vma结构，明确用户栈的位置在用户虚空间的顶端，大小为256个页，即1MB，并分配一定数量的物理内存且建立好栈的虚地址<-->物理地址映射关系，这个就是就是很简单的调用mm_mmap，mm_mmap有4个参数，第一个对应着mm，第二个对应着栈顶，第三个对应着栈空间大小，第四个对应着虚空间的属性，最后有一个参数为null

   6. 111-114行，至此,进程内的内存管理vma和mm数据结构已经建立完成，于是把mm->pgdir赋值到cr3寄存器中，即更新了用户进程的虚拟内存空间，此时的initproc已经被hello的代码和数据覆盖，成为了第一个用户进程，但此时这个用户进程的执行现场还没建立好；

   7. 117-133行，先清空进程的中断帧，再重新设置进程的中断帧，使得在执行中断返回指令“iret”后，能够让CPU转到用户态特权级，并回到用户态内存空间，使用用户态的代码段、数据段和堆栈，且能够跳转到用户进程的第一条指令执行，并确保在用户态能够响应中断，这里也就对应着练习1的内容；

   **至此，用户进程的用户环境已经搭建完毕。此时initproc将按产生系统调用的函数调用路径原路返回，执行中断返回指令“iret”（位于trapentry.S的最后一句）后，将切换到用户进程hello的第一条语句位置_start处（位于user/libs/initcode.S的第三句）开始执行。**

   ### 进程退出和等待进程

   当进程执行完它的工作后，就需要执行退出操作，释放进程占用的资源。ucore分了两步来完成这个工作，首先由进程本身完成大部分资源的占用内存回收工作，然后由此进程的父进程完成剩余资源占用内存的回收工作。为何不让进程本身完成所有的资源回收工作呢？这是因为进程要执行回收操作，就表明此进程还存在，还在执行指令，这就需要内核栈的空间不能释放，且表示进程存在的进程控制块不能释放。所以需要父进程来帮忙释放子进程无法完成的这两个资源回收工作。

   为此在用户态的函数库中提供了exit函数，此函数最终访问sys_exit系统调用接口让操作系统来帮助当前进程执行退出过程中的部分资源回收。我们来看看ucore是如何做进程退出工作的。

   首先，exit函数会把一个退出码error_code传递给ucore，ucore通过执行内核函数do_exit来完成对当前进程的退出处理，主要工作简单地说就是回收当前进程所占的大部分内存资源，并通知父进程完成最后的回收工作，具体流程和代码如下：

   ```
   int
   do_exit(int error_code) {
       if (current == idleproc) {
           panic("idleproc exit.\n");
       }
       if (current == initproc) {
           panic("initproc exit.\n");
       }
       
       struct mm_struct *mm = current->mm;
       if (mm != NULL) {
           lcr3(boot_cr3);
           if (mm_count_dec(mm) == 0) {
               exit_mmap(mm);
               put_pgdir(mm);
               mm_destroy(mm);
           }
           current->mm = NULL;
       }
       current->state = PROC_ZOMBIE;
       current->exit_code = error_code;
       
       bool intr_flag;
       struct proc_struct *proc;
       local_intr_save(intr_flag);
       {
           proc = current->parent;
           if (proc->wait_state == WT_CHILD) {
               wakeup_proc(proc);
           }
           while (current->cptr != NULL) {
               proc = current->cptr;
               current->cptr = proc->optr;
       
               proc->yptr = NULL;
               if ((proc->optr = initproc->cptr) != NULL) {
                   initproc->cptr->yptr = proc;
               }
               proc->parent = initproc;
               initproc->cptr = proc;
               if (proc->state == PROC_ZOMBIE) {
                   if (initproc->wait_state == WT_CHILD) {
                       wakeup_proc(initproc);
                   }
               }
           }
       }
       local_intr_restore(intr_flag);
       
       schedule();
       panic("do_exit will not return!! %d.\n", current->pid);
   }
   ```

   1. 10-19行，如果current->mm != NULL，表示是用户进程，则开始回收此用户进程所占用的用户态虚拟内存空间；

      - 首先执行“lcr3(boot_cr3)”，切换到内核态的页表上，这样当前用户进程目前只能在内核虚拟地址空间执行了，这是为了确保后续释放用户态内存和进程页表的工作能够正常执行；

      - 如果当前进程控制块的成员变量mm的成员变量mm_count减1后为0（调用的是mm_count_dec函数表明这个mm没有再被其他进程共享，可以彻底释放进程所占的用户虚拟空间了。），则开始回收用户进程所占的内存资源，mm_count_dec函数代码如下：

        ```
        static inline int
        mm_count_dec(struct mm_struct *mm) {
            mm->mm_count -= 1;
            return mm->mm_count;
        }
        ```

        - 调用exit_mmap函数释放current->mm->vma链表中每个vma描述的进程合法空间中实际分配的内存，然后把对应的页表项内容清空，最后还把页表所占用的空间释放并把对应的页目录表项清空；exit_mmap代码如下：

          ```
          void
          exit_mmap(struct mm_struct *mm) {
              assert(mm != NULL && mm_count(mm) == 0);
              pde_t *pgdir = mm->pgdir;
              list_entry_t *list = &(mm->mmap_list), *le = list;
              while ((le = list_next(le)) != list) {
                  struct vma_struct *vma = le2vma(le, list_link);
                  unmap_range(pgdir, vma->vm_start, vma->vm_end);
              }
              while ((le = list_next(le)) != list) {
                  struct vma_struct *vma = le2vma(le, list_link);
                  exit_range(pgdir, vma->vm_start, vma->vm_end);
              }
          }
          ```

        - 调用put_pgdir函数释放当前进程的页目录所占的内存；put_pgdir代码如下：

          ```
          static void
          put_pgdir(struct mm_struct *mm) {
              free_page(kva2page(mm->pgdir));
          }
          ```

        - 调用mm_destroy函数释放mm中的vma所占内存，最后释放mm所占内存；mm_destory代码如下：

          ```
          void
          mm_destroy(struct mm_struct *mm) {
          
              list_entry_t *list = &(mm->mmap_list), *le;
              while ((le = list_next(list)) != list) {
                  list_del(le);
                  kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
              }
              kfree(mm, sizeof(struct mm_struct)); //kfree mm
              mm=NULL;
          }
          ```

   2. 20-21行，这时，设置当前进程的执行状态current->state=PROC_ZOMBIE，当前进程的退出码current->exit_code=error_code。此时当前进程已经不能被调度了，需要此进程的父进程来做最后的回收工作（即回收描述此进程的内核栈和进程控制块）；

   3. 27-30行，如果当前进程的父进程current->parent处于等待子进程状态：

      `current->parent->wait_state==WT_CHILD`，

      则唤醒父进程（即执行“wakeup_proc(current->parent)”），让父进程帮助自己完成最后的资源回收；wakeup_proc代码如下：

      ```
      void
      wakeup_proc(struct proc_struct *proc) {
          assert(proc->state != PROC_ZOMBIE && proc->state != PROC_RUNNABLE);
          proc->state = PROC_RUNNABLE;
      }
      ```

   4. 31-46行，如果当前进程还有子进程，则需要把这些子进程的父进程指针设置为内核线程initproc，且各个子进程指针需要插入到initproc的子进程链表中。如果某个子进程的执行状态是PROC_ZOMBIE，则需要唤醒initproc来完成对此子进程的最后回收工作。

   5. 50行执行schedule()函数，选择新的进程执行。

那么父进程如何完成对子进程的最后回收工作呢？这要求父进程要执行wait用户函数或wait_pid用户函数，这两个函数的区别是，wait函数等待任意子进程的结束通知，而wait_pid函数等待进程id号为pid的子进程结束通知。这两个函数最终访问sys_wait系统调用接口让ucore来完成对子进程的最后回收工作，即回收子进程的内核栈和进程控制块所占内存空间，具体流程和代码如下：

```
int
do_wait(int pid, int *code_store) {
    struct mm_struct *mm = current->mm;
    if (code_store != NULL) {
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
            return -E_INVAL;
        }
    }

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0) {
        proc = find_proc(pid);
        if (proc != NULL && proc->parent == current) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    else {
        proc = current->cptr;
        for (; proc != NULL; proc = proc->optr) {
            haskid = 1;
            if (proc->state == PROC_ZOMBIE) {
                goto found;
            }
        }
    }
    if (haskid) {
        current->state = PROC_SLEEPING;
        current->wait_state = WT_CHILD;
        schedule();
        if (current->flags & PF_EXITING) {
            do_exit(-E_KILLED);
        }
        goto repeat;
    }
    return -E_BAD_PROC;

found:
    if (proc == idleproc || proc == initproc) {
        panic("wait idleproc or initproc.\n");
    }
    if (code_store != NULL) {
        *code_store = proc->exit_code;
    }
    local_intr_save(intr_flag);
    {
        unhash_proc(proc);
        remove_links(proc);
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
```

1. 14-15行，如果pid!=0，表示只找一个进程id号为pid的退出状态的子进程，否则找任意一个处于退出状态的子进程；
2. 16-35行，如果此子进程的执行状态不为PROC_ZOMBIE，表明此子进程还没有退出，则当前进程只好设置自己的执行状态为PROC_SLEEPING，睡眠原因为WT_CHILD（即等待子进程退出），调用schedule()函数选择新的进程执行，自己睡眠等待，如果被唤醒，则重复跳回步骤1处执行；
3.  43-59行以及16-35行中成功goto的语句，如果此子进程的执行状态为PROC_ZOMBIE，表明此子进程处于退出状态，需要当前进程（即子进程的父进程）完成对子进程的最终回收工作，即首先把子进程控制块从两个进程队列proc_list和hash_list中删除，并释放子进程的内核堆栈和进程控制块。自此，子进程才彻底地结束了它的执行过程，消除了它所占用的所有资源。

### 系统调用实现

#### 1. 初始化系统调用对应的中断描述符

在ucore初始化函数kern_init中调用了idt_init函数来初始化中断描述符表，并设置一个特定中断号的中断门，专门用于用户进程访问系统调用。此事由ide_init函数完成：

```
void
idt_init(void) {
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
    }
    SETGATE(idt[T_SYSCALL], 1, GD_KTEXT, __vectors[T_SYSCALL], DPL_USER);
    lidt(&idt_pd);
}
```

在上述代码中，可以看到在执行加载中断描述符表lidt指令前，专门设置了一个特殊的中断描述符idt[T_SYSCALL]，它的特权级设置为DPL_USER，中断向量处理地址在\_\_vectors[T_SYSCALL]处。这样建立好这个中断描述符后，一旦用户进程执行“INT T_SYSCALL”后，由于此中断允许用户态进程产生（注意它的特权级设置为DPL_USER），所以CPU就会从用户态切换到内核态，保存相关寄存器，并跳转到__vectors[T_SYSCALL]处开始执行，形成如下执行路径：

```
vector128(vectors.S) --> __alltraps(trapentry.S) --> trap(trap.c) --> trap_dispatch(trap.c) --> syscall(syscall.c)
```

在syscall中，根据系统调用号来完成不同的系统调用服务,这里上面已经分析过了。

#### 2. 建立系统调用的用户库准备

在操作系统中初始化好系统调用相关的中断描述符、中断处理起始地址等后，还需在用户态的应用程序中初始化好相关工作，简化应用程序访问系统调用的复杂性。为此在用户态建立了一个中间层，即简化的libc实现，在user/libs/ulib.[ch]和user/libs/syscall.[ch]中完成了对访问系统调用的封装。用户态最终的访问系统调用函数是syscall，实现如下：

```
static inline int
syscall(int num, ...) {
    va_list ap;
    va_start(ap, num);
    uint32_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint32_t);
    }
    va_end(ap);

    asm volatile (
        "int %1;"
        : "=a" (ret)
        : "i" (T_SYSCALL),
          "a" (num),
          "d" (a[0]),
          "c" (a[1]),
          "b" (a[2]),
          "D" (a[3]),
          "S" (a[4])
        : "cc", "memory");
    return ret;
}
```

从中可以看出，应用程序调用的exit/fork/wait/getpid等库函数最终都会调用syscall函数，只是调用的参数不同而已，如果看最终的汇编代码会更清楚：

```
……
  34:    8b 55 d4               mov    -0x2c(%ebp),%edx
  37:    8b 4d d8               mov    -0x28(%ebp),%ecx
  3a:    8b 5d dc                mov    -0x24(%ebp),%ebx
  3d:    8b 7d e0                mov    -0x20(%ebp),%edi
  40:    8b 75 e4                mov    -0x1c(%ebp),%esi
  43:    8b 45 08               mov    0x8(%ebp),%eax
  46:    cd 80                   int    $0x80
48: 89 45 f0                mov    %eax,-0x10(%ebp)
……
```

可以看到其实是把系统调用号放到EAX，其他5个参数a[0]~a[4]分别保存到EDX/ECX/EBX/EDI/ESI五个寄存器中，及最多用6个寄存器来传递系统调用的参数，且系统调用的返回结果是EAX。比如对于getpid库函数而言，系统调用号（SYS_getpid=18）是保存在EAX中，返回值（调用此库函数的的当前进程号pid）也在EAX中。

#### 3. 与用户进程相关的系统调用

在本实验中，与进程相关的各个系统调用属性如下所示：

| 系统调用名 | 含义                                      | 具体完成服务的函数                                           |
| ---------- | ----------------------------------------- | ------------------------------------------------------------ |
| SYS_exit   | process exit                              | do_exit                                                      |
| SYS_fork   | create child process, dup mm              | do_fork-->wakeup_proc                                        |
| SYS_wait   | wait child process                        | do_wait                                                      |
| SYS_exec   | after fork, process execute a new program | load a program and refresh the mm                            |
| SYS_yield  | process flag itself need resecheduling    | proc->need_sched=1, then scheduler will rescheule this process |
| SYS_kill   | kill process                              | do_kill-->proc->flags \|= PF_EXITING, -->wakeup_proc-->do_wait-->do_exit |
| SYS_getpid | get the process's pid                     |                                                              |

通过这些系统调用，可方便地完成从进程/线程创建到退出的整个运行过程。

#### 4. 系统调用的执行过程

与用户态的函数库调用执行过程相比，系统调用执行过程的有四点主要的不同：

- 不是通过“CALL”指令而是通过“INT”指令发起调用；
- 不是通过“RET”指令，而是通过“IRET”指令完成调用返回；
- 当到达内核态后，操作系统需要严格检查系统调用传递的参数，确保不破坏整个系统的安全性；
- 执行系统调用可导致进程等待某事件发生，从而可引起进程切换；

下面我们以getpid系统调用的执行过程大致看看操作系统是如何完成整个执行过程的。当用户进程调用getpid函数，最终执行到“INT T_SYSCALL”指令后，CPU根据操作系统建立的系统调用中断描述符，转入内核态，并跳转到vector128处（kern/trap/vectors.S），开始了操作系统的系统调用执行过程，函数调用和返回操作的关系如下所示：

```
vector128(vectors.S) -->
__alltraps(trapentry.S) --> trap(trap.c) --> trap_dispatch(trap.c) --
--> syscall(syscall.c) --> sys_getpid(syscall.c) -->……--> __trapret(trapentry.S)
```

在执行trap函数前，软件还需进一步保存执行系统调用前的执行现场，即把与用户进程继续执行所需的相关寄存器等当前内容保存到当前进程的中断帧trapframe中（注意，在创建进程是，把进程的trapframe放在给进程的内核栈分配的空间的顶部）。软件做的工作在vector128和__alltraps的起始部分：

```
vectors.S::vector128起始处:
  pushl $0
  pushl $128
......
trapentry.S::__alltraps起始处:
pushl %ds
  pushl %es
  pushal
……
```

自此，用于保存用户态的用户进程执行现场的trapframe的内容填写完毕，操作系统可开始完成具体的系统调用服务。在sys_getpid函数中，简单地把当前进程的pid成员变量做为函数返回值就是一个具体的系统调用服务。完成服务后，操作系统按调用关系的路径原路返回到__alltraps中。然后操作系统开始根据当前进程的中断帧内容做恢复执行现场操作。其实就是把trapframe的一部分内容保存到寄存器内容。恢复寄存器内容结束后，调整内核堆栈指针到中断帧的tf_eip处，这是内核栈的结构如下：

```
/* below here defined by x86 hardware */
    uintptr_t tf_eip;
    uint16_t tf_cs;
    uint16_t tf_padding3;
    uint32_t tf_eflags;
/* below here only when crossing rings */
    uintptr_t tf_esp;
    uint16_t tf_ss;
    uint16_t tf_padding4;
```

这时执行“IRET”指令后，CPU根据内核栈的情况回复到用户态，并把EIP指向tf_eip的值，即“INT T_SYSCALL”后的那条指令。这样整个系统调用就执行完毕了。

这里就直接复制粘贴了，因为上面对于这些已经大致都分析过了

## 项目组成

```
├── boot  
├── kern   
│ ├── debug  
│ │ ├── kdebug.c   
│ │ └── ……  
│ ├── mm  
│ │ ├── memlayout.h   
│ │ ├── pmm.c  
│ │ ├── pmm.h  
│ │ ├── ......  
│ │ ├── vmm.c  
│ │ └── vmm.h  
│ ├── process  
│ │ ├── proc.c  
│ │ ├── proc.h  
│ │ └── ......  
│ ├── schedule  
│ │ ├── sched.c  
│ │ └── ......  
│ ├── sync  
│ │ └── sync.h   
│ ├── syscall  
│ │ ├── syscall.c  
│ │ └── syscall.h  
│ └── trap  
│ ├── trap.c  
│ ├── trapentry.S  
│ ├── trap.h  
│ └── vectors.S  
├── libs  
│ ├── elf.h  
│ ├── error.h  
│ ├── printfmt.c  
│ ├── unistd.h  
│ └── ......  
├── tools  
│ ├── user.ld  
│ └── ......  
└── user  
├── hello.c  
├── libs  
│ ├── initcode.S  
│ ├── syscall.c  
│ ├── syscall.h  
│ └── ......  
└── ......
```

相对与实验四，实验五主要增加的文件如上表红色部分所示，主要修改的文件如上表紫色部分所示。主要改动如下：

◆ kern/debug/

kdebug.c：修改：解析用户进程的符号信息表示（可不用理会）

◆ kern/mm/ （与本次实验有较大关系）

memlayout.h：修改：增加了用户虚存地址空间的图形表示和宏定义 （需仔细理解）。

pmm.[ch]：修改：添加了用于进程退出（do_exit）的内存资源回收的page_remove_pte、unmap_range、exit_range函数和用于创建子进程（do_fork）中拷贝父进程内存空间的copy_range函数，修改了pgdir_alloc_page函数

vmm.[ch]：修改：扩展了mm_struct数据结构，增加了一系列函数

- mm_map/dup_mmap/exit_mmap：设定/取消/复制/删除用户进程的合法内存空间
- copy_from_user/copy_to_user：用户内存空间内容与内核内存空间内容的相互拷贝的实现
- user_mem_check：搜索vma链表，检查是否是一个合法的用户空间范围

◆ kern/process/ （与本次实验有较大关系）

proc.[ch]：修改：扩展了proc_struct数据结构。增加或修改了一系列函数

- setup_pgdir/put_pgdir：创建并设置/释放页目录表
- copy_mm：复制用户进程的内存空间和设置相关内存管理（如页表等）信息
- do_exit：释放进程自身所占内存空间和相关内存管理（如页表等）信息所占空间，唤醒父进程，好让父进程收了自己，让调度器切换到其他进程
- load_icode：被do_execve调用，完成加载放在内存中的执行程序到进程空间，这涉及到对页表等的修改，分配用户栈
- do_execve：先回收自身所占用户空间，然后调用load_icode，用新的程序覆盖内存空间，形成一个执行新程序的新进程
- do_yield：让调度器执行一次选择新进程的过程
- do_wait：父进程等待子进程，并在得到子进程的退出消息后，彻底回收子进程所占的资源（比如子进程的内核栈和进程控制块）
- do_kill：给一个进程设置PF_EXITING标志（“kill”信息，即要它死掉），这样在trap函数中，将根据此标志，让进程退出
- KERNEL_EXECVE/__KERNEL_EXECVE/__KERNEL_EXECVE2：被user_main调用，执行一用户进程

◆ kern/trap/

trap.c：修改：在idt_init函数中，对IDT初始化时，设置好了用于系统调用的中断门（idt[T_SYSCALL]）信息。这主要与syscall的实现相关

◆ user/*

新增的用户程序和用户库