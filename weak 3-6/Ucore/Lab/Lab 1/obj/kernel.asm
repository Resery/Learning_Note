
bin/kernel:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100000:	55                   	push   %ebp
  100001:	89 e5                	mov    %esp,%ebp
  100003:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  100006:	ba a0 0d 11 00       	mov    $0x110da0,%edx
  10000b:	b8 16 fa 10 00       	mov    $0x10fa16,%eax
  100010:	29 c2                	sub    %eax,%edx
  100012:	89 d0                	mov    %edx,%eax
  100014:	89 44 24 08          	mov    %eax,0x8(%esp)
  100018:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10001f:	00 
  100020:	c7 04 24 16 fa 10 00 	movl   $0x10fa16,(%esp)
  100027:	e8 66 30 00 00       	call   103092 <memset>

    cons_init();                // init the console
  10002c:	e8 5d 15 00 00       	call   10158e <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100031:	c7 45 f4 a0 38 10 00 	movl   $0x1038a0,-0xc(%ebp)
    cprintf("%s\n\n", message);
  100038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10003b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10003f:	c7 04 24 bc 38 10 00 	movl   $0x1038bc,(%esp)
  100046:	e8 21 02 00 00       	call   10026c <cprintf>

    print_kerninfo();
  10004b:	e8 c2 08 00 00       	call   100912 <print_kerninfo>

    grade_backtrace();
  100050:	e8 8e 00 00 00       	call   1000e3 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100055:	e8 0d 2d 00 00       	call   102d67 <pmm_init>

    pic_init();                 // init interrupt controller
  10005a:	e8 6d 16 00 00       	call   1016cc <pic_init>
    idt_init();                 // init interrupt descriptor table
  10005f:	e8 c6 17 00 00       	call   10182a <idt_init>

    clock_init();               // init clock interrupt
  100064:	e8 16 0d 00 00       	call   100d7f <clock_init>
    intr_enable();              // enable irq interrupt
  100069:	e8 91 17 00 00       	call   1017ff <intr_enable>

    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    lab1_switch_test();
  10006e:	e8 6b 01 00 00       	call   1001de <lab1_switch_test>

    /* do nothing */
    while (1);
  100073:	eb fe                	jmp    100073 <kern_init+0x73>

00100075 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  100075:	55                   	push   %ebp
  100076:	89 e5                	mov    %esp,%ebp
  100078:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  10007b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  100082:	00 
  100083:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10008a:	00 
  10008b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100092:	e8 d6 0c 00 00       	call   100d6d <mon_backtrace>
}
  100097:	90                   	nop
  100098:	c9                   	leave  
  100099:	c3                   	ret    

0010009a <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  10009a:	55                   	push   %ebp
  10009b:	89 e5                	mov    %esp,%ebp
  10009d:	53                   	push   %ebx
  10009e:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000a1:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000a7:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000aa:	8b 45 08             	mov    0x8(%ebp),%eax
  1000ad:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000b1:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000b5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000b9:	89 04 24             	mov    %eax,(%esp)
  1000bc:	e8 b4 ff ff ff       	call   100075 <grade_backtrace2>
}
  1000c1:	90                   	nop
  1000c2:	83 c4 14             	add    $0x14,%esp
  1000c5:	5b                   	pop    %ebx
  1000c6:	5d                   	pop    %ebp
  1000c7:	c3                   	ret    

001000c8 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000c8:	55                   	push   %ebp
  1000c9:	89 e5                	mov    %esp,%ebp
  1000cb:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1000d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1000d8:	89 04 24             	mov    %eax,(%esp)
  1000db:	e8 ba ff ff ff       	call   10009a <grade_backtrace1>
}
  1000e0:	90                   	nop
  1000e1:	c9                   	leave  
  1000e2:	c3                   	ret    

001000e3 <grade_backtrace>:

void
grade_backtrace(void) {
  1000e3:	55                   	push   %ebp
  1000e4:	89 e5                	mov    %esp,%ebp
  1000e6:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  1000e9:	b8 00 00 10 00       	mov    $0x100000,%eax
  1000ee:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  1000f5:	ff 
  1000f6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1000fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100101:	e8 c2 ff ff ff       	call   1000c8 <grade_backtrace0>
}
  100106:	90                   	nop
  100107:	c9                   	leave  
  100108:	c3                   	ret    

00100109 <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  100109:	55                   	push   %ebp
  10010a:	89 e5                	mov    %esp,%ebp
  10010c:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  10010f:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100112:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100115:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100118:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10011b:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10011f:	83 e0 03             	and    $0x3,%eax
  100122:	89 c2                	mov    %eax,%edx
  100124:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100129:	89 54 24 08          	mov    %edx,0x8(%esp)
  10012d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100131:	c7 04 24 c1 38 10 00 	movl   $0x1038c1,(%esp)
  100138:	e8 2f 01 00 00       	call   10026c <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10013d:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100141:	89 c2                	mov    %eax,%edx
  100143:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100148:	89 54 24 08          	mov    %edx,0x8(%esp)
  10014c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100150:	c7 04 24 cf 38 10 00 	movl   $0x1038cf,(%esp)
  100157:	e8 10 01 00 00       	call   10026c <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10015c:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100160:	89 c2                	mov    %eax,%edx
  100162:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100167:	89 54 24 08          	mov    %edx,0x8(%esp)
  10016b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10016f:	c7 04 24 dd 38 10 00 	movl   $0x1038dd,(%esp)
  100176:	e8 f1 00 00 00       	call   10026c <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  10017b:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  10017f:	89 c2                	mov    %eax,%edx
  100181:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  100186:	89 54 24 08          	mov    %edx,0x8(%esp)
  10018a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10018e:	c7 04 24 eb 38 10 00 	movl   $0x1038eb,(%esp)
  100195:	e8 d2 00 00 00       	call   10026c <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  10019a:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  10019e:	89 c2                	mov    %eax,%edx
  1001a0:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001ad:	c7 04 24 f9 38 10 00 	movl   $0x1038f9,(%esp)
  1001b4:	e8 b3 00 00 00       	call   10026c <cprintf>
    round ++;
  1001b9:	a1 20 fa 10 00       	mov    0x10fa20,%eax
  1001be:	40                   	inc    %eax
  1001bf:	a3 20 fa 10 00       	mov    %eax,0x10fa20
}
  1001c4:	90                   	nop
  1001c5:	c9                   	leave  
  1001c6:	c3                   	ret    

001001c7 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001c7:	55                   	push   %ebp
  1001c8:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
  1001ca:	83 ec 08             	sub    $0x8,%esp
  1001cd:	cd 78                	int    $0x78
  1001cf:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        : 
        : "i"(T_SWITCH_TOU)
    );
}
  1001d1:	90                   	nop
  1001d2:	5d                   	pop    %ebp
  1001d3:	c3                   	ret    

001001d4 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  1001d4:	55                   	push   %ebp
  1001d5:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO

        asm volatile (
  1001d7:	cd 79                	int    $0x79
  1001d9:	89 ec                	mov    %ebp,%esp
           "int %0 \n"
           "movl %%ebp, %%esp"
           : 
           : "i"(T_SWITCH_TOK)
       );
}
  1001db:	90                   	nop
  1001dc:	5d                   	pop    %ebp
  1001dd:	c3                   	ret    

001001de <lab1_switch_test>:

static void
lab1_switch_test(void) {
  1001de:	55                   	push   %ebp
  1001df:	89 e5                	mov    %esp,%ebp
  1001e1:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  1001e4:	e8 20 ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  1001e9:	c7 04 24 08 39 10 00 	movl   $0x103908,(%esp)
  1001f0:	e8 77 00 00 00       	call   10026c <cprintf>
    lab1_switch_to_user();
  1001f5:	e8 cd ff ff ff       	call   1001c7 <lab1_switch_to_user>
    lab1_print_cur_status();
  1001fa:	e8 0a ff ff ff       	call   100109 <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  1001ff:	c7 04 24 28 39 10 00 	movl   $0x103928,(%esp)
  100206:	e8 61 00 00 00       	call   10026c <cprintf>
    lab1_switch_to_kernel();
  10020b:	e8 c4 ff ff ff       	call   1001d4 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100210:	e8 f4 fe ff ff       	call   100109 <lab1_print_cur_status>
}
  100215:	90                   	nop
  100216:	c9                   	leave  
  100217:	c3                   	ret    

00100218 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100218:	55                   	push   %ebp
  100219:	89 e5                	mov    %esp,%ebp
  10021b:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10021e:	8b 45 08             	mov    0x8(%ebp),%eax
  100221:	89 04 24             	mov    %eax,(%esp)
  100224:	e8 92 13 00 00       	call   1015bb <cons_putc>
    (*cnt) ++;
  100229:	8b 45 0c             	mov    0xc(%ebp),%eax
  10022c:	8b 00                	mov    (%eax),%eax
  10022e:	8d 50 01             	lea    0x1(%eax),%edx
  100231:	8b 45 0c             	mov    0xc(%ebp),%eax
  100234:	89 10                	mov    %edx,(%eax)
}
  100236:	90                   	nop
  100237:	c9                   	leave  
  100238:	c3                   	ret    

00100239 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100239:	55                   	push   %ebp
  10023a:	89 e5                	mov    %esp,%ebp
  10023c:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10023f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100246:	8b 45 0c             	mov    0xc(%ebp),%eax
  100249:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10024d:	8b 45 08             	mov    0x8(%ebp),%eax
  100250:	89 44 24 08          	mov    %eax,0x8(%esp)
  100254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100257:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025b:	c7 04 24 18 02 10 00 	movl   $0x100218,(%esp)
  100262:	e8 7e 31 00 00       	call   1033e5 <vprintfmt>
    return cnt;
  100267:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10026a:	c9                   	leave  
  10026b:	c3                   	ret    

0010026c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10026c:	55                   	push   %ebp
  10026d:	89 e5                	mov    %esp,%ebp
  10026f:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  100272:	8d 45 0c             	lea    0xc(%ebp),%eax
  100275:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100278:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10027b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10027f:	8b 45 08             	mov    0x8(%ebp),%eax
  100282:	89 04 24             	mov    %eax,(%esp)
  100285:	e8 af ff ff ff       	call   100239 <vcprintf>
  10028a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10028d:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100290:	c9                   	leave  
  100291:	c3                   	ret    

00100292 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  100292:	55                   	push   %ebp
  100293:	89 e5                	mov    %esp,%ebp
  100295:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100298:	8b 45 08             	mov    0x8(%ebp),%eax
  10029b:	89 04 24             	mov    %eax,(%esp)
  10029e:	e8 18 13 00 00       	call   1015bb <cons_putc>
}
  1002a3:	90                   	nop
  1002a4:	c9                   	leave  
  1002a5:	c3                   	ret    

001002a6 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002a6:	55                   	push   %ebp
  1002a7:	89 e5                	mov    %esp,%ebp
  1002a9:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002ac:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002b3:	eb 13                	jmp    1002c8 <cputs+0x22>
        cputch(c, &cnt);
  1002b5:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002b9:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002bc:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002c0:	89 04 24             	mov    %eax,(%esp)
  1002c3:	e8 50 ff ff ff       	call   100218 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1002cb:	8d 50 01             	lea    0x1(%eax),%edx
  1002ce:	89 55 08             	mov    %edx,0x8(%ebp)
  1002d1:	0f b6 00             	movzbl (%eax),%eax
  1002d4:	88 45 f7             	mov    %al,-0x9(%ebp)
  1002d7:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1002db:	75 d8                	jne    1002b5 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  1002dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1002e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002e4:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1002eb:	e8 28 ff ff ff       	call   100218 <cputch>
    return cnt;
  1002f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1002f3:	c9                   	leave  
  1002f4:	c3                   	ret    

001002f5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1002f5:	55                   	push   %ebp
  1002f6:	89 e5                	mov    %esp,%ebp
  1002f8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1002fb:	e8 e5 12 00 00       	call   1015e5 <cons_getc>
  100300:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100303:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100307:	74 f2                	je     1002fb <getchar+0x6>
        /* do nothing */;
    return c;
  100309:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10030c:	c9                   	leave  
  10030d:	c3                   	ret    

0010030e <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10030e:	55                   	push   %ebp
  10030f:	89 e5                	mov    %esp,%ebp
  100311:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100314:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100318:	74 13                	je     10032d <readline+0x1f>
        cprintf("%s", prompt);
  10031a:	8b 45 08             	mov    0x8(%ebp),%eax
  10031d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100321:	c7 04 24 47 39 10 00 	movl   $0x103947,(%esp)
  100328:	e8 3f ff ff ff       	call   10026c <cprintf>
    }
    int i = 0, c;
  10032d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100334:	e8 bc ff ff ff       	call   1002f5 <getchar>
  100339:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10033c:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100340:	79 07                	jns    100349 <readline+0x3b>
            return NULL;
  100342:	b8 00 00 00 00       	mov    $0x0,%eax
  100347:	eb 78                	jmp    1003c1 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100349:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10034d:	7e 28                	jle    100377 <readline+0x69>
  10034f:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100356:	7f 1f                	jg     100377 <readline+0x69>
            cputchar(c);
  100358:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10035b:	89 04 24             	mov    %eax,(%esp)
  10035e:	e8 2f ff ff ff       	call   100292 <cputchar>
            buf[i ++] = c;
  100363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100366:	8d 50 01             	lea    0x1(%eax),%edx
  100369:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10036c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10036f:	88 90 40 fa 10 00    	mov    %dl,0x10fa40(%eax)
  100375:	eb 45                	jmp    1003bc <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  100377:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  10037b:	75 16                	jne    100393 <readline+0x85>
  10037d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100381:	7e 10                	jle    100393 <readline+0x85>
            cputchar(c);
  100383:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100386:	89 04 24             	mov    %eax,(%esp)
  100389:	e8 04 ff ff ff       	call   100292 <cputchar>
            i --;
  10038e:	ff 4d f4             	decl   -0xc(%ebp)
  100391:	eb 29                	jmp    1003bc <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  100393:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  100397:	74 06                	je     10039f <readline+0x91>
  100399:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  10039d:	75 95                	jne    100334 <readline+0x26>
            cputchar(c);
  10039f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003a2:	89 04 24             	mov    %eax,(%esp)
  1003a5:	e8 e8 fe ff ff       	call   100292 <cputchar>
            buf[i] = '\0';
  1003aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ad:	05 40 fa 10 00       	add    $0x10fa40,%eax
  1003b2:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003b5:	b8 40 fa 10 00       	mov    $0x10fa40,%eax
  1003ba:	eb 05                	jmp    1003c1 <readline+0xb3>
        }
    }
  1003bc:	e9 73 ff ff ff       	jmp    100334 <readline+0x26>
}
  1003c1:	c9                   	leave  
  1003c2:	c3                   	ret    

001003c3 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003c3:	55                   	push   %ebp
  1003c4:	89 e5                	mov    %esp,%ebp
  1003c6:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003c9:	a1 40 fe 10 00       	mov    0x10fe40,%eax
  1003ce:	85 c0                	test   %eax,%eax
  1003d0:	75 5b                	jne    10042d <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  1003d2:	c7 05 40 fe 10 00 01 	movl   $0x1,0x10fe40
  1003d9:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  1003dc:	8d 45 14             	lea    0x14(%ebp),%eax
  1003df:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  1003e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1003e5:	89 44 24 08          	mov    %eax,0x8(%esp)
  1003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1003ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003f0:	c7 04 24 4a 39 10 00 	movl   $0x10394a,(%esp)
  1003f7:	e8 70 fe ff ff       	call   10026c <cprintf>
    vcprintf(fmt, ap);
  1003fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  100403:	8b 45 10             	mov    0x10(%ebp),%eax
  100406:	89 04 24             	mov    %eax,(%esp)
  100409:	e8 2b fe ff ff       	call   100239 <vcprintf>
    cprintf("\n");
  10040e:	c7 04 24 66 39 10 00 	movl   $0x103966,(%esp)
  100415:	e8 52 fe ff ff       	call   10026c <cprintf>
    
    cprintf("stack trackback:\n");
  10041a:	c7 04 24 68 39 10 00 	movl   $0x103968,(%esp)
  100421:	e8 46 fe ff ff       	call   10026c <cprintf>
    print_stackframe();
  100426:	e8 32 06 00 00       	call   100a5d <print_stackframe>
  10042b:	eb 01                	jmp    10042e <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  10042d:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  10042e:	e8 d3 13 00 00       	call   101806 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100433:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10043a:	e8 61 08 00 00       	call   100ca0 <kmonitor>
    }
  10043f:	eb f2                	jmp    100433 <__panic+0x70>

00100441 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100441:	55                   	push   %ebp
  100442:	89 e5                	mov    %esp,%ebp
  100444:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100447:	8d 45 14             	lea    0x14(%ebp),%eax
  10044a:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  10044d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100450:	89 44 24 08          	mov    %eax,0x8(%esp)
  100454:	8b 45 08             	mov    0x8(%ebp),%eax
  100457:	89 44 24 04          	mov    %eax,0x4(%esp)
  10045b:	c7 04 24 7a 39 10 00 	movl   $0x10397a,(%esp)
  100462:	e8 05 fe ff ff       	call   10026c <cprintf>
    vcprintf(fmt, ap);
  100467:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10046a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10046e:	8b 45 10             	mov    0x10(%ebp),%eax
  100471:	89 04 24             	mov    %eax,(%esp)
  100474:	e8 c0 fd ff ff       	call   100239 <vcprintf>
    cprintf("\n");
  100479:	c7 04 24 66 39 10 00 	movl   $0x103966,(%esp)
  100480:	e8 e7 fd ff ff       	call   10026c <cprintf>
    va_end(ap);
}
  100485:	90                   	nop
  100486:	c9                   	leave  
  100487:	c3                   	ret    

00100488 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100488:	55                   	push   %ebp
  100489:	89 e5                	mov    %esp,%ebp
    return is_panic;
  10048b:	a1 40 fe 10 00       	mov    0x10fe40,%eax
}
  100490:	5d                   	pop    %ebp
  100491:	c3                   	ret    

00100492 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100492:	55                   	push   %ebp
  100493:	89 e5                	mov    %esp,%ebp
  100495:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100498:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049b:	8b 00                	mov    (%eax),%eax
  10049d:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004a0:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a3:	8b 00                	mov    (%eax),%eax
  1004a5:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004a8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004af:	e9 ca 00 00 00       	jmp    10057e <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004b4:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004b7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004ba:	01 d0                	add    %edx,%eax
  1004bc:	89 c2                	mov    %eax,%edx
  1004be:	c1 ea 1f             	shr    $0x1f,%edx
  1004c1:	01 d0                	add    %edx,%eax
  1004c3:	d1 f8                	sar    %eax
  1004c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004c8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004cb:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004ce:	eb 03                	jmp    1004d3 <stab_binsearch+0x41>
            m --;
  1004d0:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1004d9:	7c 1f                	jl     1004fa <stab_binsearch+0x68>
  1004db:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004de:	89 d0                	mov    %edx,%eax
  1004e0:	01 c0                	add    %eax,%eax
  1004e2:	01 d0                	add    %edx,%eax
  1004e4:	c1 e0 02             	shl    $0x2,%eax
  1004e7:	89 c2                	mov    %eax,%edx
  1004e9:	8b 45 08             	mov    0x8(%ebp),%eax
  1004ec:	01 d0                	add    %edx,%eax
  1004ee:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1004f2:	0f b6 c0             	movzbl %al,%eax
  1004f5:	3b 45 14             	cmp    0x14(%ebp),%eax
  1004f8:	75 d6                	jne    1004d0 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  1004fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004fd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100500:	7d 09                	jge    10050b <stab_binsearch+0x79>
            l = true_m + 1;
  100502:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100505:	40                   	inc    %eax
  100506:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100509:	eb 73                	jmp    10057e <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10050b:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100512:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100515:	89 d0                	mov    %edx,%eax
  100517:	01 c0                	add    %eax,%eax
  100519:	01 d0                	add    %edx,%eax
  10051b:	c1 e0 02             	shl    $0x2,%eax
  10051e:	89 c2                	mov    %eax,%edx
  100520:	8b 45 08             	mov    0x8(%ebp),%eax
  100523:	01 d0                	add    %edx,%eax
  100525:	8b 40 08             	mov    0x8(%eax),%eax
  100528:	3b 45 18             	cmp    0x18(%ebp),%eax
  10052b:	73 11                	jae    10053e <stab_binsearch+0xac>
            *region_left = m;
  10052d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100530:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100533:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100535:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100538:	40                   	inc    %eax
  100539:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10053c:	eb 40                	jmp    10057e <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  10053e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100541:	89 d0                	mov    %edx,%eax
  100543:	01 c0                	add    %eax,%eax
  100545:	01 d0                	add    %edx,%eax
  100547:	c1 e0 02             	shl    $0x2,%eax
  10054a:	89 c2                	mov    %eax,%edx
  10054c:	8b 45 08             	mov    0x8(%ebp),%eax
  10054f:	01 d0                	add    %edx,%eax
  100551:	8b 40 08             	mov    0x8(%eax),%eax
  100554:	3b 45 18             	cmp    0x18(%ebp),%eax
  100557:	76 14                	jbe    10056d <stab_binsearch+0xdb>
            *region_right = m - 1;
  100559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10055c:	8d 50 ff             	lea    -0x1(%eax),%edx
  10055f:	8b 45 10             	mov    0x10(%ebp),%eax
  100562:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100564:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100567:	48                   	dec    %eax
  100568:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10056b:	eb 11                	jmp    10057e <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10056d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100570:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100573:	89 10                	mov    %edx,(%eax)
            l = m;
  100575:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100578:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  10057b:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  10057e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100581:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  100584:	0f 8e 2a ff ff ff    	jle    1004b4 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  10058a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10058e:	75 0f                	jne    10059f <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  100590:	8b 45 0c             	mov    0xc(%ebp),%eax
  100593:	8b 00                	mov    (%eax),%eax
  100595:	8d 50 ff             	lea    -0x1(%eax),%edx
  100598:	8b 45 10             	mov    0x10(%ebp),%eax
  10059b:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10059d:	eb 3e                	jmp    1005dd <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  10059f:	8b 45 10             	mov    0x10(%ebp),%eax
  1005a2:	8b 00                	mov    (%eax),%eax
  1005a4:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005a7:	eb 03                	jmp    1005ac <stab_binsearch+0x11a>
  1005a9:	ff 4d fc             	decl   -0x4(%ebp)
  1005ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005af:	8b 00                	mov    (%eax),%eax
  1005b1:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005b4:	7d 1f                	jge    1005d5 <stab_binsearch+0x143>
  1005b6:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005b9:	89 d0                	mov    %edx,%eax
  1005bb:	01 c0                	add    %eax,%eax
  1005bd:	01 d0                	add    %edx,%eax
  1005bf:	c1 e0 02             	shl    $0x2,%eax
  1005c2:	89 c2                	mov    %eax,%edx
  1005c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005c7:	01 d0                	add    %edx,%eax
  1005c9:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005cd:	0f b6 c0             	movzbl %al,%eax
  1005d0:	3b 45 14             	cmp    0x14(%ebp),%eax
  1005d3:	75 d4                	jne    1005a9 <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
  1005d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005db:	89 10                	mov    %edx,(%eax)
    }
}
  1005dd:	90                   	nop
  1005de:	c9                   	leave  
  1005df:	c3                   	ret    

