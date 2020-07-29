# Shell Lab

这个lab需要我们模拟shell的执行，和对信号的处理，要实现内置命令quit，fg，bg，jobs（显示作业列表），然后可以执行可执行文件。

书上的例子每一个都应该仔细看几遍，才能写的出来。

辅助函数：

- `int parseline(const char *cmdline,char **argv)`：获取参数列表`char **argv`，返回是否为后台运行命令（`true`）。
- `void clearjob(struct job_t *job)`：清除`job`结构。
- `void initjobs(struct job_t *jobs)`：初始化`jobs`链表。
- `void maxjid(struct job_t *jobs)`：返回`jobs`链表中最大的`jid`号。
- `int addjob(struct job_t *jobs,pid_t pid,int state,char *cmdline)`：在`jobs`链表中添加`job`
- `int deletejob(struct job_t *jobs,pid_t pid)`：在`jobs`链表中删除`pid`的`job`。
- `pid_t fgpid(struct job_t *jobs)`：返回当前前台运行`job`的`pid`号。
- `struct job_t *getjobpid(struct job_t *jobs,pid_t pid)`：返回`pid`号的`job`。
- `struct job_t *getjobjid(struct job_t *jobs,int jid)`：返回`jid`号的`job`。
- `int pid2jid(pid_t pid)`：将`pid`号转化为`jid`。
- `void listjobs(struct job_t *jobs)`：打印`jobs`。
- `void sigquit_handler(int sig)`：处理`SIGQUIT`信号。

完成步骤

1. 第一步，应该先完成eval，eval应该包含的功能有
   - 检测是否为内置命令，内置命令直接执行，不是内置命令就当作可执行文件执行，如果是可执行文件就执行，不是就输出找不到命令
   - 检测是前台运行还是后台运行，前台运行就需要等待作业结束才能结束进程（要显式地等待结束使用sigsuspend函数），后台运行就需要fork一个新进程并且要注意竞争，所以在fork之后要解除阻塞的信号集合，而且为了实现捕获ctrl+c和ctrl+z还需要在fork之后修改子进程的group id，也是为了避免 ctrl-c 发送到每个process（setpgrp（）函数把本进程的gid 修改为pid）
2. 第二步，就是完善eval函数中的内容首先完成builtin\_cmd函数，书上有相应的框架，填东西就可以了
   - 因为要实现内置命令直接执行，所以需要设置3种情况即3个if判断，检测出命令是内置的就执行对应的功能，除了quit其余的3个内置命令都转去调用另一个函数
   - 命令结尾为&就代表说要后台执行
3. 第三步，完善等待前台作业结束的waitfg函数
   - waitfg这个书上也有对应的框架，先设置一个空的阻塞信号集合，然后直接使用sigsuspend函数就可以了
4. 第四步，就是该完成builtin\_cmd函数中直接调用的do\_bgfg函数了，完成这个函数需要看一下tshref.out这个文件，好知道什么情况应该输出什么
   - 先检测bg或者fg之后有没有参数，如果没有参数就应该输出错误信息即使用方法，然后直接退出。
   - 有参数就要对参数进行处理了，%a 和 a是不一样的！一个是对一个作业操作，另一个是对进程操作，而作业代表了一个进程组。
   - 参数为进程的情况下，先返回一个pid号的job，然后检测job存不存在或者这个job的状态是不是没有定义，如果两个条件都不满足就表明没有这个进程
   - 参数为作业的情况下，先返回一个jid号的job，同样检测job不存在或者这个job的状态是不是没有定义，如果两个条件都不满足就表明没有这个作业
   - 参数输入错误的情况下，输出一条错误信息，提示参数的正确格式
   - 参数处理完成之后就是该进行bg和fg操作了，bg需要输出jid，pid 和对应的命令，然后设置状态，然后直接使用kill函数发送SIGCONT给进程组中的每个进程。fg就直接设置状态，然后也使用kill函数发送SIGCONT给进程组中的每个进程，然后调用waitfg等待前台程序结束
