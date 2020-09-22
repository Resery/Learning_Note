# Unix Note Ⅰ

**环境配置**

这个环境配置很简单，git clone下来之后，进入到apue.c，执行以下make就可以了，不过make可能会报错，如果报错了就需要执行下面的第一条命令，但后把编译好的头文件和.a文件复制到全局目录下就可以了

```
git clone https://github.com/MeiK2333/apue.git
sudo apt-get install libbsd-dev
cd apue.3e
make
......

sudo cp ./include/apue.h /usr/include/
sudo cp ./lib/libapue.a /usr/local/lib/
```

**登陆项的组成**

```
root  :x      :0        :0       :root   :/root  :/usr/bin/zsh
登录名  加密口令 数字用户ID  数字组ID  注释字段 起始目录  shell程序
```

**列出一个目录下的文件和子目录**

```
#include "apue.h"

#include <dirent.h>

int main(int argc, char *argv[]) {
    DIR *dp;
    struct dirent *dirp;

    if (argc != 2)
        err_quit("usage: ls directory_name");

    if ((dp = opendir(argv[1])) == NULL)
        err_sys("can't open %s", argv[1]);
    while ((dirp = readdir(dp)) != NULL)
        printf("%s\n", dirp->d_name);
    closedir(dp);
    exit(0);
}
```

这个代码很好理解，只是需要再说明一下几个函数

1. err_quit函数：直接退出，并且打印参数里面的字符串
2. err_sys函数：这个会个根据错误类型来告诉你这是什么错误
3. opendir函数：返回一个DIR结构的指针
4. readdir函数：返回一个dirent结构的指针
5. closedir函数：关闭这个目录，其实更具体的接就是free掉dir结构，然后清空指针

**标准输入读，标准输出写**

```
#------------------------------------------------------------------
# read write 版本
#include "apue.h"

#define BUFFSIZE 4096

int main(int argc, char *argv[]) {
    int n;
    char buf[BUFFSIZE];

    while ((n = read(STDIN_FILENO, buf, BUFFSIZE)) > 0)
        if (write(STDOUT_FILENO, buf, n) != n)
            err_sys("write error");

    if (n < 0)
        err_sys("read error");
    exit(0);
}

#------------------------------------------------------------------
# getc putc 版本
#include "apue.h"

int main(int argc, char *argv[]) {
    int c;
    while ((c = getc(stdin)) != EOF)
        if (putc(c, stdout) == EOF)
            err_sys("output error");

    if (ferror(stdin))
        err_sys("input error");
    exit(0);
}
```

1. STDIN_FILENO：标准输入读文件对应的文件描述符是0，只是为了好识别所以定了这个宏来代表标准输入读
2. STDOUT_FILENO：标准输出写文件对应的文件描述符是1，只是为了好识别所以定了这个宏来代表标准输出写
3. read：返回读的字节数量，如果发生读错误read返回-1

**输出进程ID**

```
#include "apue.h"

int main(int argc, char *argv[]) {
    printf("hello world from process ID %ld\n", (long)getpid());
    exit(0);
}
```

1. getpid：返回进程ID号

**从标准输入读命令，然后执行命令**

```
#include "apue.h"

#include <sys/wait.h>

int main(int argc, char *argv[]) {
    char buf[MAXLINE];  // apue.h 中定义 #define	MAXLINE	4096
    pid_t pid;
    int status;

    printf("%% ");
    while (fgets(buf, MAXLINE, stdin) != NULL) {
        if (buf[strlen(buf) - 1] == '\n')
            buf[strlen(buf) - 1] = 0;

        if ((pid = fork()) < 0) {
            err_sys("fork error");
        } else if (pid == 0) {
            execlp(buf, buf, (char *) 0);
            err_ret("couldn't execute: %s", buf);
            exit(127);
        }

        if ((pid = waitpid(pid, &status, 0)) < 0)
            err_sys("waitpid error");
        printf("%% ");
    }
    exit(0);
}
```

1. fgets：从标准输入读数据写到buf里面，一直读到换行
2. fork：创建子进程
3. waitpid：等待进程退出
4. execlp：执行标准输入读入的命令，只是这个函数也就是加载可执行程序的命令

**出错处理**

```
#include "apue.h"

#include <errno.h>

int main(int argc, char *argv[]) {
    fprintf(stderr, "EACCES: %s\n", strerror(EACCES));
    errno = ENOENT;
    perror(argv[0]);
    exit(0);
yi
```

