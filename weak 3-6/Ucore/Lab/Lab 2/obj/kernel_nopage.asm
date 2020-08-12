
bin/kernel_nopage:     file format elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 90 11 40       	mov    $0x40119000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 90 11 00       	mov    %eax,0x119000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 80 11 00       	mov    $0x118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	ba a8 bf 11 00       	mov    $0x11bfa8,%edx
  100041:	b8 36 8a 11 00       	mov    $0x118a36,%eax
  100046:	29 c2                	sub    %eax,%edx
  100048:	89 d0                	mov    %edx,%eax
  10004a:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100055:	00 
  100056:	c7 04 24 36 8a 11 00 	movl   $0x118a36,(%esp)
  10005d:	e8 19 5c 00 00       	call   105c7b <memset>

    cons_init();                // init the console
  100062:	e8 96 15 00 00       	call   1015fd <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100067:	c7 45 f4 80 64 10 00 	movl   $0x106480,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100071:	89 44 24 04          	mov    %eax,0x4(%esp)
  100075:	c7 04 24 9c 64 10 00 	movl   $0x10649c,(%esp)
  10007c:	e8 1c 02 00 00       	call   10029d <cprintf>

    print_kerninfo();
  100081:	e8 bd 08 00 00       	call   100943 <print_kerninfo>

    grade_backtrace();
  100086:	e8 89 00 00 00       	call   100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
  10008b:	e8 91 35 00 00       	call   103621 <pmm_init>

    pic_init();                 // init interrupt controller
  100090:	e8 cc 16 00 00       	call   101761 <pic_init>
    idt_init();                 // init interrupt descriptor table
  100095:	e8 25 18 00 00       	call   1018bf <idt_init>

    clock_init();               // init clock interrupt
  10009a:	e8 11 0d 00 00       	call   100db0 <clock_init>
    intr_enable();              // enable irq interrupt
  10009f:	e8 f0 17 00 00       	call   101894 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a4:	eb fe                	jmp    1000a4 <kern_init+0x6e>

001000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a6:	55                   	push   %ebp
  1000a7:	89 e5                	mov    %esp,%ebp
  1000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000b3:	00 
  1000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000bb:	00 
  1000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000c3:	e8 d6 0c 00 00       	call   100d9e <mon_backtrace>
}
  1000c8:	90                   	nop
  1000c9:	c9                   	leave  
  1000ca:	c3                   	ret    

001000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000cb:	55                   	push   %ebp
  1000cc:	89 e5                	mov    %esp,%ebp
  1000ce:	53                   	push   %ebx
  1000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b4 ff ff ff       	call   1000a6 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	83 c4 14             	add    $0x14,%esp
  1000f6:	5b                   	pop    %ebx
  1000f7:	5d                   	pop    %ebp
  1000f8:	c3                   	ret    

001000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000f9:	55                   	push   %ebp
  1000fa:	89 e5                	mov    %esp,%ebp
  1000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  1000ff:	8b 45 10             	mov    0x10(%ebp),%eax
  100102:	89 44 24 04          	mov    %eax,0x4(%esp)
  100106:	8b 45 08             	mov    0x8(%ebp),%eax
  100109:	89 04 24             	mov    %eax,(%esp)
  10010c:	e8 ba ff ff ff       	call   1000cb <grade_backtrace1>
}
  100111:	90                   	nop
  100112:	c9                   	leave  
  100113:	c3                   	ret    

00100114 <grade_backtrace>:

void
grade_backtrace(void) {
  100114:	55                   	push   %ebp
  100115:	89 e5                	mov    %esp,%ebp
  100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011a:	b8 36 00 10 00       	mov    $0x100036,%eax
  10011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100126:	ff 
  100127:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100132:	e8 c2 ff ff ff       	call   1000f9 <grade_backtrace0>
}
  100137:	90                   	nop
  100138:	c9                   	leave  
  100139:	c3                   	ret    

0010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013a:	55                   	push   %ebp
  10013b:	89 e5                	mov    %esp,%ebp
  10013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
  100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  10014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100150:	83 e0 03             	and    $0x3,%eax
  100153:	89 c2                	mov    %eax,%edx
  100155:	a1 00 b0 11 00       	mov    0x11b000,%eax
  10015a:	89 54 24 08          	mov    %edx,0x8(%esp)
  10015e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100162:	c7 04 24 a1 64 10 00 	movl   $0x1064a1,(%esp)
  100169:	e8 2f 01 00 00       	call   10029d <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  10016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100172:	89 c2                	mov    %eax,%edx
  100174:	a1 00 b0 11 00       	mov    0x11b000,%eax
  100179:	89 54 24 08          	mov    %edx,0x8(%esp)
  10017d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100181:	c7 04 24 af 64 10 00 	movl   $0x1064af,(%esp)
  100188:	e8 10 01 00 00       	call   10029d <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  10018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100191:	89 c2                	mov    %eax,%edx
  100193:	a1 00 b0 11 00       	mov    0x11b000,%eax
  100198:	89 54 24 08          	mov    %edx,0x8(%esp)
  10019c:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a0:	c7 04 24 bd 64 10 00 	movl   $0x1064bd,(%esp)
  1001a7:	e8 f1 00 00 00       	call   10029d <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b0:	89 c2                	mov    %eax,%edx
  1001b2:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001bf:	c7 04 24 cb 64 10 00 	movl   $0x1064cb,(%esp)
  1001c6:	e8 d2 00 00 00       	call   10029d <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001cf:	89 c2                	mov    %eax,%edx
  1001d1:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001da:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001de:	c7 04 24 d9 64 10 00 	movl   $0x1064d9,(%esp)
  1001e5:	e8 b3 00 00 00       	call   10029d <cprintf>
    round ++;
  1001ea:	a1 00 b0 11 00       	mov    0x11b000,%eax
  1001ef:	40                   	inc    %eax
  1001f0:	a3 00 b0 11 00       	mov    %eax,0x11b000
}
  1001f5:	90                   	nop
  1001f6:	c9                   	leave  
  1001f7:	c3                   	ret    

001001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001f8:	55                   	push   %ebp
  1001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
  1001fb:	83 ec 08             	sub    $0x8,%esp
  1001fe:	cd 78                	int    $0x78
  100200:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        : 
        : "i"(T_SWITCH_TOU)
    );
}
  100202:	90                   	nop
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
  100208:	cd 79                	int    $0x79
  10020a:	89 ec                	mov    %ebp,%esp
           "int %0 \n"
           "movl %%ebp, %%esp"
           : 
           : "i"(T_SWITCH_TOK)
    );
}
  10020c:	90                   	nop
  10020d:	5d                   	pop    %ebp
  10020e:	c3                   	ret    

0010020f <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10020f:	55                   	push   %ebp
  100210:	89 e5                	mov    %esp,%ebp
  100212:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100215:	e8 20 ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  10021a:	c7 04 24 e8 64 10 00 	movl   $0x1064e8,(%esp)
  100221:	e8 77 00 00 00       	call   10029d <cprintf>
    lab1_switch_to_user();
  100226:	e8 cd ff ff ff       	call   1001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
  10022b:	e8 0a ff ff ff       	call   10013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  100230:	c7 04 24 08 65 10 00 	movl   $0x106508,(%esp)
  100237:	e8 61 00 00 00       	call   10029d <cprintf>
    lab1_switch_to_kernel();
  10023c:	e8 c4 ff ff ff       	call   100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  100241:	e8 f4 fe ff ff       	call   10013a <lab1_print_cur_status>
}
  100246:	90                   	nop
  100247:	c9                   	leave  
  100248:	c3                   	ret    

00100249 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  100249:	55                   	push   %ebp
  10024a:	89 e5                	mov    %esp,%ebp
  10024c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  10024f:	8b 45 08             	mov    0x8(%ebp),%eax
  100252:	89 04 24             	mov    %eax,(%esp)
  100255:	e8 d0 13 00 00       	call   10162a <cons_putc>
    (*cnt) ++;
  10025a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10025d:	8b 00                	mov    (%eax),%eax
  10025f:	8d 50 01             	lea    0x1(%eax),%edx
  100262:	8b 45 0c             	mov    0xc(%ebp),%eax
  100265:	89 10                	mov    %edx,(%eax)
}
  100267:	90                   	nop
  100268:	c9                   	leave  
  100269:	c3                   	ret    

0010026a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  10026a:	55                   	push   %ebp
  10026b:	89 e5                	mov    %esp,%ebp
  10026d:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100270:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  100277:	8b 45 0c             	mov    0xc(%ebp),%eax
  10027a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10027e:	8b 45 08             	mov    0x8(%ebp),%eax
  100281:	89 44 24 08          	mov    %eax,0x8(%esp)
  100285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  100288:	89 44 24 04          	mov    %eax,0x4(%esp)
  10028c:	c7 04 24 49 02 10 00 	movl   $0x100249,(%esp)
  100293:	e8 36 5d 00 00       	call   105fce <vprintfmt>
    return cnt;
  100298:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10029b:	c9                   	leave  
  10029c:	c3                   	ret    

0010029d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  10029d:	55                   	push   %ebp
  10029e:	89 e5                	mov    %esp,%ebp
  1002a0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
  1002a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  1002a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  1002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  1002b3:	89 04 24             	mov    %eax,(%esp)
  1002b6:	e8 af ff ff ff       	call   10026a <vcprintf>
  1002bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  1002be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1002c1:	c9                   	leave  
  1002c2:	c3                   	ret    

001002c3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  1002c3:	55                   	push   %ebp
  1002c4:	89 e5                	mov    %esp,%ebp
  1002c6:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  1002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  1002cc:	89 04 24             	mov    %eax,(%esp)
  1002cf:	e8 56 13 00 00       	call   10162a <cons_putc>
}
  1002d4:	90                   	nop
  1002d5:	c9                   	leave  
  1002d6:	c3                   	ret    

001002d7 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  1002d7:	55                   	push   %ebp
  1002d8:	89 e5                	mov    %esp,%ebp
  1002da:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  1002dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1002e4:	eb 13                	jmp    1002f9 <cputs+0x22>
        cputch(c, &cnt);
  1002e6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1002ea:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  1002f1:	89 04 24             	mov    %eax,(%esp)
  1002f4:	e8 50 ff ff ff       	call   100249 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
  1002f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1002fc:	8d 50 01             	lea    0x1(%eax),%edx
  1002ff:	89 55 08             	mov    %edx,0x8(%ebp)
  100302:	0f b6 00             	movzbl (%eax),%eax
  100305:	88 45 f7             	mov    %al,-0x9(%ebp)
  100308:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  10030c:	75 d8                	jne    1002e6 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
  10030e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  100311:	89 44 24 04          	mov    %eax,0x4(%esp)
  100315:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  10031c:	e8 28 ff ff ff       	call   100249 <cputch>
    return cnt;
  100321:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  100324:	c9                   	leave  
  100325:	c3                   	ret    

00100326 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  100326:	55                   	push   %ebp
  100327:	89 e5                	mov    %esp,%ebp
  100329:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  10032c:	e8 36 13 00 00       	call   101667 <cons_getc>
  100331:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100334:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100338:	74 f2                	je     10032c <getchar+0x6>
        /* do nothing */;
    return c;
  10033a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10033d:	c9                   	leave  
  10033e:	c3                   	ret    

0010033f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  10033f:	55                   	push   %ebp
  100340:	89 e5                	mov    %esp,%ebp
  100342:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  100345:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100349:	74 13                	je     10035e <readline+0x1f>
        cprintf("%s", prompt);
  10034b:	8b 45 08             	mov    0x8(%ebp),%eax
  10034e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100352:	c7 04 24 27 65 10 00 	movl   $0x106527,(%esp)
  100359:	e8 3f ff ff ff       	call   10029d <cprintf>
    }
    int i = 0, c;
  10035e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  100365:	e8 bc ff ff ff       	call   100326 <getchar>
  10036a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  10036d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100371:	79 07                	jns    10037a <readline+0x3b>
            return NULL;
  100373:	b8 00 00 00 00       	mov    $0x0,%eax
  100378:	eb 78                	jmp    1003f2 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  10037a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  10037e:	7e 28                	jle    1003a8 <readline+0x69>
  100380:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  100387:	7f 1f                	jg     1003a8 <readline+0x69>
            cputchar(c);
  100389:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10038c:	89 04 24             	mov    %eax,(%esp)
  10038f:	e8 2f ff ff ff       	call   1002c3 <cputchar>
            buf[i ++] = c;
  100394:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100397:	8d 50 01             	lea    0x1(%eax),%edx
  10039a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10039d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1003a0:	88 90 20 b0 11 00    	mov    %dl,0x11b020(%eax)
  1003a6:	eb 45                	jmp    1003ed <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1003a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1003ac:	75 16                	jne    1003c4 <readline+0x85>
  1003ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003b2:	7e 10                	jle    1003c4 <readline+0x85>
            cputchar(c);
  1003b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003b7:	89 04 24             	mov    %eax,(%esp)
  1003ba:	e8 04 ff ff ff       	call   1002c3 <cputchar>
            i --;
  1003bf:	ff 4d f4             	decl   -0xc(%ebp)
  1003c2:	eb 29                	jmp    1003ed <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1003c4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1003c8:	74 06                	je     1003d0 <readline+0x91>
  1003ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1003ce:	75 95                	jne    100365 <readline+0x26>
            cputchar(c);
  1003d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1003d3:	89 04 24             	mov    %eax,(%esp)
  1003d6:	e8 e8 fe ff ff       	call   1002c3 <cputchar>
            buf[i] = '\0';
  1003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1003de:	05 20 b0 11 00       	add    $0x11b020,%eax
  1003e3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1003e6:	b8 20 b0 11 00       	mov    $0x11b020,%eax
  1003eb:	eb 05                	jmp    1003f2 <readline+0xb3>
        }
    }
  1003ed:	e9 73 ff ff ff       	jmp    100365 <readline+0x26>
}
  1003f2:	c9                   	leave  
  1003f3:	c3                   	ret    

001003f4 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  1003f4:	55                   	push   %ebp
  1003f5:	89 e5                	mov    %esp,%ebp
  1003f7:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  1003fa:	a1 20 b4 11 00       	mov    0x11b420,%eax
  1003ff:	85 c0                	test   %eax,%eax
  100401:	75 5b                	jne    10045e <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100403:	c7 05 20 b4 11 00 01 	movl   $0x1,0x11b420
  10040a:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  10040d:	8d 45 14             	lea    0x14(%ebp),%eax
  100410:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100413:	8b 45 0c             	mov    0xc(%ebp),%eax
  100416:	89 44 24 08          	mov    %eax,0x8(%esp)
  10041a:	8b 45 08             	mov    0x8(%ebp),%eax
  10041d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100421:	c7 04 24 2a 65 10 00 	movl   $0x10652a,(%esp)
  100428:	e8 70 fe ff ff       	call   10029d <cprintf>
    vcprintf(fmt, ap);
  10042d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100430:	89 44 24 04          	mov    %eax,0x4(%esp)
  100434:	8b 45 10             	mov    0x10(%ebp),%eax
  100437:	89 04 24             	mov    %eax,(%esp)
  10043a:	e8 2b fe ff ff       	call   10026a <vcprintf>
    cprintf("\n");
  10043f:	c7 04 24 46 65 10 00 	movl   $0x106546,(%esp)
  100446:	e8 52 fe ff ff       	call   10029d <cprintf>
    
    cprintf("stack trackback:\n");
  10044b:	c7 04 24 48 65 10 00 	movl   $0x106548,(%esp)
  100452:	e8 46 fe ff ff       	call   10029d <cprintf>
    print_stackframe();
  100457:	e8 32 06 00 00       	call   100a8e <print_stackframe>
  10045c:	eb 01                	jmp    10045f <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
  10045e:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
  10045f:	e8 37 14 00 00       	call   10189b <intr_disable>
    while (1) {
        kmonitor(NULL);
  100464:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  10046b:	e8 61 08 00 00       	call   100cd1 <kmonitor>
    }
  100470:	eb f2                	jmp    100464 <__panic+0x70>

00100472 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100472:	55                   	push   %ebp
  100473:	89 e5                	mov    %esp,%ebp
  100475:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100478:	8d 45 14             	lea    0x14(%ebp),%eax
  10047b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  10047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100481:	89 44 24 08          	mov    %eax,0x8(%esp)
  100485:	8b 45 08             	mov    0x8(%ebp),%eax
  100488:	89 44 24 04          	mov    %eax,0x4(%esp)
  10048c:	c7 04 24 5a 65 10 00 	movl   $0x10655a,(%esp)
  100493:	e8 05 fe ff ff       	call   10029d <cprintf>
    vcprintf(fmt, ap);
  100498:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10049b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10049f:	8b 45 10             	mov    0x10(%ebp),%eax
  1004a2:	89 04 24             	mov    %eax,(%esp)
  1004a5:	e8 c0 fd ff ff       	call   10026a <vcprintf>
    cprintf("\n");
  1004aa:	c7 04 24 46 65 10 00 	movl   $0x106546,(%esp)
  1004b1:	e8 e7 fd ff ff       	call   10029d <cprintf>
    va_end(ap);
}
  1004b6:	90                   	nop
  1004b7:	c9                   	leave  
  1004b8:	c3                   	ret    

001004b9 <is_kernel_panic>:

bool
is_kernel_panic(void) {
  1004b9:	55                   	push   %ebp
  1004ba:	89 e5                	mov    %esp,%ebp
    return is_panic;
  1004bc:	a1 20 b4 11 00       	mov    0x11b420,%eax
}
  1004c1:	5d                   	pop    %ebp
  1004c2:	c3                   	ret    

001004c3 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  1004c3:	55                   	push   %ebp
  1004c4:	89 e5                	mov    %esp,%ebp
  1004c6:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  1004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004cc:	8b 00                	mov    (%eax),%eax
  1004ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004d1:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d4:	8b 00                	mov    (%eax),%eax
  1004d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  1004e0:	e9 ca 00 00 00       	jmp    1005af <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  1004e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1004e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1004eb:	01 d0                	add    %edx,%eax
  1004ed:	89 c2                	mov    %eax,%edx
  1004ef:	c1 ea 1f             	shr    $0x1f,%edx
  1004f2:	01 d0                	add    %edx,%eax
  1004f4:	d1 f8                	sar    %eax
  1004f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1004f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  1004ff:	eb 03                	jmp    100504 <stab_binsearch+0x41>
            m --;
  100501:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  100504:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100507:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10050a:	7c 1f                	jl     10052b <stab_binsearch+0x68>
  10050c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10050f:	89 d0                	mov    %edx,%eax
  100511:	01 c0                	add    %eax,%eax
  100513:	01 d0                	add    %edx,%eax
  100515:	c1 e0 02             	shl    $0x2,%eax
  100518:	89 c2                	mov    %eax,%edx
  10051a:	8b 45 08             	mov    0x8(%ebp),%eax
  10051d:	01 d0                	add    %edx,%eax
  10051f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100523:	0f b6 c0             	movzbl %al,%eax
  100526:	3b 45 14             	cmp    0x14(%ebp),%eax
  100529:	75 d6                	jne    100501 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
  10052b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10052e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100531:	7d 09                	jge    10053c <stab_binsearch+0x79>
            l = true_m + 1;
  100533:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100536:	40                   	inc    %eax
  100537:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  10053a:	eb 73                	jmp    1005af <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10053c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100543:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100546:	89 d0                	mov    %edx,%eax
  100548:	01 c0                	add    %eax,%eax
  10054a:	01 d0                	add    %edx,%eax
  10054c:	c1 e0 02             	shl    $0x2,%eax
  10054f:	89 c2                	mov    %eax,%edx
  100551:	8b 45 08             	mov    0x8(%ebp),%eax
  100554:	01 d0                	add    %edx,%eax
  100556:	8b 40 08             	mov    0x8(%eax),%eax
  100559:	3b 45 18             	cmp    0x18(%ebp),%eax
  10055c:	73 11                	jae    10056f <stab_binsearch+0xac>
            *region_left = m;
  10055e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100561:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100564:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  100566:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100569:	40                   	inc    %eax
  10056a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10056d:	eb 40                	jmp    1005af <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  10056f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100572:	89 d0                	mov    %edx,%eax
  100574:	01 c0                	add    %eax,%eax
  100576:	01 d0                	add    %edx,%eax
  100578:	c1 e0 02             	shl    $0x2,%eax
  10057b:	89 c2                	mov    %eax,%edx
  10057d:	8b 45 08             	mov    0x8(%ebp),%eax
  100580:	01 d0                	add    %edx,%eax
  100582:	8b 40 08             	mov    0x8(%eax),%eax
  100585:	3b 45 18             	cmp    0x18(%ebp),%eax
  100588:	76 14                	jbe    10059e <stab_binsearch+0xdb>
            *region_right = m - 1;
  10058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10058d:	8d 50 ff             	lea    -0x1(%eax),%edx
  100590:	8b 45 10             	mov    0x10(%ebp),%eax
  100593:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  100595:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100598:	48                   	dec    %eax
  100599:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10059c:	eb 11                	jmp    1005af <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  10059e:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1005a4:	89 10                	mov    %edx,(%eax)
            l = m;
  1005a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1005ac:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
  1005af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1005b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1005b5:	0f 8e 2a ff ff ff    	jle    1004e5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
  1005bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1005bf:	75 0f                	jne    1005d0 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005c4:	8b 00                	mov    (%eax),%eax
  1005c6:	8d 50 ff             	lea    -0x1(%eax),%edx
  1005c9:	8b 45 10             	mov    0x10(%ebp),%eax
  1005cc:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  1005ce:	eb 3e                	jmp    10060e <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
  1005d0:	8b 45 10             	mov    0x10(%ebp),%eax
  1005d3:	8b 00                	mov    (%eax),%eax
  1005d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  1005d8:	eb 03                	jmp    1005dd <stab_binsearch+0x11a>
  1005da:	ff 4d fc             	decl   -0x4(%ebp)
  1005dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  1005e0:	8b 00                	mov    (%eax),%eax
  1005e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  1005e5:	7d 1f                	jge    100606 <stab_binsearch+0x143>
  1005e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
  1005ea:	89 d0                	mov    %edx,%eax
  1005ec:	01 c0                	add    %eax,%eax
  1005ee:	01 d0                	add    %edx,%eax
  1005f0:	c1 e0 02             	shl    $0x2,%eax
  1005f3:	89 c2                	mov    %eax,%edx
  1005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1005f8:	01 d0                	add    %edx,%eax
  1005fa:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1005fe:	0f b6 c0             	movzbl %al,%eax
  100601:	3b 45 14             	cmp    0x14(%ebp),%eax
  100604:	75 d4                	jne    1005da <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
  100606:	8b 45 0c             	mov    0xc(%ebp),%eax
  100609:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10060c:	89 10                	mov    %edx,(%eax)
    }
}
  10060e:	90                   	nop
  10060f:	c9                   	leave  
  100610:	c3                   	ret    

00100611 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100611:	55                   	push   %ebp
  100612:	89 e5                	mov    %esp,%ebp
  100614:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100617:	8b 45 0c             	mov    0xc(%ebp),%eax
  10061a:	c7 00 78 65 10 00    	movl   $0x106578,(%eax)
    info->eip_line = 0;
  100620:	8b 45 0c             	mov    0xc(%ebp),%eax
  100623:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10062a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10062d:	c7 40 08 78 65 10 00 	movl   $0x106578,0x8(%eax)
    info->eip_fn_namelen = 9;
  100634:	8b 45 0c             	mov    0xc(%ebp),%eax
  100637:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10063e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100641:	8b 55 08             	mov    0x8(%ebp),%edx
  100644:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100647:	8b 45 0c             	mov    0xc(%ebp),%eax
  10064a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100651:	c7 45 f4 38 78 10 00 	movl   $0x107838,-0xc(%ebp)
    stab_end = __STAB_END__;
  100658:	c7 45 f0 a0 2d 11 00 	movl   $0x112da0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10065f:	c7 45 ec a1 2d 11 00 	movl   $0x112da1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  100666:	c7 45 e8 d4 58 11 00 	movl   $0x1158d4,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  10066d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100670:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  100673:	76 0b                	jbe    100680 <debuginfo_eip+0x6f>
  100675:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100678:	48                   	dec    %eax
  100679:	0f b6 00             	movzbl (%eax),%eax
  10067c:	84 c0                	test   %al,%al
  10067e:	74 0a                	je     10068a <debuginfo_eip+0x79>
        return -1;
  100680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100685:	e9 b7 02 00 00       	jmp    100941 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  10068a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  100691:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100697:	29 c2                	sub    %eax,%edx
  100699:	89 d0                	mov    %edx,%eax
  10069b:	c1 f8 02             	sar    $0x2,%eax
  10069e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1006a4:	48                   	dec    %eax
  1006a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1006a8:	8b 45 08             	mov    0x8(%ebp),%eax
  1006ab:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006af:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1006b6:	00 
  1006b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1006ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  1006be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006c8:	89 04 24             	mov    %eax,(%esp)
  1006cb:	e8 f3 fd ff ff       	call   1004c3 <stab_binsearch>
    if (lfile == 0)
  1006d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006d3:	85 c0                	test   %eax,%eax
  1006d5:	75 0a                	jne    1006e1 <debuginfo_eip+0xd0>
        return -1;
  1006d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1006dc:	e9 60 02 00 00       	jmp    100941 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  1006e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006e4:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  1006ed:	8b 45 08             	mov    0x8(%ebp),%eax
  1006f0:	89 44 24 10          	mov    %eax,0x10(%esp)
  1006f4:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  1006fb:	00 
  1006fc:	8d 45 d8             	lea    -0x28(%ebp),%eax
  1006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  100703:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100706:	89 44 24 04          	mov    %eax,0x4(%esp)
  10070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10070d:	89 04 24             	mov    %eax,(%esp)
  100710:	e8 ae fd ff ff       	call   1004c3 <stab_binsearch>

    if (lfun <= rfun) {
  100715:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100718:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10071b:	39 c2                	cmp    %eax,%edx
  10071d:	7f 7c                	jg     10079b <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10071f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100722:	89 c2                	mov    %eax,%edx
  100724:	89 d0                	mov    %edx,%eax
  100726:	01 c0                	add    %eax,%eax
  100728:	01 d0                	add    %edx,%eax
  10072a:	c1 e0 02             	shl    $0x2,%eax
  10072d:	89 c2                	mov    %eax,%edx
  10072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100732:	01 d0                	add    %edx,%eax
  100734:	8b 00                	mov    (%eax),%eax
  100736:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  100739:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10073c:	29 d1                	sub    %edx,%ecx
  10073e:	89 ca                	mov    %ecx,%edx
  100740:	39 d0                	cmp    %edx,%eax
  100742:	73 22                	jae    100766 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  100744:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100747:	89 c2                	mov    %eax,%edx
  100749:	89 d0                	mov    %edx,%eax
  10074b:	01 c0                	add    %eax,%eax
  10074d:	01 d0                	add    %edx,%eax
  10074f:	c1 e0 02             	shl    $0x2,%eax
  100752:	89 c2                	mov    %eax,%edx
  100754:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100757:	01 d0                	add    %edx,%eax
  100759:	8b 10                	mov    (%eax),%edx
  10075b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10075e:	01 c2                	add    %eax,%edx
  100760:	8b 45 0c             	mov    0xc(%ebp),%eax
  100763:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  100766:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100769:	89 c2                	mov    %eax,%edx
  10076b:	89 d0                	mov    %edx,%eax
  10076d:	01 c0                	add    %eax,%eax
  10076f:	01 d0                	add    %edx,%eax
  100771:	c1 e0 02             	shl    $0x2,%eax
  100774:	89 c2                	mov    %eax,%edx
  100776:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100779:	01 d0                	add    %edx,%eax
  10077b:	8b 50 08             	mov    0x8(%eax),%edx
  10077e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100781:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  100784:	8b 45 0c             	mov    0xc(%ebp),%eax
  100787:	8b 40 10             	mov    0x10(%eax),%eax
  10078a:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  10078d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100790:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  100793:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100796:	89 45 d0             	mov    %eax,-0x30(%ebp)
  100799:	eb 15                	jmp    1007b0 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  10079b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10079e:	8b 55 08             	mov    0x8(%ebp),%edx
  1007a1:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1007a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1007aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1007ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007b3:	8b 40 08             	mov    0x8(%eax),%eax
  1007b6:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1007bd:	00 
  1007be:	89 04 24             	mov    %eax,(%esp)
  1007c1:	e8 31 53 00 00       	call   105af7 <strfind>
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007cb:	8b 40 08             	mov    0x8(%eax),%eax
  1007ce:	29 c2                	sub    %eax,%edx
  1007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1007d3:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  1007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  1007d9:	89 44 24 10          	mov    %eax,0x10(%esp)
  1007dd:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  1007e4:	00 
  1007e5:	8d 45 d0             	lea    -0x30(%ebp),%eax
  1007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  1007ec:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  1007ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  1007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f6:	89 04 24             	mov    %eax,(%esp)
  1007f9:	e8 c5 fc ff ff       	call   1004c3 <stab_binsearch>
    if (lline <= rline) {
  1007fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100801:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100804:	39 c2                	cmp    %eax,%edx
  100806:	7f 23                	jg     10082b <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
  100808:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10080b:	89 c2                	mov    %eax,%edx
  10080d:	89 d0                	mov    %edx,%eax
  10080f:	01 c0                	add    %eax,%eax
  100811:	01 d0                	add    %edx,%eax
  100813:	c1 e0 02             	shl    $0x2,%eax
  100816:	89 c2                	mov    %eax,%edx
  100818:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10081b:	01 d0                	add    %edx,%eax
  10081d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100821:	89 c2                	mov    %eax,%edx
  100823:	8b 45 0c             	mov    0xc(%ebp),%eax
  100826:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100829:	eb 11                	jmp    10083c <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
  10082b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100830:	e9 0c 01 00 00       	jmp    100941 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  100835:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100838:	48                   	dec    %eax
  100839:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  10083c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10083f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100842:	39 c2                	cmp    %eax,%edx
  100844:	7c 56                	jl     10089c <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
  100846:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100849:	89 c2                	mov    %eax,%edx
  10084b:	89 d0                	mov    %edx,%eax
  10084d:	01 c0                	add    %eax,%eax
  10084f:	01 d0                	add    %edx,%eax
  100851:	c1 e0 02             	shl    $0x2,%eax
  100854:	89 c2                	mov    %eax,%edx
  100856:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100859:	01 d0                	add    %edx,%eax
  10085b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10085f:	3c 84                	cmp    $0x84,%al
  100861:	74 39                	je     10089c <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  100863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100866:	89 c2                	mov    %eax,%edx
  100868:	89 d0                	mov    %edx,%eax
  10086a:	01 c0                	add    %eax,%eax
  10086c:	01 d0                	add    %edx,%eax
  10086e:	c1 e0 02             	shl    $0x2,%eax
  100871:	89 c2                	mov    %eax,%edx
  100873:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100876:	01 d0                	add    %edx,%eax
  100878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10087c:	3c 64                	cmp    $0x64,%al
  10087e:	75 b5                	jne    100835 <debuginfo_eip+0x224>
  100880:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100883:	89 c2                	mov    %eax,%edx
  100885:	89 d0                	mov    %edx,%eax
  100887:	01 c0                	add    %eax,%eax
  100889:	01 d0                	add    %edx,%eax
  10088b:	c1 e0 02             	shl    $0x2,%eax
  10088e:	89 c2                	mov    %eax,%edx
  100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100893:	01 d0                	add    %edx,%eax
  100895:	8b 40 08             	mov    0x8(%eax),%eax
  100898:	85 c0                	test   %eax,%eax
  10089a:	74 99                	je     100835 <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  10089c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10089f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1008a2:	39 c2                	cmp    %eax,%edx
  1008a4:	7c 46                	jl     1008ec <debuginfo_eip+0x2db>
  1008a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008a9:	89 c2                	mov    %eax,%edx
  1008ab:	89 d0                	mov    %edx,%eax
  1008ad:	01 c0                	add    %eax,%eax
  1008af:	01 d0                	add    %edx,%eax
  1008b1:	c1 e0 02             	shl    $0x2,%eax
  1008b4:	89 c2                	mov    %eax,%edx
  1008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008b9:	01 d0                	add    %edx,%eax
  1008bb:	8b 00                	mov    (%eax),%eax
  1008bd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
  1008c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1008c3:	29 d1                	sub    %edx,%ecx
  1008c5:	89 ca                	mov    %ecx,%edx
  1008c7:	39 d0                	cmp    %edx,%eax
  1008c9:	73 21                	jae    1008ec <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1008cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1008ce:	89 c2                	mov    %eax,%edx
  1008d0:	89 d0                	mov    %edx,%eax
  1008d2:	01 c0                	add    %eax,%eax
  1008d4:	01 d0                	add    %edx,%eax
  1008d6:	c1 e0 02             	shl    $0x2,%eax
  1008d9:	89 c2                	mov    %eax,%edx
  1008db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1008de:	01 d0                	add    %edx,%eax
  1008e0:	8b 10                	mov    (%eax),%edx
  1008e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1008e5:	01 c2                	add    %eax,%edx
  1008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1008ea:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  1008ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1008ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1008f2:	39 c2                	cmp    %eax,%edx
  1008f4:	7d 46                	jge    10093c <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
  1008f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1008f9:	40                   	inc    %eax
  1008fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  1008fd:	eb 16                	jmp    100915 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  1008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100902:	8b 40 14             	mov    0x14(%eax),%eax
  100905:	8d 50 01             	lea    0x1(%eax),%edx
  100908:	8b 45 0c             	mov    0xc(%ebp),%eax
  10090b:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
  10090e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100911:	40                   	inc    %eax
  100912:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100915:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100918:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
  10091b:	39 c2                	cmp    %eax,%edx
  10091d:	7d 1d                	jge    10093c <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
  10091f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100922:	89 c2                	mov    %eax,%edx
  100924:	89 d0                	mov    %edx,%eax
  100926:	01 c0                	add    %eax,%eax
  100928:	01 d0                	add    %edx,%eax
  10092a:	c1 e0 02             	shl    $0x2,%eax
  10092d:	89 c2                	mov    %eax,%edx
  10092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100932:	01 d0                	add    %edx,%eax
  100934:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100938:	3c a0                	cmp    $0xa0,%al
  10093a:	74 c3                	je     1008ff <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
  10093c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100941:	c9                   	leave  
  100942:	c3                   	ret    

00100943 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100943:	55                   	push   %ebp
  100944:	89 e5                	mov    %esp,%ebp
  100946:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  100949:	c7 04 24 82 65 10 00 	movl   $0x106582,(%esp)
  100950:	e8 48 f9 ff ff       	call   10029d <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  100955:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  10095c:	00 
  10095d:	c7 04 24 9b 65 10 00 	movl   $0x10659b,(%esp)
  100964:	e8 34 f9 ff ff       	call   10029d <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  100969:	c7 44 24 04 75 64 10 	movl   $0x106475,0x4(%esp)
  100970:	00 
  100971:	c7 04 24 b3 65 10 00 	movl   $0x1065b3,(%esp)
  100978:	e8 20 f9 ff ff       	call   10029d <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  10097d:	c7 44 24 04 36 8a 11 	movl   $0x118a36,0x4(%esp)
  100984:	00 
  100985:	c7 04 24 cb 65 10 00 	movl   $0x1065cb,(%esp)
  10098c:	e8 0c f9 ff ff       	call   10029d <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  100991:	c7 44 24 04 a8 bf 11 	movl   $0x11bfa8,0x4(%esp)
  100998:	00 
  100999:	c7 04 24 e3 65 10 00 	movl   $0x1065e3,(%esp)
  1009a0:	e8 f8 f8 ff ff       	call   10029d <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1009a5:	b8 a8 bf 11 00       	mov    $0x11bfa8,%eax
  1009aa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009b0:	b8 36 00 10 00       	mov    $0x100036,%eax
  1009b5:	29 c2                	sub    %eax,%edx
  1009b7:	89 d0                	mov    %edx,%eax
  1009b9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1009bf:	85 c0                	test   %eax,%eax
  1009c1:	0f 48 c2             	cmovs  %edx,%eax
  1009c4:	c1 f8 0a             	sar    $0xa,%eax
  1009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009cb:	c7 04 24 fc 65 10 00 	movl   $0x1065fc,(%esp)
  1009d2:	e8 c6 f8 ff ff       	call   10029d <cprintf>
}
  1009d7:	90                   	nop
  1009d8:	c9                   	leave  
  1009d9:	c3                   	ret    

001009da <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  1009da:	55                   	push   %ebp
  1009db:	89 e5                	mov    %esp,%ebp
  1009dd:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  1009e3:	8d 45 dc             	lea    -0x24(%ebp),%eax
  1009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009ea:	8b 45 08             	mov    0x8(%ebp),%eax
  1009ed:	89 04 24             	mov    %eax,(%esp)
  1009f0:	e8 1c fc ff ff       	call   100611 <debuginfo_eip>
  1009f5:	85 c0                	test   %eax,%eax
  1009f7:	74 15                	je     100a0e <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  1009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  1009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a00:	c7 04 24 26 66 10 00 	movl   $0x106626,(%esp)
  100a07:	e8 91 f8 ff ff       	call   10029d <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  100a0c:	eb 6c                	jmp    100a7a <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100a15:	eb 1b                	jmp    100a32 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  100a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  100a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a1d:	01 d0                	add    %edx,%eax
  100a1f:	0f b6 00             	movzbl (%eax),%eax
  100a22:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100a2b:	01 ca                	add    %ecx,%edx
  100a2d:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100a2f:	ff 45 f4             	incl   -0xc(%ebp)
  100a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a35:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  100a38:	7f dd                	jg     100a17 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
  100a3a:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a43:	01 d0                	add    %edx,%eax
  100a45:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
  100a48:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  100a4b:	8b 55 08             	mov    0x8(%ebp),%edx
  100a4e:	89 d1                	mov    %edx,%ecx
  100a50:	29 c1                	sub    %eax,%ecx
  100a52:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100a55:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100a58:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  100a5c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100a62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a66:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a6e:	c7 04 24 42 66 10 00 	movl   $0x106642,(%esp)
  100a75:	e8 23 f8 ff ff       	call   10029d <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
  100a7a:	90                   	nop
  100a7b:	c9                   	leave  
  100a7c:	c3                   	ret    

00100a7d <read_eip>:

static __noinline uint32_t
read_eip(void) {
  100a7d:	55                   	push   %ebp
  100a7e:	89 e5                	mov    %esp,%ebp
  100a80:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  100a83:	8b 45 04             	mov    0x4(%ebp),%eax
  100a86:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  100a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  100a8c:	c9                   	leave  
  100a8d:	c3                   	ret    

00100a8e <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  100a8e:	55                   	push   %ebp
  100a8f:	89 e5                	mov    %esp,%ebp
  100a91:	83 ec 48             	sub    $0x48,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  100a94:	89 e8                	mov    %ebp,%eax
  100a96:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ebp;
  100a99:	8b 45 d8             	mov    -0x28(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
  100a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
  100a9f:	e8 d9 ff ff ff       	call   100a7d <read_eip>
  100aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
  100aa7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  100aae:	e9 9b 00 00 00       	jmp    100b4e <print_stackframe+0xc0>
        cprintf("ebp:0x%08x eip:0x%08x ",ebp,eip);
  100ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100ab6:	89 44 24 08          	mov    %eax,0x8(%esp)
  100aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac1:	c7 04 24 54 66 10 00 	movl   $0x106654,(%esp)
  100ac8:	e8 d0 f7 ff ff       	call   10029d <cprintf>
        arg0 = *((uint32_t *)ebp + 2);
  100acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ad0:	83 c0 08             	add    $0x8,%eax
  100ad3:	8b 00                	mov    (%eax),%eax
  100ad5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        arg1 = *((uint32_t *)ebp + 3);
  100ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100adb:	83 c0 0c             	add    $0xc,%eax
  100ade:	8b 00                	mov    (%eax),%eax
  100ae0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        arg2 = *((uint32_t *)ebp + 4);
  100ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100ae6:	83 c0 10             	add    $0x10,%eax
  100ae9:	8b 00                	mov    (%eax),%eax
  100aeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        arg3 = *((uint32_t *)ebp + 5);
  100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af1:	83 c0 14             	add    $0x14,%eax
  100af4:	8b 00                	mov    (%eax),%eax
  100af6:	89 45 dc             	mov    %eax,-0x24(%ebp)
        cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x",arg0,arg1,arg2,arg3);
  100af9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  100afc:	89 44 24 10          	mov    %eax,0x10(%esp)
  100b00:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100b03:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  100b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b15:	c7 04 24 6c 66 10 00 	movl   $0x10666c,(%esp)
  100b1c:	e8 7c f7 ff ff       	call   10029d <cprintf>
        cprintf("\n");
  100b21:	c7 04 24 8d 66 10 00 	movl   $0x10668d,(%esp)
  100b28:	e8 70 f7 ff ff       	call   10029d <cprintf>
        print_debuginfo(eip);
  100b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100b30:	89 04 24             	mov    %eax,(%esp)
  100b33:	e8 a2 fe ff ff       	call   1009da <print_debuginfo>
        eip = *((uint32_t *)ebp + 1);
  100b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b3b:	83 c0 04             	add    $0x4,%eax
  100b3e:	8b 00                	mov    (%eax),%eax
  100b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = *((uint32_t *)ebp);
  100b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100b46:	8b 00                	mov    (%eax),%eax
  100b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
  100b4b:	ff 45 ec             	incl   -0x14(%ebp)
  100b4e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100b52:	7f 0a                	jg     100b5e <print_stackframe+0xd0>
  100b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100b58:	0f 85 55 ff ff ff    	jne    100ab3 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip);
        eip = *((uint32_t *)ebp + 1);
        ebp = *((uint32_t *)ebp);
    }
}
  100b5e:	90                   	nop
  100b5f:	c9                   	leave  
  100b60:	c3                   	ret    

00100b61 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100b61:	55                   	push   %ebp
  100b62:	89 e5                	mov    %esp,%ebp
  100b64:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100b67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b6e:	eb 0c                	jmp    100b7c <parse+0x1b>
            *buf ++ = '\0';
  100b70:	8b 45 08             	mov    0x8(%ebp),%eax
  100b73:	8d 50 01             	lea    0x1(%eax),%edx
  100b76:	89 55 08             	mov    %edx,0x8(%ebp)
  100b79:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b7c:	8b 45 08             	mov    0x8(%ebp),%eax
  100b7f:	0f b6 00             	movzbl (%eax),%eax
  100b82:	84 c0                	test   %al,%al
  100b84:	74 1d                	je     100ba3 <parse+0x42>
  100b86:	8b 45 08             	mov    0x8(%ebp),%eax
  100b89:	0f b6 00             	movzbl (%eax),%eax
  100b8c:	0f be c0             	movsbl %al,%eax
  100b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b93:	c7 04 24 10 67 10 00 	movl   $0x106710,(%esp)
  100b9a:	e8 26 4f 00 00       	call   105ac5 <strchr>
  100b9f:	85 c0                	test   %eax,%eax
  100ba1:	75 cd                	jne    100b70 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
  100ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  100ba6:	0f b6 00             	movzbl (%eax),%eax
  100ba9:	84 c0                	test   %al,%al
  100bab:	74 69                	je     100c16 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100bad:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100bb1:	75 14                	jne    100bc7 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100bb3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100bba:	00 
  100bbb:	c7 04 24 15 67 10 00 	movl   $0x106715,(%esp)
  100bc2:	e8 d6 f6 ff ff       	call   10029d <cprintf>
        }
        argv[argc ++] = buf;
  100bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bca:	8d 50 01             	lea    0x1(%eax),%edx
  100bcd:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100bd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  100bda:	01 c2                	add    %eax,%edx
  100bdc:	8b 45 08             	mov    0x8(%ebp),%eax
  100bdf:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100be1:	eb 03                	jmp    100be6 <parse+0x85>
            buf ++;
  100be3:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100be6:	8b 45 08             	mov    0x8(%ebp),%eax
  100be9:	0f b6 00             	movzbl (%eax),%eax
  100bec:	84 c0                	test   %al,%al
  100bee:	0f 84 7a ff ff ff    	je     100b6e <parse+0xd>
  100bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  100bf7:	0f b6 00             	movzbl (%eax),%eax
  100bfa:	0f be c0             	movsbl %al,%eax
  100bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c01:	c7 04 24 10 67 10 00 	movl   $0x106710,(%esp)
  100c08:	e8 b8 4e 00 00       	call   105ac5 <strchr>
  100c0d:	85 c0                	test   %eax,%eax
  100c0f:	74 d2                	je     100be3 <parse+0x82>
            buf ++;
        }
    }
  100c11:	e9 58 ff ff ff       	jmp    100b6e <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
  100c16:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
  100c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100c1a:	c9                   	leave  
  100c1b:	c3                   	ret    

00100c1c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100c1c:	55                   	push   %ebp
  100c1d:	89 e5                	mov    %esp,%ebp
  100c1f:	53                   	push   %ebx
  100c20:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100c23:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c26:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  100c2d:	89 04 24             	mov    %eax,(%esp)
  100c30:	e8 2c ff ff ff       	call   100b61 <parse>
  100c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100c38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100c3c:	75 0a                	jne    100c48 <runcmd+0x2c>
        return 0;
  100c3e:	b8 00 00 00 00       	mov    $0x0,%eax
  100c43:	e9 83 00 00 00       	jmp    100ccb <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c4f:	eb 5a                	jmp    100cab <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100c51:	8b 4d b0             	mov    -0x50(%ebp),%ecx
  100c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c57:	89 d0                	mov    %edx,%eax
  100c59:	01 c0                	add    %eax,%eax
  100c5b:	01 d0                	add    %edx,%eax
  100c5d:	c1 e0 02             	shl    $0x2,%eax
  100c60:	05 00 80 11 00       	add    $0x118000,%eax
  100c65:	8b 00                	mov    (%eax),%eax
  100c67:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  100c6b:	89 04 24             	mov    %eax,(%esp)
  100c6e:	e8 b5 4d 00 00       	call   105a28 <strcmp>
  100c73:	85 c0                	test   %eax,%eax
  100c75:	75 31                	jne    100ca8 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
  100c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c7a:	89 d0                	mov    %edx,%eax
  100c7c:	01 c0                	add    %eax,%eax
  100c7e:	01 d0                	add    %edx,%eax
  100c80:	c1 e0 02             	shl    $0x2,%eax
  100c83:	05 08 80 11 00       	add    $0x118008,%eax
  100c88:	8b 10                	mov    (%eax),%edx
  100c8a:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100c8d:	83 c0 04             	add    $0x4,%eax
  100c90:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100c93:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100c99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ca1:	89 1c 24             	mov    %ebx,(%esp)
  100ca4:	ff d2                	call   *%edx
  100ca6:	eb 23                	jmp    100ccb <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100ca8:	ff 45 f4             	incl   -0xc(%ebp)
  100cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cae:	83 f8 02             	cmp    $0x2,%eax
  100cb1:	76 9e                	jbe    100c51 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100cb3:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
  100cba:	c7 04 24 33 67 10 00 	movl   $0x106733,(%esp)
  100cc1:	e8 d7 f5 ff ff       	call   10029d <cprintf>
    return 0;
  100cc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ccb:	83 c4 64             	add    $0x64,%esp
  100cce:	5b                   	pop    %ebx
  100ccf:	5d                   	pop    %ebp
  100cd0:	c3                   	ret    

00100cd1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100cd1:	55                   	push   %ebp
  100cd2:	89 e5                	mov    %esp,%ebp
  100cd4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100cd7:	c7 04 24 4c 67 10 00 	movl   $0x10674c,(%esp)
  100cde:	e8 ba f5 ff ff       	call   10029d <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100ce3:	c7 04 24 74 67 10 00 	movl   $0x106774,(%esp)
  100cea:	e8 ae f5 ff ff       	call   10029d <cprintf>

    if (tf != NULL) {
  100cef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100cf3:	74 0b                	je     100d00 <kmonitor+0x2f>
        print_trapframe(tf);
  100cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  100cf8:	89 04 24             	mov    %eax,(%esp)
  100cfb:	e8 9b 0e 00 00       	call   101b9b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100d00:	c7 04 24 99 67 10 00 	movl   $0x106799,(%esp)
  100d07:	e8 33 f6 ff ff       	call   10033f <readline>
  100d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100d13:	74 eb                	je     100d00 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100d15:	8b 45 08             	mov    0x8(%ebp),%eax
  100d18:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d1f:	89 04 24             	mov    %eax,(%esp)
  100d22:	e8 f5 fe ff ff       	call   100c1c <runcmd>
  100d27:	85 c0                	test   %eax,%eax
  100d29:	78 02                	js     100d2d <kmonitor+0x5c>
                break;
            }
        }
    }
  100d2b:	eb d3                	jmp    100d00 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
  100d2d:	90                   	nop
            }
        }
    }
}
  100d2e:	90                   	nop
  100d2f:	c9                   	leave  
  100d30:	c3                   	ret    

00100d31 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100d31:	55                   	push   %ebp
  100d32:	89 e5                	mov    %esp,%ebp
  100d34:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100d3e:	eb 3d                	jmp    100d7d <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100d40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d43:	89 d0                	mov    %edx,%eax
  100d45:	01 c0                	add    %eax,%eax
  100d47:	01 d0                	add    %edx,%eax
  100d49:	c1 e0 02             	shl    $0x2,%eax
  100d4c:	05 04 80 11 00       	add    $0x118004,%eax
  100d51:	8b 08                	mov    (%eax),%ecx
  100d53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100d56:	89 d0                	mov    %edx,%eax
  100d58:	01 c0                	add    %eax,%eax
  100d5a:	01 d0                	add    %edx,%eax
  100d5c:	c1 e0 02             	shl    $0x2,%eax
  100d5f:	05 00 80 11 00       	add    $0x118000,%eax
  100d64:	8b 00                	mov    (%eax),%eax
  100d66:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d6e:	c7 04 24 9d 67 10 00 	movl   $0x10679d,(%esp)
  100d75:	e8 23 f5 ff ff       	call   10029d <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100d7a:	ff 45 f4             	incl   -0xc(%ebp)
  100d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d80:	83 f8 02             	cmp    $0x2,%eax
  100d83:	76 bb                	jbe    100d40 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
  100d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d8a:	c9                   	leave  
  100d8b:	c3                   	ret    

00100d8c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100d8c:	55                   	push   %ebp
  100d8d:	89 e5                	mov    %esp,%ebp
  100d8f:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100d92:	e8 ac fb ff ff       	call   100943 <print_kerninfo>
    return 0;
  100d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100d9c:	c9                   	leave  
  100d9d:	c3                   	ret    

00100d9e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100d9e:	55                   	push   %ebp
  100d9f:	89 e5                	mov    %esp,%ebp
  100da1:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100da4:	e8 e5 fc ff ff       	call   100a8e <print_stackframe>
    return 0;
  100da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100dae:	c9                   	leave  
  100daf:	c3                   	ret    

00100db0 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100db0:	55                   	push   %ebp
  100db1:	89 e5                	mov    %esp,%ebp
  100db3:	83 ec 28             	sub    $0x28,%esp
  100db6:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
  100dbc:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dc0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
  100dc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100dc8:	ee                   	out    %al,(%dx)
  100dc9:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
  100dcf:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
  100dd3:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  100dd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100dda:	ee                   	out    %al,(%dx)
  100ddb:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100de1:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
  100de5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100de9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100ded:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dee:	c7 05 2c bf 11 00 00 	movl   $0x0,0x11bf2c
  100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100df8:	c7 04 24 a6 67 10 00 	movl   $0x1067a6,(%esp)
  100dff:	e8 99 f4 ff ff       	call   10029d <cprintf>
    pic_enable(IRQ_TIMER);
  100e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e0b:	e8 1e 09 00 00       	call   10172e <pic_enable>
}
  100e10:	90                   	nop
  100e11:	c9                   	leave  
  100e12:	c3                   	ret    

00100e13 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e13:	55                   	push   %ebp
  100e14:	89 e5                	mov    %esp,%ebp
  100e16:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e19:	9c                   	pushf  
  100e1a:	58                   	pop    %eax
  100e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e21:	25 00 02 00 00       	and    $0x200,%eax
  100e26:	85 c0                	test   %eax,%eax
  100e28:	74 0c                	je     100e36 <__intr_save+0x23>
        intr_disable();
  100e2a:	e8 6c 0a 00 00       	call   10189b <intr_disable>
        return 1;
  100e2f:	b8 01 00 00 00       	mov    $0x1,%eax
  100e34:	eb 05                	jmp    100e3b <__intr_save+0x28>
    }
    return 0;
  100e36:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e3b:	c9                   	leave  
  100e3c:	c3                   	ret    

00100e3d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e3d:	55                   	push   %ebp
  100e3e:	89 e5                	mov    %esp,%ebp
  100e40:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e43:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e47:	74 05                	je     100e4e <__intr_restore+0x11>
        intr_enable();
  100e49:	e8 46 0a 00 00       	call   101894 <intr_enable>
    }
}
  100e4e:	90                   	nop
  100e4f:	c9                   	leave  
  100e50:	c3                   	ret    

00100e51 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e51:	55                   	push   %ebp
  100e52:	89 e5                	mov    %esp,%ebp
  100e54:	83 ec 10             	sub    $0x10,%esp
  100e57:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e5d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100e61:	89 c2                	mov    %eax,%edx
  100e63:	ec                   	in     (%dx),%al
  100e64:	88 45 f4             	mov    %al,-0xc(%ebp)
  100e67:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
  100e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100e70:	89 c2                	mov    %eax,%edx
  100e72:	ec                   	in     (%dx),%al
  100e73:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e76:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e7c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e80:	89 c2                	mov    %eax,%edx
  100e82:	ec                   	in     (%dx),%al
  100e83:	88 45 f6             	mov    %al,-0xa(%ebp)
  100e86:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
  100e8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100e8f:	89 c2                	mov    %eax,%edx
  100e91:	ec                   	in     (%dx),%al
  100e92:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100e95:	90                   	nop
  100e96:	c9                   	leave  
  100e97:	c3                   	ret    

00100e98 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100e98:	55                   	push   %ebp
  100e99:	89 e5                	mov    %esp,%ebp
  100e9b:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100e9e:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ea8:	0f b7 00             	movzwl (%eax),%eax
  100eab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eb2:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100eba:	0f b7 00             	movzwl (%eax),%eax
  100ebd:	0f b7 c0             	movzwl %ax,%eax
  100ec0:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100ec5:	74 12                	je     100ed9 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100ec7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ece:	66 c7 05 46 b4 11 00 	movw   $0x3b4,0x11b446
  100ed5:	b4 03 
  100ed7:	eb 13                	jmp    100eec <cga_init+0x54>
    } else {
        *cp = was;
  100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ee3:	66 c7 05 46 b4 11 00 	movw   $0x3d4,0x11b446
  100eea:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100eec:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100ef3:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
  100ef7:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100efb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  100eff:	8b 55 f8             	mov    -0x8(%ebp),%edx
  100f02:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
  100f03:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f0a:	40                   	inc    %eax
  100f0b:	0f b7 c0             	movzwl %ax,%eax
  100f0e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f12:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f16:	89 c2                	mov    %eax,%edx
  100f18:	ec                   	in     (%dx),%al
  100f19:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  100f1c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  100f20:	0f b6 c0             	movzbl %al,%eax
  100f23:	c1 e0 08             	shl    $0x8,%eax
  100f26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f29:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f30:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
  100f34:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f38:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
  100f3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100f3f:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
  100f40:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  100f47:	40                   	inc    %eax
  100f48:	0f b7 c0             	movzwl %ax,%eax
  100f4b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f4f:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  100f53:	89 c2                	mov    %eax,%edx
  100f55:	ec                   	in     (%dx),%al
  100f56:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  100f59:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f5d:	0f b6 c0             	movzbl %al,%eax
  100f60:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f63:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f66:	a3 40 b4 11 00       	mov    %eax,0x11b440
    crt_pos = pos;
  100f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f6e:	0f b7 c0             	movzwl %ax,%eax
  100f71:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
}
  100f77:	90                   	nop
  100f78:	c9                   	leave  
  100f79:	c3                   	ret    

00100f7a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f7a:	55                   	push   %ebp
  100f7b:	89 e5                	mov    %esp,%ebp
  100f7d:	83 ec 38             	sub    $0x38,%esp
  100f80:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
  100f86:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f8a:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  100f8e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100f92:	ee                   	out    %al,(%dx)
  100f93:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
  100f99:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
  100f9d:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  100fa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100fa4:	ee                   	out    %al,(%dx)
  100fa5:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
  100fab:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
  100faf:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  100fb3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100fb7:	ee                   	out    %al,(%dx)
  100fb8:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
  100fbe:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
  100fc2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fc6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100fc9:	ee                   	out    %al,(%dx)
  100fca:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
  100fd0:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
  100fd4:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  100fd8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100fdc:	ee                   	out    %al,(%dx)
  100fdd:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
  100fe3:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
  100fe7:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  100feb:	8b 55 ec             	mov    -0x14(%ebp),%edx
  100fee:	ee                   	out    %al,(%dx)
  100fef:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  100ff5:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
  100ff9:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  100ffd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101001:	ee                   	out    %al,(%dx)
  101002:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101008:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10100b:	89 c2                	mov    %eax,%edx
  10100d:	ec                   	in     (%dx),%al
  10100e:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
  101011:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  101015:	3c ff                	cmp    $0xff,%al
  101017:	0f 95 c0             	setne  %al
  10101a:	0f b6 c0             	movzbl %al,%eax
  10101d:	a3 48 b4 11 00       	mov    %eax,0x11b448
  101022:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101028:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
  10102c:	89 c2                	mov    %eax,%edx
  10102e:	ec                   	in     (%dx),%al
  10102f:	88 45 e2             	mov    %al,-0x1e(%ebp)
  101032:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
  101038:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10103b:	89 c2                	mov    %eax,%edx
  10103d:	ec                   	in     (%dx),%al
  10103e:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101041:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101046:	85 c0                	test   %eax,%eax
  101048:	74 0c                	je     101056 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
  10104a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101051:	e8 d8 06 00 00       	call   10172e <pic_enable>
    }
}
  101056:	90                   	nop
  101057:	c9                   	leave  
  101058:	c3                   	ret    

00101059 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101059:	55                   	push   %ebp
  10105a:	89 e5                	mov    %esp,%ebp
  10105c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10105f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101066:	eb 08                	jmp    101070 <lpt_putc_sub+0x17>
        delay();
  101068:	e8 e4 fd ff ff       	call   100e51 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  10106d:	ff 45 fc             	incl   -0x4(%ebp)
  101070:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
  101076:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101079:	89 c2                	mov    %eax,%edx
  10107b:	ec                   	in     (%dx),%al
  10107c:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
  10107f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101083:	84 c0                	test   %al,%al
  101085:	78 09                	js     101090 <lpt_putc_sub+0x37>
  101087:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10108e:	7e d8                	jle    101068 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
  101090:	8b 45 08             	mov    0x8(%ebp),%eax
  101093:	0f b6 c0             	movzbl %al,%eax
  101096:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
  10109c:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10109f:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
  1010a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1010a6:	ee                   	out    %al,(%dx)
  1010a7:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010ad:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
  1010b1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010b5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010b9:	ee                   	out    %al,(%dx)
  1010ba:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
  1010c0:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
  1010c4:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
  1010c8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1010cc:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010cd:	90                   	nop
  1010ce:	c9                   	leave  
  1010cf:	c3                   	ret    

001010d0 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  1010d0:	55                   	push   %ebp
  1010d1:	89 e5                	mov    %esp,%ebp
  1010d3:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  1010d6:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  1010da:	74 0d                	je     1010e9 <lpt_putc+0x19>
        lpt_putc_sub(c);
  1010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1010df:	89 04 24             	mov    %eax,(%esp)
  1010e2:	e8 72 ff ff ff       	call   101059 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  1010e7:	eb 24                	jmp    10110d <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
  1010e9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1010f0:	e8 64 ff ff ff       	call   101059 <lpt_putc_sub>
        lpt_putc_sub(' ');
  1010f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1010fc:	e8 58 ff ff ff       	call   101059 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101101:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101108:	e8 4c ff ff ff       	call   101059 <lpt_putc_sub>
    }
}
  10110d:	90                   	nop
  10110e:	c9                   	leave  
  10110f:	c3                   	ret    

00101110 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101110:	55                   	push   %ebp
  101111:	89 e5                	mov    %esp,%ebp
  101113:	53                   	push   %ebx
  101114:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
  101117:	8b 45 08             	mov    0x8(%ebp),%eax
  10111a:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10111f:	85 c0                	test   %eax,%eax
  101121:	75 07                	jne    10112a <cga_putc+0x1a>
        c |= 0x0700;
  101123:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10112a:	8b 45 08             	mov    0x8(%ebp),%eax
  10112d:	0f b6 c0             	movzbl %al,%eax
  101130:	83 f8 0a             	cmp    $0xa,%eax
  101133:	74 54                	je     101189 <cga_putc+0x79>
  101135:	83 f8 0d             	cmp    $0xd,%eax
  101138:	74 62                	je     10119c <cga_putc+0x8c>
  10113a:	83 f8 08             	cmp    $0x8,%eax
  10113d:	0f 85 93 00 00 00    	jne    1011d6 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
  101143:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10114a:	85 c0                	test   %eax,%eax
  10114c:	0f 84 ae 00 00 00    	je     101200 <cga_putc+0xf0>
            crt_pos --;
  101152:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101159:	48                   	dec    %eax
  10115a:	0f b7 c0             	movzwl %ax,%eax
  10115d:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  101163:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101168:	0f b7 15 44 b4 11 00 	movzwl 0x11b444,%edx
  10116f:	01 d2                	add    %edx,%edx
  101171:	01 c2                	add    %eax,%edx
  101173:	8b 45 08             	mov    0x8(%ebp),%eax
  101176:	98                   	cwtl   
  101177:	25 00 ff ff ff       	and    $0xffffff00,%eax
  10117c:	98                   	cwtl   
  10117d:	83 c8 20             	or     $0x20,%eax
  101180:	98                   	cwtl   
  101181:	0f b7 c0             	movzwl %ax,%eax
  101184:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  101187:	eb 77                	jmp    101200 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
  101189:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101190:	83 c0 50             	add    $0x50,%eax
  101193:	0f b7 c0             	movzwl %ax,%eax
  101196:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  10119c:	0f b7 1d 44 b4 11 00 	movzwl 0x11b444,%ebx
  1011a3:	0f b7 0d 44 b4 11 00 	movzwl 0x11b444,%ecx
  1011aa:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011af:	89 c8                	mov    %ecx,%eax
  1011b1:	f7 e2                	mul    %edx
  1011b3:	c1 ea 06             	shr    $0x6,%edx
  1011b6:	89 d0                	mov    %edx,%eax
  1011b8:	c1 e0 02             	shl    $0x2,%eax
  1011bb:	01 d0                	add    %edx,%eax
  1011bd:	c1 e0 04             	shl    $0x4,%eax
  1011c0:	29 c1                	sub    %eax,%ecx
  1011c2:	89 c8                	mov    %ecx,%eax
  1011c4:	0f b7 c0             	movzwl %ax,%eax
  1011c7:	29 c3                	sub    %eax,%ebx
  1011c9:	89 d8                	mov    %ebx,%eax
  1011cb:	0f b7 c0             	movzwl %ax,%eax
  1011ce:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
        break;
  1011d4:	eb 2b                	jmp    101201 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  1011d6:	8b 0d 40 b4 11 00    	mov    0x11b440,%ecx
  1011dc:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1011e3:	8d 50 01             	lea    0x1(%eax),%edx
  1011e6:	0f b7 d2             	movzwl %dx,%edx
  1011e9:	66 89 15 44 b4 11 00 	mov    %dx,0x11b444
  1011f0:	01 c0                	add    %eax,%eax
  1011f2:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  1011f5:	8b 45 08             	mov    0x8(%ebp),%eax
  1011f8:	0f b7 c0             	movzwl %ax,%eax
  1011fb:	66 89 02             	mov    %ax,(%edx)
        break;
  1011fe:	eb 01                	jmp    101201 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
  101200:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101201:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101208:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  10120d:	76 5d                	jbe    10126c <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10120f:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101214:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10121a:	a1 40 b4 11 00       	mov    0x11b440,%eax
  10121f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101226:	00 
  101227:	89 54 24 04          	mov    %edx,0x4(%esp)
  10122b:	89 04 24             	mov    %eax,(%esp)
  10122e:	e8 88 4a 00 00       	call   105cbb <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101233:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10123a:	eb 14                	jmp    101250 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
  10123c:	a1 40 b4 11 00       	mov    0x11b440,%eax
  101241:	8b 55 f4             	mov    -0xc(%ebp),%edx
  101244:	01 d2                	add    %edx,%edx
  101246:	01 d0                	add    %edx,%eax
  101248:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10124d:	ff 45 f4             	incl   -0xc(%ebp)
  101250:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101257:	7e e3                	jle    10123c <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
  101259:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  101260:	83 e8 50             	sub    $0x50,%eax
  101263:	0f b7 c0             	movzwl %ax,%eax
  101266:	66 a3 44 b4 11 00    	mov    %ax,0x11b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  10126c:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  101273:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
  101277:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
  10127b:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
  10127f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  101283:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
  101284:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  10128b:	c1 e8 08             	shr    $0x8,%eax
  10128e:	0f b7 c0             	movzwl %ax,%eax
  101291:	0f b6 c0             	movzbl %al,%eax
  101294:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  10129b:	42                   	inc    %edx
  10129c:	0f b7 d2             	movzwl %dx,%edx
  10129f:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
  1012a3:	88 45 e9             	mov    %al,-0x17(%ebp)
  1012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
  1012ae:	0f b7 05 46 b4 11 00 	movzwl 0x11b446,%eax
  1012b5:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012b9:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
  1012bd:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
  1012c1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1012c5:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
  1012c6:	0f b7 05 44 b4 11 00 	movzwl 0x11b444,%eax
  1012cd:	0f b6 c0             	movzbl %al,%eax
  1012d0:	0f b7 15 46 b4 11 00 	movzwl 0x11b446,%edx
  1012d7:	42                   	inc    %edx
  1012d8:	0f b7 d2             	movzwl %dx,%edx
  1012db:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
  1012df:	88 45 eb             	mov    %al,-0x15(%ebp)
  1012e2:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
  1012e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1012e9:	ee                   	out    %al,(%dx)
}
  1012ea:	90                   	nop
  1012eb:	83 c4 24             	add    $0x24,%esp
  1012ee:	5b                   	pop    %ebx
  1012ef:	5d                   	pop    %ebp
  1012f0:	c3                   	ret    

001012f1 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  1012f1:	55                   	push   %ebp
  1012f2:	89 e5                	mov    %esp,%ebp
  1012f4:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  1012f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1012fe:	eb 08                	jmp    101308 <serial_putc_sub+0x17>
        delay();
  101300:	e8 4c fb ff ff       	call   100e51 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  101305:	ff 45 fc             	incl   -0x4(%ebp)
  101308:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10130e:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101311:	89 c2                	mov    %eax,%edx
  101313:	ec                   	in     (%dx),%al
  101314:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  101317:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10131b:	0f b6 c0             	movzbl %al,%eax
  10131e:	83 e0 20             	and    $0x20,%eax
  101321:	85 c0                	test   %eax,%eax
  101323:	75 09                	jne    10132e <serial_putc_sub+0x3d>
  101325:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  10132c:	7e d2                	jle    101300 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
  10132e:	8b 45 08             	mov    0x8(%ebp),%eax
  101331:	0f b6 c0             	movzbl %al,%eax
  101334:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
  10133a:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10133d:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
  101341:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  101345:	ee                   	out    %al,(%dx)
}
  101346:	90                   	nop
  101347:	c9                   	leave  
  101348:	c3                   	ret    

00101349 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101349:	55                   	push   %ebp
  10134a:	89 e5                	mov    %esp,%ebp
  10134c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10134f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  101353:	74 0d                	je     101362 <serial_putc+0x19>
        serial_putc_sub(c);
  101355:	8b 45 08             	mov    0x8(%ebp),%eax
  101358:	89 04 24             	mov    %eax,(%esp)
  10135b:	e8 91 ff ff ff       	call   1012f1 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  101360:	eb 24                	jmp    101386 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
  101362:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101369:	e8 83 ff ff ff       	call   1012f1 <serial_putc_sub>
        serial_putc_sub(' ');
  10136e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  101375:	e8 77 ff ff ff       	call   1012f1 <serial_putc_sub>
        serial_putc_sub('\b');
  10137a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101381:	e8 6b ff ff ff       	call   1012f1 <serial_putc_sub>
    }
}
  101386:	90                   	nop
  101387:	c9                   	leave  
  101388:	c3                   	ret    

00101389 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  101389:	55                   	push   %ebp
  10138a:	89 e5                	mov    %esp,%ebp
  10138c:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  10138f:	eb 33                	jmp    1013c4 <cons_intr+0x3b>
        if (c != 0) {
  101391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  101395:	74 2d                	je     1013c4 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  101397:	a1 64 b6 11 00       	mov    0x11b664,%eax
  10139c:	8d 50 01             	lea    0x1(%eax),%edx
  10139f:	89 15 64 b6 11 00    	mov    %edx,0x11b664
  1013a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013a8:	88 90 60 b4 11 00    	mov    %dl,0x11b460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013ae:	a1 64 b6 11 00       	mov    0x11b664,%eax
  1013b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  1013b8:	75 0a                	jne    1013c4 <cons_intr+0x3b>
                cons.wpos = 0;
  1013ba:	c7 05 64 b6 11 00 00 	movl   $0x0,0x11b664
  1013c1:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
  1013c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1013c7:	ff d0                	call   *%eax
  1013c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1013cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  1013d0:	75 bf                	jne    101391 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
  1013d2:	90                   	nop
  1013d3:	c9                   	leave  
  1013d4:	c3                   	ret    

001013d5 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  1013d5:	55                   	push   %ebp
  1013d6:	89 e5                	mov    %esp,%ebp
  1013d8:	83 ec 10             	sub    $0x10,%esp
  1013db:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1013e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1013e4:	89 c2                	mov    %eax,%edx
  1013e6:	ec                   	in     (%dx),%al
  1013e7:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
  1013ea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  1013ee:	0f b6 c0             	movzbl %al,%eax
  1013f1:	83 e0 01             	and    $0x1,%eax
  1013f4:	85 c0                	test   %eax,%eax
  1013f6:	75 07                	jne    1013ff <serial_proc_data+0x2a>
        return -1;
  1013f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1013fd:	eb 2a                	jmp    101429 <serial_proc_data+0x54>
  1013ff:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101405:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101409:	89 c2                	mov    %eax,%edx
  10140b:	ec                   	in     (%dx),%al
  10140c:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
  10140f:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101413:	0f b6 c0             	movzbl %al,%eax
  101416:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  101419:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10141d:	75 07                	jne    101426 <serial_proc_data+0x51>
        c = '\b';
  10141f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101426:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  101429:	c9                   	leave  
  10142a:	c3                   	ret    

0010142b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10142b:	55                   	push   %ebp
  10142c:	89 e5                	mov    %esp,%ebp
  10142e:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101431:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101436:	85 c0                	test   %eax,%eax
  101438:	74 0c                	je     101446 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10143a:	c7 04 24 d5 13 10 00 	movl   $0x1013d5,(%esp)
  101441:	e8 43 ff ff ff       	call   101389 <cons_intr>
    }
}
  101446:	90                   	nop
  101447:	c9                   	leave  
  101448:	c3                   	ret    

00101449 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  101449:	55                   	push   %ebp
  10144a:	89 e5                	mov    %esp,%ebp
  10144c:	83 ec 28             	sub    $0x28,%esp
  10144f:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101455:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101458:	89 c2                	mov    %eax,%edx
  10145a:	ec                   	in     (%dx),%al
  10145b:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  10145e:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  101462:	0f b6 c0             	movzbl %al,%eax
  101465:	83 e0 01             	and    $0x1,%eax
  101468:	85 c0                	test   %eax,%eax
  10146a:	75 0a                	jne    101476 <kbd_proc_data+0x2d>
        return -1;
  10146c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  101471:	e9 56 01 00 00       	jmp    1015cc <kbd_proc_data+0x183>
  101476:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10147f:	89 c2                	mov    %eax,%edx
  101481:	ec                   	in     (%dx),%al
  101482:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
  101485:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
  101489:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  10148c:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  101490:	75 17                	jne    1014a9 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  101492:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101497:	83 c8 40             	or     $0x40,%eax
  10149a:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  10149f:	b8 00 00 00 00       	mov    $0x0,%eax
  1014a4:	e9 23 01 00 00       	jmp    1015cc <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014ad:	84 c0                	test   %al,%al
  1014af:	79 45                	jns    1014f6 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  1014b1:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014b6:	83 e0 40             	and    $0x40,%eax
  1014b9:	85 c0                	test   %eax,%eax
  1014bb:	75 08                	jne    1014c5 <kbd_proc_data+0x7c>
  1014bd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c1:	24 7f                	and    $0x7f,%al
  1014c3:	eb 04                	jmp    1014c9 <kbd_proc_data+0x80>
  1014c5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014c9:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  1014cc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1014d0:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  1014d7:	0c 40                	or     $0x40,%al
  1014d9:	0f b6 c0             	movzbl %al,%eax
  1014dc:	f7 d0                	not    %eax
  1014de:	89 c2                	mov    %eax,%edx
  1014e0:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014e5:	21 d0                	and    %edx,%eax
  1014e7:	a3 68 b6 11 00       	mov    %eax,0x11b668
        return 0;
  1014ec:	b8 00 00 00 00       	mov    $0x0,%eax
  1014f1:	e9 d6 00 00 00       	jmp    1015cc <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  1014f6:	a1 68 b6 11 00       	mov    0x11b668,%eax
  1014fb:	83 e0 40             	and    $0x40,%eax
  1014fe:	85 c0                	test   %eax,%eax
  101500:	74 11                	je     101513 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101502:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  101506:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10150b:	83 e0 bf             	and    $0xffffffbf,%eax
  10150e:	a3 68 b6 11 00       	mov    %eax,0x11b668
    }

    shift |= shiftcode[data];
  101513:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101517:	0f b6 80 40 80 11 00 	movzbl 0x118040(%eax),%eax
  10151e:	0f b6 d0             	movzbl %al,%edx
  101521:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101526:	09 d0                	or     %edx,%eax
  101528:	a3 68 b6 11 00       	mov    %eax,0x11b668
    shift ^= togglecode[data];
  10152d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101531:	0f b6 80 40 81 11 00 	movzbl 0x118140(%eax),%eax
  101538:	0f b6 d0             	movzbl %al,%edx
  10153b:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101540:	31 d0                	xor    %edx,%eax
  101542:	a3 68 b6 11 00       	mov    %eax,0x11b668

    c = charcode[shift & (CTL | SHIFT)][data];
  101547:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10154c:	83 e0 03             	and    $0x3,%eax
  10154f:	8b 14 85 40 85 11 00 	mov    0x118540(,%eax,4),%edx
  101556:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10155a:	01 d0                	add    %edx,%eax
  10155c:	0f b6 00             	movzbl (%eax),%eax
  10155f:	0f b6 c0             	movzbl %al,%eax
  101562:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  101565:	a1 68 b6 11 00       	mov    0x11b668,%eax
  10156a:	83 e0 08             	and    $0x8,%eax
  10156d:	85 c0                	test   %eax,%eax
  10156f:	74 22                	je     101593 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  101571:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  101575:	7e 0c                	jle    101583 <kbd_proc_data+0x13a>
  101577:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  10157b:	7f 06                	jg     101583 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  10157d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  101581:	eb 10                	jmp    101593 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  101583:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  101587:	7e 0a                	jle    101593 <kbd_proc_data+0x14a>
  101589:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  10158d:	7f 04                	jg     101593 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  10158f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  101593:	a1 68 b6 11 00       	mov    0x11b668,%eax
  101598:	f7 d0                	not    %eax
  10159a:	83 e0 06             	and    $0x6,%eax
  10159d:	85 c0                	test   %eax,%eax
  10159f:	75 28                	jne    1015c9 <kbd_proc_data+0x180>
  1015a1:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015a8:	75 1f                	jne    1015c9 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  1015aa:	c7 04 24 c1 67 10 00 	movl   $0x1067c1,(%esp)
  1015b1:	e8 e7 ec ff ff       	call   10029d <cprintf>
  1015b6:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
  1015bc:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1015c0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1015c4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1015c8:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  1015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1015cc:	c9                   	leave  
  1015cd:	c3                   	ret    

001015ce <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  1015ce:	55                   	push   %ebp
  1015cf:	89 e5                	mov    %esp,%ebp
  1015d1:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  1015d4:	c7 04 24 49 14 10 00 	movl   $0x101449,(%esp)
  1015db:	e8 a9 fd ff ff       	call   101389 <cons_intr>
}
  1015e0:	90                   	nop
  1015e1:	c9                   	leave  
  1015e2:	c3                   	ret    

001015e3 <kbd_init>:

static void
kbd_init(void) {
  1015e3:	55                   	push   %ebp
  1015e4:	89 e5                	mov    %esp,%ebp
  1015e6:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  1015e9:	e8 e0 ff ff ff       	call   1015ce <kbd_intr>
    pic_enable(IRQ_KBD);
  1015ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1015f5:	e8 34 01 00 00       	call   10172e <pic_enable>
}
  1015fa:	90                   	nop
  1015fb:	c9                   	leave  
  1015fc:	c3                   	ret    

001015fd <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  1015fd:	55                   	push   %ebp
  1015fe:	89 e5                	mov    %esp,%ebp
  101600:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  101603:	e8 90 f8 ff ff       	call   100e98 <cga_init>
    serial_init();
  101608:	e8 6d f9 ff ff       	call   100f7a <serial_init>
    kbd_init();
  10160d:	e8 d1 ff ff ff       	call   1015e3 <kbd_init>
    if (!serial_exists) {
  101612:	a1 48 b4 11 00       	mov    0x11b448,%eax
  101617:	85 c0                	test   %eax,%eax
  101619:	75 0c                	jne    101627 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  10161b:	c7 04 24 cd 67 10 00 	movl   $0x1067cd,(%esp)
  101622:	e8 76 ec ff ff       	call   10029d <cprintf>
    }
}
  101627:	90                   	nop
  101628:	c9                   	leave  
  101629:	c3                   	ret    

0010162a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  10162a:	55                   	push   %ebp
  10162b:	89 e5                	mov    %esp,%ebp
  10162d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  101630:	e8 de f7 ff ff       	call   100e13 <__intr_save>
  101635:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101638:	8b 45 08             	mov    0x8(%ebp),%eax
  10163b:	89 04 24             	mov    %eax,(%esp)
  10163e:	e8 8d fa ff ff       	call   1010d0 <lpt_putc>
        cga_putc(c);
  101643:	8b 45 08             	mov    0x8(%ebp),%eax
  101646:	89 04 24             	mov    %eax,(%esp)
  101649:	e8 c2 fa ff ff       	call   101110 <cga_putc>
        serial_putc(c);
  10164e:	8b 45 08             	mov    0x8(%ebp),%eax
  101651:	89 04 24             	mov    %eax,(%esp)
  101654:	e8 f0 fc ff ff       	call   101349 <serial_putc>
    }
    local_intr_restore(intr_flag);
  101659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10165c:	89 04 24             	mov    %eax,(%esp)
  10165f:	e8 d9 f7 ff ff       	call   100e3d <__intr_restore>
}
  101664:	90                   	nop
  101665:	c9                   	leave  
  101666:	c3                   	ret    

00101667 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  101667:	55                   	push   %ebp
  101668:	89 e5                	mov    %esp,%ebp
  10166a:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  10166d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  101674:	e8 9a f7 ff ff       	call   100e13 <__intr_save>
  101679:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  10167c:	e8 aa fd ff ff       	call   10142b <serial_intr>
        kbd_intr();
  101681:	e8 48 ff ff ff       	call   1015ce <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  101686:	8b 15 60 b6 11 00    	mov    0x11b660,%edx
  10168c:	a1 64 b6 11 00       	mov    0x11b664,%eax
  101691:	39 c2                	cmp    %eax,%edx
  101693:	74 31                	je     1016c6 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  101695:	a1 60 b6 11 00       	mov    0x11b660,%eax
  10169a:	8d 50 01             	lea    0x1(%eax),%edx
  10169d:	89 15 60 b6 11 00    	mov    %edx,0x11b660
  1016a3:	0f b6 80 60 b4 11 00 	movzbl 0x11b460(%eax),%eax
  1016aa:	0f b6 c0             	movzbl %al,%eax
  1016ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  1016b0:	a1 60 b6 11 00       	mov    0x11b660,%eax
  1016b5:	3d 00 02 00 00       	cmp    $0x200,%eax
  1016ba:	75 0a                	jne    1016c6 <cons_getc+0x5f>
                cons.rpos = 0;
  1016bc:	c7 05 60 b6 11 00 00 	movl   $0x0,0x11b660
  1016c3:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  1016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1016c9:	89 04 24             	mov    %eax,(%esp)
  1016cc:	e8 6c f7 ff ff       	call   100e3d <__intr_restore>
    return c;
  1016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1016d4:	c9                   	leave  
  1016d5:	c3                   	ret    

001016d6 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  1016d6:	55                   	push   %ebp
  1016d7:	89 e5                	mov    %esp,%ebp
  1016d9:	83 ec 14             	sub    $0x14,%esp
  1016dc:	8b 45 08             	mov    0x8(%ebp),%eax
  1016df:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  1016e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016e6:	66 a3 50 85 11 00    	mov    %ax,0x118550
    if (did_init) {
  1016ec:	a1 6c b6 11 00       	mov    0x11b66c,%eax
  1016f1:	85 c0                	test   %eax,%eax
  1016f3:	74 36                	je     10172b <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
  1016f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1016f8:	0f b6 c0             	movzbl %al,%eax
  1016fb:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101701:	88 45 fa             	mov    %al,-0x6(%ebp)
  101704:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
  101708:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10170c:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
  10170d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101711:	c1 e8 08             	shr    $0x8,%eax
  101714:	0f b7 c0             	movzwl %ax,%eax
  101717:	0f b6 c0             	movzbl %al,%eax
  10171a:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  101720:	88 45 fb             	mov    %al,-0x5(%ebp)
  101723:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
  101727:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10172a:	ee                   	out    %al,(%dx)
    }
}
  10172b:	90                   	nop
  10172c:	c9                   	leave  
  10172d:	c3                   	ret    

0010172e <pic_enable>:

void
pic_enable(unsigned int irq) {
  10172e:	55                   	push   %ebp
  10172f:	89 e5                	mov    %esp,%ebp
  101731:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  101734:	8b 45 08             	mov    0x8(%ebp),%eax
  101737:	ba 01 00 00 00       	mov    $0x1,%edx
  10173c:	88 c1                	mov    %al,%cl
  10173e:	d3 e2                	shl    %cl,%edx
  101740:	89 d0                	mov    %edx,%eax
  101742:	98                   	cwtl   
  101743:	f7 d0                	not    %eax
  101745:	0f bf d0             	movswl %ax,%edx
  101748:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10174f:	98                   	cwtl   
  101750:	21 d0                	and    %edx,%eax
  101752:	98                   	cwtl   
  101753:	0f b7 c0             	movzwl %ax,%eax
  101756:	89 04 24             	mov    %eax,(%esp)
  101759:	e8 78 ff ff ff       	call   1016d6 <pic_setmask>
}
  10175e:	90                   	nop
  10175f:	c9                   	leave  
  101760:	c3                   	ret    

00101761 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  101761:	55                   	push   %ebp
  101762:	89 e5                	mov    %esp,%ebp
  101764:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
  101767:	c7 05 6c b6 11 00 01 	movl   $0x1,0x11b66c
  10176e:	00 00 00 
  101771:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
  101777:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
  10177b:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
  10177f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101783:	ee                   	out    %al,(%dx)
  101784:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
  10178a:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
  10178e:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
  101792:	8b 55 fc             	mov    -0x4(%ebp),%edx
  101795:	ee                   	out    %al,(%dx)
  101796:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
  10179c:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
  1017a0:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
  1017a4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1017a8:	ee                   	out    %al,(%dx)
  1017a9:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
  1017af:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
  1017b3:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  1017b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
  1017ba:	ee                   	out    %al,(%dx)
  1017bb:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
  1017c1:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
  1017c5:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
  1017c9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1017cd:	ee                   	out    %al,(%dx)
  1017ce:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
  1017d4:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
  1017d8:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
  1017dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1017df:	ee                   	out    %al,(%dx)
  1017e0:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
  1017e6:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
  1017ea:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
  1017ee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1017f2:	ee                   	out    %al,(%dx)
  1017f3:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
  1017f9:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
  1017fd:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  101801:	8b 55 f0             	mov    -0x10(%ebp),%edx
  101804:	ee                   	out    %al,(%dx)
  101805:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  10180b:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
  10180f:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
  101813:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101817:	ee                   	out    %al,(%dx)
  101818:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
  10181e:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
  101822:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
  101826:	8b 55 ec             	mov    -0x14(%ebp),%edx
  101829:	ee                   	out    %al,(%dx)
  10182a:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
  101830:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
  101834:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
  101838:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10183c:	ee                   	out    %al,(%dx)
  10183d:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
  101843:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
  101847:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  10184b:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10184e:	ee                   	out    %al,(%dx)
  10184f:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
  101855:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
  101859:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
  10185d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101861:	ee                   	out    %al,(%dx)
  101862:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
  101868:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
  10186c:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
  101870:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  101873:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101874:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  10187b:	3d ff ff 00 00       	cmp    $0xffff,%eax
  101880:	74 0f                	je     101891 <pic_init+0x130>
        pic_setmask(irq_mask);
  101882:	0f b7 05 50 85 11 00 	movzwl 0x118550,%eax
  101889:	89 04 24             	mov    %eax,(%esp)
  10188c:	e8 45 fe ff ff       	call   1016d6 <pic_setmask>
    }
}
  101891:	90                   	nop
  101892:	c9                   	leave  
  101893:	c3                   	ret    

00101894 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101894:	55                   	push   %ebp
  101895:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
  101897:	fb                   	sti    
    sti();
}
  101898:	90                   	nop
  101899:	5d                   	pop    %ebp
  10189a:	c3                   	ret    

0010189b <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  10189b:	55                   	push   %ebp
  10189c:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
  10189e:	fa                   	cli    
    cli();
}
  10189f:	90                   	nop
  1018a0:	5d                   	pop    %ebp
  1018a1:	c3                   	ret    

001018a2 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
  1018a2:	55                   	push   %ebp
  1018a3:	89 e5                	mov    %esp,%ebp
  1018a5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  1018a8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  1018af:	00 
  1018b0:	c7 04 24 00 68 10 00 	movl   $0x106800,(%esp)
  1018b7:	e8 e1 e9 ff ff       	call   10029d <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
  1018bc:	90                   	nop
  1018bd:	c9                   	leave  
  1018be:	c3                   	ret    

001018bf <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  1018bf:	55                   	push   %ebp
  1018c0:	89 e5                	mov    %esp,%ebp
  1018c2:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
  1018c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  1018cc:	e9 67 02 00 00       	jmp    101b38 <idt_init+0x279>
        if(i == 128){
  1018d1:	81 7d fc 80 00 00 00 	cmpl   $0x80,-0x4(%ebp)
  1018d8:	0f 85 c6 00 00 00    	jne    1019a4 <idt_init+0xe5>
            SETGATE(idt[i],0,8,__vectors[i],3);
  1018de:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018e1:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  1018e8:	0f b7 d0             	movzwl %ax,%edx
  1018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018ee:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  1018f5:	00 
  1018f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1018f9:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  101900:	00 08 00 
  101903:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101906:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  10190d:	00 
  10190e:	80 e2 e0             	and    $0xe0,%dl
  101911:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101918:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10191b:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  101922:	00 
  101923:	80 e2 1f             	and    $0x1f,%dl
  101926:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  10192d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101930:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101937:	00 
  101938:	80 e2 f0             	and    $0xf0,%dl
  10193b:	80 ca 0e             	or     $0xe,%dl
  10193e:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101945:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101948:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  10194f:	00 
  101950:	80 e2 ef             	and    $0xef,%dl
  101953:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10195a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10195d:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101964:	00 
  101965:	80 ca 60             	or     $0x60,%dl
  101968:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  10196f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101972:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101979:	00 
  10197a:	80 ca 80             	or     $0x80,%dl
  10197d:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101987:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  10198e:	c1 e8 10             	shr    $0x10,%eax
  101991:	0f b7 d0             	movzwl %ax,%edx
  101994:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101997:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  10199e:	00 
  10199f:	e9 91 01 00 00       	jmp    101b35 <idt_init+0x276>
        }
        else if(i == 121){
  1019a4:	83 7d fc 79          	cmpl   $0x79,-0x4(%ebp)
  1019a8:	0f 85 c6 00 00 00    	jne    101a74 <idt_init+0x1b5>
            SETGATE(idt[i],0,8,__vectors[i],3);
  1019ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b1:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  1019b8:	0f b7 d0             	movzwl %ax,%edx
  1019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019be:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  1019c5:	00 
  1019c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019c9:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  1019d0:	00 08 00 
  1019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019d6:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  1019dd:	00 
  1019de:	80 e2 e0             	and    $0xe0,%dl
  1019e1:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019eb:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  1019f2:	00 
  1019f3:	80 e2 1f             	and    $0x1f,%dl
  1019f6:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  1019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a00:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101a07:	00 
  101a08:	80 e2 f0             	and    $0xf0,%dl
  101a0b:	80 ca 0e             	or     $0xe,%dl
  101a0e:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a18:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101a1f:	00 
  101a20:	80 e2 ef             	and    $0xef,%dl
  101a23:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a2d:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101a34:	00 
  101a35:	80 ca 60             	or     $0x60,%dl
  101a38:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a42:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101a49:	00 
  101a4a:	80 ca 80             	or     $0x80,%dl
  101a4d:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a57:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101a5e:	c1 e8 10             	shr    $0x10,%eax
  101a61:	0f b7 d0             	movzwl %ax,%edx
  101a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a67:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  101a6e:	00 
  101a6f:	e9 c1 00 00 00       	jmp    101b35 <idt_init+0x276>
        }
        else{
            SETGATE(idt[i],0,8,__vectors[i],0);
  101a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a77:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101a7e:	0f b7 d0             	movzwl %ax,%edx
  101a81:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a84:	66 89 14 c5 80 b6 11 	mov    %dx,0x11b680(,%eax,8)
  101a8b:	00 
  101a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a8f:	66 c7 04 c5 82 b6 11 	movw   $0x8,0x11b682(,%eax,8)
  101a96:	00 08 00 
  101a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a9c:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  101aa3:	00 
  101aa4:	80 e2 e0             	and    $0xe0,%dl
  101aa7:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101aae:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101ab1:	0f b6 14 c5 84 b6 11 	movzbl 0x11b684(,%eax,8),%edx
  101ab8:	00 
  101ab9:	80 e2 1f             	and    $0x1f,%dl
  101abc:	88 14 c5 84 b6 11 00 	mov    %dl,0x11b684(,%eax,8)
  101ac3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101ac6:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101acd:	00 
  101ace:	80 e2 f0             	and    $0xf0,%dl
  101ad1:	80 ca 0e             	or     $0xe,%dl
  101ad4:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101adb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101ade:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101ae5:	00 
  101ae6:	80 e2 ef             	and    $0xef,%dl
  101ae9:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101af0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101af3:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101afa:	00 
  101afb:	80 e2 9f             	and    $0x9f,%dl
  101afe:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101b08:	0f b6 14 c5 85 b6 11 	movzbl 0x11b685(,%eax,8),%edx
  101b0f:	00 
  101b10:	80 ca 80             	or     $0x80,%dl
  101b13:	88 14 c5 85 b6 11 00 	mov    %dl,0x11b685(,%eax,8)
  101b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101b1d:	8b 04 85 e0 85 11 00 	mov    0x1185e0(,%eax,4),%eax
  101b24:	c1 e8 10             	shr    $0x10,%eax
  101b27:	0f b7 d0             	movzwl %ax,%edx
  101b2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101b2d:	66 89 14 c5 86 b6 11 	mov    %dx,0x11b686(,%eax,8)
  101b34:	00 
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
  101b35:	ff 45 fc             	incl   -0x4(%ebp)
  101b38:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
  101b3f:	0f 8e 8c fd ff ff    	jle    1018d1 <idt_init+0x12>
  101b45:	c7 45 f8 60 85 11 00 	movl   $0x118560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101b4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101b4f:	0f 01 18             	lidtl  (%eax)
        //          for software to invoke this interrupt/trap gate explicitly
        //          using an int instruction.
    }

    lidt(&idt_pd);
}
  101b52:	90                   	nop
  101b53:	c9                   	leave  
  101b54:	c3                   	ret    

00101b55 <trapname>:

static const char *
trapname(int trapno) {
  101b55:	55                   	push   %ebp
  101b56:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101b58:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5b:	83 f8 13             	cmp    $0x13,%eax
  101b5e:	77 0c                	ja     101b6c <trapname+0x17>
        return excnames[trapno];
  101b60:	8b 45 08             	mov    0x8(%ebp),%eax
  101b63:	8b 04 85 60 6b 10 00 	mov    0x106b60(,%eax,4),%eax
  101b6a:	eb 18                	jmp    101b84 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101b6c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101b70:	7e 0d                	jle    101b7f <trapname+0x2a>
  101b72:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101b76:	7f 07                	jg     101b7f <trapname+0x2a>
        return "Hardware Interrupt";
  101b78:	b8 0a 68 10 00       	mov    $0x10680a,%eax
  101b7d:	eb 05                	jmp    101b84 <trapname+0x2f>
    }
    return "(unknown trap)";
  101b7f:	b8 1d 68 10 00       	mov    $0x10681d,%eax
}
  101b84:	5d                   	pop    %ebp
  101b85:	c3                   	ret    

00101b86 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b86:	55                   	push   %ebp
  101b87:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b89:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b90:	83 f8 08             	cmp    $0x8,%eax
  101b93:	0f 94 c0             	sete   %al
  101b96:	0f b6 c0             	movzbl %al,%eax
}
  101b99:	5d                   	pop    %ebp
  101b9a:	c3                   	ret    

00101b9b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b9b:	55                   	push   %ebp
  101b9c:	89 e5                	mov    %esp,%ebp
  101b9e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ba8:	c7 04 24 5e 68 10 00 	movl   $0x10685e,(%esp)
  101baf:	e8 e9 e6 ff ff       	call   10029d <cprintf>
    print_regs(&tf->tf_regs);
  101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
  101bb7:	89 04 24             	mov    %eax,(%esp)
  101bba:	e8 91 01 00 00       	call   101d50 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
  101bc2:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bca:	c7 04 24 6f 68 10 00 	movl   $0x10686f,(%esp)
  101bd1:	e8 c7 e6 ff ff       	call   10029d <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  101bd9:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be1:	c7 04 24 82 68 10 00 	movl   $0x106882,(%esp)
  101be8:	e8 b0 e6 ff ff       	call   10029d <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101bed:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf0:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bf8:	c7 04 24 95 68 10 00 	movl   $0x106895,(%esp)
  101bff:	e8 99 e6 ff ff       	call   10029d <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101c04:	8b 45 08             	mov    0x8(%ebp),%eax
  101c07:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c0f:	c7 04 24 a8 68 10 00 	movl   $0x1068a8,(%esp)
  101c16:	e8 82 e6 ff ff       	call   10029d <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c1e:	8b 40 30             	mov    0x30(%eax),%eax
  101c21:	89 04 24             	mov    %eax,(%esp)
  101c24:	e8 2c ff ff ff       	call   101b55 <trapname>
  101c29:	89 c2                	mov    %eax,%edx
  101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c2e:	8b 40 30             	mov    0x30(%eax),%eax
  101c31:	89 54 24 08          	mov    %edx,0x8(%esp)
  101c35:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c39:	c7 04 24 bb 68 10 00 	movl   $0x1068bb,(%esp)
  101c40:	e8 58 e6 ff ff       	call   10029d <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101c45:	8b 45 08             	mov    0x8(%ebp),%eax
  101c48:	8b 40 34             	mov    0x34(%eax),%eax
  101c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c4f:	c7 04 24 cd 68 10 00 	movl   $0x1068cd,(%esp)
  101c56:	e8 42 e6 ff ff       	call   10029d <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  101c5e:	8b 40 38             	mov    0x38(%eax),%eax
  101c61:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c65:	c7 04 24 dc 68 10 00 	movl   $0x1068dc,(%esp)
  101c6c:	e8 2c e6 ff ff       	call   10029d <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101c71:	8b 45 08             	mov    0x8(%ebp),%eax
  101c74:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101c78:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c7c:	c7 04 24 eb 68 10 00 	movl   $0x1068eb,(%esp)
  101c83:	e8 15 e6 ff ff       	call   10029d <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c88:	8b 45 08             	mov    0x8(%ebp),%eax
  101c8b:	8b 40 40             	mov    0x40(%eax),%eax
  101c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c92:	c7 04 24 fe 68 10 00 	movl   $0x1068fe,(%esp)
  101c99:	e8 ff e5 ff ff       	call   10029d <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101ca5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101cac:	eb 3d                	jmp    101ceb <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101cae:	8b 45 08             	mov    0x8(%ebp),%eax
  101cb1:	8b 50 40             	mov    0x40(%eax),%edx
  101cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101cb7:	21 d0                	and    %edx,%eax
  101cb9:	85 c0                	test   %eax,%eax
  101cbb:	74 28                	je     101ce5 <print_trapframe+0x14a>
  101cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cc0:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101cc7:	85 c0                	test   %eax,%eax
  101cc9:	74 1a                	je     101ce5 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
  101ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cce:	8b 04 85 80 85 11 00 	mov    0x118580(,%eax,4),%eax
  101cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cd9:	c7 04 24 0d 69 10 00 	movl   $0x10690d,(%esp)
  101ce0:	e8 b8 e5 ff ff       	call   10029d <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101ce5:	ff 45 f4             	incl   -0xc(%ebp)
  101ce8:	d1 65 f0             	shll   -0x10(%ebp)
  101ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101cee:	83 f8 17             	cmp    $0x17,%eax
  101cf1:	76 bb                	jbe    101cae <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf6:	8b 40 40             	mov    0x40(%eax),%eax
  101cf9:	25 00 30 00 00       	and    $0x3000,%eax
  101cfe:	c1 e8 0c             	shr    $0xc,%eax
  101d01:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d05:	c7 04 24 11 69 10 00 	movl   $0x106911,(%esp)
  101d0c:	e8 8c e5 ff ff       	call   10029d <cprintf>

    if (!trap_in_kernel(tf)) {
  101d11:	8b 45 08             	mov    0x8(%ebp),%eax
  101d14:	89 04 24             	mov    %eax,(%esp)
  101d17:	e8 6a fe ff ff       	call   101b86 <trap_in_kernel>
  101d1c:	85 c0                	test   %eax,%eax
  101d1e:	75 2d                	jne    101d4d <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101d20:	8b 45 08             	mov    0x8(%ebp),%eax
  101d23:	8b 40 44             	mov    0x44(%eax),%eax
  101d26:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d2a:	c7 04 24 1a 69 10 00 	movl   $0x10691a,(%esp)
  101d31:	e8 67 e5 ff ff       	call   10029d <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101d36:	8b 45 08             	mov    0x8(%ebp),%eax
  101d39:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d41:	c7 04 24 29 69 10 00 	movl   $0x106929,(%esp)
  101d48:	e8 50 e5 ff ff       	call   10029d <cprintf>
    }
}
  101d4d:	90                   	nop
  101d4e:	c9                   	leave  
  101d4f:	c3                   	ret    

00101d50 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101d50:	55                   	push   %ebp
  101d51:	89 e5                	mov    %esp,%ebp
  101d53:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101d56:	8b 45 08             	mov    0x8(%ebp),%eax
  101d59:	8b 00                	mov    (%eax),%eax
  101d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d5f:	c7 04 24 3c 69 10 00 	movl   $0x10693c,(%esp)
  101d66:	e8 32 e5 ff ff       	call   10029d <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d6e:	8b 40 04             	mov    0x4(%eax),%eax
  101d71:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d75:	c7 04 24 4b 69 10 00 	movl   $0x10694b,(%esp)
  101d7c:	e8 1c e5 ff ff       	call   10029d <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d81:	8b 45 08             	mov    0x8(%ebp),%eax
  101d84:	8b 40 08             	mov    0x8(%eax),%eax
  101d87:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d8b:	c7 04 24 5a 69 10 00 	movl   $0x10695a,(%esp)
  101d92:	e8 06 e5 ff ff       	call   10029d <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d97:	8b 45 08             	mov    0x8(%ebp),%eax
  101d9a:	8b 40 0c             	mov    0xc(%eax),%eax
  101d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101da1:	c7 04 24 69 69 10 00 	movl   $0x106969,(%esp)
  101da8:	e8 f0 e4 ff ff       	call   10029d <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101dad:	8b 45 08             	mov    0x8(%ebp),%eax
  101db0:	8b 40 10             	mov    0x10(%eax),%eax
  101db3:	89 44 24 04          	mov    %eax,0x4(%esp)
  101db7:	c7 04 24 78 69 10 00 	movl   $0x106978,(%esp)
  101dbe:	e8 da e4 ff ff       	call   10029d <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
  101dc6:	8b 40 14             	mov    0x14(%eax),%eax
  101dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  101dcd:	c7 04 24 87 69 10 00 	movl   $0x106987,(%esp)
  101dd4:	e8 c4 e4 ff ff       	call   10029d <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  101ddc:	8b 40 18             	mov    0x18(%eax),%eax
  101ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101de3:	c7 04 24 96 69 10 00 	movl   $0x106996,(%esp)
  101dea:	e8 ae e4 ff ff       	call   10029d <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101def:	8b 45 08             	mov    0x8(%ebp),%eax
  101df2:	8b 40 1c             	mov    0x1c(%eax),%eax
  101df5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101df9:	c7 04 24 a5 69 10 00 	movl   $0x1069a5,(%esp)
  101e00:	e8 98 e4 ff ff       	call   10029d <cprintf>
}
  101e05:	90                   	nop
  101e06:	c9                   	leave  
  101e07:	c3                   	ret    

00101e08 <l_switch_to_user>:
static uint32_t i_in_td, tf_end_in_td;
struct trapframe switchk2u, *switchu2k;
extern void __move_down_stack2(uint32_t end, uint32_t tf);
extern struct trapframe* __move_up_stack2(uint32_t end, uint32_t tf, uint32_t esp);

static void l_switch_to_user() {
  101e08:	55                   	push   %ebp
  101e09:	89 e5                	mov    %esp,%ebp
    asm volatile (
  101e0b:	83 ec 08             	sub    $0x8,%esp
  101e0e:	cd 78                	int    $0x78
  101e10:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        : 
        : "i"(T_SWITCH_TOU)
    );
}
  101e12:	90                   	nop
  101e13:	5d                   	pop    %ebp
  101e14:	c3                   	ret    

00101e15 <l_switch_to_kernel>:

static void l_switch_to_kernel(void) {
  101e15:	55                   	push   %ebp
  101e16:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
        asm volatile (
  101e18:	cd 79                	int    $0x79
  101e1a:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp \n"
        : 
        : "i"(T_SWITCH_TOK)
        );
}
  101e1c:	90                   	nop
  101e1d:	5d                   	pop    %ebp
  101e1e:	c3                   	ret    

00101e1f <trap_dispatch>:
}


/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101e1f:	55                   	push   %ebp
  101e20:	89 e5                	mov    %esp,%ebp
  101e22:	56                   	push   %esi
  101e23:	53                   	push   %ebx
  101e24:	83 ec 20             	sub    $0x20,%esp
    char c;

    switch (tf->tf_trapno) {
  101e27:	8b 45 08             	mov    0x8(%ebp),%eax
  101e2a:	8b 40 30             	mov    0x30(%eax),%eax
  101e2d:	83 f8 2f             	cmp    $0x2f,%eax
  101e30:	77 1d                	ja     101e4f <trap_dispatch+0x30>
  101e32:	83 f8 2e             	cmp    $0x2e,%eax
  101e35:	0f 83 2a 03 00 00    	jae    102165 <trap_dispatch+0x346>
  101e3b:	83 f8 21             	cmp    $0x21,%eax
  101e3e:	74 7c                	je     101ebc <trap_dispatch+0x9d>
  101e40:	83 f8 24             	cmp    $0x24,%eax
  101e43:	74 4e                	je     101e93 <trap_dispatch+0x74>
  101e45:	83 f8 20             	cmp    $0x20,%eax
  101e48:	74 1c                	je     101e66 <trap_dispatch+0x47>
  101e4a:	e9 e1 02 00 00       	jmp    102130 <trap_dispatch+0x311>
  101e4f:	83 f8 78             	cmp    $0x78,%eax
  101e52:	0f 84 d0 01 00 00    	je     102028 <trap_dispatch+0x209>
  101e58:	83 f8 79             	cmp    $0x79,%eax
  101e5b:	0f 84 4b 02 00 00    	je     1020ac <trap_dispatch+0x28d>
  101e61:	e9 ca 02 00 00       	jmp    102130 <trap_dispatch+0x311>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        count++;
  101e66:	a1 80 be 11 00       	mov    0x11be80,%eax
  101e6b:	40                   	inc    %eax
  101e6c:	a3 80 be 11 00       	mov    %eax,0x11be80
        if(count == TICK_NUM){
  101e71:	a1 80 be 11 00       	mov    0x11be80,%eax
  101e76:	83 f8 64             	cmp    $0x64,%eax
  101e79:	0f 85 e9 02 00 00    	jne    102168 <trap_dispatch+0x349>
            count = 0;
  101e7f:	c7 05 80 be 11 00 00 	movl   $0x0,0x11be80
  101e86:	00 00 00 
            print_ticks();
  101e89:	e8 14 fa ff ff       	call   1018a2 <print_ticks>
        }
        break;
  101e8e:	e9 d5 02 00 00       	jmp    102168 <trap_dispatch+0x349>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e93:	e8 cf f7 ff ff       	call   101667 <cons_getc>
  101e98:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e9b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e9f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101ea3:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
  101eab:	c7 04 24 b4 69 10 00 	movl   $0x1069b4,(%esp)
  101eb2:	e8 e6 e3 ff ff       	call   10029d <cprintf>
        break;
  101eb7:	e9 b3 02 00 00       	jmp    10216f <trap_dispatch+0x350>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101ebc:	e8 a6 f7 ff ff       	call   101667 <cons_getc>
  101ec1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101ec4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101ec8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101ecc:	89 54 24 08          	mov    %edx,0x8(%esp)
  101ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ed4:	c7 04 24 c6 69 10 00 	movl   $0x1069c6,(%esp)
  101edb:	e8 bd e3 ff ff       	call   10029d <cprintf>
        if (c == 0x30) { // switch to kernel mode
  101ee0:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
  101ee4:	0f 85 82 00 00 00    	jne    101f6c <trap_dispatch+0x14d>
            saved_tf = __move_up_stack2((uint32_t)(tf) + sizeof(struct trapframe) - 8, (uint32_t) tf, tf->tf_esp);
  101eea:	8b 45 08             	mov    0x8(%ebp),%eax
  101eed:	8b 50 44             	mov    0x44(%eax),%edx
  101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  101ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  101ef6:	83 c1 44             	add    $0x44,%ecx
  101ef9:	89 54 24 08          	mov    %edx,0x8(%esp)
  101efd:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f01:	89 0c 24             	mov    %ecx,(%esp)
  101f04:	e8 5d 0d 00 00       	call   102c66 <__move_up_stack2>
  101f09:	a3 84 be 11 00       	mov    %eax,0x11be84
            saved_tf->tf_cs = KERNEL_CS;
  101f0e:	a1 84 be 11 00       	mov    0x11be84,%eax
  101f13:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_gs = KERNEL_DS;
  101f19:	8b 1d 84 be 11 00    	mov    0x11be84,%ebx
  101f1f:	a1 84 be 11 00       	mov    0x11be84,%eax
  101f24:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  101f2a:	8b 0d 84 be 11 00    	mov    0x11be84,%ecx
  101f30:	66 c7 41 20 10 00    	movw   $0x10,0x20(%ecx)
  101f36:	0f b7 49 20          	movzwl 0x20(%ecx),%ecx
  101f3a:	66 89 4a 24          	mov    %cx,0x24(%edx)
  101f3e:	0f b7 52 24          	movzwl 0x24(%edx),%edx
  101f42:	66 89 50 28          	mov    %dx,0x28(%eax)
  101f46:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101f4a:	66 89 43 2c          	mov    %ax,0x2c(%ebx)
            saved_tf->tf_trapno = 0x21;
  101f4e:	a1 84 be 11 00       	mov    0x11be84,%eax
  101f53:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
            asm volatile (
  101f5a:	b8 10 00 00 00       	mov    $0x10,%eax
  101f5f:	8e d0                	mov    %eax,%ss
                "movw %0, %%ss"
                :
                : "r"(KERNEL_DS)
                 );
            print_trapframe(tf);
  101f61:	8b 45 08             	mov    0x8(%ebp),%eax
  101f64:	89 04 24             	mov    %eax,(%esp)
  101f67:	e8 2f fc ff ff       	call   101b9b <print_trapframe>
        }

        if (c == 0x33) { // switch to user mode
  101f6c:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
  101f70:	0f 85 f5 01 00 00    	jne    10216b <trap_dispatch+0x34c>
            saved_tf = (struct trapname*) ((uint32_t)(tf) - 8);
  101f76:	8b 45 08             	mov    0x8(%ebp),%eax
  101f79:	83 e8 08             	sub    $0x8,%eax
  101f7c:	a3 84 be 11 00       	mov    %eax,0x11be84
    
            __move_down_stack2( (uint32_t)(tf) + sizeof(struct trapframe) - 8 , (uint32_t) tf );
  101f81:	8b 45 08             	mov    0x8(%ebp),%eax
  101f84:	8b 55 08             	mov    0x8(%ebp),%edx
  101f87:	83 c2 44             	add    $0x44,%edx
  101f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101f8e:	89 14 24             	mov    %edx,(%esp)
  101f91:	e8 89 0c 00 00       	call   102c1f <__move_down_stack2>

            saved_tf->tf_eflags |= FL_IOPL_MASK;
  101f96:	a1 84 be 11 00       	mov    0x11be84,%eax
  101f9b:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  101fa1:	8b 52 40             	mov    0x40(%edx),%edx
  101fa4:	81 ca 00 30 00 00    	or     $0x3000,%edx
  101faa:	89 50 40             	mov    %edx,0x40(%eax)
            saved_tf->tf_cs = USER_CS;
  101fad:	a1 84 be 11 00       	mov    0x11be84,%eax
  101fb2:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
  101fb8:	8b 35 84 be 11 00    	mov    0x11be84,%esi
  101fbe:	a1 84 be 11 00       	mov    0x11be84,%eax
  101fc3:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  101fc9:	8b 0d 84 be 11 00    	mov    0x11be84,%ecx
  101fcf:	8b 1d 84 be 11 00    	mov    0x11be84,%ebx
  101fd5:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
  101fdb:	0f b7 5b 20          	movzwl 0x20(%ebx),%ebx
  101fdf:	66 89 59 48          	mov    %bx,0x48(%ecx)
  101fe3:	0f b7 49 48          	movzwl 0x48(%ecx),%ecx
  101fe7:	66 89 4a 24          	mov    %cx,0x24(%edx)
  101feb:	0f b7 52 24          	movzwl 0x24(%edx),%edx
  101fef:	66 89 50 28          	mov    %dx,0x28(%eax)
  101ff3:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101ff7:	66 89 46 2c          	mov    %ax,0x2c(%esi)
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
  101ffb:	a1 84 be 11 00       	mov    0x11be84,%eax
  102000:	8b 15 84 be 11 00    	mov    0x11be84,%edx
  102006:	83 c2 4c             	add    $0x4c,%edx
  102009:	89 50 44             	mov    %edx,0x44(%eax)
            saved_tf->tf_trapno = 0x21;
  10200c:	a1 84 be 11 00       	mov    0x11be84,%eax
  102011:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
            print_trapframe(tf);
  102018:	8b 45 08             	mov    0x8(%ebp),%eax
  10201b:	89 04 24             	mov    %eax,(%esp)
  10201e:	e8 78 fb ff ff       	call   101b9b <print_trapframe>
        }
        break;
  102023:	e9 43 01 00 00       	jmp    10216b <trap_dispatch+0x34c>
  102028:	8b 45 08             	mov    0x8(%ebp),%eax
  10202b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        saved_tf->tf_trapno = 0x21;
    }
}

static inline __attribute__((always_inline)) void switch_to_user(struct trapframe *tf) {
    if (tf->tf_cs != USER_CS) {
  10202e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102031:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102035:	83 f8 1b             	cmp    $0x1b,%eax
  102038:	0f 84 30 01 00 00    	je     10216e <trap_dispatch+0x34f>
     
        tf->tf_eflags |= FL_IOPL_MASK;
  10203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102041:	8b 40 40             	mov    0x40(%eax),%eax
  102044:	0d 00 30 00 00       	or     $0x3000,%eax
  102049:	89 c2                	mov    %eax,%edx
  10204b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10204e:	89 50 40             	mov    %edx,0x40(%eax)
        tf->tf_cs = USER_CS;
  102051:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102054:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = USER_DS;
  10205a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10205d:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
  102063:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102066:	0f b7 50 24          	movzwl 0x24(%eax),%edx
  10206a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10206d:	66 89 50 48          	mov    %dx,0x48(%eax)
  102071:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102074:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  102078:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10207b:	66 89 50 20          	mov    %dx,0x20(%eax)
  10207f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102082:	0f b7 50 20          	movzwl 0x20(%eax),%edx
  102086:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102089:	66 89 50 28          	mov    %dx,0x28(%eax)
  10208d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102090:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  102094:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102097:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        saved_tf->tf_trapno = 0x21;
  10209b:	a1 84 be 11 00       	mov    0x11be84,%eax
  1020a0:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
        }
        break;
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
  1020a7:	e9 c2 00 00 00       	jmp    10216e <trap_dispatch+0x34f>
  1020ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1020af:	89 45 f0             	mov    %eax,-0x10(%ebp)
        : "i"(T_SWITCH_TOK)
        );
}

static inline __attribute__((always_inline)) void switch_to_kernel(struct trapframe *tf) {
    if (tf->tf_cs != KERNEL_CS) {
  1020b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  1020b9:	83 f8 08             	cmp    $0x8,%eax
  1020bc:	74 56                	je     102114 <trap_dispatch+0x2f5>
        tf->tf_cs = KERNEL_CS;
  1020be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020c1:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = KERNEL_DS;
  1020c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020ca:	66 c7 40 24 10 00    	movw   $0x10,0x24(%eax)
  1020d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020d3:	0f b7 50 24          	movzwl 0x24(%eax),%edx
  1020d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020da:	66 89 50 48          	mov    %dx,0x48(%eax)
  1020de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020e1:	0f b7 50 48          	movzwl 0x48(%eax),%edx
  1020e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020e8:	66 89 50 20          	mov    %dx,0x20(%eax)
  1020ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020ef:	0f b7 50 20          	movzwl 0x20(%eax),%edx
  1020f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020f6:	66 89 50 28          	mov    %dx,0x28(%eax)
  1020fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1020fd:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  102101:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102104:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        saved_tf->tf_trapno = 0x21;
  102108:	a1 84 be 11 00       	mov    0x11be84,%eax
  10210d:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
    case T_SWITCH_TOK:
        switch_to_kernel(tf);
        panic("T_SWITCH_** ??\n");
  102114:	c7 44 24 08 d5 69 10 	movl   $0x1069d5,0x8(%esp)
  10211b:	00 
  10211c:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  102123:	00 
  102124:	c7 04 24 e5 69 10 00 	movl   $0x1069e5,(%esp)
  10212b:	e8 c4 e2 ff ff       	call   1003f4 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  102130:	8b 45 08             	mov    0x8(%ebp),%eax
  102133:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  102137:	83 e0 03             	and    $0x3,%eax
  10213a:	85 c0                	test   %eax,%eax
  10213c:	75 31                	jne    10216f <trap_dispatch+0x350>
            print_trapframe(tf);
  10213e:	8b 45 08             	mov    0x8(%ebp),%eax
  102141:	89 04 24             	mov    %eax,(%esp)
  102144:	e8 52 fa ff ff       	call   101b9b <print_trapframe>
            panic("unexpected trap in kernel.\n");
  102149:	c7 44 24 08 f6 69 10 	movl   $0x1069f6,0x8(%esp)
  102150:	00 
  102151:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  102158:	00 
  102159:	c7 04 24 e5 69 10 00 	movl   $0x1069e5,(%esp)
  102160:	e8 8f e2 ff ff       	call   1003f4 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
  102165:	90                   	nop
  102166:	eb 07                	jmp    10216f <trap_dispatch+0x350>
        count++;
        if(count == TICK_NUM){
            count = 0;
            print_ticks();
        }
        break;
  102168:	90                   	nop
  102169:	eb 04                	jmp    10216f <trap_dispatch+0x350>
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
            saved_tf->tf_trapno = 0x21;
            print_trapframe(tf);
        }
        break;
  10216b:	90                   	nop
  10216c:	eb 01                	jmp    10216f <trap_dispatch+0x350>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
  10216e:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
  10216f:	90                   	nop
  102170:	83 c4 20             	add    $0x20,%esp
  102173:	5b                   	pop    %ebx
  102174:	5e                   	pop    %esi
  102175:	5d                   	pop    %ebp
  102176:	c3                   	ret    

00102177 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  102177:	55                   	push   %ebp
  102178:	89 e5                	mov    %esp,%ebp
  10217a:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  10217d:	8b 45 08             	mov    0x8(%ebp),%eax
  102180:	89 04 24             	mov    %eax,(%esp)
  102183:	e8 97 fc ff ff       	call   101e1f <trap_dispatch>
}
  102188:	90                   	nop
  102189:	c9                   	leave  
  10218a:	c3                   	ret    

0010218b <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  10218b:	6a 00                	push   $0x0
  pushl $0
  10218d:	6a 00                	push   $0x0
  jmp __alltraps
  10218f:	e9 69 0a 00 00       	jmp    102bfd <__alltraps>

00102194 <vector1>:
.globl vector1
vector1:
  pushl $0
  102194:	6a 00                	push   $0x0
  pushl $1
  102196:	6a 01                	push   $0x1
  jmp __alltraps
  102198:	e9 60 0a 00 00       	jmp    102bfd <__alltraps>

0010219d <vector2>:
.globl vector2
vector2:
  pushl $0
  10219d:	6a 00                	push   $0x0
  pushl $2
  10219f:	6a 02                	push   $0x2
  jmp __alltraps
  1021a1:	e9 57 0a 00 00       	jmp    102bfd <__alltraps>

001021a6 <vector3>:
.globl vector3
vector3:
  pushl $0
  1021a6:	6a 00                	push   $0x0
  pushl $3
  1021a8:	6a 03                	push   $0x3
  jmp __alltraps
  1021aa:	e9 4e 0a 00 00       	jmp    102bfd <__alltraps>

001021af <vector4>:
.globl vector4
vector4:
  pushl $0
  1021af:	6a 00                	push   $0x0
  pushl $4
  1021b1:	6a 04                	push   $0x4
  jmp __alltraps
  1021b3:	e9 45 0a 00 00       	jmp    102bfd <__alltraps>

001021b8 <vector5>:
.globl vector5
vector5:
  pushl $0
  1021b8:	6a 00                	push   $0x0
  pushl $5
  1021ba:	6a 05                	push   $0x5
  jmp __alltraps
  1021bc:	e9 3c 0a 00 00       	jmp    102bfd <__alltraps>

001021c1 <vector6>:
.globl vector6
vector6:
  pushl $0
  1021c1:	6a 00                	push   $0x0
  pushl $6
  1021c3:	6a 06                	push   $0x6
  jmp __alltraps
  1021c5:	e9 33 0a 00 00       	jmp    102bfd <__alltraps>

001021ca <vector7>:
.globl vector7
vector7:
  pushl $0
  1021ca:	6a 00                	push   $0x0
  pushl $7
  1021cc:	6a 07                	push   $0x7
  jmp __alltraps
  1021ce:	e9 2a 0a 00 00       	jmp    102bfd <__alltraps>

001021d3 <vector8>:
.globl vector8
vector8:
  pushl $8
  1021d3:	6a 08                	push   $0x8
  jmp __alltraps
  1021d5:	e9 23 0a 00 00       	jmp    102bfd <__alltraps>

001021da <vector9>:
.globl vector9
vector9:
  pushl $0
  1021da:	6a 00                	push   $0x0
  pushl $9
  1021dc:	6a 09                	push   $0x9
  jmp __alltraps
  1021de:	e9 1a 0a 00 00       	jmp    102bfd <__alltraps>

001021e3 <vector10>:
.globl vector10
vector10:
  pushl $10
  1021e3:	6a 0a                	push   $0xa
  jmp __alltraps
  1021e5:	e9 13 0a 00 00       	jmp    102bfd <__alltraps>

001021ea <vector11>:
.globl vector11
vector11:
  pushl $11
  1021ea:	6a 0b                	push   $0xb
  jmp __alltraps
  1021ec:	e9 0c 0a 00 00       	jmp    102bfd <__alltraps>

001021f1 <vector12>:
.globl vector12
vector12:
  pushl $12
  1021f1:	6a 0c                	push   $0xc
  jmp __alltraps
  1021f3:	e9 05 0a 00 00       	jmp    102bfd <__alltraps>

001021f8 <vector13>:
.globl vector13
vector13:
  pushl $13
  1021f8:	6a 0d                	push   $0xd
  jmp __alltraps
  1021fa:	e9 fe 09 00 00       	jmp    102bfd <__alltraps>

001021ff <vector14>:
.globl vector14
vector14:
  pushl $14
  1021ff:	6a 0e                	push   $0xe
  jmp __alltraps
  102201:	e9 f7 09 00 00       	jmp    102bfd <__alltraps>

00102206 <vector15>:
.globl vector15
vector15:
  pushl $0
  102206:	6a 00                	push   $0x0
  pushl $15
  102208:	6a 0f                	push   $0xf
  jmp __alltraps
  10220a:	e9 ee 09 00 00       	jmp    102bfd <__alltraps>

0010220f <vector16>:
.globl vector16
vector16:
  pushl $0
  10220f:	6a 00                	push   $0x0
  pushl $16
  102211:	6a 10                	push   $0x10
  jmp __alltraps
  102213:	e9 e5 09 00 00       	jmp    102bfd <__alltraps>

00102218 <vector17>:
.globl vector17
vector17:
  pushl $17
  102218:	6a 11                	push   $0x11
  jmp __alltraps
  10221a:	e9 de 09 00 00       	jmp    102bfd <__alltraps>

0010221f <vector18>:
.globl vector18
vector18:
  pushl $0
  10221f:	6a 00                	push   $0x0
  pushl $18
  102221:	6a 12                	push   $0x12
  jmp __alltraps
  102223:	e9 d5 09 00 00       	jmp    102bfd <__alltraps>

00102228 <vector19>:
.globl vector19
vector19:
  pushl $0
  102228:	6a 00                	push   $0x0
  pushl $19
  10222a:	6a 13                	push   $0x13
  jmp __alltraps
  10222c:	e9 cc 09 00 00       	jmp    102bfd <__alltraps>

00102231 <vector20>:
.globl vector20
vector20:
  pushl $0
  102231:	6a 00                	push   $0x0
  pushl $20
  102233:	6a 14                	push   $0x14
  jmp __alltraps
  102235:	e9 c3 09 00 00       	jmp    102bfd <__alltraps>

0010223a <vector21>:
.globl vector21
vector21:
  pushl $0
  10223a:	6a 00                	push   $0x0
  pushl $21
  10223c:	6a 15                	push   $0x15
  jmp __alltraps
  10223e:	e9 ba 09 00 00       	jmp    102bfd <__alltraps>

00102243 <vector22>:
.globl vector22
vector22:
  pushl $0
  102243:	6a 00                	push   $0x0
  pushl $22
  102245:	6a 16                	push   $0x16
  jmp __alltraps
  102247:	e9 b1 09 00 00       	jmp    102bfd <__alltraps>

0010224c <vector23>:
.globl vector23
vector23:
  pushl $0
  10224c:	6a 00                	push   $0x0
  pushl $23
  10224e:	6a 17                	push   $0x17
  jmp __alltraps
  102250:	e9 a8 09 00 00       	jmp    102bfd <__alltraps>

00102255 <vector24>:
.globl vector24
vector24:
  pushl $0
  102255:	6a 00                	push   $0x0
  pushl $24
  102257:	6a 18                	push   $0x18
  jmp __alltraps
  102259:	e9 9f 09 00 00       	jmp    102bfd <__alltraps>

0010225e <vector25>:
.globl vector25
vector25:
  pushl $0
  10225e:	6a 00                	push   $0x0
  pushl $25
  102260:	6a 19                	push   $0x19
  jmp __alltraps
  102262:	e9 96 09 00 00       	jmp    102bfd <__alltraps>

00102267 <vector26>:
.globl vector26
vector26:
  pushl $0
  102267:	6a 00                	push   $0x0
  pushl $26
  102269:	6a 1a                	push   $0x1a
  jmp __alltraps
  10226b:	e9 8d 09 00 00       	jmp    102bfd <__alltraps>

00102270 <vector27>:
.globl vector27
vector27:
  pushl $0
  102270:	6a 00                	push   $0x0
  pushl $27
  102272:	6a 1b                	push   $0x1b
  jmp __alltraps
  102274:	e9 84 09 00 00       	jmp    102bfd <__alltraps>

00102279 <vector28>:
.globl vector28
vector28:
  pushl $0
  102279:	6a 00                	push   $0x0
  pushl $28
  10227b:	6a 1c                	push   $0x1c
  jmp __alltraps
  10227d:	e9 7b 09 00 00       	jmp    102bfd <__alltraps>

00102282 <vector29>:
.globl vector29
vector29:
  pushl $0
  102282:	6a 00                	push   $0x0
  pushl $29
  102284:	6a 1d                	push   $0x1d
  jmp __alltraps
  102286:	e9 72 09 00 00       	jmp    102bfd <__alltraps>

0010228b <vector30>:
.globl vector30
vector30:
  pushl $0
  10228b:	6a 00                	push   $0x0
  pushl $30
  10228d:	6a 1e                	push   $0x1e
  jmp __alltraps
  10228f:	e9 69 09 00 00       	jmp    102bfd <__alltraps>

00102294 <vector31>:
.globl vector31
vector31:
  pushl $0
  102294:	6a 00                	push   $0x0
  pushl $31
  102296:	6a 1f                	push   $0x1f
  jmp __alltraps
  102298:	e9 60 09 00 00       	jmp    102bfd <__alltraps>

0010229d <vector32>:
.globl vector32
vector32:
  pushl $0
  10229d:	6a 00                	push   $0x0
  pushl $32
  10229f:	6a 20                	push   $0x20
  jmp __alltraps
  1022a1:	e9 57 09 00 00       	jmp    102bfd <__alltraps>

001022a6 <vector33>:
.globl vector33
vector33:
  pushl $0
  1022a6:	6a 00                	push   $0x0
  pushl $33
  1022a8:	6a 21                	push   $0x21
  jmp __alltraps
  1022aa:	e9 4e 09 00 00       	jmp    102bfd <__alltraps>

001022af <vector34>:
.globl vector34
vector34:
  pushl $0
  1022af:	6a 00                	push   $0x0
  pushl $34
  1022b1:	6a 22                	push   $0x22
  jmp __alltraps
  1022b3:	e9 45 09 00 00       	jmp    102bfd <__alltraps>

001022b8 <vector35>:
.globl vector35
vector35:
  pushl $0
  1022b8:	6a 00                	push   $0x0
  pushl $35
  1022ba:	6a 23                	push   $0x23
  jmp __alltraps
  1022bc:	e9 3c 09 00 00       	jmp    102bfd <__alltraps>

001022c1 <vector36>:
.globl vector36
vector36:
  pushl $0
  1022c1:	6a 00                	push   $0x0
  pushl $36
  1022c3:	6a 24                	push   $0x24
  jmp __alltraps
  1022c5:	e9 33 09 00 00       	jmp    102bfd <__alltraps>

001022ca <vector37>:
.globl vector37
vector37:
  pushl $0
  1022ca:	6a 00                	push   $0x0
  pushl $37
  1022cc:	6a 25                	push   $0x25
  jmp __alltraps
  1022ce:	e9 2a 09 00 00       	jmp    102bfd <__alltraps>

001022d3 <vector38>:
.globl vector38
vector38:
  pushl $0
  1022d3:	6a 00                	push   $0x0
  pushl $38
  1022d5:	6a 26                	push   $0x26
  jmp __alltraps
  1022d7:	e9 21 09 00 00       	jmp    102bfd <__alltraps>

001022dc <vector39>:
.globl vector39
vector39:
  pushl $0
  1022dc:	6a 00                	push   $0x0
  pushl $39
  1022de:	6a 27                	push   $0x27
  jmp __alltraps
  1022e0:	e9 18 09 00 00       	jmp    102bfd <__alltraps>

001022e5 <vector40>:
.globl vector40
vector40:
  pushl $0
  1022e5:	6a 00                	push   $0x0
  pushl $40
  1022e7:	6a 28                	push   $0x28
  jmp __alltraps
  1022e9:	e9 0f 09 00 00       	jmp    102bfd <__alltraps>

001022ee <vector41>:
.globl vector41
vector41:
  pushl $0
  1022ee:	6a 00                	push   $0x0
  pushl $41
  1022f0:	6a 29                	push   $0x29
  jmp __alltraps
  1022f2:	e9 06 09 00 00       	jmp    102bfd <__alltraps>

001022f7 <vector42>:
.globl vector42
vector42:
  pushl $0
  1022f7:	6a 00                	push   $0x0
  pushl $42
  1022f9:	6a 2a                	push   $0x2a
  jmp __alltraps
  1022fb:	e9 fd 08 00 00       	jmp    102bfd <__alltraps>

00102300 <vector43>:
.globl vector43
vector43:
  pushl $0
  102300:	6a 00                	push   $0x0
  pushl $43
  102302:	6a 2b                	push   $0x2b
  jmp __alltraps
  102304:	e9 f4 08 00 00       	jmp    102bfd <__alltraps>

00102309 <vector44>:
.globl vector44
vector44:
  pushl $0
  102309:	6a 00                	push   $0x0
  pushl $44
  10230b:	6a 2c                	push   $0x2c
  jmp __alltraps
  10230d:	e9 eb 08 00 00       	jmp    102bfd <__alltraps>

00102312 <vector45>:
.globl vector45
vector45:
  pushl $0
  102312:	6a 00                	push   $0x0
  pushl $45
  102314:	6a 2d                	push   $0x2d
  jmp __alltraps
  102316:	e9 e2 08 00 00       	jmp    102bfd <__alltraps>

0010231b <vector46>:
.globl vector46
vector46:
  pushl $0
  10231b:	6a 00                	push   $0x0
  pushl $46
  10231d:	6a 2e                	push   $0x2e
  jmp __alltraps
  10231f:	e9 d9 08 00 00       	jmp    102bfd <__alltraps>

00102324 <vector47>:
.globl vector47
vector47:
  pushl $0
  102324:	6a 00                	push   $0x0
  pushl $47
  102326:	6a 2f                	push   $0x2f
  jmp __alltraps
  102328:	e9 d0 08 00 00       	jmp    102bfd <__alltraps>

0010232d <vector48>:
.globl vector48
vector48:
  pushl $0
  10232d:	6a 00                	push   $0x0
  pushl $48
  10232f:	6a 30                	push   $0x30
  jmp __alltraps
  102331:	e9 c7 08 00 00       	jmp    102bfd <__alltraps>

00102336 <vector49>:
.globl vector49
vector49:
  pushl $0
  102336:	6a 00                	push   $0x0
  pushl $49
  102338:	6a 31                	push   $0x31
  jmp __alltraps
  10233a:	e9 be 08 00 00       	jmp    102bfd <__alltraps>

0010233f <vector50>:
.globl vector50
vector50:
  pushl $0
  10233f:	6a 00                	push   $0x0
  pushl $50
  102341:	6a 32                	push   $0x32
  jmp __alltraps
  102343:	e9 b5 08 00 00       	jmp    102bfd <__alltraps>

00102348 <vector51>:
.globl vector51
vector51:
  pushl $0
  102348:	6a 00                	push   $0x0
  pushl $51
  10234a:	6a 33                	push   $0x33
  jmp __alltraps
  10234c:	e9 ac 08 00 00       	jmp    102bfd <__alltraps>

00102351 <vector52>:
.globl vector52
vector52:
  pushl $0
  102351:	6a 00                	push   $0x0
  pushl $52
  102353:	6a 34                	push   $0x34
  jmp __alltraps
  102355:	e9 a3 08 00 00       	jmp    102bfd <__alltraps>

0010235a <vector53>:
.globl vector53
vector53:
  pushl $0
  10235a:	6a 00                	push   $0x0
  pushl $53
  10235c:	6a 35                	push   $0x35
  jmp __alltraps
  10235e:	e9 9a 08 00 00       	jmp    102bfd <__alltraps>

00102363 <vector54>:
.globl vector54
vector54:
  pushl $0
  102363:	6a 00                	push   $0x0
  pushl $54
  102365:	6a 36                	push   $0x36
  jmp __alltraps
  102367:	e9 91 08 00 00       	jmp    102bfd <__alltraps>

0010236c <vector55>:
.globl vector55
vector55:
  pushl $0
  10236c:	6a 00                	push   $0x0
  pushl $55
  10236e:	6a 37                	push   $0x37
  jmp __alltraps
  102370:	e9 88 08 00 00       	jmp    102bfd <__alltraps>

00102375 <vector56>:
.globl vector56
vector56:
  pushl $0
  102375:	6a 00                	push   $0x0
  pushl $56
  102377:	6a 38                	push   $0x38
  jmp __alltraps
  102379:	e9 7f 08 00 00       	jmp    102bfd <__alltraps>

0010237e <vector57>:
.globl vector57
vector57:
  pushl $0
  10237e:	6a 00                	push   $0x0
  pushl $57
  102380:	6a 39                	push   $0x39
  jmp __alltraps
  102382:	e9 76 08 00 00       	jmp    102bfd <__alltraps>

00102387 <vector58>:
.globl vector58
vector58:
  pushl $0
  102387:	6a 00                	push   $0x0
  pushl $58
  102389:	6a 3a                	push   $0x3a
  jmp __alltraps
  10238b:	e9 6d 08 00 00       	jmp    102bfd <__alltraps>

00102390 <vector59>:
.globl vector59
vector59:
  pushl $0
  102390:	6a 00                	push   $0x0
  pushl $59
  102392:	6a 3b                	push   $0x3b
  jmp __alltraps
  102394:	e9 64 08 00 00       	jmp    102bfd <__alltraps>

00102399 <vector60>:
.globl vector60
vector60:
  pushl $0
  102399:	6a 00                	push   $0x0
  pushl $60
  10239b:	6a 3c                	push   $0x3c
  jmp __alltraps
  10239d:	e9 5b 08 00 00       	jmp    102bfd <__alltraps>

001023a2 <vector61>:
.globl vector61
vector61:
  pushl $0
  1023a2:	6a 00                	push   $0x0
  pushl $61
  1023a4:	6a 3d                	push   $0x3d
  jmp __alltraps
  1023a6:	e9 52 08 00 00       	jmp    102bfd <__alltraps>

001023ab <vector62>:
.globl vector62
vector62:
  pushl $0
  1023ab:	6a 00                	push   $0x0
  pushl $62
  1023ad:	6a 3e                	push   $0x3e
  jmp __alltraps
  1023af:	e9 49 08 00 00       	jmp    102bfd <__alltraps>

001023b4 <vector63>:
.globl vector63
vector63:
  pushl $0
  1023b4:	6a 00                	push   $0x0
  pushl $63
  1023b6:	6a 3f                	push   $0x3f
  jmp __alltraps
  1023b8:	e9 40 08 00 00       	jmp    102bfd <__alltraps>

001023bd <vector64>:
.globl vector64
vector64:
  pushl $0
  1023bd:	6a 00                	push   $0x0
  pushl $64
  1023bf:	6a 40                	push   $0x40
  jmp __alltraps
  1023c1:	e9 37 08 00 00       	jmp    102bfd <__alltraps>

001023c6 <vector65>:
.globl vector65
vector65:
  pushl $0
  1023c6:	6a 00                	push   $0x0
  pushl $65
  1023c8:	6a 41                	push   $0x41
  jmp __alltraps
  1023ca:	e9 2e 08 00 00       	jmp    102bfd <__alltraps>

001023cf <vector66>:
.globl vector66
vector66:
  pushl $0
  1023cf:	6a 00                	push   $0x0
  pushl $66
  1023d1:	6a 42                	push   $0x42
  jmp __alltraps
  1023d3:	e9 25 08 00 00       	jmp    102bfd <__alltraps>

001023d8 <vector67>:
.globl vector67
vector67:
  pushl $0
  1023d8:	6a 00                	push   $0x0
  pushl $67
  1023da:	6a 43                	push   $0x43
  jmp __alltraps
  1023dc:	e9 1c 08 00 00       	jmp    102bfd <__alltraps>

001023e1 <vector68>:
.globl vector68
vector68:
  pushl $0
  1023e1:	6a 00                	push   $0x0
  pushl $68
  1023e3:	6a 44                	push   $0x44
  jmp __alltraps
  1023e5:	e9 13 08 00 00       	jmp    102bfd <__alltraps>

001023ea <vector69>:
.globl vector69
vector69:
  pushl $0
  1023ea:	6a 00                	push   $0x0
  pushl $69
  1023ec:	6a 45                	push   $0x45
  jmp __alltraps
  1023ee:	e9 0a 08 00 00       	jmp    102bfd <__alltraps>

001023f3 <vector70>:
.globl vector70
vector70:
  pushl $0
  1023f3:	6a 00                	push   $0x0
  pushl $70
  1023f5:	6a 46                	push   $0x46
  jmp __alltraps
  1023f7:	e9 01 08 00 00       	jmp    102bfd <__alltraps>

001023fc <vector71>:
.globl vector71
vector71:
  pushl $0
  1023fc:	6a 00                	push   $0x0
  pushl $71
  1023fe:	6a 47                	push   $0x47
  jmp __alltraps
  102400:	e9 f8 07 00 00       	jmp    102bfd <__alltraps>

00102405 <vector72>:
.globl vector72
vector72:
  pushl $0
  102405:	6a 00                	push   $0x0
  pushl $72
  102407:	6a 48                	push   $0x48
  jmp __alltraps
  102409:	e9 ef 07 00 00       	jmp    102bfd <__alltraps>

0010240e <vector73>:
.globl vector73
vector73:
  pushl $0
  10240e:	6a 00                	push   $0x0
  pushl $73
  102410:	6a 49                	push   $0x49
  jmp __alltraps
  102412:	e9 e6 07 00 00       	jmp    102bfd <__alltraps>

00102417 <vector74>:
.globl vector74
vector74:
  pushl $0
  102417:	6a 00                	push   $0x0
  pushl $74
  102419:	6a 4a                	push   $0x4a
  jmp __alltraps
  10241b:	e9 dd 07 00 00       	jmp    102bfd <__alltraps>

00102420 <vector75>:
.globl vector75
vector75:
  pushl $0
  102420:	6a 00                	push   $0x0
  pushl $75
  102422:	6a 4b                	push   $0x4b
  jmp __alltraps
  102424:	e9 d4 07 00 00       	jmp    102bfd <__alltraps>

00102429 <vector76>:
.globl vector76
vector76:
  pushl $0
  102429:	6a 00                	push   $0x0
  pushl $76
  10242b:	6a 4c                	push   $0x4c
  jmp __alltraps
  10242d:	e9 cb 07 00 00       	jmp    102bfd <__alltraps>

00102432 <vector77>:
.globl vector77
vector77:
  pushl $0
  102432:	6a 00                	push   $0x0
  pushl $77
  102434:	6a 4d                	push   $0x4d
  jmp __alltraps
  102436:	e9 c2 07 00 00       	jmp    102bfd <__alltraps>

0010243b <vector78>:
.globl vector78
vector78:
  pushl $0
  10243b:	6a 00                	push   $0x0
  pushl $78
  10243d:	6a 4e                	push   $0x4e
  jmp __alltraps
  10243f:	e9 b9 07 00 00       	jmp    102bfd <__alltraps>

00102444 <vector79>:
.globl vector79
vector79:
  pushl $0
  102444:	6a 00                	push   $0x0
  pushl $79
  102446:	6a 4f                	push   $0x4f
  jmp __alltraps
  102448:	e9 b0 07 00 00       	jmp    102bfd <__alltraps>

0010244d <vector80>:
.globl vector80
vector80:
  pushl $0
  10244d:	6a 00                	push   $0x0
  pushl $80
  10244f:	6a 50                	push   $0x50
  jmp __alltraps
  102451:	e9 a7 07 00 00       	jmp    102bfd <__alltraps>

00102456 <vector81>:
.globl vector81
vector81:
  pushl $0
  102456:	6a 00                	push   $0x0
  pushl $81
  102458:	6a 51                	push   $0x51
  jmp __alltraps
  10245a:	e9 9e 07 00 00       	jmp    102bfd <__alltraps>

0010245f <vector82>:
.globl vector82
vector82:
  pushl $0
  10245f:	6a 00                	push   $0x0
  pushl $82
  102461:	6a 52                	push   $0x52
  jmp __alltraps
  102463:	e9 95 07 00 00       	jmp    102bfd <__alltraps>

00102468 <vector83>:
.globl vector83
vector83:
  pushl $0
  102468:	6a 00                	push   $0x0
  pushl $83
  10246a:	6a 53                	push   $0x53
  jmp __alltraps
  10246c:	e9 8c 07 00 00       	jmp    102bfd <__alltraps>

00102471 <vector84>:
.globl vector84
vector84:
  pushl $0
  102471:	6a 00                	push   $0x0
  pushl $84
  102473:	6a 54                	push   $0x54
  jmp __alltraps
  102475:	e9 83 07 00 00       	jmp    102bfd <__alltraps>

0010247a <vector85>:
.globl vector85
vector85:
  pushl $0
  10247a:	6a 00                	push   $0x0
  pushl $85
  10247c:	6a 55                	push   $0x55
  jmp __alltraps
  10247e:	e9 7a 07 00 00       	jmp    102bfd <__alltraps>

00102483 <vector86>:
.globl vector86
vector86:
  pushl $0
  102483:	6a 00                	push   $0x0
  pushl $86
  102485:	6a 56                	push   $0x56
  jmp __alltraps
  102487:	e9 71 07 00 00       	jmp    102bfd <__alltraps>

0010248c <vector87>:
.globl vector87
vector87:
  pushl $0
  10248c:	6a 00                	push   $0x0
  pushl $87
  10248e:	6a 57                	push   $0x57
  jmp __alltraps
  102490:	e9 68 07 00 00       	jmp    102bfd <__alltraps>

00102495 <vector88>:
.globl vector88
vector88:
  pushl $0
  102495:	6a 00                	push   $0x0
  pushl $88
  102497:	6a 58                	push   $0x58
  jmp __alltraps
  102499:	e9 5f 07 00 00       	jmp    102bfd <__alltraps>

0010249e <vector89>:
.globl vector89
vector89:
  pushl $0
  10249e:	6a 00                	push   $0x0
  pushl $89
  1024a0:	6a 59                	push   $0x59
  jmp __alltraps
  1024a2:	e9 56 07 00 00       	jmp    102bfd <__alltraps>

001024a7 <vector90>:
.globl vector90
vector90:
  pushl $0
  1024a7:	6a 00                	push   $0x0
  pushl $90
  1024a9:	6a 5a                	push   $0x5a
  jmp __alltraps
  1024ab:	e9 4d 07 00 00       	jmp    102bfd <__alltraps>

001024b0 <vector91>:
.globl vector91
vector91:
  pushl $0
  1024b0:	6a 00                	push   $0x0
  pushl $91
  1024b2:	6a 5b                	push   $0x5b
  jmp __alltraps
  1024b4:	e9 44 07 00 00       	jmp    102bfd <__alltraps>

001024b9 <vector92>:
.globl vector92
vector92:
  pushl $0
  1024b9:	6a 00                	push   $0x0
  pushl $92
  1024bb:	6a 5c                	push   $0x5c
  jmp __alltraps
  1024bd:	e9 3b 07 00 00       	jmp    102bfd <__alltraps>

001024c2 <vector93>:
.globl vector93
vector93:
  pushl $0
  1024c2:	6a 00                	push   $0x0
  pushl $93
  1024c4:	6a 5d                	push   $0x5d
  jmp __alltraps
  1024c6:	e9 32 07 00 00       	jmp    102bfd <__alltraps>

001024cb <vector94>:
.globl vector94
vector94:
  pushl $0
  1024cb:	6a 00                	push   $0x0
  pushl $94
  1024cd:	6a 5e                	push   $0x5e
  jmp __alltraps
  1024cf:	e9 29 07 00 00       	jmp    102bfd <__alltraps>

001024d4 <vector95>:
.globl vector95
vector95:
  pushl $0
  1024d4:	6a 00                	push   $0x0
  pushl $95
  1024d6:	6a 5f                	push   $0x5f
  jmp __alltraps
  1024d8:	e9 20 07 00 00       	jmp    102bfd <__alltraps>

001024dd <vector96>:
.globl vector96
vector96:
  pushl $0
  1024dd:	6a 00                	push   $0x0
  pushl $96
  1024df:	6a 60                	push   $0x60
  jmp __alltraps
  1024e1:	e9 17 07 00 00       	jmp    102bfd <__alltraps>

001024e6 <vector97>:
.globl vector97
vector97:
  pushl $0
  1024e6:	6a 00                	push   $0x0
  pushl $97
  1024e8:	6a 61                	push   $0x61
  jmp __alltraps
  1024ea:	e9 0e 07 00 00       	jmp    102bfd <__alltraps>

001024ef <vector98>:
.globl vector98
vector98:
  pushl $0
  1024ef:	6a 00                	push   $0x0
  pushl $98
  1024f1:	6a 62                	push   $0x62
  jmp __alltraps
  1024f3:	e9 05 07 00 00       	jmp    102bfd <__alltraps>

001024f8 <vector99>:
.globl vector99
vector99:
  pushl $0
  1024f8:	6a 00                	push   $0x0
  pushl $99
  1024fa:	6a 63                	push   $0x63
  jmp __alltraps
  1024fc:	e9 fc 06 00 00       	jmp    102bfd <__alltraps>

00102501 <vector100>:
.globl vector100
vector100:
  pushl $0
  102501:	6a 00                	push   $0x0
  pushl $100
  102503:	6a 64                	push   $0x64
  jmp __alltraps
  102505:	e9 f3 06 00 00       	jmp    102bfd <__alltraps>

0010250a <vector101>:
.globl vector101
vector101:
  pushl $0
  10250a:	6a 00                	push   $0x0
  pushl $101
  10250c:	6a 65                	push   $0x65
  jmp __alltraps
  10250e:	e9 ea 06 00 00       	jmp    102bfd <__alltraps>

00102513 <vector102>:
.globl vector102
vector102:
  pushl $0
  102513:	6a 00                	push   $0x0
  pushl $102
  102515:	6a 66                	push   $0x66
  jmp __alltraps
  102517:	e9 e1 06 00 00       	jmp    102bfd <__alltraps>

0010251c <vector103>:
.globl vector103
vector103:
  pushl $0
  10251c:	6a 00                	push   $0x0
  pushl $103
  10251e:	6a 67                	push   $0x67
  jmp __alltraps
  102520:	e9 d8 06 00 00       	jmp    102bfd <__alltraps>

00102525 <vector104>:
.globl vector104
vector104:
  pushl $0
  102525:	6a 00                	push   $0x0
  pushl $104
  102527:	6a 68                	push   $0x68
  jmp __alltraps
  102529:	e9 cf 06 00 00       	jmp    102bfd <__alltraps>

0010252e <vector105>:
.globl vector105
vector105:
  pushl $0
  10252e:	6a 00                	push   $0x0
  pushl $105
  102530:	6a 69                	push   $0x69
  jmp __alltraps
  102532:	e9 c6 06 00 00       	jmp    102bfd <__alltraps>

00102537 <vector106>:
.globl vector106
vector106:
  pushl $0
  102537:	6a 00                	push   $0x0
  pushl $106
  102539:	6a 6a                	push   $0x6a
  jmp __alltraps
  10253b:	e9 bd 06 00 00       	jmp    102bfd <__alltraps>

00102540 <vector107>:
.globl vector107
vector107:
  pushl $0
  102540:	6a 00                	push   $0x0
  pushl $107
  102542:	6a 6b                	push   $0x6b
  jmp __alltraps
  102544:	e9 b4 06 00 00       	jmp    102bfd <__alltraps>

00102549 <vector108>:
.globl vector108
vector108:
  pushl $0
  102549:	6a 00                	push   $0x0
  pushl $108
  10254b:	6a 6c                	push   $0x6c
  jmp __alltraps
  10254d:	e9 ab 06 00 00       	jmp    102bfd <__alltraps>

00102552 <vector109>:
.globl vector109
vector109:
  pushl $0
  102552:	6a 00                	push   $0x0
  pushl $109
  102554:	6a 6d                	push   $0x6d
  jmp __alltraps
  102556:	e9 a2 06 00 00       	jmp    102bfd <__alltraps>

0010255b <vector110>:
.globl vector110
vector110:
  pushl $0
  10255b:	6a 00                	push   $0x0
  pushl $110
  10255d:	6a 6e                	push   $0x6e
  jmp __alltraps
  10255f:	e9 99 06 00 00       	jmp    102bfd <__alltraps>

00102564 <vector111>:
.globl vector111
vector111:
  pushl $0
  102564:	6a 00                	push   $0x0
  pushl $111
  102566:	6a 6f                	push   $0x6f
  jmp __alltraps
  102568:	e9 90 06 00 00       	jmp    102bfd <__alltraps>

0010256d <vector112>:
.globl vector112
vector112:
  pushl $0
  10256d:	6a 00                	push   $0x0
  pushl $112
  10256f:	6a 70                	push   $0x70
  jmp __alltraps
  102571:	e9 87 06 00 00       	jmp    102bfd <__alltraps>

00102576 <vector113>:
.globl vector113
vector113:
  pushl $0
  102576:	6a 00                	push   $0x0
  pushl $113
  102578:	6a 71                	push   $0x71
  jmp __alltraps
  10257a:	e9 7e 06 00 00       	jmp    102bfd <__alltraps>

0010257f <vector114>:
.globl vector114
vector114:
  pushl $0
  10257f:	6a 00                	push   $0x0
  pushl $114
  102581:	6a 72                	push   $0x72
  jmp __alltraps
  102583:	e9 75 06 00 00       	jmp    102bfd <__alltraps>

00102588 <vector115>:
.globl vector115
vector115:
  pushl $0
  102588:	6a 00                	push   $0x0
  pushl $115
  10258a:	6a 73                	push   $0x73
  jmp __alltraps
  10258c:	e9 6c 06 00 00       	jmp    102bfd <__alltraps>

00102591 <vector116>:
.globl vector116
vector116:
  pushl $0
  102591:	6a 00                	push   $0x0
  pushl $116
  102593:	6a 74                	push   $0x74
  jmp __alltraps
  102595:	e9 63 06 00 00       	jmp    102bfd <__alltraps>

0010259a <vector117>:
.globl vector117
vector117:
  pushl $0
  10259a:	6a 00                	push   $0x0
  pushl $117
  10259c:	6a 75                	push   $0x75
  jmp __alltraps
  10259e:	e9 5a 06 00 00       	jmp    102bfd <__alltraps>

001025a3 <vector118>:
.globl vector118
vector118:
  pushl $0
  1025a3:	6a 00                	push   $0x0
  pushl $118
  1025a5:	6a 76                	push   $0x76
  jmp __alltraps
  1025a7:	e9 51 06 00 00       	jmp    102bfd <__alltraps>

001025ac <vector119>:
.globl vector119
vector119:
  pushl $0
  1025ac:	6a 00                	push   $0x0
  pushl $119
  1025ae:	6a 77                	push   $0x77
  jmp __alltraps
  1025b0:	e9 48 06 00 00       	jmp    102bfd <__alltraps>

001025b5 <vector120>:
.globl vector120
vector120:
  pushl $0
  1025b5:	6a 00                	push   $0x0
  pushl $120
  1025b7:	6a 78                	push   $0x78
  jmp __alltraps
  1025b9:	e9 3f 06 00 00       	jmp    102bfd <__alltraps>

001025be <vector121>:
.globl vector121
vector121:
  pushl $0
  1025be:	6a 00                	push   $0x0
  pushl $121
  1025c0:	6a 79                	push   $0x79
  jmp __alltraps
  1025c2:	e9 36 06 00 00       	jmp    102bfd <__alltraps>

001025c7 <vector122>:
.globl vector122
vector122:
  pushl $0
  1025c7:	6a 00                	push   $0x0
  pushl $122
  1025c9:	6a 7a                	push   $0x7a
  jmp __alltraps
  1025cb:	e9 2d 06 00 00       	jmp    102bfd <__alltraps>

001025d0 <vector123>:
.globl vector123
vector123:
  pushl $0
  1025d0:	6a 00                	push   $0x0
  pushl $123
  1025d2:	6a 7b                	push   $0x7b
  jmp __alltraps
  1025d4:	e9 24 06 00 00       	jmp    102bfd <__alltraps>

001025d9 <vector124>:
.globl vector124
vector124:
  pushl $0
  1025d9:	6a 00                	push   $0x0
  pushl $124
  1025db:	6a 7c                	push   $0x7c
  jmp __alltraps
  1025dd:	e9 1b 06 00 00       	jmp    102bfd <__alltraps>

001025e2 <vector125>:
.globl vector125
vector125:
  pushl $0
  1025e2:	6a 00                	push   $0x0
  pushl $125
  1025e4:	6a 7d                	push   $0x7d
  jmp __alltraps
  1025e6:	e9 12 06 00 00       	jmp    102bfd <__alltraps>

001025eb <vector126>:
.globl vector126
vector126:
  pushl $0
  1025eb:	6a 00                	push   $0x0
  pushl $126
  1025ed:	6a 7e                	push   $0x7e
  jmp __alltraps
  1025ef:	e9 09 06 00 00       	jmp    102bfd <__alltraps>

001025f4 <vector127>:
.globl vector127
vector127:
  pushl $0
  1025f4:	6a 00                	push   $0x0
  pushl $127
  1025f6:	6a 7f                	push   $0x7f
  jmp __alltraps
  1025f8:	e9 00 06 00 00       	jmp    102bfd <__alltraps>

001025fd <vector128>:
.globl vector128
vector128:
  pushl $0
  1025fd:	6a 00                	push   $0x0
  pushl $128
  1025ff:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102604:	e9 f4 05 00 00       	jmp    102bfd <__alltraps>

00102609 <vector129>:
.globl vector129
vector129:
  pushl $0
  102609:	6a 00                	push   $0x0
  pushl $129
  10260b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102610:	e9 e8 05 00 00       	jmp    102bfd <__alltraps>

00102615 <vector130>:
.globl vector130
vector130:
  pushl $0
  102615:	6a 00                	push   $0x0
  pushl $130
  102617:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10261c:	e9 dc 05 00 00       	jmp    102bfd <__alltraps>

00102621 <vector131>:
.globl vector131
vector131:
  pushl $0
  102621:	6a 00                	push   $0x0
  pushl $131
  102623:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  102628:	e9 d0 05 00 00       	jmp    102bfd <__alltraps>

0010262d <vector132>:
.globl vector132
vector132:
  pushl $0
  10262d:	6a 00                	push   $0x0
  pushl $132
  10262f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  102634:	e9 c4 05 00 00       	jmp    102bfd <__alltraps>

00102639 <vector133>:
.globl vector133
vector133:
  pushl $0
  102639:	6a 00                	push   $0x0
  pushl $133
  10263b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  102640:	e9 b8 05 00 00       	jmp    102bfd <__alltraps>

00102645 <vector134>:
.globl vector134
vector134:
  pushl $0
  102645:	6a 00                	push   $0x0
  pushl $134
  102647:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  10264c:	e9 ac 05 00 00       	jmp    102bfd <__alltraps>

00102651 <vector135>:
.globl vector135
vector135:
  pushl $0
  102651:	6a 00                	push   $0x0
  pushl $135
  102653:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  102658:	e9 a0 05 00 00       	jmp    102bfd <__alltraps>

0010265d <vector136>:
.globl vector136
vector136:
  pushl $0
  10265d:	6a 00                	push   $0x0
  pushl $136
  10265f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  102664:	e9 94 05 00 00       	jmp    102bfd <__alltraps>

00102669 <vector137>:
.globl vector137
vector137:
  pushl $0
  102669:	6a 00                	push   $0x0
  pushl $137
  10266b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  102670:	e9 88 05 00 00       	jmp    102bfd <__alltraps>

00102675 <vector138>:
.globl vector138
vector138:
  pushl $0
  102675:	6a 00                	push   $0x0
  pushl $138
  102677:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  10267c:	e9 7c 05 00 00       	jmp    102bfd <__alltraps>

00102681 <vector139>:
.globl vector139
vector139:
  pushl $0
  102681:	6a 00                	push   $0x0
  pushl $139
  102683:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  102688:	e9 70 05 00 00       	jmp    102bfd <__alltraps>

0010268d <vector140>:
.globl vector140
vector140:
  pushl $0
  10268d:	6a 00                	push   $0x0
  pushl $140
  10268f:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102694:	e9 64 05 00 00       	jmp    102bfd <__alltraps>

00102699 <vector141>:
.globl vector141
vector141:
  pushl $0
  102699:	6a 00                	push   $0x0
  pushl $141
  10269b:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  1026a0:	e9 58 05 00 00       	jmp    102bfd <__alltraps>

001026a5 <vector142>:
.globl vector142
vector142:
  pushl $0
  1026a5:	6a 00                	push   $0x0
  pushl $142
  1026a7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  1026ac:	e9 4c 05 00 00       	jmp    102bfd <__alltraps>

001026b1 <vector143>:
.globl vector143
vector143:
  pushl $0
  1026b1:	6a 00                	push   $0x0
  pushl $143
  1026b3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  1026b8:	e9 40 05 00 00       	jmp    102bfd <__alltraps>

001026bd <vector144>:
.globl vector144
vector144:
  pushl $0
  1026bd:	6a 00                	push   $0x0
  pushl $144
  1026bf:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  1026c4:	e9 34 05 00 00       	jmp    102bfd <__alltraps>

001026c9 <vector145>:
.globl vector145
vector145:
  pushl $0
  1026c9:	6a 00                	push   $0x0
  pushl $145
  1026cb:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  1026d0:	e9 28 05 00 00       	jmp    102bfd <__alltraps>

001026d5 <vector146>:
.globl vector146
vector146:
  pushl $0
  1026d5:	6a 00                	push   $0x0
  pushl $146
  1026d7:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  1026dc:	e9 1c 05 00 00       	jmp    102bfd <__alltraps>

001026e1 <vector147>:
.globl vector147
vector147:
  pushl $0
  1026e1:	6a 00                	push   $0x0
  pushl $147
  1026e3:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  1026e8:	e9 10 05 00 00       	jmp    102bfd <__alltraps>

001026ed <vector148>:
.globl vector148
vector148:
  pushl $0
  1026ed:	6a 00                	push   $0x0
  pushl $148
  1026ef:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  1026f4:	e9 04 05 00 00       	jmp    102bfd <__alltraps>

001026f9 <vector149>:
.globl vector149
vector149:
  pushl $0
  1026f9:	6a 00                	push   $0x0
  pushl $149
  1026fb:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102700:	e9 f8 04 00 00       	jmp    102bfd <__alltraps>

00102705 <vector150>:
.globl vector150
vector150:
  pushl $0
  102705:	6a 00                	push   $0x0
  pushl $150
  102707:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10270c:	e9 ec 04 00 00       	jmp    102bfd <__alltraps>

00102711 <vector151>:
.globl vector151
vector151:
  pushl $0
  102711:	6a 00                	push   $0x0
  pushl $151
  102713:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  102718:	e9 e0 04 00 00       	jmp    102bfd <__alltraps>

0010271d <vector152>:
.globl vector152
vector152:
  pushl $0
  10271d:	6a 00                	push   $0x0
  pushl $152
  10271f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  102724:	e9 d4 04 00 00       	jmp    102bfd <__alltraps>

00102729 <vector153>:
.globl vector153
vector153:
  pushl $0
  102729:	6a 00                	push   $0x0
  pushl $153
  10272b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  102730:	e9 c8 04 00 00       	jmp    102bfd <__alltraps>

00102735 <vector154>:
.globl vector154
vector154:
  pushl $0
  102735:	6a 00                	push   $0x0
  pushl $154
  102737:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  10273c:	e9 bc 04 00 00       	jmp    102bfd <__alltraps>

00102741 <vector155>:
.globl vector155
vector155:
  pushl $0
  102741:	6a 00                	push   $0x0
  pushl $155
  102743:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  102748:	e9 b0 04 00 00       	jmp    102bfd <__alltraps>

0010274d <vector156>:
.globl vector156
vector156:
  pushl $0
  10274d:	6a 00                	push   $0x0
  pushl $156
  10274f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  102754:	e9 a4 04 00 00       	jmp    102bfd <__alltraps>

00102759 <vector157>:
.globl vector157
vector157:
  pushl $0
  102759:	6a 00                	push   $0x0
  pushl $157
  10275b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  102760:	e9 98 04 00 00       	jmp    102bfd <__alltraps>

00102765 <vector158>:
.globl vector158
vector158:
  pushl $0
  102765:	6a 00                	push   $0x0
  pushl $158
  102767:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  10276c:	e9 8c 04 00 00       	jmp    102bfd <__alltraps>

00102771 <vector159>:
.globl vector159
vector159:
  pushl $0
  102771:	6a 00                	push   $0x0
  pushl $159
  102773:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  102778:	e9 80 04 00 00       	jmp    102bfd <__alltraps>

0010277d <vector160>:
.globl vector160
vector160:
  pushl $0
  10277d:	6a 00                	push   $0x0
  pushl $160
  10277f:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102784:	e9 74 04 00 00       	jmp    102bfd <__alltraps>

00102789 <vector161>:
.globl vector161
vector161:
  pushl $0
  102789:	6a 00                	push   $0x0
  pushl $161
  10278b:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102790:	e9 68 04 00 00       	jmp    102bfd <__alltraps>

00102795 <vector162>:
.globl vector162
vector162:
  pushl $0
  102795:	6a 00                	push   $0x0
  pushl $162
  102797:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10279c:	e9 5c 04 00 00       	jmp    102bfd <__alltraps>

001027a1 <vector163>:
.globl vector163
vector163:
  pushl $0
  1027a1:	6a 00                	push   $0x0
  pushl $163
  1027a3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  1027a8:	e9 50 04 00 00       	jmp    102bfd <__alltraps>

001027ad <vector164>:
.globl vector164
vector164:
  pushl $0
  1027ad:	6a 00                	push   $0x0
  pushl $164
  1027af:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  1027b4:	e9 44 04 00 00       	jmp    102bfd <__alltraps>

001027b9 <vector165>:
.globl vector165
vector165:
  pushl $0
  1027b9:	6a 00                	push   $0x0
  pushl $165
  1027bb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  1027c0:	e9 38 04 00 00       	jmp    102bfd <__alltraps>

001027c5 <vector166>:
.globl vector166
vector166:
  pushl $0
  1027c5:	6a 00                	push   $0x0
  pushl $166
  1027c7:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  1027cc:	e9 2c 04 00 00       	jmp    102bfd <__alltraps>

001027d1 <vector167>:
.globl vector167
vector167:
  pushl $0
  1027d1:	6a 00                	push   $0x0
  pushl $167
  1027d3:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  1027d8:	e9 20 04 00 00       	jmp    102bfd <__alltraps>

001027dd <vector168>:
.globl vector168
vector168:
  pushl $0
  1027dd:	6a 00                	push   $0x0
  pushl $168
  1027df:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  1027e4:	e9 14 04 00 00       	jmp    102bfd <__alltraps>

001027e9 <vector169>:
.globl vector169
vector169:
  pushl $0
  1027e9:	6a 00                	push   $0x0
  pushl $169
  1027eb:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  1027f0:	e9 08 04 00 00       	jmp    102bfd <__alltraps>

001027f5 <vector170>:
.globl vector170
vector170:
  pushl $0
  1027f5:	6a 00                	push   $0x0
  pushl $170
  1027f7:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  1027fc:	e9 fc 03 00 00       	jmp    102bfd <__alltraps>

00102801 <vector171>:
.globl vector171
vector171:
  pushl $0
  102801:	6a 00                	push   $0x0
  pushl $171
  102803:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  102808:	e9 f0 03 00 00       	jmp    102bfd <__alltraps>

0010280d <vector172>:
.globl vector172
vector172:
  pushl $0
  10280d:	6a 00                	push   $0x0
  pushl $172
  10280f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102814:	e9 e4 03 00 00       	jmp    102bfd <__alltraps>

00102819 <vector173>:
.globl vector173
vector173:
  pushl $0
  102819:	6a 00                	push   $0x0
  pushl $173
  10281b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  102820:	e9 d8 03 00 00       	jmp    102bfd <__alltraps>

00102825 <vector174>:
.globl vector174
vector174:
  pushl $0
  102825:	6a 00                	push   $0x0
  pushl $174
  102827:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  10282c:	e9 cc 03 00 00       	jmp    102bfd <__alltraps>

00102831 <vector175>:
.globl vector175
vector175:
  pushl $0
  102831:	6a 00                	push   $0x0
  pushl $175
  102833:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  102838:	e9 c0 03 00 00       	jmp    102bfd <__alltraps>

0010283d <vector176>:
.globl vector176
vector176:
  pushl $0
  10283d:	6a 00                	push   $0x0
  pushl $176
  10283f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  102844:	e9 b4 03 00 00       	jmp    102bfd <__alltraps>

00102849 <vector177>:
.globl vector177
vector177:
  pushl $0
  102849:	6a 00                	push   $0x0
  pushl $177
  10284b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  102850:	e9 a8 03 00 00       	jmp    102bfd <__alltraps>

00102855 <vector178>:
.globl vector178
vector178:
  pushl $0
  102855:	6a 00                	push   $0x0
  pushl $178
  102857:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  10285c:	e9 9c 03 00 00       	jmp    102bfd <__alltraps>

00102861 <vector179>:
.globl vector179
vector179:
  pushl $0
  102861:	6a 00                	push   $0x0
  pushl $179
  102863:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  102868:	e9 90 03 00 00       	jmp    102bfd <__alltraps>

0010286d <vector180>:
.globl vector180
vector180:
  pushl $0
  10286d:	6a 00                	push   $0x0
  pushl $180
  10286f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  102874:	e9 84 03 00 00       	jmp    102bfd <__alltraps>

00102879 <vector181>:
.globl vector181
vector181:
  pushl $0
  102879:	6a 00                	push   $0x0
  pushl $181
  10287b:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102880:	e9 78 03 00 00       	jmp    102bfd <__alltraps>

00102885 <vector182>:
.globl vector182
vector182:
  pushl $0
  102885:	6a 00                	push   $0x0
  pushl $182
  102887:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10288c:	e9 6c 03 00 00       	jmp    102bfd <__alltraps>

00102891 <vector183>:
.globl vector183
vector183:
  pushl $0
  102891:	6a 00                	push   $0x0
  pushl $183
  102893:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  102898:	e9 60 03 00 00       	jmp    102bfd <__alltraps>

0010289d <vector184>:
.globl vector184
vector184:
  pushl $0
  10289d:	6a 00                	push   $0x0
  pushl $184
  10289f:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  1028a4:	e9 54 03 00 00       	jmp    102bfd <__alltraps>

001028a9 <vector185>:
.globl vector185
vector185:
  pushl $0
  1028a9:	6a 00                	push   $0x0
  pushl $185
  1028ab:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  1028b0:	e9 48 03 00 00       	jmp    102bfd <__alltraps>

001028b5 <vector186>:
.globl vector186
vector186:
  pushl $0
  1028b5:	6a 00                	push   $0x0
  pushl $186
  1028b7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  1028bc:	e9 3c 03 00 00       	jmp    102bfd <__alltraps>

001028c1 <vector187>:
.globl vector187
vector187:
  pushl $0
  1028c1:	6a 00                	push   $0x0
  pushl $187
  1028c3:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  1028c8:	e9 30 03 00 00       	jmp    102bfd <__alltraps>

001028cd <vector188>:
.globl vector188
vector188:
  pushl $0
  1028cd:	6a 00                	push   $0x0
  pushl $188
  1028cf:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  1028d4:	e9 24 03 00 00       	jmp    102bfd <__alltraps>

001028d9 <vector189>:
.globl vector189
vector189:
  pushl $0
  1028d9:	6a 00                	push   $0x0
  pushl $189
  1028db:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  1028e0:	e9 18 03 00 00       	jmp    102bfd <__alltraps>

001028e5 <vector190>:
.globl vector190
vector190:
  pushl $0
  1028e5:	6a 00                	push   $0x0
  pushl $190
  1028e7:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  1028ec:	e9 0c 03 00 00       	jmp    102bfd <__alltraps>

001028f1 <vector191>:
.globl vector191
vector191:
  pushl $0
  1028f1:	6a 00                	push   $0x0
  pushl $191
  1028f3:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  1028f8:	e9 00 03 00 00       	jmp    102bfd <__alltraps>

001028fd <vector192>:
.globl vector192
vector192:
  pushl $0
  1028fd:	6a 00                	push   $0x0
  pushl $192
  1028ff:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102904:	e9 f4 02 00 00       	jmp    102bfd <__alltraps>

00102909 <vector193>:
.globl vector193
vector193:
  pushl $0
  102909:	6a 00                	push   $0x0
  pushl $193
  10290b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102910:	e9 e8 02 00 00       	jmp    102bfd <__alltraps>

00102915 <vector194>:
.globl vector194
vector194:
  pushl $0
  102915:	6a 00                	push   $0x0
  pushl $194
  102917:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10291c:	e9 dc 02 00 00       	jmp    102bfd <__alltraps>

00102921 <vector195>:
.globl vector195
vector195:
  pushl $0
  102921:	6a 00                	push   $0x0
  pushl $195
  102923:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  102928:	e9 d0 02 00 00       	jmp    102bfd <__alltraps>

0010292d <vector196>:
.globl vector196
vector196:
  pushl $0
  10292d:	6a 00                	push   $0x0
  pushl $196
  10292f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  102934:	e9 c4 02 00 00       	jmp    102bfd <__alltraps>

00102939 <vector197>:
.globl vector197
vector197:
  pushl $0
  102939:	6a 00                	push   $0x0
  pushl $197
  10293b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  102940:	e9 b8 02 00 00       	jmp    102bfd <__alltraps>

00102945 <vector198>:
.globl vector198
vector198:
  pushl $0
  102945:	6a 00                	push   $0x0
  pushl $198
  102947:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  10294c:	e9 ac 02 00 00       	jmp    102bfd <__alltraps>

00102951 <vector199>:
.globl vector199
vector199:
  pushl $0
  102951:	6a 00                	push   $0x0
  pushl $199
  102953:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  102958:	e9 a0 02 00 00       	jmp    102bfd <__alltraps>

0010295d <vector200>:
.globl vector200
vector200:
  pushl $0
  10295d:	6a 00                	push   $0x0
  pushl $200
  10295f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  102964:	e9 94 02 00 00       	jmp    102bfd <__alltraps>

00102969 <vector201>:
.globl vector201
vector201:
  pushl $0
  102969:	6a 00                	push   $0x0
  pushl $201
  10296b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  102970:	e9 88 02 00 00       	jmp    102bfd <__alltraps>

00102975 <vector202>:
.globl vector202
vector202:
  pushl $0
  102975:	6a 00                	push   $0x0
  pushl $202
  102977:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  10297c:	e9 7c 02 00 00       	jmp    102bfd <__alltraps>

00102981 <vector203>:
.globl vector203
vector203:
  pushl $0
  102981:	6a 00                	push   $0x0
  pushl $203
  102983:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  102988:	e9 70 02 00 00       	jmp    102bfd <__alltraps>

0010298d <vector204>:
.globl vector204
vector204:
  pushl $0
  10298d:	6a 00                	push   $0x0
  pushl $204
  10298f:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102994:	e9 64 02 00 00       	jmp    102bfd <__alltraps>

00102999 <vector205>:
.globl vector205
vector205:
  pushl $0
  102999:	6a 00                	push   $0x0
  pushl $205
  10299b:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  1029a0:	e9 58 02 00 00       	jmp    102bfd <__alltraps>

001029a5 <vector206>:
.globl vector206
vector206:
  pushl $0
  1029a5:	6a 00                	push   $0x0
  pushl $206
  1029a7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  1029ac:	e9 4c 02 00 00       	jmp    102bfd <__alltraps>

001029b1 <vector207>:
.globl vector207
vector207:
  pushl $0
  1029b1:	6a 00                	push   $0x0
  pushl $207
  1029b3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  1029b8:	e9 40 02 00 00       	jmp    102bfd <__alltraps>

001029bd <vector208>:
.globl vector208
vector208:
  pushl $0
  1029bd:	6a 00                	push   $0x0
  pushl $208
  1029bf:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  1029c4:	e9 34 02 00 00       	jmp    102bfd <__alltraps>

001029c9 <vector209>:
.globl vector209
vector209:
  pushl $0
  1029c9:	6a 00                	push   $0x0
  pushl $209
  1029cb:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  1029d0:	e9 28 02 00 00       	jmp    102bfd <__alltraps>

001029d5 <vector210>:
.globl vector210
vector210:
  pushl $0
  1029d5:	6a 00                	push   $0x0
  pushl $210
  1029d7:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  1029dc:	e9 1c 02 00 00       	jmp    102bfd <__alltraps>

001029e1 <vector211>:
.globl vector211
vector211:
  pushl $0
  1029e1:	6a 00                	push   $0x0
  pushl $211
  1029e3:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  1029e8:	e9 10 02 00 00       	jmp    102bfd <__alltraps>

001029ed <vector212>:
.globl vector212
vector212:
  pushl $0
  1029ed:	6a 00                	push   $0x0
  pushl $212
  1029ef:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  1029f4:	e9 04 02 00 00       	jmp    102bfd <__alltraps>

001029f9 <vector213>:
.globl vector213
vector213:
  pushl $0
  1029f9:	6a 00                	push   $0x0
  pushl $213
  1029fb:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102a00:	e9 f8 01 00 00       	jmp    102bfd <__alltraps>

00102a05 <vector214>:
.globl vector214
vector214:
  pushl $0
  102a05:	6a 00                	push   $0x0
  pushl $214
  102a07:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  102a0c:	e9 ec 01 00 00       	jmp    102bfd <__alltraps>

00102a11 <vector215>:
.globl vector215
vector215:
  pushl $0
  102a11:	6a 00                	push   $0x0
  pushl $215
  102a13:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  102a18:	e9 e0 01 00 00       	jmp    102bfd <__alltraps>

00102a1d <vector216>:
.globl vector216
vector216:
  pushl $0
  102a1d:	6a 00                	push   $0x0
  pushl $216
  102a1f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  102a24:	e9 d4 01 00 00       	jmp    102bfd <__alltraps>

00102a29 <vector217>:
.globl vector217
vector217:
  pushl $0
  102a29:	6a 00                	push   $0x0
  pushl $217
  102a2b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  102a30:	e9 c8 01 00 00       	jmp    102bfd <__alltraps>

00102a35 <vector218>:
.globl vector218
vector218:
  pushl $0
  102a35:	6a 00                	push   $0x0
  pushl $218
  102a37:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  102a3c:	e9 bc 01 00 00       	jmp    102bfd <__alltraps>

00102a41 <vector219>:
.globl vector219
vector219:
  pushl $0
  102a41:	6a 00                	push   $0x0
  pushl $219
  102a43:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  102a48:	e9 b0 01 00 00       	jmp    102bfd <__alltraps>

00102a4d <vector220>:
.globl vector220
vector220:
  pushl $0
  102a4d:	6a 00                	push   $0x0
  pushl $220
  102a4f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  102a54:	e9 a4 01 00 00       	jmp    102bfd <__alltraps>

00102a59 <vector221>:
.globl vector221
vector221:
  pushl $0
  102a59:	6a 00                	push   $0x0
  pushl $221
  102a5b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  102a60:	e9 98 01 00 00       	jmp    102bfd <__alltraps>

00102a65 <vector222>:
.globl vector222
vector222:
  pushl $0
  102a65:	6a 00                	push   $0x0
  pushl $222
  102a67:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  102a6c:	e9 8c 01 00 00       	jmp    102bfd <__alltraps>

00102a71 <vector223>:
.globl vector223
vector223:
  pushl $0
  102a71:	6a 00                	push   $0x0
  pushl $223
  102a73:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  102a78:	e9 80 01 00 00       	jmp    102bfd <__alltraps>

00102a7d <vector224>:
.globl vector224
vector224:
  pushl $0
  102a7d:	6a 00                	push   $0x0
  pushl $224
  102a7f:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102a84:	e9 74 01 00 00       	jmp    102bfd <__alltraps>

00102a89 <vector225>:
.globl vector225
vector225:
  pushl $0
  102a89:	6a 00                	push   $0x0
  pushl $225
  102a8b:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102a90:	e9 68 01 00 00       	jmp    102bfd <__alltraps>

00102a95 <vector226>:
.globl vector226
vector226:
  pushl $0
  102a95:	6a 00                	push   $0x0
  pushl $226
  102a97:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  102a9c:	e9 5c 01 00 00       	jmp    102bfd <__alltraps>

00102aa1 <vector227>:
.globl vector227
vector227:
  pushl $0
  102aa1:	6a 00                	push   $0x0
  pushl $227
  102aa3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  102aa8:	e9 50 01 00 00       	jmp    102bfd <__alltraps>

00102aad <vector228>:
.globl vector228
vector228:
  pushl $0
  102aad:	6a 00                	push   $0x0
  pushl $228
  102aaf:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102ab4:	e9 44 01 00 00       	jmp    102bfd <__alltraps>

00102ab9 <vector229>:
.globl vector229
vector229:
  pushl $0
  102ab9:	6a 00                	push   $0x0
  pushl $229
  102abb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102ac0:	e9 38 01 00 00       	jmp    102bfd <__alltraps>

00102ac5 <vector230>:
.globl vector230
vector230:
  pushl $0
  102ac5:	6a 00                	push   $0x0
  pushl $230
  102ac7:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  102acc:	e9 2c 01 00 00       	jmp    102bfd <__alltraps>

00102ad1 <vector231>:
.globl vector231
vector231:
  pushl $0
  102ad1:	6a 00                	push   $0x0
  pushl $231
  102ad3:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  102ad8:	e9 20 01 00 00       	jmp    102bfd <__alltraps>

00102add <vector232>:
.globl vector232
vector232:
  pushl $0
  102add:	6a 00                	push   $0x0
  pushl $232
  102adf:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102ae4:	e9 14 01 00 00       	jmp    102bfd <__alltraps>

00102ae9 <vector233>:
.globl vector233
vector233:
  pushl $0
  102ae9:	6a 00                	push   $0x0
  pushl $233
  102aeb:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102af0:	e9 08 01 00 00       	jmp    102bfd <__alltraps>

00102af5 <vector234>:
.globl vector234
vector234:
  pushl $0
  102af5:	6a 00                	push   $0x0
  pushl $234
  102af7:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  102afc:	e9 fc 00 00 00       	jmp    102bfd <__alltraps>

00102b01 <vector235>:
.globl vector235
vector235:
  pushl $0
  102b01:	6a 00                	push   $0x0
  pushl $235
  102b03:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  102b08:	e9 f0 00 00 00       	jmp    102bfd <__alltraps>

00102b0d <vector236>:
.globl vector236
vector236:
  pushl $0
  102b0d:	6a 00                	push   $0x0
  pushl $236
  102b0f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102b14:	e9 e4 00 00 00       	jmp    102bfd <__alltraps>

00102b19 <vector237>:
.globl vector237
vector237:
  pushl $0
  102b19:	6a 00                	push   $0x0
  pushl $237
  102b1b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  102b20:	e9 d8 00 00 00       	jmp    102bfd <__alltraps>

00102b25 <vector238>:
.globl vector238
vector238:
  pushl $0
  102b25:	6a 00                	push   $0x0
  pushl $238
  102b27:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  102b2c:	e9 cc 00 00 00       	jmp    102bfd <__alltraps>

00102b31 <vector239>:
.globl vector239
vector239:
  pushl $0
  102b31:	6a 00                	push   $0x0
  pushl $239
  102b33:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  102b38:	e9 c0 00 00 00       	jmp    102bfd <__alltraps>

00102b3d <vector240>:
.globl vector240
vector240:
  pushl $0
  102b3d:	6a 00                	push   $0x0
  pushl $240
  102b3f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  102b44:	e9 b4 00 00 00       	jmp    102bfd <__alltraps>

00102b49 <vector241>:
.globl vector241
vector241:
  pushl $0
  102b49:	6a 00                	push   $0x0
  pushl $241
  102b4b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  102b50:	e9 a8 00 00 00       	jmp    102bfd <__alltraps>

00102b55 <vector242>:
.globl vector242
vector242:
  pushl $0
  102b55:	6a 00                	push   $0x0
  pushl $242
  102b57:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  102b5c:	e9 9c 00 00 00       	jmp    102bfd <__alltraps>

00102b61 <vector243>:
.globl vector243
vector243:
  pushl $0
  102b61:	6a 00                	push   $0x0
  pushl $243
  102b63:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  102b68:	e9 90 00 00 00       	jmp    102bfd <__alltraps>

00102b6d <vector244>:
.globl vector244
vector244:
  pushl $0
  102b6d:	6a 00                	push   $0x0
  pushl $244
  102b6f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  102b74:	e9 84 00 00 00       	jmp    102bfd <__alltraps>

00102b79 <vector245>:
.globl vector245
vector245:
  pushl $0
  102b79:	6a 00                	push   $0x0
  pushl $245
  102b7b:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102b80:	e9 78 00 00 00       	jmp    102bfd <__alltraps>

00102b85 <vector246>:
.globl vector246
vector246:
  pushl $0
  102b85:	6a 00                	push   $0x0
  pushl $246
  102b87:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102b8c:	e9 6c 00 00 00       	jmp    102bfd <__alltraps>

00102b91 <vector247>:
.globl vector247
vector247:
  pushl $0
  102b91:	6a 00                	push   $0x0
  pushl $247
  102b93:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102b98:	e9 60 00 00 00       	jmp    102bfd <__alltraps>

00102b9d <vector248>:
.globl vector248
vector248:
  pushl $0
  102b9d:	6a 00                	push   $0x0
  pushl $248
  102b9f:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102ba4:	e9 54 00 00 00       	jmp    102bfd <__alltraps>

00102ba9 <vector249>:
.globl vector249
vector249:
  pushl $0
  102ba9:	6a 00                	push   $0x0
  pushl $249
  102bab:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102bb0:	e9 48 00 00 00       	jmp    102bfd <__alltraps>

00102bb5 <vector250>:
.globl vector250
vector250:
  pushl $0
  102bb5:	6a 00                	push   $0x0
  pushl $250
  102bb7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102bbc:	e9 3c 00 00 00       	jmp    102bfd <__alltraps>

00102bc1 <vector251>:
.globl vector251
vector251:
  pushl $0
  102bc1:	6a 00                	push   $0x0
  pushl $251
  102bc3:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102bc8:	e9 30 00 00 00       	jmp    102bfd <__alltraps>

00102bcd <vector252>:
.globl vector252
vector252:
  pushl $0
  102bcd:	6a 00                	push   $0x0
  pushl $252
  102bcf:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102bd4:	e9 24 00 00 00       	jmp    102bfd <__alltraps>

00102bd9 <vector253>:
.globl vector253
vector253:
  pushl $0
  102bd9:	6a 00                	push   $0x0
  pushl $253
  102bdb:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102be0:	e9 18 00 00 00       	jmp    102bfd <__alltraps>

00102be5 <vector254>:
.globl vector254
vector254:
  pushl $0
  102be5:	6a 00                	push   $0x0
  pushl $254
  102be7:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102bec:	e9 0c 00 00 00       	jmp    102bfd <__alltraps>

00102bf1 <vector255>:
.globl vector255
vector255:
  pushl $0
  102bf1:	6a 00                	push   $0x0
  pushl $255
  102bf3:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102bf8:	e9 00 00 00 00       	jmp    102bfd <__alltraps>

00102bfd <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  102bfd:	1e                   	push   %ds
    pushl %es
  102bfe:	06                   	push   %es
    pushl %fs
  102bff:	0f a0                	push   %fs
    pushl %gs
  102c01:	0f a8                	push   %gs
    pushal
  102c03:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  102c04:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  102c09:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  102c0b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  102c0d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  102c0e:	e8 64 f5 ff ff       	call   102177 <trap>

    # pop the pushed stack pointer
    popl %esp
  102c13:	5c                   	pop    %esp

00102c14 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102c14:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102c15:	0f a9                	pop    %gs
    popl %fs
  102c17:	0f a1                	pop    %fs
    popl %es
  102c19:	07                   	pop    %es
    popl %ds
  102c1a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  102c1b:	83 c4 08             	add    $0x8,%esp
    iret
  102c1e:	cf                   	iret   

00102c1f <__move_down_stack2>:

.globl __move_down_stack2 
# this function aims to move down the whole stack frame by 2 bytes so that we can insert our fake esp and ss into the trapframe
__move_down_stack2:
    pushl %ebp
  102c1f:	55                   	push   %ebp
    movl %esp, %ebp
  102c20:	89 e5                	mov    %esp,%ebp

    pushl %ebx
  102c22:	53                   	push   %ebx
    pushl %esi
  102c23:	56                   	push   %esi
    pushl %edi
  102c24:	57                   	push   %edi

    movl 8(%ebp), %ebx # ebx store the end (higher boundary) of current trapframe
  102c25:	8b 5d 08             	mov    0x8(%ebp),%ebx
    movl 12(%ebp), %edi
  102c28:	8b 7d 0c             	mov    0xc(%ebp),%edi
    subl $8, -4(%edi) # fix esp which __alltraps store on stack
  102c2b:	83 6f fc 08          	subl   $0x8,-0x4(%edi)
    movl %esp, %eax
  102c2f:	89 e0                	mov    %esp,%eax

    cmpl %eax, %ebx
  102c31:	39 c3                	cmp    %eax,%ebx
    jle loop_end
  102c33:	7e 0c                	jle    102c41 <loop_end>

00102c35 <loop_start>:

loop_start:
    movb (%eax), %cl
  102c35:	8a 08                	mov    (%eax),%cl
    movb %cl, -8(%eax)
  102c37:	88 48 f8             	mov    %cl,-0x8(%eax)
    addl $1, %eax
  102c3a:	83 c0 01             	add    $0x1,%eax
    cmpl %eax, %ebx
  102c3d:	39 c3                	cmp    %eax,%ebx
    jg loop_start
  102c3f:	7f f4                	jg     102c35 <loop_start>

00102c41 <loop_end>:

loop_end: 
    subl $8, %esp 
  102c41:	83 ec 08             	sub    $0x8,%esp
    subl $8, %ebp # remember, it is critical to correct all the base pointer store in stack area which is affected by our operations above
  102c44:	83 ed 08             	sub    $0x8,%ebp
    
    movl %ebp, %eax
  102c47:	89 e8                	mov    %ebp,%eax
    cmpl %eax, %ebx
  102c49:	39 c3                	cmp    %eax,%ebx
    jle ebp_loop_end
  102c4b:	7e 14                	jle    102c61 <ebp_loop_end>

00102c4d <ebp_loop_begin>:

ebp_loop_begin:
    movl (%eax), %ecx
  102c4d:	8b 08                	mov    (%eax),%ecx

    cmpl $0, %ecx
  102c4f:	83 f9 00             	cmp    $0x0,%ecx
    je ebp_loop_end
  102c52:	74 0d                	je     102c61 <ebp_loop_end>
    cmpl %ecx, %ebx
  102c54:	39 cb                	cmp    %ecx,%ebx
    jle ebp_loop_end
  102c56:	7e 09                	jle    102c61 <ebp_loop_end>
    subl $8, %ecx
  102c58:	83 e9 08             	sub    $0x8,%ecx
    movl %ecx, (%eax)
  102c5b:	89 08                	mov    %ecx,(%eax)
    movl %ecx, %eax
  102c5d:	89 c8                	mov    %ecx,%eax
    jmp ebp_loop_begin
  102c5f:	eb ec                	jmp    102c4d <ebp_loop_begin>

00102c61 <ebp_loop_end>:

ebp_loop_end:

    popl %edi
  102c61:	5f                   	pop    %edi
    popl %esi
  102c62:	5e                   	pop    %esi
    popl %ebx
  102c63:	5b                   	pop    %ebx

    popl %ebp
  102c64:	5d                   	pop    %ebp
    ret 
  102c65:	c3                   	ret    

00102c66 <__move_up_stack2>:
# this function aims to move the trapframe along with all stack frames below up by 2 bytes
# arg1 tf_end 
# arg2 tf
# arg3 user esp
__move_up_stack2:
    pushl %ebp 
  102c66:	55                   	push   %ebp
    movl %esp, %ebp
  102c67:	89 e5                	mov    %esp,%ebp

    pushl %ebx
  102c69:	53                   	push   %ebx
    pushl %edi
  102c6a:	57                   	push   %edi
    pushl %esi
  102c6b:	56                   	push   %esi

# first of all, copy every below tf_end to user stack
    movl 8(%ebp), %eax
  102c6c:	8b 45 08             	mov    0x8(%ebp),%eax
    subl $1, %eax
  102c6f:	83 e8 01             	sub    $0x1,%eax
    movl 16(%ebp), %ebx # ebx store the user stack pointer 
  102c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
    
    cmpl %eax, %esp
  102c75:	39 c4                	cmp    %eax,%esp
    jg copy_loop_end
  102c77:	7f 0e                	jg     102c87 <copy_loop_end>

00102c79 <copy_loop_begin>:

copy_loop_begin:
    subl $1, %ebx
  102c79:	83 eb 01             	sub    $0x1,%ebx
    movb (%eax), %cl
  102c7c:	8a 08                	mov    (%eax),%cl
    movb %cl, (%ebx)
  102c7e:	88 0b                	mov    %cl,(%ebx)

    subl $1, %eax
  102c80:	83 e8 01             	sub    $0x1,%eax
    cmpl %eax, %esp
  102c83:	39 c4                	cmp    %eax,%esp
    jle copy_loop_begin
  102c85:	7e f2                	jle    102c79 <copy_loop_begin>

00102c87 <copy_loop_end>:

copy_loop_end:

# now we have to fix all ebp on user stack, note that we can calculate the true ebp using their address displacement
    movl %ebp, %eax
  102c87:	89 e8                	mov    %ebp,%eax
    cmpl %eax, 8(%ebp)
  102c89:	39 45 08             	cmp    %eax,0x8(%ebp)
    jle fix_ebp_loop_end
  102c8c:	7e 20                	jle    102cae <fix_ebp_loop_end>

00102c8e <fix_ebp_loop_begin>:

fix_ebp_loop_begin:
    movl %eax, %edi
  102c8e:	89 c7                	mov    %eax,%edi
    subl 8(%ebp), %edi
  102c90:	2b 7d 08             	sub    0x8(%ebp),%edi
    addl 16(%ebp), %edi # edi <=> eax
  102c93:	03 7d 10             	add    0x10(%ebp),%edi

    cmpl (%eax), %esp 
  102c96:	3b 20                	cmp    (%eax),%esp
    jle normal_condition
  102c98:	7e 06                	jle    102ca0 <normal_condition>
    movl (%eax), %esi
  102c9a:	8b 30                	mov    (%eax),%esi
    movl %esi, (%edi)
  102c9c:	89 37                	mov    %esi,(%edi)
    jmp fix_ebp_loop_end
  102c9e:	eb 0e                	jmp    102cae <fix_ebp_loop_end>

00102ca0 <normal_condition>:

normal_condition:
    movl (%eax), %esi
  102ca0:	8b 30                	mov    (%eax),%esi
    subl 8(%ebp), %esi
  102ca2:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
  102ca5:	03 75 10             	add    0x10(%ebp),%esi
    movl %esi, (%edi)
  102ca8:	89 37                	mov    %esi,(%edi)
    movl (%eax), %eax
  102caa:	8b 00                	mov    (%eax),%eax
    jmp fix_ebp_loop_begin
  102cac:	eb e0                	jmp    102c8e <fix_ebp_loop_begin>

00102cae <fix_ebp_loop_end>:

fix_ebp_loop_end:

# fix the esp which __alltraps store on stack
    movl 12(%ebp), %eax
  102cae:	8b 45 0c             	mov    0xc(%ebp),%eax
    subl $4, %eax
  102cb1:	83 e8 04             	sub    $0x4,%eax

    movl %eax, %edi
  102cb4:	89 c7                	mov    %eax,%edi
    subl 8(%ebp), %edi
  102cb6:	2b 7d 08             	sub    0x8(%ebp),%edi
    addl 16(%ebp), %edi
  102cb9:	03 7d 10             	add    0x10(%ebp),%edi

    movl (%eax), %esi
  102cbc:	8b 30                	mov    (%eax),%esi
    subl 8(%ebp), %esi
  102cbe:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
  102cc1:	03 75 10             	add    0x10(%ebp),%esi

    movl %esi, (%edi)
  102cc4:	89 37                	mov    %esi,(%edi)

    movl 12(%ebp), %eax
  102cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
    subl 8(%ebp), %eax
  102cc9:	2b 45 08             	sub    0x8(%ebp),%eax
    addl 16(%ebp), %eax
  102ccc:	03 45 10             	add    0x10(%ebp),%eax

# switch to user stack
    movl %ebx, %esp
  102ccf:	89 dc                	mov    %ebx,%esp
    movl %ebp, %esi
  102cd1:	89 ee                	mov    %ebp,%esi
    subl 8(%ebp), %esi
  102cd3:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
  102cd6:	03 75 10             	add    0x10(%ebp),%esi
    movl %esi, %ebp
  102cd9:	89 f5                	mov    %esi,%ebp

    popl %esi
  102cdb:	5e                   	pop    %esi
    popl %edi
  102cdc:	5f                   	pop    %edi
    popl %ebx
  102cdd:	5b                   	pop    %ebx

    popl %ebp
  102cde:	5d                   	pop    %ebp
  102cdf:	c3                   	ret    

00102ce0 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102ce0:	55                   	push   %ebp
  102ce1:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
  102ce6:	8b 15 98 bf 11 00    	mov    0x11bf98,%edx
  102cec:	29 d0                	sub    %edx,%eax
  102cee:	c1 f8 02             	sar    $0x2,%eax
  102cf1:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102cf7:	5d                   	pop    %ebp
  102cf8:	c3                   	ret    

00102cf9 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102cf9:	55                   	push   %ebp
  102cfa:	89 e5                	mov    %esp,%ebp
  102cfc:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102cff:	8b 45 08             	mov    0x8(%ebp),%eax
  102d02:	89 04 24             	mov    %eax,(%esp)
  102d05:	e8 d6 ff ff ff       	call   102ce0 <page2ppn>
  102d0a:	c1 e0 0c             	shl    $0xc,%eax
}
  102d0d:	c9                   	leave  
  102d0e:	c3                   	ret    

00102d0f <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
  102d0f:	55                   	push   %ebp
  102d10:	89 e5                	mov    %esp,%ebp
  102d12:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  102d15:	8b 45 08             	mov    0x8(%ebp),%eax
  102d18:	c1 e8 0c             	shr    $0xc,%eax
  102d1b:	89 c2                	mov    %eax,%edx
  102d1d:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  102d22:	39 c2                	cmp    %eax,%edx
  102d24:	72 1c                	jb     102d42 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  102d26:	c7 44 24 08 b0 6b 10 	movl   $0x106bb0,0x8(%esp)
  102d2d:	00 
  102d2e:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  102d35:	00 
  102d36:	c7 04 24 cf 6b 10 00 	movl   $0x106bcf,(%esp)
  102d3d:	e8 b2 d6 ff ff       	call   1003f4 <__panic>
    }
    return &pages[PPN(pa)];
  102d42:	8b 0d 98 bf 11 00    	mov    0x11bf98,%ecx
  102d48:	8b 45 08             	mov    0x8(%ebp),%eax
  102d4b:	c1 e8 0c             	shr    $0xc,%eax
  102d4e:	89 c2                	mov    %eax,%edx
  102d50:	89 d0                	mov    %edx,%eax
  102d52:	c1 e0 02             	shl    $0x2,%eax
  102d55:	01 d0                	add    %edx,%eax
  102d57:	c1 e0 02             	shl    $0x2,%eax
  102d5a:	01 c8                	add    %ecx,%eax
}
  102d5c:	c9                   	leave  
  102d5d:	c3                   	ret    

00102d5e <page2kva>:

static inline void *
page2kva(struct Page *page) {
  102d5e:	55                   	push   %ebp
  102d5f:	89 e5                	mov    %esp,%ebp
  102d61:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  102d64:	8b 45 08             	mov    0x8(%ebp),%eax
  102d67:	89 04 24             	mov    %eax,(%esp)
  102d6a:	e8 8a ff ff ff       	call   102cf9 <page2pa>
  102d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d75:	c1 e8 0c             	shr    $0xc,%eax
  102d78:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102d7b:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  102d80:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  102d83:	72 23                	jb     102da8 <page2kva+0x4a>
  102d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d88:	89 44 24 0c          	mov    %eax,0xc(%esp)
  102d8c:	c7 44 24 08 e0 6b 10 	movl   $0x106be0,0x8(%esp)
  102d93:	00 
  102d94:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  102d9b:	00 
  102d9c:	c7 04 24 cf 6b 10 00 	movl   $0x106bcf,(%esp)
  102da3:	e8 4c d6 ff ff       	call   1003f4 <__panic>
  102da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dab:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  102db0:	c9                   	leave  
  102db1:	c3                   	ret    

00102db2 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
  102db2:	55                   	push   %ebp
  102db3:	89 e5                	mov    %esp,%ebp
  102db5:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  102db8:	8b 45 08             	mov    0x8(%ebp),%eax
  102dbb:	83 e0 01             	and    $0x1,%eax
  102dbe:	85 c0                	test   %eax,%eax
  102dc0:	75 1c                	jne    102dde <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  102dc2:	c7 44 24 08 04 6c 10 	movl   $0x106c04,0x8(%esp)
  102dc9:	00 
  102dca:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  102dd1:	00 
  102dd2:	c7 04 24 cf 6b 10 00 	movl   $0x106bcf,(%esp)
  102dd9:	e8 16 d6 ff ff       	call   1003f4 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
  102dde:	8b 45 08             	mov    0x8(%ebp),%eax
  102de1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102de6:	89 04 24             	mov    %eax,(%esp)
  102de9:	e8 21 ff ff ff       	call   102d0f <pa2page>
}
  102dee:	c9                   	leave  
  102def:	c3                   	ret    

00102df0 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
  102df0:	55                   	push   %ebp
  102df1:	89 e5                	mov    %esp,%ebp
  102df3:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  102df6:	8b 45 08             	mov    0x8(%ebp),%eax
  102df9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  102dfe:	89 04 24             	mov    %eax,(%esp)
  102e01:	e8 09 ff ff ff       	call   102d0f <pa2page>
}
  102e06:	c9                   	leave  
  102e07:	c3                   	ret    

00102e08 <page_ref>:

static inline int
page_ref(struct Page *page) {
  102e08:	55                   	push   %ebp
  102e09:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  102e0e:	8b 00                	mov    (%eax),%eax
}
  102e10:	5d                   	pop    %ebp
  102e11:	c3                   	ret    

00102e12 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102e12:	55                   	push   %ebp
  102e13:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102e15:	8b 45 08             	mov    0x8(%ebp),%eax
  102e18:	8b 55 0c             	mov    0xc(%ebp),%edx
  102e1b:	89 10                	mov    %edx,(%eax)
}
  102e1d:	90                   	nop
  102e1e:	5d                   	pop    %ebp
  102e1f:	c3                   	ret    

00102e20 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  102e20:	55                   	push   %ebp
  102e21:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  102e23:	8b 45 08             	mov    0x8(%ebp),%eax
  102e26:	8b 00                	mov    (%eax),%eax
  102e28:	8d 50 01             	lea    0x1(%eax),%edx
  102e2b:	8b 45 08             	mov    0x8(%ebp),%eax
  102e2e:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102e30:	8b 45 08             	mov    0x8(%ebp),%eax
  102e33:	8b 00                	mov    (%eax),%eax
}
  102e35:	5d                   	pop    %ebp
  102e36:	c3                   	ret    

00102e37 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  102e37:	55                   	push   %ebp
  102e38:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  102e3a:	8b 45 08             	mov    0x8(%ebp),%eax
  102e3d:	8b 00                	mov    (%eax),%eax
  102e3f:	8d 50 ff             	lea    -0x1(%eax),%edx
  102e42:	8b 45 08             	mov    0x8(%ebp),%eax
  102e45:	89 10                	mov    %edx,(%eax)
    return page->ref;
  102e47:	8b 45 08             	mov    0x8(%ebp),%eax
  102e4a:	8b 00                	mov    (%eax),%eax
}
  102e4c:	5d                   	pop    %ebp
  102e4d:	c3                   	ret    

00102e4e <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  102e4e:	55                   	push   %ebp
  102e4f:	89 e5                	mov    %esp,%ebp
  102e51:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  102e54:	9c                   	pushf  
  102e55:	58                   	pop    %eax
  102e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  102e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  102e5c:	25 00 02 00 00       	and    $0x200,%eax
  102e61:	85 c0                	test   %eax,%eax
  102e63:	74 0c                	je     102e71 <__intr_save+0x23>
        intr_disable();
  102e65:	e8 31 ea ff ff       	call   10189b <intr_disable>
        return 1;
  102e6a:	b8 01 00 00 00       	mov    $0x1,%eax
  102e6f:	eb 05                	jmp    102e76 <__intr_save+0x28>
    }
    return 0;
  102e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
  102e76:	c9                   	leave  
  102e77:	c3                   	ret    

00102e78 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  102e78:	55                   	push   %ebp
  102e79:	89 e5                	mov    %esp,%ebp
  102e7b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  102e7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102e82:	74 05                	je     102e89 <__intr_restore+0x11>
        intr_enable();
  102e84:	e8 0b ea ff ff       	call   101894 <intr_enable>
    }
}
  102e89:	90                   	nop
  102e8a:	c9                   	leave  
  102e8b:	c3                   	ret    

00102e8c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  102e8c:	55                   	push   %ebp
  102e8d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  102e8f:	8b 45 08             	mov    0x8(%ebp),%eax
  102e92:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  102e95:	b8 23 00 00 00       	mov    $0x23,%eax
  102e9a:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  102e9c:	b8 23 00 00 00       	mov    $0x23,%eax
  102ea1:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  102ea3:	b8 10 00 00 00       	mov    $0x10,%eax
  102ea8:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  102eaa:	b8 10 00 00 00       	mov    $0x10,%eax
  102eaf:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  102eb1:	b8 10 00 00 00       	mov    $0x10,%eax
  102eb6:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  102eb8:	ea bf 2e 10 00 08 00 	ljmp   $0x8,$0x102ebf
}
  102ebf:	90                   	nop
  102ec0:	5d                   	pop    %ebp
  102ec1:	c3                   	ret    

00102ec2 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  102ec2:	55                   	push   %ebp
  102ec3:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  102ec5:	8b 45 08             	mov    0x8(%ebp),%eax
  102ec8:	a3 c4 be 11 00       	mov    %eax,0x11bec4
}
  102ecd:	90                   	nop
  102ece:	5d                   	pop    %ebp
  102ecf:	c3                   	ret    

00102ed0 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  102ed0:	55                   	push   %ebp
  102ed1:	89 e5                	mov    %esp,%ebp
  102ed3:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  102ed6:	b8 00 80 11 00       	mov    $0x118000,%eax
  102edb:	89 04 24             	mov    %eax,(%esp)
  102ede:	e8 df ff ff ff       	call   102ec2 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  102ee3:	66 c7 05 c8 be 11 00 	movw   $0x10,0x11bec8
  102eea:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  102eec:	66 c7 05 28 8a 11 00 	movw   $0x68,0x118a28
  102ef3:	68 00 
  102ef5:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  102efa:	0f b7 c0             	movzwl %ax,%eax
  102efd:	66 a3 2a 8a 11 00    	mov    %ax,0x118a2a
  102f03:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  102f08:	c1 e8 10             	shr    $0x10,%eax
  102f0b:	a2 2c 8a 11 00       	mov    %al,0x118a2c
  102f10:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102f17:	24 f0                	and    $0xf0,%al
  102f19:	0c 09                	or     $0x9,%al
  102f1b:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102f20:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102f27:	24 ef                	and    $0xef,%al
  102f29:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102f2e:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102f35:	24 9f                	and    $0x9f,%al
  102f37:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102f3c:	0f b6 05 2d 8a 11 00 	movzbl 0x118a2d,%eax
  102f43:	0c 80                	or     $0x80,%al
  102f45:	a2 2d 8a 11 00       	mov    %al,0x118a2d
  102f4a:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102f51:	24 f0                	and    $0xf0,%al
  102f53:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102f58:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102f5f:	24 ef                	and    $0xef,%al
  102f61:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102f66:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102f6d:	24 df                	and    $0xdf,%al
  102f6f:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102f74:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102f7b:	0c 40                	or     $0x40,%al
  102f7d:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102f82:	0f b6 05 2e 8a 11 00 	movzbl 0x118a2e,%eax
  102f89:	24 7f                	and    $0x7f,%al
  102f8b:	a2 2e 8a 11 00       	mov    %al,0x118a2e
  102f90:	b8 c0 be 11 00       	mov    $0x11bec0,%eax
  102f95:	c1 e8 18             	shr    $0x18,%eax
  102f98:	a2 2f 8a 11 00       	mov    %al,0x118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  102f9d:	c7 04 24 30 8a 11 00 	movl   $0x118a30,(%esp)
  102fa4:	e8 e3 fe ff ff       	call   102e8c <lgdt>
  102fa9:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  102faf:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  102fb3:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
  102fb6:	90                   	nop
  102fb7:	c9                   	leave  
  102fb8:	c3                   	ret    

00102fb9 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  102fb9:	55                   	push   %ebp
  102fba:	89 e5                	mov    %esp,%ebp
  102fbc:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  102fbf:	c7 05 90 bf 11 00 20 	movl   $0x107620,0x11bf90
  102fc6:	76 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  102fc9:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  102fce:	8b 00                	mov    (%eax),%eax
  102fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
  102fd4:	c7 04 24 30 6c 10 00 	movl   $0x106c30,(%esp)
  102fdb:	e8 bd d2 ff ff       	call   10029d <cprintf>
    pmm_manager->init();
  102fe0:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  102fe5:	8b 40 04             	mov    0x4(%eax),%eax
  102fe8:	ff d0                	call   *%eax
}
  102fea:	90                   	nop
  102feb:	c9                   	leave  
  102fec:	c3                   	ret    

00102fed <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  102fed:	55                   	push   %ebp
  102fee:	89 e5                	mov    %esp,%ebp
  102ff0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  102ff3:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  102ff8:	8b 40 08             	mov    0x8(%eax),%eax
  102ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ffe:	89 54 24 04          	mov    %edx,0x4(%esp)
  103002:	8b 55 08             	mov    0x8(%ebp),%edx
  103005:	89 14 24             	mov    %edx,(%esp)
  103008:	ff d0                	call   *%eax
}
  10300a:	90                   	nop
  10300b:	c9                   	leave  
  10300c:	c3                   	ret    

0010300d <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  10300d:	55                   	push   %ebp
  10300e:	89 e5                	mov    %esp,%ebp
  103010:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  103013:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10301a:	e8 2f fe ff ff       	call   102e4e <__intr_save>
  10301f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  103022:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  103027:	8b 40 0c             	mov    0xc(%eax),%eax
  10302a:	8b 55 08             	mov    0x8(%ebp),%edx
  10302d:	89 14 24             	mov    %edx,(%esp)
  103030:	ff d0                	call   *%eax
  103032:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  103035:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103038:	89 04 24             	mov    %eax,(%esp)
  10303b:	e8 38 fe ff ff       	call   102e78 <__intr_restore>
    return page;
  103040:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  103043:	c9                   	leave  
  103044:	c3                   	ret    

00103045 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  103045:	55                   	push   %ebp
  103046:	89 e5                	mov    %esp,%ebp
  103048:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10304b:	e8 fe fd ff ff       	call   102e4e <__intr_save>
  103050:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  103053:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  103058:	8b 40 10             	mov    0x10(%eax),%eax
  10305b:	8b 55 0c             	mov    0xc(%ebp),%edx
  10305e:	89 54 24 04          	mov    %edx,0x4(%esp)
  103062:	8b 55 08             	mov    0x8(%ebp),%edx
  103065:	89 14 24             	mov    %edx,(%esp)
  103068:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  10306a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10306d:	89 04 24             	mov    %eax,(%esp)
  103070:	e8 03 fe ff ff       	call   102e78 <__intr_restore>
}
  103075:	90                   	nop
  103076:	c9                   	leave  
  103077:	c3                   	ret    

00103078 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  103078:	55                   	push   %ebp
  103079:	89 e5                	mov    %esp,%ebp
  10307b:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  10307e:	e8 cb fd ff ff       	call   102e4e <__intr_save>
  103083:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  103086:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  10308b:	8b 40 14             	mov    0x14(%eax),%eax
  10308e:	ff d0                	call   *%eax
  103090:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  103093:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103096:	89 04 24             	mov    %eax,(%esp)
  103099:	e8 da fd ff ff       	call   102e78 <__intr_restore>
    return ret;
  10309e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1030a1:	c9                   	leave  
  1030a2:	c3                   	ret    

001030a3 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  1030a3:	55                   	push   %ebp
  1030a4:	89 e5                	mov    %esp,%ebp
  1030a6:	57                   	push   %edi
  1030a7:	56                   	push   %esi
  1030a8:	53                   	push   %ebx
  1030a9:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  1030af:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  1030b6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  1030bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  1030c4:	c7 04 24 47 6c 10 00 	movl   $0x106c47,(%esp)
  1030cb:	e8 cd d1 ff ff       	call   10029d <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  1030d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1030d7:	e9 72 01 00 00       	jmp    10324e <page_init+0x1ab>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  1030dc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030df:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1030e2:	89 d0                	mov    %edx,%eax
  1030e4:	c1 e0 02             	shl    $0x2,%eax
  1030e7:	01 d0                	add    %edx,%eax
  1030e9:	c1 e0 02             	shl    $0x2,%eax
  1030ec:	01 c8                	add    %ecx,%eax
  1030ee:	8b 50 08             	mov    0x8(%eax),%edx
  1030f1:	8b 40 04             	mov    0x4(%eax),%eax
  1030f4:	89 45 b8             	mov    %eax,-0x48(%ebp)
  1030f7:	89 55 bc             	mov    %edx,-0x44(%ebp)
  1030fa:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1030fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103100:	89 d0                	mov    %edx,%eax
  103102:	c1 e0 02             	shl    $0x2,%eax
  103105:	01 d0                	add    %edx,%eax
  103107:	c1 e0 02             	shl    $0x2,%eax
  10310a:	01 c8                	add    %ecx,%eax
  10310c:	8b 48 0c             	mov    0xc(%eax),%ecx
  10310f:	8b 58 10             	mov    0x10(%eax),%ebx
  103112:	8b 45 b8             	mov    -0x48(%ebp),%eax
  103115:	8b 55 bc             	mov    -0x44(%ebp),%edx
  103118:	01 c8                	add    %ecx,%eax
  10311a:	11 da                	adc    %ebx,%edx
  10311c:	89 45 b0             	mov    %eax,-0x50(%ebp)
  10311f:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.",
  103122:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103125:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103128:	89 d0                	mov    %edx,%eax
  10312a:	c1 e0 02             	shl    $0x2,%eax
  10312d:	01 d0                	add    %edx,%eax
  10312f:	c1 e0 02             	shl    $0x2,%eax
  103132:	01 c8                	add    %ecx,%eax
  103134:	83 c0 14             	add    $0x14,%eax
  103137:	8b 00                	mov    (%eax),%eax
  103139:	89 45 84             	mov    %eax,-0x7c(%ebp)
  10313c:	8b 45 b0             	mov    -0x50(%ebp),%eax
  10313f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103142:	83 c0 ff             	add    $0xffffffff,%eax
  103145:	83 d2 ff             	adc    $0xffffffff,%edx
  103148:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
  10314e:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
  103154:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103157:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10315a:	89 d0                	mov    %edx,%eax
  10315c:	c1 e0 02             	shl    $0x2,%eax
  10315f:	01 d0                	add    %edx,%eax
  103161:	c1 e0 02             	shl    $0x2,%eax
  103164:	01 c8                	add    %ecx,%eax
  103166:	8b 48 0c             	mov    0xc(%eax),%ecx
  103169:	8b 58 10             	mov    0x10(%eax),%ebx
  10316c:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10316f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
  103173:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
  103179:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
  10317f:	89 44 24 14          	mov    %eax,0x14(%esp)
  103183:	89 54 24 18          	mov    %edx,0x18(%esp)
  103187:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10318a:	8b 55 bc             	mov    -0x44(%ebp),%edx
  10318d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103191:	89 54 24 10          	mov    %edx,0x10(%esp)
  103195:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  103199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  10319d:	c7 04 24 54 6c 10 00 	movl   $0x106c54,(%esp)
  1031a4:	e8 f4 d0 ff ff       	call   10029d <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if(memmap->map[i].type == 1){
  1031a9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1031ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1031af:	89 d0                	mov    %edx,%eax
  1031b1:	c1 e0 02             	shl    $0x2,%eax
  1031b4:	01 d0                	add    %edx,%eax
  1031b6:	c1 e0 02             	shl    $0x2,%eax
  1031b9:	01 c8                	add    %ecx,%eax
  1031bb:	83 c0 14             	add    $0x14,%eax
  1031be:	8b 00                	mov    (%eax),%eax
  1031c0:	83 f8 01             	cmp    $0x1,%eax
  1031c3:	75 0c                	jne    1031d1 <page_init+0x12e>
            cprintf("可以使用的物理内存空间\n");
  1031c5:	c7 04 24 84 6c 10 00 	movl   $0x106c84,(%esp)
  1031cc:	e8 cc d0 ff ff       	call   10029d <cprintf>
        }
        if(memmap->map[i].type == 2){
  1031d1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1031d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1031d7:	89 d0                	mov    %edx,%eax
  1031d9:	c1 e0 02             	shl    $0x2,%eax
  1031dc:	01 d0                	add    %edx,%eax
  1031de:	c1 e0 02             	shl    $0x2,%eax
  1031e1:	01 c8                	add    %ecx,%eax
  1031e3:	83 c0 14             	add    $0x14,%eax
  1031e6:	8b 00                	mov    (%eax),%eax
  1031e8:	83 f8 02             	cmp    $0x2,%eax
  1031eb:	75 0c                	jne    1031f9 <page_init+0x156>
            cprintf("不能使用的物理内存空间\n");
  1031ed:	c7 04 24 a8 6c 10 00 	movl   $0x106ca8,(%esp)
  1031f4:	e8 a4 d0 ff ff       	call   10029d <cprintf>
        }
        if (memmap->map[i].type == E820_ARM) {
  1031f9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1031fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1031ff:	89 d0                	mov    %edx,%eax
  103201:	c1 e0 02             	shl    $0x2,%eax
  103204:	01 d0                	add    %edx,%eax
  103206:	c1 e0 02             	shl    $0x2,%eax
  103209:	01 c8                	add    %ecx,%eax
  10320b:	83 c0 14             	add    $0x14,%eax
  10320e:	8b 00                	mov    (%eax),%eax
  103210:	83 f8 01             	cmp    $0x1,%eax
  103213:	75 36                	jne    10324b <page_init+0x1a8>
            if (maxpa < end && begin < KMEMSIZE) {
  103215:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103218:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10321b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  10321e:	77 2b                	ja     10324b <page_init+0x1a8>
  103220:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
  103223:	72 05                	jb     10322a <page_init+0x187>
  103225:	3b 45 b0             	cmp    -0x50(%ebp),%eax
  103228:	73 21                	jae    10324b <page_init+0x1a8>
  10322a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  10322e:	77 1b                	ja     10324b <page_init+0x1a8>
  103230:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
  103234:	72 09                	jb     10323f <page_init+0x19c>
  103236:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
  10323d:	77 0c                	ja     10324b <page_init+0x1a8>
                maxpa = end;
  10323f:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103242:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  103245:	89 45 e0             	mov    %eax,-0x20(%ebp)
  103248:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  10324b:	ff 45 dc             	incl   -0x24(%ebp)
  10324e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  103251:	8b 00                	mov    (%eax),%eax
  103253:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  103256:	0f 8f 80 fe ff ff    	jg     1030dc <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  10325c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103260:	72 1d                	jb     10327f <page_init+0x1dc>
  103262:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  103266:	77 09                	ja     103271 <page_init+0x1ce>
  103268:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
  10326f:	76 0e                	jbe    10327f <page_init+0x1dc>
        maxpa = KMEMSIZE;
  103271:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  103278:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  10327f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103282:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103285:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  103289:	c1 ea 0c             	shr    $0xc,%edx
  10328c:	a3 a0 be 11 00       	mov    %eax,0x11bea0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  103291:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
  103298:	b8 a8 bf 11 00       	mov    $0x11bfa8,%eax
  10329d:	8d 50 ff             	lea    -0x1(%eax),%edx
  1032a0:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1032a3:	01 d0                	add    %edx,%eax
  1032a5:	89 45 a8             	mov    %eax,-0x58(%ebp)
  1032a8:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1032ab:	ba 00 00 00 00       	mov    $0x0,%edx
  1032b0:	f7 75 ac             	divl   -0x54(%ebp)
  1032b3:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1032b6:	29 d0                	sub    %edx,%eax
  1032b8:	a3 98 bf 11 00       	mov    %eax,0x11bf98

    for (i = 0; i < npage; i ++) {
  1032bd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1032c4:	eb 2e                	jmp    1032f4 <page_init+0x251>
        SetPageReserved(pages + i);
  1032c6:	8b 0d 98 bf 11 00    	mov    0x11bf98,%ecx
  1032cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1032cf:	89 d0                	mov    %edx,%eax
  1032d1:	c1 e0 02             	shl    $0x2,%eax
  1032d4:	01 d0                	add    %edx,%eax
  1032d6:	c1 e0 02             	shl    $0x2,%eax
  1032d9:	01 c8                	add    %ecx,%eax
  1032db:	83 c0 04             	add    $0x4,%eax
  1032de:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
  1032e5:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1032e8:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1032eb:	8b 55 90             	mov    -0x70(%ebp),%edx
  1032ee:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
  1032f1:	ff 45 dc             	incl   -0x24(%ebp)
  1032f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1032f7:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  1032fc:	39 c2                	cmp    %eax,%edx
  1032fe:	72 c6                	jb     1032c6 <page_init+0x223>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  103300:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  103306:	89 d0                	mov    %edx,%eax
  103308:	c1 e0 02             	shl    $0x2,%eax
  10330b:	01 d0                	add    %edx,%eax
  10330d:	c1 e0 02             	shl    $0x2,%eax
  103310:	89 c2                	mov    %eax,%edx
  103312:	a1 98 bf 11 00       	mov    0x11bf98,%eax
  103317:	01 d0                	add    %edx,%eax
  103319:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  10331c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
  103323:	77 23                	ja     103348 <page_init+0x2a5>
  103325:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  103328:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10332c:	c7 44 24 08 cc 6c 10 	movl   $0x106ccc,0x8(%esp)
  103333:	00 
  103334:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  10333b:	00 
  10333c:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103343:	e8 ac d0 ff ff       	call   1003f4 <__panic>
  103348:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  10334b:	05 00 00 00 40       	add    $0x40000000,%eax
  103350:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  103353:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10335a:	e9 61 01 00 00       	jmp    1034c0 <page_init+0x41d>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10335f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103362:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103365:	89 d0                	mov    %edx,%eax
  103367:	c1 e0 02             	shl    $0x2,%eax
  10336a:	01 d0                	add    %edx,%eax
  10336c:	c1 e0 02             	shl    $0x2,%eax
  10336f:	01 c8                	add    %ecx,%eax
  103371:	8b 50 08             	mov    0x8(%eax),%edx
  103374:	8b 40 04             	mov    0x4(%eax),%eax
  103377:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10337a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10337d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  103380:	8b 55 dc             	mov    -0x24(%ebp),%edx
  103383:	89 d0                	mov    %edx,%eax
  103385:	c1 e0 02             	shl    $0x2,%eax
  103388:	01 d0                	add    %edx,%eax
  10338a:	c1 e0 02             	shl    $0x2,%eax
  10338d:	01 c8                	add    %ecx,%eax
  10338f:	8b 48 0c             	mov    0xc(%eax),%ecx
  103392:	8b 58 10             	mov    0x10(%eax),%ebx
  103395:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103398:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10339b:	01 c8                	add    %ecx,%eax
  10339d:	11 da                	adc    %ebx,%edx
  10339f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  1033a2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  1033a5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1033a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1033ab:	89 d0                	mov    %edx,%eax
  1033ad:	c1 e0 02             	shl    $0x2,%eax
  1033b0:	01 d0                	add    %edx,%eax
  1033b2:	c1 e0 02             	shl    $0x2,%eax
  1033b5:	01 c8                	add    %ecx,%eax
  1033b7:	83 c0 14             	add    $0x14,%eax
  1033ba:	8b 00                	mov    (%eax),%eax
  1033bc:	83 f8 01             	cmp    $0x1,%eax
  1033bf:	0f 85 f8 00 00 00    	jne    1034bd <page_init+0x41a>
            if (begin < freemem) {
  1033c5:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1033c8:	ba 00 00 00 00       	mov    $0x0,%edx
  1033cd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1033d0:	72 17                	jb     1033e9 <page_init+0x346>
  1033d2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  1033d5:	77 05                	ja     1033dc <page_init+0x339>
  1033d7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  1033da:	76 0d                	jbe    1033e9 <page_init+0x346>
                begin = freemem;
  1033dc:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1033df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1033e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1033e9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1033ed:	72 1d                	jb     10340c <page_init+0x369>
  1033ef:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  1033f3:	77 09                	ja     1033fe <page_init+0x35b>
  1033f5:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
  1033fc:	76 0e                	jbe    10340c <page_init+0x369>
                end = KMEMSIZE;
  1033fe:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  103405:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  10340c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10340f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103412:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103415:	0f 87 a2 00 00 00    	ja     1034bd <page_init+0x41a>
  10341b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10341e:	72 09                	jb     103429 <page_init+0x386>
  103420:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  103423:	0f 83 94 00 00 00    	jae    1034bd <page_init+0x41a>
                begin = ROUNDUP(begin, PGSIZE);
  103429:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
  103430:	8b 55 d0             	mov    -0x30(%ebp),%edx
  103433:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103436:	01 d0                	add    %edx,%eax
  103438:	48                   	dec    %eax
  103439:	89 45 98             	mov    %eax,-0x68(%ebp)
  10343c:	8b 45 98             	mov    -0x68(%ebp),%eax
  10343f:	ba 00 00 00 00       	mov    $0x0,%edx
  103444:	f7 75 9c             	divl   -0x64(%ebp)
  103447:	8b 45 98             	mov    -0x68(%ebp),%eax
  10344a:	29 d0                	sub    %edx,%eax
  10344c:	ba 00 00 00 00       	mov    $0x0,%edx
  103451:	89 45 d0             	mov    %eax,-0x30(%ebp)
  103454:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  103457:	8b 45 c8             	mov    -0x38(%ebp),%eax
  10345a:	89 45 94             	mov    %eax,-0x6c(%ebp)
  10345d:	8b 45 94             	mov    -0x6c(%ebp),%eax
  103460:	ba 00 00 00 00       	mov    $0x0,%edx
  103465:	89 c3                	mov    %eax,%ebx
  103467:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  10346d:	89 de                	mov    %ebx,%esi
  10346f:	89 d0                	mov    %edx,%eax
  103471:	83 e0 00             	and    $0x0,%eax
  103474:	89 c7                	mov    %eax,%edi
  103476:	89 75 c8             	mov    %esi,-0x38(%ebp)
  103479:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
  10347c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10347f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  103482:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  103485:	77 36                	ja     1034bd <page_init+0x41a>
  103487:	3b 55 cc             	cmp    -0x34(%ebp),%edx
  10348a:	72 05                	jb     103491 <page_init+0x3ee>
  10348c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10348f:	73 2c                	jae    1034bd <page_init+0x41a>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  103491:	8b 45 c8             	mov    -0x38(%ebp),%eax
  103494:	8b 55 cc             	mov    -0x34(%ebp),%edx
  103497:	2b 45 d0             	sub    -0x30(%ebp),%eax
  10349a:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  10349d:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  1034a1:	c1 ea 0c             	shr    $0xc,%edx
  1034a4:	89 c3                	mov    %eax,%ebx
  1034a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1034a9:	89 04 24             	mov    %eax,(%esp)
  1034ac:	e8 5e f8 ff ff       	call   102d0f <pa2page>
  1034b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1034b5:	89 04 24             	mov    %eax,(%esp)
  1034b8:	e8 30 fb ff ff       	call   102fed <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
  1034bd:	ff 45 dc             	incl   -0x24(%ebp)
  1034c0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1034c3:	8b 00                	mov    (%eax),%eax
  1034c5:	3b 45 dc             	cmp    -0x24(%ebp),%eax
  1034c8:	0f 8f 91 fe ff ff    	jg     10335f <page_init+0x2bc>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
  1034ce:	90                   	nop
  1034cf:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  1034d5:	5b                   	pop    %ebx
  1034d6:	5e                   	pop    %esi
  1034d7:	5f                   	pop    %edi
  1034d8:	5d                   	pop    %ebp
  1034d9:	c3                   	ret    

001034da <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  1034da:	55                   	push   %ebp
  1034db:	89 e5                	mov    %esp,%ebp
  1034dd:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1034e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  1034e3:	33 45 14             	xor    0x14(%ebp),%eax
  1034e6:	25 ff 0f 00 00       	and    $0xfff,%eax
  1034eb:	85 c0                	test   %eax,%eax
  1034ed:	74 24                	je     103513 <boot_map_segment+0x39>
  1034ef:	c7 44 24 0c fe 6c 10 	movl   $0x106cfe,0xc(%esp)
  1034f6:	00 
  1034f7:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1034fe:	00 
  1034ff:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  103506:	00 
  103507:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  10350e:	e8 e1 ce ff ff       	call   1003f4 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  103513:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  10351a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10351d:	25 ff 0f 00 00       	and    $0xfff,%eax
  103522:	89 c2                	mov    %eax,%edx
  103524:	8b 45 10             	mov    0x10(%ebp),%eax
  103527:	01 c2                	add    %eax,%edx
  103529:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10352c:	01 d0                	add    %edx,%eax
  10352e:	48                   	dec    %eax
  10352f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103532:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103535:	ba 00 00 00 00       	mov    $0x0,%edx
  10353a:	f7 75 f0             	divl   -0x10(%ebp)
  10353d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103540:	29 d0                	sub    %edx,%eax
  103542:	c1 e8 0c             	shr    $0xc,%eax
  103545:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  103548:	8b 45 0c             	mov    0xc(%ebp),%eax
  10354b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10354e:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103551:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103556:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  103559:	8b 45 14             	mov    0x14(%ebp),%eax
  10355c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10355f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103562:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103567:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10356a:	eb 68                	jmp    1035d4 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10356c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103573:	00 
  103574:	8b 45 0c             	mov    0xc(%ebp),%eax
  103577:	89 44 24 04          	mov    %eax,0x4(%esp)
  10357b:	8b 45 08             	mov    0x8(%ebp),%eax
  10357e:	89 04 24             	mov    %eax,(%esp)
  103581:	e8 81 01 00 00       	call   103707 <get_pte>
  103586:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  103589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10358d:	75 24                	jne    1035b3 <boot_map_segment+0xd9>
  10358f:	c7 44 24 0c 2a 6d 10 	movl   $0x106d2a,0xc(%esp)
  103596:	00 
  103597:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  10359e:	00 
  10359f:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
  1035a6:	00 
  1035a7:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1035ae:	e8 41 ce ff ff       	call   1003f4 <__panic>
        *ptep = pa | PTE_P | perm;
  1035b3:	8b 45 14             	mov    0x14(%ebp),%eax
  1035b6:	0b 45 18             	or     0x18(%ebp),%eax
  1035b9:	83 c8 01             	or     $0x1,%eax
  1035bc:	89 c2                	mov    %eax,%edx
  1035be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1035c1:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  1035c3:	ff 4d f4             	decl   -0xc(%ebp)
  1035c6:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  1035cd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  1035d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1035d8:	75 92                	jne    10356c <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
  1035da:	90                   	nop
  1035db:	c9                   	leave  
  1035dc:	c3                   	ret    

001035dd <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1035dd:	55                   	push   %ebp
  1035de:	89 e5                	mov    %esp,%ebp
  1035e0:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1035e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035ea:	e8 1e fa ff ff       	call   10300d <alloc_pages>
  1035ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1035f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1035f6:	75 1c                	jne    103614 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1035f8:	c7 44 24 08 37 6d 10 	movl   $0x106d37,0x8(%esp)
  1035ff:	00 
  103600:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
  103607:	00 
  103608:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  10360f:	e8 e0 cd ff ff       	call   1003f4 <__panic>
    }
    return page2kva(p);
  103614:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103617:	89 04 24             	mov    %eax,(%esp)
  10361a:	e8 3f f7 ff ff       	call   102d5e <page2kva>
}
  10361f:	c9                   	leave  
  103620:	c3                   	ret    

00103621 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  103621:	55                   	push   %ebp
  103622:	89 e5                	mov    %esp,%ebp
  103624:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  103627:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10362c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10362f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  103636:	77 23                	ja     10365b <pmm_init+0x3a>
  103638:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10363b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10363f:	c7 44 24 08 cc 6c 10 	movl   $0x106ccc,0x8(%esp)
  103646:	00 
  103647:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  10364e:	00 
  10364f:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103656:	e8 99 cd ff ff       	call   1003f4 <__panic>
  10365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10365e:	05 00 00 00 40       	add    $0x40000000,%eax
  103663:	a3 94 bf 11 00       	mov    %eax,0x11bf94
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  103668:	e8 4c f9 ff ff       	call   102fb9 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  10366d:	e8 31 fa ff ff       	call   1030a3 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  103672:	e8 e5 03 00 00       	call   103a5c <check_alloc_page>

    check_pgdir();
  103677:	e8 ff 03 00 00       	call   103a7b <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  10367c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103681:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
  103687:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10368c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10368f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103696:	77 23                	ja     1036bb <pmm_init+0x9a>
  103698:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10369b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10369f:	c7 44 24 08 cc 6c 10 	movl   $0x106ccc,0x8(%esp)
  1036a6:	00 
  1036a7:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
  1036ae:	00 
  1036af:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1036b6:	e8 39 cd ff ff       	call   1003f4 <__panic>
  1036bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036be:	05 00 00 00 40       	add    $0x40000000,%eax
  1036c3:	83 c8 03             	or     $0x3,%eax
  1036c6:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  1036c8:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1036cd:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  1036d4:	00 
  1036d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1036dc:	00 
  1036dd:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1036e4:	38 
  1036e5:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1036ec:	c0 
  1036ed:	89 04 24             	mov    %eax,(%esp)
  1036f0:	e8 e5 fd ff ff       	call   1034da <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1036f5:	e8 d6 f7 ff ff       	call   102ed0 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1036fa:	e8 18 0a 00 00       	call   104117 <check_boot_pgdir>

    print_pgdir();
  1036ff:	e8 91 0e 00 00       	call   104595 <print_pgdir>

}
  103704:	90                   	nop
  103705:	c9                   	leave  
  103706:	c3                   	ret    

00103707 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  103707:	55                   	push   %ebp
  103708:	89 e5                	mov    %esp,%ebp
  10370a:	83 ec 38             	sub    $0x38,%esp
    // (4) set page reference
    // (5) get linear address of page
    // (6) clear page content using memset
    // (7) set page directory entry's permission
    // (8) return page table entry
    pde_t *pdep = &pgdir[PDX(la)];
  10370d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103710:	c1 e8 16             	shr    $0x16,%eax
  103713:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10371a:	8b 45 08             	mov    0x8(%ebp),%eax
  10371d:	01 d0                	add    %edx,%eax
  10371f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!(*pdep & PTE_P)){
  103722:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103725:	8b 00                	mov    (%eax),%eax
  103727:	83 e0 01             	and    $0x1,%eax
  10372a:	85 c0                	test   %eax,%eax
  10372c:	0f 85 b6 00 00 00    	jne    1037e8 <get_pte+0xe1>
        struct Page *page;
        if(create == 1 && (page = alloc_page())){
  103732:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
  103736:	0f 85 a5 00 00 00    	jne    1037e1 <get_pte+0xda>
  10373c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103743:	e8 c5 f8 ff ff       	call   10300d <alloc_pages>
  103748:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10374b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10374f:	0f 84 8c 00 00 00    	je     1037e1 <get_pte+0xda>
            set_page_ref(page,1);
  103755:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10375c:	00 
  10375d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103760:	89 04 24             	mov    %eax,(%esp)
  103763:	e8 aa f6 ff ff       	call   102e12 <set_page_ref>
            uintptr_t pa = page2pa(page);
  103768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10376b:	89 04 24             	mov    %eax,(%esp)
  10376e:	e8 86 f5 ff ff       	call   102cf9 <page2pa>
  103773:	89 45 ec             	mov    %eax,-0x14(%ebp)
            memset(KADDR(pa), 0, PGSIZE);
  103776:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103779:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10377c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10377f:	c1 e8 0c             	shr    $0xc,%eax
  103782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103785:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  10378a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  10378d:	72 23                	jb     1037b2 <get_pte+0xab>
  10378f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103792:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103796:	c7 44 24 08 e0 6b 10 	movl   $0x106be0,0x8(%esp)
  10379d:	00 
  10379e:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
  1037a5:	00 
  1037a6:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1037ad:	e8 42 cc ff ff       	call   1003f4 <__panic>
  1037b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1037b5:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1037ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  1037c1:	00 
  1037c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1037c9:	00 
  1037ca:	89 04 24             	mov    %eax,(%esp)
  1037cd:	e8 a9 24 00 00       	call   105c7b <memset>
            *pdep = pa | PTE_U | PTE_W | PTE_P;
  1037d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1037d5:	83 c8 07             	or     $0x7,%eax
  1037d8:	89 c2                	mov    %eax,%edx
  1037da:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037dd:	89 10                	mov    %edx,(%eax)
    // (7) set page directory entry's permission
    // (8) return page table entry
    pde_t *pdep = &pgdir[PDX(la)];
    if(!(*pdep & PTE_P)){
        struct Page *page;
        if(create == 1 && (page = alloc_page())){
  1037df:	eb 07                	jmp    1037e8 <get_pte+0xe1>
            uintptr_t pa = page2pa(page);
            memset(KADDR(pa), 0, PGSIZE);
            *pdep = pa | PTE_U | PTE_W | PTE_P;
        }
        else{
            return NULL;
  1037e1:	b8 00 00 00 00       	mov    $0x0,%eax
  1037e6:	eb 5d                	jmp    103845 <get_pte+0x13e>
        }

    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  1037e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1037eb:	8b 00                	mov    (%eax),%eax
  1037ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1037f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1037f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1037f8:	c1 e8 0c             	shr    $0xc,%eax
  1037fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1037fe:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  103803:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  103806:	72 23                	jb     10382b <get_pte+0x124>
  103808:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10380b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10380f:	c7 44 24 08 e0 6b 10 	movl   $0x106be0,0x8(%esp)
  103816:	00 
  103817:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
  10381e:	00 
  10381f:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103826:	e8 c9 cb ff ff       	call   1003f4 <__panic>
  10382b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10382e:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103833:	89 c2                	mov    %eax,%edx
  103835:	8b 45 0c             	mov    0xc(%ebp),%eax
  103838:	c1 e8 0c             	shr    $0xc,%eax
  10383b:	25 ff 03 00 00       	and    $0x3ff,%eax
  103840:	c1 e0 02             	shl    $0x2,%eax
  103843:	01 d0                	add    %edx,%eax
#endif
}
  103845:	c9                   	leave  
  103846:	c3                   	ret    

00103847 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  103847:	55                   	push   %ebp
  103848:	89 e5                	mov    %esp,%ebp
  10384a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  10384d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103854:	00 
  103855:	8b 45 0c             	mov    0xc(%ebp),%eax
  103858:	89 44 24 04          	mov    %eax,0x4(%esp)
  10385c:	8b 45 08             	mov    0x8(%ebp),%eax
  10385f:	89 04 24             	mov    %eax,(%esp)
  103862:	e8 a0 fe ff ff       	call   103707 <get_pte>
  103867:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10386a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  10386e:	74 08                	je     103878 <get_page+0x31>
        *ptep_store = ptep;
  103870:	8b 45 10             	mov    0x10(%ebp),%eax
  103873:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103876:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  103878:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10387c:	74 1b                	je     103899 <get_page+0x52>
  10387e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103881:	8b 00                	mov    (%eax),%eax
  103883:	83 e0 01             	and    $0x1,%eax
  103886:	85 c0                	test   %eax,%eax
  103888:	74 0f                	je     103899 <get_page+0x52>
        return pte2page(*ptep);
  10388a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10388d:	8b 00                	mov    (%eax),%eax
  10388f:	89 04 24             	mov    %eax,(%esp)
  103892:	e8 1b f5 ff ff       	call   102db2 <pte2page>
  103897:	eb 05                	jmp    10389e <get_page+0x57>
    }
    return NULL;
  103899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  10389e:	c9                   	leave  
  10389f:	c3                   	ret    

001038a0 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  1038a0:	55                   	push   %ebp
  1038a1:	89 e5                	mov    %esp,%ebp
  1038a3:	83 ec 28             	sub    $0x28,%esp
    //(2) find corresponding page to pte
    //(3) decrease page reference
    //(4) and free this page when page reference reachs 0
    //(5) clear second page table entry
    //(6) flush tlb
    if(*ptep & PTE_P){
  1038a6:	8b 45 10             	mov    0x10(%ebp),%eax
  1038a9:	8b 00                	mov    (%eax),%eax
  1038ab:	83 e0 01             	and    $0x1,%eax
  1038ae:	85 c0                	test   %eax,%eax
  1038b0:	74 4d                	je     1038ff <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
  1038b2:	8b 45 10             	mov    0x10(%ebp),%eax
  1038b5:	8b 00                	mov    (%eax),%eax
  1038b7:	89 04 24             	mov    %eax,(%esp)
  1038ba:	e8 f3 f4 ff ff       	call   102db2 <pte2page>
  1038bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page) == 0){
  1038c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038c5:	89 04 24             	mov    %eax,(%esp)
  1038c8:	e8 6a f5 ff ff       	call   102e37 <page_ref_dec>
  1038cd:	85 c0                	test   %eax,%eax
  1038cf:	75 13                	jne    1038e4 <page_remove_pte+0x44>
            free_page(page);
  1038d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1038d8:	00 
  1038d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1038dc:	89 04 24             	mov    %eax,(%esp)
  1038df:	e8 61 f7 ff ff       	call   103045 <free_pages>
        }
        *ptep = NULL;
  1038e4:	8b 45 10             	mov    0x10(%ebp),%eax
  1038e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
  1038ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  1038f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1038f4:	8b 45 08             	mov    0x8(%ebp),%eax
  1038f7:	89 04 24             	mov    %eax,(%esp)
  1038fa:	e8 01 01 00 00       	call   103a00 <tlb_invalidate>
    }
#endif

}
  1038ff:	90                   	nop
  103900:	c9                   	leave  
  103901:	c3                   	ret    

00103902 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  103902:	55                   	push   %ebp
  103903:	89 e5                	mov    %esp,%ebp
  103905:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  103908:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10390f:	00 
  103910:	8b 45 0c             	mov    0xc(%ebp),%eax
  103913:	89 44 24 04          	mov    %eax,0x4(%esp)
  103917:	8b 45 08             	mov    0x8(%ebp),%eax
  10391a:	89 04 24             	mov    %eax,(%esp)
  10391d:	e8 e5 fd ff ff       	call   103707 <get_pte>
  103922:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  103925:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103929:	74 19                	je     103944 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  10392b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10392e:	89 44 24 08          	mov    %eax,0x8(%esp)
  103932:	8b 45 0c             	mov    0xc(%ebp),%eax
  103935:	89 44 24 04          	mov    %eax,0x4(%esp)
  103939:	8b 45 08             	mov    0x8(%ebp),%eax
  10393c:	89 04 24             	mov    %eax,(%esp)
  10393f:	e8 5c ff ff ff       	call   1038a0 <page_remove_pte>
    }
}
  103944:	90                   	nop
  103945:	c9                   	leave  
  103946:	c3                   	ret    

00103947 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  103947:	55                   	push   %ebp
  103948:	89 e5                	mov    %esp,%ebp
  10394a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  10394d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  103954:	00 
  103955:	8b 45 10             	mov    0x10(%ebp),%eax
  103958:	89 44 24 04          	mov    %eax,0x4(%esp)
  10395c:	8b 45 08             	mov    0x8(%ebp),%eax
  10395f:	89 04 24             	mov    %eax,(%esp)
  103962:	e8 a0 fd ff ff       	call   103707 <get_pte>
  103967:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  10396a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10396e:	75 0a                	jne    10397a <page_insert+0x33>
        return -E_NO_MEM;
  103970:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  103975:	e9 84 00 00 00       	jmp    1039fe <page_insert+0xb7>
    }
    page_ref_inc(page);
  10397a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10397d:	89 04 24             	mov    %eax,(%esp)
  103980:	e8 9b f4 ff ff       	call   102e20 <page_ref_inc>
    if (*ptep & PTE_P) {
  103985:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103988:	8b 00                	mov    (%eax),%eax
  10398a:	83 e0 01             	and    $0x1,%eax
  10398d:	85 c0                	test   %eax,%eax
  10398f:	74 3e                	je     1039cf <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  103991:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103994:	8b 00                	mov    (%eax),%eax
  103996:	89 04 24             	mov    %eax,(%esp)
  103999:	e8 14 f4 ff ff       	call   102db2 <pte2page>
  10399e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  1039a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1039a4:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1039a7:	75 0d                	jne    1039b6 <page_insert+0x6f>
            page_ref_dec(page);
  1039a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1039ac:	89 04 24             	mov    %eax,(%esp)
  1039af:	e8 83 f4 ff ff       	call   102e37 <page_ref_dec>
  1039b4:	eb 19                	jmp    1039cf <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  1039b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039b9:	89 44 24 08          	mov    %eax,0x8(%esp)
  1039bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1039c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1039c4:	8b 45 08             	mov    0x8(%ebp),%eax
  1039c7:	89 04 24             	mov    %eax,(%esp)
  1039ca:	e8 d1 fe ff ff       	call   1038a0 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  1039cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1039d2:	89 04 24             	mov    %eax,(%esp)
  1039d5:	e8 1f f3 ff ff       	call   102cf9 <page2pa>
  1039da:	0b 45 14             	or     0x14(%ebp),%eax
  1039dd:	83 c8 01             	or     $0x1,%eax
  1039e0:	89 c2                	mov    %eax,%edx
  1039e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1039e5:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1039e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1039ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  1039ee:	8b 45 08             	mov    0x8(%ebp),%eax
  1039f1:	89 04 24             	mov    %eax,(%esp)
  1039f4:	e8 07 00 00 00       	call   103a00 <tlb_invalidate>
    return 0;
  1039f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1039fe:	c9                   	leave  
  1039ff:	c3                   	ret    

00103a00 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  103a00:	55                   	push   %ebp
  103a01:	89 e5                	mov    %esp,%ebp
  103a03:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  103a06:	0f 20 d8             	mov    %cr3,%eax
  103a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
  103a0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  103a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103a15:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  103a1c:	77 23                	ja     103a41 <tlb_invalidate+0x41>
  103a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a21:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103a25:	c7 44 24 08 cc 6c 10 	movl   $0x106ccc,0x8(%esp)
  103a2c:	00 
  103a2d:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
  103a34:	00 
  103a35:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103a3c:	e8 b3 c9 ff ff       	call   1003f4 <__panic>
  103a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103a44:	05 00 00 00 40       	add    $0x40000000,%eax
  103a49:	39 c2                	cmp    %eax,%edx
  103a4b:	75 0c                	jne    103a59 <tlb_invalidate+0x59>
        invlpg((void *)la);
  103a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  103a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  103a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103a56:	0f 01 38             	invlpg (%eax)
    }
}
  103a59:	90                   	nop
  103a5a:	c9                   	leave  
  103a5b:	c3                   	ret    

00103a5c <check_alloc_page>:

static void
check_alloc_page(void) {
  103a5c:	55                   	push   %ebp
  103a5d:	89 e5                	mov    %esp,%ebp
  103a5f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  103a62:	a1 90 bf 11 00       	mov    0x11bf90,%eax
  103a67:	8b 40 18             	mov    0x18(%eax),%eax
  103a6a:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  103a6c:	c7 04 24 50 6d 10 00 	movl   $0x106d50,(%esp)
  103a73:	e8 25 c8 ff ff       	call   10029d <cprintf>
}
  103a78:	90                   	nop
  103a79:	c9                   	leave  
  103a7a:	c3                   	ret    

00103a7b <check_pgdir>:

static void
check_pgdir(void) {
  103a7b:	55                   	push   %ebp
  103a7c:	89 e5                	mov    %esp,%ebp
  103a7e:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  103a81:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  103a86:	3d 00 80 03 00       	cmp    $0x38000,%eax
  103a8b:	76 24                	jbe    103ab1 <check_pgdir+0x36>
  103a8d:	c7 44 24 0c 6f 6d 10 	movl   $0x106d6f,0xc(%esp)
  103a94:	00 
  103a95:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103a9c:	00 
  103a9d:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
  103aa4:	00 
  103aa5:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103aac:	e8 43 c9 ff ff       	call   1003f4 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  103ab1:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103ab6:	85 c0                	test   %eax,%eax
  103ab8:	74 0e                	je     103ac8 <check_pgdir+0x4d>
  103aba:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103abf:	25 ff 0f 00 00       	and    $0xfff,%eax
  103ac4:	85 c0                	test   %eax,%eax
  103ac6:	74 24                	je     103aec <check_pgdir+0x71>
  103ac8:	c7 44 24 0c 8c 6d 10 	movl   $0x106d8c,0xc(%esp)
  103acf:	00 
  103ad0:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103ad7:	00 
  103ad8:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  103adf:	00 
  103ae0:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103ae7:	e8 08 c9 ff ff       	call   1003f4 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  103aec:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103af1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103af8:	00 
  103af9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103b00:	00 
  103b01:	89 04 24             	mov    %eax,(%esp)
  103b04:	e8 3e fd ff ff       	call   103847 <get_page>
  103b09:	85 c0                	test   %eax,%eax
  103b0b:	74 24                	je     103b31 <check_pgdir+0xb6>
  103b0d:	c7 44 24 0c c4 6d 10 	movl   $0x106dc4,0xc(%esp)
  103b14:	00 
  103b15:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103b1c:	00 
  103b1d:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
  103b24:	00 
  103b25:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103b2c:	e8 c3 c8 ff ff       	call   1003f4 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  103b31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103b38:	e8 d0 f4 ff ff       	call   10300d <alloc_pages>
  103b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  103b40:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103b45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103b4c:	00 
  103b4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103b54:	00 
  103b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103b58:	89 54 24 04          	mov    %edx,0x4(%esp)
  103b5c:	89 04 24             	mov    %eax,(%esp)
  103b5f:	e8 e3 fd ff ff       	call   103947 <page_insert>
  103b64:	85 c0                	test   %eax,%eax
  103b66:	74 24                	je     103b8c <check_pgdir+0x111>
  103b68:	c7 44 24 0c ec 6d 10 	movl   $0x106dec,0xc(%esp)
  103b6f:	00 
  103b70:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103b77:	00 
  103b78:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
  103b7f:	00 
  103b80:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103b87:	e8 68 c8 ff ff       	call   1003f4 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  103b8c:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103b91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103b98:	00 
  103b99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103ba0:	00 
  103ba1:	89 04 24             	mov    %eax,(%esp)
  103ba4:	e8 5e fb ff ff       	call   103707 <get_pte>
  103ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103bac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103bb0:	75 24                	jne    103bd6 <check_pgdir+0x15b>
  103bb2:	c7 44 24 0c 18 6e 10 	movl   $0x106e18,0xc(%esp)
  103bb9:	00 
  103bba:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103bc1:	00 
  103bc2:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
  103bc9:	00 
  103bca:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103bd1:	e8 1e c8 ff ff       	call   1003f4 <__panic>
    assert(pte2page(*ptep) == p1);
  103bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103bd9:	8b 00                	mov    (%eax),%eax
  103bdb:	89 04 24             	mov    %eax,(%esp)
  103bde:	e8 cf f1 ff ff       	call   102db2 <pte2page>
  103be3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103be6:	74 24                	je     103c0c <check_pgdir+0x191>
  103be8:	c7 44 24 0c 45 6e 10 	movl   $0x106e45,0xc(%esp)
  103bef:	00 
  103bf0:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103bf7:	00 
  103bf8:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
  103bff:	00 
  103c00:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103c07:	e8 e8 c7 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p1) == 1);
  103c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103c0f:	89 04 24             	mov    %eax,(%esp)
  103c12:	e8 f1 f1 ff ff       	call   102e08 <page_ref>
  103c17:	83 f8 01             	cmp    $0x1,%eax
  103c1a:	74 24                	je     103c40 <check_pgdir+0x1c5>
  103c1c:	c7 44 24 0c 5b 6e 10 	movl   $0x106e5b,0xc(%esp)
  103c23:	00 
  103c24:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103c2b:	00 
  103c2c:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
  103c33:	00 
  103c34:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103c3b:	e8 b4 c7 ff ff       	call   1003f4 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  103c40:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c45:	8b 00                	mov    (%eax),%eax
  103c47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103c4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c52:	c1 e8 0c             	shr    $0xc,%eax
  103c55:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103c58:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  103c5d:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103c60:	72 23                	jb     103c85 <check_pgdir+0x20a>
  103c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c65:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103c69:	c7 44 24 08 e0 6b 10 	movl   $0x106be0,0x8(%esp)
  103c70:	00 
  103c71:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
  103c78:	00 
  103c79:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103c80:	e8 6f c7 ff ff       	call   1003f4 <__panic>
  103c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c88:	2d 00 00 00 40       	sub    $0x40000000,%eax
  103c8d:	83 c0 04             	add    $0x4,%eax
  103c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  103c93:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103c98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103c9f:	00 
  103ca0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103ca7:	00 
  103ca8:	89 04 24             	mov    %eax,(%esp)
  103cab:	e8 57 fa ff ff       	call   103707 <get_pte>
  103cb0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  103cb3:	74 24                	je     103cd9 <check_pgdir+0x25e>
  103cb5:	c7 44 24 0c 70 6e 10 	movl   $0x106e70,0xc(%esp)
  103cbc:	00 
  103cbd:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103cc4:	00 
  103cc5:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  103ccc:	00 
  103ccd:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103cd4:	e8 1b c7 ff ff       	call   1003f4 <__panic>

    p2 = alloc_page();
  103cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ce0:	e8 28 f3 ff ff       	call   10300d <alloc_pages>
  103ce5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  103ce8:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103ced:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  103cf4:	00 
  103cf5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103cfc:	00 
  103cfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  103d00:	89 54 24 04          	mov    %edx,0x4(%esp)
  103d04:	89 04 24             	mov    %eax,(%esp)
  103d07:	e8 3b fc ff ff       	call   103947 <page_insert>
  103d0c:	85 c0                	test   %eax,%eax
  103d0e:	74 24                	je     103d34 <check_pgdir+0x2b9>
  103d10:	c7 44 24 0c 98 6e 10 	movl   $0x106e98,0xc(%esp)
  103d17:	00 
  103d18:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103d1f:	00 
  103d20:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
  103d27:	00 
  103d28:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103d2f:	e8 c0 c6 ff ff       	call   1003f4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103d34:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103d39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103d40:	00 
  103d41:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103d48:	00 
  103d49:	89 04 24             	mov    %eax,(%esp)
  103d4c:	e8 b6 f9 ff ff       	call   103707 <get_pte>
  103d51:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103d58:	75 24                	jne    103d7e <check_pgdir+0x303>
  103d5a:	c7 44 24 0c d0 6e 10 	movl   $0x106ed0,0xc(%esp)
  103d61:	00 
  103d62:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103d69:	00 
  103d6a:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
  103d71:	00 
  103d72:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103d79:	e8 76 c6 ff ff       	call   1003f4 <__panic>
    assert(*ptep & PTE_U);
  103d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103d81:	8b 00                	mov    (%eax),%eax
  103d83:	83 e0 04             	and    $0x4,%eax
  103d86:	85 c0                	test   %eax,%eax
  103d88:	75 24                	jne    103dae <check_pgdir+0x333>
  103d8a:	c7 44 24 0c 00 6f 10 	movl   $0x106f00,0xc(%esp)
  103d91:	00 
  103d92:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103d99:	00 
  103d9a:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
  103da1:	00 
  103da2:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103da9:	e8 46 c6 ff ff       	call   1003f4 <__panic>
    assert(*ptep & PTE_W);
  103dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103db1:	8b 00                	mov    (%eax),%eax
  103db3:	83 e0 02             	and    $0x2,%eax
  103db6:	85 c0                	test   %eax,%eax
  103db8:	75 24                	jne    103dde <check_pgdir+0x363>
  103dba:	c7 44 24 0c 0e 6f 10 	movl   $0x106f0e,0xc(%esp)
  103dc1:	00 
  103dc2:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103dc9:	00 
  103dca:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  103dd1:	00 
  103dd2:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103dd9:	e8 16 c6 ff ff       	call   1003f4 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  103dde:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103de3:	8b 00                	mov    (%eax),%eax
  103de5:	83 e0 04             	and    $0x4,%eax
  103de8:	85 c0                	test   %eax,%eax
  103dea:	75 24                	jne    103e10 <check_pgdir+0x395>
  103dec:	c7 44 24 0c 1c 6f 10 	movl   $0x106f1c,0xc(%esp)
  103df3:	00 
  103df4:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103dfb:	00 
  103dfc:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
  103e03:	00 
  103e04:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103e0b:	e8 e4 c5 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p2) == 1);
  103e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103e13:	89 04 24             	mov    %eax,(%esp)
  103e16:	e8 ed ef ff ff       	call   102e08 <page_ref>
  103e1b:	83 f8 01             	cmp    $0x1,%eax
  103e1e:	74 24                	je     103e44 <check_pgdir+0x3c9>
  103e20:	c7 44 24 0c 32 6f 10 	movl   $0x106f32,0xc(%esp)
  103e27:	00 
  103e28:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103e2f:	00 
  103e30:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
  103e37:	00 
  103e38:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103e3f:	e8 b0 c5 ff ff       	call   1003f4 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  103e44:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103e49:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  103e50:	00 
  103e51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  103e58:	00 
  103e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
  103e5c:	89 54 24 04          	mov    %edx,0x4(%esp)
  103e60:	89 04 24             	mov    %eax,(%esp)
  103e63:	e8 df fa ff ff       	call   103947 <page_insert>
  103e68:	85 c0                	test   %eax,%eax
  103e6a:	74 24                	je     103e90 <check_pgdir+0x415>
  103e6c:	c7 44 24 0c 44 6f 10 	movl   $0x106f44,0xc(%esp)
  103e73:	00 
  103e74:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103e7b:	00 
  103e7c:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  103e83:	00 
  103e84:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103e8b:	e8 64 c5 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p1) == 2);
  103e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103e93:	89 04 24             	mov    %eax,(%esp)
  103e96:	e8 6d ef ff ff       	call   102e08 <page_ref>
  103e9b:	83 f8 02             	cmp    $0x2,%eax
  103e9e:	74 24                	je     103ec4 <check_pgdir+0x449>
  103ea0:	c7 44 24 0c 70 6f 10 	movl   $0x106f70,0xc(%esp)
  103ea7:	00 
  103ea8:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103eaf:	00 
  103eb0:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  103eb7:	00 
  103eb8:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103ebf:	e8 30 c5 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p2) == 0);
  103ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ec7:	89 04 24             	mov    %eax,(%esp)
  103eca:	e8 39 ef ff ff       	call   102e08 <page_ref>
  103ecf:	85 c0                	test   %eax,%eax
  103ed1:	74 24                	je     103ef7 <check_pgdir+0x47c>
  103ed3:	c7 44 24 0c 82 6f 10 	movl   $0x106f82,0xc(%esp)
  103eda:	00 
  103edb:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103ee2:	00 
  103ee3:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
  103eea:	00 
  103eeb:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103ef2:	e8 fd c4 ff ff       	call   1003f4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  103ef7:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103efc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  103f03:	00 
  103f04:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  103f0b:	00 
  103f0c:	89 04 24             	mov    %eax,(%esp)
  103f0f:	e8 f3 f7 ff ff       	call   103707 <get_pte>
  103f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103f17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103f1b:	75 24                	jne    103f41 <check_pgdir+0x4c6>
  103f1d:	c7 44 24 0c d0 6e 10 	movl   $0x106ed0,0xc(%esp)
  103f24:	00 
  103f25:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103f2c:	00 
  103f2d:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  103f34:	00 
  103f35:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103f3c:	e8 b3 c4 ff ff       	call   1003f4 <__panic>
    assert(pte2page(*ptep) == p1);
  103f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f44:	8b 00                	mov    (%eax),%eax
  103f46:	89 04 24             	mov    %eax,(%esp)
  103f49:	e8 64 ee ff ff       	call   102db2 <pte2page>
  103f4e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103f51:	74 24                	je     103f77 <check_pgdir+0x4fc>
  103f53:	c7 44 24 0c 45 6e 10 	movl   $0x106e45,0xc(%esp)
  103f5a:	00 
  103f5b:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103f62:	00 
  103f63:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  103f6a:	00 
  103f6b:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103f72:	e8 7d c4 ff ff       	call   1003f4 <__panic>
    assert((*ptep & PTE_U) == 0);
  103f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103f7a:	8b 00                	mov    (%eax),%eax
  103f7c:	83 e0 04             	and    $0x4,%eax
  103f7f:	85 c0                	test   %eax,%eax
  103f81:	74 24                	je     103fa7 <check_pgdir+0x52c>
  103f83:	c7 44 24 0c 94 6f 10 	movl   $0x106f94,0xc(%esp)
  103f8a:	00 
  103f8b:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103f92:	00 
  103f93:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
  103f9a:	00 
  103f9b:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103fa2:	e8 4d c4 ff ff       	call   1003f4 <__panic>

    page_remove(boot_pgdir, 0x0);
  103fa7:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  103fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  103fb3:	00 
  103fb4:	89 04 24             	mov    %eax,(%esp)
  103fb7:	e8 46 f9 ff ff       	call   103902 <page_remove>
    assert(page_ref(p1) == 1);
  103fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103fbf:	89 04 24             	mov    %eax,(%esp)
  103fc2:	e8 41 ee ff ff       	call   102e08 <page_ref>
  103fc7:	83 f8 01             	cmp    $0x1,%eax
  103fca:	74 24                	je     103ff0 <check_pgdir+0x575>
  103fcc:	c7 44 24 0c 5b 6e 10 	movl   $0x106e5b,0xc(%esp)
  103fd3:	00 
  103fd4:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  103fdb:	00 
  103fdc:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  103fe3:	00 
  103fe4:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  103feb:	e8 04 c4 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p2) == 0);
  103ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103ff3:	89 04 24             	mov    %eax,(%esp)
  103ff6:	e8 0d ee ff ff       	call   102e08 <page_ref>
  103ffb:	85 c0                	test   %eax,%eax
  103ffd:	74 24                	je     104023 <check_pgdir+0x5a8>
  103fff:	c7 44 24 0c 82 6f 10 	movl   $0x106f82,0xc(%esp)
  104006:	00 
  104007:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  10400e:	00 
  10400f:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104016:	00 
  104017:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  10401e:	e8 d1 c3 ff ff       	call   1003f4 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104023:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104028:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  10402f:	00 
  104030:	89 04 24             	mov    %eax,(%esp)
  104033:	e8 ca f8 ff ff       	call   103902 <page_remove>
    assert(page_ref(p1) == 0);
  104038:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10403b:	89 04 24             	mov    %eax,(%esp)
  10403e:	e8 c5 ed ff ff       	call   102e08 <page_ref>
  104043:	85 c0                	test   %eax,%eax
  104045:	74 24                	je     10406b <check_pgdir+0x5f0>
  104047:	c7 44 24 0c a9 6f 10 	movl   $0x106fa9,0xc(%esp)
  10404e:	00 
  10404f:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  104056:	00 
  104057:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  10405e:	00 
  10405f:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104066:	e8 89 c3 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p2) == 0);
  10406b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10406e:	89 04 24             	mov    %eax,(%esp)
  104071:	e8 92 ed ff ff       	call   102e08 <page_ref>
  104076:	85 c0                	test   %eax,%eax
  104078:	74 24                	je     10409e <check_pgdir+0x623>
  10407a:	c7 44 24 0c 82 6f 10 	movl   $0x106f82,0xc(%esp)
  104081:	00 
  104082:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  104089:	00 
  10408a:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
  104091:	00 
  104092:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104099:	e8 56 c3 ff ff       	call   1003f4 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  10409e:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1040a3:	8b 00                	mov    (%eax),%eax
  1040a5:	89 04 24             	mov    %eax,(%esp)
  1040a8:	e8 43 ed ff ff       	call   102df0 <pde2page>
  1040ad:	89 04 24             	mov    %eax,(%esp)
  1040b0:	e8 53 ed ff ff       	call   102e08 <page_ref>
  1040b5:	83 f8 01             	cmp    $0x1,%eax
  1040b8:	74 24                	je     1040de <check_pgdir+0x663>
  1040ba:	c7 44 24 0c bc 6f 10 	movl   $0x106fbc,0xc(%esp)
  1040c1:	00 
  1040c2:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1040c9:	00 
  1040ca:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  1040d1:	00 
  1040d2:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1040d9:	e8 16 c3 ff ff       	call   1003f4 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  1040de:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1040e3:	8b 00                	mov    (%eax),%eax
  1040e5:	89 04 24             	mov    %eax,(%esp)
  1040e8:	e8 03 ed ff ff       	call   102df0 <pde2page>
  1040ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1040f4:	00 
  1040f5:	89 04 24             	mov    %eax,(%esp)
  1040f8:	e8 48 ef ff ff       	call   103045 <free_pages>
    boot_pgdir[0] = 0;
  1040fd:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  104108:	c7 04 24 e3 6f 10 00 	movl   $0x106fe3,(%esp)
  10410f:	e8 89 c1 ff ff       	call   10029d <cprintf>
}
  104114:	90                   	nop
  104115:	c9                   	leave  
  104116:	c3                   	ret    

00104117 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  104117:	55                   	push   %ebp
  104118:	89 e5                	mov    %esp,%ebp
  10411a:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  10411d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104124:	e9 ca 00 00 00       	jmp    1041f3 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  104129:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10412c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10412f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104132:	c1 e8 0c             	shr    $0xc,%eax
  104135:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104138:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  10413d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  104140:	72 23                	jb     104165 <check_boot_pgdir+0x4e>
  104142:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104145:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104149:	c7 44 24 08 e0 6b 10 	movl   $0x106be0,0x8(%esp)
  104150:	00 
  104151:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  104158:	00 
  104159:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104160:	e8 8f c2 ff ff       	call   1003f4 <__panic>
  104165:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104168:	2d 00 00 00 40       	sub    $0x40000000,%eax
  10416d:	89 c2                	mov    %eax,%edx
  10416f:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104174:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10417b:	00 
  10417c:	89 54 24 04          	mov    %edx,0x4(%esp)
  104180:	89 04 24             	mov    %eax,(%esp)
  104183:	e8 7f f5 ff ff       	call   103707 <get_pte>
  104188:	89 45 e8             	mov    %eax,-0x18(%ebp)
  10418b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10418f:	75 24                	jne    1041b5 <check_boot_pgdir+0x9e>
  104191:	c7 44 24 0c 00 70 10 	movl   $0x107000,0xc(%esp)
  104198:	00 
  104199:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1041a0:	00 
  1041a1:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  1041a8:	00 
  1041a9:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1041b0:	e8 3f c2 ff ff       	call   1003f4 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  1041b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1041b8:	8b 00                	mov    (%eax),%eax
  1041ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1041bf:	89 c2                	mov    %eax,%edx
  1041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1041c4:	39 c2                	cmp    %eax,%edx
  1041c6:	74 24                	je     1041ec <check_boot_pgdir+0xd5>
  1041c8:	c7 44 24 0c 3d 70 10 	movl   $0x10703d,0xc(%esp)
  1041cf:	00 
  1041d0:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1041d7:	00 
  1041d8:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
  1041df:	00 
  1041e0:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1041e7:	e8 08 c2 ff ff       	call   1003f4 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  1041ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  1041f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1041f6:	a1 a0 be 11 00       	mov    0x11bea0,%eax
  1041fb:	39 c2                	cmp    %eax,%edx
  1041fd:	0f 82 26 ff ff ff    	jb     104129 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  104203:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  104208:	05 ac 0f 00 00       	add    $0xfac,%eax
  10420d:	8b 00                	mov    (%eax),%eax
  10420f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104214:	89 c2                	mov    %eax,%edx
  104216:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10421b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  10421e:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
  104225:	77 23                	ja     10424a <check_boot_pgdir+0x133>
  104227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10422a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10422e:	c7 44 24 08 cc 6c 10 	movl   $0x106ccc,0x8(%esp)
  104235:	00 
  104236:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  10423d:	00 
  10423e:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104245:	e8 aa c1 ff ff       	call   1003f4 <__panic>
  10424a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10424d:	05 00 00 00 40       	add    $0x40000000,%eax
  104252:	39 c2                	cmp    %eax,%edx
  104254:	74 24                	je     10427a <check_boot_pgdir+0x163>
  104256:	c7 44 24 0c 54 70 10 	movl   $0x107054,0xc(%esp)
  10425d:	00 
  10425e:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  104265:	00 
  104266:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
  10426d:	00 
  10426e:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104275:	e8 7a c1 ff ff       	call   1003f4 <__panic>

    assert(boot_pgdir[0] == 0);
  10427a:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10427f:	8b 00                	mov    (%eax),%eax
  104281:	85 c0                	test   %eax,%eax
  104283:	74 24                	je     1042a9 <check_boot_pgdir+0x192>
  104285:	c7 44 24 0c 88 70 10 	movl   $0x107088,0xc(%esp)
  10428c:	00 
  10428d:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  104294:	00 
  104295:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
  10429c:	00 
  10429d:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1042a4:	e8 4b c1 ff ff       	call   1003f4 <__panic>

    struct Page *p;
    p = alloc_page();
  1042a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1042b0:	e8 58 ed ff ff       	call   10300d <alloc_pages>
  1042b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  1042b8:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  1042bd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  1042c4:	00 
  1042c5:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  1042cc:	00 
  1042cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1042d0:	89 54 24 04          	mov    %edx,0x4(%esp)
  1042d4:	89 04 24             	mov    %eax,(%esp)
  1042d7:	e8 6b f6 ff ff       	call   103947 <page_insert>
  1042dc:	85 c0                	test   %eax,%eax
  1042de:	74 24                	je     104304 <check_boot_pgdir+0x1ed>
  1042e0:	c7 44 24 0c 9c 70 10 	movl   $0x10709c,0xc(%esp)
  1042e7:	00 
  1042e8:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1042ef:	00 
  1042f0:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
  1042f7:	00 
  1042f8:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1042ff:	e8 f0 c0 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p) == 1);
  104304:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104307:	89 04 24             	mov    %eax,(%esp)
  10430a:	e8 f9 ea ff ff       	call   102e08 <page_ref>
  10430f:	83 f8 01             	cmp    $0x1,%eax
  104312:	74 24                	je     104338 <check_boot_pgdir+0x221>
  104314:	c7 44 24 0c ca 70 10 	movl   $0x1070ca,0xc(%esp)
  10431b:	00 
  10431c:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  104323:	00 
  104324:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
  10432b:	00 
  10432c:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104333:	e8 bc c0 ff ff       	call   1003f4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  104338:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10433d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  104344:	00 
  104345:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10434c:	00 
  10434d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104350:	89 54 24 04          	mov    %edx,0x4(%esp)
  104354:	89 04 24             	mov    %eax,(%esp)
  104357:	e8 eb f5 ff ff       	call   103947 <page_insert>
  10435c:	85 c0                	test   %eax,%eax
  10435e:	74 24                	je     104384 <check_boot_pgdir+0x26d>
  104360:	c7 44 24 0c dc 70 10 	movl   $0x1070dc,0xc(%esp)
  104367:	00 
  104368:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  10436f:	00 
  104370:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
  104377:	00 
  104378:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  10437f:	e8 70 c0 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p) == 2);
  104384:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104387:	89 04 24             	mov    %eax,(%esp)
  10438a:	e8 79 ea ff ff       	call   102e08 <page_ref>
  10438f:	83 f8 02             	cmp    $0x2,%eax
  104392:	74 24                	je     1043b8 <check_boot_pgdir+0x2a1>
  104394:	c7 44 24 0c 13 71 10 	movl   $0x107113,0xc(%esp)
  10439b:	00 
  10439c:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1043a3:	00 
  1043a4:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
  1043ab:	00 
  1043ac:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  1043b3:	e8 3c c0 ff ff       	call   1003f4 <__panic>

    const char *str = "ucore: Hello world!!";
  1043b8:	c7 45 dc 24 71 10 00 	movl   $0x107124,-0x24(%ebp)
    strcpy((void *)0x100, str);
  1043bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1043c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  1043c6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1043cd:	e8 df 15 00 00       	call   1059b1 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1043d2:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1043d9:	00 
  1043da:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1043e1:	e8 42 16 00 00       	call   105a28 <strcmp>
  1043e6:	85 c0                	test   %eax,%eax
  1043e8:	74 24                	je     10440e <check_boot_pgdir+0x2f7>
  1043ea:	c7 44 24 0c 3c 71 10 	movl   $0x10713c,0xc(%esp)
  1043f1:	00 
  1043f2:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  1043f9:	00 
  1043fa:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
  104401:	00 
  104402:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104409:	e8 e6 bf ff ff       	call   1003f4 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  10440e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104411:	89 04 24             	mov    %eax,(%esp)
  104414:	e8 45 e9 ff ff       	call   102d5e <page2kva>
  104419:	05 00 01 00 00       	add    $0x100,%eax
  10441e:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  104421:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  104428:	e8 2e 15 00 00       	call   10595b <strlen>
  10442d:	85 c0                	test   %eax,%eax
  10442f:	74 24                	je     104455 <check_boot_pgdir+0x33e>
  104431:	c7 44 24 0c 74 71 10 	movl   $0x107174,0xc(%esp)
  104438:	00 
  104439:	c7 44 24 08 15 6d 10 	movl   $0x106d15,0x8(%esp)
  104440:	00 
  104441:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
  104448:	00 
  104449:	c7 04 24 f0 6c 10 00 	movl   $0x106cf0,(%esp)
  104450:	e8 9f bf ff ff       	call   1003f4 <__panic>

    free_page(p);
  104455:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10445c:	00 
  10445d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104460:	89 04 24             	mov    %eax,(%esp)
  104463:	e8 dd eb ff ff       	call   103045 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  104468:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10446d:	8b 00                	mov    (%eax),%eax
  10446f:	89 04 24             	mov    %eax,(%esp)
  104472:	e8 79 e9 ff ff       	call   102df0 <pde2page>
  104477:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10447e:	00 
  10447f:	89 04 24             	mov    %eax,(%esp)
  104482:	e8 be eb ff ff       	call   103045 <free_pages>
    boot_pgdir[0] = 0;
  104487:	a1 e0 89 11 00       	mov    0x1189e0,%eax
  10448c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  104492:	c7 04 24 98 71 10 00 	movl   $0x107198,(%esp)
  104499:	e8 ff bd ff ff       	call   10029d <cprintf>
}
  10449e:	90                   	nop
  10449f:	c9                   	leave  
  1044a0:	c3                   	ret    

001044a1 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  1044a1:	55                   	push   %ebp
  1044a2:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  1044a4:	8b 45 08             	mov    0x8(%ebp),%eax
  1044a7:	83 e0 04             	and    $0x4,%eax
  1044aa:	85 c0                	test   %eax,%eax
  1044ac:	74 04                	je     1044b2 <perm2str+0x11>
  1044ae:	b0 75                	mov    $0x75,%al
  1044b0:	eb 02                	jmp    1044b4 <perm2str+0x13>
  1044b2:	b0 2d                	mov    $0x2d,%al
  1044b4:	a2 28 bf 11 00       	mov    %al,0x11bf28
    str[1] = 'r';
  1044b9:	c6 05 29 bf 11 00 72 	movb   $0x72,0x11bf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
  1044c0:	8b 45 08             	mov    0x8(%ebp),%eax
  1044c3:	83 e0 02             	and    $0x2,%eax
  1044c6:	85 c0                	test   %eax,%eax
  1044c8:	74 04                	je     1044ce <perm2str+0x2d>
  1044ca:	b0 77                	mov    $0x77,%al
  1044cc:	eb 02                	jmp    1044d0 <perm2str+0x2f>
  1044ce:	b0 2d                	mov    $0x2d,%al
  1044d0:	a2 2a bf 11 00       	mov    %al,0x11bf2a
    str[3] = '\0';
  1044d5:	c6 05 2b bf 11 00 00 	movb   $0x0,0x11bf2b
    return str;
  1044dc:	b8 28 bf 11 00       	mov    $0x11bf28,%eax
}
  1044e1:	5d                   	pop    %ebp
  1044e2:	c3                   	ret    

001044e3 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1044e3:	55                   	push   %ebp
  1044e4:	89 e5                	mov    %esp,%ebp
  1044e6:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1044e9:	8b 45 10             	mov    0x10(%ebp),%eax
  1044ec:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1044ef:	72 0d                	jb     1044fe <get_pgtable_items+0x1b>
        return 0;
  1044f1:	b8 00 00 00 00       	mov    $0x0,%eax
  1044f6:	e9 98 00 00 00       	jmp    104593 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1044fb:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
  1044fe:	8b 45 10             	mov    0x10(%ebp),%eax
  104501:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104504:	73 18                	jae    10451e <get_pgtable_items+0x3b>
  104506:	8b 45 10             	mov    0x10(%ebp),%eax
  104509:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104510:	8b 45 14             	mov    0x14(%ebp),%eax
  104513:	01 d0                	add    %edx,%eax
  104515:	8b 00                	mov    (%eax),%eax
  104517:	83 e0 01             	and    $0x1,%eax
  10451a:	85 c0                	test   %eax,%eax
  10451c:	74 dd                	je     1044fb <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
  10451e:	8b 45 10             	mov    0x10(%ebp),%eax
  104521:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104524:	73 68                	jae    10458e <get_pgtable_items+0xab>
        if (left_store != NULL) {
  104526:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  10452a:	74 08                	je     104534 <get_pgtable_items+0x51>
            *left_store = start;
  10452c:	8b 45 18             	mov    0x18(%ebp),%eax
  10452f:	8b 55 10             	mov    0x10(%ebp),%edx
  104532:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  104534:	8b 45 10             	mov    0x10(%ebp),%eax
  104537:	8d 50 01             	lea    0x1(%eax),%edx
  10453a:	89 55 10             	mov    %edx,0x10(%ebp)
  10453d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104544:	8b 45 14             	mov    0x14(%ebp),%eax
  104547:	01 d0                	add    %edx,%eax
  104549:	8b 00                	mov    (%eax),%eax
  10454b:	83 e0 07             	and    $0x7,%eax
  10454e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  104551:	eb 03                	jmp    104556 <get_pgtable_items+0x73>
            start ++;
  104553:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
  104556:	8b 45 10             	mov    0x10(%ebp),%eax
  104559:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10455c:	73 1d                	jae    10457b <get_pgtable_items+0x98>
  10455e:	8b 45 10             	mov    0x10(%ebp),%eax
  104561:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  104568:	8b 45 14             	mov    0x14(%ebp),%eax
  10456b:	01 d0                	add    %edx,%eax
  10456d:	8b 00                	mov    (%eax),%eax
  10456f:	83 e0 07             	and    $0x7,%eax
  104572:	89 c2                	mov    %eax,%edx
  104574:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104577:	39 c2                	cmp    %eax,%edx
  104579:	74 d8                	je     104553 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
  10457b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  10457f:	74 08                	je     104589 <get_pgtable_items+0xa6>
            *right_store = start;
  104581:	8b 45 1c             	mov    0x1c(%ebp),%eax
  104584:	8b 55 10             	mov    0x10(%ebp),%edx
  104587:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  104589:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10458c:	eb 05                	jmp    104593 <get_pgtable_items+0xb0>
    }
    return 0;
  10458e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104593:	c9                   	leave  
  104594:	c3                   	ret    

00104595 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  104595:	55                   	push   %ebp
  104596:	89 e5                	mov    %esp,%ebp
  104598:	57                   	push   %edi
  104599:	56                   	push   %esi
  10459a:	53                   	push   %ebx
  10459b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  10459e:	c7 04 24 b8 71 10 00 	movl   $0x1071b8,(%esp)
  1045a5:	e8 f3 bc ff ff       	call   10029d <cprintf>
    size_t left, right = 0, perm;
  1045aa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1045b1:	e9 fa 00 00 00       	jmp    1046b0 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1045b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1045b9:	89 04 24             	mov    %eax,(%esp)
  1045bc:	e8 e0 fe ff ff       	call   1044a1 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  1045c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1045c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1045c7:	29 d1                	sub    %edx,%ecx
  1045c9:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1045cb:	89 d6                	mov    %edx,%esi
  1045cd:	c1 e6 16             	shl    $0x16,%esi
  1045d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1045d3:	89 d3                	mov    %edx,%ebx
  1045d5:	c1 e3 16             	shl    $0x16,%ebx
  1045d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1045db:	89 d1                	mov    %edx,%ecx
  1045dd:	c1 e1 16             	shl    $0x16,%ecx
  1045e0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  1045e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1045e6:	29 d7                	sub    %edx,%edi
  1045e8:	89 fa                	mov    %edi,%edx
  1045ea:	89 44 24 14          	mov    %eax,0x14(%esp)
  1045ee:	89 74 24 10          	mov    %esi,0x10(%esp)
  1045f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1045f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1045fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1045fe:	c7 04 24 e9 71 10 00 	movl   $0x1071e9,(%esp)
  104605:	e8 93 bc ff ff       	call   10029d <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
  10460a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10460d:	c1 e0 0a             	shl    $0xa,%eax
  104610:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104613:	eb 54                	jmp    104669 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  104615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104618:	89 04 24             	mov    %eax,(%esp)
  10461b:	e8 81 fe ff ff       	call   1044a1 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  104620:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  104623:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104626:	29 d1                	sub    %edx,%ecx
  104628:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  10462a:	89 d6                	mov    %edx,%esi
  10462c:	c1 e6 0c             	shl    $0xc,%esi
  10462f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104632:	89 d3                	mov    %edx,%ebx
  104634:	c1 e3 0c             	shl    $0xc,%ebx
  104637:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10463a:	89 d1                	mov    %edx,%ecx
  10463c:	c1 e1 0c             	shl    $0xc,%ecx
  10463f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  104642:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104645:	29 d7                	sub    %edx,%edi
  104647:	89 fa                	mov    %edi,%edx
  104649:	89 44 24 14          	mov    %eax,0x14(%esp)
  10464d:	89 74 24 10          	mov    %esi,0x10(%esp)
  104651:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  104655:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  104659:	89 54 24 04          	mov    %edx,0x4(%esp)
  10465d:	c7 04 24 08 72 10 00 	movl   $0x107208,(%esp)
  104664:	e8 34 bc ff ff       	call   10029d <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  104669:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10466e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104671:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104674:	89 d3                	mov    %edx,%ebx
  104676:	c1 e3 0a             	shl    $0xa,%ebx
  104679:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10467c:	89 d1                	mov    %edx,%ecx
  10467e:	c1 e1 0a             	shl    $0xa,%ecx
  104681:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  104684:	89 54 24 14          	mov    %edx,0x14(%esp)
  104688:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10468b:	89 54 24 10          	mov    %edx,0x10(%esp)
  10468f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  104693:	89 44 24 08          	mov    %eax,0x8(%esp)
  104697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10469b:	89 0c 24             	mov    %ecx,(%esp)
  10469e:	e8 40 fe ff ff       	call   1044e3 <get_pgtable_items>
  1046a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1046a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1046aa:	0f 85 65 ff ff ff    	jne    104615 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  1046b0:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  1046b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1046b8:	8d 55 dc             	lea    -0x24(%ebp),%edx
  1046bb:	89 54 24 14          	mov    %edx,0x14(%esp)
  1046bf:	8d 55 e0             	lea    -0x20(%ebp),%edx
  1046c2:	89 54 24 10          	mov    %edx,0x10(%esp)
  1046c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1046ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  1046ce:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1046d5:	00 
  1046d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1046dd:	e8 01 fe ff ff       	call   1044e3 <get_pgtable_items>
  1046e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1046e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1046e9:	0f 85 c7 fe ff ff    	jne    1045b6 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1046ef:	c7 04 24 2c 72 10 00 	movl   $0x10722c,(%esp)
  1046f6:	e8 a2 bb ff ff       	call   10029d <cprintf>
}
  1046fb:	90                   	nop
  1046fc:	83 c4 4c             	add    $0x4c,%esp
  1046ff:	5b                   	pop    %ebx
  104700:	5e                   	pop    %esi
  104701:	5f                   	pop    %edi
  104702:	5d                   	pop    %ebp
  104703:	c3                   	ret    

00104704 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  104704:	55                   	push   %ebp
  104705:	89 e5                	mov    %esp,%ebp
    return page - pages;
  104707:	8b 45 08             	mov    0x8(%ebp),%eax
  10470a:	8b 15 98 bf 11 00    	mov    0x11bf98,%edx
  104710:	29 d0                	sub    %edx,%eax
  104712:	c1 f8 02             	sar    $0x2,%eax
  104715:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  10471b:	5d                   	pop    %ebp
  10471c:	c3                   	ret    

0010471d <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  10471d:	55                   	push   %ebp
  10471e:	89 e5                	mov    %esp,%ebp
  104720:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  104723:	8b 45 08             	mov    0x8(%ebp),%eax
  104726:	89 04 24             	mov    %eax,(%esp)
  104729:	e8 d6 ff ff ff       	call   104704 <page2ppn>
  10472e:	c1 e0 0c             	shl    $0xc,%eax
}
  104731:	c9                   	leave  
  104732:	c3                   	ret    

00104733 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  104733:	55                   	push   %ebp
  104734:	89 e5                	mov    %esp,%ebp
    return page->ref;
  104736:	8b 45 08             	mov    0x8(%ebp),%eax
  104739:	8b 00                	mov    (%eax),%eax
}
  10473b:	5d                   	pop    %ebp
  10473c:	c3                   	ret    

0010473d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  10473d:	55                   	push   %ebp
  10473e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  104740:	8b 45 08             	mov    0x8(%ebp),%eax
  104743:	8b 55 0c             	mov    0xc(%ebp),%edx
  104746:	89 10                	mov    %edx,(%eax)
}
  104748:	90                   	nop
  104749:	5d                   	pop    %ebp
  10474a:	c3                   	ret    

0010474b <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  10474b:	55                   	push   %ebp
  10474c:	89 e5                	mov    %esp,%ebp
  10474e:	83 ec 10             	sub    $0x10,%esp
  104751:	c7 45 fc 9c bf 11 00 	movl   $0x11bf9c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104758:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10475b:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10475e:	89 50 04             	mov    %edx,0x4(%eax)
  104761:	8b 45 fc             	mov    -0x4(%ebp),%eax
  104764:	8b 50 04             	mov    0x4(%eax),%edx
  104767:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10476a:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
  10476c:	c7 05 a4 bf 11 00 00 	movl   $0x0,0x11bfa4
  104773:	00 00 00 
}
  104776:	90                   	nop
  104777:	c9                   	leave  
  104778:	c3                   	ret    

00104779 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  104779:	55                   	push   %ebp
  10477a:	89 e5                	mov    %esp,%ebp
  10477c:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
  10477f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104783:	75 24                	jne    1047a9 <default_init_memmap+0x30>
  104785:	c7 44 24 0c 60 72 10 	movl   $0x107260,0xc(%esp)
  10478c:	00 
  10478d:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104794:	00 
  104795:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
  10479c:	00 
  10479d:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1047a4:	e8 4b bc ff ff       	call   1003f4 <__panic>
    struct Page *p = base;
  1047a9:	8b 45 08             	mov    0x8(%ebp),%eax
  1047ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  1047af:	eb 7d                	jmp    10482e <default_init_memmap+0xb5>
        assert(PageReserved(p));
  1047b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047b4:	83 c0 04             	add    $0x4,%eax
  1047b7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
  1047be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1047c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1047c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1047c7:	0f a3 10             	bt     %edx,(%eax)
  1047ca:	19 c0                	sbb    %eax,%eax
  1047cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
  1047cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  1047d3:	0f 95 c0             	setne  %al
  1047d6:	0f b6 c0             	movzbl %al,%eax
  1047d9:	85 c0                	test   %eax,%eax
  1047db:	75 24                	jne    104801 <default_init_memmap+0x88>
  1047dd:	c7 44 24 0c 91 72 10 	movl   $0x107291,0xc(%esp)
  1047e4:	00 
  1047e5:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1047ec:	00 
  1047ed:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
  1047f4:	00 
  1047f5:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1047fc:	e8 f3 bb ff ff       	call   1003f4 <__panic>
        p->flags = p->property = 0;
  104801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104804:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  10480b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10480e:	8b 50 08             	mov    0x8(%eax),%edx
  104811:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104814:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  104817:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  10481e:	00 
  10481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104822:	89 04 24             	mov    %eax,(%esp)
  104825:	e8 13 ff ff ff       	call   10473d <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  10482a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  10482e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104831:	89 d0                	mov    %edx,%eax
  104833:	c1 e0 02             	shl    $0x2,%eax
  104836:	01 d0                	add    %edx,%eax
  104838:	c1 e0 02             	shl    $0x2,%eax
  10483b:	89 c2                	mov    %eax,%edx
  10483d:	8b 45 08             	mov    0x8(%ebp),%eax
  104840:	01 d0                	add    %edx,%eax
  104842:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104845:	0f 85 66 ff ff ff    	jne    1047b1 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
  10484b:	8b 45 08             	mov    0x8(%ebp),%eax
  10484e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104851:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104854:	8b 45 08             	mov    0x8(%ebp),%eax
  104857:	83 c0 04             	add    $0x4,%eax
  10485a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  104861:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104864:	8b 45 cc             	mov    -0x34(%ebp),%eax
  104867:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10486a:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
  10486d:	8b 15 a4 bf 11 00    	mov    0x11bfa4,%edx
  104873:	8b 45 0c             	mov    0xc(%ebp),%eax
  104876:	01 d0                	add    %edx,%eax
  104878:	a3 a4 bf 11 00       	mov    %eax,0x11bfa4
    list_add_before(&free_list, &(base->page_link));
  10487d:	8b 45 08             	mov    0x8(%ebp),%eax
  104880:	83 c0 0c             	add    $0xc,%eax
  104883:	c7 45 f0 9c bf 11 00 	movl   $0x11bf9c,-0x10(%ebp)
  10488a:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  10488d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104890:	8b 00                	mov    (%eax),%eax
  104892:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104895:	89 55 d8             	mov    %edx,-0x28(%ebp)
  104898:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  10489b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10489e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1048a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1048a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  1048a7:	89 10                	mov    %edx,(%eax)
  1048a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1048ac:	8b 10                	mov    (%eax),%edx
  1048ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1048b1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1048b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1048b7:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1048ba:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1048bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1048c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1048c3:	89 10                	mov    %edx,(%eax)
}
  1048c5:	90                   	nop
  1048c6:	c9                   	leave  
  1048c7:	c3                   	ret    

001048c8 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
  1048c8:	55                   	push   %ebp
  1048c9:	89 e5                	mov    %esp,%ebp
  1048cb:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
  1048ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  1048d2:	75 24                	jne    1048f8 <default_alloc_pages+0x30>
  1048d4:	c7 44 24 0c 60 72 10 	movl   $0x107260,0xc(%esp)
  1048db:	00 
  1048dc:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1048e3:	00 
  1048e4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
  1048eb:	00 
  1048ec:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1048f3:	e8 fc ba ff ff       	call   1003f4 <__panic>
    if (n > nr_free) {
  1048f8:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  1048fd:	3b 45 08             	cmp    0x8(%ebp),%eax
  104900:	73 0a                	jae    10490c <default_alloc_pages+0x44>
        return NULL;
  104902:	b8 00 00 00 00       	mov    $0x0,%eax
  104907:	e9 49 01 00 00       	jmp    104a55 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
  10490c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  104913:	c7 45 f0 9c bf 11 00 	movl   $0x11bf9c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10491a:	eb 1c                	jmp    104938 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
  10491c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10491f:	83 e8 0c             	sub    $0xc,%eax
  104922:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
  104925:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104928:	8b 40 08             	mov    0x8(%eax),%eax
  10492b:	3b 45 08             	cmp    0x8(%ebp),%eax
  10492e:	72 08                	jb     104938 <default_alloc_pages+0x70>
            page = p;
  104930:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104933:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  104936:	eb 18                	jmp    104950 <default_alloc_pages+0x88>
  104938:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10493b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10493e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  104941:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  104944:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104947:	81 7d f0 9c bf 11 00 	cmpl   $0x11bf9c,-0x10(%ebp)
  10494e:	75 cc                	jne    10491c <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
  104950:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104954:	0f 84 f8 00 00 00    	je     104a52 <default_alloc_pages+0x18a>
        if (page->property > n) {
  10495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10495d:	8b 40 08             	mov    0x8(%eax),%eax
  104960:	3b 45 08             	cmp    0x8(%ebp),%eax
  104963:	0f 86 98 00 00 00    	jbe    104a01 <default_alloc_pages+0x139>
            struct Page *p = page + n;
  104969:	8b 55 08             	mov    0x8(%ebp),%edx
  10496c:	89 d0                	mov    %edx,%eax
  10496e:	c1 e0 02             	shl    $0x2,%eax
  104971:	01 d0                	add    %edx,%eax
  104973:	c1 e0 02             	shl    $0x2,%eax
  104976:	89 c2                	mov    %eax,%edx
  104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10497b:	01 d0                	add    %edx,%eax
  10497d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
  104980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104983:	8b 40 08             	mov    0x8(%eax),%eax
  104986:	2b 45 08             	sub    0x8(%ebp),%eax
  104989:	89 c2                	mov    %eax,%edx
  10498b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10498e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  104991:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104994:	83 c0 04             	add    $0x4,%eax
  104997:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
  10499e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  1049a1:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1049a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1049a7:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
  1049aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1049ad:	83 c0 0c             	add    $0xc,%eax
  1049b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1049b3:	83 c2 0c             	add    $0xc,%edx
  1049b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
  1049b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1049bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1049bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  1049c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1049c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  1049c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1049cb:	8b 40 04             	mov    0x4(%eax),%eax
  1049ce:	8b 55 c8             	mov    -0x38(%ebp),%edx
  1049d1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  1049d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  1049d7:	89 55 c0             	mov    %edx,-0x40(%ebp)
  1049da:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  1049dd:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1049e0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  1049e3:	89 10                	mov    %edx,(%eax)
  1049e5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  1049e8:	8b 10                	mov    (%eax),%edx
  1049ea:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1049ed:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  1049f0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1049f3:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1049f6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  1049f9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1049fc:	8b 55 c0             	mov    -0x40(%ebp),%edx
  1049ff:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
  104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a04:	83 c0 0c             	add    $0xc,%eax
  104a07:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  104a0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104a0d:	8b 40 04             	mov    0x4(%eax),%eax
  104a10:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104a13:	8b 12                	mov    (%edx),%edx
  104a15:	89 55 b0             	mov    %edx,-0x50(%ebp)
  104a18:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104a1b:	8b 45 b0             	mov    -0x50(%ebp),%eax
  104a1e:	8b 55 ac             	mov    -0x54(%ebp),%edx
  104a21:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104a24:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104a27:	8b 55 b0             	mov    -0x50(%ebp),%edx
  104a2a:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
  104a2c:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  104a31:	2b 45 08             	sub    0x8(%ebp),%eax
  104a34:	a3 a4 bf 11 00       	mov    %eax,0x11bfa4
        ClearPageProperty(page);
  104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a3c:	83 c0 04             	add    $0x4,%eax
  104a3f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  104a46:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104a49:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104a4c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104a4f:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
  104a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104a55:	c9                   	leave  
  104a56:	c3                   	ret    

00104a57 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
  104a57:	55                   	push   %ebp
  104a58:	89 e5                	mov    %esp,%ebp
  104a5a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  104a60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  104a64:	75 24                	jne    104a8a <default_free_pages+0x33>
  104a66:	c7 44 24 0c 60 72 10 	movl   $0x107260,0xc(%esp)
  104a6d:	00 
  104a6e:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104a75:	00 
  104a76:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
  104a7d:	00 
  104a7e:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104a85:	e8 6a b9 ff ff       	call   1003f4 <__panic>
    struct Page *p = base;
  104a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  104a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  104a90:	e9 9d 00 00 00       	jmp    104b32 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a98:	83 c0 04             	add    $0x4,%eax
  104a9b:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
  104aa2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104aa5:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104aa8:	8b 55 c0             	mov    -0x40(%ebp),%edx
  104aab:	0f a3 10             	bt     %edx,(%eax)
  104aae:	19 c0                	sbb    %eax,%eax
  104ab0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  104ab3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  104ab7:	0f 95 c0             	setne  %al
  104aba:	0f b6 c0             	movzbl %al,%eax
  104abd:	85 c0                	test   %eax,%eax
  104abf:	75 2c                	jne    104aed <default_free_pages+0x96>
  104ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104ac4:	83 c0 04             	add    $0x4,%eax
  104ac7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
  104ace:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  104ad1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104ad4:	8b 55 ec             	mov    -0x14(%ebp),%edx
  104ad7:	0f a3 10             	bt     %edx,(%eax)
  104ada:	19 c0                	sbb    %eax,%eax
  104adc:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
  104adf:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
  104ae3:	0f 95 c0             	setne  %al
  104ae6:	0f b6 c0             	movzbl %al,%eax
  104ae9:	85 c0                	test   %eax,%eax
  104aeb:	74 24                	je     104b11 <default_free_pages+0xba>
  104aed:	c7 44 24 0c a4 72 10 	movl   $0x1072a4,0xc(%esp)
  104af4:	00 
  104af5:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104afc:	00 
  104afd:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
  104b04:	00 
  104b05:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104b0c:	e8 e3 b8 ff ff       	call   1003f4 <__panic>
        p->flags=0;
  104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b14:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  104b1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104b22:	00 
  104b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104b26:	89 04 24             	mov    %eax,(%esp)
  104b29:	e8 0f fc ff ff       	call   10473d <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
  104b2e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  104b32:	8b 55 0c             	mov    0xc(%ebp),%edx
  104b35:	89 d0                	mov    %edx,%eax
  104b37:	c1 e0 02             	shl    $0x2,%eax
  104b3a:	01 d0                	add    %edx,%eax
  104b3c:	c1 e0 02             	shl    $0x2,%eax
  104b3f:	89 c2                	mov    %eax,%edx
  104b41:	8b 45 08             	mov    0x8(%ebp),%eax
  104b44:	01 d0                	add    %edx,%eax
  104b46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104b49:	0f 85 46 ff ff ff    	jne    104a95 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags=0;
        set_page_ref(p, 0);
    }
    base->property = n;
  104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
  104b52:	8b 55 0c             	mov    0xc(%ebp),%edx
  104b55:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  104b58:	8b 45 08             	mov    0x8(%ebp),%eax
  104b5b:	83 c0 04             	add    $0x4,%eax
  104b5e:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  104b65:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104b68:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104b6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  104b6e:	0f ab 10             	bts    %edx,(%eax)
  104b71:	c7 45 e8 9c bf 11 00 	movl   $0x11bf9c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104b78:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104b7b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
  104b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  104b81:	e9 06 01 00 00       	jmp    104c8c <default_free_pages+0x235>
        p = le2page(le, page_link);
  104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b89:	83 e8 0c             	sub    $0xc,%eax
  104b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104b92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104b98:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  104b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
  104b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  104ba1:	8b 50 08             	mov    0x8(%eax),%edx
  104ba4:	89 d0                	mov    %edx,%eax
  104ba6:	c1 e0 02             	shl    $0x2,%eax
  104ba9:	01 d0                	add    %edx,%eax
  104bab:	c1 e0 02             	shl    $0x2,%eax
  104bae:	89 c2                	mov    %eax,%edx
  104bb0:	8b 45 08             	mov    0x8(%ebp),%eax
  104bb3:	01 d0                	add    %edx,%eax
  104bb5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104bb8:	75 58                	jne    104c12 <default_free_pages+0x1bb>
            base->property += p->property;
  104bba:	8b 45 08             	mov    0x8(%ebp),%eax
  104bbd:	8b 50 08             	mov    0x8(%eax),%edx
  104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bc3:	8b 40 08             	mov    0x8(%eax),%eax
  104bc6:	01 c2                	add    %eax,%edx
  104bc8:	8b 45 08             	mov    0x8(%ebp),%eax
  104bcb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bd1:	83 c0 04             	add    $0x4,%eax
  104bd4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  104bdb:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  104bde:	8b 45 a0             	mov    -0x60(%ebp),%eax
  104be1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104be4:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
  104be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104bea:	83 c0 0c             	add    $0xc,%eax
  104bed:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  104bf0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  104bf3:	8b 40 04             	mov    0x4(%eax),%eax
  104bf6:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104bf9:	8b 12                	mov    (%edx),%edx
  104bfb:	89 55 a8             	mov    %edx,-0x58(%ebp)
  104bfe:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104c01:	8b 45 a8             	mov    -0x58(%ebp),%eax
  104c04:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  104c07:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104c0a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  104c0d:	8b 55 a8             	mov    -0x58(%ebp),%edx
  104c10:	89 10                	mov    %edx,(%eax)
        }
        if (p + p->property == base) {
  104c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c15:	8b 50 08             	mov    0x8(%eax),%edx
  104c18:	89 d0                	mov    %edx,%eax
  104c1a:	c1 e0 02             	shl    $0x2,%eax
  104c1d:	01 d0                	add    %edx,%eax
  104c1f:	c1 e0 02             	shl    $0x2,%eax
  104c22:	89 c2                	mov    %eax,%edx
  104c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c27:	01 d0                	add    %edx,%eax
  104c29:	3b 45 08             	cmp    0x8(%ebp),%eax
  104c2c:	75 5e                	jne    104c8c <default_free_pages+0x235>
            p->property += base->property;
  104c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c31:	8b 50 08             	mov    0x8(%eax),%edx
  104c34:	8b 45 08             	mov    0x8(%ebp),%eax
  104c37:	8b 40 08             	mov    0x8(%eax),%eax
  104c3a:	01 c2                	add    %eax,%edx
  104c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c3f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  104c42:	8b 45 08             	mov    0x8(%ebp),%eax
  104c45:	83 c0 04             	add    $0x4,%eax
  104c48:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  104c4f:	89 45 94             	mov    %eax,-0x6c(%ebp)
  104c52:	8b 45 94             	mov    -0x6c(%ebp),%eax
  104c55:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104c58:	0f b3 10             	btr    %edx,(%eax)
            base = p;
  104c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c5e:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  104c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104c64:	83 c0 0c             	add    $0xc,%eax
  104c67:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
  104c6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104c6d:	8b 40 04             	mov    0x4(%eax),%eax
  104c70:	8b 55 d8             	mov    -0x28(%ebp),%edx
  104c73:	8b 12                	mov    (%edx),%edx
  104c75:	89 55 9c             	mov    %edx,-0x64(%ebp)
  104c78:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  104c7b:	8b 45 9c             	mov    -0x64(%ebp),%eax
  104c7e:	8b 55 98             	mov    -0x68(%ebp),%edx
  104c81:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  104c84:	8b 45 98             	mov    -0x68(%ebp),%eax
  104c87:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104c8a:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
  104c8c:	81 7d f0 9c bf 11 00 	cmpl   $0x11bf9c,-0x10(%ebp)
  104c93:	0f 85 ed fe ff ff    	jne    104b86 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
  104c99:	8b 15 a4 bf 11 00    	mov    0x11bfa4,%edx
  104c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  104ca2:	01 d0                	add    %edx,%eax
  104ca4:	a3 a4 bf 11 00       	mov    %eax,0x11bfa4
  104ca9:	c7 45 d0 9c bf 11 00 	movl   $0x11bf9c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  104cb0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104cb3:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  104cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  104cb9:	eb 74                	jmp    104d2f <default_free_pages+0x2d8>
        p = le2page(le, page_link);
  104cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104cbe:	83 e8 0c             	sub    $0xc,%eax
  104cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  104cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  104cc7:	8b 50 08             	mov    0x8(%eax),%edx
  104cca:	89 d0                	mov    %edx,%eax
  104ccc:	c1 e0 02             	shl    $0x2,%eax
  104ccf:	01 d0                	add    %edx,%eax
  104cd1:	c1 e0 02             	shl    $0x2,%eax
  104cd4:	89 c2                	mov    %eax,%edx
  104cd6:	8b 45 08             	mov    0x8(%ebp),%eax
  104cd9:	01 d0                	add    %edx,%eax
  104cdb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104cde:	77 40                	ja     104d20 <default_free_pages+0x2c9>
            assert(base + base->property != p);
  104ce0:	8b 45 08             	mov    0x8(%ebp),%eax
  104ce3:	8b 50 08             	mov    0x8(%eax),%edx
  104ce6:	89 d0                	mov    %edx,%eax
  104ce8:	c1 e0 02             	shl    $0x2,%eax
  104ceb:	01 d0                	add    %edx,%eax
  104ced:	c1 e0 02             	shl    $0x2,%eax
  104cf0:	89 c2                	mov    %eax,%edx
  104cf2:	8b 45 08             	mov    0x8(%ebp),%eax
  104cf5:	01 d0                	add    %edx,%eax
  104cf7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104cfa:	75 3e                	jne    104d3a <default_free_pages+0x2e3>
  104cfc:	c7 44 24 0c c9 72 10 	movl   $0x1072c9,0xc(%esp)
  104d03:	00 
  104d04:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104d0b:	00 
  104d0c:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
  104d13:	00 
  104d14:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104d1b:	e8 d4 b6 ff ff       	call   1003f4 <__panic>
  104d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d23:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104d26:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104d29:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
  104d2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
  104d2f:	81 7d f0 9c bf 11 00 	cmpl   $0x11bf9c,-0x10(%ebp)
  104d36:	75 83                	jne    104cbb <default_free_pages+0x264>
  104d38:	eb 01                	jmp    104d3b <default_free_pages+0x2e4>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
  104d3a:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
  104d3b:	8b 45 08             	mov    0x8(%ebp),%eax
  104d3e:	8d 50 0c             	lea    0xc(%eax),%edx
  104d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d44:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  104d47:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
  104d4a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104d4d:	8b 00                	mov    (%eax),%eax
  104d4f:	8b 55 90             	mov    -0x70(%ebp),%edx
  104d52:	89 55 8c             	mov    %edx,-0x74(%ebp)
  104d55:	89 45 88             	mov    %eax,-0x78(%ebp)
  104d58:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104d5b:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  104d5e:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104d61:	8b 55 8c             	mov    -0x74(%ebp),%edx
  104d64:	89 10                	mov    %edx,(%eax)
  104d66:	8b 45 84             	mov    -0x7c(%ebp),%eax
  104d69:	8b 10                	mov    (%eax),%edx
  104d6b:	8b 45 88             	mov    -0x78(%ebp),%eax
  104d6e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  104d71:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104d74:	8b 55 84             	mov    -0x7c(%ebp),%edx
  104d77:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  104d7a:	8b 45 8c             	mov    -0x74(%ebp),%eax
  104d7d:	8b 55 88             	mov    -0x78(%ebp),%edx
  104d80:	89 10                	mov    %edx,(%eax)
}
  104d82:	90                   	nop
  104d83:	c9                   	leave  
  104d84:	c3                   	ret    

00104d85 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
  104d85:	55                   	push   %ebp
  104d86:	89 e5                	mov    %esp,%ebp
    return nr_free;
  104d88:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
}
  104d8d:	5d                   	pop    %ebp
  104d8e:	c3                   	ret    

00104d8f <basic_check>:

static void
basic_check(void) {
  104d8f:	55                   	push   %ebp
  104d90:	89 e5                	mov    %esp,%ebp
  104d92:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  104d95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  104d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104d9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  104da8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104daf:	e8 59 e2 ff ff       	call   10300d <alloc_pages>
  104db4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104db7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  104dbb:	75 24                	jne    104de1 <basic_check+0x52>
  104dbd:	c7 44 24 0c e4 72 10 	movl   $0x1072e4,0xc(%esp)
  104dc4:	00 
  104dc5:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104dcc:	00 
  104dcd:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
  104dd4:	00 
  104dd5:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104ddc:	e8 13 b6 ff ff       	call   1003f4 <__panic>
    assert((p1 = alloc_page()) != NULL);
  104de1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104de8:	e8 20 e2 ff ff       	call   10300d <alloc_pages>
  104ded:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104df0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104df4:	75 24                	jne    104e1a <basic_check+0x8b>
  104df6:	c7 44 24 0c 00 73 10 	movl   $0x107300,0xc(%esp)
  104dfd:	00 
  104dfe:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104e05:	00 
  104e06:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
  104e0d:	00 
  104e0e:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104e15:	e8 da b5 ff ff       	call   1003f4 <__panic>
    assert((p2 = alloc_page()) != NULL);
  104e1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104e21:	e8 e7 e1 ff ff       	call   10300d <alloc_pages>
  104e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
  104e29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104e2d:	75 24                	jne    104e53 <basic_check+0xc4>
  104e2f:	c7 44 24 0c 1c 73 10 	movl   $0x10731c,0xc(%esp)
  104e36:	00 
  104e37:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104e3e:	00 
  104e3f:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  104e46:	00 
  104e47:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104e4e:	e8 a1 b5 ff ff       	call   1003f4 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  104e53:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e56:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  104e59:	74 10                	je     104e6b <basic_check+0xdc>
  104e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e5e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104e61:	74 08                	je     104e6b <basic_check+0xdc>
  104e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104e66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  104e69:	75 24                	jne    104e8f <basic_check+0x100>
  104e6b:	c7 44 24 0c 38 73 10 	movl   $0x107338,0xc(%esp)
  104e72:	00 
  104e73:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104e7a:	00 
  104e7b:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
  104e82:	00 
  104e83:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104e8a:	e8 65 b5 ff ff       	call   1003f4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  104e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104e92:	89 04 24             	mov    %eax,(%esp)
  104e95:	e8 99 f8 ff ff       	call   104733 <page_ref>
  104e9a:	85 c0                	test   %eax,%eax
  104e9c:	75 1e                	jne    104ebc <basic_check+0x12d>
  104e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104ea1:	89 04 24             	mov    %eax,(%esp)
  104ea4:	e8 8a f8 ff ff       	call   104733 <page_ref>
  104ea9:	85 c0                	test   %eax,%eax
  104eab:	75 0f                	jne    104ebc <basic_check+0x12d>
  104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104eb0:	89 04 24             	mov    %eax,(%esp)
  104eb3:	e8 7b f8 ff ff       	call   104733 <page_ref>
  104eb8:	85 c0                	test   %eax,%eax
  104eba:	74 24                	je     104ee0 <basic_check+0x151>
  104ebc:	c7 44 24 0c 5c 73 10 	movl   $0x10735c,0xc(%esp)
  104ec3:	00 
  104ec4:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104ecb:	00 
  104ecc:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
  104ed3:	00 
  104ed4:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104edb:	e8 14 b5 ff ff       	call   1003f4 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  104ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104ee3:	89 04 24             	mov    %eax,(%esp)
  104ee6:	e8 32 f8 ff ff       	call   10471d <page2pa>
  104eeb:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  104ef1:	c1 e2 0c             	shl    $0xc,%edx
  104ef4:	39 d0                	cmp    %edx,%eax
  104ef6:	72 24                	jb     104f1c <basic_check+0x18d>
  104ef8:	c7 44 24 0c 98 73 10 	movl   $0x107398,0xc(%esp)
  104eff:	00 
  104f00:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104f07:	00 
  104f08:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
  104f0f:	00 
  104f10:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104f17:	e8 d8 b4 ff ff       	call   1003f4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  104f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f1f:	89 04 24             	mov    %eax,(%esp)
  104f22:	e8 f6 f7 ff ff       	call   10471d <page2pa>
  104f27:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  104f2d:	c1 e2 0c             	shl    $0xc,%edx
  104f30:	39 d0                	cmp    %edx,%eax
  104f32:	72 24                	jb     104f58 <basic_check+0x1c9>
  104f34:	c7 44 24 0c b5 73 10 	movl   $0x1073b5,0xc(%esp)
  104f3b:	00 
  104f3c:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104f43:	00 
  104f44:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
  104f4b:	00 
  104f4c:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104f53:	e8 9c b4 ff ff       	call   1003f4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  104f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f5b:	89 04 24             	mov    %eax,(%esp)
  104f5e:	e8 ba f7 ff ff       	call   10471d <page2pa>
  104f63:	8b 15 a0 be 11 00    	mov    0x11bea0,%edx
  104f69:	c1 e2 0c             	shl    $0xc,%edx
  104f6c:	39 d0                	cmp    %edx,%eax
  104f6e:	72 24                	jb     104f94 <basic_check+0x205>
  104f70:	c7 44 24 0c d2 73 10 	movl   $0x1073d2,0xc(%esp)
  104f77:	00 
  104f78:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104f7f:	00 
  104f80:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
  104f87:	00 
  104f88:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104f8f:	e8 60 b4 ff ff       	call   1003f4 <__panic>

    list_entry_t free_list_store = free_list;
  104f94:	a1 9c bf 11 00       	mov    0x11bf9c,%eax
  104f99:	8b 15 a0 bf 11 00    	mov    0x11bfa0,%edx
  104f9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104fa2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  104fa5:	c7 45 e4 9c bf 11 00 	movl   $0x11bf9c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104faf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104fb2:	89 50 04             	mov    %edx,0x4(%eax)
  104fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fb8:	8b 50 04             	mov    0x4(%eax),%edx
  104fbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fbe:	89 10                	mov    %edx,(%eax)
  104fc0:	c7 45 d8 9c bf 11 00 	movl   $0x11bf9c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  104fc7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  104fca:	8b 40 04             	mov    0x4(%eax),%eax
  104fcd:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  104fd0:	0f 94 c0             	sete   %al
  104fd3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  104fd6:	85 c0                	test   %eax,%eax
  104fd8:	75 24                	jne    104ffe <basic_check+0x26f>
  104fda:	c7 44 24 0c ef 73 10 	movl   $0x1073ef,0xc(%esp)
  104fe1:	00 
  104fe2:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  104fe9:	00 
  104fea:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
  104ff1:	00 
  104ff2:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  104ff9:	e8 f6 b3 ff ff       	call   1003f4 <__panic>

    unsigned int nr_free_store = nr_free;
  104ffe:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  105003:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
  105006:	c7 05 a4 bf 11 00 00 	movl   $0x0,0x11bfa4
  10500d:	00 00 00 

    assert(alloc_page() == NULL);
  105010:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105017:	e8 f1 df ff ff       	call   10300d <alloc_pages>
  10501c:	85 c0                	test   %eax,%eax
  10501e:	74 24                	je     105044 <basic_check+0x2b5>
  105020:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  105027:	00 
  105028:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  10502f:	00 
  105030:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
  105037:	00 
  105038:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  10503f:	e8 b0 b3 ff ff       	call   1003f4 <__panic>

    free_page(p0);
  105044:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10504b:	00 
  10504c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10504f:	89 04 24             	mov    %eax,(%esp)
  105052:	e8 ee df ff ff       	call   103045 <free_pages>
    free_page(p1);
  105057:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10505e:	00 
  10505f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105062:	89 04 24             	mov    %eax,(%esp)
  105065:	e8 db df ff ff       	call   103045 <free_pages>
    free_page(p2);
  10506a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105071:	00 
  105072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105075:	89 04 24             	mov    %eax,(%esp)
  105078:	e8 c8 df ff ff       	call   103045 <free_pages>
    assert(nr_free == 3);
  10507d:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  105082:	83 f8 03             	cmp    $0x3,%eax
  105085:	74 24                	je     1050ab <basic_check+0x31c>
  105087:	c7 44 24 0c 1b 74 10 	movl   $0x10741b,0xc(%esp)
  10508e:	00 
  10508f:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105096:	00 
  105097:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
  10509e:	00 
  10509f:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1050a6:	e8 49 b3 ff ff       	call   1003f4 <__panic>

    assert((p0 = alloc_page()) != NULL);
  1050ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050b2:	e8 56 df ff ff       	call   10300d <alloc_pages>
  1050b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1050ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  1050be:	75 24                	jne    1050e4 <basic_check+0x355>
  1050c0:	c7 44 24 0c e4 72 10 	movl   $0x1072e4,0xc(%esp)
  1050c7:	00 
  1050c8:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1050cf:	00 
  1050d0:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
  1050d7:	00 
  1050d8:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1050df:	e8 10 b3 ff ff       	call   1003f4 <__panic>
    assert((p1 = alloc_page()) != NULL);
  1050e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1050eb:	e8 1d df ff ff       	call   10300d <alloc_pages>
  1050f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1050f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  1050f7:	75 24                	jne    10511d <basic_check+0x38e>
  1050f9:	c7 44 24 0c 00 73 10 	movl   $0x107300,0xc(%esp)
  105100:	00 
  105101:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105108:	00 
  105109:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
  105110:	00 
  105111:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105118:	e8 d7 b2 ff ff       	call   1003f4 <__panic>
    assert((p2 = alloc_page()) != NULL);
  10511d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105124:	e8 e4 de ff ff       	call   10300d <alloc_pages>
  105129:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10512c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105130:	75 24                	jne    105156 <basic_check+0x3c7>
  105132:	c7 44 24 0c 1c 73 10 	movl   $0x10731c,0xc(%esp)
  105139:	00 
  10513a:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105141:	00 
  105142:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
  105149:	00 
  10514a:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105151:	e8 9e b2 ff ff       	call   1003f4 <__panic>

    assert(alloc_page() == NULL);
  105156:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10515d:	e8 ab de ff ff       	call   10300d <alloc_pages>
  105162:	85 c0                	test   %eax,%eax
  105164:	74 24                	je     10518a <basic_check+0x3fb>
  105166:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  10516d:	00 
  10516e:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105175:	00 
  105176:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
  10517d:	00 
  10517e:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105185:	e8 6a b2 ff ff       	call   1003f4 <__panic>

    free_page(p0);
  10518a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105191:	00 
  105192:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105195:	89 04 24             	mov    %eax,(%esp)
  105198:	e8 a8 de ff ff       	call   103045 <free_pages>
  10519d:	c7 45 e8 9c bf 11 00 	movl   $0x11bf9c,-0x18(%ebp)
  1051a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1051a7:	8b 40 04             	mov    0x4(%eax),%eax
  1051aa:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  1051ad:	0f 94 c0             	sete   %al
  1051b0:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  1051b3:	85 c0                	test   %eax,%eax
  1051b5:	74 24                	je     1051db <basic_check+0x44c>
  1051b7:	c7 44 24 0c 28 74 10 	movl   $0x107428,0xc(%esp)
  1051be:	00 
  1051bf:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1051c6:	00 
  1051c7:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
  1051ce:	00 
  1051cf:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1051d6:	e8 19 b2 ff ff       	call   1003f4 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  1051db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1051e2:	e8 26 de ff ff       	call   10300d <alloc_pages>
  1051e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1051ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1051ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1051f0:	74 24                	je     105216 <basic_check+0x487>
  1051f2:	c7 44 24 0c 40 74 10 	movl   $0x107440,0xc(%esp)
  1051f9:	00 
  1051fa:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105201:	00 
  105202:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
  105209:	00 
  10520a:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105211:	e8 de b1 ff ff       	call   1003f4 <__panic>
    assert(alloc_page() == NULL);
  105216:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10521d:	e8 eb dd ff ff       	call   10300d <alloc_pages>
  105222:	85 c0                	test   %eax,%eax
  105224:	74 24                	je     10524a <basic_check+0x4bb>
  105226:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  10522d:	00 
  10522e:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105235:	00 
  105236:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
  10523d:	00 
  10523e:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105245:	e8 aa b1 ff ff       	call   1003f4 <__panic>

    assert(nr_free == 0);
  10524a:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  10524f:	85 c0                	test   %eax,%eax
  105251:	74 24                	je     105277 <basic_check+0x4e8>
  105253:	c7 44 24 0c 59 74 10 	movl   $0x107459,0xc(%esp)
  10525a:	00 
  10525b:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105262:	00 
  105263:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
  10526a:	00 
  10526b:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105272:	e8 7d b1 ff ff       	call   1003f4 <__panic>
    free_list = free_list_store;
  105277:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10527a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10527d:	a3 9c bf 11 00       	mov    %eax,0x11bf9c
  105282:	89 15 a0 bf 11 00    	mov    %edx,0x11bfa0
    nr_free = nr_free_store;
  105288:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10528b:	a3 a4 bf 11 00       	mov    %eax,0x11bfa4

    free_page(p);
  105290:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105297:	00 
  105298:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10529b:	89 04 24             	mov    %eax,(%esp)
  10529e:	e8 a2 dd ff ff       	call   103045 <free_pages>
    free_page(p1);
  1052a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052aa:	00 
  1052ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1052ae:	89 04 24             	mov    %eax,(%esp)
  1052b1:	e8 8f dd ff ff       	call   103045 <free_pages>
    free_page(p2);
  1052b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1052bd:	00 
  1052be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1052c1:	89 04 24             	mov    %eax,(%esp)
  1052c4:	e8 7c dd ff ff       	call   103045 <free_pages>
}
  1052c9:	90                   	nop
  1052ca:	c9                   	leave  
  1052cb:	c3                   	ret    

001052cc <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  1052cc:	55                   	push   %ebp
  1052cd:	89 e5                	mov    %esp,%ebp
  1052cf:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  1052d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1052dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  1052e3:	c7 45 ec 9c bf 11 00 	movl   $0x11bf9c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  1052ea:	eb 6a                	jmp    105356 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  1052ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052ef:	83 e8 0c             	sub    $0xc,%eax
  1052f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
  1052f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1052f8:	83 c0 04             	add    $0x4,%eax
  1052fb:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
  105302:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105305:	8b 45 ac             	mov    -0x54(%ebp),%eax
  105308:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10530b:	0f a3 10             	bt     %edx,(%eax)
  10530e:	19 c0                	sbb    %eax,%eax
  105310:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
  105313:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
  105317:	0f 95 c0             	setne  %al
  10531a:	0f b6 c0             	movzbl %al,%eax
  10531d:	85 c0                	test   %eax,%eax
  10531f:	75 24                	jne    105345 <default_check+0x79>
  105321:	c7 44 24 0c 66 74 10 	movl   $0x107466,0xc(%esp)
  105328:	00 
  105329:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105330:	00 
  105331:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  105338:	00 
  105339:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105340:	e8 af b0 ff ff       	call   1003f4 <__panic>
        count ++, total += p->property;
  105345:	ff 45 f4             	incl   -0xc(%ebp)
  105348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10534b:	8b 50 08             	mov    0x8(%eax),%edx
  10534e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105351:	01 d0                	add    %edx,%eax
  105353:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105356:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105359:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  10535c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10535f:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  105362:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105365:	81 7d ec 9c bf 11 00 	cmpl   $0x11bf9c,-0x14(%ebp)
  10536c:	0f 85 7a ff ff ff    	jne    1052ec <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
  105372:	e8 01 dd ff ff       	call   103078 <nr_free_pages>
  105377:	89 c2                	mov    %eax,%edx
  105379:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10537c:	39 c2                	cmp    %eax,%edx
  10537e:	74 24                	je     1053a4 <default_check+0xd8>
  105380:	c7 44 24 0c 76 74 10 	movl   $0x107476,0xc(%esp)
  105387:	00 
  105388:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  10538f:	00 
  105390:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
  105397:	00 
  105398:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  10539f:	e8 50 b0 ff ff       	call   1003f4 <__panic>

    basic_check();
  1053a4:	e8 e6 f9 ff ff       	call   104d8f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  1053a9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1053b0:	e8 58 dc ff ff       	call   10300d <alloc_pages>
  1053b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
  1053b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1053bc:	75 24                	jne    1053e2 <default_check+0x116>
  1053be:	c7 44 24 0c 8f 74 10 	movl   $0x10748f,0xc(%esp)
  1053c5:	00 
  1053c6:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1053cd:	00 
  1053ce:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
  1053d5:	00 
  1053d6:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1053dd:	e8 12 b0 ff ff       	call   1003f4 <__panic>
    assert(!PageProperty(p0));
  1053e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1053e5:	83 c0 04             	add    $0x4,%eax
  1053e8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
  1053ef:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1053f2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  1053f5:	8b 55 e8             	mov    -0x18(%ebp),%edx
  1053f8:	0f a3 10             	bt     %edx,(%eax)
  1053fb:	19 c0                	sbb    %eax,%eax
  1053fd:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
  105400:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
  105404:	0f 95 c0             	setne  %al
  105407:	0f b6 c0             	movzbl %al,%eax
  10540a:	85 c0                	test   %eax,%eax
  10540c:	74 24                	je     105432 <default_check+0x166>
  10540e:	c7 44 24 0c 9a 74 10 	movl   $0x10749a,0xc(%esp)
  105415:	00 
  105416:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  10541d:	00 
  10541e:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
  105425:	00 
  105426:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  10542d:	e8 c2 af ff ff       	call   1003f4 <__panic>

    list_entry_t free_list_store = free_list;
  105432:	a1 9c bf 11 00       	mov    0x11bf9c,%eax
  105437:	8b 15 a0 bf 11 00    	mov    0x11bfa0,%edx
  10543d:	89 45 80             	mov    %eax,-0x80(%ebp)
  105440:	89 55 84             	mov    %edx,-0x7c(%ebp)
  105443:	c7 45 d0 9c bf 11 00 	movl   $0x11bf9c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  10544a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10544d:	8b 55 d0             	mov    -0x30(%ebp),%edx
  105450:	89 50 04             	mov    %edx,0x4(%eax)
  105453:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105456:	8b 50 04             	mov    0x4(%eax),%edx
  105459:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10545c:	89 10                	mov    %edx,(%eax)
  10545e:	c7 45 d8 9c bf 11 00 	movl   $0x11bf9c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
  105465:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105468:	8b 40 04             	mov    0x4(%eax),%eax
  10546b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10546e:	0f 94 c0             	sete   %al
  105471:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  105474:	85 c0                	test   %eax,%eax
  105476:	75 24                	jne    10549c <default_check+0x1d0>
  105478:	c7 44 24 0c ef 73 10 	movl   $0x1073ef,0xc(%esp)
  10547f:	00 
  105480:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105487:	00 
  105488:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  10548f:	00 
  105490:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105497:	e8 58 af ff ff       	call   1003f4 <__panic>
    assert(alloc_page() == NULL);
  10549c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1054a3:	e8 65 db ff ff       	call   10300d <alloc_pages>
  1054a8:	85 c0                	test   %eax,%eax
  1054aa:	74 24                	je     1054d0 <default_check+0x204>
  1054ac:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  1054b3:	00 
  1054b4:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1054bb:	00 
  1054bc:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
  1054c3:	00 
  1054c4:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1054cb:	e8 24 af ff ff       	call   1003f4 <__panic>

    unsigned int nr_free_store = nr_free;
  1054d0:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  1054d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
  1054d8:	c7 05 a4 bf 11 00 00 	movl   $0x0,0x11bfa4
  1054df:	00 00 00 

    free_pages(p0 + 2, 3);
  1054e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1054e5:	83 c0 28             	add    $0x28,%eax
  1054e8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1054ef:	00 
  1054f0:	89 04 24             	mov    %eax,(%esp)
  1054f3:	e8 4d db ff ff       	call   103045 <free_pages>
    assert(alloc_pages(4) == NULL);
  1054f8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  1054ff:	e8 09 db ff ff       	call   10300d <alloc_pages>
  105504:	85 c0                	test   %eax,%eax
  105506:	74 24                	je     10552c <default_check+0x260>
  105508:	c7 44 24 0c ac 74 10 	movl   $0x1074ac,0xc(%esp)
  10550f:	00 
  105510:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105517:	00 
  105518:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
  10551f:	00 
  105520:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105527:	e8 c8 ae ff ff       	call   1003f4 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  10552c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10552f:	83 c0 28             	add    $0x28,%eax
  105532:	83 c0 04             	add    $0x4,%eax
  105535:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  10553c:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  10553f:	8b 45 9c             	mov    -0x64(%ebp),%eax
  105542:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105545:	0f a3 10             	bt     %edx,(%eax)
  105548:	19 c0                	sbb    %eax,%eax
  10554a:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  10554d:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  105551:	0f 95 c0             	setne  %al
  105554:	0f b6 c0             	movzbl %al,%eax
  105557:	85 c0                	test   %eax,%eax
  105559:	74 0e                	je     105569 <default_check+0x29d>
  10555b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10555e:	83 c0 28             	add    $0x28,%eax
  105561:	8b 40 08             	mov    0x8(%eax),%eax
  105564:	83 f8 03             	cmp    $0x3,%eax
  105567:	74 24                	je     10558d <default_check+0x2c1>
  105569:	c7 44 24 0c c4 74 10 	movl   $0x1074c4,0xc(%esp)
  105570:	00 
  105571:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105578:	00 
  105579:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
  105580:	00 
  105581:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105588:	e8 67 ae ff ff       	call   1003f4 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10558d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  105594:	e8 74 da ff ff       	call   10300d <alloc_pages>
  105599:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  10559c:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  1055a0:	75 24                	jne    1055c6 <default_check+0x2fa>
  1055a2:	c7 44 24 0c f0 74 10 	movl   $0x1074f0,0xc(%esp)
  1055a9:	00 
  1055aa:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1055b1:	00 
  1055b2:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
  1055b9:	00 
  1055ba:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1055c1:	e8 2e ae ff ff       	call   1003f4 <__panic>
    assert(alloc_page() == NULL);
  1055c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1055cd:	e8 3b da ff ff       	call   10300d <alloc_pages>
  1055d2:	85 c0                	test   %eax,%eax
  1055d4:	74 24                	je     1055fa <default_check+0x32e>
  1055d6:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  1055dd:	00 
  1055de:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1055e5:	00 
  1055e6:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  1055ed:	00 
  1055ee:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1055f5:	e8 fa ad ff ff       	call   1003f4 <__panic>
    assert(p0 + 2 == p1);
  1055fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1055fd:	83 c0 28             	add    $0x28,%eax
  105600:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
  105603:	74 24                	je     105629 <default_check+0x35d>
  105605:	c7 44 24 0c 0e 75 10 	movl   $0x10750e,0xc(%esp)
  10560c:	00 
  10560d:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105614:	00 
  105615:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
  10561c:	00 
  10561d:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105624:	e8 cb ad ff ff       	call   1003f4 <__panic>

    p2 = p0 + 1;
  105629:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10562c:	83 c0 14             	add    $0x14,%eax
  10562f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
  105632:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105639:	00 
  10563a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10563d:	89 04 24             	mov    %eax,(%esp)
  105640:	e8 00 da ff ff       	call   103045 <free_pages>
    free_pages(p1, 3);
  105645:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10564c:	00 
  10564d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  105650:	89 04 24             	mov    %eax,(%esp)
  105653:	e8 ed d9 ff ff       	call   103045 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  105658:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10565b:	83 c0 04             	add    $0x4,%eax
  10565e:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  105665:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  105668:	8b 45 94             	mov    -0x6c(%ebp),%eax
  10566b:	8b 55 c8             	mov    -0x38(%ebp),%edx
  10566e:	0f a3 10             	bt     %edx,(%eax)
  105671:	19 c0                	sbb    %eax,%eax
  105673:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
  105676:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
  10567a:	0f 95 c0             	setne  %al
  10567d:	0f b6 c0             	movzbl %al,%eax
  105680:	85 c0                	test   %eax,%eax
  105682:	74 0b                	je     10568f <default_check+0x3c3>
  105684:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105687:	8b 40 08             	mov    0x8(%eax),%eax
  10568a:	83 f8 01             	cmp    $0x1,%eax
  10568d:	74 24                	je     1056b3 <default_check+0x3e7>
  10568f:	c7 44 24 0c 1c 75 10 	movl   $0x10751c,0xc(%esp)
  105696:	00 
  105697:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  10569e:	00 
  10569f:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
  1056a6:	00 
  1056a7:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1056ae:	e8 41 ad ff ff       	call   1003f4 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  1056b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1056b6:	83 c0 04             	add    $0x4,%eax
  1056b9:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
  1056c0:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1056c3:	8b 45 8c             	mov    -0x74(%ebp),%eax
  1056c6:	8b 55 bc             	mov    -0x44(%ebp),%edx
  1056c9:	0f a3 10             	bt     %edx,(%eax)
  1056cc:	19 c0                	sbb    %eax,%eax
  1056ce:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
  1056d1:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
  1056d5:	0f 95 c0             	setne  %al
  1056d8:	0f b6 c0             	movzbl %al,%eax
  1056db:	85 c0                	test   %eax,%eax
  1056dd:	74 0b                	je     1056ea <default_check+0x41e>
  1056df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1056e2:	8b 40 08             	mov    0x8(%eax),%eax
  1056e5:	83 f8 03             	cmp    $0x3,%eax
  1056e8:	74 24                	je     10570e <default_check+0x442>
  1056ea:	c7 44 24 0c 44 75 10 	movl   $0x107544,0xc(%esp)
  1056f1:	00 
  1056f2:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1056f9:	00 
  1056fa:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
  105701:	00 
  105702:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105709:	e8 e6 ac ff ff       	call   1003f4 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  10570e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105715:	e8 f3 d8 ff ff       	call   10300d <alloc_pages>
  10571a:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10571d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105720:	83 e8 14             	sub    $0x14,%eax
  105723:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  105726:	74 24                	je     10574c <default_check+0x480>
  105728:	c7 44 24 0c 6a 75 10 	movl   $0x10756a,0xc(%esp)
  10572f:	00 
  105730:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105737:	00 
  105738:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
  10573f:	00 
  105740:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105747:	e8 a8 ac ff ff       	call   1003f4 <__panic>
    free_page(p0);
  10574c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105753:	00 
  105754:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105757:	89 04 24             	mov    %eax,(%esp)
  10575a:	e8 e6 d8 ff ff       	call   103045 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  10575f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  105766:	e8 a2 d8 ff ff       	call   10300d <alloc_pages>
  10576b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10576e:	8b 45 c0             	mov    -0x40(%ebp),%eax
  105771:	83 c0 14             	add    $0x14,%eax
  105774:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  105777:	74 24                	je     10579d <default_check+0x4d1>
  105779:	c7 44 24 0c 88 75 10 	movl   $0x107588,0xc(%esp)
  105780:	00 
  105781:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105788:	00 
  105789:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
  105790:	00 
  105791:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105798:	e8 57 ac ff ff       	call   1003f4 <__panic>

    free_pages(p0, 2);
  10579d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  1057a4:	00 
  1057a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1057a8:	89 04 24             	mov    %eax,(%esp)
  1057ab:	e8 95 d8 ff ff       	call   103045 <free_pages>
    free_page(p2);
  1057b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1057b7:	00 
  1057b8:	8b 45 c0             	mov    -0x40(%ebp),%eax
  1057bb:	89 04 24             	mov    %eax,(%esp)
  1057be:	e8 82 d8 ff ff       	call   103045 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  1057c3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  1057ca:	e8 3e d8 ff ff       	call   10300d <alloc_pages>
  1057cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1057d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1057d6:	75 24                	jne    1057fc <default_check+0x530>
  1057d8:	c7 44 24 0c a8 75 10 	movl   $0x1075a8,0xc(%esp)
  1057df:	00 
  1057e0:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1057e7:	00 
  1057e8:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
  1057ef:	00 
  1057f0:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1057f7:	e8 f8 ab ff ff       	call   1003f4 <__panic>
    assert(alloc_page() == NULL);
  1057fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105803:	e8 05 d8 ff ff       	call   10300d <alloc_pages>
  105808:	85 c0                	test   %eax,%eax
  10580a:	74 24                	je     105830 <default_check+0x564>
  10580c:	c7 44 24 0c 06 74 10 	movl   $0x107406,0xc(%esp)
  105813:	00 
  105814:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  10581b:	00 
  10581c:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
  105823:	00 
  105824:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  10582b:	e8 c4 ab ff ff       	call   1003f4 <__panic>

    assert(nr_free == 0);
  105830:	a1 a4 bf 11 00       	mov    0x11bfa4,%eax
  105835:	85 c0                	test   %eax,%eax
  105837:	74 24                	je     10585d <default_check+0x591>
  105839:	c7 44 24 0c 59 74 10 	movl   $0x107459,0xc(%esp)
  105840:	00 
  105841:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105848:	00 
  105849:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
  105850:	00 
  105851:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105858:	e8 97 ab ff ff       	call   1003f4 <__panic>
    nr_free = nr_free_store;
  10585d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  105860:	a3 a4 bf 11 00       	mov    %eax,0x11bfa4

    free_list = free_list_store;
  105865:	8b 45 80             	mov    -0x80(%ebp),%eax
  105868:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10586b:	a3 9c bf 11 00       	mov    %eax,0x11bf9c
  105870:	89 15 a0 bf 11 00    	mov    %edx,0x11bfa0
    free_pages(p0, 5);
  105876:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  10587d:	00 
  10587e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105881:	89 04 24             	mov    %eax,(%esp)
  105884:	e8 bc d7 ff ff       	call   103045 <free_pages>

    le = &free_list;
  105889:	c7 45 ec 9c bf 11 00 	movl   $0x11bf9c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  105890:	eb 5a                	jmp    1058ec <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
  105892:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105895:	8b 40 04             	mov    0x4(%eax),%eax
  105898:	8b 00                	mov    (%eax),%eax
  10589a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10589d:	75 0d                	jne    1058ac <default_check+0x5e0>
  10589f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058a2:	8b 00                	mov    (%eax),%eax
  1058a4:	8b 40 04             	mov    0x4(%eax),%eax
  1058a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1058aa:	74 24                	je     1058d0 <default_check+0x604>
  1058ac:	c7 44 24 0c c8 75 10 	movl   $0x1075c8,0xc(%esp)
  1058b3:	00 
  1058b4:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  1058bb:	00 
  1058bc:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
  1058c3:	00 
  1058c4:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  1058cb:	e8 24 ab ff ff       	call   1003f4 <__panic>
        struct Page *p = le2page(le, page_link);
  1058d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058d3:	83 e8 0c             	sub    $0xc,%eax
  1058d6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
  1058d9:	ff 4d f4             	decl   -0xc(%ebp)
  1058dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1058df:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1058e2:	8b 40 08             	mov    0x8(%eax),%eax
  1058e5:	29 c2                	sub    %eax,%edx
  1058e7:	89 d0                	mov    %edx,%eax
  1058e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1058ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1058ef:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
  1058f2:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1058f5:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
  1058f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1058fb:	81 7d ec 9c bf 11 00 	cmpl   $0x11bf9c,-0x14(%ebp)
  105902:	75 8e                	jne    105892 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
  105904:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  105908:	74 24                	je     10592e <default_check+0x662>
  10590a:	c7 44 24 0c f5 75 10 	movl   $0x1075f5,0xc(%esp)
  105911:	00 
  105912:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105919:	00 
  10591a:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
  105921:	00 
  105922:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105929:	e8 c6 aa ff ff       	call   1003f4 <__panic>
    assert(total == 0);
  10592e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105932:	74 24                	je     105958 <default_check+0x68c>
  105934:	c7 44 24 0c 00 76 10 	movl   $0x107600,0xc(%esp)
  10593b:	00 
  10593c:	c7 44 24 08 66 72 10 	movl   $0x107266,0x8(%esp)
  105943:	00 
  105944:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
  10594b:	00 
  10594c:	c7 04 24 7b 72 10 00 	movl   $0x10727b,(%esp)
  105953:	e8 9c aa ff ff       	call   1003f4 <__panic>
}
  105958:	90                   	nop
  105959:	c9                   	leave  
  10595a:	c3                   	ret    

0010595b <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  10595b:	55                   	push   %ebp
  10595c:	89 e5                	mov    %esp,%ebp
  10595e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105961:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105968:	eb 03                	jmp    10596d <strlen+0x12>
        cnt ++;
  10596a:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  10596d:	8b 45 08             	mov    0x8(%ebp),%eax
  105970:	8d 50 01             	lea    0x1(%eax),%edx
  105973:	89 55 08             	mov    %edx,0x8(%ebp)
  105976:	0f b6 00             	movzbl (%eax),%eax
  105979:	84 c0                	test   %al,%al
  10597b:	75 ed                	jne    10596a <strlen+0xf>
        cnt ++;
    }
    return cnt;
  10597d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105980:	c9                   	leave  
  105981:	c3                   	ret    

00105982 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105982:	55                   	push   %ebp
  105983:	89 e5                	mov    %esp,%ebp
  105985:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105988:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  10598f:	eb 03                	jmp    105994 <strnlen+0x12>
        cnt ++;
  105991:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  105994:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105997:	3b 45 0c             	cmp    0xc(%ebp),%eax
  10599a:	73 10                	jae    1059ac <strnlen+0x2a>
  10599c:	8b 45 08             	mov    0x8(%ebp),%eax
  10599f:	8d 50 01             	lea    0x1(%eax),%edx
  1059a2:	89 55 08             	mov    %edx,0x8(%ebp)
  1059a5:	0f b6 00             	movzbl (%eax),%eax
  1059a8:	84 c0                	test   %al,%al
  1059aa:	75 e5                	jne    105991 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
  1059ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1059af:	c9                   	leave  
  1059b0:	c3                   	ret    

001059b1 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  1059b1:	55                   	push   %ebp
  1059b2:	89 e5                	mov    %esp,%ebp
  1059b4:	57                   	push   %edi
  1059b5:	56                   	push   %esi
  1059b6:	83 ec 20             	sub    $0x20,%esp
  1059b9:	8b 45 08             	mov    0x8(%ebp),%eax
  1059bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1059bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  1059c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1059c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1059cb:	89 d1                	mov    %edx,%ecx
  1059cd:	89 c2                	mov    %eax,%edx
  1059cf:	89 ce                	mov    %ecx,%esi
  1059d1:	89 d7                	mov    %edx,%edi
  1059d3:	ac                   	lods   %ds:(%esi),%al
  1059d4:	aa                   	stos   %al,%es:(%edi)
  1059d5:	84 c0                	test   %al,%al
  1059d7:	75 fa                	jne    1059d3 <strcpy+0x22>
  1059d9:	89 fa                	mov    %edi,%edx
  1059db:	89 f1                	mov    %esi,%ecx
  1059dd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1059e0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  1059e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  1059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
  1059e9:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  1059ea:	83 c4 20             	add    $0x20,%esp
  1059ed:	5e                   	pop    %esi
  1059ee:	5f                   	pop    %edi
  1059ef:	5d                   	pop    %ebp
  1059f0:	c3                   	ret    

001059f1 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  1059f1:	55                   	push   %ebp
  1059f2:	89 e5                	mov    %esp,%ebp
  1059f4:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  1059f7:	8b 45 08             	mov    0x8(%ebp),%eax
  1059fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  1059fd:	eb 1e                	jmp    105a1d <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  1059ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a02:	0f b6 10             	movzbl (%eax),%edx
  105a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a08:	88 10                	mov    %dl,(%eax)
  105a0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105a0d:	0f b6 00             	movzbl (%eax),%eax
  105a10:	84 c0                	test   %al,%al
  105a12:	74 03                	je     105a17 <strncpy+0x26>
            src ++;
  105a14:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105a17:	ff 45 fc             	incl   -0x4(%ebp)
  105a1a:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
  105a1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a21:	75 dc                	jne    1059ff <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
  105a23:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105a26:	c9                   	leave  
  105a27:	c3                   	ret    

00105a28 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105a28:	55                   	push   %ebp
  105a29:	89 e5                	mov    %esp,%ebp
  105a2b:	57                   	push   %edi
  105a2c:	56                   	push   %esi
  105a2d:	83 ec 20             	sub    $0x20,%esp
  105a30:	8b 45 08             	mov    0x8(%ebp),%eax
  105a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105a36:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
  105a3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105a42:	89 d1                	mov    %edx,%ecx
  105a44:	89 c2                	mov    %eax,%edx
  105a46:	89 ce                	mov    %ecx,%esi
  105a48:	89 d7                	mov    %edx,%edi
  105a4a:	ac                   	lods   %ds:(%esi),%al
  105a4b:	ae                   	scas   %es:(%edi),%al
  105a4c:	75 08                	jne    105a56 <strcmp+0x2e>
  105a4e:	84 c0                	test   %al,%al
  105a50:	75 f8                	jne    105a4a <strcmp+0x22>
  105a52:	31 c0                	xor    %eax,%eax
  105a54:	eb 04                	jmp    105a5a <strcmp+0x32>
  105a56:	19 c0                	sbb    %eax,%eax
  105a58:	0c 01                	or     $0x1,%al
  105a5a:	89 fa                	mov    %edi,%edx
  105a5c:	89 f1                	mov    %esi,%ecx
  105a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105a61:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105a64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
  105a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
  105a6a:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105a6b:	83 c4 20             	add    $0x20,%esp
  105a6e:	5e                   	pop    %esi
  105a6f:	5f                   	pop    %edi
  105a70:	5d                   	pop    %ebp
  105a71:	c3                   	ret    

00105a72 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105a72:	55                   	push   %ebp
  105a73:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105a75:	eb 09                	jmp    105a80 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105a77:	ff 4d 10             	decl   0x10(%ebp)
  105a7a:	ff 45 08             	incl   0x8(%ebp)
  105a7d:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105a80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105a84:	74 1a                	je     105aa0 <strncmp+0x2e>
  105a86:	8b 45 08             	mov    0x8(%ebp),%eax
  105a89:	0f b6 00             	movzbl (%eax),%eax
  105a8c:	84 c0                	test   %al,%al
  105a8e:	74 10                	je     105aa0 <strncmp+0x2e>
  105a90:	8b 45 08             	mov    0x8(%ebp),%eax
  105a93:	0f b6 10             	movzbl (%eax),%edx
  105a96:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a99:	0f b6 00             	movzbl (%eax),%eax
  105a9c:	38 c2                	cmp    %al,%dl
  105a9e:	74 d7                	je     105a77 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105aa0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105aa4:	74 18                	je     105abe <strncmp+0x4c>
  105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa9:	0f b6 00             	movzbl (%eax),%eax
  105aac:	0f b6 d0             	movzbl %al,%edx
  105aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ab2:	0f b6 00             	movzbl (%eax),%eax
  105ab5:	0f b6 c0             	movzbl %al,%eax
  105ab8:	29 c2                	sub    %eax,%edx
  105aba:	89 d0                	mov    %edx,%eax
  105abc:	eb 05                	jmp    105ac3 <strncmp+0x51>
  105abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105ac3:	5d                   	pop    %ebp
  105ac4:	c3                   	ret    

00105ac5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105ac5:	55                   	push   %ebp
  105ac6:	89 e5                	mov    %esp,%ebp
  105ac8:	83 ec 04             	sub    $0x4,%esp
  105acb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ace:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ad1:	eb 13                	jmp    105ae6 <strchr+0x21>
        if (*s == c) {
  105ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ad6:	0f b6 00             	movzbl (%eax),%eax
  105ad9:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105adc:	75 05                	jne    105ae3 <strchr+0x1e>
            return (char *)s;
  105ade:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae1:	eb 12                	jmp    105af5 <strchr+0x30>
        }
        s ++;
  105ae3:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
  105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ae9:	0f b6 00             	movzbl (%eax),%eax
  105aec:	84 c0                	test   %al,%al
  105aee:	75 e3                	jne    105ad3 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
  105af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105af5:	c9                   	leave  
  105af6:	c3                   	ret    

00105af7 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105af7:	55                   	push   %ebp
  105af8:	89 e5                	mov    %esp,%ebp
  105afa:	83 ec 04             	sub    $0x4,%esp
  105afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b00:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105b03:	eb 0e                	jmp    105b13 <strfind+0x1c>
        if (*s == c) {
  105b05:	8b 45 08             	mov    0x8(%ebp),%eax
  105b08:	0f b6 00             	movzbl (%eax),%eax
  105b0b:	3a 45 fc             	cmp    -0x4(%ebp),%al
  105b0e:	74 0f                	je     105b1f <strfind+0x28>
            break;
        }
        s ++;
  105b10:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
  105b13:	8b 45 08             	mov    0x8(%ebp),%eax
  105b16:	0f b6 00             	movzbl (%eax),%eax
  105b19:	84 c0                	test   %al,%al
  105b1b:	75 e8                	jne    105b05 <strfind+0xe>
  105b1d:	eb 01                	jmp    105b20 <strfind+0x29>
        if (*s == c) {
            break;
  105b1f:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
  105b20:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105b23:	c9                   	leave  
  105b24:	c3                   	ret    

00105b25 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105b25:	55                   	push   %ebp
  105b26:	89 e5                	mov    %esp,%ebp
  105b28:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105b2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105b32:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105b39:	eb 03                	jmp    105b3e <strtol+0x19>
        s ++;
  105b3b:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  105b41:	0f b6 00             	movzbl (%eax),%eax
  105b44:	3c 20                	cmp    $0x20,%al
  105b46:	74 f3                	je     105b3b <strtol+0x16>
  105b48:	8b 45 08             	mov    0x8(%ebp),%eax
  105b4b:	0f b6 00             	movzbl (%eax),%eax
  105b4e:	3c 09                	cmp    $0x9,%al
  105b50:	74 e9                	je     105b3b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
  105b52:	8b 45 08             	mov    0x8(%ebp),%eax
  105b55:	0f b6 00             	movzbl (%eax),%eax
  105b58:	3c 2b                	cmp    $0x2b,%al
  105b5a:	75 05                	jne    105b61 <strtol+0x3c>
        s ++;
  105b5c:	ff 45 08             	incl   0x8(%ebp)
  105b5f:	eb 14                	jmp    105b75 <strtol+0x50>
    }
    else if (*s == '-') {
  105b61:	8b 45 08             	mov    0x8(%ebp),%eax
  105b64:	0f b6 00             	movzbl (%eax),%eax
  105b67:	3c 2d                	cmp    $0x2d,%al
  105b69:	75 0a                	jne    105b75 <strtol+0x50>
        s ++, neg = 1;
  105b6b:	ff 45 08             	incl   0x8(%ebp)
  105b6e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105b75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105b79:	74 06                	je     105b81 <strtol+0x5c>
  105b7b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105b7f:	75 22                	jne    105ba3 <strtol+0x7e>
  105b81:	8b 45 08             	mov    0x8(%ebp),%eax
  105b84:	0f b6 00             	movzbl (%eax),%eax
  105b87:	3c 30                	cmp    $0x30,%al
  105b89:	75 18                	jne    105ba3 <strtol+0x7e>
  105b8b:	8b 45 08             	mov    0x8(%ebp),%eax
  105b8e:	40                   	inc    %eax
  105b8f:	0f b6 00             	movzbl (%eax),%eax
  105b92:	3c 78                	cmp    $0x78,%al
  105b94:	75 0d                	jne    105ba3 <strtol+0x7e>
        s += 2, base = 16;
  105b96:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105b9a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105ba1:	eb 29                	jmp    105bcc <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105ba3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105ba7:	75 16                	jne    105bbf <strtol+0x9a>
  105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  105bac:	0f b6 00             	movzbl (%eax),%eax
  105baf:	3c 30                	cmp    $0x30,%al
  105bb1:	75 0c                	jne    105bbf <strtol+0x9a>
        s ++, base = 8;
  105bb3:	ff 45 08             	incl   0x8(%ebp)
  105bb6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105bbd:	eb 0d                	jmp    105bcc <strtol+0xa7>
    }
    else if (base == 0) {
  105bbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105bc3:	75 07                	jne    105bcc <strtol+0xa7>
        base = 10;
  105bc5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  105bcf:	0f b6 00             	movzbl (%eax),%eax
  105bd2:	3c 2f                	cmp    $0x2f,%al
  105bd4:	7e 1b                	jle    105bf1 <strtol+0xcc>
  105bd6:	8b 45 08             	mov    0x8(%ebp),%eax
  105bd9:	0f b6 00             	movzbl (%eax),%eax
  105bdc:	3c 39                	cmp    $0x39,%al
  105bde:	7f 11                	jg     105bf1 <strtol+0xcc>
            dig = *s - '0';
  105be0:	8b 45 08             	mov    0x8(%ebp),%eax
  105be3:	0f b6 00             	movzbl (%eax),%eax
  105be6:	0f be c0             	movsbl %al,%eax
  105be9:	83 e8 30             	sub    $0x30,%eax
  105bec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105bef:	eb 48                	jmp    105c39 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  105bf4:	0f b6 00             	movzbl (%eax),%eax
  105bf7:	3c 60                	cmp    $0x60,%al
  105bf9:	7e 1b                	jle    105c16 <strtol+0xf1>
  105bfb:	8b 45 08             	mov    0x8(%ebp),%eax
  105bfe:	0f b6 00             	movzbl (%eax),%eax
  105c01:	3c 7a                	cmp    $0x7a,%al
  105c03:	7f 11                	jg     105c16 <strtol+0xf1>
            dig = *s - 'a' + 10;
  105c05:	8b 45 08             	mov    0x8(%ebp),%eax
  105c08:	0f b6 00             	movzbl (%eax),%eax
  105c0b:	0f be c0             	movsbl %al,%eax
  105c0e:	83 e8 57             	sub    $0x57,%eax
  105c11:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105c14:	eb 23                	jmp    105c39 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  105c16:	8b 45 08             	mov    0x8(%ebp),%eax
  105c19:	0f b6 00             	movzbl (%eax),%eax
  105c1c:	3c 40                	cmp    $0x40,%al
  105c1e:	7e 3b                	jle    105c5b <strtol+0x136>
  105c20:	8b 45 08             	mov    0x8(%ebp),%eax
  105c23:	0f b6 00             	movzbl (%eax),%eax
  105c26:	3c 5a                	cmp    $0x5a,%al
  105c28:	7f 31                	jg     105c5b <strtol+0x136>
            dig = *s - 'A' + 10;
  105c2a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c2d:	0f b6 00             	movzbl (%eax),%eax
  105c30:	0f be c0             	movsbl %al,%eax
  105c33:	83 e8 37             	sub    $0x37,%eax
  105c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  105c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c3c:	3b 45 10             	cmp    0x10(%ebp),%eax
  105c3f:	7d 19                	jge    105c5a <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  105c41:	ff 45 08             	incl   0x8(%ebp)
  105c44:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105c47:	0f af 45 10          	imul   0x10(%ebp),%eax
  105c4b:	89 c2                	mov    %eax,%edx
  105c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105c50:	01 d0                	add    %edx,%eax
  105c52:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
  105c55:	e9 72 ff ff ff       	jmp    105bcc <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
  105c5a:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
  105c5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105c5f:	74 08                	je     105c69 <strtol+0x144>
        *endptr = (char *) s;
  105c61:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c64:	8b 55 08             	mov    0x8(%ebp),%edx
  105c67:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  105c69:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  105c6d:	74 07                	je     105c76 <strtol+0x151>
  105c6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105c72:	f7 d8                	neg    %eax
  105c74:	eb 03                	jmp    105c79 <strtol+0x154>
  105c76:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  105c79:	c9                   	leave  
  105c7a:	c3                   	ret    

00105c7b <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  105c7b:	55                   	push   %ebp
  105c7c:	89 e5                	mov    %esp,%ebp
  105c7e:	57                   	push   %edi
  105c7f:	83 ec 24             	sub    $0x24,%esp
  105c82:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c85:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  105c88:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
  105c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  105c8f:	89 55 f8             	mov    %edx,-0x8(%ebp)
  105c92:	88 45 f7             	mov    %al,-0x9(%ebp)
  105c95:	8b 45 10             	mov    0x10(%ebp),%eax
  105c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  105c9b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  105c9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  105ca2:	8b 55 f8             	mov    -0x8(%ebp),%edx
  105ca5:	89 d7                	mov    %edx,%edi
  105ca7:	f3 aa                	rep stos %al,%es:(%edi)
  105ca9:	89 fa                	mov    %edi,%edx
  105cab:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105cae:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  105cb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105cb4:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  105cb5:	83 c4 24             	add    $0x24,%esp
  105cb8:	5f                   	pop    %edi
  105cb9:	5d                   	pop    %ebp
  105cba:	c3                   	ret    

00105cbb <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  105cbb:	55                   	push   %ebp
  105cbc:	89 e5                	mov    %esp,%ebp
  105cbe:	57                   	push   %edi
  105cbf:	56                   	push   %esi
  105cc0:	53                   	push   %ebx
  105cc1:	83 ec 30             	sub    $0x30,%esp
  105cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  105cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cca:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ccd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105cd0:	8b 45 10             	mov    0x10(%ebp),%eax
  105cd3:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  105cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cd9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  105cdc:	73 42                	jae    105d20 <memmove+0x65>
  105cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105ce1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105ce4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105ce7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105ced:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105cf0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105cf3:	c1 e8 02             	shr    $0x2,%eax
  105cf6:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105cf8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105cfe:	89 d7                	mov    %edx,%edi
  105d00:	89 c6                	mov    %eax,%esi
  105d02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105d04:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  105d07:	83 e1 03             	and    $0x3,%ecx
  105d0a:	74 02                	je     105d0e <memmove+0x53>
  105d0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d0e:	89 f0                	mov    %esi,%eax
  105d10:	89 fa                	mov    %edi,%edx
  105d12:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  105d15:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  105d18:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105d1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
  105d1e:	eb 36                	jmp    105d56 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  105d20:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d23:	8d 50 ff             	lea    -0x1(%eax),%edx
  105d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d29:	01 c2                	add    %eax,%edx
  105d2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d2e:	8d 48 ff             	lea    -0x1(%eax),%ecx
  105d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d34:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
  105d37:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105d3a:	89 c1                	mov    %eax,%ecx
  105d3c:	89 d8                	mov    %ebx,%eax
  105d3e:	89 d6                	mov    %edx,%esi
  105d40:	89 c7                	mov    %eax,%edi
  105d42:	fd                   	std    
  105d43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d45:	fc                   	cld    
  105d46:	89 f8                	mov    %edi,%eax
  105d48:	89 f2                	mov    %esi,%edx
  105d4a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  105d4d:	89 55 c8             	mov    %edx,-0x38(%ebp)
  105d50:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
  105d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  105d56:	83 c4 30             	add    $0x30,%esp
  105d59:	5b                   	pop    %ebx
  105d5a:	5e                   	pop    %esi
  105d5b:	5f                   	pop    %edi
  105d5c:	5d                   	pop    %ebp
  105d5d:	c3                   	ret    

00105d5e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  105d5e:	55                   	push   %ebp
  105d5f:	89 e5                	mov    %esp,%ebp
  105d61:	57                   	push   %edi
  105d62:	56                   	push   %esi
  105d63:	83 ec 20             	sub    $0x20,%esp
  105d66:	8b 45 08             	mov    0x8(%ebp),%eax
  105d69:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105d6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105d72:	8b 45 10             	mov    0x10(%ebp),%eax
  105d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  105d78:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d7b:	c1 e8 02             	shr    $0x2,%eax
  105d7e:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
  105d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d86:	89 d7                	mov    %edx,%edi
  105d88:	89 c6                	mov    %eax,%esi
  105d8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  105d8c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  105d8f:	83 e1 03             	and    $0x3,%ecx
  105d92:	74 02                	je     105d96 <memcpy+0x38>
  105d94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  105d96:	89 f0                	mov    %esi,%eax
  105d98:	89 fa                	mov    %edi,%edx
  105d9a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105d9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  105da0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
  105da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
  105da6:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  105da7:	83 c4 20             	add    $0x20,%esp
  105daa:	5e                   	pop    %esi
  105dab:	5f                   	pop    %edi
  105dac:	5d                   	pop    %ebp
  105dad:	c3                   	ret    

00105dae <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  105dae:	55                   	push   %ebp
  105daf:	89 e5                	mov    %esp,%ebp
  105db1:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  105db4:	8b 45 08             	mov    0x8(%ebp),%eax
  105db7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  105dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  105dbd:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  105dc0:	eb 2e                	jmp    105df0 <memcmp+0x42>
        if (*s1 != *s2) {
  105dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105dc5:	0f b6 10             	movzbl (%eax),%edx
  105dc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105dcb:	0f b6 00             	movzbl (%eax),%eax
  105dce:	38 c2                	cmp    %al,%dl
  105dd0:	74 18                	je     105dea <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  105dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105dd5:	0f b6 00             	movzbl (%eax),%eax
  105dd8:	0f b6 d0             	movzbl %al,%edx
  105ddb:	8b 45 f8             	mov    -0x8(%ebp),%eax
  105dde:	0f b6 00             	movzbl (%eax),%eax
  105de1:	0f b6 c0             	movzbl %al,%eax
  105de4:	29 c2                	sub    %eax,%edx
  105de6:	89 d0                	mov    %edx,%eax
  105de8:	eb 18                	jmp    105e02 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  105dea:	ff 45 fc             	incl   -0x4(%ebp)
  105ded:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
  105df0:	8b 45 10             	mov    0x10(%ebp),%eax
  105df3:	8d 50 ff             	lea    -0x1(%eax),%edx
  105df6:	89 55 10             	mov    %edx,0x10(%ebp)
  105df9:	85 c0                	test   %eax,%eax
  105dfb:	75 c5                	jne    105dc2 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
  105dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105e02:	c9                   	leave  
  105e03:	c3                   	ret    

00105e04 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  105e04:	55                   	push   %ebp
  105e05:	89 e5                	mov    %esp,%ebp
  105e07:	83 ec 58             	sub    $0x58,%esp
  105e0a:	8b 45 10             	mov    0x10(%ebp),%eax
  105e0d:	89 45 d0             	mov    %eax,-0x30(%ebp)
  105e10:	8b 45 14             	mov    0x14(%ebp),%eax
  105e13:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  105e16:	8b 45 d0             	mov    -0x30(%ebp),%eax
  105e19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105e1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105e1f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  105e22:	8b 45 18             	mov    0x18(%ebp),%eax
  105e25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105e28:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105e2b:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105e2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e31:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  105e3e:	74 1c                	je     105e5c <printnum+0x58>
  105e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e43:	ba 00 00 00 00       	mov    $0x0,%edx
  105e48:	f7 75 e4             	divl   -0x1c(%ebp)
  105e4b:	89 55 f4             	mov    %edx,-0xc(%ebp)
  105e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e51:	ba 00 00 00 00       	mov    $0x0,%edx
  105e56:	f7 75 e4             	divl   -0x1c(%ebp)
  105e59:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e62:	f7 75 e4             	divl   -0x1c(%ebp)
  105e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105e68:	89 55 dc             	mov    %edx,-0x24(%ebp)
  105e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105e6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105e71:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105e74:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105e7a:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  105e7d:	8b 45 18             	mov    0x18(%ebp),%eax
  105e80:	ba 00 00 00 00       	mov    $0x0,%edx
  105e85:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105e88:	77 56                	ja     105ee0 <printnum+0xdc>
  105e8a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
  105e8d:	72 05                	jb     105e94 <printnum+0x90>
  105e8f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
  105e92:	77 4c                	ja     105ee0 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
  105e94:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105e97:	8d 50 ff             	lea    -0x1(%eax),%edx
  105e9a:	8b 45 20             	mov    0x20(%ebp),%eax
  105e9d:	89 44 24 18          	mov    %eax,0x18(%esp)
  105ea1:	89 54 24 14          	mov    %edx,0x14(%esp)
  105ea5:	8b 45 18             	mov    0x18(%ebp),%eax
  105ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  105eac:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105eaf:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105eb2:	89 44 24 08          	mov    %eax,0x8(%esp)
  105eb6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105eba:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec4:	89 04 24             	mov    %eax,(%esp)
  105ec7:	e8 38 ff ff ff       	call   105e04 <printnum>
  105ecc:	eb 1b                	jmp    105ee9 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105ece:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ed5:	8b 45 20             	mov    0x20(%ebp),%eax
  105ed8:	89 04 24             	mov    %eax,(%esp)
  105edb:	8b 45 08             	mov    0x8(%ebp),%eax
  105ede:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  105ee0:	ff 4d 1c             	decl   0x1c(%ebp)
  105ee3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105ee7:	7f e5                	jg     105ece <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  105ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  105eec:	05 bc 76 10 00       	add    $0x1076bc,%eax
  105ef1:	0f b6 00             	movzbl (%eax),%eax
  105ef4:	0f be c0             	movsbl %al,%eax
  105ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
  105efa:	89 54 24 04          	mov    %edx,0x4(%esp)
  105efe:	89 04 24             	mov    %eax,(%esp)
  105f01:	8b 45 08             	mov    0x8(%ebp),%eax
  105f04:	ff d0                	call   *%eax
}
  105f06:	90                   	nop
  105f07:	c9                   	leave  
  105f08:	c3                   	ret    

00105f09 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  105f09:	55                   	push   %ebp
  105f0a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105f0c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105f10:	7e 14                	jle    105f26 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  105f12:	8b 45 08             	mov    0x8(%ebp),%eax
  105f15:	8b 00                	mov    (%eax),%eax
  105f17:	8d 48 08             	lea    0x8(%eax),%ecx
  105f1a:	8b 55 08             	mov    0x8(%ebp),%edx
  105f1d:	89 0a                	mov    %ecx,(%edx)
  105f1f:	8b 50 04             	mov    0x4(%eax),%edx
  105f22:	8b 00                	mov    (%eax),%eax
  105f24:	eb 30                	jmp    105f56 <getuint+0x4d>
    }
    else if (lflag) {
  105f26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105f2a:	74 16                	je     105f42 <getuint+0x39>
        return va_arg(*ap, unsigned long);
  105f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  105f2f:	8b 00                	mov    (%eax),%eax
  105f31:	8d 48 04             	lea    0x4(%eax),%ecx
  105f34:	8b 55 08             	mov    0x8(%ebp),%edx
  105f37:	89 0a                	mov    %ecx,(%edx)
  105f39:	8b 00                	mov    (%eax),%eax
  105f3b:	ba 00 00 00 00       	mov    $0x0,%edx
  105f40:	eb 14                	jmp    105f56 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  105f42:	8b 45 08             	mov    0x8(%ebp),%eax
  105f45:	8b 00                	mov    (%eax),%eax
  105f47:	8d 48 04             	lea    0x4(%eax),%ecx
  105f4a:	8b 55 08             	mov    0x8(%ebp),%edx
  105f4d:	89 0a                	mov    %ecx,(%edx)
  105f4f:	8b 00                	mov    (%eax),%eax
  105f51:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105f56:	5d                   	pop    %ebp
  105f57:	c3                   	ret    

00105f58 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105f58:	55                   	push   %ebp
  105f59:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105f5b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  105f5f:	7e 14                	jle    105f75 <getint+0x1d>
        return va_arg(*ap, long long);
  105f61:	8b 45 08             	mov    0x8(%ebp),%eax
  105f64:	8b 00                	mov    (%eax),%eax
  105f66:	8d 48 08             	lea    0x8(%eax),%ecx
  105f69:	8b 55 08             	mov    0x8(%ebp),%edx
  105f6c:	89 0a                	mov    %ecx,(%edx)
  105f6e:	8b 50 04             	mov    0x4(%eax),%edx
  105f71:	8b 00                	mov    (%eax),%eax
  105f73:	eb 28                	jmp    105f9d <getint+0x45>
    }
    else if (lflag) {
  105f75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105f79:	74 12                	je     105f8d <getint+0x35>
        return va_arg(*ap, long);
  105f7b:	8b 45 08             	mov    0x8(%ebp),%eax
  105f7e:	8b 00                	mov    (%eax),%eax
  105f80:	8d 48 04             	lea    0x4(%eax),%ecx
  105f83:	8b 55 08             	mov    0x8(%ebp),%edx
  105f86:	89 0a                	mov    %ecx,(%edx)
  105f88:	8b 00                	mov    (%eax),%eax
  105f8a:	99                   	cltd   
  105f8b:	eb 10                	jmp    105f9d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105f8d:	8b 45 08             	mov    0x8(%ebp),%eax
  105f90:	8b 00                	mov    (%eax),%eax
  105f92:	8d 48 04             	lea    0x4(%eax),%ecx
  105f95:	8b 55 08             	mov    0x8(%ebp),%edx
  105f98:	89 0a                	mov    %ecx,(%edx)
  105f9a:	8b 00                	mov    (%eax),%eax
  105f9c:	99                   	cltd   
    }
}
  105f9d:	5d                   	pop    %ebp
  105f9e:	c3                   	ret    

00105f9f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  105f9f:	55                   	push   %ebp
  105fa0:	89 e5                	mov    %esp,%ebp
  105fa2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105fa5:	8d 45 14             	lea    0x14(%ebp),%eax
  105fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105fae:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105fb2:	8b 45 10             	mov    0x10(%ebp),%eax
  105fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  105fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  105fc3:	89 04 24             	mov    %eax,(%esp)
  105fc6:	e8 03 00 00 00       	call   105fce <vprintfmt>
    va_end(ap);
}
  105fcb:	90                   	nop
  105fcc:	c9                   	leave  
  105fcd:	c3                   	ret    

00105fce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  105fce:	55                   	push   %ebp
  105fcf:	89 e5                	mov    %esp,%ebp
  105fd1:	56                   	push   %esi
  105fd2:	53                   	push   %ebx
  105fd3:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105fd6:	eb 17                	jmp    105fef <vprintfmt+0x21>
            if (ch == '\0') {
  105fd8:	85 db                	test   %ebx,%ebx
  105fda:	0f 84 bf 03 00 00    	je     10639f <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  105fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
  105fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
  105fe7:	89 1c 24             	mov    %ebx,(%esp)
  105fea:	8b 45 08             	mov    0x8(%ebp),%eax
  105fed:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  105fef:	8b 45 10             	mov    0x10(%ebp),%eax
  105ff2:	8d 50 01             	lea    0x1(%eax),%edx
  105ff5:	89 55 10             	mov    %edx,0x10(%ebp)
  105ff8:	0f b6 00             	movzbl (%eax),%eax
  105ffb:	0f b6 d8             	movzbl %al,%ebx
  105ffe:	83 fb 25             	cmp    $0x25,%ebx
  106001:	75 d5                	jne    105fd8 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
  106003:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  106007:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  10600e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106011:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  106014:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10601b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10601e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  106021:	8b 45 10             	mov    0x10(%ebp),%eax
  106024:	8d 50 01             	lea    0x1(%eax),%edx
  106027:	89 55 10             	mov    %edx,0x10(%ebp)
  10602a:	0f b6 00             	movzbl (%eax),%eax
  10602d:	0f b6 d8             	movzbl %al,%ebx
  106030:	8d 43 dd             	lea    -0x23(%ebx),%eax
  106033:	83 f8 55             	cmp    $0x55,%eax
  106036:	0f 87 37 03 00 00    	ja     106373 <vprintfmt+0x3a5>
  10603c:	8b 04 85 e0 76 10 00 	mov    0x1076e0(,%eax,4),%eax
  106043:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  106045:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  106049:	eb d6                	jmp    106021 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  10604b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10604f:	eb d0                	jmp    106021 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  106051:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  106058:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10605b:	89 d0                	mov    %edx,%eax
  10605d:	c1 e0 02             	shl    $0x2,%eax
  106060:	01 d0                	add    %edx,%eax
  106062:	01 c0                	add    %eax,%eax
  106064:	01 d8                	add    %ebx,%eax
  106066:	83 e8 30             	sub    $0x30,%eax
  106069:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10606c:	8b 45 10             	mov    0x10(%ebp),%eax
  10606f:	0f b6 00             	movzbl (%eax),%eax
  106072:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  106075:	83 fb 2f             	cmp    $0x2f,%ebx
  106078:	7e 38                	jle    1060b2 <vprintfmt+0xe4>
  10607a:	83 fb 39             	cmp    $0x39,%ebx
  10607d:	7f 33                	jg     1060b2 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10607f:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
  106082:	eb d4                	jmp    106058 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  106084:	8b 45 14             	mov    0x14(%ebp),%eax
  106087:	8d 50 04             	lea    0x4(%eax),%edx
  10608a:	89 55 14             	mov    %edx,0x14(%ebp)
  10608d:	8b 00                	mov    (%eax),%eax
  10608f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  106092:	eb 1f                	jmp    1060b3 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  106094:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106098:	79 87                	jns    106021 <vprintfmt+0x53>
                width = 0;
  10609a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  1060a1:	e9 7b ff ff ff       	jmp    106021 <vprintfmt+0x53>

        case '#':
            altflag = 1;
  1060a6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  1060ad:	e9 6f ff ff ff       	jmp    106021 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
  1060b2:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
  1060b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1060b7:	0f 89 64 ff ff ff    	jns    106021 <vprintfmt+0x53>
                width = precision, precision = -1;
  1060bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1060c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1060c3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  1060ca:	e9 52 ff ff ff       	jmp    106021 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  1060cf:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1060d2:	e9 4a ff ff ff       	jmp    106021 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1060d7:	8b 45 14             	mov    0x14(%ebp),%eax
  1060da:	8d 50 04             	lea    0x4(%eax),%edx
  1060dd:	89 55 14             	mov    %edx,0x14(%ebp)
  1060e0:	8b 00                	mov    (%eax),%eax
  1060e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  1060e5:	89 54 24 04          	mov    %edx,0x4(%esp)
  1060e9:	89 04 24             	mov    %eax,(%esp)
  1060ec:	8b 45 08             	mov    0x8(%ebp),%eax
  1060ef:	ff d0                	call   *%eax
            break;
  1060f1:	e9 a4 02 00 00       	jmp    10639a <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1060f6:	8b 45 14             	mov    0x14(%ebp),%eax
  1060f9:	8d 50 04             	lea    0x4(%eax),%edx
  1060fc:	89 55 14             	mov    %edx,0x14(%ebp)
  1060ff:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  106101:	85 db                	test   %ebx,%ebx
  106103:	79 02                	jns    106107 <vprintfmt+0x139>
                err = -err;
  106105:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  106107:	83 fb 06             	cmp    $0x6,%ebx
  10610a:	7f 0b                	jg     106117 <vprintfmt+0x149>
  10610c:	8b 34 9d a0 76 10 00 	mov    0x1076a0(,%ebx,4),%esi
  106113:	85 f6                	test   %esi,%esi
  106115:	75 23                	jne    10613a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  106117:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  10611b:	c7 44 24 08 cd 76 10 	movl   $0x1076cd,0x8(%esp)
  106122:	00 
  106123:	8b 45 0c             	mov    0xc(%ebp),%eax
  106126:	89 44 24 04          	mov    %eax,0x4(%esp)
  10612a:	8b 45 08             	mov    0x8(%ebp),%eax
  10612d:	89 04 24             	mov    %eax,(%esp)
  106130:	e8 6a fe ff ff       	call   105f9f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  106135:	e9 60 02 00 00       	jmp    10639a <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
  10613a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  10613e:	c7 44 24 08 d6 76 10 	movl   $0x1076d6,0x8(%esp)
  106145:	00 
  106146:	8b 45 0c             	mov    0xc(%ebp),%eax
  106149:	89 44 24 04          	mov    %eax,0x4(%esp)
  10614d:	8b 45 08             	mov    0x8(%ebp),%eax
  106150:	89 04 24             	mov    %eax,(%esp)
  106153:	e8 47 fe ff ff       	call   105f9f <printfmt>
            }
            break;
  106158:	e9 3d 02 00 00       	jmp    10639a <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  10615d:	8b 45 14             	mov    0x14(%ebp),%eax
  106160:	8d 50 04             	lea    0x4(%eax),%edx
  106163:	89 55 14             	mov    %edx,0x14(%ebp)
  106166:	8b 30                	mov    (%eax),%esi
  106168:	85 f6                	test   %esi,%esi
  10616a:	75 05                	jne    106171 <vprintfmt+0x1a3>
                p = "(null)";
  10616c:	be d9 76 10 00       	mov    $0x1076d9,%esi
            }
            if (width > 0 && padc != '-') {
  106171:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106175:	7e 76                	jle    1061ed <vprintfmt+0x21f>
  106177:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  10617b:	74 70                	je     1061ed <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  10617d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  106180:	89 44 24 04          	mov    %eax,0x4(%esp)
  106184:	89 34 24             	mov    %esi,(%esp)
  106187:	e8 f6 f7 ff ff       	call   105982 <strnlen>
  10618c:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10618f:	29 c2                	sub    %eax,%edx
  106191:	89 d0                	mov    %edx,%eax
  106193:	89 45 e8             	mov    %eax,-0x18(%ebp)
  106196:	eb 16                	jmp    1061ae <vprintfmt+0x1e0>
                    putch(padc, putdat);
  106198:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  10619c:	8b 55 0c             	mov    0xc(%ebp),%edx
  10619f:	89 54 24 04          	mov    %edx,0x4(%esp)
  1061a3:	89 04 24             	mov    %eax,(%esp)
  1061a6:	8b 45 08             	mov    0x8(%ebp),%eax
  1061a9:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
  1061ab:	ff 4d e8             	decl   -0x18(%ebp)
  1061ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  1061b2:	7f e4                	jg     106198 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1061b4:	eb 37                	jmp    1061ed <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  1061b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  1061ba:	74 1f                	je     1061db <vprintfmt+0x20d>
  1061bc:	83 fb 1f             	cmp    $0x1f,%ebx
  1061bf:	7e 05                	jle    1061c6 <vprintfmt+0x1f8>
  1061c1:	83 fb 7e             	cmp    $0x7e,%ebx
  1061c4:	7e 15                	jle    1061db <vprintfmt+0x20d>
                    putch('?', putdat);
  1061c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061cd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  1061d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1061d7:	ff d0                	call   *%eax
  1061d9:	eb 0f                	jmp    1061ea <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  1061db:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061de:	89 44 24 04          	mov    %eax,0x4(%esp)
  1061e2:	89 1c 24             	mov    %ebx,(%esp)
  1061e5:	8b 45 08             	mov    0x8(%ebp),%eax
  1061e8:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  1061ea:	ff 4d e8             	decl   -0x18(%ebp)
  1061ed:	89 f0                	mov    %esi,%eax
  1061ef:	8d 70 01             	lea    0x1(%eax),%esi
  1061f2:	0f b6 00             	movzbl (%eax),%eax
  1061f5:	0f be d8             	movsbl %al,%ebx
  1061f8:	85 db                	test   %ebx,%ebx
  1061fa:	74 27                	je     106223 <vprintfmt+0x255>
  1061fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106200:	78 b4                	js     1061b6 <vprintfmt+0x1e8>
  106202:	ff 4d e4             	decl   -0x1c(%ebp)
  106205:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  106209:	79 ab                	jns    1061b6 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  10620b:	eb 16                	jmp    106223 <vprintfmt+0x255>
                putch(' ', putdat);
  10620d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106210:	89 44 24 04          	mov    %eax,0x4(%esp)
  106214:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10621b:	8b 45 08             	mov    0x8(%ebp),%eax
  10621e:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
  106220:	ff 4d e8             	decl   -0x18(%ebp)
  106223:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  106227:	7f e4                	jg     10620d <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
  106229:	e9 6c 01 00 00       	jmp    10639a <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  10622e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106231:	89 44 24 04          	mov    %eax,0x4(%esp)
  106235:	8d 45 14             	lea    0x14(%ebp),%eax
  106238:	89 04 24             	mov    %eax,(%esp)
  10623b:	e8 18 fd ff ff       	call   105f58 <getint>
  106240:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106243:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  106246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106249:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10624c:	85 d2                	test   %edx,%edx
  10624e:	79 26                	jns    106276 <vprintfmt+0x2a8>
                putch('-', putdat);
  106250:	8b 45 0c             	mov    0xc(%ebp),%eax
  106253:	89 44 24 04          	mov    %eax,0x4(%esp)
  106257:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  10625e:	8b 45 08             	mov    0x8(%ebp),%eax
  106261:	ff d0                	call   *%eax
                num = -(long long)num;
  106263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106266:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106269:	f7 d8                	neg    %eax
  10626b:	83 d2 00             	adc    $0x0,%edx
  10626e:	f7 da                	neg    %edx
  106270:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106273:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  106276:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  10627d:	e9 a8 00 00 00       	jmp    10632a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  106282:	8b 45 e0             	mov    -0x20(%ebp),%eax
  106285:	89 44 24 04          	mov    %eax,0x4(%esp)
  106289:	8d 45 14             	lea    0x14(%ebp),%eax
  10628c:	89 04 24             	mov    %eax,(%esp)
  10628f:	e8 75 fc ff ff       	call   105f09 <getuint>
  106294:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106297:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  10629a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  1062a1:	e9 84 00 00 00       	jmp    10632a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  1062a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1062a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062ad:	8d 45 14             	lea    0x14(%ebp),%eax
  1062b0:	89 04 24             	mov    %eax,(%esp)
  1062b3:	e8 51 fc ff ff       	call   105f09 <getuint>
  1062b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1062bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  1062be:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  1062c5:	eb 63                	jmp    10632a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  1062c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  1062d5:	8b 45 08             	mov    0x8(%ebp),%eax
  1062d8:	ff d0                	call   *%eax
            putch('x', putdat);
  1062da:	8b 45 0c             	mov    0xc(%ebp),%eax
  1062dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  1062e1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  1062e8:	8b 45 08             	mov    0x8(%ebp),%eax
  1062eb:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  1062ed:	8b 45 14             	mov    0x14(%ebp),%eax
  1062f0:	8d 50 04             	lea    0x4(%eax),%edx
  1062f3:	89 55 14             	mov    %edx,0x14(%ebp)
  1062f6:	8b 00                	mov    (%eax),%eax
  1062f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1062fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  106302:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  106309:	eb 1f                	jmp    10632a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  10630b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10630e:	89 44 24 04          	mov    %eax,0x4(%esp)
  106312:	8d 45 14             	lea    0x14(%ebp),%eax
  106315:	89 04 24             	mov    %eax,(%esp)
  106318:	e8 ec fb ff ff       	call   105f09 <getuint>
  10631d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  106320:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  106323:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  10632a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  10632e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106331:	89 54 24 18          	mov    %edx,0x18(%esp)
  106335:	8b 55 e8             	mov    -0x18(%ebp),%edx
  106338:	89 54 24 14          	mov    %edx,0x14(%esp)
  10633c:	89 44 24 10          	mov    %eax,0x10(%esp)
  106340:	8b 45 f0             	mov    -0x10(%ebp),%eax
  106343:	8b 55 f4             	mov    -0xc(%ebp),%edx
  106346:	89 44 24 08          	mov    %eax,0x8(%esp)
  10634a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  10634e:	8b 45 0c             	mov    0xc(%ebp),%eax
  106351:	89 44 24 04          	mov    %eax,0x4(%esp)
  106355:	8b 45 08             	mov    0x8(%ebp),%eax
  106358:	89 04 24             	mov    %eax,(%esp)
  10635b:	e8 a4 fa ff ff       	call   105e04 <printnum>
            break;
  106360:	eb 38                	jmp    10639a <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  106362:	8b 45 0c             	mov    0xc(%ebp),%eax
  106365:	89 44 24 04          	mov    %eax,0x4(%esp)
  106369:	89 1c 24             	mov    %ebx,(%esp)
  10636c:	8b 45 08             	mov    0x8(%ebp),%eax
  10636f:	ff d0                	call   *%eax
            break;
  106371:	eb 27                	jmp    10639a <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  106373:	8b 45 0c             	mov    0xc(%ebp),%eax
  106376:	89 44 24 04          	mov    %eax,0x4(%esp)
  10637a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  106381:	8b 45 08             	mov    0x8(%ebp),%eax
  106384:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  106386:	ff 4d 10             	decl   0x10(%ebp)
  106389:	eb 03                	jmp    10638e <vprintfmt+0x3c0>
  10638b:	ff 4d 10             	decl   0x10(%ebp)
  10638e:	8b 45 10             	mov    0x10(%ebp),%eax
  106391:	48                   	dec    %eax
  106392:	0f b6 00             	movzbl (%eax),%eax
  106395:	3c 25                	cmp    $0x25,%al
  106397:	75 f2                	jne    10638b <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  106399:	90                   	nop
        }
    }
  10639a:	e9 37 fc ff ff       	jmp    105fd6 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
  10639f:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  1063a0:	83 c4 40             	add    $0x40,%esp
  1063a3:	5b                   	pop    %ebx
  1063a4:	5e                   	pop    %esi
  1063a5:	5d                   	pop    %ebp
  1063a6:	c3                   	ret    

001063a7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  1063a7:	55                   	push   %ebp
  1063a8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  1063aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063ad:	8b 40 08             	mov    0x8(%eax),%eax
  1063b0:	8d 50 01             	lea    0x1(%eax),%edx
  1063b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063b6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  1063b9:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063bc:	8b 10                	mov    (%eax),%edx
  1063be:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063c1:	8b 40 04             	mov    0x4(%eax),%eax
  1063c4:	39 c2                	cmp    %eax,%edx
  1063c6:	73 12                	jae    1063da <sprintputch+0x33>
        *b->buf ++ = ch;
  1063c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063cb:	8b 00                	mov    (%eax),%eax
  1063cd:	8d 48 01             	lea    0x1(%eax),%ecx
  1063d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1063d3:	89 0a                	mov    %ecx,(%edx)
  1063d5:	8b 55 08             	mov    0x8(%ebp),%edx
  1063d8:	88 10                	mov    %dl,(%eax)
    }
}
  1063da:	90                   	nop
  1063db:	5d                   	pop    %ebp
  1063dc:	c3                   	ret    

001063dd <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  1063dd:	55                   	push   %ebp
  1063de:	89 e5                	mov    %esp,%ebp
  1063e0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  1063e3:	8d 45 14             	lea    0x14(%ebp),%eax
  1063e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  1063e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1063ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1063f0:	8b 45 10             	mov    0x10(%ebp),%eax
  1063f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  1063f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1063fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  1063fe:	8b 45 08             	mov    0x8(%ebp),%eax
  106401:	89 04 24             	mov    %eax,(%esp)
  106404:	e8 08 00 00 00       	call   106411 <vsnprintf>
  106409:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  10640c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10640f:	c9                   	leave  
  106410:	c3                   	ret    

00106411 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  106411:	55                   	push   %ebp
  106412:	89 e5                	mov    %esp,%ebp
  106414:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  106417:	8b 45 08             	mov    0x8(%ebp),%eax
  10641a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  10641d:	8b 45 0c             	mov    0xc(%ebp),%eax
  106420:	8d 50 ff             	lea    -0x1(%eax),%edx
  106423:	8b 45 08             	mov    0x8(%ebp),%eax
  106426:	01 d0                	add    %edx,%eax
  106428:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10642b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  106432:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  106436:	74 0a                	je     106442 <vsnprintf+0x31>
  106438:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10643b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10643e:	39 c2                	cmp    %eax,%edx
  106440:	76 07                	jbe    106449 <vsnprintf+0x38>
        return -E_INVAL;
  106442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  106447:	eb 2a                	jmp    106473 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  106449:	8b 45 14             	mov    0x14(%ebp),%eax
  10644c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  106450:	8b 45 10             	mov    0x10(%ebp),%eax
  106453:	89 44 24 08          	mov    %eax,0x8(%esp)
  106457:	8d 45 ec             	lea    -0x14(%ebp),%eax
  10645a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10645e:	c7 04 24 a7 63 10 00 	movl   $0x1063a7,(%esp)
  106465:	e8 64 fb ff ff       	call   105fce <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  10646a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10646d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  106470:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  106473:	c9                   	leave  
  106474:	c3                   	ret    