001005e0 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  1005e0:	55                   	push   %ebp
  1005e1:	89 e5                	mov    %esp,%ebp
  1005e3:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  1005e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e9:	c7 00 98 39 10 00    	movl   $0x103998,(%eax)
    info->eip_line = 0;
  1005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005f2:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  1005f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005fc:	c7 40 08 98 39 10 00 	movl   $0x103998,0x8(%eax)
    info->eip_fn_namelen = 9;
  100603:	8b 45 0c             	mov    0xc(%ebp),%eax
  100606:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10060d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100610:	8b 55 08             	mov    0x8(%ebp),%edx
  100613:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100616:	8b 45 0c             	mov    0xc(%ebp),%eax
  100619:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100620:	c7 45 f4 cc 41 10 00 	movl   $0x1041cc,-0xc(%ebp)
    stab_end = __STAB_END__;
  100627:	c7 45 f0 00 c2 10 00 	movl   $0x10c200,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10062e:	c7 45 ec 01 c2 10 00 	movl   $0x10c201,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100635:	c7 45 e8 f7 e2 10 00 	movl   $0x10e2f7,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10063c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10063f:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100642:	76 0b                	jbe    10064f <debuginfo_eip+0x6f>
  100644:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100647:	48                   	dec    %eax
  100648:	0f b6 00             	movzbl (%eax),%eax
  10064b:	84 c0                	test   %al,%al
  10064d:	74 0a                	je     100659 <debuginfo_eip+0x79>
        return -1;
  10064f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100654:	e9 b7 02 00 00       	jmp    100910 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  100659:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100663:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100666:	29 c2                	sub    %eax,%edx
  100668:	89 d0                	mov    %edx,%eax
  10066a:	c1 f8 02             	sar    $0x2,%eax
  10066d:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  100673:	48                   	dec    %eax
  100674:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  100677:	8b 45 08             	mov    0x8(%ebp),%eax
  10067a:	89 44 24 10          	mov    %eax,0x10(%esp)
  10067e:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  100685:	00 
  100686:	8d 45 e0             	lea    -0x20(%ebp),%eax
  100689:	89 44 24 08          	mov    %eax,0x8(%esp)
  10068d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  100690:	89 44 24 04          	mov    %eax,0x4(%esp)
  100694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100697:	89 04 24             	mov    %eax,(%esp)
  10069a:	e8 f3 fd ff ff       	call   100492 <stab_binsearch>
    if (lfile == 0)
  10069f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006a2:	85 c0                	test   %eax,%eax
  1006a4:	75 0a                	jne    1006b0 <debuginfo_eip+0xd0>
        return -1;
  1006a6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006ab:	e9 60 02 00 00       	jmp    100910 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1006bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006c3:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006ca:	00 
  1006cb:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006d2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1006d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006dc:	89 04 24             	mov    %eax,(%esp)
  1006df:	e8 ae fd ff ff       	call   100492 <stab_binsearch>

    if (lfun <= rfun) {
  1006e4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1006e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ea:	39 c2                	cmp    %eax,%edx
  1006ec:	7f 7c                	jg     10076a <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  1006ee:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006f1:	89 c2                	mov    %eax,%edx
  1006f3:	89 d0                	mov    %edx,%eax
  1006f5:	01 c0                	add    %eax,%eax
  1006f7:	01 d0                	add    %edx,%eax
  1006f9:	c1 e0 02             	shl    $0x2,%eax
  1006fc:	89 c2                	mov    %eax,%edx
  1006fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100701:	01 d0                	add    %edx,%eax
  100703:	8b 00                	mov    (%eax),%eax
  100705:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100708:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10070b:	29 d1                	sub    %edx,%ecx
  10070d:	89 ca                	mov    %ecx,%edx
  10070f:	39 d0                	cmp    %edx,%eax
  100711:	73 22                	jae    100735 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100713:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100716:	89 c2                	mov    %eax,%edx
  100718:	89 d0                	mov    %edx,%eax
  10071a:	01 c0                	add    %eax,%eax
  10071c:	01 d0                	add    %edx,%eax
  10071e:	c1 e0 02             	shl    $0x2,%eax
  100721:	89 c2                	mov    %eax,%edx
  100723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100726:	01 d0                	add    %edx,%eax
  100728:	8b 10                	mov    (%eax),%edx
  10072a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10072d:	01 c2                	add    %eax,%edx
  10072f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100732:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100735:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100738:	89 c2                	mov    %eax,%edx
  10073a:	89 d0                	mov    %edx,%eax
  10073c:	01 c0                	add    %eax,%eax
  10073e:	01 d0                	add    %edx,%eax
  100740:	c1 e0 02             	shl    $0x2,%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100748:	01 d0                	add    %edx,%eax
  10074a:	8b 50 08             	mov    0x8(%eax),%edx
  10074d:	8b 45 0c             	mov    0xc(%ebp),%eax
  100750:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100753:	8b 45 0c             	mov    0xc(%ebp),%eax
  100756:	8b 40 10             	mov    0x10(%eax),%eax
  100759:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10075c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10075f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100762:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100765:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100768:	eb 15                	jmp    10077f <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10076a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10076d:	8b 55 08             	mov    0x8(%ebp),%edx
  100770:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  100773:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100776:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  100779:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10077c:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  10077f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100782:	8b 40 08             	mov    0x8(%eax),%eax
  100785:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  10078c:	00 
  10078d:	89 04 24             	mov    %eax,(%esp)
  100790:	e8 79 27 00 00       	call   102f0e <strfind>
  100795:	89 c2                	mov    %eax,%edx
  100797:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079a:	8b 40 08             	mov    0x8(%eax),%eax
  10079d:	29 c2                	sub    %eax,%edx
  10079f:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007a2:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1007a8:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007ac:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007b3:	00 
  1007b4:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007bb:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007be:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007c5:	89 04 24             	mov    %eax,(%esp)
  1007c8:	e8 c5 fc ff ff       	call   100492 <stab_binsearch>
    if (lline <= rline) {
  1007cd:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007d3:	39 c2                	cmp    %eax,%edx
  1007d5:	7f 23                	jg     1007fa <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  1007d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1007da:	89 c2                	mov    %eax,%edx
  1007dc:	89 d0                	mov    %edx,%eax
  1007de:	01 c0                	add    %eax,%eax
  1007e0:	01 d0                	add    %edx,%eax
  1007e2:	c1 e0 02             	shl    $0x2,%eax
  1007e5:	89 c2                	mov    %eax,%edx
  1007e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ea:	01 d0                	add    %edx,%eax
  1007ec:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  1007f0:	89 c2                	mov    %eax,%edx
  1007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007f5:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  1007f8:	eb 11                	jmp    10080b <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  1007fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1007ff:	e9 0c 01 00 00       	jmp    100910 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100804:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100807:	48                   	dec    %eax
  100808:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10080b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10080e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100811:	39 c2                	cmp    %eax,%edx
  100813:	7c 56                	jl     10086b <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  100815:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100818:	89 c2                	mov    %eax,%edx
  10081a:	89 d0                	mov    %edx,%eax
  10081c:	01 c0                	add    %eax,%eax
  10081e:	01 d0                	add    %edx,%eax
  100820:	c1 e0 02             	shl    $0x2,%eax
  100823:	89 c2                	mov    %eax,%edx
  100825:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100828:	01 d0                	add    %edx,%eax
  10082a:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10082e:	3c 84                	cmp    $0x84,%al
  100830:	74 39                	je     10086b <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100832:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100835:	89 c2                	mov    %eax,%edx
  100837:	89 d0                	mov    %edx,%eax
  100839:	01 c0                	add    %eax,%eax
  10083b:	01 d0                	add    %edx,%eax
  10083d:	c1 e0 02             	shl    $0x2,%eax
  100840:	89 c2                	mov    %eax,%edx
  100842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100845:	01 d0                	add    %edx,%eax
  100847:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10084b:	3c 64                	cmp    $0x64,%al
  10084d:	75 b5                	jne    100804 <debuginfo_eip+0x224>
  10084f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100852:	89 c2                	mov    %eax,%edx
  100854:	89 d0                	mov    %edx,%eax
  100856:	01 c0                	add    %eax,%eax
  100858:	01 d0                	add    %edx,%eax
  10085a:	c1 e0 02             	shl    $0x2,%eax
  10085d:	89 c2                	mov    %eax,%edx
  10085f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100862:	01 d0                	add    %edx,%eax
  100864:	8b 40 08             	mov    0x8(%eax),%eax
  100867:	85 c0                	test   %eax,%eax
  100869:	74 99                	je     100804 <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10086b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10086e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100871:	39 c2                	cmp    %eax,%edx
  100873:	7c 46                	jl     1008bb <debuginfo_eip+0x2db>
  100875:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100878:	89 c2                	mov    %eax,%edx
  10087a:	89 d0                	mov    %edx,%eax
  10087c:	01 c0                	add    %eax,%eax
  10087e:	01 d0                	add    %edx,%eax
  100880:	c1 e0 02             	shl    $0x2,%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100888:	01 d0                	add    %edx,%eax
  10088a:	8b 00                	mov    (%eax),%eax
  10088c:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  10088f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100892:	29 d1                	sub    %edx,%ecx
  100894:	89 ca                	mov    %ecx,%edx
  100896:	39 d0                	cmp    %edx,%eax
  100898:	73 21                	jae    1008bb <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  10089a:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10089d:	89 c2                	mov    %eax,%edx
  10089f:	89 d0                	mov    %edx,%eax
  1008a1:	01 c0                	add    %eax,%eax
  1008a3:	01 d0                	add    %edx,%eax
  1008a5:	c1 e0 02             	shl    $0x2,%eax
  1008a8:	89 c2                	mov    %eax,%edx
  1008aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008ad:	01 d0                	add    %edx,%eax
  1008af:	8b 10                	mov    (%eax),%edx
  1008b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008b4:	01 c2                	add    %eax,%edx
  1008b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008b9:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008bb:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008be:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008c1:	39 c2                	cmp    %eax,%edx
  1008c3:	7d 46                	jge    10090b <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008c8:	40                   	inc    %eax
  1008c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008cc:	eb 16                	jmp    1008e4 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008d1:	8b 40 14             	mov    0x14(%eax),%eax
  1008d4:	8d 50 01             	lea    0x1(%eax),%edx
  1008d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008da:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  1008dd:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008e0:	40                   	inc    %eax
  1008e1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008e4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1008e7:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  1008ea:	39 c2                	cmp    %eax,%edx
  1008ec:	7d 1d                	jge    10090b <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  1008ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008f1:	89 c2                	mov    %eax,%edx
  1008f3:	89 d0                	mov    %edx,%eax
  1008f5:	01 c0                	add    %eax,%eax
  1008f7:	01 d0                	add    %edx,%eax
  1008f9:	c1 e0 02             	shl    $0x2,%eax
  1008fc:	89 c2                	mov    %eax,%edx
  1008fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100901:	01 d0                	add    %edx,%eax
  100903:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100907:	3c a0                	cmp    $0xa0,%al
  100909:	74 c3                	je     1008ce <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10090b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100910:	c9                   	leave  
  100911:	c3                   	ret    

00100912 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100912:	55                   	push   %ebp
  100913:	89 e5                	mov    %esp,%ebp
  100915:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100918:	c7 04 24 a2 39 10 00 	movl   $0x1039a2,(%esp)
  10091f:	e8 48 f9 ff ff       	call   10026c <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100924:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  10092b:	00 
  10092c:	c7 04 24 bb 39 10 00 	movl   $0x1039bb,(%esp)
  100933:	e8 34 f9 ff ff       	call   10026c <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100938:	c7 44 24 04 8c 38 10 	movl   $0x10388c,0x4(%esp)
  10093f:	00 
  100940:	c7 04 24 d3 39 10 00 	movl   $0x1039d3,(%esp)
  100947:	e8 20 f9 ff ff       	call   10026c <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10094c:	c7 44 24 04 16 fa 10 	movl   $0x10fa16,0x4(%esp)
  100953:	00 
  100954:	c7 04 24 eb 39 10 00 	movl   $0x1039eb,(%esp)
  10095b:	e8 0c f9 ff ff       	call   10026c <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100960:	c7 44 24 04 a0 0d 11 	movl   $0x110da0,0x4(%esp)
  100967:	00 
  100968:	c7 04 24 03 3a 10 00 	movl   $0x103a03,(%esp)
  10096f:	e8 f8 f8 ff ff       	call   10026c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  100974:	b8 a0 0d 11 00       	mov    $0x110da0,%eax
  100979:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10097f:	b8 00 00 10 00       	mov    $0x100000,%eax
  100984:	29 c2                	sub    %eax,%edx
  100986:	89 d0                	mov    %edx,%eax
  100988:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  10098e:	85 c0                	test   %eax,%eax
  100990:	0f 48 c2             	cmovs  %edx,%eax
  100993:	c1 f8 0a             	sar    $0xa,%eax
  100996:	89 44 24 04          	mov    %eax,0x4(%esp)
  10099a:	c7 04 24 1c 3a 10 00 	movl   $0x103a1c,(%esp)
  1009a1:	e8 c6 f8 ff ff       	call   10026c <cprintf>
}
  1009a6:	90                   	nop
  1009a7:	c9                   	leave  
  1009a8:	c3                   	ret    

001009a9 <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009a9:	55                   	push   %ebp
  1009aa:	89 e5                	mov    %esp,%ebp
  1009ac:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009b2:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1009bc:	89 04 24             	mov    %eax,(%esp)
  1009bf:	e8 1c fc ff ff       	call   1005e0 <debuginfo_eip>
  1009c4:	85 c0                	test   %eax,%eax
  1009c6:	74 15                	je     1009dd <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  1009cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009cf:	c7 04 24 46 3a 10 00 	movl   $0x103a46,(%esp)
  1009d6:	e8 91 f8 ff ff       	call   10026c <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  1009db:	eb 6c                	jmp    100a49 <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1009e4:	eb 1b                	jmp    100a01 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  1009e6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1009e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009ec:	01 d0                	add    %edx,%eax
  1009ee:	0f b6 00             	movzbl (%eax),%eax
  1009f1:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  1009f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1009fa:	01 ca                	add    %ecx,%edx
  1009fc:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  1009fe:	ff 45 f4             	incl   -0xc(%ebp)
  100a01:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a04:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a07:	7f dd                	jg     1009e6 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a09:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a12:	01 d0                	add    %edx,%eax
  100a14:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a17:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  100a1d:	89 d1                	mov    %edx,%ecx
  100a1f:	29 c1                	sub    %eax,%ecx
  100a21:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a24:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a27:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a2b:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a31:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a35:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a3d:	c7 04 24 62 3a 10 00 	movl   $0x103a62,(%esp)
  100a44:	e8 23 f8 ff ff       	call   10026c <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  100a49:	90                   	nop
  100a4a:	c9                   	leave  
  100a4b:	c3                   	ret    

00100a4c <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a4c:	55                   	push   %ebp
  100a4d:	89 e5                	mov    %esp,%ebp
  100a4f:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a52:	8b 45 04             	mov    0x4(%ebp),%eax
  100a55:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a58:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a5b:	c9                   	leave  
  100a5c:	c3                   	ret    

00100a5d <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a5d:	55                   	push   %ebp
  100a5e:	89 e5                	mov    %esp,%ebp
  100a60:	83 ec 48             	sub    $0x48,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a63:	89 e8                	mov    %ebp,%eax
  100a65:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ebp;
  100a68:	8b 45 d8             	mov    -0x28(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
  100a6b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  100a6e:	e8 d9 ff ff ff       	call   100a4c <read_eip>
  100a73:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
  100a76:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100a7d:	e9 9b 00 00 00       	jmp    100b1d <print_stackframe+0xc0>
        cprintf("ebp:0x%08x eip:0x%08x ",ebp,eip);
  100a82:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a85:	89 44 24 08          	mov    %eax,0x8(%esp)
  100a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a90:	c7 04 24 74 3a 10 00 	movl   $0x103a74,(%esp)
  100a97:	e8 d0 f7 ff ff       	call   10026c <cprintf>
        arg0 = *((uint32_t *)ebp + 2);
  100a9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a9f:	83 c0 08             	add    $0x8,%eax
  100aa2:	8b 00                	mov    (%eax),%eax
  100aa4:	89 45 e8             	mov    %eax,-0x18(%ebp)
        arg1 = *((uint32_t *)ebp + 3);
  100aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100aaa:	83 c0 0c             	add    $0xc,%eax
  100aad:	8b 00                	mov    (%eax),%eax
  100aaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        arg2 = *((uint32_t *)ebp + 4);
  100ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ab5:	83 c0 10             	add    $0x10,%eax
  100ab8:	8b 00                	mov    (%eax),%eax
  100aba:	89 45 e0             	mov    %eax,-0x20(%ebp)
        arg3 = *((uint32_t *)ebp + 5);
  100abd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ac0:	83 c0 14             	add    $0x14,%eax
  100ac3:	8b 00                	mov    (%eax),%eax
  100ac5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x",arg0,arg1,arg2,arg3);
  100ac8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100acb:	89 44 24 10          	mov    %eax,0x10(%esp)
  100acf:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100ad2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100ad6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100ad9:	89 44 24 08          	mov    %eax,0x8(%esp)
  100add:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100ae0:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ae4:	c7 04 24 8c 3a 10 00 	movl   $0x103a8c,(%esp)
  100aeb:	e8 7c f7 ff ff       	call   10026c <cprintf>
        cprintf("\n");
  100af0:	c7 04 24 ad 3a 10 00 	movl   $0x103aad,(%esp)
  100af7:	e8 70 f7 ff ff       	call   10026c <cprintf>
        print_debuginfo(eip);
  100afc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100aff:	89 04 24             	mov    %eax,(%esp)
  100b02:	e8 a2 fe ff ff       	call   1009a9 <print_debuginfo>
        eip = *((uint32_t *)ebp + 1);
  100b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b0a:	83 c0 04             	add    $0x4,%eax
  100b0d:	8b 00                	mov    (%eax),%eax
  100b0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = *((uint32_t *)ebp);
  100b12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b15:	8b 00                	mov    (%eax),%eax
  100b17:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
  100b1a:	ff 45 ec             	incl   -0x14(%ebp)
  100b1d:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b21:	7f 0a                	jg     100b2d <print_stackframe+0xd0>
  100b23:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b27:	0f 85 55 ff ff ff    	jne    100a82 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip);
        eip = *((uint32_t *)ebp + 1);
        ebp = *((uint32_t *)ebp);
    }
}
  100b2d:	90                   	nop
  100b2e:	c9                   	leave  
  100b2f:	c3                   	ret    

00100b30 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b30:	55                   	push   %ebp
  100b31:	89 e5                	mov    %esp,%ebp
  100b33:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b3d:	eb 0c                	jmp    100b4b <parse+0x1b>
            *buf ++ = '\0';
  100b3f:	8b 45 08             	mov    0x8(%ebp),%eax
  100b42:	8d 50 01             	lea    0x1(%eax),%edx
  100b45:	89 55 08             	mov    %edx,0x8(%ebp)
  100b48:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b4b:	8b 45 08             	mov    0x8(%ebp),%eax
  100b4e:	0f b6 00             	movzbl (%eax),%eax
  100b51:	84 c0                	test   %al,%al
  100b53:	74 1d                	je     100b72 <parse+0x42>
  100b55:	8b 45 08             	mov    0x8(%ebp),%eax
  100b58:	0f b6 00             	movzbl (%eax),%eax
  100b5b:	0f be c0             	movsbl %al,%eax
  100b5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b62:	c7 04 24 30 3b 10 00 	movl   $0x103b30,(%esp)
  100b69:	e8 6e 23 00 00       	call   102edc <strchr>
  100b6e:	85 c0                	test   %eax,%eax
  100b70:	75 cd                	jne    100b3f <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100b72:	8b 45 08             	mov    0x8(%ebp),%eax
  100b75:	0f b6 00             	movzbl (%eax),%eax
  100b78:	84 c0                	test   %al,%al
  100b7a:	74 69                	je     100be5 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100b7c:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100b80:	75 14                	jne    100b96 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100b82:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100b89:	00 
  100b8a:	c7 04 24 35 3b 10 00 	movl   $0x103b35,(%esp)
  100b91:	e8 d6 f6 ff ff       	call   10026c <cprintf>
        }
        argv[argc ++] = buf;
  100b96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b99:	8d 50 01             	lea    0x1(%eax),%edx
  100b9c:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100b9f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  100ba9:	01 c2                	add    %eax,%edx
  100bab:	8b 45 08             	mov    0x8(%ebp),%eax
  100bae:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bb0:	eb 03                	jmp    100bb5 <parse+0x85>
            buf ++;
  100bb2:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  100bb8:	0f b6 00             	movzbl (%eax),%eax
  100bbb:	84 c0                	test   %al,%al
  100bbd:	0f 84 7a ff ff ff    	je     100b3d <parse+0xd>
  100bc3:	8b 45 08             	mov    0x8(%ebp),%eax
  100bc6:	0f b6 00             	movzbl (%eax),%eax
  100bc9:	0f be c0             	movsbl %al,%eax
  100bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bd0:	c7 04 24 30 3b 10 00 	movl   $0x103b30,(%esp)
  100bd7:	e8 00 23 00 00       	call   102edc <strchr>
  100bdc:	85 c0                	test   %eax,%eax
  100bde:	74 d2                	je     100bb2 <parse+0x82>
            buf ++;
        }
    }
  100be0:	e9 58 ff ff ff       	jmp    100b3d <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100be5:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100be6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100be9:	c9                   	leave  
  100bea:	c3                   	ret    

00100beb <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100beb:	55                   	push   %ebp
  100bec:	89 e5                	mov    %esp,%ebp
  100bee:	53                   	push   %ebx
  100bef:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100bf2:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bf9:	8b 45 08             	mov    0x8(%ebp),%eax
  100bfc:	89 04 24             	mov    %eax,(%esp)
  100bff:	e8 2c ff ff ff       	call   100b30 <parse>
  100c04:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c07:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c0b:	75 0a                	jne    100c17 <runcmd+0x2c>
        return 0;
  100c0d:	b8 00 00 00 00       	mov    $0x0,%eax
  100c12:	e9 83 00 00 00       	jmp    100c9a <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c17:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c1e:	eb 5a                	jmp    100c7a <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c20:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c26:	89 d0                	mov    %edx,%eax
  100c28:	01 c0                	add    %eax,%eax
  100c2a:	01 d0                	add    %edx,%eax
  100c2c:	c1 e0 02             	shl    $0x2,%eax
  100c2f:	05 00 f0 10 00       	add    $0x10f000,%eax
  100c34:	8b 00                	mov    (%eax),%eax
  100c36:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c3a:	89 04 24             	mov    %eax,(%esp)
  100c3d:	e8 fd 21 00 00       	call   102e3f <strcmp>
  100c42:	85 c0                	test   %eax,%eax
  100c44:	75 31                	jne    100c77 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c46:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c49:	89 d0                	mov    %edx,%eax
  100c4b:	01 c0                	add    %eax,%eax
  100c4d:	01 d0                	add    %edx,%eax
  100c4f:	c1 e0 02             	shl    $0x2,%eax
  100c52:	05 08 f0 10 00       	add    $0x10f008,%eax
  100c57:	8b 10                	mov    (%eax),%edx
  100c59:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c5c:	83 c0 04             	add    $0x4,%eax
  100c5f:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c62:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c70:	89 1c 24             	mov    %ebx,(%esp)
  100c73:	ff d2                	call   *%edx
  100c75:	eb 23                	jmp    100c9a <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c77:	ff 45 f4             	incl   -0xc(%ebp)
  100c7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c7d:	83 f8 02             	cmp    $0x2,%eax
  100c80:	76 9e                	jbe    100c20 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100c82:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100c85:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c89:	c7 04 24 53 3b 10 00 	movl   $0x103b53,(%esp)
  100c90:	e8 d7 f5 ff ff       	call   10026c <cprintf>
    return 0;
  100c95:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100c9a:	83 c4 64             	add    $0x64,%esp
  100c9d:	5b                   	pop    %ebx
  100c9e:	5d                   	pop    %ebp
  100c9f:	c3                   	ret    

00100ca0 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100ca0:	55                   	push   %ebp
  100ca1:	89 e5                	mov    %esp,%ebp
  100ca3:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100ca6:	c7 04 24 6c 3b 10 00 	movl   $0x103b6c,(%esp)
  100cad:	e8 ba f5 ff ff       	call   10026c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100cb2:	c7 04 24 94 3b 10 00 	movl   $0x103b94,(%esp)
  100cb9:	e8 ae f5 ff ff       	call   10026c <cprintf>

    if (tf != NULL) {
  100cbe:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cc2:	74 0b                	je     100ccf <kmonitor+0x2f>
        print_trapframe(tf);
  100cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  100cc7:	89 04 24             	mov    %eax,(%esp)
  100cca:	e8 37 0e 00 00       	call   101b06 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100ccf:	c7 04 24 b9 3b 10 00 	movl   $0x103bb9,(%esp)
  100cd6:	e8 33 f6 ff ff       	call   10030e <readline>
  100cdb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100cde:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100ce2:	74 eb                	je     100ccf <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  100ce7:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cee:	89 04 24             	mov    %eax,(%esp)
  100cf1:	e8 f5 fe ff ff       	call   100beb <runcmd>
  100cf6:	85 c0                	test   %eax,%eax
  100cf8:	78 02                	js     100cfc <kmonitor+0x5c>
                break;
            }
        }
    }
  100cfa:	eb d3                	jmp    100ccf <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100cfc:	90                   	nop
            }
        }
    }
}
  100cfd:	90                   	nop
  100cfe:	c9                   	leave  
  100cff:	c3                   	ret    

00100d00 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d00:	55                   	push   %ebp
  100d01:	89 e5                	mov    %esp,%ebp
  100d03:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d06:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d0d:	eb 3d                	jmp    100d4c <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d0f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d12:	89 d0                	mov    %edx,%eax
  100d14:	01 c0                	add    %eax,%eax
  100d16:	01 d0                	add    %edx,%eax
  100d18:	c1 e0 02             	shl    $0x2,%eax
  100d1b:	05 04 f0 10 00       	add    $0x10f004,%eax
  100d20:	8b 08                	mov    (%eax),%ecx
  100d22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d25:	89 d0                	mov    %edx,%eax
  100d27:	01 c0                	add    %eax,%eax
  100d29:	01 d0                	add    %edx,%eax
  100d2b:	c1 e0 02             	shl    $0x2,%eax
  100d2e:	05 00 f0 10 00       	add    $0x10f000,%eax
  100d33:	8b 00                	mov    (%eax),%eax
  100d35:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d39:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d3d:	c7 04 24 bd 3b 10 00 	movl   $0x103bbd,(%esp)
  100d44:	e8 23 f5 ff ff       	call   10026c <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d49:	ff 45 f4             	incl   -0xc(%ebp)
  100d4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d4f:	83 f8 02             	cmp    $0x2,%eax
  100d52:	76 bb                	jbe    100d0f <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d59:	c9                   	leave  
  100d5a:	c3                   	ret    

00100d5b <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d5b:	55                   	push   %ebp
  100d5c:	89 e5                	mov    %esp,%ebp
  100d5e:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d61:	e8 ac fb ff ff       	call   100912 <print_kerninfo>
    return 0;
  100d66:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d6b:	c9                   	leave  
  100d6c:	c3                   	ret    

00100d6d <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d6d:	55                   	push   %ebp
  100d6e:	89 e5                	mov    %esp,%ebp
  100d70:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100d73:	e8 e5 fc ff ff       	call   100a5d <print_stackframe>
    return 0;
  100d78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d7d:	c9                   	leave  
  100d7e:	c3                   	ret    

00100d7f <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100d7f:	55                   	push   %ebp
  100d80:	89 e5                	mov    %esp,%ebp
  100d82:	83 ec 28             	sub    $0x28,%esp
  100d85:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100d8b:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100d8f:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100d93:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100d97:	ee                   	out    %al,(%dx)
  100d98:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100d9e:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100da2:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100da6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100da9:	ee                   	out    %al,(%dx)
  100daa:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100db0:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100db4:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100db8:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100dbc:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dbd:	c7 05 28 09 11 00 00 	movl   $0x0,0x110928
  100dc4:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100dc7:	c7 04 24 c6 3b 10 00 	movl   $0x103bc6,(%esp)
  100dce:	e8 99 f4 ff ff       	call   10026c <cprintf>
    pic_enable(IRQ_TIMER);
  100dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100dda:	e8 ba 08 00 00       	call   101699 <pic_enable>
}
  100ddf:	90                   	nop
  100de0:	c9                   	leave  
  100de1:	c3                   	ret    

00100de2 <delay>:
#include <picirq.h>
#include <trap.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100de2:	55                   	push   %ebp
  100de3:	89 e5                	mov    %esp,%ebp
  100de5:	83 ec 10             	sub    $0x10,%esp
  100de8:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100dee:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100df2:	89 c2                	mov    %eax,%edx
  100df4:	ec                   	in     (%dx),%al
  100df5:	88 45 f4             	mov    %al,-0xc(%ebp)
  100df8:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100dfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e01:	89 c2                	mov    %eax,%edx
  100e03:	ec                   	in     (%dx),%al
  100e04:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e07:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e0d:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e11:	89 c2                	mov    %eax,%edx
  100e13:	ec                   	in     (%dx),%al
  100e14:	88 45 f6             	mov    %al,-0xa(%ebp)
  100e17:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e1d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100e20:	89 c2                	mov    %eax,%edx
  100e22:	ec                   	in     (%dx),%al
  100e23:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e26:	90                   	nop
  100e27:	c9                   	leave  
  100e28:	c3                   	ret    

00100e29 <cga_init>:
//    -- 数据寄存器 映射 到 端口 0x3D5或0x3B5 
//    -- 索引寄存器 0x3D4或0x3B4,决定在数据寄存器中的数据表示什么。

/* TEXT-mode CGA/VGA display output */
static void
cga_init(void) {
  100e29:	55                   	push   %ebp
  100e2a:	89 e5                	mov    %esp,%ebp
  100e2c:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)CGA_BUF;   //CGA_BUF: 0xB8000 (彩色显示的显存物理基址)
  100e2f:	c7 45 fc 00 80 0b 00 	movl   $0xb8000,-0x4(%ebp)
    uint16_t was = *cp;                                            //保存当前显存0xB8000处的值
  100e36:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e39:	0f b7 00             	movzwl (%eax),%eax
  100e3c:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;                                   // 给这个地址随便写个值，看看能否再读出同样的值
  100e40:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e43:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {                                            // 如果读不出来，说明没有这块显存，即是单显配置
  100e48:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e4b:	0f b7 00             	movzwl (%eax),%eax
  100e4e:	0f b7 c0             	movzwl %ax,%eax
  100e51:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100e56:	74 12                	je     100e6a <cga_init+0x41>
        cp = (uint16_t*)MONO_BUF;                         //设置为单显的显存基址 MONO_BUF： 0xB0000
  100e58:	c7 45 fc 00 00 0b 00 	movl   $0xb0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;                           //设置为单显控制的IO地址，MONO_BASE: 0x3B4
  100e5f:	66 c7 05 66 fe 10 00 	movw   $0x3b4,0x10fe66
  100e66:	b4 03 
  100e68:	eb 13                	jmp    100e7d <cga_init+0x54>
    } else {                                                                // 如果读出来了，有这块显存，即是彩显配置
        *cp = was;                                                      //还原原来显存位置的值
  100e6a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e6d:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100e71:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;                               // 设置为彩显控制的IO地址，CGA_BASE: 0x3D4 
  100e74:	66 c7 05 66 fe 10 00 	movw   $0x3d4,0x10fe66
  100e7b:	d4 03 
    // Extract cursor location
    // 6845索引寄存器的index 0x0E（及十进制的14）== 光标位置(高位)
    // 6845索引寄存器的index 0x0F（及十进制的15）== 光标位置(低位)
    // 6845 reg 15 : Cursor Address (Low Byte)
    uint32_t pos;
    outb(addr_6845, 14);                                        
  100e7d:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100e84:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100e88:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100e8c:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100e90:	8b 55 f8             	mov    -0x8(%ebp),%edx
  100e93:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;                       //读出了光标位置(高位)
  100e94:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100e9b:	40                   	inc    %eax
  100e9c:	0f b7 c0             	movzwl %ax,%eax
  100e9f:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ea3:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100ea7:	89 c2                	mov    %eax,%edx
  100ea9:	ec                   	in     (%dx),%al
  100eaa:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100ead:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100eb1:	0f b6 c0             	movzbl %al,%eax
  100eb4:	c1 e0 08             	shl    $0x8,%eax
  100eb7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100eba:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ec1:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100ec5:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100ec9:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100ecd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100ed0:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);                             //读出了光标位置(低位)
  100ed1:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  100ed8:	40                   	inc    %eax
  100ed9:	0f b7 c0             	movzwl %ax,%eax
  100edc:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100ee0:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100ee4:	89 c2                	mov    %eax,%edx
  100ee6:	ec                   	in     (%dx),%al
  100ee7:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100eea:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100eee:	0f b6 c0             	movzbl %al,%eax
  100ef1:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;                                  //crt_buf是CGA显存起始地址
  100ef4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ef7:	a3 60 fe 10 00       	mov    %eax,0x10fe60
    crt_pos = pos;                                                  //crt_pos是CGA当前光标位置
  100efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100eff:	0f b7 c0             	movzwl %ax,%eax
  100f02:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
}
  100f08:	90                   	nop
  100f09:	c9                   	leave  
  100f0a:	c3                   	ret    

00100f0b <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f0b:	55                   	push   %ebp
  100f0c:	89 e5                	mov    %esp,%ebp
  100f0e:	83 ec 38             	sub    $0x38,%esp
  100f11:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f17:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  100f1b:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f1f:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f23:	ee                   	out    %al,(%dx)
  100f24:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f2a:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f2e:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100f32:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100f35:	ee                   	out    %al,(%dx)
  100f36:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100f3c:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100f40:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100f44:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100f48:	ee                   	out    %al,(%dx)
  100f49:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100f4f:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100f53:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100f57:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100f5a:	ee                   	out    %al,(%dx)
  100f5b:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100f61:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100f65:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100f69:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f6d:	ee                   	out    %al,(%dx)
  100f6e:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100f74:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100f78:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100f7c:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100f7f:	ee                   	out    %al,(%dx)
  100f80:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100f86:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100f8a:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100f8e:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  100f92:	ee                   	out    %al,(%dx)
  100f93:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100f99:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100f9c:	89 c2                	mov    %eax,%edx
  100f9e:	ec                   	in     (%dx),%al
  100f9f:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  100fa2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  100fa6:	3c ff                	cmp    $0xff,%al
  100fa8:	0f 95 c0             	setne  %al
  100fab:	0f b6 c0             	movzbl %al,%eax
  100fae:	a3 68 fe 10 00       	mov    %eax,0x10fe68
  100fb3:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  100fb9:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  100fbd:	89 c2                	mov    %eax,%edx
  100fbf:	ec                   	in     (%dx),%al
  100fc0:	88 45 e2             	mov    %al,-0x1e(%ebp)
  100fc3:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  100fc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100fcc:	89 c2                	mov    %eax,%edx
  100fce:	ec                   	in     (%dx),%al
  100fcf:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  100fd2:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  100fd7:	85 c0                	test   %eax,%eax
  100fd9:	74 0c                	je     100fe7 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
  100fdb:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  100fe2:	e8 b2 06 00 00       	call   101699 <pic_enable>
    }
}
  100fe7:	90                   	nop
  100fe8:	c9                   	leave  
  100fe9:	c3                   	ret    

00100fea <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  100fea:	55                   	push   %ebp
  100feb:	89 e5                	mov    %esp,%ebp
  100fed:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ff0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  100ff7:	eb 08                	jmp    101001 <lpt_putc_sub+0x17>
        delay();
  100ff9:	e8 e4 fd ff ff       	call   100de2 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  100ffe:	ff 45 fc             	incl   -0x4(%ebp)
  101001:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  101007:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10100a:	89 c2                	mov    %eax,%edx
  10100c:	ec                   	in     (%dx),%al
  10100d:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  101010:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101014:	84 c0                	test   %al,%al
  101016:	78 09                	js     101021 <lpt_putc_sub+0x37>
  101018:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10101f:	7e d8                	jle    100ff9 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101021:	8b 45 08             	mov    0x8(%ebp),%eax
  101024:	0f b6 c0             	movzbl %al,%eax
  101027:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  10102d:	88 45 f0             	mov    %al,-0x10(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101030:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  101034:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101037:	ee                   	out    %al,(%dx)
  101038:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  10103e:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  101042:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  101046:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10104a:	ee                   	out    %al,(%dx)
  10104b:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  101051:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  101055:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  101059:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10105d:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  10105e:	90                   	nop
  10105f:	c9                   	leave  
  101060:	c3                   	ret    

00101061 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101061:	55                   	push   %ebp
  101062:	89 e5                	mov    %esp,%ebp
  101064:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101067:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10106b:	74 0d                	je     10107a <lpt_putc+0x19>
        lpt_putc_sub(c);
  10106d:	8b 45 08             	mov    0x8(%ebp),%eax
  101070:	89 04 24             	mov    %eax,(%esp)
  101073:	e8 72 ff ff ff       	call   100fea <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101078:	eb 24                	jmp    10109e <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  10107a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101081:	e8 64 ff ff ff       	call   100fea <lpt_putc_sub>
        lpt_putc_sub(' ');
  101086:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10108d:	e8 58 ff ff ff       	call   100fea <lpt_putc_sub>
        lpt_putc_sub('\b');
  101092:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101099:	e8 4c ff ff ff       	call   100fea <lpt_putc_sub>
    }
}
  10109e:	90                   	nop
  10109f:	c9                   	leave  
  1010a0:	c3                   	ret    