5. 第五步，完成信号处理程序
   - sigint_handler，处理ctrl+c，如果说捕获到了SIGINT信号，先获取当前前台作业的pid然后如果pid不等于0就直接调用kill函数发送SIGINT信号给进程组中的每个进程
   - sigtstp_handler，处理ctrl+z，如果捕获到了SIGTSTP信号，先获取当前前台作业的pid然后如果pid不等于0就直接调用kill函数发送SIGTSTP信号给进程组中的每个进程
   - sigchld_handler，子进程终止或者停止，如果捕获到了SIGCHLD信号，先设置一个信号全阻塞，然后使用waitpid函数，并且设置options为立即返回（waitpid函数功能为等待子进程终止或者停止，默认情况下（options=0），waitpid挂起调用进程的执行，直到它的等待集合中的一个子进程终止。如果等待集合中的子进程都没有被停止或终止，则返回0，如果有一个停止或终止，则返回该子进程的PID），然后就是要检测退出的状态了，退出状态主要分3种
     - 正常退出：正常退出就直接删除作业，然后把信号阻塞恢复了就可以了
     - 未捕获信号退出：未捕获信号退出就需要输出具体的状态了，即jid，pid，以及使用WTERMSIG函数返回导致子进程终止的信息的编号（函数功能：返回导致子进程终止的信号的编号。只有在WIFSIGNALED()返回为真时，才定义这个状态）
     - 停止：停止也需要输出具体的状态，即jid，pid，以及使用WSTOPSIG函数返回引起子进程停止的信号的编号（函数功能：返回引起子进程停止的信号的编号。只有在WIFSTOPPED()返回为真时，才定义这个状态）

代码：

