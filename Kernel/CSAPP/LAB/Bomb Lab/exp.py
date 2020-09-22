# -*- coding: utf-8 -*-
# @Author: resery
# @Date:   2020-07-22 15:49:06
# @Last Modified by:   resery
# @Last Modified time: 2020-07-22 19:20:15
from pwn import *
from LibcSearcher import LibcSearcher

#context.log_level="debug"

if sys.argv[1]=="debug":
	sh = process("./bomb")
elif sys.argv[1]=="remote":
	sh = remote("node3.buuoj.cn",)

elf = ELF("./bomb")

ru = lambda x:sh.recvuntil(x)
rv = lambda x:sh.recv(x)
ra = lambda x:sh.recvall(x)
sl = lambda x:sh.sendline(x)
sd = lambda x:sh.send(x) 
sla = lambda x,y:sh.sendlineafter(x,y)
lg = lambda x:log.success(x)

def dbg():
	gdb.attach(sh)

sh.recv();
sl("Border relations with Canada have never been better.")
sh.recv()
sl("1 2 4 8 16 32")
sh.recv()
sl("1 311")
sh.recv()
sl("7 0")
sh.recv()
sl("9ONEFG")
sh.recv()
sl("4 3 2 1 6 5")

sh.interactive()