001010a1 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  1010a1:	55                   	push   %ebp
  1010a2:	89 e5                	mov    %esp,%ebp
  1010a4:	53                   	push   %ebx
  1010a5:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  1010a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1010ab:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1010b0:	85 c0                	test   %eax,%eax
  1010b2:	75 07                	jne    1010bb <cga_putc+0x1a>
        c |= 0x0700;
  1010b4:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  1010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1010be:	0f b6 c0             	movzbl %al,%eax
  1010c1:	83 f8 0a             	cmp    $0xa,%eax
  1010c4:	74 54                	je     10111a <cga_putc+0x79>
  1010c6:	83 f8 0d             	cmp    $0xd,%eax
  1010c9:	74 62                	je     10112d <cga_putc+0x8c>
  1010cb:	83 f8 08             	cmp    $0x8,%eax
  1010ce:	0f 85 93 00 00 00    	jne    101167 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
  1010d4:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1010db:	85 c0                	test   %eax,%eax
  1010dd:	0f 84 ae 00 00 00    	je     101191 <cga_putc+0xf0>
            crt_pos --;
  1010e3:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1010ea:	48                   	dec    %eax
  1010eb:	0f b7 c0             	movzwl %ax,%eax
  1010ee:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1010f4:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1010f9:	0f b7 15 64 fe 10 00 	movzwl 0x10fe64,%edx
  101100:	01 d2                	add    %edx,%edx
  101102:	01 c2                	add    %eax,%edx
  101104:	8b 45 08             	mov    0x8(%ebp),%eax
  101107:	98                   	cwtl   
  101108:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10110d:	98                   	cwtl   
  10110e:	83 c8 20             	or     $0x20,%eax
  101111:	98                   	cwtl   
  101112:	0f b7 c0             	movzwl %ax,%eax
  101115:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101118:	eb 77                	jmp    101191 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
  10111a:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101121:	83 c0 50             	add    $0x50,%eax
  101124:	0f b7 c0             	movzwl %ax,%eax
  101127:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10112d:	0f b7 1d 64 fe 10 00 	movzwl 0x10fe64,%ebx
  101134:	0f b7 0d 64 fe 10 00 	movzwl 0x10fe64,%ecx
  10113b:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  101140:	89 c8                	mov    %ecx,%eax
  101142:	f7 e2                	mul    %edx
  101144:	c1 ea 06             	shr    $0x6,%edx
  101147:	89 d0                	mov    %edx,%eax
  101149:	c1 e0 02             	shl    $0x2,%eax
  10114c:	01 d0                	add    %edx,%eax
  10114e:	c1 e0 04             	shl    $0x4,%eax
  101151:	29 c1                	sub    %eax,%ecx
  101153:	89 c8                	mov    %ecx,%eax
  101155:	0f b7 c0             	movzwl %ax,%eax
  101158:	29 c3                	sub    %eax,%ebx
  10115a:	89 d8                	mov    %ebx,%eax
  10115c:	0f b7 c0             	movzwl %ax,%eax
  10115f:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
        break;
  101165:	eb 2b                	jmp    101192 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101167:	8b 0d 60 fe 10 00    	mov    0x10fe60,%ecx
  10116d:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101174:	8d 50 01             	lea    0x1(%eax),%edx
  101177:	0f b7 d2             	movzwl %dx,%edx
  10117a:	66 89 15 64 fe 10 00 	mov    %dx,0x10fe64
  101181:	01 c0                	add    %eax,%eax
  101183:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101186:	8b 45 08             	mov    0x8(%ebp),%eax
  101189:	0f b7 c0             	movzwl %ax,%eax
  10118c:	66 89 02             	mov    %ax,(%edx)
        break;
  10118f:	eb 01                	jmp    101192 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  101191:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101192:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  101199:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  10119e:	76 5d                	jbe    1011fd <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  1011a0:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1011a5:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  1011ab:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1011b0:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  1011b7:	00 
  1011b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  1011bc:	89 04 24             	mov    %eax,(%esp)
  1011bf:	e8 0e 1f 00 00       	call   1030d2 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011c4:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  1011cb:	eb 14                	jmp    1011e1 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  1011cd:	a1 60 fe 10 00       	mov    0x10fe60,%eax
  1011d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1011d5:	01 d2                	add    %edx,%edx
  1011d7:	01 d0                	add    %edx,%eax
  1011d9:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  1011de:	ff 45 f4             	incl   -0xc(%ebp)
  1011e1:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  1011e8:	7e e3                	jle    1011cd <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  1011ea:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  1011f1:	83 e8 50             	sub    $0x50,%eax
  1011f4:	0f b7 c0             	movzwl %ax,%eax
  1011f7:	66 a3 64 fe 10 00    	mov    %ax,0x10fe64
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1011fd:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  101204:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101208:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  10120c:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  101210:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101214:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101215:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10121c:	c1 e8 08             	shr    $0x8,%eax
  10121f:	0f b7 c0             	movzwl %ax,%eax
  101222:	0f b6 c0             	movzbl %al,%eax
  101225:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  10122c:	42                   	inc    %edx
  10122d:	0f b7 d2             	movzwl %dx,%edx
  101230:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  101234:	88 45 e9             	mov    %al,-0x17(%ebp)
  101237:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  10123b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10123e:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  10123f:	0f b7 05 66 fe 10 00 	movzwl 0x10fe66,%eax
  101246:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  10124a:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  10124e:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  101252:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101256:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  101257:	0f b7 05 64 fe 10 00 	movzwl 0x10fe64,%eax
  10125e:	0f b6 c0             	movzbl %al,%eax
  101261:	0f b7 15 66 fe 10 00 	movzwl 0x10fe66,%edx
  101268:	42                   	inc    %edx
  101269:	0f b7 d2             	movzwl %dx,%edx
  10126c:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  101270:	88 45 eb             	mov    %al,-0x15(%ebp)
  101273:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  101277:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10127a:	ee                   	out    %al,(%dx)
}
  10127b:	90                   	nop
  10127c:	83 c4 24             	add    $0x24,%esp
  10127f:	5b                   	pop    %ebx
  101280:	5d                   	pop    %ebp
  101281:	c3                   	ret    

00101282 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101282:	55                   	push   %ebp
  101283:	89 e5                	mov    %esp,%ebp
  101285:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101288:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  10128f:	eb 08                	jmp    101299 <serial_putc_sub+0x17>
        delay();
  101291:	e8 4c fb ff ff       	call   100de2 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101296:	ff 45 fc             	incl   -0x4(%ebp)
  101299:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10129f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1012a2:	89 c2                	mov    %eax,%edx
  1012a4:	ec                   	in     (%dx),%al
  1012a5:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1012a8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1012ac:	0f b6 c0             	movzbl %al,%eax
  1012af:	83 e0 20             	and    $0x20,%eax
  1012b2:	85 c0                	test   %eax,%eax
  1012b4:	75 09                	jne    1012bf <serial_putc_sub+0x3d>
  1012b6:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1012bd:	7e d2                	jle    101291 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  1012bf:	8b 45 08             	mov    0x8(%ebp),%eax
  1012c2:	0f b6 c0             	movzbl %al,%eax
  1012c5:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  1012cb:	88 45 f6             	mov    %al,-0xa(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  1012ce:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  1012d2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1012d6:	ee                   	out    %al,(%dx)
}
  1012d7:	90                   	nop
  1012d8:	c9                   	leave  
  1012d9:	c3                   	ret    

001012da <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  1012da:	55                   	push   %ebp
  1012db:	89 e5                	mov    %esp,%ebp
  1012dd:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1012e0:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1012e4:	74 0d                	je     1012f3 <serial_putc+0x19>
        serial_putc_sub(c);
  1012e6:	8b 45 08             	mov    0x8(%ebp),%eax
  1012e9:	89 04 24             	mov    %eax,(%esp)
  1012ec:	e8 91 ff ff ff       	call   101282 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1012f1:	eb 24                	jmp    101317 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  1012f3:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1012fa:	e8 83 ff ff ff       	call   101282 <serial_putc_sub>
        serial_putc_sub(' ');
  1012ff:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101306:	e8 77 ff ff ff       	call   101282 <serial_putc_sub>
        serial_putc_sub('\b');
  10130b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101312:	e8 6b ff ff ff       	call   101282 <serial_putc_sub>
    }
}
  101317:	90                   	nop
  101318:	c9                   	leave  
  101319:	c3                   	ret    

0010131a <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  10131a:	55                   	push   %ebp
  10131b:	89 e5                	mov    %esp,%ebp
  10131d:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  101320:	eb 33                	jmp    101355 <cons_intr+0x3b>
        if (c != 0) {
  101322:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101326:	74 2d                	je     101355 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101328:	a1 84 00 11 00       	mov    0x110084,%eax
  10132d:	8d 50 01             	lea    0x1(%eax),%edx
  101330:	89 15 84 00 11 00    	mov    %edx,0x110084
  101336:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101339:	88 90 80 fe 10 00    	mov    %dl,0x10fe80(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  10133f:	a1 84 00 11 00       	mov    0x110084,%eax
  101344:	3d 00 02 00 00       	cmp    $0x200,%eax
  101349:	75 0a                	jne    101355 <cons_intr+0x3b>
                cons.wpos = 0;
  10134b:	c7 05 84 00 11 00 00 	movl   $0x0,0x110084
  101352:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  101355:	8b 45 08             	mov    0x8(%ebp),%eax
  101358:	ff d0                	call   *%eax
  10135a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10135d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  101361:	75 bf                	jne    101322 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  101363:	90                   	nop
  101364:	c9                   	leave  
  101365:	c3                   	ret    

00101366 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101366:	55                   	push   %ebp
  101367:	89 e5                	mov    %esp,%ebp
  101369:	83 ec 10             	sub    $0x10,%esp
  10136c:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101372:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101375:	89 c2                	mov    %eax,%edx
  101377:	ec                   	in     (%dx),%al
  101378:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  10137b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  10137f:	0f b6 c0             	movzbl %al,%eax
  101382:	83 e0 01             	and    $0x1,%eax
  101385:	85 c0                	test   %eax,%eax
  101387:	75 07                	jne    101390 <serial_proc_data+0x2a>
        return -1;
  101389:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10138e:	eb 2a                	jmp    1013ba <serial_proc_data+0x54>
  101390:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  101396:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10139a:	89 c2                	mov    %eax,%edx
  10139c:	ec                   	in     (%dx),%al
  10139d:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  1013a0:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  1013a4:	0f b6 c0             	movzbl %al,%eax
  1013a7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  1013aa:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  1013ae:	75 07                	jne    1013b7 <serial_proc_data+0x51>
        c = '\b';
  1013b0:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  1013b7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1013ba:	c9                   	leave  
  1013bb:	c3                   	ret    

001013bc <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  1013bc:	55                   	push   %ebp
  1013bd:	89 e5                	mov    %esp,%ebp
  1013bf:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  1013c2:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  1013c7:	85 c0                	test   %eax,%eax
  1013c9:	74 0c                	je     1013d7 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  1013cb:	c7 04 24 66 13 10 00 	movl   $0x101366,(%esp)
  1013d2:	e8 43 ff ff ff       	call   10131a <cons_intr>
    }
}
  1013d7:	90                   	nop
  1013d8:	c9                   	leave  
  1013d9:	c3                   	ret    

001013da <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  1013da:	55                   	push   %ebp
  1013db:	89 e5                	mov    %esp,%ebp
  1013dd:	83 ec 28             	sub    $0x28,%esp
  1013e0:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  1013e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1013e9:	89 c2                	mov    %eax,%edx
  1013eb:	ec                   	in     (%dx),%al
  1013ec:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1013ef:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1013f3:	0f b6 c0             	movzbl %al,%eax
  1013f6:	83 e0 01             	and    $0x1,%eax
  1013f9:	85 c0                	test   %eax,%eax
  1013fb:	75 0a                	jne    101407 <kbd_proc_data+0x2d>
        return -1;
  1013fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101402:	e9 56 01 00 00       	jmp    10155d <kbd_proc_data+0x183>
  101407:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void ltr(uint16_t sel) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port));
  10140d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101410:	89 c2                	mov    %eax,%edx
  101412:	ec                   	in     (%dx),%al
  101413:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  101416:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  10141a:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10141d:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101421:	75 17                	jne    10143a <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101423:	a1 88 00 11 00       	mov    0x110088,%eax
  101428:	83 c8 40             	or     $0x40,%eax
  10142b:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  101430:	b8 00 00 00 00       	mov    $0x0,%eax
  101435:	e9 23 01 00 00       	jmp    10155d <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  10143a:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10143e:	84 c0                	test   %al,%al
  101440:	79 45                	jns    101487 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101442:	a1 88 00 11 00       	mov    0x110088,%eax
  101447:	83 e0 40             	and    $0x40,%eax
  10144a:	85 c0                	test   %eax,%eax
  10144c:	75 08                	jne    101456 <kbd_proc_data+0x7c>
  10144e:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101452:	24 7f                	and    $0x7f,%al
  101454:	eb 04                	jmp    10145a <kbd_proc_data+0x80>
  101456:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10145a:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  10145d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101461:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  101468:	0c 40                	or     $0x40,%al
  10146a:	0f b6 c0             	movzbl %al,%eax
  10146d:	f7 d0                	not    %eax
  10146f:	89 c2                	mov    %eax,%edx
  101471:	a1 88 00 11 00       	mov    0x110088,%eax
  101476:	21 d0                	and    %edx,%eax
  101478:	a3 88 00 11 00       	mov    %eax,0x110088
        return 0;
  10147d:	b8 00 00 00 00       	mov    $0x0,%eax
  101482:	e9 d6 00 00 00       	jmp    10155d <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  101487:	a1 88 00 11 00       	mov    0x110088,%eax
  10148c:	83 e0 40             	and    $0x40,%eax
  10148f:	85 c0                	test   %eax,%eax
  101491:	74 11                	je     1014a4 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101493:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101497:	a1 88 00 11 00       	mov    0x110088,%eax
  10149c:	83 e0 bf             	and    $0xffffffbf,%eax
  10149f:	a3 88 00 11 00       	mov    %eax,0x110088
    }

    shift |= shiftcode[data];
  1014a4:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014a8:	0f b6 80 40 f0 10 00 	movzbl 0x10f040(%eax),%eax
  1014af:	0f b6 d0             	movzbl %al,%edx
  1014b2:	a1 88 00 11 00       	mov    0x110088,%eax
  1014b7:	09 d0                	or     %edx,%eax
  1014b9:	a3 88 00 11 00       	mov    %eax,0x110088
    shift ^= togglecode[data];
  1014be:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c2:	0f b6 80 40 f1 10 00 	movzbl 0x10f140(%eax),%eax
  1014c9:	0f b6 d0             	movzbl %al,%edx
  1014cc:	a1 88 00 11 00       	mov    0x110088,%eax
  1014d1:	31 d0                	xor    %edx,%eax
  1014d3:	a3 88 00 11 00       	mov    %eax,0x110088

    c = charcode[shift & (CTL | SHIFT)][data];
  1014d8:	a1 88 00 11 00       	mov    0x110088,%eax
  1014dd:	83 e0 03             	and    $0x3,%eax
  1014e0:	8b 14 85 40 f5 10 00 	mov    0x10f540(,%eax,4),%edx
  1014e7:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014eb:	01 d0                	add    %edx,%eax
  1014ed:	0f b6 00             	movzbl (%eax),%eax
  1014f0:	0f b6 c0             	movzbl %al,%eax
  1014f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1014f6:	a1 88 00 11 00       	mov    0x110088,%eax
  1014fb:	83 e0 08             	and    $0x8,%eax
  1014fe:	85 c0                	test   %eax,%eax
  101500:	74 22                	je     101524 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  101502:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101506:	7e 0c                	jle    101514 <kbd_proc_data+0x13a>
  101508:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10150c:	7f 06                	jg     101514 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  10150e:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101512:	eb 10                	jmp    101524 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101514:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101518:	7e 0a                	jle    101524 <kbd_proc_data+0x14a>
  10151a:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10151e:	7f 04                	jg     101524 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  101520:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101524:	a1 88 00 11 00       	mov    0x110088,%eax
  101529:	f7 d0                	not    %eax
  10152b:	83 e0 06             	and    $0x6,%eax
  10152e:	85 c0                	test   %eax,%eax
  101530:	75 28                	jne    10155a <kbd_proc_data+0x180>
  101532:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  101539:	75 1f                	jne    10155a <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  10153b:	c7 04 24 e1 3b 10 00 	movl   $0x103be1,(%esp)
  101542:	e8 25 ed ff ff       	call   10026c <cprintf>
  101547:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  10154d:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
            : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port));
  101551:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101555:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101559:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10155a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10155d:	c9                   	leave  
  10155e:	c3                   	ret    

0010155f <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  10155f:	55                   	push   %ebp
  101560:	89 e5                	mov    %esp,%ebp
  101562:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  101565:	c7 04 24 da 13 10 00 	movl   $0x1013da,(%esp)
  10156c:	e8 a9 fd ff ff       	call   10131a <cons_intr>
}
  101571:	90                   	nop
  101572:	c9                   	leave  
  101573:	c3                   	ret    

00101574 <kbd_init>:

static void
kbd_init(void) {
  101574:	55                   	push   %ebp
  101575:	89 e5                	mov    %esp,%ebp
  101577:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  10157a:	e8 e0 ff ff ff       	call   10155f <kbd_intr>
    pic_enable(IRQ_KBD);
  10157f:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  101586:	e8 0e 01 00 00       	call   101699 <pic_enable>
}
  10158b:	90                   	nop
  10158c:	c9                   	leave  
  10158d:	c3                   	ret    

0010158e <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  10158e:	55                   	push   %ebp
  10158f:	89 e5                	mov    %esp,%ebp
  101591:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101594:	e8 90 f8 ff ff       	call   100e29 <cga_init>
    serial_init();
  101599:	e8 6d f9 ff ff       	call   100f0b <serial_init>
    kbd_init();
  10159e:	e8 d1 ff ff ff       	call   101574 <kbd_init>
    if (!serial_exists) {
  1015a3:	a1 68 fe 10 00       	mov    0x10fe68,%eax
  1015a8:	85 c0                	test   %eax,%eax
  1015aa:	75 0c                	jne    1015b8 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  1015ac:	c7 04 24 ed 3b 10 00 	movl   $0x103bed,(%esp)
  1015b3:	e8 b4 ec ff ff       	call   10026c <cprintf>
    }
}
  1015b8:	90                   	nop
  1015b9:	c9                   	leave  
  1015ba:	c3                   	ret    

001015bb <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  1015bb:	55                   	push   %ebp
  1015bc:	89 e5                	mov    %esp,%ebp
  1015be:	83 ec 18             	sub    $0x18,%esp
    lpt_putc(c);
  1015c1:	8b 45 08             	mov    0x8(%ebp),%eax
  1015c4:	89 04 24             	mov    %eax,(%esp)
  1015c7:	e8 95 fa ff ff       	call   101061 <lpt_putc>
    cga_putc(c);
  1015cc:	8b 45 08             	mov    0x8(%ebp),%eax
  1015cf:	89 04 24             	mov    %eax,(%esp)
  1015d2:	e8 ca fa ff ff       	call   1010a1 <cga_putc>
    serial_putc(c);
  1015d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1015da:	89 04 24             	mov    %eax,(%esp)
  1015dd:	e8 f8 fc ff ff       	call   1012da <serial_putc>
}
  1015e2:	90                   	nop
  1015e3:	c9                   	leave  
  1015e4:	c3                   	ret    

001015e5 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1015e5:	55                   	push   %ebp
  1015e6:	89 e5                	mov    %esp,%ebp
  1015e8:	83 ec 18             	sub    $0x18,%esp
    int c;

    // poll for any pending input characters,
    // so that this function works even when interrupts are disabled
    // (e.g., when called from the kernel monitor).
    serial_intr();
  1015eb:	e8 cc fd ff ff       	call   1013bc <serial_intr>
    kbd_intr();
  1015f0:	e8 6a ff ff ff       	call   10155f <kbd_intr>

    // grab the next character from the input buffer.
    if (cons.rpos != cons.wpos) {
  1015f5:	8b 15 80 00 11 00    	mov    0x110080,%edx
  1015fb:	a1 84 00 11 00       	mov    0x110084,%eax
  101600:	39 c2                	cmp    %eax,%edx
  101602:	74 36                	je     10163a <cons_getc+0x55>
        c = cons.buf[cons.rpos ++];
  101604:	a1 80 00 11 00       	mov    0x110080,%eax
  101609:	8d 50 01             	lea    0x1(%eax),%edx
  10160c:	89 15 80 00 11 00    	mov    %edx,0x110080
  101612:	0f b6 80 80 fe 10 00 	movzbl 0x10fe80(%eax),%eax
  101619:	0f b6 c0             	movzbl %al,%eax
  10161c:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (cons.rpos == CONSBUFSIZE) {
  10161f:	a1 80 00 11 00       	mov    0x110080,%eax
  101624:	3d 00 02 00 00       	cmp    $0x200,%eax
  101629:	75 0a                	jne    101635 <cons_getc+0x50>
            cons.rpos = 0;
  10162b:	c7 05 80 00 11 00 00 	movl   $0x0,0x110080
  101632:	00 00 00 
        }
        return c;
  101635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101638:	eb 05                	jmp    10163f <cons_getc+0x5a>
    }
    return 0;
  10163a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10163f:	c9                   	leave  
  101640:	c3                   	ret    

00101641 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101641:	55                   	push   %ebp
  101642:	89 e5                	mov    %esp,%ebp
  101644:	83 ec 14             	sub    $0x14,%esp
  101647:	8b 45 08             	mov    0x8(%ebp),%eax
  10164a:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  10164e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101651:	66 a3 50 f5 10 00    	mov    %ax,0x10f550
    if (did_init) {
  101657:	a1 8c 00 11 00       	mov    0x11008c,%eax
  10165c:	85 c0                	test   %eax,%eax
  10165e:	74 36                	je     101696 <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
  101660:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101663:	0f b6 c0             	movzbl %al,%eax
  101666:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  10166c:	88 45 fa             	mov    %al,-0x6(%ebp)
  10166f:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  101673:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101677:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  101678:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  10167c:	c1 e8 08             	shr    $0x8,%eax
  10167f:	0f b7 c0             	movzwl %ax,%eax
  101682:	0f b6 c0             	movzbl %al,%eax
  101685:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  10168b:	88 45 fb             	mov    %al,-0x5(%ebp)
  10168e:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101692:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101695:	ee                   	out    %al,(%dx)
    }
}
  101696:	90                   	nop
  101697:	c9                   	leave  
  101698:	c3                   	ret    

00101699 <pic_enable>:

void
pic_enable(unsigned int irq) {
  101699:	55                   	push   %ebp
  10169a:	89 e5                	mov    %esp,%ebp
  10169c:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  10169f:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a2:	ba 01 00 00 00       	mov    $0x1,%edx
  1016a7:	88 c1                	mov    %al,%cl
  1016a9:	d3 e2                	shl    %cl,%edx
  1016ab:	89 d0                	mov    %edx,%eax
  1016ad:	98                   	cwtl   
  1016ae:	f7 d0                	not    %eax
  1016b0:	0f bf d0             	movswl %ax,%edx
  1016b3:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1016ba:	98                   	cwtl   
  1016bb:	21 d0                	and    %edx,%eax
  1016bd:	98                   	cwtl   
  1016be:	0f b7 c0             	movzwl %ax,%eax
  1016c1:	89 04 24             	mov    %eax,(%esp)
  1016c4:	e8 78 ff ff ff       	call   101641 <pic_setmask>
}
  1016c9:	90                   	nop
  1016ca:	c9                   	leave  
  1016cb:	c3                   	ret    

001016cc <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1016cc:	55                   	push   %ebp
  1016cd:	89 e5                	mov    %esp,%ebp
  1016cf:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
  1016d2:	c7 05 8c 00 11 00 01 	movl   $0x1,0x11008c
  1016d9:	00 00 00 
  1016dc:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  1016e2:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  1016e6:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  1016ea:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  1016ee:	ee                   	out    %al,(%dx)
  1016ef:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  1016f5:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  1016f9:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  1016fd:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101700:	ee                   	out    %al,(%dx)
  101701:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  101707:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  10170b:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  10170f:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101713:	ee                   	out    %al,(%dx)
  101714:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  10171a:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  10171e:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101722:	8b 55 f8             	mov    -0x8(%ebp),%edx
  101725:	ee                   	out    %al,(%dx)
  101726:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  10172c:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  101730:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  101734:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  101738:	ee                   	out    %al,(%dx)
  101739:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  10173f:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  101743:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  101747:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10174a:	ee                   	out    %al,(%dx)
  10174b:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  101751:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  101755:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  101759:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10175d:	ee                   	out    %al,(%dx)
  10175e:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  101764:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  101768:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10176c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10176f:	ee                   	out    %al,(%dx)
  101770:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  101776:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  10177a:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  10177e:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101782:	ee                   	out    %al,(%dx)
  101783:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  101789:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  10178d:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  101791:	8b 55 ec             	mov    -0x14(%ebp),%edx
  101794:	ee                   	out    %al,(%dx)
  101795:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  10179b:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  10179f:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  1017a3:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1017a7:	ee                   	out    %al,(%dx)
  1017a8:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  1017ae:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  1017b2:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  1017b6:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1017b9:	ee                   	out    %al,(%dx)
  1017ba:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  1017c0:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  1017c4:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  1017c8:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1017cc:	ee                   	out    %al,(%dx)
  1017cd:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  1017d3:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  1017d7:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  1017db:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1017de:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  1017df:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1017e6:	3d ff ff 00 00       	cmp    $0xffff,%eax
  1017eb:	74 0f                	je     1017fc <pic_init+0x130>
        pic_setmask(irq_mask);
  1017ed:	0f b7 05 50 f5 10 00 	movzwl 0x10f550,%eax
  1017f4:	89 04 24             	mov    %eax,(%esp)
  1017f7:	e8 45 fe ff ff       	call   101641 <pic_setmask>
    }
}
  1017fc:	90                   	nop
  1017fd:	c9                   	leave  
  1017fe:	c3                   	ret    

001017ff <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  1017ff:	55                   	push   %ebp
  101800:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd));
}

static inline void
sti(void) {
    asm volatile ("sti");
  101802:	fb                   	sti    
    sti();
}
  101803:	90                   	nop
  101804:	5d                   	pop    %ebp
  101805:	c3                   	ret    

00101806 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101806:	55                   	push   %ebp
  101807:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli");
  101809:	fa                   	cli    
    cli();
}
  10180a:	90                   	nop
  10180b:	5d                   	pop    %ebp
  10180c:	c3                   	ret    

0010180d <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  10180d:	55                   	push   %ebp
  10180e:	89 e5                	mov    %esp,%ebp
  101810:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  101813:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  10181a:	00 
  10181b:	c7 04 24 20 3c 10 00 	movl   $0x103c20,(%esp)
  101822:	e8 45 ea ff ff       	call   10026c <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  101827:	90                   	nop
  101828:	c9                   	leave  
  101829:	c3                   	ret    

0010182a <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  10182a:	55                   	push   %ebp
  10182b:	89 e5                	mov    %esp,%ebp
  10182d:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
  101830:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101837:	e9 67 02 00 00       	jmp    101aa3 <idt_init+0x279>
        if(i == 128){
  10183c:	81 7d fc 80 00 00 00 	cmpl   $0x80,-0x4(%ebp)
  101843:	0f 85 c6 00 00 00    	jne    10190f <idt_init+0xe5>
            SETGATE(idt[i],0,8,__vectors[i],3);
  101849:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10184c:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  101853:	0f b7 d0             	movzwl %ax,%edx
  101856:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101859:	66 89 14 c5 a0 00 11 	mov    %dx,0x1100a0(,%eax,8)
  101860:	00 
  101861:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101864:	66 c7 04 c5 a2 00 11 	movw   $0x8,0x1100a2(,%eax,8)
  10186b:	00 08 00 
  10186e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101871:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101878:	00 
  101879:	80 e2 e0             	and    $0xe0,%dl
  10187c:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101883:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101886:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  10188d:	00 
  10188e:	80 e2 1f             	and    $0x1f,%dl
  101891:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101898:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10189b:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1018a2:	00 
  1018a3:	80 e2 f0             	and    $0xf0,%dl
  1018a6:	80 ca 0e             	or     $0xe,%dl
  1018a9:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1018b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018b3:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1018ba:	00 
  1018bb:	80 e2 ef             	and    $0xef,%dl
  1018be:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1018c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018c8:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1018cf:	00 
  1018d0:	80 ca 60             	or     $0x60,%dl
  1018d3:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1018da:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018dd:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1018e4:	00 
  1018e5:	80 ca 80             	or     $0x80,%dl
  1018e8:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1018ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f2:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1018f9:	c1 e8 10             	shr    $0x10,%eax
  1018fc:	0f b7 d0             	movzwl %ax,%edx
  1018ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101902:	66 89 14 c5 a6 00 11 	mov    %dx,0x1100a6(,%eax,8)
  101909:	00 
  10190a:	e9 91 01 00 00       	jmp    101aa0 <idt_init+0x276>
        }
        else if(i == 121){
  10190f:	83 7d fc 79          	cmpl   $0x79,-0x4(%ebp)
  101913:	0f 85 c6 00 00 00    	jne    1019df <idt_init+0x1b5>
            SETGATE(idt[i],0,8,__vectors[i],3);
  101919:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191c:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  101923:	0f b7 d0             	movzwl %ax,%edx
  101926:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101929:	66 89 14 c5 a0 00 11 	mov    %dx,0x1100a0(,%eax,8)
  101930:	00 
  101931:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101934:	66 c7 04 c5 a2 00 11 	movw   $0x8,0x1100a2(,%eax,8)
  10193b:	00 08 00 
  10193e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101941:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101948:	00 
  101949:	80 e2 e0             	and    $0xe0,%dl
  10194c:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101953:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101956:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  10195d:	00 
  10195e:	80 e2 1f             	and    $0x1f,%dl
  101961:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101968:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10196b:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101972:	00 
  101973:	80 e2 f0             	and    $0xf0,%dl
  101976:	80 ca 0e             	or     $0xe,%dl
  101979:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101980:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101983:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  10198a:	00 
  10198b:	80 e2 ef             	and    $0xef,%dl
  10198e:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101995:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101998:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  10199f:	00 
  1019a0:	80 ca 60             	or     $0x60,%dl
  1019a3:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1019aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ad:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  1019b4:	00 
  1019b5:	80 ca 80             	or     $0x80,%dl
  1019b8:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  1019bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c2:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1019c9:	c1 e8 10             	shr    $0x10,%eax
  1019cc:	0f b7 d0             	movzwl %ax,%edx
  1019cf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d2:	66 89 14 c5 a6 00 11 	mov    %dx,0x1100a6(,%eax,8)
  1019d9:	00 
  1019da:	e9 c1 00 00 00       	jmp    101aa0 <idt_init+0x276>
        }
        else{
            SETGATE(idt[i],0,8,__vectors[i],0);
  1019df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019e2:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  1019e9:	0f b7 d0             	movzwl %ax,%edx
  1019ec:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ef:	66 89 14 c5 a0 00 11 	mov    %dx,0x1100a0(,%eax,8)
  1019f6:	00 
  1019f7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019fa:	66 c7 04 c5 a2 00 11 	movw   $0x8,0x1100a2(,%eax,8)
  101a01:	00 08 00 
  101a04:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a07:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101a0e:	00 
  101a0f:	80 e2 e0             	and    $0xe0,%dl
  101a12:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101a19:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a1c:	0f b6 14 c5 a4 00 11 	movzbl 0x1100a4(,%eax,8),%edx
  101a23:	00 
  101a24:	80 e2 1f             	and    $0x1f,%dl
  101a27:	88 14 c5 a4 00 11 00 	mov    %dl,0x1100a4(,%eax,8)
  101a2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a31:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101a38:	00 
  101a39:	80 e2 f0             	and    $0xf0,%dl
  101a3c:	80 ca 0e             	or     $0xe,%dl
  101a3f:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101a46:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a49:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101a50:	00 
  101a51:	80 e2 ef             	and    $0xef,%dl
  101a54:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101a5b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a5e:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101a65:	00 
  101a66:	80 e2 9f             	and    $0x9f,%dl
  101a69:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101a70:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a73:	0f b6 14 c5 a5 00 11 	movzbl 0x1100a5(,%eax,8),%edx
  101a7a:	00 
  101a7b:	80 ca 80             	or     $0x80,%dl
  101a7e:	88 14 c5 a5 00 11 00 	mov    %dl,0x1100a5(,%eax,8)
  101a85:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a88:	8b 04 85 e0 f5 10 00 	mov    0x10f5e0(,%eax,4),%eax
  101a8f:	c1 e8 10             	shr    $0x10,%eax
  101a92:	0f b7 d0             	movzwl %ax,%edx
  101a95:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a98:	66 89 14 c5 a6 00 11 	mov    %dx,0x1100a6(,%eax,8)
  101a9f:	00 
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
  101aa0:	ff 45 fc             	incl   -0x4(%ebp)
  101aa3:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101aaa:	0f 8e 8c fd ff ff    	jle    10183c <idt_init+0x12>
  101ab0:	c7 45 f8 60 f5 10 00 	movl   $0x10f560,-0x8(%ebp)
    return ebp;
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd));
  101ab7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101aba:	0f 01 18             	lidtl  (%eax)
        //          for software to invoke this interrupt/trap gate explicitly
        //          using an int instruction.
    }

    lidt(&idt_pd);
}
  101abd:	90                   	nop
  101abe:	c9                   	leave  
  101abf:	c3                   	ret    