```
/* 
 * tsh - A tiny shell program with job control
 * 
 * <Put your name and login ID here>
 */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>

/* Misc manifest constants */
#define MAXLINE    1024   /* max line size */
#define MAXARGS     128   /* max args on a command line */
#define MAXJOBS      16   /* max jobs at any point in time */
#define MAXJID    1<<16   /* max job ID */

/* Job states */
#define UNDEF 0 /* undefined */
#define FG 1    /* running in foreground */
#define BG 2    /* running in background */
#define ST 3    /* stopped */

/* 
 * Jobs states: FG (foreground), BG (background), ST (stopped)
 * Job state transitions and enabling actions:
 *     FG -> ST  : ctrl-z
 *     ST -> FG  : fg command
 *     ST -> BG  : bg command
 *     BG -> FG  : fg command
 * At most 1 job can be in the FG state.
 */

/* Global variables */
extern char **environ;      /* defined in libc */
char prompt[] = "tsh> ";    /* command line prompt (DO NOT CHANGE) */
int verbose = 0;            /* if true, print additional output */
int nextjid = 1;            /* next job ID to allocate */
char sbuf[MAXLINE];         /* for composing sprintf messages */

struct job_t {              /* The job struct */
    pid_t pid;              /* job PID */
    int jid;                /* job ID [1, 2, ...] */
    int state;              /* UNDEF, BG, FG, or ST */
    char cmdline[MAXLINE];  /* command line */
};
struct job_t jobs[MAXJOBS]; /* The job list */
/* End global variables */


/* Function prototypes */

/* Here are the functions that you will implement */
void eval(char *cmdline);
int builtin_cmd(char **argv);
void do_bgfg(char **argv);
void waitfg(pid_t pid);

void sigchld_handler(int sig);
void sigtstp_handler(int sig);
void sigint_handler(int sig);

/* Here are helper routines that we've provided for you */
int parseline(const char *cmdline, char **argv); 
void sigquit_handler(int sig);

void clearjob(struct job_t *job);
void initjobs(struct job_t *jobs);
int maxjid(struct job_t *jobs); 
int addjob(struct job_t *jobs, pid_t pid, int state, char *cmdline);
int deletejob(struct job_t *jobs, pid_t pid); 
pid_t fgpid(struct job_t *jobs);
struct job_t *getjobpid(struct job_t *jobs, pid_t pid);
struct job_t *getjobjid(struct job_t *jobs, int jid); 
int pid2jid(pid_t pid); 
void listjobs(struct job_t *jobs);

void usage(void);
void unix_error(char *msg);
void app_error(char *msg);
typedef void handler_t(int);
handler_t *Signal(int signum, handler_t *handler);

/*
 * main - The shell's main routine 
 */
int main(int argc, char **argv) 
{
    char c;
    char cmdline[MAXLINE];
    int emit_prompt = 1; /* emit prompt (default) */

    /* Redirect stderr to stdout (so that driver will get all output
     * on the pipe connected to stdout) */
    dup2(1, 2);

    /* Parse the command line */
    while ((c = getopt(argc, argv, "hvp")) != EOF) {
        switch (c) {
        case 'h':             /* print help message */
            usage();
	    break;
        case 'v':             /* emit additional diagnostic info */
            verbose = 1;
	    break;
        case 'p':             /* don't print a prompt */
            emit_prompt = 0;  /* handy for automatic testing */
	    break;
	default:
            usage();
	}
    }

    /* Install the signal handlers */

    /* These are the ones you will need to implement */
    Signal(SIGINT,  sigint_handler);   /* ctrl-c */
    Signal(SIGTSTP, sigtstp_handler);  /* ctrl-z */
    Signal(SIGCHLD, sigchld_handler);  /* Terminated or stopped child */

    /* This one provides a clean way to kill the shell */
    Signal(SIGQUIT, sigquit_handler); 

    /* Initialize the job list */
    initjobs(jobs);

    /* Execute the shell's read/eval loop */
    while (1) {

	/* Read command line */
	if (emit_prompt) {
	    printf("%s", prompt);
	    fflush(stdout);
	}
	if ((fgets(cmdline, MAXLINE, stdin) == NULL) && ferror(stdin))
	    app_error("fgets error");
	if (feof(stdin)) { /* End of file (ctrl-d) */
	    fflush(stdout);
	    exit(0);
	}

	/* Evaluate the command line */
	eval(cmdline);
	fflush(stdout);
	fflush(stdout);
    } 

    exit(0); /* control never reaches here */
}
  
/* 
 * eval - Evaluate the command line that the user has just typed in
 * 
 * If the user has requested a built-in command (quit, jobs, bg or fg)
 * then execute it immediately. Otherwise, fork a child process and
 * run the job in the context of the child. If the job is running in
 * the foreground, wait for it to terminate and then return.  Note:
 * each child process must have a unique process group ID so that our
 * background children don't receive SIGINT (SIGTSTP) from the kernel
 * when we type ctrl-c (ctrl-z) at the keyboard.  
*/
void eval(char *cmdline) 
{
    char *argv[MAXARGS];
    char buf[MAXLINE];
    int bg;
    pid_t pid;
    sigset_t mask_all, mask_one, mask_oldset;

    strcpy(buf,cmdline);
    bg = parseline(buf,argv);

    if(argv[0]==NULL)
        return ;

    if(!builtin_cmd(argv)){
        
        sigfillset(&mask_all);
        sigemptyset(&mask_one);
        sigaddset(&mask_one, SIGCHLD);

        sigprocmask(SIG_BLOCK,&mask_one,&mask_oldset);
        if((pid=fork())==0){
            sigprocmask(SIG_SETMASK,&mask_oldset,NULL);
            setpgid(0,0);
            if(execve(argv[0],argv,environ)<0){
                printf("%s: Command not found.\n",argv[0]);
                exit(0);
            }
        }

        int state = bg ? BG:FG;
        //parent
        sigprocmask(SIG_BLOCK,&mask_all,NULL);
        addjob(jobs,pid,state,cmdline);
        sigprocmask(SIG_SETMASK,&mask_oldset,NULL);

        if(!bg){
            waitfg(pid);
        }else{
            printf("[%d] (%d) %s",pid2jid(pid),pid,cmdline);
        }   
    }

    return;
}

/* 
 * parseline - Parse the command line and build the argv array.
 * 
 * Characters enclosed in single quotes are treated as a single
 * argument.  Return true if the user has requested a BG job, false if
 * the user has requested a FG job.  
 */
int parseline(const char *cmdline, char **argv) 
{
    static char array[MAXLINE]; /* holds local copy of command line */
    char *buf = array;          /* ptr that traverses command line */
    char *delim;                /* points to first space delimiter */
    int argc;                   /* number of args */
    int bg;                     /* background job? */

    strcpy(buf, cmdline);
    buf[strlen(buf)-1] = ' ';  /* replace trailing '\n' with space */
    while (*buf && (*buf == ' ')) /* ignore leading spaces */
	buf++;

    /* Build the argv list */
    argc = 0;
    if (*buf == '\'') {
	buf++;
	delim = strchr(buf, '\'');
    }
    else {
	delim = strchr(buf, ' ');
    }

    while (delim) {
	argv[argc++] = buf;
	*delim = '\0';
	buf = delim + 1;
	while (*buf && (*buf == ' ')) /* ignore spaces */
	       buf++;

	if (*buf == '\'') {
	    buf++;
	    delim = strchr(buf, '\'');
	}
	else {
	    delim = strchr(buf, ' ');
	}
    }
    argv[argc] = NULL;
    
    if (argc == 0)  /* ignore blank line */
	return 1;

    /* should the job run in the background? */
    if ((bg = (*argv[argc-1] == '&')) != 0) {
	argv[--argc] = NULL;
    }
    return bg;
}

/* 
 * builtin_cmd - If the user has typed a built-in command then execute
 *    it immediately.  
 */
int builtin_cmd(char **argv) 
{
    if(!strcmp(argv[0],"quit"))
        exit(0);
    if(!strcmp(argv[0],"jobs")){
        listjobs(jobs);
        return 1;
    }
    if(!strcmp(argv[0],"bg") || (!strcmp(argv[0],"bg"))){
        do_bgfg(argv);
        return 1;
    }
    if(!strcmp(argv[0],"&"))
        return 1;
    return 0;     /* not a builtin command */
}

/* 
 * do_bgfg - Execute the builtin bg and fg commands
 */
void do_bgfg(char **argv) 
{
    if(argv[1] == NULL){
        printf("%s command requires PID or %%jobid argument\n",argv[0]);
        return;
    }

    int bg = !strcmp(argv[0],"bg");
    struct job_t *job_ptr;
    pid_t pid;
    int jid;
    if(sscanf(argv[1],"%d",&pid) > 0){
        // pid
        job_ptr = getjobpid(jobs,pid);
        if(job_ptr == NULL || job_ptr->state == UNDEF){
            printf("(%d): No such process\n",pid);
            return;
        }
    }else if(sscanf(argv[1],"%%%d",&jid) > 0){
        // jid
        job_ptr = getjobjid(jobs,jid);
        if(job_ptr == NULL || job_ptr->state == UNDEF){
            printf("%%%d: No such job\n",jid);
            return;
        }
    }else{
        printf("%s: argument must be a PID or %%jobid\n",argv[0]);
        return;
    }
    // get the job_ptr;
    if(bg){
        printf("[%d] (%d) %s",job_ptr->jid,job_ptr->pid,job_ptr->cmdline);
        job_ptr->state = BG;
        kill(-job_ptr->pid,SIGCONT);
    }else{
        // "fg"
        job_ptr->state = FG;
        kill(-job_ptr->pid,SIGCONT);
        waitfg(job_ptr->pid);
    }
    return;
}

/* 
 * waitfg - Block until process pid is no longer the foreground process
 */
void waitfg(pid_t pid)
{
    sigset_t mask_temp;
    sigemptyset(&mask_temp);

    while (fgpid(jobs) > 0)
        sigsuspend(&mask_temp);
    return;
}

/*****************
 * Signal handlers
 *****************/

/* 
 * sigchld_handler - The kernel sends a SIGCHLD to the shell whenever
 *     a child job terminates (becomes a zombie), or stops because it
 *     received a SIGSTOP or SIGTSTP signal. The handler reaps all
 *     available zombie children, but doesn't wait for any other
 *     currently running children to terminate.  
 */
void sigchld_handler(int sig) 
{
    int olderrno = errno;
    sigset_t mask_all,prev;
    pid_t pid;

    int status;
    sigfillset(&mask_all);
    while((pid = waitpid(-1,&status,WNOHANG|WUNTRACED)) > 0){
        if(WIFEXITED(status)){
            // normally exit
            sigprocmask(SIG_BLOCK,&mask_all,&prev);
            deletejob(jobs,pid);
            sigprocmask(SIG_SETMASK,&prev,NULL);
        }else if(WIFSIGNALED(status)){
            // exit by signal
            struct job_t *job_ptr = getjobpid(jobs,pid);
            sigprocmask(SIG_BLOCK,&mask_all,&prev);
            printf("Job [%d] (%d) terminated by signal %d\n",job_ptr->jid,job_ptr->pid,WTERMSIG(status));
            deletejob(jobs,pid);
            sigprocmask(SIG_SETMASK,&prev,NULL);
        }else{ // stop
            struct job_t *job_ptr = getjobpid(jobs,pid);
            sigprocmask(SIG_BLOCK,&mask_all,&prev);
            printf("Job [%d] (%d) stopped by signal %d\n",job_ptr->jid,job_ptr->pid,WSTOPSIG(status));
            job_ptr->state= ST;
            sigprocmask(SIG_SETMASK,&prev,NULL);
        }
    }
    errno = olderrno;
    return;
}

/* 
 * sigint_handler - The kernel sends a SIGINT to the shell whenver the
 *    user types ctrl-c at the keyboard.  Catch it and send it along
 *    to the foreground job.  
 */
void sigint_handler(int sig) 
{
    int olderrno = errno;
    pid_t pid = fgpid(jobs);

    if(pid != 0){
        kill(-pid,SIGINT);
    }

    errno = olderrno;
    return;
}

/*
 * sigtstp_handler - The kernel sends a SIGTSTP to the shell whenever
 *     the user types ctrl-z at the keyboard. Catch it and suspend the
 *     foreground job by sending it a SIGTSTP.  
 */
void sigtstp_handler(int sig) 
{
    int olderrno = errno;
    pid_t pid = fgpid(jobs);

    if(pid != 0){
        kill(-pid,SIGTSTP);
    }

    errno = olderrno;

    return;
}

/*********************
 * End signal handlers
 *********************/

/***********************************************
 * Helper routines that manipulate the job list
 **********************************************/

/* clearjob - Clear the entries in a job struct */
void clearjob(struct job_t *job) {
    job->pid = 0;
    job->jid = 0;
    job->state = UNDEF;
    job->cmdline[0] = '\0';
}

/* initjobs - Initialize the job list */
void initjobs(struct job_t *jobs) {
    int i;

    for (i = 0; i < MAXJOBS; i++)
	clearjob(&jobs[i]);
}

/* maxjid - Returns largest allocated job ID */
int maxjid(struct job_t *jobs) 
{
    int i, max=0;

    for (i = 0; i < MAXJOBS; i++)
	if (jobs[i].jid > max)
	    max = jobs[i].jid;
    return max;
}

/* addjob - Add a job to the job list */
int addjob(struct job_t *jobs, pid_t pid, int state, char *cmdline) 
{
    int i;
    
    if (pid < 1)
	return 0;

    for (i = 0; i < MAXJOBS; i++) {
	if (jobs[i].pid == 0) {
	    jobs[i].pid = pid;
	    jobs[i].state = state;
	    jobs[i].jid = nextjid++;
	    if (nextjid > MAXJOBS)
		nextjid = 1;
	    strcpy(jobs[i].cmdline, cmdline);
  	    if(verbose){
	        printf("Added job [%d] %d %s\n", jobs[i].jid, jobs[i].pid, jobs[i].cmdline);
            }
            return 1;
	}
    }
    printf("Tried to create too many jobs\n");
    return 0;
}

/* deletejob - Delete a job whose PID=pid from the job list */
int deletejob(struct job_t *jobs, pid_t pid) 
{
    int i;

    if (pid < 1)
	return 0;

    for (i = 0; i < MAXJOBS; i++) {
	if (jobs[i].pid == pid) {
	    clearjob(&jobs[i]);
	    nextjid = maxjid(jobs)+1;
	    return 1;
	}
    }
    return 0;
}

/* fgpid - Return PID of current foreground job, 0 if no such job */
pid_t fgpid(struct job_t *jobs) {
    int i;

    for (i = 0; i < MAXJOBS; i++)
	if (jobs[i].state == FG)
	    return jobs[i].pid;
    return 0;
}

/* getjobpid  - Find a job (by PID) on the job list */
struct job_t *getjobpid(struct job_t *jobs, pid_t pid) {
    int i;

    if (pid < 1)
	return NULL;
    for (i = 0; i < MAXJOBS; i++)
	if (jobs[i].pid == pid)
	    return &jobs[i];
    return NULL;
}

/* getjobjid  - Find a job (by JID) on the job list */
struct job_t *getjobjid(struct job_t *jobs, int jid) 
{
    int i;

    if (jid < 1)
	return NULL;
    for (i = 0; i < MAXJOBS; i++)
	if (jobs[i].jid == jid)
	    return &jobs[i];
    return NULL;
}

/* pid2jid - Map process ID to job ID */
int pid2jid(pid_t pid) 
{
    int i;

    if (pid < 1)
	return 0;
    for (i = 0; i < MAXJOBS; i++)
	if (jobs[i].pid == pid) {
            return jobs[i].jid;
        }
    return 0;
}

/* listjobs - Print the job list */
void listjobs(struct job_t *jobs) 
{
    int i;
    
    for (i = 0; i < MAXJOBS; i++) {
	if (jobs[i].pid != 0) {
	    printf("[%d] (%d) ", jobs[i].jid, jobs[i].pid);
	    switch (jobs[i].state) {
		case BG: 
		    printf("Running ");
		    break;
		case FG: 
		    printf("Foreground ");
		    break;
		case ST: 
		    printf("Stopped ");
		    break;
	    default:
		    printf("listjobs: Internal error: job[%d].state=%d ", 
			   i, jobs[i].state);
	    }
	    printf("%s", jobs[i].cmdline);
	}
    }
}
/******************************
 * end job list helper routines
 ******************************/


/***********************
 * Other helper routines
 ***********************/

/*
 * usage - print a help message
 */
void usage(void) 
{
    printf("Usage: shell [-hvp]\n");
    printf("   -h   print this message\n");
    printf("   -v   print additional diagnostic information\n");
    printf("   -p   do not emit a command prompt\n");
    exit(1);
}

/*
 * unix_error - unix-style error routine
 */
void unix_error(char *msg)
{
    fprintf(stdout, "%s: %s\n", msg, strerror(errno));
    exit(1);
}

/*
 * app_error - application-style error routine
 */
void app_error(char *msg)
{
    fprintf(stdout, "%s\n", msg);
    exit(1);
}

/*
 * Signal - wrapper for the sigaction function
 */
handler_t *Signal(int signum, handler_t *handler) 
{
    struct sigaction action, old_action;

    action.sa_handler = handler;  
    sigemptyset(&action.sa_mask); /* block sigs of type being handled */
    action.sa_flags = SA_RESTART; /* restart syscalls if possible */

    if (sigaction(signum, &action, &old_action) < 0)
	unix_error("Signal error");
    return (old_action.sa_handler);
}

/*
 * sigquit_handler - The driver program can gracefully terminate the
 *    child shell by sending it a SIGQUIT signal.
 */
void sigquit_handler(int sig) 
{
    printf("Terminating after receipt of SIGQUIT signal\n");
    exit(1);
}
```

