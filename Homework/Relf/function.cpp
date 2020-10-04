#include <iostream>
#include <elf.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
using namespace std;

int main(int argc,char * argv[]) {
    int fd = open(argv[1],O_RDONLY,0);
    //设置文件偏移为文件长度(指向结尾)
    long int end = lseek(fd, 0, SEEK_END);
    //设置文件偏移为开头(为了能让read正常运行)
    long int begin = lseek(fd, 0, SEEK_SET);
    char* buf = (char *)malloc(end);
    read(fd, buf, end);

    //ELF头节表
    Elf64_Ehdr* header = (Elf64_Ehdr*)buf;
    //节名字符串表在节表中的下标
    Elf64_Half eshstrndx = header->e_shstrndx;
    //节头表
    Elf64_Shdr* section_header = (Elf64_Shdr*)(buf + header->e_shoff);
    //节名字符串表
    Elf64_Shdr* shstr = (Elf64_Shdr*)(section_header + eshstrndx);
    //存储节名字符串的节区内容
    char* shstrbuff = (char *)(buf + shstr->sh_offset);
    //存储函数的个数
    int num = 0;

    cout <<endl;
    //循环限制条件：e_shnum节区个数
    for(int i = 0;i<header->e_shnum;++i)
    {
        //sh_name是一个数字相当于一个索引，是节名字符串表中的索引，这里检验符号表
        if(!strcmp(section_header[i].sh_name + shstrbuff, ".symtab"))
        {
            //符号表的具体位置
            Elf64_Sym* symbol_table = (Elf64_Sym*)(buf + section_header[i].sh_offset);
            //根据节表大小和节表项大小计算出一共包含多少项
            int ncount = section_header[i].sh_size / section_header[i].sh_entsize;
            //Linux 中的 ELF 文件中该项指向符号表中符号所对应的字符串节区在 Section Header Table 中的偏移
            //也就是取该字符串节区的内容
            char* str_buf = (char*)((section_header + section_header[i].sh_link)->sh_offset + buf);

            for(int i = 0;i<ncount;++i)
            {
                //检验符号表的类型,这里 & 0xf,是根据elf.h文件得到的
                if(((symbol_table[i].st_info) & 0xf)==STT_FUNC)
                {
                    //st_name相当于字符串节区的索引
                    //这里就是取相应的函数名
                    cout << "function" << num+1 << ":\t" << symbol_table[i].st_name + str_buf <<endl;
                    num++;
                }
            }
            cout << "\n" << "There are " << num << " functions in total" << endl;
        }
    }
}