00101ac0 <trapname>:

static const char *
trapname(int trapno) {
  101ac0:	55                   	push   %ebp
  101ac1:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  101ac6:	83 f8 13             	cmp    $0x13,%eax
  101ac9:	77 0c                	ja     101ad7 <trapname+0x17>
        return excnames[trapno];
  101acb:	8b 45 08             	mov    0x8(%ebp),%eax
  101ace:	8b 04 85 80 3f 10 00 	mov    0x103f80(,%eax,4),%eax
  101ad5:	eb 18                	jmp    101aef <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101ad7:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101adb:	7e 0d                	jle    101aea <trapname+0x2a>
  101add:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101ae1:	7f 07                	jg     101aea <trapname+0x2a>
        return "Hardware Interrupt";
  101ae3:	b8 2a 3c 10 00       	mov    $0x103c2a,%eax
  101ae8:	eb 05                	jmp    101aef <trapname+0x2f>
    }
    return "(unknown trap)";
  101aea:	b8 3d 3c 10 00       	mov    $0x103c3d,%eax
}
  101aef:	5d                   	pop    %ebp
  101af0:	c3                   	ret    

00101af1 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101af1:	55                   	push   %ebp
  101af2:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101af4:	8b 45 08             	mov    0x8(%ebp),%eax
  101af7:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101afb:	83 f8 08             	cmp    $0x8,%eax
  101afe:	0f 94 c0             	sete   %al
  101b01:	0f b6 c0             	movzbl %al,%eax
}
  101b04:	5d                   	pop    %ebp
  101b05:	c3                   	ret    

00101b06 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b06:	55                   	push   %ebp
  101b07:	89 e5                	mov    %esp,%ebp
  101b09:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b13:	c7 04 24 7e 3c 10 00 	movl   $0x103c7e,(%esp)
  101b1a:	e8 4d e7 ff ff       	call   10026c <cprintf>
    print_regs(&tf->tf_regs);
  101b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b22:	89 04 24             	mov    %eax,(%esp)
  101b25:	e8 91 01 00 00       	call   101cbb <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2d:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b35:	c7 04 24 8f 3c 10 00 	movl   $0x103c8f,(%esp)
  101b3c:	e8 2b e7 ff ff       	call   10026c <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b41:	8b 45 08             	mov    0x8(%ebp),%eax
  101b44:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b48:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b4c:	c7 04 24 a2 3c 10 00 	movl   $0x103ca2,(%esp)
  101b53:	e8 14 e7 ff ff       	call   10026c <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b63:	c7 04 24 b5 3c 10 00 	movl   $0x103cb5,(%esp)
  101b6a:	e8 fd e6 ff ff       	call   10026c <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b72:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b76:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7a:	c7 04 24 c8 3c 10 00 	movl   $0x103cc8,(%esp)
  101b81:	e8 e6 e6 ff ff       	call   10026c <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101b86:	8b 45 08             	mov    0x8(%ebp),%eax
  101b89:	8b 40 30             	mov    0x30(%eax),%eax
  101b8c:	89 04 24             	mov    %eax,(%esp)
  101b8f:	e8 2c ff ff ff       	call   101ac0 <trapname>
  101b94:	89 c2                	mov    %eax,%edx
  101b96:	8b 45 08             	mov    0x8(%ebp),%eax
  101b99:	8b 40 30             	mov    0x30(%eax),%eax
  101b9c:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ba0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba4:	c7 04 24 db 3c 10 00 	movl   $0x103cdb,(%esp)
  101bab:	e8 bc e6 ff ff       	call   10026c <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb3:	8b 40 34             	mov    0x34(%eax),%eax
  101bb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bba:	c7 04 24 ed 3c 10 00 	movl   $0x103ced,(%esp)
  101bc1:	e8 a6 e6 ff ff       	call   10026c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bc6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc9:	8b 40 38             	mov    0x38(%eax),%eax
  101bcc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd0:	c7 04 24 fc 3c 10 00 	movl   $0x103cfc,(%esp)
  101bd7:	e8 90 e6 ff ff       	call   10026c <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  101bdf:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101be3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be7:	c7 04 24 0b 3d 10 00 	movl   $0x103d0b,(%esp)
  101bee:	e8 79 e6 ff ff       	call   10026c <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101bf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf6:	8b 40 40             	mov    0x40(%eax),%eax
  101bf9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bfd:	c7 04 24 1e 3d 10 00 	movl   $0x103d1e,(%esp)
  101c04:	e8 63 e6 ff ff       	call   10026c <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c10:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c17:	eb 3d                	jmp    101c56 <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c19:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1c:	8b 50 40             	mov    0x40(%eax),%edx
  101c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c22:	21 d0                	and    %edx,%eax
  101c24:	85 c0                	test   %eax,%eax
  101c26:	74 28                	je     101c50 <print_trapframe+0x14a>
  101c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c2b:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101c32:	85 c0                	test   %eax,%eax
  101c34:	74 1a                	je     101c50 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101c36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c39:	8b 04 85 80 f5 10 00 	mov    0x10f580(,%eax,4),%eax
  101c40:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c44:	c7 04 24 2d 3d 10 00 	movl   $0x103d2d,(%esp)
  101c4b:	e8 1c e6 ff ff       	call   10026c <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c50:	ff 45 f4             	incl   -0xc(%ebp)
  101c53:	d1 65 f0             	shll   -0x10(%ebp)
  101c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c59:	83 f8 17             	cmp    $0x17,%eax
  101c5c:	76 bb                	jbe    101c19 <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  101c61:	8b 40 40             	mov    0x40(%eax),%eax
  101c64:	25 00 30 00 00       	and    $0x3000,%eax
  101c69:	c1 e8 0c             	shr    $0xc,%eax
  101c6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c70:	c7 04 24 31 3d 10 00 	movl   $0x103d31,(%esp)
  101c77:	e8 f0 e5 ff ff       	call   10026c <cprintf>

    if (!trap_in_kernel(tf)) {
  101c7c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7f:	89 04 24             	mov    %eax,(%esp)
  101c82:	e8 6a fe ff ff       	call   101af1 <trap_in_kernel>
  101c87:	85 c0                	test   %eax,%eax
  101c89:	75 2d                	jne    101cb8 <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8e:	8b 40 44             	mov    0x44(%eax),%eax
  101c91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c95:	c7 04 24 3a 3d 10 00 	movl   $0x103d3a,(%esp)
  101c9c:	e8 cb e5 ff ff       	call   10026c <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca4:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cac:	c7 04 24 49 3d 10 00 	movl   $0x103d49,(%esp)
  101cb3:	e8 b4 e5 ff ff       	call   10026c <cprintf>
    }
}
  101cb8:	90                   	nop
  101cb9:	c9                   	leave  
  101cba:	c3                   	ret    

00101cbb <print_regs>:

void
print_regs(struct pushregs *regs) {
  101cbb:	55                   	push   %ebp
  101cbc:	89 e5                	mov    %esp,%ebp
  101cbe:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  101cc4:	8b 00                	mov    (%eax),%eax
  101cc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cca:	c7 04 24 5c 3d 10 00 	movl   $0x103d5c,(%esp)
  101cd1:	e8 96 e5 ff ff       	call   10026c <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101cd9:	8b 40 04             	mov    0x4(%eax),%eax
  101cdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce0:	c7 04 24 6b 3d 10 00 	movl   $0x103d6b,(%esp)
  101ce7:	e8 80 e5 ff ff       	call   10026c <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101cec:	8b 45 08             	mov    0x8(%ebp),%eax
  101cef:	8b 40 08             	mov    0x8(%eax),%eax
  101cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf6:	c7 04 24 7a 3d 10 00 	movl   $0x103d7a,(%esp)
  101cfd:	e8 6a e5 ff ff       	call   10026c <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d02:	8b 45 08             	mov    0x8(%ebp),%eax
  101d05:	8b 40 0c             	mov    0xc(%eax),%eax
  101d08:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0c:	c7 04 24 89 3d 10 00 	movl   $0x103d89,(%esp)
  101d13:	e8 54 e5 ff ff       	call   10026c <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d18:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1b:	8b 40 10             	mov    0x10(%eax),%eax
  101d1e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d22:	c7 04 24 98 3d 10 00 	movl   $0x103d98,(%esp)
  101d29:	e8 3e e5 ff ff       	call   10026c <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  101d31:	8b 40 14             	mov    0x14(%eax),%eax
  101d34:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d38:	c7 04 24 a7 3d 10 00 	movl   $0x103da7,(%esp)
  101d3f:	e8 28 e5 ff ff       	call   10026c <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d44:	8b 45 08             	mov    0x8(%ebp),%eax
  101d47:	8b 40 18             	mov    0x18(%eax),%eax
  101d4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d4e:	c7 04 24 b6 3d 10 00 	movl   $0x103db6,(%esp)
  101d55:	e8 12 e5 ff ff       	call   10026c <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  101d5d:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d60:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d64:	c7 04 24 c5 3d 10 00 	movl   $0x103dc5,(%esp)
  101d6b:	e8 fc e4 ff ff       	call   10026c <cprintf>
}
  101d70:	90                   	nop
  101d71:	c9                   	leave  
  101d72:	c3                   	ret    

00101d73 <l_switch_to_user>:
static uint32_t i_in_td, tf_end_in_td;
struct trapframe switchk2u, *switchu2k;
extern void __move_down_stack2(uint32_t end, uint32_t tf);
extern struct trapframe* __move_up_stack2(uint32_t end, uint32_t tf, uint32_t esp);

static void l_switch_to_user() {
  101d73:	55                   	push   %ebp
  101d74:	89 e5                	mov    %esp,%ebp
    asm volatile (
  101d76:	83 ec 08             	sub    $0x8,%esp
  101d79:	cd 78                	int    $0x78
  101d7b:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        : 
        : "i"(T_SWITCH_TOU)
    );
}
  101d7d:	90                   	nop
  101d7e:	5d                   	pop    %ebp
  101d7f:	c3                   	ret    

00101d80 <l_switch_to_kernel>:

static void l_switch_to_kernel(void) {
  101d80:	55                   	push   %ebp
  101d81:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
        asm volatile (
  101d83:	cd 79                	int    $0x79
  101d85:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp \n"
        : 
        : "i"(T_SWITCH_TOK)
        );
}
  101d87:	90                   	nop
  101d88:	5d                   	pop    %ebp
  101d89:	c3                   	ret    

00101d8a <trap_dispatch>:
    }
}

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d8a:	55                   	push   %ebp
  101d8b:	89 e5                	mov    %esp,%ebp
  101d8d:	56                   	push   %esi
  101d8e:	53                   	push   %ebx
  101d8f:	83 ec 20             	sub    $0x20,%esp
    char c;
    
    switch (tf->tf_trapno) {
  101d92:	8b 45 08             	mov    0x8(%ebp),%eax
  101d95:	8b 40 30             	mov    0x30(%eax),%eax
  101d98:	83 f8 2f             	cmp    $0x2f,%eax
  101d9b:	77 1d                	ja     101dba <trap_dispatch+0x30>
  101d9d:	83 f8 2e             	cmp    $0x2e,%eax
  101da0:	0f 83 14 03 00 00    	jae    1020ba <trap_dispatch+0x330>
  101da6:	83 f8 21             	cmp    $0x21,%eax
  101da9:	74 7c                	je     101e27 <trap_dispatch+0x9d>
  101dab:	83 f8 24             	cmp    $0x24,%eax
  101dae:	74 4e                	je     101dfe <trap_dispatch+0x74>
  101db0:	83 f8 20             	cmp    $0x20,%eax
  101db3:	74 1c                	je     101dd1 <trap_dispatch+0x47>
  101db5:	e9 cb 02 00 00       	jmp    102085 <trap_dispatch+0x2fb>
  101dba:	83 f8 78             	cmp    $0x78,%eax
  101dbd:	0f 84 d0 01 00 00    	je     101f93 <trap_dispatch+0x209>
  101dc3:	83 f8 79             	cmp    $0x79,%eax
  101dc6:	0f 84 4b 02 00 00    	je     102017 <trap_dispatch+0x28d>
  101dcc:	e9 b4 02 00 00       	jmp    102085 <trap_dispatch+0x2fb>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        count++;
  101dd1:	a1 a0 08 11 00       	mov    0x1108a0,%eax
  101dd6:	40                   	inc    %eax
  101dd7:	a3 a0 08 11 00       	mov    %eax,0x1108a0
        if(count == TICK_NUM){
  101ddc:	a1 a0 08 11 00       	mov    0x1108a0,%eax
  101de1:	83 f8 64             	cmp    $0x64,%eax
  101de4:	0f 85 d3 02 00 00    	jne    1020bd <trap_dispatch+0x333>
            count = 0;
  101dea:	c7 05 a0 08 11 00 00 	movl   $0x0,0x1108a0
  101df1:	00 00 00 
            print_ticks();
  101df4:	e8 14 fa ff ff       	call   10180d <print_ticks>
        }
        break;
  101df9:	e9 bf 02 00 00       	jmp    1020bd <trap_dispatch+0x333>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101dfe:	e8 e2 f7 ff ff       	call   1015e5 <cons_getc>
  101e03:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e06:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e0a:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e0e:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e12:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e16:	c7 04 24 d4 3d 10 00 	movl   $0x103dd4,(%esp)
  101e1d:	e8 4a e4 ff ff       	call   10026c <cprintf>
        break;
  101e22:	e9 a0 02 00 00       	jmp    1020c7 <trap_dispatch+0x33d>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e27:	e8 b9 f7 ff ff       	call   1015e5 <cons_getc>
  101e2c:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e2f:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e33:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e37:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e3f:	c7 04 24 e6 3d 10 00 	movl   $0x103de6,(%esp)
  101e46:	e8 21 e4 ff ff       	call   10026c <cprintf>
        if (c == 0x30) { // switch to kernel mode
  101e4b:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101e4f:	0f 85 82 00 00 00    	jne    101ed7 <trap_dispatch+0x14d>
            saved_tf = __move_up_stack2((uint32_t)(tf) + sizeof(struct trapframe) - 8, (uint32_t) tf, tf->tf_esp);
  101e55:	8b 45 08             	mov    0x8(%ebp),%eax
  101e58:	8b 50 44             	mov    0x44(%eax),%edx
  101e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  101e61:	83 c1 44             	add    $0x44,%ecx
  101e64:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e68:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e6c:	89 0c 24             	mov    %ecx,(%esp)
  101e6f:	e8 4a 0d 00 00       	call   102bbe <__move_up_stack2>
  101e74:	a3 a4 08 11 00       	mov    %eax,0x1108a4
            saved_tf->tf_cs = KERNEL_CS;
  101e79:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101e7e:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_gs = KERNEL_DS;
  101e84:	8b 1d a4 08 11 00    	mov    0x1108a4,%ebx
  101e8a:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101e8f:	8b 15 a4 08 11 00    	mov    0x1108a4,%edx
  101e95:	8b 0d a4 08 11 00    	mov    0x1108a4,%ecx
  101e9b:	66 c7 41 20 10 00    	movw   $0x10,0x20(%ecx)
  101ea1:	0f b7 49 20          	movzwl 0x20(%ecx),%ecx
  101ea5:	66 89 4a 24          	mov    %cx,0x24(%edx)
  101ea9:	0f b7 52 24          	movzwl 0x24(%edx),%edx
  101ead:	66 89 50 28          	mov    %dx,0x28(%eax)
  101eb1:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101eb5:	66 89 43 2c          	mov    %ax,0x2c(%ebx)
            saved_tf->tf_trapno = 0x21;
  101eb9:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101ebe:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
            asm volatile (
  101ec5:	b8 10 00 00 00       	mov    $0x10,%eax
  101eca:	8e d0                	mov    %eax,%ss
                "movw %0, %%ss"
                :
                : "r"(KERNEL_DS)
                 );
            print_trapframe(tf);
  101ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  101ecf:	89 04 24             	mov    %eax,(%esp)
  101ed2:	e8 2f fc ff ff       	call   101b06 <print_trapframe>
        }

        if (c == 0x33) { // switch to user mode
  101ed7:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101edb:	0f 85 df 01 00 00    	jne    1020c0 <trap_dispatch+0x336>
            saved_tf = (struct trapname*) ((uint32_t)(tf) - 8);
  101ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee4:	83 e8 08             	sub    $0x8,%eax
  101ee7:	a3 a4 08 11 00       	mov    %eax,0x1108a4
    
            __move_down_stack2( (uint32_t)(tf) + sizeof(struct trapframe) - 8 , (uint32_t) tf );
  101eec:	8b 45 08             	mov    0x8(%ebp),%eax
  101eef:	8b 55 08             	mov    0x8(%ebp),%edx
  101ef2:	83 c2 44             	add    $0x44,%edx
  101ef5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ef9:	89 14 24             	mov    %edx,(%esp)
  101efc:	e8 76 0c 00 00       	call   102b77 <__move_down_stack2>

            saved_tf->tf_eflags |= FL_IOPL_MASK;
  101f01:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101f06:	8b 15 a4 08 11 00    	mov    0x1108a4,%edx
  101f0c:	8b 52 40             	mov    0x40(%edx),%edx
  101f0f:	81 ca 00 30 00 00    	or     $0x3000,%edx
  101f15:	89 50 40             	mov    %edx,0x40(%eax)
            saved_tf->tf_cs = USER_CS;
  101f18:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101f1d:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
  101f23:	8b 35 a4 08 11 00    	mov    0x1108a4,%esi
  101f29:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101f2e:	8b 15 a4 08 11 00    	mov    0x1108a4,%edx
  101f34:	8b 0d a4 08 11 00    	mov    0x1108a4,%ecx
  101f3a:	8b 1d a4 08 11 00    	mov    0x1108a4,%ebx
  101f40:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
  101f46:	0f b7 5b 20          	movzwl 0x20(%ebx),%ebx
  101f4a:	66 89 59 48          	mov    %bx,0x48(%ecx)
  101f4e:	0f b7 49 48          	movzwl 0x48(%ecx),%ecx
  101f52:	66 89 4a 24          	mov    %cx,0x24(%edx)
  101f56:	0f b7 52 24          	movzwl 0x24(%edx),%edx
  101f5a:	66 89 50 28          	mov    %dx,0x28(%eax)
  101f5e:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101f62:	66 89 46 2c          	mov    %ax,0x2c(%esi)
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
  101f66:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101f6b:	8b 15 a4 08 11 00    	mov    0x1108a4,%edx
  101f71:	83 c2 4c             	add    $0x4c,%edx
  101f74:	89 50 44             	mov    %edx,0x44(%eax)
            saved_tf->tf_trapno = 0x21;
  101f77:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  101f7c:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
            print_trapframe(tf);
  101f83:	8b 45 08             	mov    0x8(%ebp),%eax
  101f86:	89 04 24             	mov    %eax,(%esp)
  101f89:	e8 78 fb ff ff       	call   101b06 <print_trapframe>
        }   
        break;
  101f8e:	e9 2d 01 00 00       	jmp    1020c0 <trap_dispatch+0x336>
  101f93:	8b 45 08             	mov    0x8(%ebp),%eax
  101f96:	89 45 ec             	mov    %eax,-0x14(%ebp)
        saved_tf->tf_trapno = 0x21;
    }
}

static inline __attribute__((always_inline)) void switch_to_user(struct trapframe *tf) {
    if (tf->tf_cs != USER_CS) {
  101f99:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101f9c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101fa0:	83 f8 1b             	cmp    $0x1b,%eax
  101fa3:	0f 84 1a 01 00 00    	je     1020c3 <trap_dispatch+0x339>
     
        tf->tf_eflags |= FL_IOPL_MASK;
  101fa9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fac:	8b 40 40             	mov    0x40(%eax),%eax
  101faf:	0d 00 30 00 00       	or     $0x3000,%eax
  101fb4:	89 c2                	mov    %eax,%edx
  101fb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fb9:	89 50 40             	mov    %edx,0x40(%eax)
        tf->tf_cs = USER_CS;
  101fbc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fbf:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = USER_DS;
  101fc5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fc8:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
  101fce:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fd1:	0f b7 50 24          	movzwl 0x24(%eax),%edx
  101fd5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fd8:	66 89 50 48          	mov    %dx,0x48(%eax)
  101fdc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fdf:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  101fe3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fe6:	66 89 50 20          	mov    %dx,0x20(%eax)
  101fea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101fed:	0f b7 50 20          	movzwl 0x20(%eax),%edx
  101ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101ff4:	66 89 50 28          	mov    %dx,0x28(%eax)
  101ff8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101ffb:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101fff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102002:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        saved_tf->tf_trapno = 0x21;
  102006:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  10200b:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
        break;

    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
  102012:	e9 ac 00 00 00       	jmp    1020c3 <trap_dispatch+0x339>
  102017:	8b 45 08             	mov    0x8(%ebp),%eax
  10201a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        : "i"(T_SWITCH_TOK)
        );
}

static inline __attribute__((always_inline)) void switch_to_kernel(struct trapframe *tf) {
    if (tf->tf_cs != KERNEL_CS) {
  10201d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102020:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102024:	83 f8 08             	cmp    $0x8,%eax
  102027:	0f 84 99 00 00 00    	je     1020c6 <trap_dispatch+0x33c>
        tf->tf_cs = KERNEL_CS;
  10202d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102030:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = KERNEL_DS;
  102036:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102039:	66 c7 40 24 10 00    	movw   $0x10,0x24(%eax)
  10203f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102042:	0f b7 50 24          	movzwl 0x24(%eax),%edx
  102046:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102049:	66 89 50 48          	mov    %dx,0x48(%eax)
  10204d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102050:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  102054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102057:	66 89 50 20          	mov    %dx,0x20(%eax)
  10205b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10205e:	0f b7 50 20          	movzwl 0x20(%eax),%edx
  102062:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102065:	66 89 50 28          	mov    %dx,0x28(%eax)
  102069:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10206c:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  102070:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102073:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        saved_tf->tf_trapno = 0x21;
  102077:	a1 a4 08 11 00       	mov    0x1108a4,%eax
  10207c:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
    case T_SWITCH_TOK:
        switch_to_kernel(tf);
        break;
  102083:	eb 41                	jmp    1020c6 <trap_dispatch+0x33c>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  102085:	8b 45 08             	mov    0x8(%ebp),%eax
  102088:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  10208c:	83 e0 03             	and    $0x3,%eax
  10208f:	85 c0                	test   %eax,%eax
  102091:	75 34                	jne    1020c7 <trap_dispatch+0x33d>
            print_trapframe(tf);
  102093:	8b 45 08             	mov    0x8(%ebp),%eax
  102096:	89 04 24             	mov    %eax,(%esp)
  102099:	e8 68 fa ff ff       	call   101b06 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  10209e:	c7 44 24 08 f5 3d 10 	movl   $0x103df5,0x8(%esp)
  1020a5:	00 
  1020a6:	c7 44 24 04 11 01 00 	movl   $0x111,0x4(%esp)
  1020ad:	00 
  1020ae:	c7 04 24 11 3e 10 00 	movl   $0x103e11,(%esp)
  1020b5:	e8 09 e3 ff ff       	call   1003c3 <__panic>
        switch_to_kernel(tf);
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  1020ba:	90                   	nop
  1020bb:	eb 0a                	jmp    1020c7 <trap_dispatch+0x33d>
        count++;
        if(count == TICK_NUM){
            count = 0;
            print_ticks();
        }
        break;
  1020bd:	90                   	nop
  1020be:	eb 07                	jmp    1020c7 <trap_dispatch+0x33d>
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
            saved_tf->tf_trapno = 0x21;
            print_trapframe(tf);
        }   
        break;
  1020c0:	90                   	nop
  1020c1:	eb 04                	jmp    1020c7 <trap_dispatch+0x33d>

    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
  1020c3:	90                   	nop
  1020c4:	eb 01                	jmp    1020c7 <trap_dispatch+0x33d>
    case T_SWITCH_TOK:
        switch_to_kernel(tf);
        break;
  1020c6:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  1020c7:	90                   	nop
  1020c8:	83 c4 20             	add    $0x20,%esp
  1020cb:	5b                   	pop    %ebx
  1020cc:	5e                   	pop    %esi
  1020cd:	5d                   	pop    %ebp
  1020ce:	c3                   	ret    

001020cf <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  1020cf:	55                   	push   %ebp
  1020d0:	89 e5                	mov    %esp,%ebp
  1020d2:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  1020d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1020d8:	89 04 24             	mov    %eax,(%esp)
  1020db:	e8 aa fc ff ff       	call   101d8a <trap_dispatch>
}
  1020e0:	90                   	nop
  1020e1:	c9                   	leave  
  1020e2:	c3                   	ret    

001020e3 <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  1020e3:	6a 00                	push   $0x0
  pushl $0
  1020e5:	6a 00                	push   $0x0
  jmp __alltraps
  1020e7:	e9 69 0a 00 00       	jmp    102b55 <__alltraps>

001020ec <vector1>:
.globl vector1
vector1:
  pushl $0
  1020ec:	6a 00                	push   $0x0
  pushl $1
  1020ee:	6a 01                	push   $0x1
  jmp __alltraps
  1020f0:	e9 60 0a 00 00       	jmp    102b55 <__alltraps>

001020f5 <vector2>:
.globl vector2
vector2:
  pushl $0
  1020f5:	6a 00                	push   $0x0
  pushl $2
  1020f7:	6a 02                	push   $0x2
  jmp __alltraps
  1020f9:	e9 57 0a 00 00       	jmp    102b55 <__alltraps>

001020fe <vector3>:
.globl vector3
vector3:
  pushl $0
  1020fe:	6a 00                	push   $0x0
  pushl $3
  102100:	6a 03                	push   $0x3
  jmp __alltraps
  102102:	e9 4e 0a 00 00       	jmp    102b55 <__alltraps>

00102107 <vector4>:
.globl vector4
vector4:
  pushl $0
  102107:	6a 00                	push   $0x0
  pushl $4
  102109:	6a 04                	push   $0x4
  jmp __alltraps
  10210b:	e9 45 0a 00 00       	jmp    102b55 <__alltraps>

00102110 <vector5>:
.globl vector5
vector5:
  pushl $0
  102110:	6a 00                	push   $0x0
  pushl $5
  102112:	6a 05                	push   $0x5
  jmp __alltraps
  102114:	e9 3c 0a 00 00       	jmp    102b55 <__alltraps>

00102119 <vector6>:
.globl vector6
vector6:
  pushl $0
  102119:	6a 00                	push   $0x0
  pushl $6
  10211b:	6a 06                	push   $0x6
  jmp __alltraps
  10211d:	e9 33 0a 00 00       	jmp    102b55 <__alltraps>

00102122 <vector7>:
.globl vector7
vector7:
  pushl $0
  102122:	6a 00                	push   $0x0
  pushl $7
  102124:	6a 07                	push   $0x7
  jmp __alltraps
  102126:	e9 2a 0a 00 00       	jmp    102b55 <__alltraps>

0010212b <vector8>:
.globl vector8
vector8:
  pushl $8
  10212b:	6a 08                	push   $0x8
  jmp __alltraps
  10212d:	e9 23 0a 00 00       	jmp    102b55 <__alltraps>

00102132 <vector9>:
.globl vector9
vector9:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $9
  102134:	6a 09                	push   $0x9
  jmp __alltraps
  102136:	e9 1a 0a 00 00       	jmp    102b55 <__alltraps>

0010213b <vector10>:
.globl vector10
vector10:
  pushl $10
  10213b:	6a 0a                	push   $0xa
  jmp __alltraps
  10213d:	e9 13 0a 00 00       	jmp    102b55 <__alltraps>

00102142 <vector11>:
.globl vector11
vector11:
  pushl $11
  102142:	6a 0b                	push   $0xb
  jmp __alltraps
  102144:	e9 0c 0a 00 00       	jmp    102b55 <__alltraps>

00102149 <vector12>:
.globl vector12
vector12:
  pushl $12
  102149:	6a 0c                	push   $0xc
  jmp __alltraps
  10214b:	e9 05 0a 00 00       	jmp    102b55 <__alltraps>

00102150 <vector13>:
.globl vector13
vector13:
  pushl $13
  102150:	6a 0d                	push   $0xd
  jmp __alltraps
  102152:	e9 fe 09 00 00       	jmp    102b55 <__alltraps>

00102157 <vector14>:
.globl vector14
vector14:
  pushl $14
  102157:	6a 0e                	push   $0xe
  jmp __alltraps
  102159:	e9 f7 09 00 00       	jmp    102b55 <__alltraps>

0010215e <vector15>:
.globl vector15
vector15:
  pushl $0
  10215e:	6a 00                	push   $0x0
  pushl $15
  102160:	6a 0f                	push   $0xf
  jmp __alltraps
  102162:	e9 ee 09 00 00       	jmp    102b55 <__alltraps>

00102167 <vector16>:
.globl vector16
vector16:
  pushl $0
  102167:	6a 00                	push   $0x0
  pushl $16
  102169:	6a 10                	push   $0x10
  jmp __alltraps
  10216b:	e9 e5 09 00 00       	jmp    102b55 <__alltraps>

00102170 <vector17>:
.globl vector17
vector17:
  pushl $17
  102170:	6a 11                	push   $0x11
  jmp __alltraps
  102172:	e9 de 09 00 00       	jmp    102b55 <__alltraps>

00102177 <vector18>:
.globl vector18
vector18:
  pushl $0
  102177:	6a 00                	push   $0x0
  pushl $18
  102179:	6a 12                	push   $0x12
  jmp __alltraps
  10217b:	e9 d5 09 00 00       	jmp    102b55 <__alltraps>

00102180 <vector19>:
.globl vector19
vector19:
  pushl $0
  102180:	6a 00                	push   $0x0
  pushl $19
  102182:	6a 13                	push   $0x13
  jmp __alltraps
  102184:	e9 cc 09 00 00       	jmp    102b55 <__alltraps>

00102189 <vector20>:
.globl vector20
vector20:
  pushl $0
  102189:	6a 00                	push   $0x0
  pushl $20
  10218b:	6a 14                	push   $0x14
  jmp __alltraps
  10218d:	e9 c3 09 00 00       	jmp    102b55 <__alltraps>

00102192 <vector21>:
.globl vector21
vector21:
  pushl $0
  102192:	6a 00                	push   $0x0
  pushl $21
  102194:	6a 15                	push   $0x15
  jmp __alltraps
  102196:	e9 ba 09 00 00       	jmp    102b55 <__alltraps>

0010219b <vector22>:
.globl vector22
vector22:
  pushl $0
  10219b:	6a 00                	push   $0x0
  pushl $22
  10219d:	6a 16                	push   $0x16
  jmp __alltraps
  10219f:	e9 b1 09 00 00       	jmp    102b55 <__alltraps>