1. strerror：函数定义是这样的`char *strerror(int errnum)`，功能是把errnum映射为一个出错消息的字符串，并且返回此字符串的指针
2. perror：基于errno的值输出一条对应的错误信息，然后会在输出参数指向的字符串的时候，会在参数指向的字符串的后面加上一个冒号，然后就是对应于errno的错误信息

**获取用户id和组id**

```
#include "apue.h"

int main(int argc, char *argv[]) {
    printf("uid = %d, gid = %d\n", getuid(), getgid());
    exit(0);
}
```

1. getuid：获取用户id
2. getpid：获取组id

**信号处理**

```
#include "apue.h"
#include <sys/wait.h>

static void sig_int(int);

int main(int argc, char *argv[]) {
    char buf[MAXLINE];
    pid_t pid;
    int status;

    printf("pid: %d\n", getpid());

    if (signal(SIGINT, sig_int) == SIG_ERR)
        err_sys("signal error");
    printf("%% ");
    while (fgets(buf, MAXLINE, stdin) != NULL) {
        if (buf[strlen(buf) - 1] == '\n')
            buf[strlen(buf) - 1] = 0;

        if ((pid = fork()) < 0) {
            err_sys("fork error");
        } else if (pid == 0) {
            execlp(buf, buf, (char *) 0);
            err_ret("couldn't execute: %s", buf);
            exit(127);
        }

        if ((pid = waitpid(pid, &status, 0)) < 0)
            err_sys("waitpid error");
        printf("%% ");
    }
    exit(0);
}

void sig_int(int signo) {
    printf("interrupt\n%% ");
}
```

1. signal：检测参数里规定的信号，如果检测到了这个信号就执行参数里指向的信号处理程序

可以看到这个代码是改了上面的代码，它的功能就是会捕捉ctrl+c信号，然后执行对应的信号处理程序，这里信号处理程序的功能就是输出一个字符串

**时间值**

时钟时间：进程运行的时间总量

用户CPU时间：执行用户指令所用的时间

系统CPU时间：执行内核程序所经历的时间，如使用系统调用，内核执行该调用所花费的时间就算到系统CPU时间里面

## 习题

1. 在系统上验证，除根目录外，目录.和..是不同的

   ```
   # root @ ubuntu in /home/resery/Unix/Exercise/Chapter-01 [18:44:19] 
   $ ls .
   1.4.3.c  1.5.3.c  1.5.4  1.5.4.c  1.6.2  1.6.2.c  1.6.3  1.6.3.c  1.7.c  1.8.c  1.9  1.9.c  a.out  p1.c  p4.c  p5.c  README.md
   
   # root @ ubuntu in /home/resery/Unix/Exercise/Chapter-01 [18:50:46] 
   $ ls ..
   apue.3e     Chapter-02  Chapter-04  Chapter-06  Chapter-08  Chapter-10  Chapter-12  Chapter-14  Chapter-16  README.md
   Chapter-01  Chapter-03  Chapter-05  Chapter-07  Chapter-09  Chapter-11  Chapter-13  Chapter-15  Chapter-17
   
   ```

2. 分析输出进程ID代码的输出，说明两个进程发生了什么情况，输出如下：

   ```
   hello world from process ID 5780
   
   hello world from process ID 5789
   ```

   第一个进程：内核分配ID，然后进程结束，第二个进程：内核分配ID，不过ID是按顺序分配的，然后进程结束

3. 出错处理中的perror的参数是用ISO C的属性const定义的，而strerror的整型参数没有用此属性定义，为什么？

   ```
   char *
   strerror(int error)
   {
   	static char	mesg[30];
   
   	if (error >= 0 && error <= sys_nerr)
   		return((char *)sys_errlist[error]);
   
   	sprintf(mesg, "Unknown error (%d)", error);
   	return(mesg);
   }
   ```

   从上面的代码可以直到，strerror里并没有对error进行修改所以不用const定义也可以

   ```
   extern void perror (const char *__s);
   ```

   perror传的是指针，如果说函数内部更改了参数，由于传的是指针所以也就会修改对应的值，所以需要加一个const定义，定义为常量

4. 若日历时间存放带符号的32位整型数中，那么到哪一年他将溢出？可以用什么方法扩展浮点数？采用的策略是否与现有的应用相兼容?

   到2的32次方那年会溢出，使用 IEEE754 编码扩展（double），与现有的应用不一定兼容。

5. 若进程时间存放在带符号的 32 位整型数中，而且每秒为 100 时钟滴答，那么经过多少天后该时间值将会溢出？

   （2的31次方减1）除100除60除60除24