001021a4 <vector23>:
.globl vector23
vector23:
  pushl $0
  1021a4:	6a 00                	push   $0x0
  pushl $23
  1021a6:	6a 17                	push   $0x17
  jmp __alltraps
  1021a8:	e9 a8 09 00 00       	jmp    102b55 <__alltraps>

001021ad <vector24>:
.globl vector24
vector24:
  pushl $0
  1021ad:	6a 00                	push   $0x0
  pushl $24
  1021af:	6a 18                	push   $0x18
  jmp __alltraps
  1021b1:	e9 9f 09 00 00       	jmp    102b55 <__alltraps>

001021b6 <vector25>:
.globl vector25
vector25:
  pushl $0
  1021b6:	6a 00                	push   $0x0
  pushl $25
  1021b8:	6a 19                	push   $0x19
  jmp __alltraps
  1021ba:	e9 96 09 00 00       	jmp    102b55 <__alltraps>

001021bf <vector26>:
.globl vector26
vector26:
  pushl $0
  1021bf:	6a 00                	push   $0x0
  pushl $26
  1021c1:	6a 1a                	push   $0x1a
  jmp __alltraps
  1021c3:	e9 8d 09 00 00       	jmp    102b55 <__alltraps>

001021c8 <vector27>:
.globl vector27
vector27:
  pushl $0
  1021c8:	6a 00                	push   $0x0
  pushl $27
  1021ca:	6a 1b                	push   $0x1b
  jmp __alltraps
  1021cc:	e9 84 09 00 00       	jmp    102b55 <__alltraps>

001021d1 <vector28>:
.globl vector28
vector28:
  pushl $0
  1021d1:	6a 00                	push   $0x0
  pushl $28
  1021d3:	6a 1c                	push   $0x1c
  jmp __alltraps
  1021d5:	e9 7b 09 00 00       	jmp    102b55 <__alltraps>

001021da <vector29>:
.globl vector29
vector29:
  pushl $0
  1021da:	6a 00                	push   $0x0
  pushl $29
  1021dc:	6a 1d                	push   $0x1d
  jmp __alltraps
  1021de:	e9 72 09 00 00       	jmp    102b55 <__alltraps>

001021e3 <vector30>:
.globl vector30
vector30:
  pushl $0
  1021e3:	6a 00                	push   $0x0
  pushl $30
  1021e5:	6a 1e                	push   $0x1e
  jmp __alltraps
  1021e7:	e9 69 09 00 00       	jmp    102b55 <__alltraps>

001021ec <vector31>:
.globl vector31
vector31:
  pushl $0
  1021ec:	6a 00                	push   $0x0
  pushl $31
  1021ee:	6a 1f                	push   $0x1f
  jmp __alltraps
  1021f0:	e9 60 09 00 00       	jmp    102b55 <__alltraps>

001021f5 <vector32>:
.globl vector32
vector32:
  pushl $0
  1021f5:	6a 00                	push   $0x0
  pushl $32
  1021f7:	6a 20                	push   $0x20
  jmp __alltraps
  1021f9:	e9 57 09 00 00       	jmp    102b55 <__alltraps>

001021fe <vector33>:
.globl vector33
vector33:
  pushl $0
  1021fe:	6a 00                	push   $0x0
  pushl $33
  102200:	6a 21                	push   $0x21
  jmp __alltraps
  102202:	e9 4e 09 00 00       	jmp    102b55 <__alltraps>

00102207 <vector34>:
.globl vector34
vector34:
  pushl $0
  102207:	6a 00                	push   $0x0
  pushl $34
  102209:	6a 22                	push   $0x22
  jmp __alltraps
  10220b:	e9 45 09 00 00       	jmp    102b55 <__alltraps>

00102210 <vector35>:
.globl vector35
vector35:
  pushl $0
  102210:	6a 00                	push   $0x0
  pushl $35
  102212:	6a 23                	push   $0x23
  jmp __alltraps
  102214:	e9 3c 09 00 00       	jmp    102b55 <__alltraps>

00102219 <vector36>:
.globl vector36
vector36:
  pushl $0
  102219:	6a 00                	push   $0x0
  pushl $36
  10221b:	6a 24                	push   $0x24
  jmp __alltraps
  10221d:	e9 33 09 00 00       	jmp    102b55 <__alltraps>

00102222 <vector37>:
.globl vector37
vector37:
  pushl $0
  102222:	6a 00                	push   $0x0
  pushl $37
  102224:	6a 25                	push   $0x25
  jmp __alltraps
  102226:	e9 2a 09 00 00       	jmp    102b55 <__alltraps>

0010222b <vector38>:
.globl vector38
vector38:
  pushl $0
  10222b:	6a 00                	push   $0x0
  pushl $38
  10222d:	6a 26                	push   $0x26
  jmp __alltraps
  10222f:	e9 21 09 00 00       	jmp    102b55 <__alltraps>

00102234 <vector39>:
.globl vector39
vector39:
  pushl $0
  102234:	6a 00                	push   $0x0
  pushl $39
  102236:	6a 27                	push   $0x27
  jmp __alltraps
  102238:	e9 18 09 00 00       	jmp    102b55 <__alltraps>

0010223d <vector40>:
.globl vector40
vector40:
  pushl $0
  10223d:	6a 00                	push   $0x0
  pushl $40
  10223f:	6a 28                	push   $0x28
  jmp __alltraps
  102241:	e9 0f 09 00 00       	jmp    102b55 <__alltraps>

00102246 <vector41>:
.globl vector41
vector41:
  pushl $0
  102246:	6a 00                	push   $0x0
  pushl $41
  102248:	6a 29                	push   $0x29
  jmp __alltraps
  10224a:	e9 06 09 00 00       	jmp    102b55 <__alltraps>

0010224f <vector42>:
.globl vector42
vector42:
  pushl $0
  10224f:	6a 00                	push   $0x0
  pushl $42
  102251:	6a 2a                	push   $0x2a
  jmp __alltraps
  102253:	e9 fd 08 00 00       	jmp    102b55 <__alltraps>

00102258 <vector43>:
.globl vector43
vector43:
  pushl $0
  102258:	6a 00                	push   $0x0
  pushl $43
  10225a:	6a 2b                	push   $0x2b
  jmp __alltraps
  10225c:	e9 f4 08 00 00       	jmp    102b55 <__alltraps>

00102261 <vector44>:
.globl vector44
vector44:
  pushl $0
  102261:	6a 00                	push   $0x0
  pushl $44
  102263:	6a 2c                	push   $0x2c
  jmp __alltraps
  102265:	e9 eb 08 00 00       	jmp    102b55 <__alltraps>

0010226a <vector45>:
.globl vector45
vector45:
  pushl $0
  10226a:	6a 00                	push   $0x0
  pushl $45
  10226c:	6a 2d                	push   $0x2d
  jmp __alltraps
  10226e:	e9 e2 08 00 00       	jmp    102b55 <__alltraps>

00102273 <vector46>:
.globl vector46
vector46:
  pushl $0
  102273:	6a 00                	push   $0x0
  pushl $46
  102275:	6a 2e                	push   $0x2e
  jmp __alltraps
  102277:	e9 d9 08 00 00       	jmp    102b55 <__alltraps>

0010227c <vector47>:
.globl vector47
vector47:
  pushl $0
  10227c:	6a 00                	push   $0x0
  pushl $47
  10227e:	6a 2f                	push   $0x2f
  jmp __alltraps
  102280:	e9 d0 08 00 00       	jmp    102b55 <__alltraps>

00102285 <vector48>:
.globl vector48
vector48:
  pushl $0
  102285:	6a 00                	push   $0x0
  pushl $48
  102287:	6a 30                	push   $0x30
  jmp __alltraps
  102289:	e9 c7 08 00 00       	jmp    102b55 <__alltraps>

0010228e <vector49>:
.globl vector49
vector49:
  pushl $0
  10228e:	6a 00                	push   $0x0
  pushl $49
  102290:	6a 31                	push   $0x31
  jmp __alltraps
  102292:	e9 be 08 00 00       	jmp    102b55 <__alltraps>

00102297 <vector50>:
.globl vector50
vector50:
  pushl $0
  102297:	6a 00                	push   $0x0
  pushl $50
  102299:	6a 32                	push   $0x32
  jmp __alltraps
  10229b:	e9 b5 08 00 00       	jmp    102b55 <__alltraps>

001022a0 <vector51>:
.globl vector51
vector51:
  pushl $0
  1022a0:	6a 00                	push   $0x0
  pushl $51
  1022a2:	6a 33                	push   $0x33
  jmp __alltraps
  1022a4:	e9 ac 08 00 00       	jmp    102b55 <__alltraps>

001022a9 <vector52>:
.globl vector52
vector52:
  pushl $0
  1022a9:	6a 00                	push   $0x0
  pushl $52
  1022ab:	6a 34                	push   $0x34
  jmp __alltraps
  1022ad:	e9 a3 08 00 00       	jmp    102b55 <__alltraps>

001022b2 <vector53>:
.globl vector53
vector53:
  pushl $0
  1022b2:	6a 00                	push   $0x0
  pushl $53
  1022b4:	6a 35                	push   $0x35
  jmp __alltraps
  1022b6:	e9 9a 08 00 00       	jmp    102b55 <__alltraps>

001022bb <vector54>:
.globl vector54
vector54:
  pushl $0
  1022bb:	6a 00                	push   $0x0
  pushl $54
  1022bd:	6a 36                	push   $0x36
  jmp __alltraps
  1022bf:	e9 91 08 00 00       	jmp    102b55 <__alltraps>

001022c4 <vector55>:
.globl vector55
vector55:
  pushl $0
  1022c4:	6a 00                	push   $0x0
  pushl $55
  1022c6:	6a 37                	push   $0x37
  jmp __alltraps
  1022c8:	e9 88 08 00 00       	jmp    102b55 <__alltraps>

001022cd <vector56>:
.globl vector56
vector56:
  pushl $0
  1022cd:	6a 00                	push   $0x0
  pushl $56
  1022cf:	6a 38                	push   $0x38
  jmp __alltraps
  1022d1:	e9 7f 08 00 00       	jmp    102b55 <__alltraps>

001022d6 <vector57>:
.globl vector57
vector57:
  pushl $0
  1022d6:	6a 00                	push   $0x0
  pushl $57
  1022d8:	6a 39                	push   $0x39
  jmp __alltraps
  1022da:	e9 76 08 00 00       	jmp    102b55 <__alltraps>

001022df <vector58>:
.globl vector58
vector58:
  pushl $0
  1022df:	6a 00                	push   $0x0
  pushl $58
  1022e1:	6a 3a                	push   $0x3a
  jmp __alltraps
  1022e3:	e9 6d 08 00 00       	jmp    102b55 <__alltraps>

001022e8 <vector59>:
.globl vector59
vector59:
  pushl $0
  1022e8:	6a 00                	push   $0x0
  pushl $59
  1022ea:	6a 3b                	push   $0x3b
  jmp __alltraps
  1022ec:	e9 64 08 00 00       	jmp    102b55 <__alltraps>

001022f1 <vector60>:
.globl vector60
vector60:
  pushl $0
  1022f1:	6a 00                	push   $0x0
  pushl $60
  1022f3:	6a 3c                	push   $0x3c
  jmp __alltraps
  1022f5:	e9 5b 08 00 00       	jmp    102b55 <__alltraps>

001022fa <vector61>:
.globl vector61
vector61:
  pushl $0
  1022fa:	6a 00                	push   $0x0
  pushl $61
  1022fc:	6a 3d                	push   $0x3d
  jmp __alltraps
  1022fe:	e9 52 08 00 00       	jmp    102b55 <__alltraps>

00102303 <vector62>:
.globl vector62
vector62:
  pushl $0
  102303:	6a 00                	push   $0x0
  pushl $62
  102305:	6a 3e                	push   $0x3e
  jmp __alltraps
  102307:	e9 49 08 00 00       	jmp    102b55 <__alltraps>

0010230c <vector63>:
.globl vector63
vector63:
  pushl $0
  10230c:	6a 00                	push   $0x0
  pushl $63
  10230e:	6a 3f                	push   $0x3f
  jmp __alltraps
  102310:	e9 40 08 00 00       	jmp    102b55 <__alltraps>

00102315 <vector64>:
.globl vector64
vector64:
  pushl $0
  102315:	6a 00                	push   $0x0
  pushl $64
  102317:	6a 40                	push   $0x40
  jmp __alltraps
  102319:	e9 37 08 00 00       	jmp    102b55 <__alltraps>

0010231e <vector65>:
.globl vector65
vector65:
  pushl $0
  10231e:	6a 00                	push   $0x0
  pushl $65
  102320:	6a 41                	push   $0x41
  jmp __alltraps
  102322:	e9 2e 08 00 00       	jmp    102b55 <__alltraps>

00102327 <vector66>:
.globl vector66
vector66:
  pushl $0
  102327:	6a 00                	push   $0x0
  pushl $66
  102329:	6a 42                	push   $0x42
  jmp __alltraps
  10232b:	e9 25 08 00 00       	jmp    102b55 <__alltraps>

00102330 <vector67>:
.globl vector67
vector67:
  pushl $0
  102330:	6a 00                	push   $0x0
  pushl $67
  102332:	6a 43                	push   $0x43
  jmp __alltraps
  102334:	e9 1c 08 00 00       	jmp    102b55 <__alltraps>

00102339 <vector68>:
.globl vector68
vector68:
  pushl $0
  102339:	6a 00                	push   $0x0
  pushl $68
  10233b:	6a 44                	push   $0x44
  jmp __alltraps
  10233d:	e9 13 08 00 00       	jmp    102b55 <__alltraps>

00102342 <vector69>:
.globl vector69
vector69:
  pushl $0
  102342:	6a 00                	push   $0x0
  pushl $69
  102344:	6a 45                	push   $0x45
  jmp __alltraps
  102346:	e9 0a 08 00 00       	jmp    102b55 <__alltraps>

0010234b <vector70>:
.globl vector70
vector70:
  pushl $0
  10234b:	6a 00                	push   $0x0
  pushl $70
  10234d:	6a 46                	push   $0x46
  jmp __alltraps
  10234f:	e9 01 08 00 00       	jmp    102b55 <__alltraps>

00102354 <vector71>:
.globl vector71
vector71:
  pushl $0
  102354:	6a 00                	push   $0x0
  pushl $71
  102356:	6a 47                	push   $0x47
  jmp __alltraps
  102358:	e9 f8 07 00 00       	jmp    102b55 <__alltraps>

0010235d <vector72>:
.globl vector72
vector72:
  pushl $0
  10235d:	6a 00                	push   $0x0
  pushl $72
  10235f:	6a 48                	push   $0x48
  jmp __alltraps
  102361:	e9 ef 07 00 00       	jmp    102b55 <__alltraps>

00102366 <vector73>:
.globl vector73
vector73:
  pushl $0
  102366:	6a 00                	push   $0x0
  pushl $73
  102368:	6a 49                	push   $0x49
  jmp __alltraps
  10236a:	e9 e6 07 00 00       	jmp    102b55 <__alltraps>

0010236f <vector74>:
.globl vector74
vector74:
  pushl $0
  10236f:	6a 00                	push   $0x0
  pushl $74
  102371:	6a 4a                	push   $0x4a
  jmp __alltraps
  102373:	e9 dd 07 00 00       	jmp    102b55 <__alltraps>

00102378 <vector75>:
.globl vector75
vector75:
  pushl $0
  102378:	6a 00                	push   $0x0
  pushl $75
  10237a:	6a 4b                	push   $0x4b
  jmp __alltraps
  10237c:	e9 d4 07 00 00       	jmp    102b55 <__alltraps>

00102381 <vector76>:
.globl vector76
vector76:
  pushl $0
  102381:	6a 00                	push   $0x0
  pushl $76
  102383:	6a 4c                	push   $0x4c
  jmp __alltraps
  102385:	e9 cb 07 00 00       	jmp    102b55 <__alltraps>

0010238a <vector77>:
.globl vector77
vector77:
  pushl $0
  10238a:	6a 00                	push   $0x0
  pushl $77
  10238c:	6a 4d                	push   $0x4d
  jmp __alltraps
  10238e:	e9 c2 07 00 00       	jmp    102b55 <__alltraps>

00102393 <vector78>:
.globl vector78
vector78:
  pushl $0
  102393:	6a 00                	push   $0x0
  pushl $78
  102395:	6a 4e                	push   $0x4e
  jmp __alltraps
  102397:	e9 b9 07 00 00       	jmp    102b55 <__alltraps>

0010239c <vector79>:
.globl vector79
vector79:
  pushl $0
  10239c:	6a 00                	push   $0x0
  pushl $79
  10239e:	6a 4f                	push   $0x4f
  jmp __alltraps
  1023a0:	e9 b0 07 00 00       	jmp    102b55 <__alltraps>

001023a5 <vector80>:
.globl vector80
vector80:
  pushl $0
  1023a5:	6a 00                	push   $0x0
  pushl $80
  1023a7:	6a 50                	push   $0x50
  jmp __alltraps
  1023a9:	e9 a7 07 00 00       	jmp    102b55 <__alltraps>

001023ae <vector81>:
.globl vector81
vector81:
  pushl $0
  1023ae:	6a 00                	push   $0x0
  pushl $81
  1023b0:	6a 51                	push   $0x51
  jmp __alltraps
  1023b2:	e9 9e 07 00 00       	jmp    102b55 <__alltraps>

001023b7 <vector82>:
.globl vector82
vector82:
  pushl $0
  1023b7:	6a 00                	push   $0x0
  pushl $82
  1023b9:	6a 52                	push   $0x52
  jmp __alltraps
  1023bb:	e9 95 07 00 00       	jmp    102b55 <__alltraps>

001023c0 <vector83>:
.globl vector83
vector83:
  pushl $0
  1023c0:	6a 00                	push   $0x0
  pushl $83
  1023c2:	6a 53                	push   $0x53
  jmp __alltraps
  1023c4:	e9 8c 07 00 00       	jmp    102b55 <__alltraps>

001023c9 <vector84>:
.globl vector84
vector84:
  pushl $0
  1023c9:	6a 00                	push   $0x0
  pushl $84
  1023cb:	6a 54                	push   $0x54
  jmp __alltraps
  1023cd:	e9 83 07 00 00       	jmp    102b55 <__alltraps>

001023d2 <vector85>:
.globl vector85
vector85:
  pushl $0
  1023d2:	6a 00                	push   $0x0
  pushl $85
  1023d4:	6a 55                	push   $0x55
  jmp __alltraps
  1023d6:	e9 7a 07 00 00       	jmp    102b55 <__alltraps>

001023db <vector86>:
.globl vector86
vector86:
  pushl $0
  1023db:	6a 00                	push   $0x0
  pushl $86
  1023dd:	6a 56                	push   $0x56
  jmp __alltraps
  1023df:	e9 71 07 00 00       	jmp    102b55 <__alltraps>

001023e4 <vector87>:
.globl vector87
vector87:
  pushl $0
  1023e4:	6a 00                	push   $0x0
  pushl $87
  1023e6:	6a 57                	push   $0x57
  jmp __alltraps
  1023e8:	e9 68 07 00 00       	jmp    102b55 <__alltraps>

001023ed <vector88>:
.globl vector88
vector88:
  pushl $0
  1023ed:	6a 00                	push   $0x0
  pushl $88
  1023ef:	6a 58                	push   $0x58
  jmp __alltraps
  1023f1:	e9 5f 07 00 00       	jmp    102b55 <__alltraps>

001023f6 <vector89>:
.globl vector89
vector89:
  pushl $0
  1023f6:	6a 00                	push   $0x0
  pushl $89
  1023f8:	6a 59                	push   $0x59
  jmp __alltraps
  1023fa:	e9 56 07 00 00       	jmp    102b55 <__alltraps>

001023ff <vector90>:
.globl vector90
vector90:
  pushl $0
  1023ff:	6a 00                	push   $0x0
  pushl $90
  102401:	6a 5a                	push   $0x5a
  jmp __alltraps
  102403:	e9 4d 07 00 00       	jmp    102b55 <__alltraps>

00102408 <vector91>:
.globl vector91
vector91:
  pushl $0
  102408:	6a 00                	push   $0x0
  pushl $91
  10240a:	6a 5b                	push   $0x5b
  jmp __alltraps
  10240c:	e9 44 07 00 00       	jmp    102b55 <__alltraps>

00102411 <vector92>:
.globl vector92
vector92:
  pushl $0
  102411:	6a 00                	push   $0x0
  pushl $92
  102413:	6a 5c                	push   $0x5c
  jmp __alltraps
  102415:	e9 3b 07 00 00       	jmp    102b55 <__alltraps>

0010241a <vector93>:
.globl vector93
vector93:
  pushl $0
  10241a:	6a 00                	push   $0x0
  pushl $93
  10241c:	6a 5d                	push   $0x5d
  jmp __alltraps
  10241e:	e9 32 07 00 00       	jmp    102b55 <__alltraps>

00102423 <vector94>:
.globl vector94
vector94:
  pushl $0
  102423:	6a 00                	push   $0x0
  pushl $94
  102425:	6a 5e                	push   $0x5e
  jmp __alltraps
  102427:	e9 29 07 00 00       	jmp    102b55 <__alltraps>

0010242c <vector95>:
.globl vector95
vector95:
  pushl $0
  10242c:	6a 00                	push   $0x0
  pushl $95
  10242e:	6a 5f                	push   $0x5f
  jmp __alltraps
  102430:	e9 20 07 00 00       	jmp    102b55 <__alltraps>

00102435 <vector96>:
.globl vector96
vector96:
  pushl $0
  102435:	6a 00                	push   $0x0
  pushl $96
  102437:	6a 60                	push   $0x60
  jmp __alltraps
  102439:	e9 17 07 00 00       	jmp    102b55 <__alltraps>

0010243e <vector97>:
.globl vector97
vector97:
  pushl $0
  10243e:	6a 00                	push   $0x0
  pushl $97
  102440:	6a 61                	push   $0x61
  jmp __alltraps
  102442:	e9 0e 07 00 00       	jmp    102b55 <__alltraps>

00102447 <vector98>:
.globl vector98
vector98:
  pushl $0
  102447:	6a 00                	push   $0x0
  pushl $98
  102449:	6a 62                	push   $0x62
  jmp __alltraps
  10244b:	e9 05 07 00 00       	jmp    102b55 <__alltraps>

00102450 <vector99>:
.globl vector99
vector99:
  pushl $0
  102450:	6a 00                	push   $0x0
  pushl $99
  102452:	6a 63                	push   $0x63
  jmp __alltraps
  102454:	e9 fc 06 00 00       	jmp    102b55 <__alltraps>

00102459 <vector100>:
.globl vector100
vector100:
  pushl $0
  102459:	6a 00                	push   $0x0
  pushl $100
  10245b:	6a 64                	push   $0x64
  jmp __alltraps
  10245d:	e9 f3 06 00 00       	jmp    102b55 <__alltraps>

00102462 <vector101>:
.globl vector101
vector101:
  pushl $0
  102462:	6a 00                	push   $0x0
  pushl $101
  102464:	6a 65                	push   $0x65
  jmp __alltraps
  102466:	e9 ea 06 00 00       	jmp    102b55 <__alltraps>

0010246b <vector102>:
.globl vector102
vector102:
  pushl $0
  10246b:	6a 00                	push   $0x0
  pushl $102
  10246d:	6a 66                	push   $0x66
  jmp __alltraps
  10246f:	e9 e1 06 00 00       	jmp    102b55 <__alltraps>

00102474 <vector103>:
.globl vector103
vector103:
  pushl $0
  102474:	6a 00                	push   $0x0
  pushl $103
  102476:	6a 67                	push   $0x67
  jmp __alltraps
  102478:	e9 d8 06 00 00       	jmp    102b55 <__alltraps>

0010247d <vector104>:
.globl vector104
vector104:
  pushl $0
  10247d:	6a 00                	push   $0x0
  pushl $104
  10247f:	6a 68                	push   $0x68
  jmp __alltraps
  102481:	e9 cf 06 00 00       	jmp    102b55 <__alltraps>

00102486 <vector105>:
.globl vector105
vector105:
  pushl $0
  102486:	6a 00                	push   $0x0
  pushl $105
  102488:	6a 69                	push   $0x69
  jmp __alltraps
  10248a:	e9 c6 06 00 00       	jmp    102b55 <__alltraps>

0010248f <vector106>:
.globl vector106
vector106:
  pushl $0
  10248f:	6a 00                	push   $0x0
  pushl $106
  102491:	6a 6a                	push   $0x6a
  jmp __alltraps
  102493:	e9 bd 06 00 00       	jmp    102b55 <__alltraps>

00102498 <vector107>:
.globl vector107
vector107:
  pushl $0
  102498:	6a 00                	push   $0x0
  pushl $107
  10249a:	6a 6b                	push   $0x6b
  jmp __alltraps
  10249c:	e9 b4 06 00 00       	jmp    102b55 <__alltraps>

001024a1 <vector108>:
.globl vector108
vector108:
  pushl $0
  1024a1:	6a 00                	push   $0x0
  pushl $108
  1024a3:	6a 6c                	push   $0x6c
  jmp __alltraps
  1024a5:	e9 ab 06 00 00       	jmp    102b55 <__alltraps>

001024aa <vector109>:
.globl vector109
vector109:
  pushl $0
  1024aa:	6a 00                	push   $0x0
  pushl $109
  1024ac:	6a 6d                	push   $0x6d
  jmp __alltraps
  1024ae:	e9 a2 06 00 00       	jmp    102b55 <__alltraps>

001024b3 <vector110>:
.globl vector110
vector110:
  pushl $0
  1024b3:	6a 00                	push   $0x0
  pushl $110
  1024b5:	6a 6e                	push   $0x6e
  jmp __alltraps
  1024b7:	e9 99 06 00 00       	jmp    102b55 <__alltraps>

001024bc <vector111>:
.globl vector111
vector111:
  pushl $0
  1024bc:	6a 00                	push   $0x0
  pushl $111
  1024be:	6a 6f                	push   $0x6f
  jmp __alltraps
  1024c0:	e9 90 06 00 00       	jmp    102b55 <__alltraps>

001024c5 <vector112>:
.globl vector112
vector112:
  pushl $0
  1024c5:	6a 00                	push   $0x0
  pushl $112
  1024c7:	6a 70                	push   $0x70
  jmp __alltraps
  1024c9:	e9 87 06 00 00       	jmp    102b55 <__alltraps>

001024ce <vector113>:
.globl vector113
vector113:
  pushl $0
  1024ce:	6a 00                	push   $0x0
  pushl $113
  1024d0:	6a 71                	push   $0x71
  jmp __alltraps
  1024d2:	e9 7e 06 00 00       	jmp    102b55 <__alltraps>

001024d7 <vector114>:
.globl vector114
vector114:
  pushl $0
  1024d7:	6a 00                	push   $0x0
  pushl $114
  1024d9:	6a 72                	push   $0x72
  jmp __alltraps
  1024db:	e9 75 06 00 00       	jmp    102b55 <__alltraps>

001024e0 <vector115>:
.globl vector115
vector115:
  pushl $0
  1024e0:	6a 00                	push   $0x0
  pushl $115
  1024e2:	6a 73                	push   $0x73
  jmp __alltraps
  1024e4:	e9 6c 06 00 00       	jmp    102b55 <__alltraps>

001024e9 <vector116>:
.globl vector116
vector116:
  pushl $0
  1024e9:	6a 00                	push   $0x0
  pushl $116
  1024eb:	6a 74                	push   $0x74
  jmp __alltraps
  1024ed:	e9 63 06 00 00       	jmp    102b55 <__alltraps>

001024f2 <vector117>:
.globl vector117
vector117:
  pushl $0
  1024f2:	6a 00                	push   $0x0
  pushl $117
  1024f4:	6a 75                	push   $0x75
  jmp __alltraps
  1024f6:	e9 5a 06 00 00       	jmp    102b55 <__alltraps>

001024fb <vector118>:
.globl vector118
vector118:
  pushl $0
  1024fb:	6a 00                	push   $0x0
  pushl $118
  1024fd:	6a 76                	push   $0x76
  jmp __alltraps
  1024ff:	e9 51 06 00 00       	jmp    102b55 <__alltraps>

00102504 <vector119>:
.globl vector119
vector119:
  pushl $0
  102504:	6a 00                	push   $0x0
  pushl $119
  102506:	6a 77                	push   $0x77
  jmp __alltraps
  102508:	e9 48 06 00 00       	jmp    102b55 <__alltraps>

0010250d <vector120>:
.globl vector120
vector120:
  pushl $0
  10250d:	6a 00                	push   $0x0
  pushl $120
  10250f:	6a 78                	push   $0x78
  jmp __alltraps
  102511:	e9 3f 06 00 00       	jmp    102b55 <__alltraps>

00102516 <vector121>:
.globl vector121
vector121:
  pushl $0
  102516:	6a 00                	push   $0x0
  pushl $121
  102518:	6a 79                	push   $0x79
  jmp __alltraps
  10251a:	e9 36 06 00 00       	jmp    102b55 <__alltraps>

0010251f <vector122>:
.globl vector122
vector122:
  pushl $0
  10251f:	6a 00                	push   $0x0
  pushl $122
  102521:	6a 7a                	push   $0x7a
  jmp __alltraps
  102523:	e9 2d 06 00 00       	jmp    102b55 <__alltraps>

00102528 <vector123>:
.globl vector123
vector123:
  pushl $0
  102528:	6a 00                	push   $0x0
  pushl $123
  10252a:	6a 7b                	push   $0x7b
  jmp __alltraps
  10252c:	e9 24 06 00 00       	jmp    102b55 <__alltraps>

00102531 <vector124>:
.globl vector124
vector124:
  pushl $0
  102531:	6a 00                	push   $0x0
  pushl $124
  102533:	6a 7c                	push   $0x7c
  jmp __alltraps
  102535:	e9 1b 06 00 00       	jmp    102b55 <__alltraps>

0010253a <vector125>:
.globl vector125
vector125:
  pushl $0
  10253a:	6a 00                	push   $0x0
  pushl $125
  10253c:	6a 7d                	push   $0x7d
  jmp __alltraps
  10253e:	e9 12 06 00 00       	jmp    102b55 <__alltraps>

00102543 <vector126>:
.globl vector126
vector126:
  pushl $0
  102543:	6a 00                	push   $0x0
  pushl $126
  102545:	6a 7e                	push   $0x7e
  jmp __alltraps
  102547:	e9 09 06 00 00       	jmp    102b55 <__alltraps>

0010254c <vector127>:
.globl vector127
vector127:
  pushl $0
  10254c:	6a 00                	push   $0x0
  pushl $127
  10254e:	6a 7f                	push   $0x7f
  jmp __alltraps
  102550:	e9 00 06 00 00       	jmp    102b55 <__alltraps>

00102555 <vector128>:
.globl vector128
vector128:
  pushl $0
  102555:	6a 00                	push   $0x0
  pushl $128
  102557:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  10255c:	e9 f4 05 00 00       	jmp    102b55 <__alltraps>

00102561 <vector129>:
.globl vector129
vector129:
  pushl $0
  102561:	6a 00                	push   $0x0
  pushl $129
  102563:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102568:	e9 e8 05 00 00       	jmp    102b55 <__alltraps>

0010256d <vector130>:
.globl vector130
vector130:
  pushl $0
  10256d:	6a 00                	push   $0x0
  pushl $130
  10256f:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  102574:	e9 dc 05 00 00       	jmp    102b55 <__alltraps>

00102579 <vector131>:
.globl vector131
vector131:
  pushl $0
  102579:	6a 00                	push   $0x0
  pushl $131
  10257b:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102580:	e9 d0 05 00 00       	jmp    102b55 <__alltraps>

00102585 <vector132>:
.globl vector132
vector132:
  pushl $0
  102585:	6a 00                	push   $0x0
  pushl $132
  102587:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  10258c:	e9 c4 05 00 00       	jmp    102b55 <__alltraps>

00102591 <vector133>:
.globl vector133
vector133:
  pushl $0
  102591:	6a 00                	push   $0x0
  pushl $133
  102593:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102598:	e9 b8 05 00 00       	jmp    102b55 <__alltraps>

0010259d <vector134>:
.globl vector134
vector134:
  pushl $0
  10259d:	6a 00                	push   $0x0
  pushl $134
  10259f:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1025a4:	e9 ac 05 00 00       	jmp    102b55 <__alltraps>

001025a9 <vector135>:
.globl vector135
vector135:
  pushl $0
  1025a9:	6a 00                	push   $0x0
  pushl $135
  1025ab:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1025b0:	e9 a0 05 00 00       	jmp    102b55 <__alltraps>

001025b5 <vector136>:
.globl vector136
vector136:
  pushl $0
  1025b5:	6a 00                	push   $0x0
  pushl $136
  1025b7:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1025bc:	e9 94 05 00 00       	jmp    102b55 <__alltraps>

001025c1 <vector137>:
.globl vector137
vector137:
  pushl $0
  1025c1:	6a 00                	push   $0x0
  pushl $137
  1025c3:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1025c8:	e9 88 05 00 00       	jmp    102b55 <__alltraps>

001025cd <vector138>:
.globl vector138
vector138:
  pushl $0
  1025cd:	6a 00                	push   $0x0
  pushl $138
  1025cf:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1025d4:	e9 7c 05 00 00       	jmp    102b55 <__alltraps>

001025d9 <vector139>:
.globl vector139
vector139:
  pushl $0
  1025d9:	6a 00                	push   $0x0
  pushl $139
  1025db:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  1025e0:	e9 70 05 00 00       	jmp    102b55 <__alltraps>

001025e5 <vector140>:
.globl vector140
vector140:
  pushl $0
  1025e5:	6a 00                	push   $0x0
  pushl $140
  1025e7:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  1025ec:	e9 64 05 00 00       	jmp    102b55 <__alltraps>

001025f1 <vector141>:
.globl vector141
vector141:
  pushl $0
  1025f1:	6a 00                	push   $0x0
  pushl $141
  1025f3:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1025f8:	e9 58 05 00 00       	jmp    102b55 <__alltraps>

001025fd <vector142>:
.globl vector142
vector142:
  pushl $0
  1025fd:	6a 00                	push   $0x0
  pushl $142
  1025ff:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  102604:	e9 4c 05 00 00       	jmp    102b55 <__alltraps>

00102609 <vector143>:
.globl vector143
vector143:
  pushl $0
  102609:	6a 00                	push   $0x0
  pushl $143
  10260b:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  102610:	e9 40 05 00 00       	jmp    102b55 <__alltraps>

00102615 <vector144>:
.globl vector144
vector144:
  pushl $0
  102615:	6a 00                	push   $0x0
  pushl $144
  102617:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  10261c:	e9 34 05 00 00       	jmp    102b55 <__alltraps>

00102621 <vector145>:
.globl vector145
vector145:
  pushl $0
  102621:	6a 00                	push   $0x0
  pushl $145
  102623:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102628:	e9 28 05 00 00       	jmp    102b55 <__alltraps>

0010262d <vector146>:
.globl vector146
vector146:
  pushl $0
  10262d:	6a 00                	push   $0x0
  pushl $146
  10262f:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  102634:	e9 1c 05 00 00       	jmp    102b55 <__alltraps>

00102639 <vector147>:
.globl vector147
vector147:
  pushl $0
  102639:	6a 00                	push   $0x0
  pushl $147
  10263b:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  102640:	e9 10 05 00 00       	jmp    102b55 <__alltraps>

00102645 <vector148>:
.globl vector148
vector148:
  pushl $0
  102645:	6a 00                	push   $0x0
  pushl $148
  102647:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  10264c:	e9 04 05 00 00       	jmp    102b55 <__alltraps>

00102651 <vector149>:
.globl vector149
vector149:
  pushl $0
  102651:	6a 00                	push   $0x0
  pushl $149
  102653:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102658:	e9 f8 04 00 00       	jmp    102b55 <__alltraps>

0010265d <vector150>:
.globl vector150
vector150:
  pushl $0
  10265d:	6a 00                	push   $0x0
  pushl $150
  10265f:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  102664:	e9 ec 04 00 00       	jmp    102b55 <__alltraps>

00102669 <vector151>:
.globl vector151
vector151:
  pushl $0
  102669:	6a 00                	push   $0x0
  pushl $151
  10266b:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102670:	e9 e0 04 00 00       	jmp    102b55 <__alltraps>

00102675 <vector152>:
.globl vector152
vector152:
  pushl $0
  102675:	6a 00                	push   $0x0
  pushl $152
  102677:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  10267c:	e9 d4 04 00 00       	jmp    102b55 <__alltraps>

00102681 <vector153>:
.globl vector153
vector153:
  pushl $0
  102681:	6a 00                	push   $0x0
  pushl $153
  102683:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102688:	e9 c8 04 00 00       	jmp    102b55 <__alltraps>

0010268d <vector154>:
.globl vector154
vector154:
  pushl $0
  10268d:	6a 00                	push   $0x0
  pushl $154
  10268f:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  102694:	e9 bc 04 00 00       	jmp    102b55 <__alltraps>

00102699 <vector155>:
.globl vector155
vector155:
  pushl $0
  102699:	6a 00                	push   $0x0
  pushl $155
  10269b:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1026a0:	e9 b0 04 00 00       	jmp    102b55 <__alltraps>

001026a5 <vector156>:
.globl vector156
vector156:
  pushl $0
  1026a5:	6a 00                	push   $0x0
  pushl $156
  1026a7:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1026ac:	e9 a4 04 00 00       	jmp    102b55 <__alltraps>

001026b1 <vector157>:
.globl vector157
vector157:
  pushl $0
  1026b1:	6a 00                	push   $0x0
  pushl $157
  1026b3:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1026b8:	e9 98 04 00 00       	jmp    102b55 <__alltraps>

001026bd <vector158>:
.globl vector158
vector158:
  pushl $0
  1026bd:	6a 00                	push   $0x0
  pushl $158
  1026bf:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1026c4:	e9 8c 04 00 00       	jmp    102b55 <__alltraps>

001026c9 <vector159>:
.globl vector159
vector159:
  pushl $0
  1026c9:	6a 00                	push   $0x0
  pushl $159
  1026cb:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1026d0:	e9 80 04 00 00       	jmp    102b55 <__alltraps>

001026d5 <vector160>:
.globl vector160
vector160:
  pushl $0
  1026d5:	6a 00                	push   $0x0
  pushl $160
  1026d7:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  1026dc:	e9 74 04 00 00       	jmp    102b55 <__alltraps>

001026e1 <vector161>:
.globl vector161
vector161:
  pushl $0
  1026e1:	6a 00                	push   $0x0
  pushl $161
  1026e3:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  1026e8:	e9 68 04 00 00       	jmp    102b55 <__alltraps>

001026ed <vector162>:
.globl vector162
vector162:
  pushl $0
  1026ed:	6a 00                	push   $0x0
  pushl $162
  1026ef:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  1026f4:	e9 5c 04 00 00       	jmp    102b55 <__alltraps>

001026f9 <vector163>:
.globl vector163
vector163:
  pushl $0
  1026f9:	6a 00                	push   $0x0
  pushl $163
  1026fb:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  102700:	e9 50 04 00 00       	jmp    102b55 <__alltraps>

00102705 <vector164>:
.globl vector164
vector164:
  pushl $0
  102705:	6a 00                	push   $0x0
  pushl $164
  102707:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  10270c:	e9 44 04 00 00       	jmp    102b55 <__alltraps>

00102711 <vector165>:
.globl vector165
vector165:
  pushl $0
  102711:	6a 00                	push   $0x0
  pushl $165
  102713:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102718:	e9 38 04 00 00       	jmp    102b55 <__alltraps>

0010271d <vector166>:
.globl vector166
vector166:
  pushl $0
  10271d:	6a 00                	push   $0x0
  pushl $166
  10271f:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  102724:	e9 2c 04 00 00       	jmp    102b55 <__alltraps>

00102729 <vector167>:
.globl vector167
vector167:
  pushl $0
  102729:	6a 00                	push   $0x0
  pushl $167
  10272b:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  102730:	e9 20 04 00 00       	jmp    102b55 <__alltraps>

00102735 <vector168>:
.globl vector168
vector168:
  pushl $0
  102735:	6a 00                	push   $0x0
  pushl $168
  102737:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  10273c:	e9 14 04 00 00       	jmp    102b55 <__alltraps>

00102741 <vector169>:
.globl vector169
vector169:
  pushl $0
  102741:	6a 00                	push   $0x0
  pushl $169
  102743:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102748:	e9 08 04 00 00       	jmp    102b55 <__alltraps>

0010274d <vector170>:
.globl vector170
vector170:
  pushl $0
  10274d:	6a 00                	push   $0x0
  pushl $170
  10274f:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  102754:	e9 fc 03 00 00       	jmp    102b55 <__alltraps>

00102759 <vector171>:
.globl vector171
vector171:
  pushl $0
  102759:	6a 00                	push   $0x0
  pushl $171
  10275b:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102760:	e9 f0 03 00 00       	jmp    102b55 <__alltraps>

00102765 <vector172>:
.globl vector172
vector172:
  pushl $0
  102765:	6a 00                	push   $0x0
  pushl $172
  102767:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  10276c:	e9 e4 03 00 00       	jmp    102b55 <__alltraps>

00102771 <vector173>:
.globl vector173
vector173:
  pushl $0
  102771:	6a 00                	push   $0x0
  pushl $173
  102773:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102778:	e9 d8 03 00 00       	jmp    102b55 <__alltraps>

0010277d <vector174>:
.globl vector174
vector174:
  pushl $0
  10277d:	6a 00                	push   $0x0
  pushl $174
  10277f:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  102784:	e9 cc 03 00 00       	jmp    102b55 <__alltraps>

00102789 <vector175>:
.globl vector175
vector175:
  pushl $0
  102789:	6a 00                	push   $0x0
  pushl $175
  10278b:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102790:	e9 c0 03 00 00       	jmp    102b55 <__alltraps>

00102795 <vector176>:
.globl vector176
vector176:
  pushl $0
  102795:	6a 00                	push   $0x0
  pushl $176
  102797:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  10279c:	e9 b4 03 00 00       	jmp    102b55 <__alltraps>

001027a1 <vector177>:
.globl vector177
vector177:
  pushl $0
  1027a1:	6a 00                	push   $0x0
  pushl $177
  1027a3:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1027a8:	e9 a8 03 00 00       	jmp    102b55 <__alltraps>

001027ad <vector178>:
.globl vector178
vector178:
  pushl $0
  1027ad:	6a 00                	push   $0x0
  pushl $178
  1027af:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1027b4:	e9 9c 03 00 00       	jmp    102b55 <__alltraps>

001027b9 <vector179>:
.globl vector179
vector179:
  pushl $0
  1027b9:	6a 00                	push   $0x0
  pushl $179
  1027bb:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1027c0:	e9 90 03 00 00       	jmp    102b55 <__alltraps>

001027c5 <vector180>:
.globl vector180
vector180:
  pushl $0
  1027c5:	6a 00                	push   $0x0
  pushl $180
  1027c7:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1027cc:	e9 84 03 00 00       	jmp    102b55 <__alltraps>

001027d1 <vector181>:
.globl vector181
vector181:
  pushl $0
  1027d1:	6a 00                	push   $0x0
  pushl $181
  1027d3:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  1027d8:	e9 78 03 00 00       	jmp    102b55 <__alltraps>

001027dd <vector182>:
.globl vector182
vector182:
  pushl $0
  1027dd:	6a 00                	push   $0x0
  pushl $182
  1027df:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  1027e4:	e9 6c 03 00 00       	jmp    102b55 <__alltraps>

001027e9 <vector183>:
.globl vector183
vector183:
  pushl $0
  1027e9:	6a 00                	push   $0x0
  pushl $183
  1027eb:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  1027f0:	e9 60 03 00 00       	jmp    102b55 <__alltraps>

001027f5 <vector184>:
.globl vector184
vector184:
  pushl $0
  1027f5:	6a 00                	push   $0x0
  pushl $184
  1027f7:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1027fc:	e9 54 03 00 00       	jmp    102b55 <__alltraps>

00102801 <vector185>:
.globl vector185
vector185:
  pushl $0
  102801:	6a 00                	push   $0x0
  pushl $185
  102803:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102808:	e9 48 03 00 00       	jmp    102b55 <__alltraps>

0010280d <vector186>:
.globl vector186
vector186:
  pushl $0
  10280d:	6a 00                	push   $0x0
  pushl $186
  10280f:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  102814:	e9 3c 03 00 00       	jmp    102b55 <__alltraps>

00102819 <vector187>:
.globl vector187
vector187:
  pushl $0
  102819:	6a 00                	push   $0x0
  pushl $187
  10281b:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  102820:	e9 30 03 00 00       	jmp    102b55 <__alltraps>

00102825 <vector188>:
.globl vector188
vector188:
  pushl $0
  102825:	6a 00                	push   $0x0
  pushl $188
  102827:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  10282c:	e9 24 03 00 00       	jmp    102b55 <__alltraps>

00102831 <vector189>:
.globl vector189
vector189:
  pushl $0
  102831:	6a 00                	push   $0x0
  pushl $189
  102833:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102838:	e9 18 03 00 00       	jmp    102b55 <__alltraps>

0010283d <vector190>:
.globl vector190
vector190:
  pushl $0
  10283d:	6a 00                	push   $0x0
  pushl $190
  10283f:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  102844:	e9 0c 03 00 00       	jmp    102b55 <__alltraps>

00102849 <vector191>:
.globl vector191
vector191:
  pushl $0
  102849:	6a 00                	push   $0x0
  pushl $191
  10284b:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  102850:	e9 00 03 00 00       	jmp    102b55 <__alltraps>

00102855 <vector192>:
.globl vector192
vector192:
  pushl $0
  102855:	6a 00                	push   $0x0
  pushl $192
  102857:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  10285c:	e9 f4 02 00 00       	jmp    102b55 <__alltraps>

00102861 <vector193>:
.globl vector193
vector193:
  pushl $0
  102861:	6a 00                	push   $0x0
  pushl $193
  102863:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102868:	e9 e8 02 00 00       	jmp    102b55 <__alltraps>

0010286d <vector194>:
.globl vector194
vector194:
  pushl $0
  10286d:	6a 00                	push   $0x0
  pushl $194
  10286f:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  102874:	e9 dc 02 00 00       	jmp    102b55 <__alltraps>

00102879 <vector195>:
.globl vector195
vector195:
  pushl $0
  102879:	6a 00                	push   $0x0
  pushl $195
  10287b:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102880:	e9 d0 02 00 00       	jmp    102b55 <__alltraps>

00102885 <vector196>:
.globl vector196
vector196:
  pushl $0
  102885:	6a 00                	push   $0x0
  pushl $196
  102887:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  10288c:	e9 c4 02 00 00       	jmp    102b55 <__alltraps>

00102891 <vector197>:
.globl vector197
vector197:
  pushl $0
  102891:	6a 00                	push   $0x0
  pushl $197
  102893:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102898:	e9 b8 02 00 00       	jmp    102b55 <__alltraps>

0010289d <vector198>:
.globl vector198
vector198:
  pushl $0
  10289d:	6a 00                	push   $0x0
  pushl $198
  10289f:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1028a4:	e9 ac 02 00 00       	jmp    102b55 <__alltraps>

001028a9 <vector199>:
.globl vector199
vector199:
  pushl $0
  1028a9:	6a 00                	push   $0x0
  pushl $199
  1028ab:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1028b0:	e9 a0 02 00 00       	jmp    102b55 <__alltraps>

001028b5 <vector200>:
.globl vector200
vector200:
  pushl $0
  1028b5:	6a 00                	push   $0x0
  pushl $200
  1028b7:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1028bc:	e9 94 02 00 00       	jmp    102b55 <__alltraps>

001028c1 <vector201>:
.globl vector201
vector201:
  pushl $0
  1028c1:	6a 00                	push   $0x0
  pushl $201
  1028c3:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1028c8:	e9 88 02 00 00       	jmp    102b55 <__alltraps>

001028cd <vector202>:
.globl vector202
vector202:
  pushl $0
  1028cd:	6a 00                	push   $0x0
  pushl $202
  1028cf:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1028d4:	e9 7c 02 00 00       	jmp    102b55 <__alltraps>

001028d9 <vector203>:
.globl vector203
vector203:
  pushl $0
  1028d9:	6a 00                	push   $0x0
  pushl $203
  1028db:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  1028e0:	e9 70 02 00 00       	jmp    102b55 <__alltraps>

001028e5 <vector204>:
.globl vector204
vector204:
  pushl $0
  1028e5:	6a 00                	push   $0x0
  pushl $204
  1028e7:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  1028ec:	e9 64 02 00 00       	jmp    102b55 <__alltraps>

001028f1 <vector205>:
.globl vector205
vector205:
  pushl $0
  1028f1:	6a 00                	push   $0x0
  pushl $205
  1028f3:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1028f8:	e9 58 02 00 00       	jmp    102b55 <__alltraps>

001028fd <vector206>:
.globl vector206
vector206:
  pushl $0
  1028fd:	6a 00                	push   $0x0
  pushl $206
  1028ff:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  102904:	e9 4c 02 00 00       	jmp    102b55 <__alltraps>

00102909 <vector207>:
.globl vector207
vector207:
  pushl $0
  102909:	6a 00                	push   $0x0
  pushl $207
  10290b:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  102910:	e9 40 02 00 00       	jmp    102b55 <__alltraps>

00102915 <vector208>:
.globl vector208
vector208:
  pushl $0
  102915:	6a 00                	push   $0x0
  pushl $208
  102917:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  10291c:	e9 34 02 00 00       	jmp    102b55 <__alltraps>

00102921 <vector209>:
.globl vector209
vector209:
  pushl $0
  102921:	6a 00                	push   $0x0
  pushl $209
  102923:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102928:	e9 28 02 00 00       	jmp    102b55 <__alltraps>

0010292d <vector210>:
.globl vector210
vector210:
  pushl $0
  10292d:	6a 00                	push   $0x0
  pushl $210
  10292f:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  102934:	e9 1c 02 00 00       	jmp    102b55 <__alltraps>

00102939 <vector211>:
.globl vector211
vector211:
  pushl $0
  102939:	6a 00                	push   $0x0
  pushl $211
  10293b:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  102940:	e9 10 02 00 00       	jmp    102b55 <__alltraps>

00102945 <vector212>:
.globl vector212
vector212:
  pushl $0
  102945:	6a 00                	push   $0x0
  pushl $212
  102947:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  10294c:	e9 04 02 00 00       	jmp    102b55 <__alltraps>

00102951 <vector213>:
.globl vector213
vector213:
  pushl $0
  102951:	6a 00                	push   $0x0
  pushl $213
  102953:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102958:	e9 f8 01 00 00       	jmp    102b55 <__alltraps>

0010295d <vector214>:
.globl vector214
vector214:
  pushl $0
  10295d:	6a 00                	push   $0x0
  pushl $214
  10295f:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102964:	e9 ec 01 00 00       	jmp    102b55 <__alltraps>

00102969 <vector215>:
.globl vector215
vector215:
  pushl $0
  102969:	6a 00                	push   $0x0
  pushl $215
  10296b:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102970:	e9 e0 01 00 00       	jmp    102b55 <__alltraps>

00102975 <vector216>:
.globl vector216
vector216:
  pushl $0
  102975:	6a 00                	push   $0x0
  pushl $216
  102977:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  10297c:	e9 d4 01 00 00       	jmp    102b55 <__alltraps>

00102981 <vector217>:
.globl vector217
vector217:
  pushl $0
  102981:	6a 00                	push   $0x0
  pushl $217
  102983:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102988:	e9 c8 01 00 00       	jmp    102b55 <__alltraps>

0010298d <vector218>:
.globl vector218
vector218:
  pushl $0
  10298d:	6a 00                	push   $0x0
  pushl $218
  10298f:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102994:	e9 bc 01 00 00       	jmp    102b55 <__alltraps>

00102999 <vector219>:
.globl vector219
vector219:
  pushl $0
  102999:	6a 00                	push   $0x0
  pushl $219
  10299b:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1029a0:	e9 b0 01 00 00       	jmp    102b55 <__alltraps>

001029a5 <vector220>:
.globl vector220
vector220:
  pushl $0
  1029a5:	6a 00                	push   $0x0
  pushl $220
  1029a7:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1029ac:	e9 a4 01 00 00       	jmp    102b55 <__alltraps>

001029b1 <vector221>:
.globl vector221
vector221:
  pushl $0
  1029b1:	6a 00                	push   $0x0
  pushl $221
  1029b3:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1029b8:	e9 98 01 00 00       	jmp    102b55 <__alltraps>

001029bd <vector222>:
.globl vector222
vector222:
  pushl $0
  1029bd:	6a 00                	push   $0x0
  pushl $222
  1029bf:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1029c4:	e9 8c 01 00 00       	jmp    102b55 <__alltraps>

001029c9 <vector223>:
.globl vector223
vector223:
  pushl $0
  1029c9:	6a 00                	push   $0x0
  pushl $223
  1029cb:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1029d0:	e9 80 01 00 00       	jmp    102b55 <__alltraps>

001029d5 <vector224>:
.globl vector224
vector224:
  pushl $0
  1029d5:	6a 00                	push   $0x0
  pushl $224
  1029d7:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  1029dc:	e9 74 01 00 00       	jmp    102b55 <__alltraps>

001029e1 <vector225>:
.globl vector225
vector225:
  pushl $0
  1029e1:	6a 00                	push   $0x0
  pushl $225
  1029e3:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  1029e8:	e9 68 01 00 00       	jmp    102b55 <__alltraps>

001029ed <vector226>:
.globl vector226
vector226:
  pushl $0
  1029ed:	6a 00                	push   $0x0
  pushl $226
  1029ef:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  1029f4:	e9 5c 01 00 00       	jmp    102b55 <__alltraps>

001029f9 <vector227>:
.globl vector227
vector227:
  pushl $0
  1029f9:	6a 00                	push   $0x0
  pushl $227
  1029fb:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102a00:	e9 50 01 00 00       	jmp    102b55 <__alltraps>

00102a05 <vector228>:
.globl vector228
vector228:
  pushl $0
  102a05:	6a 00                	push   $0x0
  pushl $228
  102a07:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102a0c:	e9 44 01 00 00       	jmp    102b55 <__alltraps>

00102a11 <vector229>:
.globl vector229
vector229:
  pushl $0
  102a11:	6a 00                	push   $0x0
  pushl $229
  102a13:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102a18:	e9 38 01 00 00       	jmp    102b55 <__alltraps>

00102a1d <vector230>:
.globl vector230
vector230:
  pushl $0
  102a1d:	6a 00                	push   $0x0
  pushl $230
  102a1f:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102a24:	e9 2c 01 00 00       	jmp    102b55 <__alltraps>

00102a29 <vector231>:
.globl vector231
vector231:
  pushl $0
  102a29:	6a 00                	push   $0x0
  pushl $231
  102a2b:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102a30:	e9 20 01 00 00       	jmp    102b55 <__alltraps>

00102a35 <vector232>:
.globl vector232
vector232:
  pushl $0
  102a35:	6a 00                	push   $0x0
  pushl $232
  102a37:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102a3c:	e9 14 01 00 00       	jmp    102b55 <__alltraps>

00102a41 <vector233>:
.globl vector233
vector233:
  pushl $0
  102a41:	6a 00                	push   $0x0
  pushl $233
  102a43:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102a48:	e9 08 01 00 00       	jmp    102b55 <__alltraps>

00102a4d <vector234>:
.globl vector234
vector234:
  pushl $0
  102a4d:	6a 00                	push   $0x0
  pushl $234
  102a4f:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102a54:	e9 fc 00 00 00       	jmp    102b55 <__alltraps>

00102a59 <vector235>:
.globl vector235
vector235:
  pushl $0
  102a59:	6a 00                	push   $0x0
  pushl $235
  102a5b:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102a60:	e9 f0 00 00 00       	jmp    102b55 <__alltraps>

00102a65 <vector236>:
.globl vector236
vector236:
  pushl $0
  102a65:	6a 00                	push   $0x0
  pushl $236
  102a67:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102a6c:	e9 e4 00 00 00       	jmp    102b55 <__alltraps>

00102a71 <vector237>:
.globl vector237
vector237:
  pushl $0
  102a71:	6a 00                	push   $0x0
  pushl $237
  102a73:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102a78:	e9 d8 00 00 00       	jmp    102b55 <__alltraps>

00102a7d <vector238>:
.globl vector238
vector238:
  pushl $0
  102a7d:	6a 00                	push   $0x0
  pushl $238
  102a7f:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102a84:	e9 cc 00 00 00       	jmp    102b55 <__alltraps>

00102a89 <vector239>:
.globl vector239
vector239:
  pushl $0
  102a89:	6a 00                	push   $0x0
  pushl $239
  102a8b:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102a90:	e9 c0 00 00 00       	jmp    102b55 <__alltraps>

00102a95 <vector240>:
.globl vector240
vector240:
  pushl $0
  102a95:	6a 00                	push   $0x0
  pushl $240
  102a97:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102a9c:	e9 b4 00 00 00       	jmp    102b55 <__alltraps>

00102aa1 <vector241>:
.globl vector241
vector241:
  pushl $0
  102aa1:	6a 00                	push   $0x0
  pushl $241
  102aa3:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102aa8:	e9 a8 00 00 00       	jmp    102b55 <__alltraps>

00102aad <vector242>:
.globl vector242
vector242:
  pushl $0
  102aad:	6a 00                	push   $0x0
  pushl $242
  102aaf:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102ab4:	e9 9c 00 00 00       	jmp    102b55 <__alltraps>

00102ab9 <vector243>:
.globl vector243
vector243:
  pushl $0
  102ab9:	6a 00                	push   $0x0
  pushl $243
  102abb:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102ac0:	e9 90 00 00 00       	jmp    102b55 <__alltraps>

00102ac5 <vector244>:
.globl vector244
vector244:
  pushl $0
  102ac5:	6a 00                	push   $0x0
  pushl $244
  102ac7:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102acc:	e9 84 00 00 00       	jmp    102b55 <__alltraps>

00102ad1 <vector245>:
.globl vector245
vector245:
  pushl $0
  102ad1:	6a 00                	push   $0x0
  pushl $245
  102ad3:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102ad8:	e9 78 00 00 00       	jmp    102b55 <__alltraps>

00102add <vector246>:
.globl vector246
vector246:
  pushl $0
  102add:	6a 00                	push   $0x0
  pushl $246
  102adf:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102ae4:	e9 6c 00 00 00       	jmp    102b55 <__alltraps>

00102ae9 <vector247>:
.globl vector247
vector247:
  pushl $0
  102ae9:	6a 00                	push   $0x0
  pushl $247
  102aeb:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102af0:	e9 60 00 00 00       	jmp    102b55 <__alltraps>

00102af5 <vector248>:
.globl vector248
vector248:
  pushl $0
  102af5:	6a 00                	push   $0x0
  pushl $248
  102af7:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102afc:	e9 54 00 00 00       	jmp    102b55 <__alltraps>

00102b01 <vector249>:
.globl vector249
vector249:
  pushl $0
  102b01:	6a 00                	push   $0x0
  pushl $249
  102b03:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102b08:	e9 48 00 00 00       	jmp    102b55 <__alltraps>

00102b0d <vector250>:
.globl vector250
vector250:
  pushl $0
  102b0d:	6a 00                	push   $0x0
  pushl $250
  102b0f:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102b14:	e9 3c 00 00 00       	jmp    102b55 <__alltraps>

00102b19 <vector251>:
.globl vector251
vector251:
  pushl $0
  102b19:	6a 00                	push   $0x0
  pushl $251
  102b1b:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102b20:	e9 30 00 00 00       	jmp    102b55 <__alltraps>

00102b25 <vector252>:
.globl vector252
vector252:
  pushl $0
  102b25:	6a 00                	push   $0x0
  pushl $252
  102b27:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102b2c:	e9 24 00 00 00       	jmp    102b55 <__alltraps>

00102b31 <vector253>:
.globl vector253
vector253:
  pushl $0
  102b31:	6a 00                	push   $0x0
  pushl $253
  102b33:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102b38:	e9 18 00 00 00       	jmp    102b55 <__alltraps>

00102b3d <vector254>:
.globl vector254
vector254:
  pushl $0
  102b3d:	6a 00                	push   $0x0
  pushl $254
  102b3f:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102b44:	e9 0c 00 00 00       	jmp    102b55 <__alltraps>

00102b49 <vector255>:
.globl vector255
vector255:
  pushl $0
  102b49:	6a 00                	push   $0x0
  pushl $255
  102b4b:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102b50:	e9 00 00 00 00       	jmp    102b55 <__alltraps>

00102b55 <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102b55:	1e                   	push   %ds
    pushl %es
  102b56:	06                   	push   %es
    pushl %fs
  102b57:	0f a0                	push   %fs
    pushl %gs
  102b59:	0f a8                	push   %gs
    pushal
  102b5b:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102b5c:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102b61:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102b63:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102b65:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102b66:	e8 64 f5 ff ff       	call   1020cf <trap>

    # pop the pushed stack pointer
    popl %esp
  102b6b:	5c                   	pop    %esp

00102b6c <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102b6c:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102b6d:	0f a9                	pop    %gs
    popl %fs
  102b6f:	0f a1                	pop    %fs
    popl %es
  102b71:	07                   	pop    %es
    popl %ds
  102b72:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102b73:	83 c4 08             	add    $0x8,%esp
    iret
  102b76:	cf                   	iret   

00102b77 <__move_down_stack2>:

.globl __move_down_stack2 
# this function aims to move down the whole stack frame by 2 bytes so that we can insert our fake esp and ss into the trapframe
__move_down_stack2:
    pushl %ebp
  102b77:	55                   	push   %ebp
    movl %esp, %ebp
  102b78:	89 e5                	mov    %esp,%ebp

    pushl %ebx
  102b7a:	53                   	push   %ebx
    pushl %esi
  102b7b:	56                   	push   %esi
    pushl %edi
  102b7c:	57                   	push   %edi

    movl 8(%ebp), %ebx # ebx store the end (higher boundary) of current trapframe
  102b7d:	8b 5d 08             	mov    0x8(%ebp),%ebx
    movl 12(%ebp), %edi
  102b80:	8b 7d 0c             	mov    0xc(%ebp),%edi
    subl $8, -4(%edi) # fix esp which __alltraps store on stack
  102b83:	83 6f fc 08          	subl   $0x8,-0x4(%edi)
    movl %esp, %eax
  102b87:	89 e0                	mov    %esp,%eax

    cmpl %eax, %ebx
  102b89:	39 c3                	cmp    %eax,%ebx
    jle loop_end
  102b8b:	7e 0c                	jle    102b99 <loop_end>

00102b8d <loop_start>:

loop_start:
    movb (%eax), %cl
  102b8d:	8a 08                	mov    (%eax),%cl
    movb %cl, -8(%eax)
  102b8f:	88 48 f8             	mov    %cl,-0x8(%eax)
    addl $1, %eax
  102b92:	83 c0 01             	add    $0x1,%eax
    cmpl %eax, %ebx
  102b95:	39 c3                	cmp    %eax,%ebx
    jg loop_start
  102b97:	7f f4                	jg     102b8d <loop_start>

00102b99 <loop_end>:

loop_end: 
    subl $8, %esp 
  102b99:	83 ec 08             	sub    $0x8,%esp
    subl $8, %ebp # remember, it is critical to correct all the base pointer store in stack area which is affected by our operations above
  102b9c:	83 ed 08             	sub    $0x8,%ebp
    
    movl %ebp, %eax
  102b9f:	89 e8                	mov    %ebp,%eax
    cmpl %eax, %ebx
  102ba1:	39 c3                	cmp    %eax,%ebx
    jle ebp_loop_end
  102ba3:	7e 14                	jle    102bb9 <ebp_loop_end>

00102ba5 <ebp_loop_begin>:

ebp_loop_begin:
    movl (%eax), %ecx
  102ba5:	8b 08                	mov    (%eax),%ecx

    cmpl $0, %ecx
  102ba7:	83 f9 00             	cmp    $0x0,%ecx
    je ebp_loop_end
  102baa:	74 0d                	je     102bb9 <ebp_loop_end>
    cmpl %ecx, %ebx
  102bac:	39 cb                	cmp    %ecx,%ebx
    jle ebp_loop_end
  102bae:	7e 09                	jle    102bb9 <ebp_loop_end>
    subl $8, %ecx
  102bb0:	83 e9 08             	sub    $0x8,%ecx
    movl %ecx, (%eax)
  102bb3:	89 08                	mov    %ecx,(%eax)
    movl %ecx, %eax
  102bb5:	89 c8                	mov    %ecx,%eax
    jmp ebp_loop_begin
  102bb7:	eb ec                	jmp    102ba5 <ebp_loop_begin>

00102bb9 <ebp_loop_end>:

ebp_loop_end:

    popl %edi
  102bb9:	5f                   	pop    %edi
    popl %esi
  102bba:	5e                   	pop    %esi
    popl %ebx
  102bbb:	5b                   	pop    %ebx

    popl %ebp
  102bbc:	5d                   	pop    %ebp
    ret 
  102bbd:	c3                   	ret    

00102bbe <__move_up_stack2>:
# this function aims to move the trapframe along with all stack frames below up by 2 bytes
# arg1 tf_end 
# arg2 tf
# arg3 user esp
__move_up_stack2:
    pushl %ebp 
  102bbe:	55                   	push   %ebp
    movl %esp, %ebp
  102bbf:	89 e5                	mov    %esp,%ebp

    pushl %ebx
  102bc1:	53                   	push   %ebx
    pushl %edi
  102bc2:	57                   	push   %edi
    pushl %esi
  102bc3:	56                   	push   %esi

# first of all, copy every below tf_end to user stack
    movl 8(%ebp), %eax
  102bc4:	8b 45 08             	mov    0x8(%ebp),%eax
    subl $1, %eax
  102bc7:	83 e8 01             	sub    $0x1,%eax
    movl 16(%ebp), %ebx # ebx store the user stack pointer 
  102bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
    
    cmpl %eax, %esp
  102bcd:	39 c4                	cmp    %eax,%esp
    jg copy_loop_end
  102bcf:	7f 0e                	jg     102bdf <copy_loop_end>

00102bd1 <copy_loop_begin>:

copy_loop_begin:
    subl $1, %ebx
  102bd1:	83 eb 01             	sub    $0x1,%ebx
    movb (%eax), %cl
  102bd4:	8a 08                	mov    (%eax),%cl
    movb %cl, (%ebx)
  102bd6:	88 0b                	mov    %cl,(%ebx)

    subl $1, %eax
  102bd8:	83 e8 01             	sub    $0x1,%eax
    cmpl %eax, %esp
  102bdb:	39 c4                	cmp    %eax,%esp
    jle copy_loop_begin
  102bdd:	7e f2                	jle    102bd1 <copy_loop_begin>

00102bdf <copy_loop_end>:

copy_loop_end:

# now we have to fix all ebp on user stack, note that we can calculate the true ebp using their address displacement
    movl %ebp, %eax
  102bdf:	89 e8                	mov    %ebp,%eax
    cmpl %eax, 8(%ebp)
  102be1:	39 45 08             	cmp    %eax,0x8(%ebp)
    jle fix_ebp_loop_end
  102be4:	7e 20                	jle    102c06 <fix_ebp_loop_end>

00102be6 <fix_ebp_loop_begin>:

fix_ebp_loop_begin:
    movl %eax, %edi
  102be6:	89 c7                	mov    %eax,%edi
    subl 8(%ebp), %edi
  102be8:	2b 7d 08             	sub    0x8(%ebp),%edi
    addl 16(%ebp), %edi # edi <=> eax
  102beb:	03 7d 10             	add    0x10(%ebp),%edi

    cmpl (%eax), %esp 
  102bee:	3b 20                	cmp    (%eax),%esp
    jle normal_condition
  102bf0:	7e 06                	jle    102bf8 <normal_condition>
    movl (%eax), %esi
  102bf2:	8b 30                	mov    (%eax),%esi
    movl %esi, (%edi)
  102bf4:	89 37                	mov    %esi,(%edi)
    jmp fix_ebp_loop_end
  102bf6:	eb 0e                	jmp    102c06 <fix_ebp_loop_end>

00102bf8 <normal_condition>:

normal_condition:
    movl (%eax), %esi
  102bf8:	8b 30                	mov    (%eax),%esi
    subl 8(%ebp), %esi
  102bfa:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
  102bfd:	03 75 10             	add    0x10(%ebp),%esi
    movl %esi, (%edi)
  102c00:	89 37                	mov    %esi,(%edi)
    movl (%eax), %eax
  102c02:	8b 00                	mov    (%eax),%eax
    jmp fix_ebp_loop_begin
  102c04:	eb e0                	jmp    102be6 <fix_ebp_loop_begin>

00102c06 <fix_ebp_loop_end>:

fix_ebp_loop_end:

# fix the esp which __alltraps store on stack
    movl 12(%ebp), %eax
  102c06:	8b 45 0c             	mov    0xc(%ebp),%eax
    subl $4, %eax
  102c09:	83 e8 04             	sub    $0x4,%eax

    movl %eax, %edi
  102c0c:	89 c7                	mov    %eax,%edi
    subl 8(%ebp), %edi
  102c0e:	2b 7d 08             	sub    0x8(%ebp),%edi
    addl 16(%ebp), %edi
  102c11:	03 7d 10             	add    0x10(%ebp),%edi

    movl (%eax), %esi
  102c14:	8b 30                	mov    (%eax),%esi
    subl 8(%ebp), %esi
  102c16:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
  102c19:	03 75 10             	add    0x10(%ebp),%esi

    movl %esi, (%edi)
  102c1c:	89 37                	mov    %esi,(%edi)

    movl 12(%ebp), %eax
  102c1e:	8b 45 0c             	mov    0xc(%ebp),%eax
    subl 8(%ebp), %eax
  102c21:	2b 45 08             	sub    0x8(%ebp),%eax
    addl 16(%ebp), %eax
  102c24:	03 45 10             	add    0x10(%ebp),%eax

# switch to user stack
    movl %ebx, %esp
  102c27:	89 dc                	mov    %ebx,%esp
    movl %ebp, %esi
  102c29:	89 ee                	mov    %ebp,%esi
    subl 8(%ebp), %esi
  102c2b:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
  102c2e:	03 75 10             	add    0x10(%ebp),%esi
    movl %esi, %ebp
  102c31:	89 f5                	mov    %esi,%ebp

    popl %esi
  102c33:	5e                   	pop    %esi
    popl %edi
  102c34:	5f                   	pop    %edi
    popl %ebx
  102c35:	5b                   	pop    %ebx

    popl %ebp
  102c36:	5d                   	pop    %ebp
  102c37:	c3                   	ret    

00102c38 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102c38:	55                   	push   %ebp
  102c39:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  102c3e:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102c41:	b8 23 00 00 00       	mov    $0x23,%eax
  102c46:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102c48:	b8 23 00 00 00       	mov    $0x23,%eax
  102c4d:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102c4f:	b8 10 00 00 00       	mov    $0x10,%eax
  102c54:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102c56:	b8 10 00 00 00       	mov    $0x10,%eax
  102c5b:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102c5d:	b8 10 00 00 00       	mov    $0x10,%eax
  102c62:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102c64:	ea 6b 2c 10 00 08 00 	ljmp   $0x8,$0x102c6b
}
  102c6b:	90                   	nop
  102c6c:	5d                   	pop    %ebp
  102c6d:	c3                   	ret    

00102c6e <gdt_init>:
/* temporary kernel stack */
uint8_t stack0[1024];

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102c6e:	55                   	push   %ebp
  102c6f:	89 e5                	mov    %esp,%ebp
  102c71:	83 ec 14             	sub    $0x14,%esp
    // Setup a TSS so that we can get the right stack when we trap from
    // user to the kernel. But not safe here, it's only a temporary value,
    // it will be set to KSTACKTOP in lab2.
    ts.ts_esp0 = (uint32_t)&stack0 + sizeof(stack0);
  102c74:	b8 a0 09 11 00       	mov    $0x1109a0,%eax
  102c79:	05 00 04 00 00       	add    $0x400,%eax
  102c7e:	a3 c4 08 11 00       	mov    %eax,0x1108c4
    ts.ts_ss0 = KERNEL_DS;
  102c83:	66 c7 05 c8 08 11 00 	movw   $0x10,0x1108c8
  102c8a:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEG16(STS_T32A, (uint32_t)&ts, sizeof(ts), DPL_KERNEL);
  102c8c:	66 c7 05 08 fa 10 00 	movw   $0x68,0x10fa08
  102c93:	68 00 
  102c95:	b8 c0 08 11 00       	mov    $0x1108c0,%eax
  102c9a:	0f b7 c0             	movzwl %ax,%eax
  102c9d:	66 a3 0a fa 10 00    	mov    %ax,0x10fa0a
  102ca3:	b8 c0 08 11 00       	mov    $0x1108c0,%eax
  102ca8:	c1 e8 10             	shr    $0x10,%eax
  102cab:	a2 0c fa 10 00       	mov    %al,0x10fa0c
  102cb0:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102cb7:	24 f0                	and    $0xf0,%al
  102cb9:	0c 09                	or     $0x9,%al
  102cbb:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102cc0:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102cc7:	0c 10                	or     $0x10,%al
  102cc9:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102cce:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102cd5:	24 9f                	and    $0x9f,%al
  102cd7:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102cdc:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102ce3:	0c 80                	or     $0x80,%al
  102ce5:	a2 0d fa 10 00       	mov    %al,0x10fa0d
  102cea:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102cf1:	24 f0                	and    $0xf0,%al
  102cf3:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102cf8:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102cff:	24 ef                	and    $0xef,%al
  102d01:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102d06:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102d0d:	24 df                	and    $0xdf,%al
  102d0f:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102d14:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102d1b:	0c 40                	or     $0x40,%al
  102d1d:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102d22:	0f b6 05 0e fa 10 00 	movzbl 0x10fa0e,%eax
  102d29:	24 7f                	and    $0x7f,%al
  102d2b:	a2 0e fa 10 00       	mov    %al,0x10fa0e
  102d30:	b8 c0 08 11 00       	mov    $0x1108c0,%eax
  102d35:	c1 e8 18             	shr    $0x18,%eax
  102d38:	a2 0f fa 10 00       	mov    %al,0x10fa0f
    gdt[SEG_TSS].sd_s = 0;
  102d3d:	0f b6 05 0d fa 10 00 	movzbl 0x10fa0d,%eax
  102d44:	24 ef                	and    $0xef,%al
  102d46:	a2 0d fa 10 00       	mov    %al,0x10fa0d

    // reload all segment registers
    lgdt(&gdt_pd);
  102d4b:	c7 04 24 10 fa 10 00 	movl   $0x10fa10,(%esp)
  102d52:	e8 e1 fe ff ff       	call   102c38 <lgdt>
  102d57:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel));
  102d5d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102d61:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102d64:	90                   	nop
  102d65:	c9                   	leave  
  102d66:	c3                   	ret    

00102d67 <pmm_init>:

/* pmm_init - initialize the physical memory management */
void
pmm_init(void) {
  102d67:	55                   	push   %ebp
  102d68:	89 e5                	mov    %esp,%ebp
    gdt_init();
  102d6a:	e8 ff fe ff ff       	call   102c6e <gdt_init>
}
  102d6f:	90                   	nop
  102d70:	5d                   	pop    %ebp
  102d71:	c3                   	ret    

00102d72 <strlen>:
 * @s:        the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  102d72:	55                   	push   %ebp
  102d73:	89 e5                	mov    %esp,%ebp
  102d75:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102d78:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  102d7f:	eb 03                	jmp    102d84 <strlen+0x12>
        cnt ++;
  102d81:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  102d84:	8b 45 08             	mov    0x8(%ebp),%eax
  102d87:	8d 50 01             	lea    0x1(%eax),%edx
  102d8a:	89 55 08             	mov    %edx,0x8(%ebp)
  102d8d:	0f b6 00             	movzbl (%eax),%eax
  102d90:	84 c0                	test   %al,%al
  102d92:	75 ed                	jne    102d81 <strlen+0xf>
        cnt ++;
    }
    return cnt;
  102d94:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102d97:	c9                   	leave  
  102d98:	c3                   	ret    

00102d99 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  102d99:	55                   	push   %ebp
  102d9a:	89 e5                	mov    %esp,%ebp
  102d9c:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  102d9f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  102da6:	eb 03                	jmp    102dab <strnlen+0x12>
        cnt ++;
  102da8:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  102dab:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102dae:	3b 45 0c             	cmp    0xc(%ebp),%eax
  102db1:	73 10                	jae    102dc3 <strnlen+0x2a>
  102db3:	8b 45 08             	mov    0x8(%ebp),%eax
  102db6:	8d 50 01             	lea    0x1(%eax),%edx
  102db9:	89 55 08             	mov    %edx,0x8(%ebp)
  102dbc:	0f b6 00             	movzbl (%eax),%eax
  102dbf:	84 c0                	test   %al,%al
  102dc1:	75 e5                	jne    102da8 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  102dc3:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  102dc6:	c9                   	leave  
  102dc7:	c3                   	ret    

00102dc8 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  102dc8:	55                   	push   %ebp
  102dc9:	89 e5                	mov    %esp,%ebp
  102dcb:	57                   	push   %edi
  102dcc:	56                   	push   %esi
  102dcd:	83 ec 20             	sub    $0x20,%esp
  102dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  102dd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102dd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  102ddc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102ddf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102de2:	89 d1                	mov    %edx,%ecx
  102de4:	89 c2                	mov    %eax,%edx
  102de6:	89 ce                	mov    %ecx,%esi
  102de8:	89 d7                	mov    %edx,%edi
  102dea:	ac                   	lods   %ds:(%esi),%al
  102deb:	aa                   	stos   %al,%es:(%edi)
  102dec:	84 c0                	test   %al,%al
  102dee:	75 fa                	jne    102dea <strcpy+0x22>
  102df0:	89 fa                	mov    %edi,%edx
  102df2:	89 f1                	mov    %esi,%ecx
  102df4:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  102df7:	89 55 e8             	mov    %edx,-0x18(%ebp)
  102dfa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "stosb;"
            "testb %%al, %%al;"
            "jne 1b;"
            : "=&S" (d0), "=&D" (d1), "=&a" (d2)
            : "0" (src), "1" (dst) : "memory");
    return dst;
  102dfd:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  102e00:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  102e01:	83 c4 20             	add    $0x20,%esp
  102e04:	5e                   	pop    %esi
  102e05:	5f                   	pop    %edi
  102e06:	5d                   	pop    %ebp
  102e07:	c3                   	ret    

00102e08 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  102e08:	55                   	push   %ebp
  102e09:	89 e5                	mov    %esp,%ebp
  102e0b:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  102e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  102e11:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  102e14:	eb 1e                	jmp    102e34 <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  102e16:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e19:	0f b6 10             	movzbl (%eax),%edx
  102e1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102e1f:	88 10                	mov    %dl,(%eax)
  102e21:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102e24:	0f b6 00             	movzbl (%eax),%eax
  102e27:	84 c0                	test   %al,%al
  102e29:	74 03                	je     102e2e <strncpy+0x26>
            src ++;
  102e2b:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  102e2e:	ff 45 fc             	incl   -0x4(%ebp)
  102e31:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  102e34:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102e38:	75 dc                	jne    102e16 <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  102e3a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102e3d:	c9                   	leave  
  102e3e:	c3                   	ret    

00102e3f <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  102e3f:	55                   	push   %ebp
  102e40:	89 e5                	mov    %esp,%ebp
  102e42:	57                   	push   %edi
  102e43:	56                   	push   %esi
  102e44:	83 ec 20             	sub    $0x20,%esp
  102e47:	8b 45 08             	mov    0x8(%ebp),%eax
  102e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102e4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  102e50:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  102e53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102e56:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102e59:	89 d1                	mov    %edx,%ecx
  102e5b:	89 c2                	mov    %eax,%edx
  102e5d:	89 ce                	mov    %ecx,%esi
  102e5f:	89 d7                	mov    %edx,%edi
  102e61:	ac                   	lods   %ds:(%esi),%al
  102e62:	ae                   	scas   %es:(%edi),%al
  102e63:	75 08                	jne    102e6d <strcmp+0x2e>
  102e65:	84 c0                	test   %al,%al
  102e67:	75 f8                	jne    102e61 <strcmp+0x22>
  102e69:	31 c0                	xor    %eax,%eax
  102e6b:	eb 04                	jmp    102e71 <strcmp+0x32>
  102e6d:	19 c0                	sbb    %eax,%eax
  102e6f:	0c 01                	or     $0x1,%al
  102e71:	89 fa                	mov    %edi,%edx
  102e73:	89 f1                	mov    %esi,%ecx
  102e75:	89 45 ec             	mov    %eax,-0x14(%ebp)
  102e78:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  102e7b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
            "orb $1, %%al;"
            "3:"
            : "=a" (ret), "=&S" (d0), "=&D" (d1)
            : "1" (s1), "2" (s2)
            : "memory");
    return ret;
  102e7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  102e81:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  102e82:	83 c4 20             	add    $0x20,%esp
  102e85:	5e                   	pop    %esi
  102e86:	5f                   	pop    %edi
  102e87:	5d                   	pop    %ebp
  102e88:	c3                   	ret    

00102e89 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  102e89:	55                   	push   %ebp
  102e8a:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102e8c:	eb 09                	jmp    102e97 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  102e8e:	ff 4d 10             	decl   0x10(%ebp)
  102e91:	ff 45 08             	incl   0x8(%ebp)
  102e94:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  102e97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102e9b:	74 1a                	je     102eb7 <strncmp+0x2e>
  102e9d:	8b 45 08             	mov    0x8(%ebp),%eax
  102ea0:	0f b6 00             	movzbl (%eax),%eax
  102ea3:	84 c0                	test   %al,%al
  102ea5:	74 10                	je     102eb7 <strncmp+0x2e>
  102ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  102eaa:	0f b6 10             	movzbl (%eax),%edx
  102ead:	8b 45 0c             	mov    0xc(%ebp),%eax
  102eb0:	0f b6 00             	movzbl (%eax),%eax
  102eb3:	38 c2                	cmp    %al,%dl
  102eb5:	74 d7                	je     102e8e <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  102eb7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102ebb:	74 18                	je     102ed5 <strncmp+0x4c>
  102ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec0:	0f b6 00             	movzbl (%eax),%eax
  102ec3:	0f b6 d0             	movzbl %al,%edx
  102ec6:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ec9:	0f b6 00             	movzbl (%eax),%eax
  102ecc:	0f b6 c0             	movzbl %al,%eax
  102ecf:	29 c2                	sub    %eax,%edx
  102ed1:	89 d0                	mov    %edx,%eax
  102ed3:	eb 05                	jmp    102eda <strncmp+0x51>
  102ed5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102eda:	5d                   	pop    %ebp
  102edb:	c3                   	ret    

00102edc <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  102edc:	55                   	push   %ebp
  102edd:	89 e5                	mov    %esp,%ebp
  102edf:	83 ec 04             	sub    $0x4,%esp
  102ee2:	8b 45 0c             	mov    0xc(%ebp),%eax
  102ee5:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102ee8:	eb 13                	jmp    102efd <strchr+0x21>
        if (*s == c) {
  102eea:	8b 45 08             	mov    0x8(%ebp),%eax
  102eed:	0f b6 00             	movzbl (%eax),%eax
  102ef0:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102ef3:	75 05                	jne    102efa <strchr+0x1e>
            return (char *)s;
  102ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  102ef8:	eb 12                	jmp    102f0c <strchr+0x30>
        }
        s ++;
  102efa:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  102efd:	8b 45 08             	mov    0x8(%ebp),%eax
  102f00:	0f b6 00             	movzbl (%eax),%eax
  102f03:	84 c0                	test   %al,%al
  102f05:	75 e3                	jne    102eea <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  102f07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102f0c:	c9                   	leave  
  102f0d:	c3                   	ret    

00102f0e <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  102f0e:	55                   	push   %ebp
  102f0f:	89 e5                	mov    %esp,%ebp
  102f11:	83 ec 04             	sub    $0x4,%esp
  102f14:	8b 45 0c             	mov    0xc(%ebp),%eax
  102f17:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  102f1a:	eb 0e                	jmp    102f2a <strfind+0x1c>
        if (*s == c) {
  102f1c:	8b 45 08             	mov    0x8(%ebp),%eax
  102f1f:	0f b6 00             	movzbl (%eax),%eax
  102f22:	3a 45 fc             	cmp    -0x4(%ebp),%al
  102f25:	74 0f                	je     102f36 <strfind+0x28>
            break;
        }
        s ++;
  102f27:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  102f2a:	8b 45 08             	mov    0x8(%ebp),%eax
  102f2d:	0f b6 00             	movzbl (%eax),%eax
  102f30:	84 c0                	test   %al,%al
  102f32:	75 e8                	jne    102f1c <strfind+0xe>
  102f34:	eb 01                	jmp    102f37 <strfind+0x29>
        if (*s == c) {
            break;
  102f36:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  102f37:	8b 45 08             	mov    0x8(%ebp),%eax
}
  102f3a:	c9                   	leave  
  102f3b:	c3                   	ret    

00102f3c <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  102f3c:	55                   	push   %ebp
  102f3d:	89 e5                	mov    %esp,%ebp
  102f3f:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  102f42:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  102f49:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102f50:	eb 03                	jmp    102f55 <strtol+0x19>
        s ++;
  102f52:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  102f55:	8b 45 08             	mov    0x8(%ebp),%eax
  102f58:	0f b6 00             	movzbl (%eax),%eax
  102f5b:	3c 20                	cmp    $0x20,%al
  102f5d:	74 f3                	je     102f52 <strtol+0x16>
  102f5f:	8b 45 08             	mov    0x8(%ebp),%eax
  102f62:	0f b6 00             	movzbl (%eax),%eax
  102f65:	3c 09                	cmp    $0x9,%al
  102f67:	74 e9                	je     102f52 <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  102f69:	8b 45 08             	mov    0x8(%ebp),%eax
  102f6c:	0f b6 00             	movzbl (%eax),%eax
  102f6f:	3c 2b                	cmp    $0x2b,%al
  102f71:	75 05                	jne    102f78 <strtol+0x3c>
        s ++;
  102f73:	ff 45 08             	incl   0x8(%ebp)
  102f76:	eb 14                	jmp    102f8c <strtol+0x50>
    }
    else if (*s == '-') {
  102f78:	8b 45 08             	mov    0x8(%ebp),%eax
  102f7b:	0f b6 00             	movzbl (%eax),%eax
  102f7e:	3c 2d                	cmp    $0x2d,%al
  102f80:	75 0a                	jne    102f8c <strtol+0x50>
        s ++, neg = 1;
  102f82:	ff 45 08             	incl   0x8(%ebp)
  102f85:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  102f8c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102f90:	74 06                	je     102f98 <strtol+0x5c>
  102f92:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  102f96:	75 22                	jne    102fba <strtol+0x7e>
  102f98:	8b 45 08             	mov    0x8(%ebp),%eax
  102f9b:	0f b6 00             	movzbl (%eax),%eax
  102f9e:	3c 30                	cmp    $0x30,%al
  102fa0:	75 18                	jne    102fba <strtol+0x7e>
  102fa2:	8b 45 08             	mov    0x8(%ebp),%eax
  102fa5:	40                   	inc    %eax
  102fa6:	0f b6 00             	movzbl (%eax),%eax
  102fa9:	3c 78                	cmp    $0x78,%al
  102fab:	75 0d                	jne    102fba <strtol+0x7e>
        s += 2, base = 16;
  102fad:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  102fb1:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  102fb8:	eb 29                	jmp    102fe3 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  102fba:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102fbe:	75 16                	jne    102fd6 <strtol+0x9a>
  102fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  102fc3:	0f b6 00             	movzbl (%eax),%eax
  102fc6:	3c 30                	cmp    $0x30,%al
  102fc8:	75 0c                	jne    102fd6 <strtol+0x9a>
        s ++, base = 8;
  102fca:	ff 45 08             	incl   0x8(%ebp)
  102fcd:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  102fd4:	eb 0d                	jmp    102fe3 <strtol+0xa7>
    }
    else if (base == 0) {
  102fd6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  102fda:	75 07                	jne    102fe3 <strtol+0xa7>
        base = 10;
  102fdc:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  102fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  102fe6:	0f b6 00             	movzbl (%eax),%eax
  102fe9:	3c 2f                	cmp    $0x2f,%al
  102feb:	7e 1b                	jle    103008 <strtol+0xcc>
  102fed:	8b 45 08             	mov    0x8(%ebp),%eax
  102ff0:	0f b6 00             	movzbl (%eax),%eax
  102ff3:	3c 39                	cmp    $0x39,%al
  102ff5:	7f 11                	jg     103008 <strtol+0xcc>
            dig = *s - '0';
  102ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  102ffa:	0f b6 00             	movzbl (%eax),%eax
  102ffd:	0f be c0             	movsbl %al,%eax
  103000:	83 e8 30             	sub    $0x30,%eax
  103003:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103006:	eb 48                	jmp    103050 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  103008:	8b 45 08             	mov    0x8(%ebp),%eax
  10300b:	0f b6 00             	movzbl (%eax),%eax
  10300e:	3c 60                	cmp    $0x60,%al
  103010:	7e 1b                	jle    10302d <strtol+0xf1>
  103012:	8b 45 08             	mov    0x8(%ebp),%eax
  103015:	0f b6 00             	movzbl (%eax),%eax
  103018:	3c 7a                	cmp    $0x7a,%al
  10301a:	7f 11                	jg     10302d <strtol+0xf1>
            dig = *s - 'a' + 10;
  10301c:	8b 45 08             	mov    0x8(%ebp),%eax
  10301f:	0f b6 00             	movzbl (%eax),%eax
  103022:	0f be c0             	movsbl %al,%eax
  103025:	83 e8 57             	sub    $0x57,%eax
  103028:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10302b:	eb 23                	jmp    103050 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10302d:	8b 45 08             	mov    0x8(%ebp),%eax
  103030:	0f b6 00             	movzbl (%eax),%eax
  103033:	3c 40                	cmp    $0x40,%al
  103035:	7e 3b                	jle    103072 <strtol+0x136>
  103037:	8b 45 08             	mov    0x8(%ebp),%eax
  10303a:	0f b6 00             	movzbl (%eax),%eax
  10303d:	3c 5a                	cmp    $0x5a,%al
  10303f:	7f 31                	jg     103072 <strtol+0x136>
            dig = *s - 'A' + 10;
  103041:	8b 45 08             	mov    0x8(%ebp),%eax
  103044:	0f b6 00             	movzbl (%eax),%eax
  103047:	0f be c0             	movsbl %al,%eax
  10304a:	83 e8 37             	sub    $0x37,%eax
  10304d:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  103050:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103053:	3b 45 10             	cmp    0x10(%ebp),%eax
  103056:	7d 19                	jge    103071 <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  103058:	ff 45 08             	incl   0x8(%ebp)
  10305b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10305e:	0f af 45 10          	imul   0x10(%ebp),%eax
  103062:	89 c2                	mov    %eax,%edx
  103064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103067:	01 d0                	add    %edx,%eax
  103069:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  10306c:	e9 72 ff ff ff       	jmp    102fe3 <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  103071:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  103072:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103076:	74 08                	je     103080 <strtol+0x144>
        *endptr = (char *) s;
  103078:	8b 45 0c             	mov    0xc(%ebp),%eax
  10307b:	8b 55 08             	mov    0x8(%ebp),%edx
  10307e:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  103080:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  103084:	74 07                	je     10308d <strtol+0x151>
  103086:	8b 45 f8             	mov    -0x8(%ebp),%eax
  103089:	f7 d8                	neg    %eax
  10308b:	eb 03                	jmp    103090 <strtol+0x154>
  10308d:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  103090:	c9                   	leave  
  103091:	c3                   	ret    

00103092 <memset>:
 * @n:        number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  103092:	55                   	push   %ebp
  103093:	89 e5                	mov    %esp,%ebp
  103095:	57                   	push   %edi
  103096:	83 ec 24             	sub    $0x24,%esp
  103099:	8b 45 0c             	mov    0xc(%ebp),%eax
  10309c:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  10309f:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  1030a3:	8b 55 08             	mov    0x8(%ebp),%edx
  1030a6:	89 55 f8             	mov    %edx,-0x8(%ebp)
  1030a9:	88 45 f7             	mov    %al,-0x9(%ebp)
  1030ac:	8b 45 10             	mov    0x10(%ebp),%eax
  1030af:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  1030b2:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  1030b5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  1030b9:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1030bc:	89 d7                	mov    %edx,%edi
  1030be:	f3 aa                	rep stos %al,%es:(%edi)
  1030c0:	89 fa                	mov    %edi,%edx
  1030c2:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1030c5:	89 55 e8             	mov    %edx,-0x18(%ebp)
            "rep; stosb;"
            : "=&c" (d0), "=&D" (d1)
            : "0" (n), "a" (c), "1" (s)
            : "memory");
    return s;
  1030c8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1030cb:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1030cc:	83 c4 24             	add    $0x24,%esp
  1030cf:	5f                   	pop    %edi
  1030d0:	5d                   	pop    %ebp
  1030d1:	c3                   	ret    

001030d2 <memmove>:
 * @n:        number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1030d2:	55                   	push   %ebp
  1030d3:	89 e5                	mov    %esp,%ebp
  1030d5:	57                   	push   %edi
  1030d6:	56                   	push   %esi
  1030d7:	53                   	push   %ebx
  1030d8:	83 ec 30             	sub    $0x30,%esp
  1030db:	8b 45 08             	mov    0x8(%ebp),%eax
  1030de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1030e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1030e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1030e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1030ea:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1030ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030f0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1030f3:	73 42                	jae    103137 <memmove+0x65>
  1030f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1030fb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1030fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103101:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103104:	89 45 dc             	mov    %eax,-0x24(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  103107:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10310a:	c1 e8 02             	shr    $0x2,%eax
  10310d:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  10310f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103112:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103115:	89 d7                	mov    %edx,%edi
  103117:	89 c6                	mov    %eax,%esi
  103119:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  10311b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  10311e:	83 e1 03             	and    $0x3,%ecx
  103121:	74 02                	je     103125 <memmove+0x53>
  103123:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  103125:	89 f0                	mov    %esi,%eax
  103127:	89 fa                	mov    %edi,%edx
  103129:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10312c:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10312f:	89 45 d0             	mov    %eax,-0x30(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  103132:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  103135:	eb 36                	jmp    10316d <memmove+0x9b>
    asm volatile (
            "std;"
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  103137:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10313a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10313d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103140:	01 c2                	add    %eax,%edx
  103142:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103145:	8d 48 ff             	lea    -0x1(%eax),%ecx
  103148:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10314b:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  10314e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103151:	89 c1                	mov    %eax,%ecx
  103153:	89 d8                	mov    %ebx,%eax
  103155:	89 d6                	mov    %edx,%esi
  103157:	89 c7                	mov    %eax,%edi
  103159:	fd                   	std    
  10315a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10315c:	fc                   	cld    
  10315d:	89 f8                	mov    %edi,%eax
  10315f:	89 f2                	mov    %esi,%edx
  103161:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  103164:	89 55 c8             	mov    %edx,-0x38(%ebp)
  103167:	89 45 c4             	mov    %eax,-0x3c(%ebp)
            "rep; movsb;"
            "cld;"
            : "=&c" (d0), "=&S" (d1), "=&D" (d2)
            : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
            : "memory");
    return dst;
  10316a:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10316d:	83 c4 30             	add    $0x30,%esp
  103170:	5b                   	pop    %ebx
  103171:	5e                   	pop    %esi
  103172:	5f                   	pop    %edi
  103173:	5d                   	pop    %ebp
  103174:	c3                   	ret    

00103175 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  103175:	55                   	push   %ebp
  103176:	89 e5                	mov    %esp,%ebp
  103178:	57                   	push   %edi
  103179:	56                   	push   %esi
  10317a:	83 ec 20             	sub    $0x20,%esp
  10317d:	8b 45 08             	mov    0x8(%ebp),%eax
  103180:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103183:	8b 45 0c             	mov    0xc(%ebp),%eax
  103186:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103189:	8b 45 10             	mov    0x10(%ebp),%eax
  10318c:	89 45 ec             	mov    %eax,-0x14(%ebp)
            "andl $3, %%ecx;"
            "jz 1f;"
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  10318f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103192:	c1 e8 02             	shr    $0x2,%eax
  103195:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  103197:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10319a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10319d:	89 d7                	mov    %edx,%edi
  10319f:	89 c6                	mov    %eax,%esi
  1031a1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1031a3:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  1031a6:	83 e1 03             	and    $0x3,%ecx
  1031a9:	74 02                	je     1031ad <memcpy+0x38>
  1031ab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  1031ad:	89 f0                	mov    %esi,%eax
  1031af:	89 fa                	mov    %edi,%edx
  1031b1:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  1031b4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  1031b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
            "rep; movsb;"
            "1:"
            : "=&c" (d0), "=&D" (d1), "=&S" (d2)
            : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
            : "memory");
    return dst;
  1031ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  1031bd:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  1031be:	83 c4 20             	add    $0x20,%esp
  1031c1:	5e                   	pop    %esi
  1031c2:	5f                   	pop    %edi
  1031c3:	5d                   	pop    %ebp
  1031c4:	c3                   	ret    

001031c5 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1031c5:	55                   	push   %ebp
  1031c6:	89 e5                	mov    %esp,%ebp
  1031c8:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1031cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1031ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1031d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1031d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1031d7:	eb 2e                	jmp    103207 <memcmp+0x42>
        if (*s1 != *s2) {
  1031d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031dc:	0f b6 10             	movzbl (%eax),%edx
  1031df:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1031e2:	0f b6 00             	movzbl (%eax),%eax
  1031e5:	38 c2                	cmp    %al,%dl
  1031e7:	74 18                	je     103201 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1031e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1031ec:	0f b6 00             	movzbl (%eax),%eax
  1031ef:	0f b6 d0             	movzbl %al,%edx
  1031f2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1031f5:	0f b6 00             	movzbl (%eax),%eax
  1031f8:	0f b6 c0             	movzbl %al,%eax
  1031fb:	29 c2                	sub    %eax,%edx
  1031fd:	89 d0                	mov    %edx,%eax
  1031ff:	eb 18                	jmp    103219 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  103201:	ff 45 fc             	incl   -0x4(%ebp)
  103204:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  103207:	8b 45 10             	mov    0x10(%ebp),%eax
  10320a:	8d 50 ff             	lea    -0x1(%eax),%edx
  10320d:	89 55 10             	mov    %edx,0x10(%ebp)
  103210:	85 c0                	test   %eax,%eax
  103212:	75 c5                	jne    1031d9 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  103214:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103219:	c9                   	leave  
  10321a:	c3                   	ret    

0010321b <printnum>:
 * @width:         maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:        character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  10321b:	55                   	push   %ebp
  10321c:	89 e5                	mov    %esp,%ebp
  10321e:	83 ec 58             	sub    $0x58,%esp
  103221:	8b 45 10             	mov    0x10(%ebp),%eax
  103224:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103227:	8b 45 14             	mov    0x14(%ebp),%eax
  10322a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  10322d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103230:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103233:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103236:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  103239:	8b 45 18             	mov    0x18(%ebp),%eax
  10323c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10323f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103242:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103245:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103248:	89 55 f0             	mov    %edx,-0x10(%ebp)
  10324b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10324e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103251:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103255:	74 1c                	je     103273 <printnum+0x58>
  103257:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10325a:	ba 00 00 00 00       	mov    $0x0,%edx
  10325f:	f7 75 e4             	divl   -0x1c(%ebp)
  103262:	89 55 f4             	mov    %edx,-0xc(%ebp)
  103265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103268:	ba 00 00 00 00       	mov    $0x0,%edx
  10326d:	f7 75 e4             	divl   -0x1c(%ebp)
  103270:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103273:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103276:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103279:	f7 75 e4             	divl   -0x1c(%ebp)
  10327c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10327f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  103282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103285:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103288:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10328b:	89 55 ec             	mov    %edx,-0x14(%ebp)
  10328e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103291:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  103294:	8b 45 18             	mov    0x18(%ebp),%eax
  103297:	ba 00 00 00 00       	mov    $0x0,%edx
  10329c:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  10329f:	77 56                	ja     1032f7 <printnum+0xdc>
  1032a1:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1032a4:	72 05                	jb     1032ab <printnum+0x90>
  1032a6:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1032a9:	77 4c                	ja     1032f7 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  1032ab:	8b 45 1c             	mov    0x1c(%ebp),%eax
  1032ae:	8d 50 ff             	lea    -0x1(%eax),%edx
  1032b1:	8b 45 20             	mov    0x20(%ebp),%eax
  1032b4:	89 44 24 18          	mov    %eax,0x18(%esp)
  1032b8:	89 54 24 14          	mov    %edx,0x14(%esp)
  1032bc:	8b 45 18             	mov    0x18(%ebp),%eax
  1032bf:	89 44 24 10          	mov    %eax,0x10(%esp)
  1032c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1032c6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1032c9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1032cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  1032d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032d8:	8b 45 08             	mov    0x8(%ebp),%eax
  1032db:	89 04 24             	mov    %eax,(%esp)
  1032de:	e8 38 ff ff ff       	call   10321b <printnum>
  1032e3:	eb 1b                	jmp    103300 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  1032e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1032e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1032ec:	8b 45 20             	mov    0x20(%ebp),%eax
  1032ef:	89 04 24             	mov    %eax,(%esp)
  1032f2:	8b 45 08             	mov    0x8(%ebp),%eax
  1032f5:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  1032f7:	ff 4d 1c             	decl   0x1c(%ebp)
  1032fa:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1032fe:	7f e5                	jg     1032e5 <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  103300:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103303:	05 50 40 10 00       	add    $0x104050,%eax
  103308:	0f b6 00             	movzbl (%eax),%eax
  10330b:	0f be c0             	movsbl %al,%eax
  10330e:	8b 55 0c             	mov    0xc(%ebp),%edx
  103311:	89 54 24 04          	mov    %edx,0x4(%esp)
  103315:	89 04 24             	mov    %eax,(%esp)
  103318:	8b 45 08             	mov    0x8(%ebp),%eax
  10331b:	ff d0                	call   *%eax
}
  10331d:	90                   	nop
  10331e:	c9                   	leave  
  10331f:	c3                   	ret    

00103320 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  103320:	55                   	push   %ebp
  103321:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103323:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103327:	7e 14                	jle    10333d <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  103329:	8b 45 08             	mov    0x8(%ebp),%eax
  10332c:	8b 00                	mov    (%eax),%eax
  10332e:	8d 48 08             	lea    0x8(%eax),%ecx
  103331:	8b 55 08             	mov    0x8(%ebp),%edx
  103334:	89 0a                	mov    %ecx,(%edx)
  103336:	8b 50 04             	mov    0x4(%eax),%edx
  103339:	8b 00                	mov    (%eax),%eax
  10333b:	eb 30                	jmp    10336d <getuint+0x4d>
    }
    else if (lflag) {
  10333d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103341:	74 16                	je     103359 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  103343:	8b 45 08             	mov    0x8(%ebp),%eax
  103346:	8b 00                	mov    (%eax),%eax
  103348:	8d 48 04             	lea    0x4(%eax),%ecx
  10334b:	8b 55 08             	mov    0x8(%ebp),%edx
  10334e:	89 0a                	mov    %ecx,(%edx)
  103350:	8b 00                	mov    (%eax),%eax
  103352:	ba 00 00 00 00       	mov    $0x0,%edx
  103357:	eb 14                	jmp    10336d <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  103359:	8b 45 08             	mov    0x8(%ebp),%eax
  10335c:	8b 00                	mov    (%eax),%eax
  10335e:	8d 48 04             	lea    0x4(%eax),%ecx
  103361:	8b 55 08             	mov    0x8(%ebp),%edx
  103364:	89 0a                	mov    %ecx,(%edx)
  103366:	8b 00                	mov    (%eax),%eax
  103368:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  10336d:	5d                   	pop    %ebp
  10336e:	c3                   	ret    

0010336f <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:            a varargs list pointer
 * @lflag:        determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  10336f:	55                   	push   %ebp
  103370:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  103372:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  103376:	7e 14                	jle    10338c <getint+0x1d>
        return va_arg(*ap, long long);
  103378:	8b 45 08             	mov    0x8(%ebp),%eax
  10337b:	8b 00                	mov    (%eax),%eax
  10337d:	8d 48 08             	lea    0x8(%eax),%ecx
  103380:	8b 55 08             	mov    0x8(%ebp),%edx
  103383:	89 0a                	mov    %ecx,(%edx)
  103385:	8b 50 04             	mov    0x4(%eax),%edx
  103388:	8b 00                	mov    (%eax),%eax
  10338a:	eb 28                	jmp    1033b4 <getint+0x45>
    }
    else if (lflag) {
  10338c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  103390:	74 12                	je     1033a4 <getint+0x35>
        return va_arg(*ap, long);
  103392:	8b 45 08             	mov    0x8(%ebp),%eax
  103395:	8b 00                	mov    (%eax),%eax
  103397:	8d 48 04             	lea    0x4(%eax),%ecx
  10339a:	8b 55 08             	mov    0x8(%ebp),%edx
  10339d:	89 0a                	mov    %ecx,(%edx)
  10339f:	8b 00                	mov    (%eax),%eax
  1033a1:	99                   	cltd   
  1033a2:	eb 10                	jmp    1033b4 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  1033a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1033a7:	8b 00                	mov    (%eax),%eax
  1033a9:	8d 48 04             	lea    0x4(%eax),%ecx
  1033ac:	8b 55 08             	mov    0x8(%ebp),%edx
  1033af:	89 0a                	mov    %ecx,(%edx)
  1033b1:	8b 00                	mov    (%eax),%eax
  1033b3:	99                   	cltd   
    }
}
  1033b4:	5d                   	pop    %ebp
  1033b5:	c3                   	ret    

001033b6 <printfmt>:
 * @putch:        specified putch function, print a single character
 * @putdat:        used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  1033b6:	55                   	push   %ebp
  1033b7:	89 e5                	mov    %esp,%ebp
  1033b9:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  1033bc:	8d 45 14             	lea    0x14(%ebp),%eax
  1033bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  1033c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1033c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1033c9:	8b 45 10             	mov    0x10(%ebp),%eax
  1033cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  1033d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033d7:	8b 45 08             	mov    0x8(%ebp),%eax
  1033da:	89 04 24             	mov    %eax,(%esp)
  1033dd:	e8 03 00 00 00       	call   1033e5 <vprintfmt>
    va_end(ap);
}
  1033e2:	90                   	nop
  1033e3:	c9                   	leave  
  1033e4:	c3                   	ret    

001033e5 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  1033e5:	55                   	push   %ebp
  1033e6:	89 e5                	mov    %esp,%ebp
  1033e8:	56                   	push   %esi
  1033e9:	53                   	push   %ebx
  1033ea:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1033ed:	eb 17                	jmp    103406 <vprintfmt+0x21>
            if (ch == '\0') {
  1033ef:	85 db                	test   %ebx,%ebx
  1033f1:	0f 84 bf 03 00 00    	je     1037b6 <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1033f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1033fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1033fe:	89 1c 24             	mov    %ebx,(%esp)
  103401:	8b 45 08             	mov    0x8(%ebp),%eax
  103404:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  103406:	8b 45 10             	mov    0x10(%ebp),%eax
  103409:	8d 50 01             	lea    0x1(%eax),%edx
  10340c:	89 55 10             	mov    %edx,0x10(%ebp)
  10340f:	0f b6 00             	movzbl (%eax),%eax
  103412:	0f b6 d8             	movzbl %al,%ebx
  103415:	83 fb 25             	cmp    $0x25,%ebx
  103418:	75 d5                	jne    1033ef <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  10341a:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  10341e:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  103425:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103428:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  10342b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  103432:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103435:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  103438:	8b 45 10             	mov    0x10(%ebp),%eax
  10343b:	8d 50 01             	lea    0x1(%eax),%edx
  10343e:	89 55 10             	mov    %edx,0x10(%ebp)
  103441:	0f b6 00             	movzbl (%eax),%eax
  103444:	0f b6 d8             	movzbl %al,%ebx
  103447:	8d 43 dd             	lea    -0x23(%ebx),%eax
  10344a:	83 f8 55             	cmp    $0x55,%eax
  10344d:	0f 87 37 03 00 00    	ja     10378a <vprintfmt+0x3a5>
  103453:	8b 04 85 74 40 10 00 	mov    0x104074(,%eax,4),%eax
  10345a:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  10345c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  103460:	eb d6                	jmp    103438 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  103462:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  103466:	eb d0                	jmp    103438 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103468:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  10346f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103472:	89 d0                	mov    %edx,%eax
  103474:	c1 e0 02             	shl    $0x2,%eax
  103477:	01 d0                	add    %edx,%eax
  103479:	01 c0                	add    %eax,%eax
  10347b:	01 d8                	add    %ebx,%eax
  10347d:	83 e8 30             	sub    $0x30,%eax
  103480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  103483:	8b 45 10             	mov    0x10(%ebp),%eax
  103486:	0f b6 00             	movzbl (%eax),%eax
  103489:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  10348c:	83 fb 2f             	cmp    $0x2f,%ebx
  10348f:	7e 38                	jle    1034c9 <vprintfmt+0xe4>
  103491:	83 fb 39             	cmp    $0x39,%ebx
  103494:	7f 33                	jg     1034c9 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  103496:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  103499:	eb d4                	jmp    10346f <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  10349b:	8b 45 14             	mov    0x14(%ebp),%eax
  10349e:	8d 50 04             	lea    0x4(%eax),%edx
  1034a1:	89 55 14             	mov    %edx,0x14(%ebp)
  1034a4:	8b 00                	mov    (%eax),%eax
  1034a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  1034a9:	eb 1f                	jmp    1034ca <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  1034ab:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1034af:	79 87                	jns    103438 <vprintfmt+0x53>
                width = 0;
  1034b1:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1034b8:	e9 7b ff ff ff       	jmp    103438 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1034bd:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1034c4:	e9 6f ff ff ff       	jmp    103438 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  1034c9:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  1034ca:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1034ce:	0f 89 64 ff ff ff    	jns    103438 <vprintfmt+0x53>
                width = precision, precision = -1;
  1034d4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1034d7:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1034da:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1034e1:	e9 52 ff ff ff       	jmp    103438 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1034e6:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1034e9:	e9 4a ff ff ff       	jmp    103438 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1034ee:	8b 45 14             	mov    0x14(%ebp),%eax
  1034f1:	8d 50 04             	lea    0x4(%eax),%edx
  1034f4:	89 55 14             	mov    %edx,0x14(%ebp)
  1034f7:	8b 00                	mov    (%eax),%eax
  1034f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  1034fc:	89 54 24 04          	mov    %edx,0x4(%esp)
  103500:	89 04 24             	mov    %eax,(%esp)
  103503:	8b 45 08             	mov    0x8(%ebp),%eax
  103506:	ff d0                	call   *%eax
            break;
  103508:	e9 a4 02 00 00       	jmp    1037b1 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  10350d:	8b 45 14             	mov    0x14(%ebp),%eax
  103510:	8d 50 04             	lea    0x4(%eax),%edx
  103513:	89 55 14             	mov    %edx,0x14(%ebp)
  103516:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  103518:	85 db                	test   %ebx,%ebx
  10351a:	79 02                	jns    10351e <vprintfmt+0x139>
                err = -err;
  10351c:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  10351e:	83 fb 06             	cmp    $0x6,%ebx
  103521:	7f 0b                	jg     10352e <vprintfmt+0x149>
  103523:	8b 34 9d 34 40 10 00 	mov    0x104034(,%ebx,4),%esi
  10352a:	85 f6                	test   %esi,%esi
  10352c:	75 23                	jne    103551 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  10352e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  103532:	c7 44 24 08 61 40 10 	movl   $0x104061,0x8(%esp)
  103539:	00 
  10353a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10353d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103541:	8b 45 08             	mov    0x8(%ebp),%eax
  103544:	89 04 24             	mov    %eax,(%esp)
  103547:	e8 6a fe ff ff       	call   1033b6 <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  10354c:	e9 60 02 00 00       	jmp    1037b1 <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  103551:	89 74 24 0c          	mov    %esi,0xc(%esp)
  103555:	c7 44 24 08 6a 40 10 	movl   $0x10406a,0x8(%esp)
  10355c:	00 
  10355d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103560:	89 44 24 04          	mov    %eax,0x4(%esp)
  103564:	8b 45 08             	mov    0x8(%ebp),%eax
  103567:	89 04 24             	mov    %eax,(%esp)
  10356a:	e8 47 fe ff ff       	call   1033b6 <printfmt>
            }
            break;
  10356f:	e9 3d 02 00 00       	jmp    1037b1 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  103574:	8b 45 14             	mov    0x14(%ebp),%eax
  103577:	8d 50 04             	lea    0x4(%eax),%edx
  10357a:	89 55 14             	mov    %edx,0x14(%ebp)
  10357d:	8b 30                	mov    (%eax),%esi
  10357f:	85 f6                	test   %esi,%esi
  103581:	75 05                	jne    103588 <vprintfmt+0x1a3>
                p = "(null)";
  103583:	be 6d 40 10 00       	mov    $0x10406d,%esi
            }
            if (width > 0 && padc != '-') {
  103588:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10358c:	7e 76                	jle    103604 <vprintfmt+0x21f>
  10358e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  103592:	74 70                	je     103604 <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  103594:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103597:	89 44 24 04          	mov    %eax,0x4(%esp)
  10359b:	89 34 24             	mov    %esi,(%esp)
  10359e:	e8 f6 f7 ff ff       	call   102d99 <strnlen>
  1035a3:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1035a6:	29 c2                	sub    %eax,%edx
  1035a8:	89 d0                	mov    %edx,%eax
  1035aa:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1035ad:	eb 16                	jmp    1035c5 <vprintfmt+0x1e0>
                    putch(padc, putdat);
  1035af:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  1035b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  1035b6:	89 54 24 04          	mov    %edx,0x4(%esp)
  1035ba:	89 04 24             	mov    %eax,(%esp)
  1035bd:	8b 45 08             	mov    0x8(%ebp),%eax
  1035c0:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1035c2:	ff 4d e8             	decl   -0x18(%ebp)
  1035c5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1035c9:	7f e4                	jg     1035af <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1035cb:	eb 37                	jmp    103604 <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  1035cd:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1035d1:	74 1f                	je     1035f2 <vprintfmt+0x20d>
  1035d3:	83 fb 1f             	cmp    $0x1f,%ebx
  1035d6:	7e 05                	jle    1035dd <vprintfmt+0x1f8>
  1035d8:	83 fb 7e             	cmp    $0x7e,%ebx
  1035db:	7e 15                	jle    1035f2 <vprintfmt+0x20d>
                    putch('?', putdat);
  1035dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1035eb:	8b 45 08             	mov    0x8(%ebp),%eax
  1035ee:	ff d0                	call   *%eax
  1035f0:	eb 0f                	jmp    103601 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  1035f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1035f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  1035f9:	89 1c 24             	mov    %ebx,(%esp)
  1035fc:	8b 45 08             	mov    0x8(%ebp),%eax
  1035ff:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  103601:	ff 4d e8             	decl   -0x18(%ebp)
  103604:	89 f0                	mov    %esi,%eax
  103606:	8d 70 01             	lea    0x1(%eax),%esi
  103609:	0f b6 00             	movzbl (%eax),%eax
  10360c:	0f be d8             	movsbl %al,%ebx
  10360f:	85 db                	test   %ebx,%ebx
  103611:	74 27                	je     10363a <vprintfmt+0x255>
  103613:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103617:	78 b4                	js     1035cd <vprintfmt+0x1e8>
  103619:	ff 4d e4             	decl   -0x1c(%ebp)
  10361c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103620:	79 ab                	jns    1035cd <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  103622:	eb 16                	jmp    10363a <vprintfmt+0x255>
                putch(' ', putdat);
  103624:	8b 45 0c             	mov    0xc(%ebp),%eax
  103627:	89 44 24 04          	mov    %eax,0x4(%esp)
  10362b:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  103632:	8b 45 08             	mov    0x8(%ebp),%eax
  103635:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  103637:	ff 4d e8             	decl   -0x18(%ebp)
  10363a:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10363e:	7f e4                	jg     103624 <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  103640:	e9 6c 01 00 00       	jmp    1037b1 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  103645:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103648:	89 44 24 04          	mov    %eax,0x4(%esp)
  10364c:	8d 45 14             	lea    0x14(%ebp),%eax
  10364f:	89 04 24             	mov    %eax,(%esp)
  103652:	e8 18 fd ff ff       	call   10336f <getint>
  103657:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10365a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  10365d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103660:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103663:	85 d2                	test   %edx,%edx
  103665:	79 26                	jns    10368d <vprintfmt+0x2a8>
                putch('-', putdat);
  103667:	8b 45 0c             	mov    0xc(%ebp),%eax
  10366a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10366e:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  103675:	8b 45 08             	mov    0x8(%ebp),%eax
  103678:	ff d0                	call   *%eax
                num = -(long long)num;
  10367a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10367d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103680:	f7 d8                	neg    %eax
  103682:	83 d2 00             	adc    $0x0,%edx
  103685:	f7 da                	neg    %edx
  103687:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10368a:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  10368d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  103694:	e9 a8 00 00 00       	jmp    103741 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  103699:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10369c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036a0:	8d 45 14             	lea    0x14(%ebp),%eax
  1036a3:	89 04 24             	mov    %eax,(%esp)
  1036a6:	e8 75 fc ff ff       	call   103320 <getuint>
  1036ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  1036b1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1036b8:	e9 84 00 00 00       	jmp    103741 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1036bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1036c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036c4:	8d 45 14             	lea    0x14(%ebp),%eax
  1036c7:	89 04 24             	mov    %eax,(%esp)
  1036ca:	e8 51 fc ff ff       	call   103320 <getuint>
  1036cf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036d2:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1036d5:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1036dc:	eb 63                	jmp    103741 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  1036de:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036e5:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1036ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1036ef:	ff d0                	call   *%eax
            putch('x', putdat);
  1036f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1036f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1036f8:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1036ff:	8b 45 08             	mov    0x8(%ebp),%eax
  103702:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  103704:	8b 45 14             	mov    0x14(%ebp),%eax
  103707:	8d 50 04             	lea    0x4(%eax),%edx
  10370a:	89 55 14             	mov    %edx,0x14(%ebp)
  10370d:	8b 00                	mov    (%eax),%eax
  10370f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103712:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  103719:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  103720:	eb 1f                	jmp    103741 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  103722:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103725:	89 44 24 04          	mov    %eax,0x4(%esp)
  103729:	8d 45 14             	lea    0x14(%ebp),%eax
  10372c:	89 04 24             	mov    %eax,(%esp)
  10372f:	e8 ec fb ff ff       	call   103320 <getuint>
  103734:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103737:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  10373a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  103741:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  103745:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103748:	89 54 24 18          	mov    %edx,0x18(%esp)
  10374c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10374f:	89 54 24 14          	mov    %edx,0x14(%esp)
  103753:	89 44 24 10          	mov    %eax,0x10(%esp)
  103757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10375a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10375d:	89 44 24 08          	mov    %eax,0x8(%esp)
  103761:	89 54 24 0c          	mov    %edx,0xc(%esp)
  103765:	8b 45 0c             	mov    0xc(%ebp),%eax
  103768:	89 44 24 04          	mov    %eax,0x4(%esp)
  10376c:	8b 45 08             	mov    0x8(%ebp),%eax
  10376f:	89 04 24             	mov    %eax,(%esp)
  103772:	e8 a4 fa ff ff       	call   10321b <printnum>
            break;
  103777:	eb 38                	jmp    1037b1 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  103779:	8b 45 0c             	mov    0xc(%ebp),%eax
  10377c:	89 44 24 04          	mov    %eax,0x4(%esp)
  103780:	89 1c 24             	mov    %ebx,(%esp)
  103783:	8b 45 08             	mov    0x8(%ebp),%eax
  103786:	ff d0                	call   *%eax
            break;
  103788:	eb 27                	jmp    1037b1 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  10378a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10378d:	89 44 24 04          	mov    %eax,0x4(%esp)
  103791:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  103798:	8b 45 08             	mov    0x8(%ebp),%eax
  10379b:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  10379d:	ff 4d 10             	decl   0x10(%ebp)
  1037a0:	eb 03                	jmp    1037a5 <vprintfmt+0x3c0>
  1037a2:	ff 4d 10             	decl   0x10(%ebp)
  1037a5:	8b 45 10             	mov    0x10(%ebp),%eax
  1037a8:	48                   	dec    %eax
  1037a9:	0f b6 00             	movzbl (%eax),%eax
  1037ac:	3c 25                	cmp    $0x25,%al
  1037ae:	75 f2                	jne    1037a2 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  1037b0:	90                   	nop
        }
    }
  1037b1:	e9 37 fc ff ff       	jmp    1033ed <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  1037b6:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1037b7:	83 c4 40             	add    $0x40,%esp
  1037ba:	5b                   	pop    %ebx
  1037bb:	5e                   	pop    %esi
  1037bc:	5d                   	pop    %ebp
  1037bd:	c3                   	ret    

001037be <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:            the character will be printed
 * @b:            the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1037be:	55                   	push   %ebp
  1037bf:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1037c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037c4:	8b 40 08             	mov    0x8(%eax),%eax
  1037c7:	8d 50 01             	lea    0x1(%eax),%edx
  1037ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037cd:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1037d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037d3:	8b 10                	mov    (%eax),%edx
  1037d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037d8:	8b 40 04             	mov    0x4(%eax),%eax
  1037db:	39 c2                	cmp    %eax,%edx
  1037dd:	73 12                	jae    1037f1 <sprintputch+0x33>
        *b->buf ++ = ch;
  1037df:	8b 45 0c             	mov    0xc(%ebp),%eax
  1037e2:	8b 00                	mov    (%eax),%eax
  1037e4:	8d 48 01             	lea    0x1(%eax),%ecx
  1037e7:	8b 55 0c             	mov    0xc(%ebp),%edx
  1037ea:	89 0a                	mov    %ecx,(%edx)
  1037ec:	8b 55 08             	mov    0x8(%ebp),%edx
  1037ef:	88 10                	mov    %dl,(%eax)
    }
}
  1037f1:	90                   	nop
  1037f2:	5d                   	pop    %ebp
  1037f3:	c3                   	ret    

001037f4 <snprintf>:
 * @str:        the buffer to place the result into
 * @size:        the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1037f4:	55                   	push   %ebp
  1037f5:	89 e5                	mov    %esp,%ebp
  1037f7:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1037fa:	8d 45 14             	lea    0x14(%ebp),%eax
  1037fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  103800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103807:	8b 45 10             	mov    0x10(%ebp),%eax
  10380a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10380e:	8b 45 0c             	mov    0xc(%ebp),%eax
  103811:	89 44 24 04          	mov    %eax,0x4(%esp)
  103815:	8b 45 08             	mov    0x8(%ebp),%eax
  103818:	89 04 24             	mov    %eax,(%esp)
  10381b:	e8 08 00 00 00       	call   103828 <vsnprintf>
  103820:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  103823:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103826:	c9                   	leave  
  103827:	c3                   	ret    

00103828 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  103828:	55                   	push   %ebp
  103829:	89 e5                	mov    %esp,%ebp
  10382b:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  10382e:	8b 45 08             	mov    0x8(%ebp),%eax
  103831:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103834:	8b 45 0c             	mov    0xc(%ebp),%eax
  103837:	8d 50 ff             	lea    -0x1(%eax),%edx
  10383a:	8b 45 08             	mov    0x8(%ebp),%eax
  10383d:	01 d0                	add    %edx,%eax
  10383f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103842:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  103849:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  10384d:	74 0a                	je     103859 <vsnprintf+0x31>
  10384f:	8b 55 ec             	mov    -0x14(%ebp),%edx
  103852:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103855:	39 c2                	cmp    %eax,%edx
  103857:	76 07                	jbe    103860 <vsnprintf+0x38>
        return -E_INVAL;
  103859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  10385e:	eb 2a                	jmp    10388a <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  103860:	8b 45 14             	mov    0x14(%ebp),%eax
  103863:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103867:	8b 45 10             	mov    0x10(%ebp),%eax
  10386a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10386e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  103871:	89 44 24 04          	mov    %eax,0x4(%esp)
  103875:	c7 04 24 be 37 10 00 	movl   $0x1037be,(%esp)
  10387c:	e8 64 fb ff ff       	call   1033e5 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  103881:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103884:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  103887:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10388a:	c9                   	leave  
  10388b:	c3                   	ret    
