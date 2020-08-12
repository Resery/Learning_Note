
bin/kernel:     file format elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 90 11 00       	mov    $0x119000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 90 11 c0       	mov    %eax,0xc0119000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 80 11 c0       	mov    $0xc0118000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	ba a8 bf 11 c0       	mov    $0xc011bfa8,%edx
c0100041:	b8 00 b0 11 c0       	mov    $0xc011b000,%eax
c0100046:	29 c2                	sub    %eax,%edx
c0100048:	89 d0                	mov    %edx,%eax
c010004a:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100055:	00 
c0100056:	c7 04 24 00 b0 11 c0 	movl   $0xc011b000,(%esp)
c010005d:	e8 19 5c 00 00       	call   c0105c7b <memset>

    cons_init();                // init the console
c0100062:	e8 96 15 00 00       	call   c01015fd <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100067:	c7 45 f4 80 64 10 c0 	movl   $0xc0106480,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100071:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100075:	c7 04 24 9c 64 10 c0 	movl   $0xc010649c,(%esp)
c010007c:	e8 1c 02 00 00       	call   c010029d <cprintf>

    print_kerninfo();
c0100081:	e8 bd 08 00 00       	call   c0100943 <print_kerninfo>

    grade_backtrace();
c0100086:	e8 89 00 00 00       	call   c0100114 <grade_backtrace>

    pmm_init();                 // init physical memory management
c010008b:	e8 91 35 00 00       	call   c0103621 <pmm_init>

    pic_init();                 // init interrupt controller
c0100090:	e8 cc 16 00 00       	call   c0101761 <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100095:	e8 25 18 00 00       	call   c01018bf <idt_init>

    clock_init();               // init clock interrupt
c010009a:	e8 11 0d 00 00       	call   c0100db0 <clock_init>
    intr_enable();              // enable irq interrupt
c010009f:	e8 f0 17 00 00       	call   c0101894 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a4:	eb fe                	jmp    c01000a4 <kern_init+0x6e>

c01000a6 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a6:	55                   	push   %ebp
c01000a7:	89 e5                	mov    %esp,%ebp
c01000a9:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000ac:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000b3:	00 
c01000b4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000bb:	00 
c01000bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000c3:	e8 d6 0c 00 00       	call   c0100d9e <mon_backtrace>
}
c01000c8:	90                   	nop
c01000c9:	c9                   	leave  
c01000ca:	c3                   	ret    

c01000cb <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000cb:	55                   	push   %ebp
c01000cc:	89 e5                	mov    %esp,%ebp
c01000ce:	53                   	push   %ebx
c01000cf:	83 ec 14             	sub    $0x14,%esp
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b4 ff ff ff       	call   c01000a6 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	83 c4 14             	add    $0x14,%esp
c01000f6:	5b                   	pop    %ebx
c01000f7:	5d                   	pop    %ebp
c01000f8:	c3                   	ret    

c01000f9 <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000f9:	55                   	push   %ebp
c01000fa:	89 e5                	mov    %esp,%ebp
c01000fc:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c01000ff:	8b 45 10             	mov    0x10(%ebp),%eax
c0100102:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100106:	8b 45 08             	mov    0x8(%ebp),%eax
c0100109:	89 04 24             	mov    %eax,(%esp)
c010010c:	e8 ba ff ff ff       	call   c01000cb <grade_backtrace1>
}
c0100111:	90                   	nop
c0100112:	c9                   	leave  
c0100113:	c3                   	ret    

c0100114 <grade_backtrace>:

void
grade_backtrace(void) {
c0100114:	55                   	push   %ebp
c0100115:	89 e5                	mov    %esp,%ebp
c0100117:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011a:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c010011f:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100126:	ff 
c0100127:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100132:	e8 c2 ff ff ff       	call   c01000f9 <grade_backtrace0>
}
c0100137:	90                   	nop
c0100138:	c9                   	leave  
c0100139:	c3                   	ret    

c010013a <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013a:	55                   	push   %ebp
c010013b:	89 e5                	mov    %esp,%ebp
c010013d:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100140:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100143:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c0100146:	8c 45 f2             	mov    %es,-0xe(%ebp)
c0100149:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c010014c:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100150:	83 e0 03             	and    $0x3,%eax
c0100153:	89 c2                	mov    %eax,%edx
c0100155:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c010015a:	89 54 24 08          	mov    %edx,0x8(%esp)
c010015e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100162:	c7 04 24 a1 64 10 c0 	movl   $0xc01064a1,(%esp)
c0100169:	e8 2f 01 00 00       	call   c010029d <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c010016e:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100172:	89 c2                	mov    %eax,%edx
c0100174:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c0100179:	89 54 24 08          	mov    %edx,0x8(%esp)
c010017d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100181:	c7 04 24 af 64 10 c0 	movl   $0xc01064af,(%esp)
c0100188:	e8 10 01 00 00       	call   c010029d <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c010018d:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100191:	89 c2                	mov    %eax,%edx
c0100193:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c0100198:	89 54 24 08          	mov    %edx,0x8(%esp)
c010019c:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a0:	c7 04 24 bd 64 10 c0 	movl   $0xc01064bd,(%esp)
c01001a7:	e8 f1 00 00 00       	call   c010029d <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001ac:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b0:	89 c2                	mov    %eax,%edx
c01001b2:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001b7:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001bb:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001bf:	c7 04 24 cb 64 10 c0 	movl   $0xc01064cb,(%esp)
c01001c6:	e8 d2 00 00 00       	call   c010029d <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001cb:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001cf:	89 c2                	mov    %eax,%edx
c01001d1:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001d6:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001da:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001de:	c7 04 24 d9 64 10 c0 	movl   $0xc01064d9,(%esp)
c01001e5:	e8 b3 00 00 00       	call   c010029d <cprintf>
    round ++;
c01001ea:	a1 00 b0 11 c0       	mov    0xc011b000,%eax
c01001ef:	40                   	inc    %eax
c01001f0:	a3 00 b0 11 c0       	mov    %eax,0xc011b000
}
c01001f5:	90                   	nop
c01001f6:	c9                   	leave  
c01001f7:	c3                   	ret    

c01001f8 <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001f8:	55                   	push   %ebp
c01001f9:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
    asm volatile (
c01001fb:	83 ec 08             	sub    $0x8,%esp
c01001fe:	cd 78                	int    $0x78
c0100200:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        : 
        : "i"(T_SWITCH_TOU)
    );
}
c0100202:	90                   	nop
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
    asm volatile (
c0100208:	cd 79                	int    $0x79
c010020a:	89 ec                	mov    %ebp,%esp
           "int %0 \n"
           "movl %%ebp, %%esp"
           : 
           : "i"(T_SWITCH_TOK)
    );
}
c010020c:	90                   	nop
c010020d:	5d                   	pop    %ebp
c010020e:	c3                   	ret    

c010020f <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010020f:	55                   	push   %ebp
c0100210:	89 e5                	mov    %esp,%ebp
c0100212:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100215:	e8 20 ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c010021a:	c7 04 24 e8 64 10 c0 	movl   $0xc01064e8,(%esp)
c0100221:	e8 77 00 00 00       	call   c010029d <cprintf>
    lab1_switch_to_user();
c0100226:	e8 cd ff ff ff       	call   c01001f8 <lab1_switch_to_user>
    lab1_print_cur_status();
c010022b:	e8 0a ff ff ff       	call   c010013a <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c0100230:	c7 04 24 08 65 10 c0 	movl   $0xc0106508,(%esp)
c0100237:	e8 61 00 00 00       	call   c010029d <cprintf>
    lab1_switch_to_kernel();
c010023c:	e8 c4 ff ff ff       	call   c0100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c0100241:	e8 f4 fe ff ff       	call   c010013a <lab1_print_cur_status>
}
c0100246:	90                   	nop
c0100247:	c9                   	leave  
c0100248:	c3                   	ret    

c0100249 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c0100249:	55                   	push   %ebp
c010024a:	89 e5                	mov    %esp,%ebp
c010024c:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c010024f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100252:	89 04 24             	mov    %eax,(%esp)
c0100255:	e8 d0 13 00 00       	call   c010162a <cons_putc>
    (*cnt) ++;
c010025a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010025d:	8b 00                	mov    (%eax),%eax
c010025f:	8d 50 01             	lea    0x1(%eax),%edx
c0100262:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100265:	89 10                	mov    %edx,(%eax)
}
c0100267:	90                   	nop
c0100268:	c9                   	leave  
c0100269:	c3                   	ret    

c010026a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c010026a:	55                   	push   %ebp
c010026b:	89 e5                	mov    %esp,%ebp
c010026d:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100270:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c0100277:	8b 45 0c             	mov    0xc(%ebp),%eax
c010027a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010027e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100281:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100285:	8d 45 f4             	lea    -0xc(%ebp),%eax
c0100288:	89 44 24 04          	mov    %eax,0x4(%esp)
c010028c:	c7 04 24 49 02 10 c0 	movl   $0xc0100249,(%esp)
c0100293:	e8 36 5d 00 00       	call   c0105fce <vprintfmt>
    return cnt;
c0100298:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010029b:	c9                   	leave  
c010029c:	c3                   	ret    

c010029d <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c010029d:	55                   	push   %ebp
c010029e:	89 e5                	mov    %esp,%ebp
c01002a0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01002a3:	8d 45 0c             	lea    0xc(%ebp),%eax
c01002a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c01002a9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002ac:	89 44 24 04          	mov    %eax,0x4(%esp)
c01002b0:	8b 45 08             	mov    0x8(%ebp),%eax
c01002b3:	89 04 24             	mov    %eax,(%esp)
c01002b6:	e8 af ff ff ff       	call   c010026a <vcprintf>
c01002bb:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c01002be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01002c1:	c9                   	leave  
c01002c2:	c3                   	ret    

c01002c3 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c01002c3:	55                   	push   %ebp
c01002c4:	89 e5                	mov    %esp,%ebp
c01002c6:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c01002c9:	8b 45 08             	mov    0x8(%ebp),%eax
c01002cc:	89 04 24             	mov    %eax,(%esp)
c01002cf:	e8 56 13 00 00       	call   c010162a <cons_putc>
}
c01002d4:	90                   	nop
c01002d5:	c9                   	leave  
c01002d6:	c3                   	ret    

c01002d7 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c01002d7:	55                   	push   %ebp
c01002d8:	89 e5                	mov    %esp,%ebp
c01002da:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c01002dd:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01002e4:	eb 13                	jmp    c01002f9 <cputs+0x22>
        cputch(c, &cnt);
c01002e6:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01002ea:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01002ed:	89 54 24 04          	mov    %edx,0x4(%esp)
c01002f1:	89 04 24             	mov    %eax,(%esp)
c01002f4:	e8 50 ff ff ff       	call   c0100249 <cputch>
 * */
int
cputs(const char *str) {
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
c01002f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01002fc:	8d 50 01             	lea    0x1(%eax),%edx
c01002ff:	89 55 08             	mov    %edx,0x8(%ebp)
c0100302:	0f b6 00             	movzbl (%eax),%eax
c0100305:	88 45 f7             	mov    %al,-0x9(%ebp)
c0100308:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c010030c:	75 d8                	jne    c01002e6 <cputs+0xf>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
c010030e:	8d 45 f0             	lea    -0x10(%ebp),%eax
c0100311:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100315:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c010031c:	e8 28 ff ff ff       	call   c0100249 <cputch>
    return cnt;
c0100321:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c0100324:	c9                   	leave  
c0100325:	c3                   	ret    

c0100326 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c0100326:	55                   	push   %ebp
c0100327:	89 e5                	mov    %esp,%ebp
c0100329:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c010032c:	e8 36 13 00 00       	call   c0101667 <cons_getc>
c0100331:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100334:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100338:	74 f2                	je     c010032c <getchar+0x6>
        /* do nothing */;
    return c;
c010033a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010033d:	c9                   	leave  
c010033e:	c3                   	ret    

c010033f <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c010033f:	55                   	push   %ebp
c0100340:	89 e5                	mov    %esp,%ebp
c0100342:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c0100345:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100349:	74 13                	je     c010035e <readline+0x1f>
        cprintf("%s", prompt);
c010034b:	8b 45 08             	mov    0x8(%ebp),%eax
c010034e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100352:	c7 04 24 27 65 10 c0 	movl   $0xc0106527,(%esp)
c0100359:	e8 3f ff ff ff       	call   c010029d <cprintf>
    }
    int i = 0, c;
c010035e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c0100365:	e8 bc ff ff ff       	call   c0100326 <getchar>
c010036a:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c010036d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100371:	79 07                	jns    c010037a <readline+0x3b>
            return NULL;
c0100373:	b8 00 00 00 00       	mov    $0x0,%eax
c0100378:	eb 78                	jmp    c01003f2 <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c010037a:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c010037e:	7e 28                	jle    c01003a8 <readline+0x69>
c0100380:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c0100387:	7f 1f                	jg     c01003a8 <readline+0x69>
            cputchar(c);
c0100389:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010038c:	89 04 24             	mov    %eax,(%esp)
c010038f:	e8 2f ff ff ff       	call   c01002c3 <cputchar>
            buf[i ++] = c;
c0100394:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100397:	8d 50 01             	lea    0x1(%eax),%edx
c010039a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010039d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01003a0:	88 90 20 b0 11 c0    	mov    %dl,-0x3fee4fe0(%eax)
c01003a6:	eb 45                	jmp    c01003ed <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01003a8:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01003ac:	75 16                	jne    c01003c4 <readline+0x85>
c01003ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003b2:	7e 10                	jle    c01003c4 <readline+0x85>
            cputchar(c);
c01003b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003b7:	89 04 24             	mov    %eax,(%esp)
c01003ba:	e8 04 ff ff ff       	call   c01002c3 <cputchar>
            i --;
c01003bf:	ff 4d f4             	decl   -0xc(%ebp)
c01003c2:	eb 29                	jmp    c01003ed <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01003c4:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01003c8:	74 06                	je     c01003d0 <readline+0x91>
c01003ca:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01003ce:	75 95                	jne    c0100365 <readline+0x26>
            cputchar(c);
c01003d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01003d3:	89 04 24             	mov    %eax,(%esp)
c01003d6:	e8 e8 fe ff ff       	call   c01002c3 <cputchar>
            buf[i] = '\0';
c01003db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01003de:	05 20 b0 11 c0       	add    $0xc011b020,%eax
c01003e3:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01003e6:	b8 20 b0 11 c0       	mov    $0xc011b020,%eax
c01003eb:	eb 05                	jmp    c01003f2 <readline+0xb3>
        }
    }
c01003ed:	e9 73 ff ff ff       	jmp    c0100365 <readline+0x26>
}
c01003f2:	c9                   	leave  
c01003f3:	c3                   	ret    

c01003f4 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c01003f4:	55                   	push   %ebp
c01003f5:	89 e5                	mov    %esp,%ebp
c01003f7:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c01003fa:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
c01003ff:	85 c0                	test   %eax,%eax
c0100401:	75 5b                	jne    c010045e <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100403:	c7 05 20 b4 11 c0 01 	movl   $0x1,0xc011b420
c010040a:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c010040d:	8d 45 14             	lea    0x14(%ebp),%eax
c0100410:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100413:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100416:	89 44 24 08          	mov    %eax,0x8(%esp)
c010041a:	8b 45 08             	mov    0x8(%ebp),%eax
c010041d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100421:	c7 04 24 2a 65 10 c0 	movl   $0xc010652a,(%esp)
c0100428:	e8 70 fe ff ff       	call   c010029d <cprintf>
    vcprintf(fmt, ap);
c010042d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100430:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100434:	8b 45 10             	mov    0x10(%ebp),%eax
c0100437:	89 04 24             	mov    %eax,(%esp)
c010043a:	e8 2b fe ff ff       	call   c010026a <vcprintf>
    cprintf("\n");
c010043f:	c7 04 24 46 65 10 c0 	movl   $0xc0106546,(%esp)
c0100446:	e8 52 fe ff ff       	call   c010029d <cprintf>
    
    cprintf("stack trackback:\n");
c010044b:	c7 04 24 48 65 10 c0 	movl   $0xc0106548,(%esp)
c0100452:	e8 46 fe ff ff       	call   c010029d <cprintf>
    print_stackframe();
c0100457:	e8 32 06 00 00       	call   c0100a8e <print_stackframe>
c010045c:	eb 01                	jmp    c010045f <__panic+0x6b>
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
        goto panic_dead;
c010045e:	90                   	nop
    print_stackframe();
    
    va_end(ap);

panic_dead:
    intr_disable();
c010045f:	e8 37 14 00 00       	call   c010189b <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100464:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c010046b:	e8 61 08 00 00       	call   c0100cd1 <kmonitor>
    }
c0100470:	eb f2                	jmp    c0100464 <__panic+0x70>

c0100472 <__warn>:
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100472:	55                   	push   %ebp
c0100473:	89 e5                	mov    %esp,%ebp
c0100475:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100478:	8d 45 14             	lea    0x14(%ebp),%eax
c010047b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c010047e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100481:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100485:	8b 45 08             	mov    0x8(%ebp),%eax
c0100488:	89 44 24 04          	mov    %eax,0x4(%esp)
c010048c:	c7 04 24 5a 65 10 c0 	movl   $0xc010655a,(%esp)
c0100493:	e8 05 fe ff ff       	call   c010029d <cprintf>
    vcprintf(fmt, ap);
c0100498:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010049b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010049f:	8b 45 10             	mov    0x10(%ebp),%eax
c01004a2:	89 04 24             	mov    %eax,(%esp)
c01004a5:	e8 c0 fd ff ff       	call   c010026a <vcprintf>
    cprintf("\n");
c01004aa:	c7 04 24 46 65 10 c0 	movl   $0xc0106546,(%esp)
c01004b1:	e8 e7 fd ff ff       	call   c010029d <cprintf>
    va_end(ap);
}
c01004b6:	90                   	nop
c01004b7:	c9                   	leave  
c01004b8:	c3                   	ret    

c01004b9 <is_kernel_panic>:

bool
is_kernel_panic(void) {
c01004b9:	55                   	push   %ebp
c01004ba:	89 e5                	mov    %esp,%ebp
    return is_panic;
c01004bc:	a1 20 b4 11 c0       	mov    0xc011b420,%eax
}
c01004c1:	5d                   	pop    %ebp
c01004c2:	c3                   	ret    

c01004c3 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c01004c3:	55                   	push   %ebp
c01004c4:	89 e5                	mov    %esp,%ebp
c01004c6:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c01004c9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004cc:	8b 00                	mov    (%eax),%eax
c01004ce:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004d1:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d4:	8b 00                	mov    (%eax),%eax
c01004d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c01004e0:	e9 ca 00 00 00       	jmp    c01005af <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c01004e5:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01004e8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01004eb:	01 d0                	add    %edx,%eax
c01004ed:	89 c2                	mov    %eax,%edx
c01004ef:	c1 ea 1f             	shr    $0x1f,%edx
c01004f2:	01 d0                	add    %edx,%eax
c01004f4:	d1 f8                	sar    %eax
c01004f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01004f9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004fc:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c01004ff:	eb 03                	jmp    c0100504 <stab_binsearch+0x41>
            m --;
c0100501:	ff 4d f0             	decl   -0x10(%ebp)

    while (l <= r) {
        int true_m = (l + r) / 2, m = true_m;

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c0100504:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100507:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010050a:	7c 1f                	jl     c010052b <stab_binsearch+0x68>
c010050c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010050f:	89 d0                	mov    %edx,%eax
c0100511:	01 c0                	add    %eax,%eax
c0100513:	01 d0                	add    %edx,%eax
c0100515:	c1 e0 02             	shl    $0x2,%eax
c0100518:	89 c2                	mov    %eax,%edx
c010051a:	8b 45 08             	mov    0x8(%ebp),%eax
c010051d:	01 d0                	add    %edx,%eax
c010051f:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100523:	0f b6 c0             	movzbl %al,%eax
c0100526:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100529:	75 d6                	jne    c0100501 <stab_binsearch+0x3e>
            m --;
        }
        if (m < l) {    // no match in [l, m]
c010052b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010052e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100531:	7d 09                	jge    c010053c <stab_binsearch+0x79>
            l = true_m + 1;
c0100533:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100536:	40                   	inc    %eax
c0100537:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c010053a:	eb 73                	jmp    c01005af <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010053c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100543:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100546:	89 d0                	mov    %edx,%eax
c0100548:	01 c0                	add    %eax,%eax
c010054a:	01 d0                	add    %edx,%eax
c010054c:	c1 e0 02             	shl    $0x2,%eax
c010054f:	89 c2                	mov    %eax,%edx
c0100551:	8b 45 08             	mov    0x8(%ebp),%eax
c0100554:	01 d0                	add    %edx,%eax
c0100556:	8b 40 08             	mov    0x8(%eax),%eax
c0100559:	3b 45 18             	cmp    0x18(%ebp),%eax
c010055c:	73 11                	jae    c010056f <stab_binsearch+0xac>
            *region_left = m;
c010055e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100561:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100564:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c0100566:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100569:	40                   	inc    %eax
c010056a:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010056d:	eb 40                	jmp    c01005af <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c010056f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100572:	89 d0                	mov    %edx,%eax
c0100574:	01 c0                	add    %eax,%eax
c0100576:	01 d0                	add    %edx,%eax
c0100578:	c1 e0 02             	shl    $0x2,%eax
c010057b:	89 c2                	mov    %eax,%edx
c010057d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100580:	01 d0                	add    %edx,%eax
c0100582:	8b 40 08             	mov    0x8(%eax),%eax
c0100585:	3b 45 18             	cmp    0x18(%ebp),%eax
c0100588:	76 14                	jbe    c010059e <stab_binsearch+0xdb>
            *region_right = m - 1;
c010058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010058d:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100590:	8b 45 10             	mov    0x10(%ebp),%eax
c0100593:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c0100595:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100598:	48                   	dec    %eax
c0100599:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010059c:	eb 11                	jmp    c01005af <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c010059e:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01005a4:	89 10                	mov    %edx,(%eax)
            l = m;
c01005a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01005ac:	ff 45 18             	incl   0x18(%ebp)
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
    int l = *region_left, r = *region_right, any_matches = 0;

    while (l <= r) {
c01005af:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01005b2:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01005b5:	0f 8e 2a ff ff ff    	jle    c01004e5 <stab_binsearch+0x22>
            l = m;
            addr ++;
        }
    }

    if (!any_matches) {
c01005bb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01005bf:	75 0f                	jne    c01005d0 <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01005c1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005c4:	8b 00                	mov    (%eax),%eax
c01005c6:	8d 50 ff             	lea    -0x1(%eax),%edx
c01005c9:	8b 45 10             	mov    0x10(%ebp),%eax
c01005cc:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c01005ce:	eb 3e                	jmp    c010060e <stab_binsearch+0x14b>
    if (!any_matches) {
        *region_right = *region_left - 1;
    }
    else {
        // find rightmost region containing 'addr'
        l = *region_right;
c01005d0:	8b 45 10             	mov    0x10(%ebp),%eax
c01005d3:	8b 00                	mov    (%eax),%eax
c01005d5:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c01005d8:	eb 03                	jmp    c01005dd <stab_binsearch+0x11a>
c01005da:	ff 4d fc             	decl   -0x4(%ebp)
c01005dd:	8b 45 0c             	mov    0xc(%ebp),%eax
c01005e0:	8b 00                	mov    (%eax),%eax
c01005e2:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c01005e5:	7d 1f                	jge    c0100606 <stab_binsearch+0x143>
c01005e7:	8b 55 fc             	mov    -0x4(%ebp),%edx
c01005ea:	89 d0                	mov    %edx,%eax
c01005ec:	01 c0                	add    %eax,%eax
c01005ee:	01 d0                	add    %edx,%eax
c01005f0:	c1 e0 02             	shl    $0x2,%eax
c01005f3:	89 c2                	mov    %eax,%edx
c01005f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01005f8:	01 d0                	add    %edx,%eax
c01005fa:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01005fe:	0f b6 c0             	movzbl %al,%eax
c0100601:	3b 45 14             	cmp    0x14(%ebp),%eax
c0100604:	75 d4                	jne    c01005da <stab_binsearch+0x117>
            /* do nothing */;
        *region_left = l;
c0100606:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100609:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010060c:	89 10                	mov    %edx,(%eax)
    }
}
c010060e:	90                   	nop
c010060f:	c9                   	leave  
c0100610:	c3                   	ret    

c0100611 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100611:	55                   	push   %ebp
c0100612:	89 e5                	mov    %esp,%ebp
c0100614:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100617:	8b 45 0c             	mov    0xc(%ebp),%eax
c010061a:	c7 00 78 65 10 c0    	movl   $0xc0106578,(%eax)
    info->eip_line = 0;
c0100620:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100623:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010062a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010062d:	c7 40 08 78 65 10 c0 	movl   $0xc0106578,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100634:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100637:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010063e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100641:	8b 55 08             	mov    0x8(%ebp),%edx
c0100644:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100647:	8b 45 0c             	mov    0xc(%ebp),%eax
c010064a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100651:	c7 45 f4 38 78 10 c0 	movl   $0xc0107838,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100658:	c7 45 f0 a0 2d 11 c0 	movl   $0xc0112da0,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010065f:	c7 45 ec a1 2d 11 c0 	movl   $0xc0112da1,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c0100666:	c7 45 e8 d4 58 11 c0 	movl   $0xc01158d4,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c010066d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100670:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0100673:	76 0b                	jbe    c0100680 <debuginfo_eip+0x6f>
c0100675:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100678:	48                   	dec    %eax
c0100679:	0f b6 00             	movzbl (%eax),%eax
c010067c:	84 c0                	test   %al,%al
c010067e:	74 0a                	je     c010068a <debuginfo_eip+0x79>
        return -1;
c0100680:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100685:	e9 b7 02 00 00       	jmp    c0100941 <debuginfo_eip+0x330>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c010068a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c0100691:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100694:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100697:	29 c2                	sub    %eax,%edx
c0100699:	89 d0                	mov    %edx,%eax
c010069b:	c1 f8 02             	sar    $0x2,%eax
c010069e:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01006a4:	48                   	dec    %eax
c01006a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01006a8:	8b 45 08             	mov    0x8(%ebp),%eax
c01006ab:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006af:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01006b6:	00 
c01006b7:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01006ba:	89 44 24 08          	mov    %eax,0x8(%esp)
c01006be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01006c1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006c8:	89 04 24             	mov    %eax,(%esp)
c01006cb:	e8 f3 fd ff ff       	call   c01004c3 <stab_binsearch>
    if (lfile == 0)
c01006d0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006d3:	85 c0                	test   %eax,%eax
c01006d5:	75 0a                	jne    c01006e1 <debuginfo_eip+0xd0>
        return -1;
c01006d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01006dc:	e9 60 02 00 00       	jmp    c0100941 <debuginfo_eip+0x330>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c01006e1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006e4:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01006e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c01006ed:	8b 45 08             	mov    0x8(%ebp),%eax
c01006f0:	89 44 24 10          	mov    %eax,0x10(%esp)
c01006f4:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c01006fb:	00 
c01006fc:	8d 45 d8             	lea    -0x28(%ebp),%eax
c01006ff:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100703:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100706:	89 44 24 04          	mov    %eax,0x4(%esp)
c010070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010070d:	89 04 24             	mov    %eax,(%esp)
c0100710:	e8 ae fd ff ff       	call   c01004c3 <stab_binsearch>

    if (lfun <= rfun) {
c0100715:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100718:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010071b:	39 c2                	cmp    %eax,%edx
c010071d:	7f 7c                	jg     c010079b <debuginfo_eip+0x18a>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010071f:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100722:	89 c2                	mov    %eax,%edx
c0100724:	89 d0                	mov    %edx,%eax
c0100726:	01 c0                	add    %eax,%eax
c0100728:	01 d0                	add    %edx,%eax
c010072a:	c1 e0 02             	shl    $0x2,%eax
c010072d:	89 c2                	mov    %eax,%edx
c010072f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100732:	01 d0                	add    %edx,%eax
c0100734:	8b 00                	mov    (%eax),%eax
c0100736:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c0100739:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010073c:	29 d1                	sub    %edx,%ecx
c010073e:	89 ca                	mov    %ecx,%edx
c0100740:	39 d0                	cmp    %edx,%eax
c0100742:	73 22                	jae    c0100766 <debuginfo_eip+0x155>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c0100744:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100747:	89 c2                	mov    %eax,%edx
c0100749:	89 d0                	mov    %edx,%eax
c010074b:	01 c0                	add    %eax,%eax
c010074d:	01 d0                	add    %edx,%eax
c010074f:	c1 e0 02             	shl    $0x2,%eax
c0100752:	89 c2                	mov    %eax,%edx
c0100754:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100757:	01 d0                	add    %edx,%eax
c0100759:	8b 10                	mov    (%eax),%edx
c010075b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010075e:	01 c2                	add    %eax,%edx
c0100760:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100763:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c0100766:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100769:	89 c2                	mov    %eax,%edx
c010076b:	89 d0                	mov    %edx,%eax
c010076d:	01 c0                	add    %eax,%eax
c010076f:	01 d0                	add    %edx,%eax
c0100771:	c1 e0 02             	shl    $0x2,%eax
c0100774:	89 c2                	mov    %eax,%edx
c0100776:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100779:	01 d0                	add    %edx,%eax
c010077b:	8b 50 08             	mov    0x8(%eax),%edx
c010077e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100781:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c0100784:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100787:	8b 40 10             	mov    0x10(%eax),%eax
c010078a:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c010078d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100790:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c0100793:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100796:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0100799:	eb 15                	jmp    c01007b0 <debuginfo_eip+0x19f>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c010079b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010079e:	8b 55 08             	mov    0x8(%ebp),%edx
c01007a1:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01007a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01007aa:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01007ad:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01007b0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007b3:	8b 40 08             	mov    0x8(%eax),%eax
c01007b6:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01007bd:	00 
c01007be:	89 04 24             	mov    %eax,(%esp)
c01007c1:	e8 31 53 00 00       	call   c0105af7 <strfind>
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007cb:	8b 40 08             	mov    0x8(%eax),%eax
c01007ce:	29 c2                	sub    %eax,%edx
c01007d0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01007d3:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c01007d6:	8b 45 08             	mov    0x8(%ebp),%eax
c01007d9:	89 44 24 10          	mov    %eax,0x10(%esp)
c01007dd:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c01007e4:	00 
c01007e5:	8d 45 d0             	lea    -0x30(%ebp),%eax
c01007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
c01007ec:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c01007ef:	89 44 24 04          	mov    %eax,0x4(%esp)
c01007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f6:	89 04 24             	mov    %eax,(%esp)
c01007f9:	e8 c5 fc ff ff       	call   c01004c3 <stab_binsearch>
    if (lline <= rline) {
c01007fe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100801:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100804:	39 c2                	cmp    %eax,%edx
c0100806:	7f 23                	jg     c010082b <debuginfo_eip+0x21a>
        info->eip_line = stabs[rline].n_desc;
c0100808:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010080b:	89 c2                	mov    %eax,%edx
c010080d:	89 d0                	mov    %edx,%eax
c010080f:	01 c0                	add    %eax,%eax
c0100811:	01 d0                	add    %edx,%eax
c0100813:	c1 e0 02             	shl    $0x2,%eax
c0100816:	89 c2                	mov    %eax,%edx
c0100818:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010081b:	01 d0                	add    %edx,%eax
c010081d:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100821:	89 c2                	mov    %eax,%edx
c0100823:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100826:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100829:	eb 11                	jmp    c010083c <debuginfo_eip+0x22b>
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
    if (lline <= rline) {
        info->eip_line = stabs[rline].n_desc;
    } else {
        return -1;
c010082b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100830:	e9 0c 01 00 00       	jmp    c0100941 <debuginfo_eip+0x330>
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c0100835:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100838:	48                   	dec    %eax
c0100839:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c010083c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010083f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100842:	39 c2                	cmp    %eax,%edx
c0100844:	7c 56                	jl     c010089c <debuginfo_eip+0x28b>
           && stabs[lline].n_type != N_SOL
c0100846:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100849:	89 c2                	mov    %eax,%edx
c010084b:	89 d0                	mov    %edx,%eax
c010084d:	01 c0                	add    %eax,%eax
c010084f:	01 d0                	add    %edx,%eax
c0100851:	c1 e0 02             	shl    $0x2,%eax
c0100854:	89 c2                	mov    %eax,%edx
c0100856:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100859:	01 d0                	add    %edx,%eax
c010085b:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010085f:	3c 84                	cmp    $0x84,%al
c0100861:	74 39                	je     c010089c <debuginfo_eip+0x28b>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c0100863:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100866:	89 c2                	mov    %eax,%edx
c0100868:	89 d0                	mov    %edx,%eax
c010086a:	01 c0                	add    %eax,%eax
c010086c:	01 d0                	add    %edx,%eax
c010086e:	c1 e0 02             	shl    $0x2,%eax
c0100871:	89 c2                	mov    %eax,%edx
c0100873:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100876:	01 d0                	add    %edx,%eax
c0100878:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010087c:	3c 64                	cmp    $0x64,%al
c010087e:	75 b5                	jne    c0100835 <debuginfo_eip+0x224>
c0100880:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100883:	89 c2                	mov    %eax,%edx
c0100885:	89 d0                	mov    %edx,%eax
c0100887:	01 c0                	add    %eax,%eax
c0100889:	01 d0                	add    %edx,%eax
c010088b:	c1 e0 02             	shl    $0x2,%eax
c010088e:	89 c2                	mov    %eax,%edx
c0100890:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100893:	01 d0                	add    %edx,%eax
c0100895:	8b 40 08             	mov    0x8(%eax),%eax
c0100898:	85 c0                	test   %eax,%eax
c010089a:	74 99                	je     c0100835 <debuginfo_eip+0x224>
        lline --;
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c010089c:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010089f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01008a2:	39 c2                	cmp    %eax,%edx
c01008a4:	7c 46                	jl     c01008ec <debuginfo_eip+0x2db>
c01008a6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008a9:	89 c2                	mov    %eax,%edx
c01008ab:	89 d0                	mov    %edx,%eax
c01008ad:	01 c0                	add    %eax,%eax
c01008af:	01 d0                	add    %edx,%eax
c01008b1:	c1 e0 02             	shl    $0x2,%eax
c01008b4:	89 c2                	mov    %eax,%edx
c01008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008b9:	01 d0                	add    %edx,%eax
c01008bb:	8b 00                	mov    (%eax),%eax
c01008bd:	8b 4d e8             	mov    -0x18(%ebp),%ecx
c01008c0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01008c3:	29 d1                	sub    %edx,%ecx
c01008c5:	89 ca                	mov    %ecx,%edx
c01008c7:	39 d0                	cmp    %edx,%eax
c01008c9:	73 21                	jae    c01008ec <debuginfo_eip+0x2db>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01008cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01008ce:	89 c2                	mov    %eax,%edx
c01008d0:	89 d0                	mov    %edx,%eax
c01008d2:	01 c0                	add    %eax,%eax
c01008d4:	01 d0                	add    %edx,%eax
c01008d6:	c1 e0 02             	shl    $0x2,%eax
c01008d9:	89 c2                	mov    %eax,%edx
c01008db:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01008de:	01 d0                	add    %edx,%eax
c01008e0:	8b 10                	mov    (%eax),%edx
c01008e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01008e5:	01 c2                	add    %eax,%edx
c01008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01008ea:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c01008ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01008ef:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01008f2:	39 c2                	cmp    %eax,%edx
c01008f4:	7d 46                	jge    c010093c <debuginfo_eip+0x32b>
        for (lline = lfun + 1;
c01008f6:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01008f9:	40                   	inc    %eax
c01008fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c01008fd:	eb 16                	jmp    c0100915 <debuginfo_eip+0x304>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c01008ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100902:	8b 40 14             	mov    0x14(%eax),%eax
c0100905:	8d 50 01             	lea    0x1(%eax),%edx
c0100908:	8b 45 0c             	mov    0xc(%ebp),%eax
c010090b:	89 50 14             	mov    %edx,0x14(%eax)
    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
c010090e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100911:	40                   	inc    %eax
c0100912:	89 45 d4             	mov    %eax,-0x2c(%ebp)

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100915:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100918:	8b 45 d8             	mov    -0x28(%ebp),%eax
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
        for (lline = lfun + 1;
c010091b:	39 c2                	cmp    %eax,%edx
c010091d:	7d 1d                	jge    c010093c <debuginfo_eip+0x32b>
             lline < rfun && stabs[lline].n_type == N_PSYM;
c010091f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100922:	89 c2                	mov    %eax,%edx
c0100924:	89 d0                	mov    %edx,%eax
c0100926:	01 c0                	add    %eax,%eax
c0100928:	01 d0                	add    %edx,%eax
c010092a:	c1 e0 02             	shl    $0x2,%eax
c010092d:	89 c2                	mov    %eax,%edx
c010092f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100932:	01 d0                	add    %edx,%eax
c0100934:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100938:	3c a0                	cmp    $0xa0,%al
c010093a:	74 c3                	je     c01008ff <debuginfo_eip+0x2ee>
             lline ++) {
            info->eip_fn_narg ++;
        }
    }
    return 0;
c010093c:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100941:	c9                   	leave  
c0100942:	c3                   	ret    

c0100943 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100943:	55                   	push   %ebp
c0100944:	89 e5                	mov    %esp,%ebp
c0100946:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c0100949:	c7 04 24 82 65 10 c0 	movl   $0xc0106582,(%esp)
c0100950:	e8 48 f9 ff ff       	call   c010029d <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c0100955:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c010095c:	c0 
c010095d:	c7 04 24 9b 65 10 c0 	movl   $0xc010659b,(%esp)
c0100964:	e8 34 f9 ff ff       	call   c010029d <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c0100969:	c7 44 24 04 75 64 10 	movl   $0xc0106475,0x4(%esp)
c0100970:	c0 
c0100971:	c7 04 24 b3 65 10 c0 	movl   $0xc01065b3,(%esp)
c0100978:	e8 20 f9 ff ff       	call   c010029d <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c010097d:	c7 44 24 04 00 b0 11 	movl   $0xc011b000,0x4(%esp)
c0100984:	c0 
c0100985:	c7 04 24 cb 65 10 c0 	movl   $0xc01065cb,(%esp)
c010098c:	e8 0c f9 ff ff       	call   c010029d <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c0100991:	c7 44 24 04 a8 bf 11 	movl   $0xc011bfa8,0x4(%esp)
c0100998:	c0 
c0100999:	c7 04 24 e3 65 10 c0 	movl   $0xc01065e3,(%esp)
c01009a0:	e8 f8 f8 ff ff       	call   c010029d <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01009a5:	b8 a8 bf 11 c0       	mov    $0xc011bfa8,%eax
c01009aa:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009b0:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c01009b5:	29 c2                	sub    %eax,%edx
c01009b7:	89 d0                	mov    %edx,%eax
c01009b9:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01009bf:	85 c0                	test   %eax,%eax
c01009c1:	0f 48 c2             	cmovs  %edx,%eax
c01009c4:	c1 f8 0a             	sar    $0xa,%eax
c01009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009cb:	c7 04 24 fc 65 10 c0 	movl   $0xc01065fc,(%esp)
c01009d2:	e8 c6 f8 ff ff       	call   c010029d <cprintf>
}
c01009d7:	90                   	nop
c01009d8:	c9                   	leave  
c01009d9:	c3                   	ret    

c01009da <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c01009da:	55                   	push   %ebp
c01009db:	89 e5                	mov    %esp,%ebp
c01009dd:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c01009e3:	8d 45 dc             	lea    -0x24(%ebp),%eax
c01009e6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009ea:	8b 45 08             	mov    0x8(%ebp),%eax
c01009ed:	89 04 24             	mov    %eax,(%esp)
c01009f0:	e8 1c fc ff ff       	call   c0100611 <debuginfo_eip>
c01009f5:	85 c0                	test   %eax,%eax
c01009f7:	74 15                	je     c0100a0e <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c01009f9:	8b 45 08             	mov    0x8(%ebp),%eax
c01009fc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a00:	c7 04 24 26 66 10 c0 	movl   $0xc0106626,(%esp)
c0100a07:	e8 91 f8 ff ff       	call   c010029d <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a0c:	eb 6c                	jmp    c0100a7a <print_debuginfo+0xa0>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a0e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100a15:	eb 1b                	jmp    c0100a32 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c0100a17:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0100a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a1d:	01 d0                	add    %edx,%eax
c0100a1f:	0f b6 00             	movzbl (%eax),%eax
c0100a22:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a28:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100a2b:	01 ca                	add    %ecx,%edx
c0100a2d:	88 02                	mov    %al,(%edx)
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
    }
    else {
        char fnname[256];
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100a2f:	ff 45 f4             	incl   -0xc(%ebp)
c0100a32:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a35:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0100a38:	7f dd                	jg     c0100a17 <print_debuginfo+0x3d>
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
c0100a3a:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100a40:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a43:	01 d0                	add    %edx,%eax
c0100a45:	c6 00 00             	movb   $0x0,(%eax)
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
c0100a48:	8b 45 ec             	mov    -0x14(%ebp),%eax
        int j;
        for (j = 0; j < info.eip_fn_namelen; j ++) {
            fnname[j] = info.eip_fn_name[j];
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c0100a4b:	8b 55 08             	mov    0x8(%ebp),%edx
c0100a4e:	89 d1                	mov    %edx,%ecx
c0100a50:	29 c1                	sub    %eax,%ecx
c0100a52:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100a55:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100a58:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c0100a5c:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100a62:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a66:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a6e:	c7 04 24 42 66 10 c0 	movl   $0xc0106642,(%esp)
c0100a75:	e8 23 f8 ff ff       	call   c010029d <cprintf>
                fnname, eip - info.eip_fn_addr);
    }
}
c0100a7a:	90                   	nop
c0100a7b:	c9                   	leave  
c0100a7c:	c3                   	ret    

c0100a7d <read_eip>:

static __noinline uint32_t
read_eip(void) {
c0100a7d:	55                   	push   %ebp
c0100a7e:	89 e5                	mov    %esp,%ebp
c0100a80:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c0100a83:	8b 45 04             	mov    0x4(%ebp),%eax
c0100a86:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c0100a89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0100a8c:	c9                   	leave  
c0100a8d:	c3                   	ret    

c0100a8e <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c0100a8e:	55                   	push   %ebp
c0100a8f:	89 e5                	mov    %esp,%ebp
c0100a91:	83 ec 48             	sub    $0x48,%esp
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c0100a94:	89 e8                	mov    %ebp,%eax
c0100a96:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return ebp;
c0100a99:	8b 45 d8             	mov    -0x28(%ebp),%eax
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
c0100a9c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
c0100a9f:	e8 d9 ff ff ff       	call   c0100a7d <read_eip>
c0100aa4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
c0100aa7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0100aae:	e9 9b 00 00 00       	jmp    c0100b4e <print_stackframe+0xc0>
        cprintf("ebp:0x%08x eip:0x%08x ",ebp,eip);
c0100ab3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100ab6:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100abd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac1:	c7 04 24 54 66 10 c0 	movl   $0xc0106654,(%esp)
c0100ac8:	e8 d0 f7 ff ff       	call   c010029d <cprintf>
        arg0 = *((uint32_t *)ebp + 2);
c0100acd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ad0:	83 c0 08             	add    $0x8,%eax
c0100ad3:	8b 00                	mov    (%eax),%eax
c0100ad5:	89 45 e8             	mov    %eax,-0x18(%ebp)
        arg1 = *((uint32_t *)ebp + 3);
c0100ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100adb:	83 c0 0c             	add    $0xc,%eax
c0100ade:	8b 00                	mov    (%eax),%eax
c0100ae0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        arg2 = *((uint32_t *)ebp + 4);
c0100ae3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100ae6:	83 c0 10             	add    $0x10,%eax
c0100ae9:	8b 00                	mov    (%eax),%eax
c0100aeb:	89 45 e0             	mov    %eax,-0x20(%ebp)
        arg3 = *((uint32_t *)ebp + 5);
c0100aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af1:	83 c0 14             	add    $0x14,%eax
c0100af4:	8b 00                	mov    (%eax),%eax
c0100af6:	89 45 dc             	mov    %eax,-0x24(%ebp)
        cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x",arg0,arg1,arg2,arg3);
c0100af9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0100afc:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100b00:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100b03:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100b07:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100b0e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100b11:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b15:	c7 04 24 6c 66 10 c0 	movl   $0xc010666c,(%esp)
c0100b1c:	e8 7c f7 ff ff       	call   c010029d <cprintf>
        cprintf("\n");
c0100b21:	c7 04 24 8d 66 10 c0 	movl   $0xc010668d,(%esp)
c0100b28:	e8 70 f7 ff ff       	call   c010029d <cprintf>
        print_debuginfo(eip);
c0100b2d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100b30:	89 04 24             	mov    %eax,(%esp)
c0100b33:	e8 a2 fe ff ff       	call   c01009da <print_debuginfo>
        eip = *((uint32_t *)ebp + 1);
c0100b38:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b3b:	83 c0 04             	add    $0x4,%eax
c0100b3e:	8b 00                	mov    (%eax),%eax
c0100b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
        ebp = *((uint32_t *)ebp);
c0100b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100b46:	8b 00                	mov    (%eax),%eax
c0100b48:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip = read_eip();
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
c0100b4b:	ff 45 ec             	incl   -0x14(%ebp)
c0100b4e:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100b52:	7f 0a                	jg     c0100b5e <print_stackframe+0xd0>
c0100b54:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100b58:	0f 85 55 ff ff ff    	jne    c0100ab3 <print_stackframe+0x25>
        cprintf("\n");
        print_debuginfo(eip);
        eip = *((uint32_t *)ebp + 1);
        ebp = *((uint32_t *)ebp);
    }
}
c0100b5e:	90                   	nop
c0100b5f:	c9                   	leave  
c0100b60:	c3                   	ret    

c0100b61 <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100b61:	55                   	push   %ebp
c0100b62:	89 e5                	mov    %esp,%ebp
c0100b64:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100b67:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b6e:	eb 0c                	jmp    c0100b7c <parse+0x1b>
            *buf ++ = '\0';
c0100b70:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b73:	8d 50 01             	lea    0x1(%eax),%edx
c0100b76:	89 55 08             	mov    %edx,0x8(%ebp)
c0100b79:	c6 00 00             	movb   $0x0,(%eax)
static int
parse(char *buf, char **argv) {
    int argc = 0;
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b7c:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b7f:	0f b6 00             	movzbl (%eax),%eax
c0100b82:	84 c0                	test   %al,%al
c0100b84:	74 1d                	je     c0100ba3 <parse+0x42>
c0100b86:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b89:	0f b6 00             	movzbl (%eax),%eax
c0100b8c:	0f be c0             	movsbl %al,%eax
c0100b8f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b93:	c7 04 24 10 67 10 c0 	movl   $0xc0106710,(%esp)
c0100b9a:	e8 26 4f 00 00       	call   c0105ac5 <strchr>
c0100b9f:	85 c0                	test   %eax,%eax
c0100ba1:	75 cd                	jne    c0100b70 <parse+0xf>
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
c0100ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ba6:	0f b6 00             	movzbl (%eax),%eax
c0100ba9:	84 c0                	test   %al,%al
c0100bab:	74 69                	je     c0100c16 <parse+0xb5>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100bad:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100bb1:	75 14                	jne    c0100bc7 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100bb3:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100bba:	00 
c0100bbb:	c7 04 24 15 67 10 c0 	movl   $0xc0106715,(%esp)
c0100bc2:	e8 d6 f6 ff ff       	call   c010029d <cprintf>
        }
        argv[argc ++] = buf;
c0100bc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bca:	8d 50 01             	lea    0x1(%eax),%edx
c0100bcd:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100bd0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100bd7:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100bda:	01 c2                	add    %eax,%edx
c0100bdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bdf:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100be1:	eb 03                	jmp    c0100be6 <parse+0x85>
            buf ++;
c0100be3:	ff 45 08             	incl   0x8(%ebp)
        // save and scan past next arg
        if (argc == MAXARGS - 1) {
            cprintf("Too many arguments (max %d).\n", MAXARGS);
        }
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100be6:	8b 45 08             	mov    0x8(%ebp),%eax
c0100be9:	0f b6 00             	movzbl (%eax),%eax
c0100bec:	84 c0                	test   %al,%al
c0100bee:	0f 84 7a ff ff ff    	je     c0100b6e <parse+0xd>
c0100bf4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100bf7:	0f b6 00             	movzbl (%eax),%eax
c0100bfa:	0f be c0             	movsbl %al,%eax
c0100bfd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c01:	c7 04 24 10 67 10 c0 	movl   $0xc0106710,(%esp)
c0100c08:	e8 b8 4e 00 00       	call   c0105ac5 <strchr>
c0100c0d:	85 c0                	test   %eax,%eax
c0100c0f:	74 d2                	je     c0100be3 <parse+0x82>
            buf ++;
        }
    }
c0100c11:	e9 58 ff ff ff       	jmp    c0100b6e <parse+0xd>
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
            *buf ++ = '\0';
        }
        if (*buf == '\0') {
            break;
c0100c16:	90                   	nop
        argv[argc ++] = buf;
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
            buf ++;
        }
    }
    return argc;
c0100c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100c1a:	c9                   	leave  
c0100c1b:	c3                   	ret    

c0100c1c <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100c1c:	55                   	push   %ebp
c0100c1d:	89 e5                	mov    %esp,%ebp
c0100c1f:	53                   	push   %ebx
c0100c20:	83 ec 64             	sub    $0x64,%esp
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100c23:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c2d:	89 04 24             	mov    %eax,(%esp)
c0100c30:	e8 2c ff ff ff       	call   c0100b61 <parse>
c0100c35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100c38:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100c3c:	75 0a                	jne    c0100c48 <runcmd+0x2c>
        return 0;
c0100c3e:	b8 00 00 00 00       	mov    $0x0,%eax
c0100c43:	e9 83 00 00 00       	jmp    c0100ccb <runcmd+0xaf>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c4f:	eb 5a                	jmp    c0100cab <runcmd+0x8f>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100c51:	8b 4d b0             	mov    -0x50(%ebp),%ecx
c0100c54:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c57:	89 d0                	mov    %edx,%eax
c0100c59:	01 c0                	add    %eax,%eax
c0100c5b:	01 d0                	add    %edx,%eax
c0100c5d:	c1 e0 02             	shl    $0x2,%eax
c0100c60:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100c65:	8b 00                	mov    (%eax),%eax
c0100c67:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0100c6b:	89 04 24             	mov    %eax,(%esp)
c0100c6e:	e8 b5 4d 00 00       	call   c0105a28 <strcmp>
c0100c73:	85 c0                	test   %eax,%eax
c0100c75:	75 31                	jne    c0100ca8 <runcmd+0x8c>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100c77:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c7a:	89 d0                	mov    %edx,%eax
c0100c7c:	01 c0                	add    %eax,%eax
c0100c7e:	01 d0                	add    %edx,%eax
c0100c80:	c1 e0 02             	shl    $0x2,%eax
c0100c83:	05 08 80 11 c0       	add    $0xc0118008,%eax
c0100c88:	8b 10                	mov    (%eax),%edx
c0100c8a:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100c8d:	83 c0 04             	add    $0x4,%eax
c0100c90:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100c93:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100c99:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100c9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ca1:	89 1c 24             	mov    %ebx,(%esp)
c0100ca4:	ff d2                	call   *%edx
c0100ca6:	eb 23                	jmp    c0100ccb <runcmd+0xaf>
    int argc = parse(buf, argv);
    if (argc == 0) {
        return 0;
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100ca8:	ff 45 f4             	incl   -0xc(%ebp)
c0100cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cae:	83 f8 02             	cmp    $0x2,%eax
c0100cb1:	76 9e                	jbe    c0100c51 <runcmd+0x35>
        if (strcmp(commands[i].name, argv[0]) == 0) {
            return commands[i].func(argc - 1, argv + 1, tf);
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100cb3:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100cb6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100cba:	c7 04 24 33 67 10 c0 	movl   $0xc0106733,(%esp)
c0100cc1:	e8 d7 f5 ff ff       	call   c010029d <cprintf>
    return 0;
c0100cc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccb:	83 c4 64             	add    $0x64,%esp
c0100cce:	5b                   	pop    %ebx
c0100ccf:	5d                   	pop    %ebp
c0100cd0:	c3                   	ret    

c0100cd1 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100cd1:	55                   	push   %ebp
c0100cd2:	89 e5                	mov    %esp,%ebp
c0100cd4:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100cd7:	c7 04 24 4c 67 10 c0 	movl   $0xc010674c,(%esp)
c0100cde:	e8 ba f5 ff ff       	call   c010029d <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100ce3:	c7 04 24 74 67 10 c0 	movl   $0xc0106774,(%esp)
c0100cea:	e8 ae f5 ff ff       	call   c010029d <cprintf>

    if (tf != NULL) {
c0100cef:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100cf3:	74 0b                	je     c0100d00 <kmonitor+0x2f>
        print_trapframe(tf);
c0100cf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0100cf8:	89 04 24             	mov    %eax,(%esp)
c0100cfb:	e8 9b 0e 00 00       	call   c0101b9b <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100d00:	c7 04 24 99 67 10 c0 	movl   $0xc0106799,(%esp)
c0100d07:	e8 33 f6 ff ff       	call   c010033f <readline>
c0100d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100d13:	74 eb                	je     c0100d00 <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100d15:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d18:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d1f:	89 04 24             	mov    %eax,(%esp)
c0100d22:	e8 f5 fe ff ff       	call   c0100c1c <runcmd>
c0100d27:	85 c0                	test   %eax,%eax
c0100d29:	78 02                	js     c0100d2d <kmonitor+0x5c>
                break;
            }
        }
    }
c0100d2b:	eb d3                	jmp    c0100d00 <kmonitor+0x2f>

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
            if (runcmd(buf, tf) < 0) {
                break;
c0100d2d:	90                   	nop
            }
        }
    }
}
c0100d2e:	90                   	nop
c0100d2f:	c9                   	leave  
c0100d30:	c3                   	ret    

c0100d31 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100d31:	55                   	push   %ebp
c0100d32:	89 e5                	mov    %esp,%ebp
c0100d34:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d37:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100d3e:	eb 3d                	jmp    c0100d7d <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100d40:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d43:	89 d0                	mov    %edx,%eax
c0100d45:	01 c0                	add    %eax,%eax
c0100d47:	01 d0                	add    %edx,%eax
c0100d49:	c1 e0 02             	shl    $0x2,%eax
c0100d4c:	05 04 80 11 c0       	add    $0xc0118004,%eax
c0100d51:	8b 08                	mov    (%eax),%ecx
c0100d53:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100d56:	89 d0                	mov    %edx,%eax
c0100d58:	01 c0                	add    %eax,%eax
c0100d5a:	01 d0                	add    %edx,%eax
c0100d5c:	c1 e0 02             	shl    $0x2,%eax
c0100d5f:	05 00 80 11 c0       	add    $0xc0118000,%eax
c0100d64:	8b 00                	mov    (%eax),%eax
c0100d66:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100d6a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d6e:	c7 04 24 9d 67 10 c0 	movl   $0xc010679d,(%esp)
c0100d75:	e8 23 f5 ff ff       	call   c010029d <cprintf>

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100d7a:	ff 45 f4             	incl   -0xc(%ebp)
c0100d7d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d80:	83 f8 02             	cmp    $0x2,%eax
c0100d83:	76 bb                	jbe    c0100d40 <mon_help+0xf>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    }
    return 0;
c0100d85:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d8a:	c9                   	leave  
c0100d8b:	c3                   	ret    

c0100d8c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100d8c:	55                   	push   %ebp
c0100d8d:	89 e5                	mov    %esp,%ebp
c0100d8f:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100d92:	e8 ac fb ff ff       	call   c0100943 <print_kerninfo>
    return 0;
c0100d97:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100d9c:	c9                   	leave  
c0100d9d:	c3                   	ret    

c0100d9e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100d9e:	55                   	push   %ebp
c0100d9f:	89 e5                	mov    %esp,%ebp
c0100da1:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100da4:	e8 e5 fc ff ff       	call   c0100a8e <print_stackframe>
    return 0;
c0100da9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100dae:	c9                   	leave  
c0100daf:	c3                   	ret    

c0100db0 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100db0:	55                   	push   %ebp
c0100db1:	89 e5                	mov    %esp,%ebp
c0100db3:	83 ec 28             	sub    $0x28,%esp
c0100db6:	66 c7 45 f6 43 00    	movw   $0x43,-0xa(%ebp)
c0100dbc:	c6 45 ef 34          	movb   $0x34,-0x11(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dc0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
c0100dc4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100dc8:	ee                   	out    %al,(%dx)
c0100dc9:	66 c7 45 f4 40 00    	movw   $0x40,-0xc(%ebp)
c0100dcf:	c6 45 f0 9c          	movb   $0x9c,-0x10(%ebp)
c0100dd3:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c0100dd7:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100dda:	ee                   	out    %al,(%dx)
c0100ddb:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100de1:	c6 45 f1 2e          	movb   $0x2e,-0xf(%ebp)
c0100de5:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100de9:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100ded:	ee                   	out    %al,(%dx)
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dee:	c7 05 2c bf 11 c0 00 	movl   $0x0,0xc011bf2c
c0100df5:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100df8:	c7 04 24 a6 67 10 c0 	movl   $0xc01067a6,(%esp)
c0100dff:	e8 99 f4 ff ff       	call   c010029d <cprintf>
    pic_enable(IRQ_TIMER);
c0100e04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e0b:	e8 1e 09 00 00       	call   c010172e <pic_enable>
}
c0100e10:	90                   	nop
c0100e11:	c9                   	leave  
c0100e12:	c3                   	ret    

c0100e13 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e13:	55                   	push   %ebp
c0100e14:	89 e5                	mov    %esp,%ebp
c0100e16:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e19:	9c                   	pushf  
c0100e1a:	58                   	pop    %eax
c0100e1b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e21:	25 00 02 00 00       	and    $0x200,%eax
c0100e26:	85 c0                	test   %eax,%eax
c0100e28:	74 0c                	je     c0100e36 <__intr_save+0x23>
        intr_disable();
c0100e2a:	e8 6c 0a 00 00       	call   c010189b <intr_disable>
        return 1;
c0100e2f:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e34:	eb 05                	jmp    c0100e3b <__intr_save+0x28>
    }
    return 0;
c0100e36:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e3b:	c9                   	leave  
c0100e3c:	c3                   	ret    

c0100e3d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e3d:	55                   	push   %ebp
c0100e3e:	89 e5                	mov    %esp,%ebp
c0100e40:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e43:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e47:	74 05                	je     c0100e4e <__intr_restore+0x11>
        intr_enable();
c0100e49:	e8 46 0a 00 00       	call   c0101894 <intr_enable>
    }
}
c0100e4e:	90                   	nop
c0100e4f:	c9                   	leave  
c0100e50:	c3                   	ret    

c0100e51 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e51:	55                   	push   %ebp
c0100e52:	89 e5                	mov    %esp,%ebp
c0100e54:	83 ec 10             	sub    $0x10,%esp
c0100e57:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e5d:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100e61:	89 c2                	mov    %eax,%edx
c0100e63:	ec                   	in     (%dx),%al
c0100e64:	88 45 f4             	mov    %al,-0xc(%ebp)
c0100e67:	66 c7 45 fc 84 00    	movw   $0x84,-0x4(%ebp)
c0100e6d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100e70:	89 c2                	mov    %eax,%edx
c0100e72:	ec                   	in     (%dx),%al
c0100e73:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e76:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e7c:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e80:	89 c2                	mov    %eax,%edx
c0100e82:	ec                   	in     (%dx),%al
c0100e83:	88 45 f6             	mov    %al,-0xa(%ebp)
c0100e86:	66 c7 45 f8 84 00    	movw   $0x84,-0x8(%ebp)
c0100e8c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100e8f:	89 c2                	mov    %eax,%edx
c0100e91:	ec                   	in     (%dx),%al
c0100e92:	88 45 f7             	mov    %al,-0x9(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100e95:	90                   	nop
c0100e96:	c9                   	leave  
c0100e97:	c3                   	ret    

c0100e98 <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100e98:	55                   	push   %ebp
c0100e99:	89 e5                	mov    %esp,%ebp
c0100e9b:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100e9e:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ea5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ea8:	0f b7 00             	movzwl (%eax),%eax
c0100eab:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100eaf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eb2:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100eb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100eba:	0f b7 00             	movzwl (%eax),%eax
c0100ebd:	0f b7 c0             	movzwl %ax,%eax
c0100ec0:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100ec5:	74 12                	je     c0100ed9 <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100ec7:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ece:	66 c7 05 46 b4 11 c0 	movw   $0x3b4,0xc011b446
c0100ed5:	b4 03 
c0100ed7:	eb 13                	jmp    c0100eec <cga_init+0x54>
    } else {
        *cp = was;
c0100ed9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100edc:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ee0:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ee3:	66 c7 05 46 b4 11 c0 	movw   $0x3d4,0xc011b446
c0100eea:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100eec:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100ef3:	66 89 45 f8          	mov    %ax,-0x8(%ebp)
c0100ef7:	c6 45 ea 0e          	movb   $0xe,-0x16(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100efb:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c0100eff:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0100f02:	ee                   	out    %al,(%dx)
    pos = inb(addr_6845 + 1) << 8;
c0100f03:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f0a:	40                   	inc    %eax
c0100f0b:	0f b7 c0             	movzwl %ax,%eax
c0100f0e:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f12:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f16:	89 c2                	mov    %eax,%edx
c0100f18:	ec                   	in     (%dx),%al
c0100f19:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c0100f1c:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c0100f20:	0f b6 c0             	movzbl %al,%eax
c0100f23:	c1 e0 08             	shl    $0x8,%eax
c0100f26:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f29:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f30:	66 89 45 f0          	mov    %ax,-0x10(%ebp)
c0100f34:	c6 45 ec 0f          	movb   $0xf,-0x14(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f38:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
c0100f3c:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100f3f:	ee                   	out    %al,(%dx)
    pos |= inb(addr_6845 + 1);
c0100f40:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0100f47:	40                   	inc    %eax
c0100f48:	0f b7 c0             	movzwl %ax,%eax
c0100f4b:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f4f:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0100f53:	89 c2                	mov    %eax,%edx
c0100f55:	ec                   	in     (%dx),%al
c0100f56:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0100f59:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f5d:	0f b6 c0             	movzbl %al,%eax
c0100f60:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f63:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f66:	a3 40 b4 11 c0       	mov    %eax,0xc011b440
    crt_pos = pos;
c0100f6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f6e:	0f b7 c0             	movzwl %ax,%eax
c0100f71:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
}
c0100f77:	90                   	nop
c0100f78:	c9                   	leave  
c0100f79:	c3                   	ret    

c0100f7a <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f7a:	55                   	push   %ebp
c0100f7b:	89 e5                	mov    %esp,%ebp
c0100f7d:	83 ec 38             	sub    $0x38,%esp
c0100f80:	66 c7 45 f6 fa 03    	movw   $0x3fa,-0xa(%ebp)
c0100f86:	c6 45 da 00          	movb   $0x0,-0x26(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f8a:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c0100f8e:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100f92:	ee                   	out    %al,(%dx)
c0100f93:	66 c7 45 f4 fb 03    	movw   $0x3fb,-0xc(%ebp)
c0100f99:	c6 45 db 80          	movb   $0x80,-0x25(%ebp)
c0100f9d:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c0100fa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100fa4:	ee                   	out    %al,(%dx)
c0100fa5:	66 c7 45 f2 f8 03    	movw   $0x3f8,-0xe(%ebp)
c0100fab:	c6 45 dc 0c          	movb   $0xc,-0x24(%ebp)
c0100faf:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c0100fb3:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100fb7:	ee                   	out    %al,(%dx)
c0100fb8:	66 c7 45 f0 f9 03    	movw   $0x3f9,-0x10(%ebp)
c0100fbe:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
c0100fc2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fc6:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100fc9:	ee                   	out    %al,(%dx)
c0100fca:	66 c7 45 ee fb 03    	movw   $0x3fb,-0x12(%ebp)
c0100fd0:	c6 45 de 03          	movb   $0x3,-0x22(%ebp)
c0100fd4:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0100fd8:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100fdc:	ee                   	out    %al,(%dx)
c0100fdd:	66 c7 45 ec fc 03    	movw   $0x3fc,-0x14(%ebp)
c0100fe3:	c6 45 df 00          	movb   $0x0,-0x21(%ebp)
c0100fe7:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0100feb:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0100fee:	ee                   	out    %al,(%dx)
c0100fef:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c0100ff5:	c6 45 e0 01          	movb   $0x1,-0x20(%ebp)
c0100ff9:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0100ffd:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101001:	ee                   	out    %al,(%dx)
c0101002:	66 c7 45 e8 fd 03    	movw   $0x3fd,-0x18(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101008:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010100b:	89 c2                	mov    %eax,%edx
c010100d:	ec                   	in     (%dx),%al
c010100e:	88 45 e1             	mov    %al,-0x1f(%ebp)
    return data;
c0101011:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c0101015:	3c ff                	cmp    $0xff,%al
c0101017:	0f 95 c0             	setne  %al
c010101a:	0f b6 c0             	movzbl %al,%eax
c010101d:	a3 48 b4 11 c0       	mov    %eax,0xc011b448
c0101022:	66 c7 45 e6 fa 03    	movw   $0x3fa,-0x1a(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101028:	0f b7 45 e6          	movzwl -0x1a(%ebp),%eax
c010102c:	89 c2                	mov    %eax,%edx
c010102e:	ec                   	in     (%dx),%al
c010102f:	88 45 e2             	mov    %al,-0x1e(%ebp)
c0101032:	66 c7 45 e4 f8 03    	movw   $0x3f8,-0x1c(%ebp)
c0101038:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010103b:	89 c2                	mov    %eax,%edx
c010103d:	ec                   	in     (%dx),%al
c010103e:	88 45 e3             	mov    %al,-0x1d(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101041:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101046:	85 c0                	test   %eax,%eax
c0101048:	74 0c                	je     c0101056 <serial_init+0xdc>
        pic_enable(IRQ_COM1);
c010104a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101051:	e8 d8 06 00 00       	call   c010172e <pic_enable>
    }
}
c0101056:	90                   	nop
c0101057:	c9                   	leave  
c0101058:	c3                   	ret    

c0101059 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101059:	55                   	push   %ebp
c010105a:	89 e5                	mov    %esp,%ebp
c010105c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010105f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101066:	eb 08                	jmp    c0101070 <lpt_putc_sub+0x17>
        delay();
c0101068:	e8 e4 fd ff ff       	call   c0100e51 <delay>
}

static void
lpt_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c010106d:	ff 45 fc             	incl   -0x4(%ebp)
c0101070:	66 c7 45 f4 79 03    	movw   $0x379,-0xc(%ebp)
c0101076:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101079:	89 c2                	mov    %eax,%edx
c010107b:	ec                   	in     (%dx),%al
c010107c:	88 45 f3             	mov    %al,-0xd(%ebp)
    return data;
c010107f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101083:	84 c0                	test   %al,%al
c0101085:	78 09                	js     c0101090 <lpt_putc_sub+0x37>
c0101087:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010108e:	7e d8                	jle    c0101068 <lpt_putc_sub+0xf>
        delay();
    }
    outb(LPTPORT + 0, c);
c0101090:	8b 45 08             	mov    0x8(%ebp),%eax
c0101093:	0f b6 c0             	movzbl %al,%eax
c0101096:	66 c7 45 f8 78 03    	movw   $0x378,-0x8(%ebp)
c010109c:	88 45 f0             	mov    %al,-0x10(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010109f:	0f b6 45 f0          	movzbl -0x10(%ebp),%eax
c01010a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01010a6:	ee                   	out    %al,(%dx)
c01010a7:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010ad:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
c01010b1:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010b5:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010b9:	ee                   	out    %al,(%dx)
c01010ba:	66 c7 45 fa 7a 03    	movw   $0x37a,-0x6(%ebp)
c01010c0:	c6 45 f2 08          	movb   $0x8,-0xe(%ebp)
c01010c4:	0f b6 45 f2          	movzbl -0xe(%ebp),%eax
c01010c8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01010cc:	ee                   	out    %al,(%dx)
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010cd:	90                   	nop
c01010ce:	c9                   	leave  
c01010cf:	c3                   	ret    

c01010d0 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c01010d0:	55                   	push   %ebp
c01010d1:	89 e5                	mov    %esp,%ebp
c01010d3:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c01010d6:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c01010da:	74 0d                	je     c01010e9 <lpt_putc+0x19>
        lpt_putc_sub(c);
c01010dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01010df:	89 04 24             	mov    %eax,(%esp)
c01010e2:	e8 72 ff ff ff       	call   c0101059 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c01010e7:	eb 24                	jmp    c010110d <lpt_putc+0x3d>
lpt_putc(int c) {
    if (c != '\b') {
        lpt_putc_sub(c);
    }
    else {
        lpt_putc_sub('\b');
c01010e9:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01010f0:	e8 64 ff ff ff       	call   c0101059 <lpt_putc_sub>
        lpt_putc_sub(' ');
c01010f5:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01010fc:	e8 58 ff ff ff       	call   c0101059 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101101:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101108:	e8 4c ff ff ff       	call   c0101059 <lpt_putc_sub>
    }
}
c010110d:	90                   	nop
c010110e:	c9                   	leave  
c010110f:	c3                   	ret    

c0101110 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101110:	55                   	push   %ebp
c0101111:	89 e5                	mov    %esp,%ebp
c0101113:	53                   	push   %ebx
c0101114:	83 ec 24             	sub    $0x24,%esp
    // set black on white
    if (!(c & ~0xFF)) {
c0101117:	8b 45 08             	mov    0x8(%ebp),%eax
c010111a:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010111f:	85 c0                	test   %eax,%eax
c0101121:	75 07                	jne    c010112a <cga_putc+0x1a>
        c |= 0x0700;
c0101123:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010112a:	8b 45 08             	mov    0x8(%ebp),%eax
c010112d:	0f b6 c0             	movzbl %al,%eax
c0101130:	83 f8 0a             	cmp    $0xa,%eax
c0101133:	74 54                	je     c0101189 <cga_putc+0x79>
c0101135:	83 f8 0d             	cmp    $0xd,%eax
c0101138:	74 62                	je     c010119c <cga_putc+0x8c>
c010113a:	83 f8 08             	cmp    $0x8,%eax
c010113d:	0f 85 93 00 00 00    	jne    c01011d6 <cga_putc+0xc6>
    case '\b':
        if (crt_pos > 0) {
c0101143:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010114a:	85 c0                	test   %eax,%eax
c010114c:	0f 84 ae 00 00 00    	je     c0101200 <cga_putc+0xf0>
            crt_pos --;
c0101152:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101159:	48                   	dec    %eax
c010115a:	0f b7 c0             	movzwl %ax,%eax
c010115d:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c0101163:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101168:	0f b7 15 44 b4 11 c0 	movzwl 0xc011b444,%edx
c010116f:	01 d2                	add    %edx,%edx
c0101171:	01 c2                	add    %eax,%edx
c0101173:	8b 45 08             	mov    0x8(%ebp),%eax
c0101176:	98                   	cwtl   
c0101177:	25 00 ff ff ff       	and    $0xffffff00,%eax
c010117c:	98                   	cwtl   
c010117d:	83 c8 20             	or     $0x20,%eax
c0101180:	98                   	cwtl   
c0101181:	0f b7 c0             	movzwl %ax,%eax
c0101184:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c0101187:	eb 77                	jmp    c0101200 <cga_putc+0xf0>
    case '\n':
        crt_pos += CRT_COLS;
c0101189:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101190:	83 c0 50             	add    $0x50,%eax
c0101193:	0f b7 c0             	movzwl %ax,%eax
c0101196:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c010119c:	0f b7 1d 44 b4 11 c0 	movzwl 0xc011b444,%ebx
c01011a3:	0f b7 0d 44 b4 11 c0 	movzwl 0xc011b444,%ecx
c01011aa:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011af:	89 c8                	mov    %ecx,%eax
c01011b1:	f7 e2                	mul    %edx
c01011b3:	c1 ea 06             	shr    $0x6,%edx
c01011b6:	89 d0                	mov    %edx,%eax
c01011b8:	c1 e0 02             	shl    $0x2,%eax
c01011bb:	01 d0                	add    %edx,%eax
c01011bd:	c1 e0 04             	shl    $0x4,%eax
c01011c0:	29 c1                	sub    %eax,%ecx
c01011c2:	89 c8                	mov    %ecx,%eax
c01011c4:	0f b7 c0             	movzwl %ax,%eax
c01011c7:	29 c3                	sub    %eax,%ebx
c01011c9:	89 d8                	mov    %ebx,%eax
c01011cb:	0f b7 c0             	movzwl %ax,%eax
c01011ce:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
        break;
c01011d4:	eb 2b                	jmp    c0101201 <cga_putc+0xf1>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c01011d6:	8b 0d 40 b4 11 c0    	mov    0xc011b440,%ecx
c01011dc:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01011e3:	8d 50 01             	lea    0x1(%eax),%edx
c01011e6:	0f b7 d2             	movzwl %dx,%edx
c01011e9:	66 89 15 44 b4 11 c0 	mov    %dx,0xc011b444
c01011f0:	01 c0                	add    %eax,%eax
c01011f2:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c01011f5:	8b 45 08             	mov    0x8(%ebp),%eax
c01011f8:	0f b7 c0             	movzwl %ax,%eax
c01011fb:	66 89 02             	mov    %ax,(%edx)
        break;
c01011fe:	eb 01                	jmp    c0101201 <cga_putc+0xf1>
    case '\b':
        if (crt_pos > 0) {
            crt_pos --;
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
        }
        break;
c0101200:	90                   	nop
        crt_buf[crt_pos ++] = c;     // write the character
        break;
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101201:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101208:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c010120d:	76 5d                	jbe    c010126c <cga_putc+0x15c>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010120f:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101214:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010121a:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c010121f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101226:	00 
c0101227:	89 54 24 04          	mov    %edx,0x4(%esp)
c010122b:	89 04 24             	mov    %eax,(%esp)
c010122e:	e8 88 4a 00 00       	call   c0105cbb <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101233:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010123a:	eb 14                	jmp    c0101250 <cga_putc+0x140>
            crt_buf[i] = 0x0700 | ' ';
c010123c:	a1 40 b4 11 c0       	mov    0xc011b440,%eax
c0101241:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0101244:	01 d2                	add    %edx,%edx
c0101246:	01 d0                	add    %edx,%eax
c0101248:	66 c7 00 20 07       	movw   $0x720,(%eax)

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010124d:	ff 45 f4             	incl   -0xc(%ebp)
c0101250:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101257:	7e e3                	jle    c010123c <cga_putc+0x12c>
            crt_buf[i] = 0x0700 | ' ';
        }
        crt_pos -= CRT_COLS;
c0101259:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c0101260:	83 e8 50             	sub    $0x50,%eax
c0101263:	0f b7 c0             	movzwl %ax,%eax
c0101266:	66 a3 44 b4 11 c0    	mov    %ax,0xc011b444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c010126c:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c0101273:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
c0101277:	c6 45 e8 0e          	movb   $0xe,-0x18(%ebp)
c010127b:	0f b6 45 e8          	movzbl -0x18(%ebp),%eax
c010127f:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0101283:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos >> 8);
c0101284:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c010128b:	c1 e8 08             	shr    $0x8,%eax
c010128e:	0f b7 c0             	movzwl %ax,%eax
c0101291:	0f b6 c0             	movzbl %al,%eax
c0101294:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c010129b:	42                   	inc    %edx
c010129c:	0f b7 d2             	movzwl %dx,%edx
c010129f:	66 89 55 f0          	mov    %dx,-0x10(%ebp)
c01012a3:	88 45 e9             	mov    %al,-0x17(%ebp)
c01012a6:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012aa:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01012ad:	ee                   	out    %al,(%dx)
    outb(addr_6845, 15);
c01012ae:	0f b7 05 46 b4 11 c0 	movzwl 0xc011b446,%eax
c01012b5:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012b9:	c6 45 ea 0f          	movb   $0xf,-0x16(%ebp)
c01012bd:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
c01012c1:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01012c5:	ee                   	out    %al,(%dx)
    outb(addr_6845 + 1, crt_pos);
c01012c6:	0f b7 05 44 b4 11 c0 	movzwl 0xc011b444,%eax
c01012cd:	0f b6 c0             	movzbl %al,%eax
c01012d0:	0f b7 15 46 b4 11 c0 	movzwl 0xc011b446,%edx
c01012d7:	42                   	inc    %edx
c01012d8:	0f b7 d2             	movzwl %dx,%edx
c01012db:	66 89 55 ec          	mov    %dx,-0x14(%ebp)
c01012df:	88 45 eb             	mov    %al,-0x15(%ebp)
c01012e2:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
c01012e6:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01012e9:	ee                   	out    %al,(%dx)
}
c01012ea:	90                   	nop
c01012eb:	83 c4 24             	add    $0x24,%esp
c01012ee:	5b                   	pop    %ebx
c01012ef:	5d                   	pop    %ebp
c01012f0:	c3                   	ret    

c01012f1 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c01012f1:	55                   	push   %ebp
c01012f2:	89 e5                	mov    %esp,%ebp
c01012f4:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c01012f7:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01012fe:	eb 08                	jmp    c0101308 <serial_putc_sub+0x17>
        delay();
c0101300:	e8 4c fb ff ff       	call   c0100e51 <delay>
}

static void
serial_putc_sub(int c) {
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c0101305:	ff 45 fc             	incl   -0x4(%ebp)
c0101308:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010130e:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101311:	89 c2                	mov    %eax,%edx
c0101313:	ec                   	in     (%dx),%al
c0101314:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c0101317:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010131b:	0f b6 c0             	movzbl %al,%eax
c010131e:	83 e0 20             	and    $0x20,%eax
c0101321:	85 c0                	test   %eax,%eax
c0101323:	75 09                	jne    c010132e <serial_putc_sub+0x3d>
c0101325:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c010132c:	7e d2                	jle    c0101300 <serial_putc_sub+0xf>
        delay();
    }
    outb(COM1 + COM_TX, c);
c010132e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101331:	0f b6 c0             	movzbl %al,%eax
c0101334:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
c010133a:	88 45 f6             	mov    %al,-0xa(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010133d:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
c0101341:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0101345:	ee                   	out    %al,(%dx)
}
c0101346:	90                   	nop
c0101347:	c9                   	leave  
c0101348:	c3                   	ret    

c0101349 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101349:	55                   	push   %ebp
c010134a:	89 e5                	mov    %esp,%ebp
c010134c:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010134f:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c0101353:	74 0d                	je     c0101362 <serial_putc+0x19>
        serial_putc_sub(c);
c0101355:	8b 45 08             	mov    0x8(%ebp),%eax
c0101358:	89 04 24             	mov    %eax,(%esp)
c010135b:	e8 91 ff ff ff       	call   c01012f1 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c0101360:	eb 24                	jmp    c0101386 <serial_putc+0x3d>
serial_putc(int c) {
    if (c != '\b') {
        serial_putc_sub(c);
    }
    else {
        serial_putc_sub('\b');
c0101362:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101369:	e8 83 ff ff ff       	call   c01012f1 <serial_putc_sub>
        serial_putc_sub(' ');
c010136e:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0101375:	e8 77 ff ff ff       	call   c01012f1 <serial_putc_sub>
        serial_putc_sub('\b');
c010137a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101381:	e8 6b ff ff ff       	call   c01012f1 <serial_putc_sub>
    }
}
c0101386:	90                   	nop
c0101387:	c9                   	leave  
c0101388:	c3                   	ret    

c0101389 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c0101389:	55                   	push   %ebp
c010138a:	89 e5                	mov    %esp,%ebp
c010138c:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c010138f:	eb 33                	jmp    c01013c4 <cons_intr+0x3b>
        if (c != 0) {
c0101391:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0101395:	74 2d                	je     c01013c4 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c0101397:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c010139c:	8d 50 01             	lea    0x1(%eax),%edx
c010139f:	89 15 64 b6 11 c0    	mov    %edx,0xc011b664
c01013a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013a8:	88 90 60 b4 11 c0    	mov    %dl,-0x3fee4ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013ae:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c01013b3:	3d 00 02 00 00       	cmp    $0x200,%eax
c01013b8:	75 0a                	jne    c01013c4 <cons_intr+0x3b>
                cons.wpos = 0;
c01013ba:	c7 05 64 b6 11 c0 00 	movl   $0x0,0xc011b664
c01013c1:	00 00 00 
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
    int c;
    while ((c = (*proc)()) != -1) {
c01013c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01013c7:	ff d0                	call   *%eax
c01013c9:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01013cc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c01013d0:	75 bf                	jne    c0101391 <cons_intr+0x8>
            if (cons.wpos == CONSBUFSIZE) {
                cons.wpos = 0;
            }
        }
    }
}
c01013d2:	90                   	nop
c01013d3:	c9                   	leave  
c01013d4:	c3                   	ret    

c01013d5 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c01013d5:	55                   	push   %ebp
c01013d6:	89 e5                	mov    %esp,%ebp
c01013d8:	83 ec 10             	sub    $0x10,%esp
c01013db:	66 c7 45 f8 fd 03    	movw   $0x3fd,-0x8(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01013e1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01013e4:	89 c2                	mov    %eax,%edx
c01013e6:	ec                   	in     (%dx),%al
c01013e7:	88 45 f7             	mov    %al,-0x9(%ebp)
    return data;
c01013ea:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c01013ee:	0f b6 c0             	movzbl %al,%eax
c01013f1:	83 e0 01             	and    $0x1,%eax
c01013f4:	85 c0                	test   %eax,%eax
c01013f6:	75 07                	jne    c01013ff <serial_proc_data+0x2a>
        return -1;
c01013f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01013fd:	eb 2a                	jmp    c0101429 <serial_proc_data+0x54>
c01013ff:	66 c7 45 fa f8 03    	movw   $0x3f8,-0x6(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101405:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101409:	89 c2                	mov    %eax,%edx
c010140b:	ec                   	in     (%dx),%al
c010140c:	88 45 f6             	mov    %al,-0xa(%ebp)
    return data;
c010140f:	0f b6 45 f6          	movzbl -0xa(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101413:	0f b6 c0             	movzbl %al,%eax
c0101416:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c0101419:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010141d:	75 07                	jne    c0101426 <serial_proc_data+0x51>
        c = '\b';
c010141f:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101426:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0101429:	c9                   	leave  
c010142a:	c3                   	ret    

c010142b <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010142b:	55                   	push   %ebp
c010142c:	89 e5                	mov    %esp,%ebp
c010142e:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101431:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101436:	85 c0                	test   %eax,%eax
c0101438:	74 0c                	je     c0101446 <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010143a:	c7 04 24 d5 13 10 c0 	movl   $0xc01013d5,(%esp)
c0101441:	e8 43 ff ff ff       	call   c0101389 <cons_intr>
    }
}
c0101446:	90                   	nop
c0101447:	c9                   	leave  
c0101448:	c3                   	ret    

c0101449 <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c0101449:	55                   	push   %ebp
c010144a:	89 e5                	mov    %esp,%ebp
c010144c:	83 ec 28             	sub    $0x28,%esp
c010144f:	66 c7 45 ec 64 00    	movw   $0x64,-0x14(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101455:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101458:	89 c2                	mov    %eax,%edx
c010145a:	ec                   	in     (%dx),%al
c010145b:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c010145e:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c0101462:	0f b6 c0             	movzbl %al,%eax
c0101465:	83 e0 01             	and    $0x1,%eax
c0101468:	85 c0                	test   %eax,%eax
c010146a:	75 0a                	jne    c0101476 <kbd_proc_data+0x2d>
        return -1;
c010146c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0101471:	e9 56 01 00 00       	jmp    c01015cc <kbd_proc_data+0x183>
c0101476:	66 c7 45 f0 60 00    	movw   $0x60,-0x10(%ebp)
static inline void invlpg(void *addr) __attribute__((always_inline));

static inline uint8_t
inb(uint16_t port) {
    uint8_t data;
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010147c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010147f:	89 c2                	mov    %eax,%edx
c0101481:	ec                   	in     (%dx),%al
c0101482:	88 45 ea             	mov    %al,-0x16(%ebp)
    return data;
c0101485:	0f b6 45 ea          	movzbl -0x16(%ebp),%eax
    }

    data = inb(KBDATAP);
c0101489:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c010148c:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c0101490:	75 17                	jne    c01014a9 <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c0101492:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101497:	83 c8 40             	or     $0x40,%eax
c010149a:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c010149f:	b8 00 00 00 00       	mov    $0x0,%eax
c01014a4:	e9 23 01 00 00       	jmp    c01015cc <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c01014a9:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014ad:	84 c0                	test   %al,%al
c01014af:	79 45                	jns    c01014f6 <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c01014b1:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014b6:	83 e0 40             	and    $0x40,%eax
c01014b9:	85 c0                	test   %eax,%eax
c01014bb:	75 08                	jne    c01014c5 <kbd_proc_data+0x7c>
c01014bd:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c1:	24 7f                	and    $0x7f,%al
c01014c3:	eb 04                	jmp    c01014c9 <kbd_proc_data+0x80>
c01014c5:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014c9:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c01014cc:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01014d0:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c01014d7:	0c 40                	or     $0x40,%al
c01014d9:	0f b6 c0             	movzbl %al,%eax
c01014dc:	f7 d0                	not    %eax
c01014de:	89 c2                	mov    %eax,%edx
c01014e0:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014e5:	21 d0                	and    %edx,%eax
c01014e7:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
        return 0;
c01014ec:	b8 00 00 00 00       	mov    $0x0,%eax
c01014f1:	e9 d6 00 00 00       	jmp    c01015cc <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c01014f6:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c01014fb:	83 e0 40             	and    $0x40,%eax
c01014fe:	85 c0                	test   %eax,%eax
c0101500:	74 11                	je     c0101513 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101502:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c0101506:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010150b:	83 e0 bf             	and    $0xffffffbf,%eax
c010150e:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    }

    shift |= shiftcode[data];
c0101513:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101517:	0f b6 80 40 80 11 c0 	movzbl -0x3fee7fc0(%eax),%eax
c010151e:	0f b6 d0             	movzbl %al,%edx
c0101521:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101526:	09 d0                	or     %edx,%eax
c0101528:	a3 68 b6 11 c0       	mov    %eax,0xc011b668
    shift ^= togglecode[data];
c010152d:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101531:	0f b6 80 40 81 11 c0 	movzbl -0x3fee7ec0(%eax),%eax
c0101538:	0f b6 d0             	movzbl %al,%edx
c010153b:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101540:	31 d0                	xor    %edx,%eax
c0101542:	a3 68 b6 11 c0       	mov    %eax,0xc011b668

    c = charcode[shift & (CTL | SHIFT)][data];
c0101547:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010154c:	83 e0 03             	and    $0x3,%eax
c010154f:	8b 14 85 40 85 11 c0 	mov    -0x3fee7ac0(,%eax,4),%edx
c0101556:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010155a:	01 d0                	add    %edx,%eax
c010155c:	0f b6 00             	movzbl (%eax),%eax
c010155f:	0f b6 c0             	movzbl %al,%eax
c0101562:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c0101565:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c010156a:	83 e0 08             	and    $0x8,%eax
c010156d:	85 c0                	test   %eax,%eax
c010156f:	74 22                	je     c0101593 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c0101571:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c0101575:	7e 0c                	jle    c0101583 <kbd_proc_data+0x13a>
c0101577:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c010157b:	7f 06                	jg     c0101583 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c010157d:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c0101581:	eb 10                	jmp    c0101593 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c0101583:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c0101587:	7e 0a                	jle    c0101593 <kbd_proc_data+0x14a>
c0101589:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c010158d:	7f 04                	jg     c0101593 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c010158f:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c0101593:	a1 68 b6 11 c0       	mov    0xc011b668,%eax
c0101598:	f7 d0                	not    %eax
c010159a:	83 e0 06             	and    $0x6,%eax
c010159d:	85 c0                	test   %eax,%eax
c010159f:	75 28                	jne    c01015c9 <kbd_proc_data+0x180>
c01015a1:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015a8:	75 1f                	jne    c01015c9 <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c01015aa:	c7 04 24 c1 67 10 c0 	movl   $0xc01067c1,(%esp)
c01015b1:	e8 e7 ec ff ff       	call   c010029d <cprintf>
c01015b6:	66 c7 45 ee 92 00    	movw   $0x92,-0x12(%ebp)
c01015bc:	c6 45 e9 03          	movb   $0x3,-0x17(%ebp)
        : "memory", "cc");
}

static inline void
outb(uint16_t port, uint8_t data) {
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01015c0:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01015c4:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01015c8:	ee                   	out    %al,(%dx)
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c01015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01015cc:	c9                   	leave  
c01015cd:	c3                   	ret    

c01015ce <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c01015ce:	55                   	push   %ebp
c01015cf:	89 e5                	mov    %esp,%ebp
c01015d1:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c01015d4:	c7 04 24 49 14 10 c0 	movl   $0xc0101449,(%esp)
c01015db:	e8 a9 fd ff ff       	call   c0101389 <cons_intr>
}
c01015e0:	90                   	nop
c01015e1:	c9                   	leave  
c01015e2:	c3                   	ret    

c01015e3 <kbd_init>:

static void
kbd_init(void) {
c01015e3:	55                   	push   %ebp
c01015e4:	89 e5                	mov    %esp,%ebp
c01015e6:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c01015e9:	e8 e0 ff ff ff       	call   c01015ce <kbd_intr>
    pic_enable(IRQ_KBD);
c01015ee:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01015f5:	e8 34 01 00 00       	call   c010172e <pic_enable>
}
c01015fa:	90                   	nop
c01015fb:	c9                   	leave  
c01015fc:	c3                   	ret    

c01015fd <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c01015fd:	55                   	push   %ebp
c01015fe:	89 e5                	mov    %esp,%ebp
c0101600:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c0101603:	e8 90 f8 ff ff       	call   c0100e98 <cga_init>
    serial_init();
c0101608:	e8 6d f9 ff ff       	call   c0100f7a <serial_init>
    kbd_init();
c010160d:	e8 d1 ff ff ff       	call   c01015e3 <kbd_init>
    if (!serial_exists) {
c0101612:	a1 48 b4 11 c0       	mov    0xc011b448,%eax
c0101617:	85 c0                	test   %eax,%eax
c0101619:	75 0c                	jne    c0101627 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c010161b:	c7 04 24 cd 67 10 c0 	movl   $0xc01067cd,(%esp)
c0101622:	e8 76 ec ff ff       	call   c010029d <cprintf>
    }
}
c0101627:	90                   	nop
c0101628:	c9                   	leave  
c0101629:	c3                   	ret    

c010162a <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c010162a:	55                   	push   %ebp
c010162b:	89 e5                	mov    %esp,%ebp
c010162d:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c0101630:	e8 de f7 ff ff       	call   c0100e13 <__intr_save>
c0101635:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101638:	8b 45 08             	mov    0x8(%ebp),%eax
c010163b:	89 04 24             	mov    %eax,(%esp)
c010163e:	e8 8d fa ff ff       	call   c01010d0 <lpt_putc>
        cga_putc(c);
c0101643:	8b 45 08             	mov    0x8(%ebp),%eax
c0101646:	89 04 24             	mov    %eax,(%esp)
c0101649:	e8 c2 fa ff ff       	call   c0101110 <cga_putc>
        serial_putc(c);
c010164e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101651:	89 04 24             	mov    %eax,(%esp)
c0101654:	e8 f0 fc ff ff       	call   c0101349 <serial_putc>
    }
    local_intr_restore(intr_flag);
c0101659:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010165c:	89 04 24             	mov    %eax,(%esp)
c010165f:	e8 d9 f7 ff ff       	call   c0100e3d <__intr_restore>
}
c0101664:	90                   	nop
c0101665:	c9                   	leave  
c0101666:	c3                   	ret    

c0101667 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c0101667:	55                   	push   %ebp
c0101668:	89 e5                	mov    %esp,%ebp
c010166a:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c010166d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c0101674:	e8 9a f7 ff ff       	call   c0100e13 <__intr_save>
c0101679:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c010167c:	e8 aa fd ff ff       	call   c010142b <serial_intr>
        kbd_intr();
c0101681:	e8 48 ff ff ff       	call   c01015ce <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c0101686:	8b 15 60 b6 11 c0    	mov    0xc011b660,%edx
c010168c:	a1 64 b6 11 c0       	mov    0xc011b664,%eax
c0101691:	39 c2                	cmp    %eax,%edx
c0101693:	74 31                	je     c01016c6 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c0101695:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c010169a:	8d 50 01             	lea    0x1(%eax),%edx
c010169d:	89 15 60 b6 11 c0    	mov    %edx,0xc011b660
c01016a3:	0f b6 80 60 b4 11 c0 	movzbl -0x3fee4ba0(%eax),%eax
c01016aa:	0f b6 c0             	movzbl %al,%eax
c01016ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c01016b0:	a1 60 b6 11 c0       	mov    0xc011b660,%eax
c01016b5:	3d 00 02 00 00       	cmp    $0x200,%eax
c01016ba:	75 0a                	jne    c01016c6 <cons_getc+0x5f>
                cons.rpos = 0;
c01016bc:	c7 05 60 b6 11 c0 00 	movl   $0x0,0xc011b660
c01016c3:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c01016c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01016c9:	89 04 24             	mov    %eax,(%esp)
c01016cc:	e8 6c f7 ff ff       	call   c0100e3d <__intr_restore>
    return c;
c01016d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01016d4:	c9                   	leave  
c01016d5:	c3                   	ret    

c01016d6 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c01016d6:	55                   	push   %ebp
c01016d7:	89 e5                	mov    %esp,%ebp
c01016d9:	83 ec 14             	sub    $0x14,%esp
c01016dc:	8b 45 08             	mov    0x8(%ebp),%eax
c01016df:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c01016e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016e6:	66 a3 50 85 11 c0    	mov    %ax,0xc0118550
    if (did_init) {
c01016ec:	a1 6c b6 11 c0       	mov    0xc011b66c,%eax
c01016f1:	85 c0                	test   %eax,%eax
c01016f3:	74 36                	je     c010172b <pic_setmask+0x55>
        outb(IO_PIC1 + 1, mask);
c01016f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01016f8:	0f b6 c0             	movzbl %al,%eax
c01016fb:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101701:	88 45 fa             	mov    %al,-0x6(%ebp)
c0101704:	0f b6 45 fa          	movzbl -0x6(%ebp),%eax
c0101708:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010170c:	ee                   	out    %al,(%dx)
        outb(IO_PIC2 + 1, mask >> 8);
c010170d:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101711:	c1 e8 08             	shr    $0x8,%eax
c0101714:	0f b7 c0             	movzwl %ax,%eax
c0101717:	0f b6 c0             	movzbl %al,%eax
c010171a:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c0101720:	88 45 fb             	mov    %al,-0x5(%ebp)
c0101723:	0f b6 45 fb          	movzbl -0x5(%ebp),%eax
c0101727:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010172a:	ee                   	out    %al,(%dx)
    }
}
c010172b:	90                   	nop
c010172c:	c9                   	leave  
c010172d:	c3                   	ret    

c010172e <pic_enable>:

void
pic_enable(unsigned int irq) {
c010172e:	55                   	push   %ebp
c010172f:	89 e5                	mov    %esp,%ebp
c0101731:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c0101734:	8b 45 08             	mov    0x8(%ebp),%eax
c0101737:	ba 01 00 00 00       	mov    $0x1,%edx
c010173c:	88 c1                	mov    %al,%cl
c010173e:	d3 e2                	shl    %cl,%edx
c0101740:	89 d0                	mov    %edx,%eax
c0101742:	98                   	cwtl   
c0101743:	f7 d0                	not    %eax
c0101745:	0f bf d0             	movswl %ax,%edx
c0101748:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010174f:	98                   	cwtl   
c0101750:	21 d0                	and    %edx,%eax
c0101752:	98                   	cwtl   
c0101753:	0f b7 c0             	movzwl %ax,%eax
c0101756:	89 04 24             	mov    %eax,(%esp)
c0101759:	e8 78 ff ff ff       	call   c01016d6 <pic_setmask>
}
c010175e:	90                   	nop
c010175f:	c9                   	leave  
c0101760:	c3                   	ret    

c0101761 <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c0101761:	55                   	push   %ebp
c0101762:	89 e5                	mov    %esp,%ebp
c0101764:	83 ec 34             	sub    $0x34,%esp
    did_init = 1;
c0101767:	c7 05 6c b6 11 c0 01 	movl   $0x1,0xc011b66c
c010176e:	00 00 00 
c0101771:	66 c7 45 fe 21 00    	movw   $0x21,-0x2(%ebp)
c0101777:	c6 45 d6 ff          	movb   $0xff,-0x2a(%ebp)
c010177b:	0f b6 45 d6          	movzbl -0x2a(%ebp),%eax
c010177f:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101783:	ee                   	out    %al,(%dx)
c0101784:	66 c7 45 fc a1 00    	movw   $0xa1,-0x4(%ebp)
c010178a:	c6 45 d7 ff          	movb   $0xff,-0x29(%ebp)
c010178e:	0f b6 45 d7          	movzbl -0x29(%ebp),%eax
c0101792:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0101795:	ee                   	out    %al,(%dx)
c0101796:	66 c7 45 fa 20 00    	movw   $0x20,-0x6(%ebp)
c010179c:	c6 45 d8 11          	movb   $0x11,-0x28(%ebp)
c01017a0:	0f b6 45 d8          	movzbl -0x28(%ebp),%eax
c01017a4:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01017a8:	ee                   	out    %al,(%dx)
c01017a9:	66 c7 45 f8 21 00    	movw   $0x21,-0x8(%ebp)
c01017af:	c6 45 d9 20          	movb   $0x20,-0x27(%ebp)
c01017b3:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c01017b7:	8b 55 f8             	mov    -0x8(%ebp),%edx
c01017ba:	ee                   	out    %al,(%dx)
c01017bb:	66 c7 45 f6 21 00    	movw   $0x21,-0xa(%ebp)
c01017c1:	c6 45 da 04          	movb   $0x4,-0x26(%ebp)
c01017c5:	0f b6 45 da          	movzbl -0x26(%ebp),%eax
c01017c9:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01017cd:	ee                   	out    %al,(%dx)
c01017ce:	66 c7 45 f4 21 00    	movw   $0x21,-0xc(%ebp)
c01017d4:	c6 45 db 03          	movb   $0x3,-0x25(%ebp)
c01017d8:	0f b6 45 db          	movzbl -0x25(%ebp),%eax
c01017dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01017df:	ee                   	out    %al,(%dx)
c01017e0:	66 c7 45 f2 a0 00    	movw   $0xa0,-0xe(%ebp)
c01017e6:	c6 45 dc 11          	movb   $0x11,-0x24(%ebp)
c01017ea:	0f b6 45 dc          	movzbl -0x24(%ebp),%eax
c01017ee:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01017f2:	ee                   	out    %al,(%dx)
c01017f3:	66 c7 45 f0 a1 00    	movw   $0xa1,-0x10(%ebp)
c01017f9:	c6 45 dd 28          	movb   $0x28,-0x23(%ebp)
c01017fd:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0101801:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0101804:	ee                   	out    %al,(%dx)
c0101805:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c010180b:	c6 45 de 02          	movb   $0x2,-0x22(%ebp)
c010180f:	0f b6 45 de          	movzbl -0x22(%ebp),%eax
c0101813:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101817:	ee                   	out    %al,(%dx)
c0101818:	66 c7 45 ec a1 00    	movw   $0xa1,-0x14(%ebp)
c010181e:	c6 45 df 03          	movb   $0x3,-0x21(%ebp)
c0101822:	0f b6 45 df          	movzbl -0x21(%ebp),%eax
c0101826:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0101829:	ee                   	out    %al,(%dx)
c010182a:	66 c7 45 ea 20 00    	movw   $0x20,-0x16(%ebp)
c0101830:	c6 45 e0 68          	movb   $0x68,-0x20(%ebp)
c0101834:	0f b6 45 e0          	movzbl -0x20(%ebp),%eax
c0101838:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010183c:	ee                   	out    %al,(%dx)
c010183d:	66 c7 45 e8 20 00    	movw   $0x20,-0x18(%ebp)
c0101843:	c6 45 e1 0a          	movb   $0xa,-0x1f(%ebp)
c0101847:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c010184b:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010184e:	ee                   	out    %al,(%dx)
c010184f:	66 c7 45 e6 a0 00    	movw   $0xa0,-0x1a(%ebp)
c0101855:	c6 45 e2 68          	movb   $0x68,-0x1e(%ebp)
c0101859:	0f b6 45 e2          	movzbl -0x1e(%ebp),%eax
c010185d:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101861:	ee                   	out    %al,(%dx)
c0101862:	66 c7 45 e4 a0 00    	movw   $0xa0,-0x1c(%ebp)
c0101868:	c6 45 e3 0a          	movb   $0xa,-0x1d(%ebp)
c010186c:	0f b6 45 e3          	movzbl -0x1d(%ebp),%eax
c0101870:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0101873:	ee                   	out    %al,(%dx)
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101874:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c010187b:	3d ff ff 00 00       	cmp    $0xffff,%eax
c0101880:	74 0f                	je     c0101891 <pic_init+0x130>
        pic_setmask(irq_mask);
c0101882:	0f b7 05 50 85 11 c0 	movzwl 0xc0118550,%eax
c0101889:	89 04 24             	mov    %eax,(%esp)
c010188c:	e8 45 fe ff ff       	call   c01016d6 <pic_setmask>
    }
}
c0101891:	90                   	nop
c0101892:	c9                   	leave  
c0101893:	c3                   	ret    

c0101894 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101894:	55                   	push   %ebp
c0101895:	89 e5                	mov    %esp,%ebp
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
}

static inline void
sti(void) {
    asm volatile ("sti");
c0101897:	fb                   	sti    
    sti();
}
c0101898:	90                   	nop
c0101899:	5d                   	pop    %ebp
c010189a:	c3                   	ret    

c010189b <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c010189b:	55                   	push   %ebp
c010189c:	89 e5                	mov    %esp,%ebp
}

static inline void
cli(void) {
    asm volatile ("cli" ::: "memory");
c010189e:	fa                   	cli    
    cli();
}
c010189f:	90                   	nop
c01018a0:	5d                   	pop    %ebp
c01018a1:	c3                   	ret    

c01018a2 <print_ticks>:
#include <console.h>
#include <kdebug.h>

#define TICK_NUM 100

static void print_ticks() {
c01018a2:	55                   	push   %ebp
c01018a3:	89 e5                	mov    %esp,%ebp
c01018a5:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c01018a8:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c01018af:	00 
c01018b0:	c7 04 24 00 68 10 c0 	movl   $0xc0106800,(%esp)
c01018b7:	e8 e1 e9 ff ff       	call   c010029d <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
    panic("EOT: kernel seems ok.");
#endif
}
c01018bc:	90                   	nop
c01018bd:	c9                   	leave  
c01018be:	c3                   	ret    

c01018bf <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c01018bf:	55                   	push   %ebp
c01018c0:	89 e5                	mov    %esp,%ebp
c01018c2:	83 ec 10             	sub    $0x10,%esp
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
c01018c5:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c01018cc:	e9 67 02 00 00       	jmp    c0101b38 <idt_init+0x279>
        if(i == 128){
c01018d1:	81 7d fc 80 00 00 00 	cmpl   $0x80,-0x4(%ebp)
c01018d8:	0f 85 c6 00 00 00    	jne    c01019a4 <idt_init+0xe5>
            SETGATE(idt[i],0,8,__vectors[i],3);
c01018de:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018e1:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c01018e8:	0f b7 d0             	movzwl %ax,%edx
c01018eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018ee:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c01018f5:	c0 
c01018f6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01018f9:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c0101900:	c0 08 00 
c0101903:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101906:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c010190d:	c0 
c010190e:	80 e2 e0             	and    $0xe0,%dl
c0101911:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101918:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010191b:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c0101922:	c0 
c0101923:	80 e2 1f             	and    $0x1f,%dl
c0101926:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c010192d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101930:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101937:	c0 
c0101938:	80 e2 f0             	and    $0xf0,%dl
c010193b:	80 ca 0e             	or     $0xe,%dl
c010193e:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101945:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101948:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c010194f:	c0 
c0101950:	80 e2 ef             	and    $0xef,%dl
c0101953:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010195a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010195d:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101964:	c0 
c0101965:	80 ca 60             	or     $0x60,%dl
c0101968:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c010196f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101972:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101979:	c0 
c010197a:	80 ca 80             	or     $0x80,%dl
c010197d:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101984:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101987:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c010198e:	c1 e8 10             	shr    $0x10,%eax
c0101991:	0f b7 d0             	movzwl %ax,%edx
c0101994:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101997:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c010199e:	c0 
c010199f:	e9 91 01 00 00       	jmp    c0101b35 <idt_init+0x276>
        }
        else if(i == 121){
c01019a4:	83 7d fc 79          	cmpl   $0x79,-0x4(%ebp)
c01019a8:	0f 85 c6 00 00 00    	jne    c0101a74 <idt_init+0x1b5>
            SETGATE(idt[i],0,8,__vectors[i],3);
c01019ae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b1:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c01019b8:	0f b7 d0             	movzwl %ax,%edx
c01019bb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019be:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c01019c5:	c0 
c01019c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019c9:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c01019d0:	c0 08 00 
c01019d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019d6:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c01019dd:	c0 
c01019de:	80 e2 e0             	and    $0xe0,%dl
c01019e1:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01019e8:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019eb:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c01019f2:	c0 
c01019f3:	80 e2 1f             	and    $0x1f,%dl
c01019f6:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c01019fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a00:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101a07:	c0 
c0101a08:	80 e2 f0             	and    $0xf0,%dl
c0101a0b:	80 ca 0e             	or     $0xe,%dl
c0101a0e:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101a15:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a18:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101a1f:	c0 
c0101a20:	80 e2 ef             	and    $0xef,%dl
c0101a23:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101a2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a2d:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101a34:	c0 
c0101a35:	80 ca 60             	or     $0x60,%dl
c0101a38:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101a3f:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a42:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101a49:	c0 
c0101a4a:	80 ca 80             	or     $0x80,%dl
c0101a4d:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101a54:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a57:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101a5e:	c1 e8 10             	shr    $0x10,%eax
c0101a61:	0f b7 d0             	movzwl %ax,%edx
c0101a64:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a67:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c0101a6e:	c0 
c0101a6f:	e9 c1 00 00 00       	jmp    c0101b35 <idt_init+0x276>
        }
        else{
            SETGATE(idt[i],0,8,__vectors[i],0);
c0101a74:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a77:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101a7e:	0f b7 d0             	movzwl %ax,%edx
c0101a81:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a84:	66 89 14 c5 80 b6 11 	mov    %dx,-0x3fee4980(,%eax,8)
c0101a8b:	c0 
c0101a8c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a8f:	66 c7 04 c5 82 b6 11 	movw   $0x8,-0x3fee497e(,%eax,8)
c0101a96:	c0 08 00 
c0101a99:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a9c:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c0101aa3:	c0 
c0101aa4:	80 e2 e0             	and    $0xe0,%dl
c0101aa7:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101aae:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101ab1:	0f b6 14 c5 84 b6 11 	movzbl -0x3fee497c(,%eax,8),%edx
c0101ab8:	c0 
c0101ab9:	80 e2 1f             	and    $0x1f,%dl
c0101abc:	88 14 c5 84 b6 11 c0 	mov    %dl,-0x3fee497c(,%eax,8)
c0101ac3:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101ac6:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101acd:	c0 
c0101ace:	80 e2 f0             	and    $0xf0,%dl
c0101ad1:	80 ca 0e             	or     $0xe,%dl
c0101ad4:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101adb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101ade:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101ae5:	c0 
c0101ae6:	80 e2 ef             	and    $0xef,%dl
c0101ae9:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101af0:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101af3:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101afa:	c0 
c0101afb:	80 e2 9f             	and    $0x9f,%dl
c0101afe:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101b05:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101b08:	0f b6 14 c5 85 b6 11 	movzbl -0x3fee497b(,%eax,8),%edx
c0101b0f:	c0 
c0101b10:	80 ca 80             	or     $0x80,%dl
c0101b13:	88 14 c5 85 b6 11 c0 	mov    %dl,-0x3fee497b(,%eax,8)
c0101b1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101b1d:	8b 04 85 e0 85 11 c0 	mov    -0x3fee7a20(,%eax,4),%eax
c0101b24:	c1 e8 10             	shr    $0x10,%eax
c0101b27:	0f b7 d0             	movzwl %ax,%edx
c0101b2a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101b2d:	66 89 14 c5 86 b6 11 	mov    %dx,-0x3fee497a(,%eax,8)
c0101b34:	c0 
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
c0101b35:	ff 45 fc             	incl   -0x4(%ebp)
c0101b38:	81 7d fc ff 00 00 00 	cmpl   $0xff,-0x4(%ebp)
c0101b3f:	0f 8e 8c fd ff ff    	jle    c01018d1 <idt_init+0x12>
c0101b45:	c7 45 f8 60 85 11 c0 	movl   $0xc0118560,-0x8(%ebp)
    }
}

static inline void
lidt(struct pseudodesc *pd) {
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101b4c:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101b4f:	0f 01 18             	lidtl  (%eax)
        //          for software to invoke this interrupt/trap gate explicitly
        //          using an int instruction.
    }

    lidt(&idt_pd);
}
c0101b52:	90                   	nop
c0101b53:	c9                   	leave  
c0101b54:	c3                   	ret    

c0101b55 <trapname>:

static const char *
trapname(int trapno) {
c0101b55:	55                   	push   %ebp
c0101b56:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5b:	83 f8 13             	cmp    $0x13,%eax
c0101b5e:	77 0c                	ja     c0101b6c <trapname+0x17>
        return excnames[trapno];
c0101b60:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b63:	8b 04 85 60 6b 10 c0 	mov    -0x3fef94a0(,%eax,4),%eax
c0101b6a:	eb 18                	jmp    c0101b84 <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101b6c:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101b70:	7e 0d                	jle    c0101b7f <trapname+0x2a>
c0101b72:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101b76:	7f 07                	jg     c0101b7f <trapname+0x2a>
        return "Hardware Interrupt";
c0101b78:	b8 0a 68 10 c0       	mov    $0xc010680a,%eax
c0101b7d:	eb 05                	jmp    c0101b84 <trapname+0x2f>
    }
    return "(unknown trap)";
c0101b7f:	b8 1d 68 10 c0       	mov    $0xc010681d,%eax
}
c0101b84:	5d                   	pop    %ebp
c0101b85:	c3                   	ret    

c0101b86 <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101b86:	55                   	push   %ebp
c0101b87:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101b89:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b90:	83 f8 08             	cmp    $0x8,%eax
c0101b93:	0f 94 c0             	sete   %al
c0101b96:	0f b6 c0             	movzbl %al,%eax
}
c0101b99:	5d                   	pop    %ebp
c0101b9a:	c3                   	ret    

c0101b9b <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b9b:	55                   	push   %ebp
c0101b9c:	89 e5                	mov    %esp,%ebp
c0101b9e:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ba8:	c7 04 24 5e 68 10 c0 	movl   $0xc010685e,(%esp)
c0101baf:	e8 e9 e6 ff ff       	call   c010029d <cprintf>
    print_regs(&tf->tf_regs);
c0101bb4:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bb7:	89 04 24             	mov    %eax,(%esp)
c0101bba:	e8 91 01 00 00       	call   c0101d50 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101bbf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bc2:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101bc6:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bca:	c7 04 24 6f 68 10 c0 	movl   $0xc010686f,(%esp)
c0101bd1:	e8 c7 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101bd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bd9:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be1:	c7 04 24 82 68 10 c0 	movl   $0xc0106882,(%esp)
c0101be8:	e8 b0 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101bed:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf0:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101bf4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bf8:	c7 04 24 95 68 10 c0 	movl   $0xc0106895,(%esp)
c0101bff:	e8 99 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101c04:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c07:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101c0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c0f:	c7 04 24 a8 68 10 c0 	movl   $0xc01068a8,(%esp)
c0101c16:	e8 82 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101c1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c1e:	8b 40 30             	mov    0x30(%eax),%eax
c0101c21:	89 04 24             	mov    %eax,(%esp)
c0101c24:	e8 2c ff ff ff       	call   c0101b55 <trapname>
c0101c29:	89 c2                	mov    %eax,%edx
c0101c2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c2e:	8b 40 30             	mov    0x30(%eax),%eax
c0101c31:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101c35:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c39:	c7 04 24 bb 68 10 c0 	movl   $0xc01068bb,(%esp)
c0101c40:	e8 58 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101c45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c48:	8b 40 34             	mov    0x34(%eax),%eax
c0101c4b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c4f:	c7 04 24 cd 68 10 c0 	movl   $0xc01068cd,(%esp)
c0101c56:	e8 42 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101c5b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c5e:	8b 40 38             	mov    0x38(%eax),%eax
c0101c61:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c65:	c7 04 24 dc 68 10 c0 	movl   $0xc01068dc,(%esp)
c0101c6c:	e8 2c e6 ff ff       	call   c010029d <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101c71:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c74:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101c78:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c7c:	c7 04 24 eb 68 10 c0 	movl   $0xc01068eb,(%esp)
c0101c83:	e8 15 e6 ff ff       	call   c010029d <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101c88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c8b:	8b 40 40             	mov    0x40(%eax),%eax
c0101c8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c92:	c7 04 24 fe 68 10 c0 	movl   $0xc01068fe,(%esp)
c0101c99:	e8 ff e5 ff ff       	call   c010029d <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c9e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101ca5:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101cac:	eb 3d                	jmp    c0101ceb <print_trapframe+0x150>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101cae:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cb1:	8b 50 40             	mov    0x40(%eax),%edx
c0101cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101cb7:	21 d0                	and    %edx,%eax
c0101cb9:	85 c0                	test   %eax,%eax
c0101cbb:	74 28                	je     c0101ce5 <print_trapframe+0x14a>
c0101cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cc0:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101cc7:	85 c0                	test   %eax,%eax
c0101cc9:	74 1a                	je     c0101ce5 <print_trapframe+0x14a>
            cprintf("%s,", IA32flags[i]);
c0101ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cce:	8b 04 85 80 85 11 c0 	mov    -0x3fee7a80(,%eax,4),%eax
c0101cd5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cd9:	c7 04 24 0d 69 10 c0 	movl   $0xc010690d,(%esp)
c0101ce0:	e8 b8 e5 ff ff       	call   c010029d <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
    cprintf("  flag 0x%08x ", tf->tf_eflags);

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101ce5:	ff 45 f4             	incl   -0xc(%ebp)
c0101ce8:	d1 65 f0             	shll   -0x10(%ebp)
c0101ceb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101cee:	83 f8 17             	cmp    $0x17,%eax
c0101cf1:	76 bb                	jbe    c0101cae <print_trapframe+0x113>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
            cprintf("%s,", IA32flags[i]);
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101cf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf6:	8b 40 40             	mov    0x40(%eax),%eax
c0101cf9:	25 00 30 00 00       	and    $0x3000,%eax
c0101cfe:	c1 e8 0c             	shr    $0xc,%eax
c0101d01:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d05:	c7 04 24 11 69 10 c0 	movl   $0xc0106911,(%esp)
c0101d0c:	e8 8c e5 ff ff       	call   c010029d <cprintf>

    if (!trap_in_kernel(tf)) {
c0101d11:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d14:	89 04 24             	mov    %eax,(%esp)
c0101d17:	e8 6a fe ff ff       	call   c0101b86 <trap_in_kernel>
c0101d1c:	85 c0                	test   %eax,%eax
c0101d1e:	75 2d                	jne    c0101d4d <print_trapframe+0x1b2>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101d20:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d23:	8b 40 44             	mov    0x44(%eax),%eax
c0101d26:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d2a:	c7 04 24 1a 69 10 c0 	movl   $0xc010691a,(%esp)
c0101d31:	e8 67 e5 ff ff       	call   c010029d <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101d36:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d39:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101d3d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d41:	c7 04 24 29 69 10 c0 	movl   $0xc0106929,(%esp)
c0101d48:	e8 50 e5 ff ff       	call   c010029d <cprintf>
    }
}
c0101d4d:	90                   	nop
c0101d4e:	c9                   	leave  
c0101d4f:	c3                   	ret    

c0101d50 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101d50:	55                   	push   %ebp
c0101d51:	89 e5                	mov    %esp,%ebp
c0101d53:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101d56:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d59:	8b 00                	mov    (%eax),%eax
c0101d5b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d5f:	c7 04 24 3c 69 10 c0 	movl   $0xc010693c,(%esp)
c0101d66:	e8 32 e5 ff ff       	call   c010029d <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101d6b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d6e:	8b 40 04             	mov    0x4(%eax),%eax
c0101d71:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d75:	c7 04 24 4b 69 10 c0 	movl   $0xc010694b,(%esp)
c0101d7c:	e8 1c e5 ff ff       	call   c010029d <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101d81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d84:	8b 40 08             	mov    0x8(%eax),%eax
c0101d87:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d8b:	c7 04 24 5a 69 10 c0 	movl   $0xc010695a,(%esp)
c0101d92:	e8 06 e5 ff ff       	call   c010029d <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d97:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d9a:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d9d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101da1:	c7 04 24 69 69 10 c0 	movl   $0xc0106969,(%esp)
c0101da8:	e8 f0 e4 ff ff       	call   c010029d <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101dad:	8b 45 08             	mov    0x8(%ebp),%eax
c0101db0:	8b 40 10             	mov    0x10(%eax),%eax
c0101db3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101db7:	c7 04 24 78 69 10 c0 	movl   $0xc0106978,(%esp)
c0101dbe:	e8 da e4 ff ff       	call   c010029d <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101dc3:	8b 45 08             	mov    0x8(%ebp),%eax
c0101dc6:	8b 40 14             	mov    0x14(%eax),%eax
c0101dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101dcd:	c7 04 24 87 69 10 c0 	movl   $0xc0106987,(%esp)
c0101dd4:	e8 c4 e4 ff ff       	call   c010029d <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101dd9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ddc:	8b 40 18             	mov    0x18(%eax),%eax
c0101ddf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101de3:	c7 04 24 96 69 10 c0 	movl   $0xc0106996,(%esp)
c0101dea:	e8 ae e4 ff ff       	call   c010029d <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101def:	8b 45 08             	mov    0x8(%ebp),%eax
c0101df2:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101df5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101df9:	c7 04 24 a5 69 10 c0 	movl   $0xc01069a5,(%esp)
c0101e00:	e8 98 e4 ff ff       	call   c010029d <cprintf>
}
c0101e05:	90                   	nop
c0101e06:	c9                   	leave  
c0101e07:	c3                   	ret    

c0101e08 <l_switch_to_user>:
static uint32_t i_in_td, tf_end_in_td;
struct trapframe switchk2u, *switchu2k;
extern void __move_down_stack2(uint32_t end, uint32_t tf);
extern struct trapframe* __move_up_stack2(uint32_t end, uint32_t tf, uint32_t esp);

static void l_switch_to_user() {
c0101e08:	55                   	push   %ebp
c0101e09:	89 e5                	mov    %esp,%ebp
    asm volatile (
c0101e0b:	83 ec 08             	sub    $0x8,%esp
c0101e0e:	cd 78                	int    $0x78
c0101e10:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp"
        : 
        : "i"(T_SWITCH_TOU)
    );
}
c0101e12:	90                   	nop
c0101e13:	5d                   	pop    %ebp
c0101e14:	c3                   	ret    

c0101e15 <l_switch_to_kernel>:

static void l_switch_to_kernel(void) {
c0101e15:	55                   	push   %ebp
c0101e16:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
        asm volatile (
c0101e18:	cd 79                	int    $0x79
c0101e1a:	89 ec                	mov    %ebp,%esp
        "int %0 \n"
        "movl %%ebp, %%esp \n"
        : 
        : "i"(T_SWITCH_TOK)
        );
}
c0101e1c:	90                   	nop
c0101e1d:	5d                   	pop    %ebp
c0101e1e:	c3                   	ret    

c0101e1f <trap_dispatch>:
}


/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101e1f:	55                   	push   %ebp
c0101e20:	89 e5                	mov    %esp,%ebp
c0101e22:	56                   	push   %esi
c0101e23:	53                   	push   %ebx
c0101e24:	83 ec 20             	sub    $0x20,%esp
    char c;

    switch (tf->tf_trapno) {
c0101e27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e2a:	8b 40 30             	mov    0x30(%eax),%eax
c0101e2d:	83 f8 2f             	cmp    $0x2f,%eax
c0101e30:	77 1d                	ja     c0101e4f <trap_dispatch+0x30>
c0101e32:	83 f8 2e             	cmp    $0x2e,%eax
c0101e35:	0f 83 2a 03 00 00    	jae    c0102165 <trap_dispatch+0x346>
c0101e3b:	83 f8 21             	cmp    $0x21,%eax
c0101e3e:	74 7c                	je     c0101ebc <trap_dispatch+0x9d>
c0101e40:	83 f8 24             	cmp    $0x24,%eax
c0101e43:	74 4e                	je     c0101e93 <trap_dispatch+0x74>
c0101e45:	83 f8 20             	cmp    $0x20,%eax
c0101e48:	74 1c                	je     c0101e66 <trap_dispatch+0x47>
c0101e4a:	e9 e1 02 00 00       	jmp    c0102130 <trap_dispatch+0x311>
c0101e4f:	83 f8 78             	cmp    $0x78,%eax
c0101e52:	0f 84 d0 01 00 00    	je     c0102028 <trap_dispatch+0x209>
c0101e58:	83 f8 79             	cmp    $0x79,%eax
c0101e5b:	0f 84 4b 02 00 00    	je     c01020ac <trap_dispatch+0x28d>
c0101e61:	e9 ca 02 00 00       	jmp    c0102130 <trap_dispatch+0x311>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        count++;
c0101e66:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0101e6b:	40                   	inc    %eax
c0101e6c:	a3 80 be 11 c0       	mov    %eax,0xc011be80
        if(count == TICK_NUM){
c0101e71:	a1 80 be 11 c0       	mov    0xc011be80,%eax
c0101e76:	83 f8 64             	cmp    $0x64,%eax
c0101e79:	0f 85 e9 02 00 00    	jne    c0102168 <trap_dispatch+0x349>
            count = 0;
c0101e7f:	c7 05 80 be 11 c0 00 	movl   $0x0,0xc011be80
c0101e86:	00 00 00 
            print_ticks();
c0101e89:	e8 14 fa ff ff       	call   c01018a2 <print_ticks>
        }
        break;
c0101e8e:	e9 d5 02 00 00       	jmp    c0102168 <trap_dispatch+0x349>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101e93:	e8 cf f7 ff ff       	call   c0101667 <cons_getc>
c0101e98:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101e9b:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e9f:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101ea3:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ea7:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101eab:	c7 04 24 b4 69 10 c0 	movl   $0xc01069b4,(%esp)
c0101eb2:	e8 e6 e3 ff ff       	call   c010029d <cprintf>
        break;
c0101eb7:	e9 b3 02 00 00       	jmp    c010216f <trap_dispatch+0x350>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101ebc:	e8 a6 f7 ff ff       	call   c0101667 <cons_getc>
c0101ec1:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101ec4:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101ec8:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101ecc:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101ed0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ed4:	c7 04 24 c6 69 10 c0 	movl   $0xc01069c6,(%esp)
c0101edb:	e8 bd e3 ff ff       	call   c010029d <cprintf>
        if (c == 0x30) { // switch to kernel mode
c0101ee0:	80 7d f7 30          	cmpb   $0x30,-0x9(%ebp)
c0101ee4:	0f 85 82 00 00 00    	jne    c0101f6c <trap_dispatch+0x14d>
            saved_tf = __move_up_stack2((uint32_t)(tf) + sizeof(struct trapframe) - 8, (uint32_t) tf, tf->tf_esp);
c0101eea:	8b 45 08             	mov    0x8(%ebp),%eax
c0101eed:	8b 50 44             	mov    0x44(%eax),%edx
c0101ef0:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ef3:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0101ef6:	83 c1 44             	add    $0x44,%ecx
c0101ef9:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101efd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f01:	89 0c 24             	mov    %ecx,(%esp)
c0101f04:	e8 5d 0d 00 00       	call   c0102c66 <__move_up_stack2>
c0101f09:	a3 84 be 11 c0       	mov    %eax,0xc011be84
            saved_tf->tf_cs = KERNEL_CS;
c0101f0e:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0101f13:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_gs = KERNEL_DS;
c0101f19:	8b 1d 84 be 11 c0    	mov    0xc011be84,%ebx
c0101f1f:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0101f24:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c0101f2a:	8b 0d 84 be 11 c0    	mov    0xc011be84,%ecx
c0101f30:	66 c7 41 20 10 00    	movw   $0x10,0x20(%ecx)
c0101f36:	0f b7 49 20          	movzwl 0x20(%ecx),%ecx
c0101f3a:	66 89 4a 24          	mov    %cx,0x24(%edx)
c0101f3e:	0f b7 52 24          	movzwl 0x24(%edx),%edx
c0101f42:	66 89 50 28          	mov    %dx,0x28(%eax)
c0101f46:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101f4a:	66 89 43 2c          	mov    %ax,0x2c(%ebx)
            saved_tf->tf_trapno = 0x21;
c0101f4e:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0101f53:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
            asm volatile (
c0101f5a:	b8 10 00 00 00       	mov    $0x10,%eax
c0101f5f:	8e d0                	mov    %eax,%ss
                "movw %0, %%ss"
                :
                : "r"(KERNEL_DS)
                 );
            print_trapframe(tf);
c0101f61:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f64:	89 04 24             	mov    %eax,(%esp)
c0101f67:	e8 2f fc ff ff       	call   c0101b9b <print_trapframe>
        }

        if (c == 0x33) { // switch to user mode
c0101f6c:	80 7d f7 33          	cmpb   $0x33,-0x9(%ebp)
c0101f70:	0f 85 f5 01 00 00    	jne    c010216b <trap_dispatch+0x34c>
            saved_tf = (struct trapname*) ((uint32_t)(tf) - 8);
c0101f76:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f79:	83 e8 08             	sub    $0x8,%eax
c0101f7c:	a3 84 be 11 c0       	mov    %eax,0xc011be84
    
            __move_down_stack2( (uint32_t)(tf) + sizeof(struct trapframe) - 8 , (uint32_t) tf );
c0101f81:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f84:	8b 55 08             	mov    0x8(%ebp),%edx
c0101f87:	83 c2 44             	add    $0x44,%edx
c0101f8a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101f8e:	89 14 24             	mov    %edx,(%esp)
c0101f91:	e8 89 0c 00 00       	call   c0102c1f <__move_down_stack2>

            saved_tf->tf_eflags |= FL_IOPL_MASK;
c0101f96:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0101f9b:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c0101fa1:	8b 52 40             	mov    0x40(%edx),%edx
c0101fa4:	81 ca 00 30 00 00    	or     $0x3000,%edx
c0101faa:	89 50 40             	mov    %edx,0x40(%eax)
            saved_tf->tf_cs = USER_CS;
c0101fad:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0101fb2:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
c0101fb8:	8b 35 84 be 11 c0    	mov    0xc011be84,%esi
c0101fbe:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0101fc3:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c0101fc9:	8b 0d 84 be 11 c0    	mov    0xc011be84,%ecx
c0101fcf:	8b 1d 84 be 11 c0    	mov    0xc011be84,%ebx
c0101fd5:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
c0101fdb:	0f b7 5b 20          	movzwl 0x20(%ebx),%ebx
c0101fdf:	66 89 59 48          	mov    %bx,0x48(%ecx)
c0101fe3:	0f b7 49 48          	movzwl 0x48(%ecx),%ecx
c0101fe7:	66 89 4a 24          	mov    %cx,0x24(%edx)
c0101feb:	0f b7 52 24          	movzwl 0x24(%edx),%edx
c0101fef:	66 89 50 28          	mov    %dx,0x28(%eax)
c0101ff3:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101ff7:	66 89 46 2c          	mov    %ax,0x2c(%esi)
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
c0101ffb:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0102000:	8b 15 84 be 11 c0    	mov    0xc011be84,%edx
c0102006:	83 c2 4c             	add    $0x4c,%edx
c0102009:	89 50 44             	mov    %edx,0x44(%eax)
            saved_tf->tf_trapno = 0x21;
c010200c:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c0102011:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
            print_trapframe(tf);
c0102018:	8b 45 08             	mov    0x8(%ebp),%eax
c010201b:	89 04 24             	mov    %eax,(%esp)
c010201e:	e8 78 fb ff ff       	call   c0101b9b <print_trapframe>
        }
        break;
c0102023:	e9 43 01 00 00       	jmp    c010216b <trap_dispatch+0x34c>
c0102028:	8b 45 08             	mov    0x8(%ebp),%eax
c010202b:	89 45 ec             	mov    %eax,-0x14(%ebp)
        saved_tf->tf_trapno = 0x21;
    }
}

static inline __attribute__((always_inline)) void switch_to_user(struct trapframe *tf) {
    if (tf->tf_cs != USER_CS) {
c010202e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102031:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102035:	83 f8 1b             	cmp    $0x1b,%eax
c0102038:	0f 84 30 01 00 00    	je     c010216e <trap_dispatch+0x34f>
     
        tf->tf_eflags |= FL_IOPL_MASK;
c010203e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102041:	8b 40 40             	mov    0x40(%eax),%eax
c0102044:	0d 00 30 00 00       	or     $0x3000,%eax
c0102049:	89 c2                	mov    %eax,%edx
c010204b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010204e:	89 50 40             	mov    %edx,0x40(%eax)
        tf->tf_cs = USER_CS;
c0102051:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102054:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = USER_DS;
c010205a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010205d:	66 c7 40 24 23 00    	movw   $0x23,0x24(%eax)
c0102063:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102066:	0f b7 50 24          	movzwl 0x24(%eax),%edx
c010206a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010206d:	66 89 50 48          	mov    %dx,0x48(%eax)
c0102071:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102074:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c0102078:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010207b:	66 89 50 20          	mov    %dx,0x20(%eax)
c010207f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102082:	0f b7 50 20          	movzwl 0x20(%eax),%edx
c0102086:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102089:	66 89 50 28          	mov    %dx,0x28(%eax)
c010208d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102090:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102094:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102097:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        saved_tf->tf_trapno = 0x21;
c010209b:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c01020a0:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
        }
        break;
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
c01020a7:	e9 c2 00 00 00       	jmp    c010216e <trap_dispatch+0x34f>
c01020ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01020af:	89 45 f0             	mov    %eax,-0x10(%ebp)
        : "i"(T_SWITCH_TOK)
        );
}

static inline __attribute__((always_inline)) void switch_to_kernel(struct trapframe *tf) {
    if (tf->tf_cs != KERNEL_CS) {
c01020b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c01020b9:	83 f8 08             	cmp    $0x8,%eax
c01020bc:	74 56                	je     c0102114 <trap_dispatch+0x2f5>
        tf->tf_cs = KERNEL_CS;
c01020be:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020c1:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = KERNEL_DS;
c01020c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020ca:	66 c7 40 24 10 00    	movw   $0x10,0x24(%eax)
c01020d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020d3:	0f b7 50 24          	movzwl 0x24(%eax),%edx
c01020d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020da:	66 89 50 48          	mov    %dx,0x48(%eax)
c01020de:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020e1:	0f b7 50 48          	movzwl 0x48(%eax),%edx
c01020e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020e8:	66 89 50 20          	mov    %dx,0x20(%eax)
c01020ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020ef:	0f b7 50 20          	movzwl 0x20(%eax),%edx
c01020f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020f6:	66 89 50 28          	mov    %dx,0x28(%eax)
c01020fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01020fd:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0102101:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102104:	66 89 50 2c          	mov    %dx,0x2c(%eax)
        saved_tf->tf_trapno = 0x21;
c0102108:	a1 84 be 11 c0       	mov    0xc011be84,%eax
c010210d:	c7 40 30 21 00 00 00 	movl   $0x21,0x30(%eax)
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
    case T_SWITCH_TOK:
        switch_to_kernel(tf);
        panic("T_SWITCH_** ??\n");
c0102114:	c7 44 24 08 d5 69 10 	movl   $0xc01069d5,0x8(%esp)
c010211b:	c0 
c010211c:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0102123:	00 
c0102124:	c7 04 24 e5 69 10 c0 	movl   $0xc01069e5,(%esp)
c010212b:	e8 c4 e2 ff ff       	call   c01003f4 <__panic>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0102130:	8b 45 08             	mov    0x8(%ebp),%eax
c0102133:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0102137:	83 e0 03             	and    $0x3,%eax
c010213a:	85 c0                	test   %eax,%eax
c010213c:	75 31                	jne    c010216f <trap_dispatch+0x350>
            print_trapframe(tf);
c010213e:	8b 45 08             	mov    0x8(%ebp),%eax
c0102141:	89 04 24             	mov    %eax,(%esp)
c0102144:	e8 52 fa ff ff       	call   c0101b9b <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0102149:	c7 44 24 08 f6 69 10 	movl   $0xc01069f6,0x8(%esp)
c0102150:	c0 
c0102151:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0102158:	00 
c0102159:	c7 04 24 e5 69 10 c0 	movl   $0xc01069e5,(%esp)
c0102160:	e8 8f e2 ff ff       	call   c01003f4 <__panic>
        panic("T_SWITCH_** ??\n");
        break;
    case IRQ_OFFSET + IRQ_IDE1:
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
c0102165:	90                   	nop
c0102166:	eb 07                	jmp    c010216f <trap_dispatch+0x350>
        count++;
        if(count == TICK_NUM){
            count = 0;
            print_ticks();
        }
        break;
c0102168:	90                   	nop
c0102169:	eb 04                	jmp    c010216f <trap_dispatch+0x350>
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
            saved_tf->tf_trapno = 0x21;
            print_trapframe(tf);
        }
        break;
c010216b:	90                   	nop
c010216c:	eb 01                	jmp    c010216f <trap_dispatch+0x350>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        switch_to_user(tf);
        break;
c010216e:	90                   	nop
        if ((tf->tf_cs & 3) == 0) {
            print_trapframe(tf);
            panic("unexpected trap in kernel.\n");
        }
    }
}
c010216f:	90                   	nop
c0102170:	83 c4 20             	add    $0x20,%esp
c0102173:	5b                   	pop    %ebx
c0102174:	5e                   	pop    %esi
c0102175:	5d                   	pop    %ebp
c0102176:	c3                   	ret    

c0102177 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0102177:	55                   	push   %ebp
c0102178:	89 e5                	mov    %esp,%ebp
c010217a:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c010217d:	8b 45 08             	mov    0x8(%ebp),%eax
c0102180:	89 04 24             	mov    %eax,(%esp)
c0102183:	e8 97 fc ff ff       	call   c0101e1f <trap_dispatch>
}
c0102188:	90                   	nop
c0102189:	c9                   	leave  
c010218a:	c3                   	ret    

c010218b <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010218b:	6a 00                	push   $0x0
  pushl $0
c010218d:	6a 00                	push   $0x0
  jmp __alltraps
c010218f:	e9 69 0a 00 00       	jmp    c0102bfd <__alltraps>

c0102194 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102194:	6a 00                	push   $0x0
  pushl $1
c0102196:	6a 01                	push   $0x1
  jmp __alltraps
c0102198:	e9 60 0a 00 00       	jmp    c0102bfd <__alltraps>

c010219d <vector2>:
.globl vector2
vector2:
  pushl $0
c010219d:	6a 00                	push   $0x0
  pushl $2
c010219f:	6a 02                	push   $0x2
  jmp __alltraps
c01021a1:	e9 57 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021a6 <vector3>:
.globl vector3
vector3:
  pushl $0
c01021a6:	6a 00                	push   $0x0
  pushl $3
c01021a8:	6a 03                	push   $0x3
  jmp __alltraps
c01021aa:	e9 4e 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021af <vector4>:
.globl vector4
vector4:
  pushl $0
c01021af:	6a 00                	push   $0x0
  pushl $4
c01021b1:	6a 04                	push   $0x4
  jmp __alltraps
c01021b3:	e9 45 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021b8 <vector5>:
.globl vector5
vector5:
  pushl $0
c01021b8:	6a 00                	push   $0x0
  pushl $5
c01021ba:	6a 05                	push   $0x5
  jmp __alltraps
c01021bc:	e9 3c 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021c1 <vector6>:
.globl vector6
vector6:
  pushl $0
c01021c1:	6a 00                	push   $0x0
  pushl $6
c01021c3:	6a 06                	push   $0x6
  jmp __alltraps
c01021c5:	e9 33 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021ca <vector7>:
.globl vector7
vector7:
  pushl $0
c01021ca:	6a 00                	push   $0x0
  pushl $7
c01021cc:	6a 07                	push   $0x7
  jmp __alltraps
c01021ce:	e9 2a 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021d3 <vector8>:
.globl vector8
vector8:
  pushl $8
c01021d3:	6a 08                	push   $0x8
  jmp __alltraps
c01021d5:	e9 23 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021da <vector9>:
.globl vector9
vector9:
  pushl $0
c01021da:	6a 00                	push   $0x0
  pushl $9
c01021dc:	6a 09                	push   $0x9
  jmp __alltraps
c01021de:	e9 1a 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021e3 <vector10>:
.globl vector10
vector10:
  pushl $10
c01021e3:	6a 0a                	push   $0xa
  jmp __alltraps
c01021e5:	e9 13 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021ea <vector11>:
.globl vector11
vector11:
  pushl $11
c01021ea:	6a 0b                	push   $0xb
  jmp __alltraps
c01021ec:	e9 0c 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021f1 <vector12>:
.globl vector12
vector12:
  pushl $12
c01021f1:	6a 0c                	push   $0xc
  jmp __alltraps
c01021f3:	e9 05 0a 00 00       	jmp    c0102bfd <__alltraps>

c01021f8 <vector13>:
.globl vector13
vector13:
  pushl $13
c01021f8:	6a 0d                	push   $0xd
  jmp __alltraps
c01021fa:	e9 fe 09 00 00       	jmp    c0102bfd <__alltraps>

c01021ff <vector14>:
.globl vector14
vector14:
  pushl $14
c01021ff:	6a 0e                	push   $0xe
  jmp __alltraps
c0102201:	e9 f7 09 00 00       	jmp    c0102bfd <__alltraps>

c0102206 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102206:	6a 00                	push   $0x0
  pushl $15
c0102208:	6a 0f                	push   $0xf
  jmp __alltraps
c010220a:	e9 ee 09 00 00       	jmp    c0102bfd <__alltraps>

c010220f <vector16>:
.globl vector16
vector16:
  pushl $0
c010220f:	6a 00                	push   $0x0
  pushl $16
c0102211:	6a 10                	push   $0x10
  jmp __alltraps
c0102213:	e9 e5 09 00 00       	jmp    c0102bfd <__alltraps>

c0102218 <vector17>:
.globl vector17
vector17:
  pushl $17
c0102218:	6a 11                	push   $0x11
  jmp __alltraps
c010221a:	e9 de 09 00 00       	jmp    c0102bfd <__alltraps>

c010221f <vector18>:
.globl vector18
vector18:
  pushl $0
c010221f:	6a 00                	push   $0x0
  pushl $18
c0102221:	6a 12                	push   $0x12
  jmp __alltraps
c0102223:	e9 d5 09 00 00       	jmp    c0102bfd <__alltraps>

c0102228 <vector19>:
.globl vector19
vector19:
  pushl $0
c0102228:	6a 00                	push   $0x0
  pushl $19
c010222a:	6a 13                	push   $0x13
  jmp __alltraps
c010222c:	e9 cc 09 00 00       	jmp    c0102bfd <__alltraps>

c0102231 <vector20>:
.globl vector20
vector20:
  pushl $0
c0102231:	6a 00                	push   $0x0
  pushl $20
c0102233:	6a 14                	push   $0x14
  jmp __alltraps
c0102235:	e9 c3 09 00 00       	jmp    c0102bfd <__alltraps>

c010223a <vector21>:
.globl vector21
vector21:
  pushl $0
c010223a:	6a 00                	push   $0x0
  pushl $21
c010223c:	6a 15                	push   $0x15
  jmp __alltraps
c010223e:	e9 ba 09 00 00       	jmp    c0102bfd <__alltraps>

c0102243 <vector22>:
.globl vector22
vector22:
  pushl $0
c0102243:	6a 00                	push   $0x0
  pushl $22
c0102245:	6a 16                	push   $0x16
  jmp __alltraps
c0102247:	e9 b1 09 00 00       	jmp    c0102bfd <__alltraps>

c010224c <vector23>:
.globl vector23
vector23:
  pushl $0
c010224c:	6a 00                	push   $0x0
  pushl $23
c010224e:	6a 17                	push   $0x17
  jmp __alltraps
c0102250:	e9 a8 09 00 00       	jmp    c0102bfd <__alltraps>

c0102255 <vector24>:
.globl vector24
vector24:
  pushl $0
c0102255:	6a 00                	push   $0x0
  pushl $24
c0102257:	6a 18                	push   $0x18
  jmp __alltraps
c0102259:	e9 9f 09 00 00       	jmp    c0102bfd <__alltraps>

c010225e <vector25>:
.globl vector25
vector25:
  pushl $0
c010225e:	6a 00                	push   $0x0
  pushl $25
c0102260:	6a 19                	push   $0x19
  jmp __alltraps
c0102262:	e9 96 09 00 00       	jmp    c0102bfd <__alltraps>

c0102267 <vector26>:
.globl vector26
vector26:
  pushl $0
c0102267:	6a 00                	push   $0x0
  pushl $26
c0102269:	6a 1a                	push   $0x1a
  jmp __alltraps
c010226b:	e9 8d 09 00 00       	jmp    c0102bfd <__alltraps>

c0102270 <vector27>:
.globl vector27
vector27:
  pushl $0
c0102270:	6a 00                	push   $0x0
  pushl $27
c0102272:	6a 1b                	push   $0x1b
  jmp __alltraps
c0102274:	e9 84 09 00 00       	jmp    c0102bfd <__alltraps>

c0102279 <vector28>:
.globl vector28
vector28:
  pushl $0
c0102279:	6a 00                	push   $0x0
  pushl $28
c010227b:	6a 1c                	push   $0x1c
  jmp __alltraps
c010227d:	e9 7b 09 00 00       	jmp    c0102bfd <__alltraps>

c0102282 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102282:	6a 00                	push   $0x0
  pushl $29
c0102284:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102286:	e9 72 09 00 00       	jmp    c0102bfd <__alltraps>

c010228b <vector30>:
.globl vector30
vector30:
  pushl $0
c010228b:	6a 00                	push   $0x0
  pushl $30
c010228d:	6a 1e                	push   $0x1e
  jmp __alltraps
c010228f:	e9 69 09 00 00       	jmp    c0102bfd <__alltraps>

c0102294 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102294:	6a 00                	push   $0x0
  pushl $31
c0102296:	6a 1f                	push   $0x1f
  jmp __alltraps
c0102298:	e9 60 09 00 00       	jmp    c0102bfd <__alltraps>

c010229d <vector32>:
.globl vector32
vector32:
  pushl $0
c010229d:	6a 00                	push   $0x0
  pushl $32
c010229f:	6a 20                	push   $0x20
  jmp __alltraps
c01022a1:	e9 57 09 00 00       	jmp    c0102bfd <__alltraps>

c01022a6 <vector33>:
.globl vector33
vector33:
  pushl $0
c01022a6:	6a 00                	push   $0x0
  pushl $33
c01022a8:	6a 21                	push   $0x21
  jmp __alltraps
c01022aa:	e9 4e 09 00 00       	jmp    c0102bfd <__alltraps>

c01022af <vector34>:
.globl vector34
vector34:
  pushl $0
c01022af:	6a 00                	push   $0x0
  pushl $34
c01022b1:	6a 22                	push   $0x22
  jmp __alltraps
c01022b3:	e9 45 09 00 00       	jmp    c0102bfd <__alltraps>

c01022b8 <vector35>:
.globl vector35
vector35:
  pushl $0
c01022b8:	6a 00                	push   $0x0
  pushl $35
c01022ba:	6a 23                	push   $0x23
  jmp __alltraps
c01022bc:	e9 3c 09 00 00       	jmp    c0102bfd <__alltraps>

c01022c1 <vector36>:
.globl vector36
vector36:
  pushl $0
c01022c1:	6a 00                	push   $0x0
  pushl $36
c01022c3:	6a 24                	push   $0x24
  jmp __alltraps
c01022c5:	e9 33 09 00 00       	jmp    c0102bfd <__alltraps>

c01022ca <vector37>:
.globl vector37
vector37:
  pushl $0
c01022ca:	6a 00                	push   $0x0
  pushl $37
c01022cc:	6a 25                	push   $0x25
  jmp __alltraps
c01022ce:	e9 2a 09 00 00       	jmp    c0102bfd <__alltraps>

c01022d3 <vector38>:
.globl vector38
vector38:
  pushl $0
c01022d3:	6a 00                	push   $0x0
  pushl $38
c01022d5:	6a 26                	push   $0x26
  jmp __alltraps
c01022d7:	e9 21 09 00 00       	jmp    c0102bfd <__alltraps>

c01022dc <vector39>:
.globl vector39
vector39:
  pushl $0
c01022dc:	6a 00                	push   $0x0
  pushl $39
c01022de:	6a 27                	push   $0x27
  jmp __alltraps
c01022e0:	e9 18 09 00 00       	jmp    c0102bfd <__alltraps>

c01022e5 <vector40>:
.globl vector40
vector40:
  pushl $0
c01022e5:	6a 00                	push   $0x0
  pushl $40
c01022e7:	6a 28                	push   $0x28
  jmp __alltraps
c01022e9:	e9 0f 09 00 00       	jmp    c0102bfd <__alltraps>

c01022ee <vector41>:
.globl vector41
vector41:
  pushl $0
c01022ee:	6a 00                	push   $0x0
  pushl $41
c01022f0:	6a 29                	push   $0x29
  jmp __alltraps
c01022f2:	e9 06 09 00 00       	jmp    c0102bfd <__alltraps>

c01022f7 <vector42>:
.globl vector42
vector42:
  pushl $0
c01022f7:	6a 00                	push   $0x0
  pushl $42
c01022f9:	6a 2a                	push   $0x2a
  jmp __alltraps
c01022fb:	e9 fd 08 00 00       	jmp    c0102bfd <__alltraps>

c0102300 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102300:	6a 00                	push   $0x0
  pushl $43
c0102302:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102304:	e9 f4 08 00 00       	jmp    c0102bfd <__alltraps>

c0102309 <vector44>:
.globl vector44
vector44:
  pushl $0
c0102309:	6a 00                	push   $0x0
  pushl $44
c010230b:	6a 2c                	push   $0x2c
  jmp __alltraps
c010230d:	e9 eb 08 00 00       	jmp    c0102bfd <__alltraps>

c0102312 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102312:	6a 00                	push   $0x0
  pushl $45
c0102314:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102316:	e9 e2 08 00 00       	jmp    c0102bfd <__alltraps>

c010231b <vector46>:
.globl vector46
vector46:
  pushl $0
c010231b:	6a 00                	push   $0x0
  pushl $46
c010231d:	6a 2e                	push   $0x2e
  jmp __alltraps
c010231f:	e9 d9 08 00 00       	jmp    c0102bfd <__alltraps>

c0102324 <vector47>:
.globl vector47
vector47:
  pushl $0
c0102324:	6a 00                	push   $0x0
  pushl $47
c0102326:	6a 2f                	push   $0x2f
  jmp __alltraps
c0102328:	e9 d0 08 00 00       	jmp    c0102bfd <__alltraps>

c010232d <vector48>:
.globl vector48
vector48:
  pushl $0
c010232d:	6a 00                	push   $0x0
  pushl $48
c010232f:	6a 30                	push   $0x30
  jmp __alltraps
c0102331:	e9 c7 08 00 00       	jmp    c0102bfd <__alltraps>

c0102336 <vector49>:
.globl vector49
vector49:
  pushl $0
c0102336:	6a 00                	push   $0x0
  pushl $49
c0102338:	6a 31                	push   $0x31
  jmp __alltraps
c010233a:	e9 be 08 00 00       	jmp    c0102bfd <__alltraps>

c010233f <vector50>:
.globl vector50
vector50:
  pushl $0
c010233f:	6a 00                	push   $0x0
  pushl $50
c0102341:	6a 32                	push   $0x32
  jmp __alltraps
c0102343:	e9 b5 08 00 00       	jmp    c0102bfd <__alltraps>

c0102348 <vector51>:
.globl vector51
vector51:
  pushl $0
c0102348:	6a 00                	push   $0x0
  pushl $51
c010234a:	6a 33                	push   $0x33
  jmp __alltraps
c010234c:	e9 ac 08 00 00       	jmp    c0102bfd <__alltraps>

c0102351 <vector52>:
.globl vector52
vector52:
  pushl $0
c0102351:	6a 00                	push   $0x0
  pushl $52
c0102353:	6a 34                	push   $0x34
  jmp __alltraps
c0102355:	e9 a3 08 00 00       	jmp    c0102bfd <__alltraps>

c010235a <vector53>:
.globl vector53
vector53:
  pushl $0
c010235a:	6a 00                	push   $0x0
  pushl $53
c010235c:	6a 35                	push   $0x35
  jmp __alltraps
c010235e:	e9 9a 08 00 00       	jmp    c0102bfd <__alltraps>

c0102363 <vector54>:
.globl vector54
vector54:
  pushl $0
c0102363:	6a 00                	push   $0x0
  pushl $54
c0102365:	6a 36                	push   $0x36
  jmp __alltraps
c0102367:	e9 91 08 00 00       	jmp    c0102bfd <__alltraps>

c010236c <vector55>:
.globl vector55
vector55:
  pushl $0
c010236c:	6a 00                	push   $0x0
  pushl $55
c010236e:	6a 37                	push   $0x37
  jmp __alltraps
c0102370:	e9 88 08 00 00       	jmp    c0102bfd <__alltraps>

c0102375 <vector56>:
.globl vector56
vector56:
  pushl $0
c0102375:	6a 00                	push   $0x0
  pushl $56
c0102377:	6a 38                	push   $0x38
  jmp __alltraps
c0102379:	e9 7f 08 00 00       	jmp    c0102bfd <__alltraps>

c010237e <vector57>:
.globl vector57
vector57:
  pushl $0
c010237e:	6a 00                	push   $0x0
  pushl $57
c0102380:	6a 39                	push   $0x39
  jmp __alltraps
c0102382:	e9 76 08 00 00       	jmp    c0102bfd <__alltraps>

c0102387 <vector58>:
.globl vector58
vector58:
  pushl $0
c0102387:	6a 00                	push   $0x0
  pushl $58
c0102389:	6a 3a                	push   $0x3a
  jmp __alltraps
c010238b:	e9 6d 08 00 00       	jmp    c0102bfd <__alltraps>

c0102390 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102390:	6a 00                	push   $0x0
  pushl $59
c0102392:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102394:	e9 64 08 00 00       	jmp    c0102bfd <__alltraps>

c0102399 <vector60>:
.globl vector60
vector60:
  pushl $0
c0102399:	6a 00                	push   $0x0
  pushl $60
c010239b:	6a 3c                	push   $0x3c
  jmp __alltraps
c010239d:	e9 5b 08 00 00       	jmp    c0102bfd <__alltraps>

c01023a2 <vector61>:
.globl vector61
vector61:
  pushl $0
c01023a2:	6a 00                	push   $0x0
  pushl $61
c01023a4:	6a 3d                	push   $0x3d
  jmp __alltraps
c01023a6:	e9 52 08 00 00       	jmp    c0102bfd <__alltraps>

c01023ab <vector62>:
.globl vector62
vector62:
  pushl $0
c01023ab:	6a 00                	push   $0x0
  pushl $62
c01023ad:	6a 3e                	push   $0x3e
  jmp __alltraps
c01023af:	e9 49 08 00 00       	jmp    c0102bfd <__alltraps>

c01023b4 <vector63>:
.globl vector63
vector63:
  pushl $0
c01023b4:	6a 00                	push   $0x0
  pushl $63
c01023b6:	6a 3f                	push   $0x3f
  jmp __alltraps
c01023b8:	e9 40 08 00 00       	jmp    c0102bfd <__alltraps>

c01023bd <vector64>:
.globl vector64
vector64:
  pushl $0
c01023bd:	6a 00                	push   $0x0
  pushl $64
c01023bf:	6a 40                	push   $0x40
  jmp __alltraps
c01023c1:	e9 37 08 00 00       	jmp    c0102bfd <__alltraps>

c01023c6 <vector65>:
.globl vector65
vector65:
  pushl $0
c01023c6:	6a 00                	push   $0x0
  pushl $65
c01023c8:	6a 41                	push   $0x41
  jmp __alltraps
c01023ca:	e9 2e 08 00 00       	jmp    c0102bfd <__alltraps>

c01023cf <vector66>:
.globl vector66
vector66:
  pushl $0
c01023cf:	6a 00                	push   $0x0
  pushl $66
c01023d1:	6a 42                	push   $0x42
  jmp __alltraps
c01023d3:	e9 25 08 00 00       	jmp    c0102bfd <__alltraps>

c01023d8 <vector67>:
.globl vector67
vector67:
  pushl $0
c01023d8:	6a 00                	push   $0x0
  pushl $67
c01023da:	6a 43                	push   $0x43
  jmp __alltraps
c01023dc:	e9 1c 08 00 00       	jmp    c0102bfd <__alltraps>

c01023e1 <vector68>:
.globl vector68
vector68:
  pushl $0
c01023e1:	6a 00                	push   $0x0
  pushl $68
c01023e3:	6a 44                	push   $0x44
  jmp __alltraps
c01023e5:	e9 13 08 00 00       	jmp    c0102bfd <__alltraps>

c01023ea <vector69>:
.globl vector69
vector69:
  pushl $0
c01023ea:	6a 00                	push   $0x0
  pushl $69
c01023ec:	6a 45                	push   $0x45
  jmp __alltraps
c01023ee:	e9 0a 08 00 00       	jmp    c0102bfd <__alltraps>

c01023f3 <vector70>:
.globl vector70
vector70:
  pushl $0
c01023f3:	6a 00                	push   $0x0
  pushl $70
c01023f5:	6a 46                	push   $0x46
  jmp __alltraps
c01023f7:	e9 01 08 00 00       	jmp    c0102bfd <__alltraps>

c01023fc <vector71>:
.globl vector71
vector71:
  pushl $0
c01023fc:	6a 00                	push   $0x0
  pushl $71
c01023fe:	6a 47                	push   $0x47
  jmp __alltraps
c0102400:	e9 f8 07 00 00       	jmp    c0102bfd <__alltraps>

c0102405 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102405:	6a 00                	push   $0x0
  pushl $72
c0102407:	6a 48                	push   $0x48
  jmp __alltraps
c0102409:	e9 ef 07 00 00       	jmp    c0102bfd <__alltraps>

c010240e <vector73>:
.globl vector73
vector73:
  pushl $0
c010240e:	6a 00                	push   $0x0
  pushl $73
c0102410:	6a 49                	push   $0x49
  jmp __alltraps
c0102412:	e9 e6 07 00 00       	jmp    c0102bfd <__alltraps>

c0102417 <vector74>:
.globl vector74
vector74:
  pushl $0
c0102417:	6a 00                	push   $0x0
  pushl $74
c0102419:	6a 4a                	push   $0x4a
  jmp __alltraps
c010241b:	e9 dd 07 00 00       	jmp    c0102bfd <__alltraps>

c0102420 <vector75>:
.globl vector75
vector75:
  pushl $0
c0102420:	6a 00                	push   $0x0
  pushl $75
c0102422:	6a 4b                	push   $0x4b
  jmp __alltraps
c0102424:	e9 d4 07 00 00       	jmp    c0102bfd <__alltraps>

c0102429 <vector76>:
.globl vector76
vector76:
  pushl $0
c0102429:	6a 00                	push   $0x0
  pushl $76
c010242b:	6a 4c                	push   $0x4c
  jmp __alltraps
c010242d:	e9 cb 07 00 00       	jmp    c0102bfd <__alltraps>

c0102432 <vector77>:
.globl vector77
vector77:
  pushl $0
c0102432:	6a 00                	push   $0x0
  pushl $77
c0102434:	6a 4d                	push   $0x4d
  jmp __alltraps
c0102436:	e9 c2 07 00 00       	jmp    c0102bfd <__alltraps>

c010243b <vector78>:
.globl vector78
vector78:
  pushl $0
c010243b:	6a 00                	push   $0x0
  pushl $78
c010243d:	6a 4e                	push   $0x4e
  jmp __alltraps
c010243f:	e9 b9 07 00 00       	jmp    c0102bfd <__alltraps>

c0102444 <vector79>:
.globl vector79
vector79:
  pushl $0
c0102444:	6a 00                	push   $0x0
  pushl $79
c0102446:	6a 4f                	push   $0x4f
  jmp __alltraps
c0102448:	e9 b0 07 00 00       	jmp    c0102bfd <__alltraps>

c010244d <vector80>:
.globl vector80
vector80:
  pushl $0
c010244d:	6a 00                	push   $0x0
  pushl $80
c010244f:	6a 50                	push   $0x50
  jmp __alltraps
c0102451:	e9 a7 07 00 00       	jmp    c0102bfd <__alltraps>

c0102456 <vector81>:
.globl vector81
vector81:
  pushl $0
c0102456:	6a 00                	push   $0x0
  pushl $81
c0102458:	6a 51                	push   $0x51
  jmp __alltraps
c010245a:	e9 9e 07 00 00       	jmp    c0102bfd <__alltraps>

c010245f <vector82>:
.globl vector82
vector82:
  pushl $0
c010245f:	6a 00                	push   $0x0
  pushl $82
c0102461:	6a 52                	push   $0x52
  jmp __alltraps
c0102463:	e9 95 07 00 00       	jmp    c0102bfd <__alltraps>

c0102468 <vector83>:
.globl vector83
vector83:
  pushl $0
c0102468:	6a 00                	push   $0x0
  pushl $83
c010246a:	6a 53                	push   $0x53
  jmp __alltraps
c010246c:	e9 8c 07 00 00       	jmp    c0102bfd <__alltraps>

c0102471 <vector84>:
.globl vector84
vector84:
  pushl $0
c0102471:	6a 00                	push   $0x0
  pushl $84
c0102473:	6a 54                	push   $0x54
  jmp __alltraps
c0102475:	e9 83 07 00 00       	jmp    c0102bfd <__alltraps>

c010247a <vector85>:
.globl vector85
vector85:
  pushl $0
c010247a:	6a 00                	push   $0x0
  pushl $85
c010247c:	6a 55                	push   $0x55
  jmp __alltraps
c010247e:	e9 7a 07 00 00       	jmp    c0102bfd <__alltraps>

c0102483 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102483:	6a 00                	push   $0x0
  pushl $86
c0102485:	6a 56                	push   $0x56
  jmp __alltraps
c0102487:	e9 71 07 00 00       	jmp    c0102bfd <__alltraps>

c010248c <vector87>:
.globl vector87
vector87:
  pushl $0
c010248c:	6a 00                	push   $0x0
  pushl $87
c010248e:	6a 57                	push   $0x57
  jmp __alltraps
c0102490:	e9 68 07 00 00       	jmp    c0102bfd <__alltraps>

c0102495 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102495:	6a 00                	push   $0x0
  pushl $88
c0102497:	6a 58                	push   $0x58
  jmp __alltraps
c0102499:	e9 5f 07 00 00       	jmp    c0102bfd <__alltraps>

c010249e <vector89>:
.globl vector89
vector89:
  pushl $0
c010249e:	6a 00                	push   $0x0
  pushl $89
c01024a0:	6a 59                	push   $0x59
  jmp __alltraps
c01024a2:	e9 56 07 00 00       	jmp    c0102bfd <__alltraps>

c01024a7 <vector90>:
.globl vector90
vector90:
  pushl $0
c01024a7:	6a 00                	push   $0x0
  pushl $90
c01024a9:	6a 5a                	push   $0x5a
  jmp __alltraps
c01024ab:	e9 4d 07 00 00       	jmp    c0102bfd <__alltraps>

c01024b0 <vector91>:
.globl vector91
vector91:
  pushl $0
c01024b0:	6a 00                	push   $0x0
  pushl $91
c01024b2:	6a 5b                	push   $0x5b
  jmp __alltraps
c01024b4:	e9 44 07 00 00       	jmp    c0102bfd <__alltraps>

c01024b9 <vector92>:
.globl vector92
vector92:
  pushl $0
c01024b9:	6a 00                	push   $0x0
  pushl $92
c01024bb:	6a 5c                	push   $0x5c
  jmp __alltraps
c01024bd:	e9 3b 07 00 00       	jmp    c0102bfd <__alltraps>

c01024c2 <vector93>:
.globl vector93
vector93:
  pushl $0
c01024c2:	6a 00                	push   $0x0
  pushl $93
c01024c4:	6a 5d                	push   $0x5d
  jmp __alltraps
c01024c6:	e9 32 07 00 00       	jmp    c0102bfd <__alltraps>

c01024cb <vector94>:
.globl vector94
vector94:
  pushl $0
c01024cb:	6a 00                	push   $0x0
  pushl $94
c01024cd:	6a 5e                	push   $0x5e
  jmp __alltraps
c01024cf:	e9 29 07 00 00       	jmp    c0102bfd <__alltraps>

c01024d4 <vector95>:
.globl vector95
vector95:
  pushl $0
c01024d4:	6a 00                	push   $0x0
  pushl $95
c01024d6:	6a 5f                	push   $0x5f
  jmp __alltraps
c01024d8:	e9 20 07 00 00       	jmp    c0102bfd <__alltraps>

c01024dd <vector96>:
.globl vector96
vector96:
  pushl $0
c01024dd:	6a 00                	push   $0x0
  pushl $96
c01024df:	6a 60                	push   $0x60
  jmp __alltraps
c01024e1:	e9 17 07 00 00       	jmp    c0102bfd <__alltraps>

c01024e6 <vector97>:
.globl vector97
vector97:
  pushl $0
c01024e6:	6a 00                	push   $0x0
  pushl $97
c01024e8:	6a 61                	push   $0x61
  jmp __alltraps
c01024ea:	e9 0e 07 00 00       	jmp    c0102bfd <__alltraps>

c01024ef <vector98>:
.globl vector98
vector98:
  pushl $0
c01024ef:	6a 00                	push   $0x0
  pushl $98
c01024f1:	6a 62                	push   $0x62
  jmp __alltraps
c01024f3:	e9 05 07 00 00       	jmp    c0102bfd <__alltraps>

c01024f8 <vector99>:
.globl vector99
vector99:
  pushl $0
c01024f8:	6a 00                	push   $0x0
  pushl $99
c01024fa:	6a 63                	push   $0x63
  jmp __alltraps
c01024fc:	e9 fc 06 00 00       	jmp    c0102bfd <__alltraps>

c0102501 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102501:	6a 00                	push   $0x0
  pushl $100
c0102503:	6a 64                	push   $0x64
  jmp __alltraps
c0102505:	e9 f3 06 00 00       	jmp    c0102bfd <__alltraps>

c010250a <vector101>:
.globl vector101
vector101:
  pushl $0
c010250a:	6a 00                	push   $0x0
  pushl $101
c010250c:	6a 65                	push   $0x65
  jmp __alltraps
c010250e:	e9 ea 06 00 00       	jmp    c0102bfd <__alltraps>

c0102513 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102513:	6a 00                	push   $0x0
  pushl $102
c0102515:	6a 66                	push   $0x66
  jmp __alltraps
c0102517:	e9 e1 06 00 00       	jmp    c0102bfd <__alltraps>

c010251c <vector103>:
.globl vector103
vector103:
  pushl $0
c010251c:	6a 00                	push   $0x0
  pushl $103
c010251e:	6a 67                	push   $0x67
  jmp __alltraps
c0102520:	e9 d8 06 00 00       	jmp    c0102bfd <__alltraps>

c0102525 <vector104>:
.globl vector104
vector104:
  pushl $0
c0102525:	6a 00                	push   $0x0
  pushl $104
c0102527:	6a 68                	push   $0x68
  jmp __alltraps
c0102529:	e9 cf 06 00 00       	jmp    c0102bfd <__alltraps>

c010252e <vector105>:
.globl vector105
vector105:
  pushl $0
c010252e:	6a 00                	push   $0x0
  pushl $105
c0102530:	6a 69                	push   $0x69
  jmp __alltraps
c0102532:	e9 c6 06 00 00       	jmp    c0102bfd <__alltraps>

c0102537 <vector106>:
.globl vector106
vector106:
  pushl $0
c0102537:	6a 00                	push   $0x0
  pushl $106
c0102539:	6a 6a                	push   $0x6a
  jmp __alltraps
c010253b:	e9 bd 06 00 00       	jmp    c0102bfd <__alltraps>

c0102540 <vector107>:
.globl vector107
vector107:
  pushl $0
c0102540:	6a 00                	push   $0x0
  pushl $107
c0102542:	6a 6b                	push   $0x6b
  jmp __alltraps
c0102544:	e9 b4 06 00 00       	jmp    c0102bfd <__alltraps>

c0102549 <vector108>:
.globl vector108
vector108:
  pushl $0
c0102549:	6a 00                	push   $0x0
  pushl $108
c010254b:	6a 6c                	push   $0x6c
  jmp __alltraps
c010254d:	e9 ab 06 00 00       	jmp    c0102bfd <__alltraps>

c0102552 <vector109>:
.globl vector109
vector109:
  pushl $0
c0102552:	6a 00                	push   $0x0
  pushl $109
c0102554:	6a 6d                	push   $0x6d
  jmp __alltraps
c0102556:	e9 a2 06 00 00       	jmp    c0102bfd <__alltraps>

c010255b <vector110>:
.globl vector110
vector110:
  pushl $0
c010255b:	6a 00                	push   $0x0
  pushl $110
c010255d:	6a 6e                	push   $0x6e
  jmp __alltraps
c010255f:	e9 99 06 00 00       	jmp    c0102bfd <__alltraps>

c0102564 <vector111>:
.globl vector111
vector111:
  pushl $0
c0102564:	6a 00                	push   $0x0
  pushl $111
c0102566:	6a 6f                	push   $0x6f
  jmp __alltraps
c0102568:	e9 90 06 00 00       	jmp    c0102bfd <__alltraps>

c010256d <vector112>:
.globl vector112
vector112:
  pushl $0
c010256d:	6a 00                	push   $0x0
  pushl $112
c010256f:	6a 70                	push   $0x70
  jmp __alltraps
c0102571:	e9 87 06 00 00       	jmp    c0102bfd <__alltraps>

c0102576 <vector113>:
.globl vector113
vector113:
  pushl $0
c0102576:	6a 00                	push   $0x0
  pushl $113
c0102578:	6a 71                	push   $0x71
  jmp __alltraps
c010257a:	e9 7e 06 00 00       	jmp    c0102bfd <__alltraps>

c010257f <vector114>:
.globl vector114
vector114:
  pushl $0
c010257f:	6a 00                	push   $0x0
  pushl $114
c0102581:	6a 72                	push   $0x72
  jmp __alltraps
c0102583:	e9 75 06 00 00       	jmp    c0102bfd <__alltraps>

c0102588 <vector115>:
.globl vector115
vector115:
  pushl $0
c0102588:	6a 00                	push   $0x0
  pushl $115
c010258a:	6a 73                	push   $0x73
  jmp __alltraps
c010258c:	e9 6c 06 00 00       	jmp    c0102bfd <__alltraps>

c0102591 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102591:	6a 00                	push   $0x0
  pushl $116
c0102593:	6a 74                	push   $0x74
  jmp __alltraps
c0102595:	e9 63 06 00 00       	jmp    c0102bfd <__alltraps>

c010259a <vector117>:
.globl vector117
vector117:
  pushl $0
c010259a:	6a 00                	push   $0x0
  pushl $117
c010259c:	6a 75                	push   $0x75
  jmp __alltraps
c010259e:	e9 5a 06 00 00       	jmp    c0102bfd <__alltraps>

c01025a3 <vector118>:
.globl vector118
vector118:
  pushl $0
c01025a3:	6a 00                	push   $0x0
  pushl $118
c01025a5:	6a 76                	push   $0x76
  jmp __alltraps
c01025a7:	e9 51 06 00 00       	jmp    c0102bfd <__alltraps>

c01025ac <vector119>:
.globl vector119
vector119:
  pushl $0
c01025ac:	6a 00                	push   $0x0
  pushl $119
c01025ae:	6a 77                	push   $0x77
  jmp __alltraps
c01025b0:	e9 48 06 00 00       	jmp    c0102bfd <__alltraps>

c01025b5 <vector120>:
.globl vector120
vector120:
  pushl $0
c01025b5:	6a 00                	push   $0x0
  pushl $120
c01025b7:	6a 78                	push   $0x78
  jmp __alltraps
c01025b9:	e9 3f 06 00 00       	jmp    c0102bfd <__alltraps>

c01025be <vector121>:
.globl vector121
vector121:
  pushl $0
c01025be:	6a 00                	push   $0x0
  pushl $121
c01025c0:	6a 79                	push   $0x79
  jmp __alltraps
c01025c2:	e9 36 06 00 00       	jmp    c0102bfd <__alltraps>

c01025c7 <vector122>:
.globl vector122
vector122:
  pushl $0
c01025c7:	6a 00                	push   $0x0
  pushl $122
c01025c9:	6a 7a                	push   $0x7a
  jmp __alltraps
c01025cb:	e9 2d 06 00 00       	jmp    c0102bfd <__alltraps>

c01025d0 <vector123>:
.globl vector123
vector123:
  pushl $0
c01025d0:	6a 00                	push   $0x0
  pushl $123
c01025d2:	6a 7b                	push   $0x7b
  jmp __alltraps
c01025d4:	e9 24 06 00 00       	jmp    c0102bfd <__alltraps>

c01025d9 <vector124>:
.globl vector124
vector124:
  pushl $0
c01025d9:	6a 00                	push   $0x0
  pushl $124
c01025db:	6a 7c                	push   $0x7c
  jmp __alltraps
c01025dd:	e9 1b 06 00 00       	jmp    c0102bfd <__alltraps>

c01025e2 <vector125>:
.globl vector125
vector125:
  pushl $0
c01025e2:	6a 00                	push   $0x0
  pushl $125
c01025e4:	6a 7d                	push   $0x7d
  jmp __alltraps
c01025e6:	e9 12 06 00 00       	jmp    c0102bfd <__alltraps>

c01025eb <vector126>:
.globl vector126
vector126:
  pushl $0
c01025eb:	6a 00                	push   $0x0
  pushl $126
c01025ed:	6a 7e                	push   $0x7e
  jmp __alltraps
c01025ef:	e9 09 06 00 00       	jmp    c0102bfd <__alltraps>

c01025f4 <vector127>:
.globl vector127
vector127:
  pushl $0
c01025f4:	6a 00                	push   $0x0
  pushl $127
c01025f6:	6a 7f                	push   $0x7f
  jmp __alltraps
c01025f8:	e9 00 06 00 00       	jmp    c0102bfd <__alltraps>

c01025fd <vector128>:
.globl vector128
vector128:
  pushl $0
c01025fd:	6a 00                	push   $0x0
  pushl $128
c01025ff:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102604:	e9 f4 05 00 00       	jmp    c0102bfd <__alltraps>

c0102609 <vector129>:
.globl vector129
vector129:
  pushl $0
c0102609:	6a 00                	push   $0x0
  pushl $129
c010260b:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102610:	e9 e8 05 00 00       	jmp    c0102bfd <__alltraps>

c0102615 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102615:	6a 00                	push   $0x0
  pushl $130
c0102617:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010261c:	e9 dc 05 00 00       	jmp    c0102bfd <__alltraps>

c0102621 <vector131>:
.globl vector131
vector131:
  pushl $0
c0102621:	6a 00                	push   $0x0
  pushl $131
c0102623:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c0102628:	e9 d0 05 00 00       	jmp    c0102bfd <__alltraps>

c010262d <vector132>:
.globl vector132
vector132:
  pushl $0
c010262d:	6a 00                	push   $0x0
  pushl $132
c010262f:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c0102634:	e9 c4 05 00 00       	jmp    c0102bfd <__alltraps>

c0102639 <vector133>:
.globl vector133
vector133:
  pushl $0
c0102639:	6a 00                	push   $0x0
  pushl $133
c010263b:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c0102640:	e9 b8 05 00 00       	jmp    c0102bfd <__alltraps>

c0102645 <vector134>:
.globl vector134
vector134:
  pushl $0
c0102645:	6a 00                	push   $0x0
  pushl $134
c0102647:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c010264c:	e9 ac 05 00 00       	jmp    c0102bfd <__alltraps>

c0102651 <vector135>:
.globl vector135
vector135:
  pushl $0
c0102651:	6a 00                	push   $0x0
  pushl $135
c0102653:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c0102658:	e9 a0 05 00 00       	jmp    c0102bfd <__alltraps>

c010265d <vector136>:
.globl vector136
vector136:
  pushl $0
c010265d:	6a 00                	push   $0x0
  pushl $136
c010265f:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c0102664:	e9 94 05 00 00       	jmp    c0102bfd <__alltraps>

c0102669 <vector137>:
.globl vector137
vector137:
  pushl $0
c0102669:	6a 00                	push   $0x0
  pushl $137
c010266b:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c0102670:	e9 88 05 00 00       	jmp    c0102bfd <__alltraps>

c0102675 <vector138>:
.globl vector138
vector138:
  pushl $0
c0102675:	6a 00                	push   $0x0
  pushl $138
c0102677:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c010267c:	e9 7c 05 00 00       	jmp    c0102bfd <__alltraps>

c0102681 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102681:	6a 00                	push   $0x0
  pushl $139
c0102683:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c0102688:	e9 70 05 00 00       	jmp    c0102bfd <__alltraps>

c010268d <vector140>:
.globl vector140
vector140:
  pushl $0
c010268d:	6a 00                	push   $0x0
  pushl $140
c010268f:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102694:	e9 64 05 00 00       	jmp    c0102bfd <__alltraps>

c0102699 <vector141>:
.globl vector141
vector141:
  pushl $0
c0102699:	6a 00                	push   $0x0
  pushl $141
c010269b:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c01026a0:	e9 58 05 00 00       	jmp    c0102bfd <__alltraps>

c01026a5 <vector142>:
.globl vector142
vector142:
  pushl $0
c01026a5:	6a 00                	push   $0x0
  pushl $142
c01026a7:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c01026ac:	e9 4c 05 00 00       	jmp    c0102bfd <__alltraps>

c01026b1 <vector143>:
.globl vector143
vector143:
  pushl $0
c01026b1:	6a 00                	push   $0x0
  pushl $143
c01026b3:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c01026b8:	e9 40 05 00 00       	jmp    c0102bfd <__alltraps>

c01026bd <vector144>:
.globl vector144
vector144:
  pushl $0
c01026bd:	6a 00                	push   $0x0
  pushl $144
c01026bf:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c01026c4:	e9 34 05 00 00       	jmp    c0102bfd <__alltraps>

c01026c9 <vector145>:
.globl vector145
vector145:
  pushl $0
c01026c9:	6a 00                	push   $0x0
  pushl $145
c01026cb:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c01026d0:	e9 28 05 00 00       	jmp    c0102bfd <__alltraps>

c01026d5 <vector146>:
.globl vector146
vector146:
  pushl $0
c01026d5:	6a 00                	push   $0x0
  pushl $146
c01026d7:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c01026dc:	e9 1c 05 00 00       	jmp    c0102bfd <__alltraps>

c01026e1 <vector147>:
.globl vector147
vector147:
  pushl $0
c01026e1:	6a 00                	push   $0x0
  pushl $147
c01026e3:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c01026e8:	e9 10 05 00 00       	jmp    c0102bfd <__alltraps>

c01026ed <vector148>:
.globl vector148
vector148:
  pushl $0
c01026ed:	6a 00                	push   $0x0
  pushl $148
c01026ef:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c01026f4:	e9 04 05 00 00       	jmp    c0102bfd <__alltraps>

c01026f9 <vector149>:
.globl vector149
vector149:
  pushl $0
c01026f9:	6a 00                	push   $0x0
  pushl $149
c01026fb:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102700:	e9 f8 04 00 00       	jmp    c0102bfd <__alltraps>

c0102705 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102705:	6a 00                	push   $0x0
  pushl $150
c0102707:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010270c:	e9 ec 04 00 00       	jmp    c0102bfd <__alltraps>

c0102711 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102711:	6a 00                	push   $0x0
  pushl $151
c0102713:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c0102718:	e9 e0 04 00 00       	jmp    c0102bfd <__alltraps>

c010271d <vector152>:
.globl vector152
vector152:
  pushl $0
c010271d:	6a 00                	push   $0x0
  pushl $152
c010271f:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c0102724:	e9 d4 04 00 00       	jmp    c0102bfd <__alltraps>

c0102729 <vector153>:
.globl vector153
vector153:
  pushl $0
c0102729:	6a 00                	push   $0x0
  pushl $153
c010272b:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c0102730:	e9 c8 04 00 00       	jmp    c0102bfd <__alltraps>

c0102735 <vector154>:
.globl vector154
vector154:
  pushl $0
c0102735:	6a 00                	push   $0x0
  pushl $154
c0102737:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c010273c:	e9 bc 04 00 00       	jmp    c0102bfd <__alltraps>

c0102741 <vector155>:
.globl vector155
vector155:
  pushl $0
c0102741:	6a 00                	push   $0x0
  pushl $155
c0102743:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c0102748:	e9 b0 04 00 00       	jmp    c0102bfd <__alltraps>

c010274d <vector156>:
.globl vector156
vector156:
  pushl $0
c010274d:	6a 00                	push   $0x0
  pushl $156
c010274f:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c0102754:	e9 a4 04 00 00       	jmp    c0102bfd <__alltraps>

c0102759 <vector157>:
.globl vector157
vector157:
  pushl $0
c0102759:	6a 00                	push   $0x0
  pushl $157
c010275b:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c0102760:	e9 98 04 00 00       	jmp    c0102bfd <__alltraps>

c0102765 <vector158>:
.globl vector158
vector158:
  pushl $0
c0102765:	6a 00                	push   $0x0
  pushl $158
c0102767:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c010276c:	e9 8c 04 00 00       	jmp    c0102bfd <__alltraps>

c0102771 <vector159>:
.globl vector159
vector159:
  pushl $0
c0102771:	6a 00                	push   $0x0
  pushl $159
c0102773:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c0102778:	e9 80 04 00 00       	jmp    c0102bfd <__alltraps>

c010277d <vector160>:
.globl vector160
vector160:
  pushl $0
c010277d:	6a 00                	push   $0x0
  pushl $160
c010277f:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102784:	e9 74 04 00 00       	jmp    c0102bfd <__alltraps>

c0102789 <vector161>:
.globl vector161
vector161:
  pushl $0
c0102789:	6a 00                	push   $0x0
  pushl $161
c010278b:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102790:	e9 68 04 00 00       	jmp    c0102bfd <__alltraps>

c0102795 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102795:	6a 00                	push   $0x0
  pushl $162
c0102797:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010279c:	e9 5c 04 00 00       	jmp    c0102bfd <__alltraps>

c01027a1 <vector163>:
.globl vector163
vector163:
  pushl $0
c01027a1:	6a 00                	push   $0x0
  pushl $163
c01027a3:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c01027a8:	e9 50 04 00 00       	jmp    c0102bfd <__alltraps>

c01027ad <vector164>:
.globl vector164
vector164:
  pushl $0
c01027ad:	6a 00                	push   $0x0
  pushl $164
c01027af:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c01027b4:	e9 44 04 00 00       	jmp    c0102bfd <__alltraps>

c01027b9 <vector165>:
.globl vector165
vector165:
  pushl $0
c01027b9:	6a 00                	push   $0x0
  pushl $165
c01027bb:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c01027c0:	e9 38 04 00 00       	jmp    c0102bfd <__alltraps>

c01027c5 <vector166>:
.globl vector166
vector166:
  pushl $0
c01027c5:	6a 00                	push   $0x0
  pushl $166
c01027c7:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c01027cc:	e9 2c 04 00 00       	jmp    c0102bfd <__alltraps>

c01027d1 <vector167>:
.globl vector167
vector167:
  pushl $0
c01027d1:	6a 00                	push   $0x0
  pushl $167
c01027d3:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c01027d8:	e9 20 04 00 00       	jmp    c0102bfd <__alltraps>

c01027dd <vector168>:
.globl vector168
vector168:
  pushl $0
c01027dd:	6a 00                	push   $0x0
  pushl $168
c01027df:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c01027e4:	e9 14 04 00 00       	jmp    c0102bfd <__alltraps>

c01027e9 <vector169>:
.globl vector169
vector169:
  pushl $0
c01027e9:	6a 00                	push   $0x0
  pushl $169
c01027eb:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c01027f0:	e9 08 04 00 00       	jmp    c0102bfd <__alltraps>

c01027f5 <vector170>:
.globl vector170
vector170:
  pushl $0
c01027f5:	6a 00                	push   $0x0
  pushl $170
c01027f7:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c01027fc:	e9 fc 03 00 00       	jmp    c0102bfd <__alltraps>

c0102801 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102801:	6a 00                	push   $0x0
  pushl $171
c0102803:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c0102808:	e9 f0 03 00 00       	jmp    c0102bfd <__alltraps>

c010280d <vector172>:
.globl vector172
vector172:
  pushl $0
c010280d:	6a 00                	push   $0x0
  pushl $172
c010280f:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102814:	e9 e4 03 00 00       	jmp    c0102bfd <__alltraps>

c0102819 <vector173>:
.globl vector173
vector173:
  pushl $0
c0102819:	6a 00                	push   $0x0
  pushl $173
c010281b:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c0102820:	e9 d8 03 00 00       	jmp    c0102bfd <__alltraps>

c0102825 <vector174>:
.globl vector174
vector174:
  pushl $0
c0102825:	6a 00                	push   $0x0
  pushl $174
c0102827:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c010282c:	e9 cc 03 00 00       	jmp    c0102bfd <__alltraps>

c0102831 <vector175>:
.globl vector175
vector175:
  pushl $0
c0102831:	6a 00                	push   $0x0
  pushl $175
c0102833:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c0102838:	e9 c0 03 00 00       	jmp    c0102bfd <__alltraps>

c010283d <vector176>:
.globl vector176
vector176:
  pushl $0
c010283d:	6a 00                	push   $0x0
  pushl $176
c010283f:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c0102844:	e9 b4 03 00 00       	jmp    c0102bfd <__alltraps>

c0102849 <vector177>:
.globl vector177
vector177:
  pushl $0
c0102849:	6a 00                	push   $0x0
  pushl $177
c010284b:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c0102850:	e9 a8 03 00 00       	jmp    c0102bfd <__alltraps>

c0102855 <vector178>:
.globl vector178
vector178:
  pushl $0
c0102855:	6a 00                	push   $0x0
  pushl $178
c0102857:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c010285c:	e9 9c 03 00 00       	jmp    c0102bfd <__alltraps>

c0102861 <vector179>:
.globl vector179
vector179:
  pushl $0
c0102861:	6a 00                	push   $0x0
  pushl $179
c0102863:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c0102868:	e9 90 03 00 00       	jmp    c0102bfd <__alltraps>

c010286d <vector180>:
.globl vector180
vector180:
  pushl $0
c010286d:	6a 00                	push   $0x0
  pushl $180
c010286f:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c0102874:	e9 84 03 00 00       	jmp    c0102bfd <__alltraps>

c0102879 <vector181>:
.globl vector181
vector181:
  pushl $0
c0102879:	6a 00                	push   $0x0
  pushl $181
c010287b:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102880:	e9 78 03 00 00       	jmp    c0102bfd <__alltraps>

c0102885 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102885:	6a 00                	push   $0x0
  pushl $182
c0102887:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010288c:	e9 6c 03 00 00       	jmp    c0102bfd <__alltraps>

c0102891 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102891:	6a 00                	push   $0x0
  pushl $183
c0102893:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c0102898:	e9 60 03 00 00       	jmp    c0102bfd <__alltraps>

c010289d <vector184>:
.globl vector184
vector184:
  pushl $0
c010289d:	6a 00                	push   $0x0
  pushl $184
c010289f:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c01028a4:	e9 54 03 00 00       	jmp    c0102bfd <__alltraps>

c01028a9 <vector185>:
.globl vector185
vector185:
  pushl $0
c01028a9:	6a 00                	push   $0x0
  pushl $185
c01028ab:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c01028b0:	e9 48 03 00 00       	jmp    c0102bfd <__alltraps>

c01028b5 <vector186>:
.globl vector186
vector186:
  pushl $0
c01028b5:	6a 00                	push   $0x0
  pushl $186
c01028b7:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c01028bc:	e9 3c 03 00 00       	jmp    c0102bfd <__alltraps>

c01028c1 <vector187>:
.globl vector187
vector187:
  pushl $0
c01028c1:	6a 00                	push   $0x0
  pushl $187
c01028c3:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c01028c8:	e9 30 03 00 00       	jmp    c0102bfd <__alltraps>

c01028cd <vector188>:
.globl vector188
vector188:
  pushl $0
c01028cd:	6a 00                	push   $0x0
  pushl $188
c01028cf:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c01028d4:	e9 24 03 00 00       	jmp    c0102bfd <__alltraps>

c01028d9 <vector189>:
.globl vector189
vector189:
  pushl $0
c01028d9:	6a 00                	push   $0x0
  pushl $189
c01028db:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c01028e0:	e9 18 03 00 00       	jmp    c0102bfd <__alltraps>

c01028e5 <vector190>:
.globl vector190
vector190:
  pushl $0
c01028e5:	6a 00                	push   $0x0
  pushl $190
c01028e7:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c01028ec:	e9 0c 03 00 00       	jmp    c0102bfd <__alltraps>

c01028f1 <vector191>:
.globl vector191
vector191:
  pushl $0
c01028f1:	6a 00                	push   $0x0
  pushl $191
c01028f3:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c01028f8:	e9 00 03 00 00       	jmp    c0102bfd <__alltraps>

c01028fd <vector192>:
.globl vector192
vector192:
  pushl $0
c01028fd:	6a 00                	push   $0x0
  pushl $192
c01028ff:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102904:	e9 f4 02 00 00       	jmp    c0102bfd <__alltraps>

c0102909 <vector193>:
.globl vector193
vector193:
  pushl $0
c0102909:	6a 00                	push   $0x0
  pushl $193
c010290b:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102910:	e9 e8 02 00 00       	jmp    c0102bfd <__alltraps>

c0102915 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102915:	6a 00                	push   $0x0
  pushl $194
c0102917:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010291c:	e9 dc 02 00 00       	jmp    c0102bfd <__alltraps>

c0102921 <vector195>:
.globl vector195
vector195:
  pushl $0
c0102921:	6a 00                	push   $0x0
  pushl $195
c0102923:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c0102928:	e9 d0 02 00 00       	jmp    c0102bfd <__alltraps>

c010292d <vector196>:
.globl vector196
vector196:
  pushl $0
c010292d:	6a 00                	push   $0x0
  pushl $196
c010292f:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c0102934:	e9 c4 02 00 00       	jmp    c0102bfd <__alltraps>

c0102939 <vector197>:
.globl vector197
vector197:
  pushl $0
c0102939:	6a 00                	push   $0x0
  pushl $197
c010293b:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c0102940:	e9 b8 02 00 00       	jmp    c0102bfd <__alltraps>

c0102945 <vector198>:
.globl vector198
vector198:
  pushl $0
c0102945:	6a 00                	push   $0x0
  pushl $198
c0102947:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c010294c:	e9 ac 02 00 00       	jmp    c0102bfd <__alltraps>

c0102951 <vector199>:
.globl vector199
vector199:
  pushl $0
c0102951:	6a 00                	push   $0x0
  pushl $199
c0102953:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c0102958:	e9 a0 02 00 00       	jmp    c0102bfd <__alltraps>

c010295d <vector200>:
.globl vector200
vector200:
  pushl $0
c010295d:	6a 00                	push   $0x0
  pushl $200
c010295f:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c0102964:	e9 94 02 00 00       	jmp    c0102bfd <__alltraps>

c0102969 <vector201>:
.globl vector201
vector201:
  pushl $0
c0102969:	6a 00                	push   $0x0
  pushl $201
c010296b:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c0102970:	e9 88 02 00 00       	jmp    c0102bfd <__alltraps>

c0102975 <vector202>:
.globl vector202
vector202:
  pushl $0
c0102975:	6a 00                	push   $0x0
  pushl $202
c0102977:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c010297c:	e9 7c 02 00 00       	jmp    c0102bfd <__alltraps>

c0102981 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102981:	6a 00                	push   $0x0
  pushl $203
c0102983:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c0102988:	e9 70 02 00 00       	jmp    c0102bfd <__alltraps>

c010298d <vector204>:
.globl vector204
vector204:
  pushl $0
c010298d:	6a 00                	push   $0x0
  pushl $204
c010298f:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102994:	e9 64 02 00 00       	jmp    c0102bfd <__alltraps>

c0102999 <vector205>:
.globl vector205
vector205:
  pushl $0
c0102999:	6a 00                	push   $0x0
  pushl $205
c010299b:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c01029a0:	e9 58 02 00 00       	jmp    c0102bfd <__alltraps>

c01029a5 <vector206>:
.globl vector206
vector206:
  pushl $0
c01029a5:	6a 00                	push   $0x0
  pushl $206
c01029a7:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c01029ac:	e9 4c 02 00 00       	jmp    c0102bfd <__alltraps>

c01029b1 <vector207>:
.globl vector207
vector207:
  pushl $0
c01029b1:	6a 00                	push   $0x0
  pushl $207
c01029b3:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c01029b8:	e9 40 02 00 00       	jmp    c0102bfd <__alltraps>

c01029bd <vector208>:
.globl vector208
vector208:
  pushl $0
c01029bd:	6a 00                	push   $0x0
  pushl $208
c01029bf:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c01029c4:	e9 34 02 00 00       	jmp    c0102bfd <__alltraps>

c01029c9 <vector209>:
.globl vector209
vector209:
  pushl $0
c01029c9:	6a 00                	push   $0x0
  pushl $209
c01029cb:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c01029d0:	e9 28 02 00 00       	jmp    c0102bfd <__alltraps>

c01029d5 <vector210>:
.globl vector210
vector210:
  pushl $0
c01029d5:	6a 00                	push   $0x0
  pushl $210
c01029d7:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c01029dc:	e9 1c 02 00 00       	jmp    c0102bfd <__alltraps>

c01029e1 <vector211>:
.globl vector211
vector211:
  pushl $0
c01029e1:	6a 00                	push   $0x0
  pushl $211
c01029e3:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c01029e8:	e9 10 02 00 00       	jmp    c0102bfd <__alltraps>

c01029ed <vector212>:
.globl vector212
vector212:
  pushl $0
c01029ed:	6a 00                	push   $0x0
  pushl $212
c01029ef:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c01029f4:	e9 04 02 00 00       	jmp    c0102bfd <__alltraps>

c01029f9 <vector213>:
.globl vector213
vector213:
  pushl $0
c01029f9:	6a 00                	push   $0x0
  pushl $213
c01029fb:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102a00:	e9 f8 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a05 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102a05:	6a 00                	push   $0x0
  pushl $214
c0102a07:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c0102a0c:	e9 ec 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a11 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102a11:	6a 00                	push   $0x0
  pushl $215
c0102a13:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c0102a18:	e9 e0 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a1d <vector216>:
.globl vector216
vector216:
  pushl $0
c0102a1d:	6a 00                	push   $0x0
  pushl $216
c0102a1f:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c0102a24:	e9 d4 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a29 <vector217>:
.globl vector217
vector217:
  pushl $0
c0102a29:	6a 00                	push   $0x0
  pushl $217
c0102a2b:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c0102a30:	e9 c8 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a35 <vector218>:
.globl vector218
vector218:
  pushl $0
c0102a35:	6a 00                	push   $0x0
  pushl $218
c0102a37:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c0102a3c:	e9 bc 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a41 <vector219>:
.globl vector219
vector219:
  pushl $0
c0102a41:	6a 00                	push   $0x0
  pushl $219
c0102a43:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c0102a48:	e9 b0 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a4d <vector220>:
.globl vector220
vector220:
  pushl $0
c0102a4d:	6a 00                	push   $0x0
  pushl $220
c0102a4f:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c0102a54:	e9 a4 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a59 <vector221>:
.globl vector221
vector221:
  pushl $0
c0102a59:	6a 00                	push   $0x0
  pushl $221
c0102a5b:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c0102a60:	e9 98 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a65 <vector222>:
.globl vector222
vector222:
  pushl $0
c0102a65:	6a 00                	push   $0x0
  pushl $222
c0102a67:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c0102a6c:	e9 8c 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a71 <vector223>:
.globl vector223
vector223:
  pushl $0
c0102a71:	6a 00                	push   $0x0
  pushl $223
c0102a73:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c0102a78:	e9 80 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a7d <vector224>:
.globl vector224
vector224:
  pushl $0
c0102a7d:	6a 00                	push   $0x0
  pushl $224
c0102a7f:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102a84:	e9 74 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a89 <vector225>:
.globl vector225
vector225:
  pushl $0
c0102a89:	6a 00                	push   $0x0
  pushl $225
c0102a8b:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102a90:	e9 68 01 00 00       	jmp    c0102bfd <__alltraps>

c0102a95 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102a95:	6a 00                	push   $0x0
  pushl $226
c0102a97:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c0102a9c:	e9 5c 01 00 00       	jmp    c0102bfd <__alltraps>

c0102aa1 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102aa1:	6a 00                	push   $0x0
  pushl $227
c0102aa3:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c0102aa8:	e9 50 01 00 00       	jmp    c0102bfd <__alltraps>

c0102aad <vector228>:
.globl vector228
vector228:
  pushl $0
c0102aad:	6a 00                	push   $0x0
  pushl $228
c0102aaf:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102ab4:	e9 44 01 00 00       	jmp    c0102bfd <__alltraps>

c0102ab9 <vector229>:
.globl vector229
vector229:
  pushl $0
c0102ab9:	6a 00                	push   $0x0
  pushl $229
c0102abb:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102ac0:	e9 38 01 00 00       	jmp    c0102bfd <__alltraps>

c0102ac5 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102ac5:	6a 00                	push   $0x0
  pushl $230
c0102ac7:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c0102acc:	e9 2c 01 00 00       	jmp    c0102bfd <__alltraps>

c0102ad1 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102ad1:	6a 00                	push   $0x0
  pushl $231
c0102ad3:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c0102ad8:	e9 20 01 00 00       	jmp    c0102bfd <__alltraps>

c0102add <vector232>:
.globl vector232
vector232:
  pushl $0
c0102add:	6a 00                	push   $0x0
  pushl $232
c0102adf:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102ae4:	e9 14 01 00 00       	jmp    c0102bfd <__alltraps>

c0102ae9 <vector233>:
.globl vector233
vector233:
  pushl $0
c0102ae9:	6a 00                	push   $0x0
  pushl $233
c0102aeb:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102af0:	e9 08 01 00 00       	jmp    c0102bfd <__alltraps>

c0102af5 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102af5:	6a 00                	push   $0x0
  pushl $234
c0102af7:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c0102afc:	e9 fc 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b01 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102b01:	6a 00                	push   $0x0
  pushl $235
c0102b03:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c0102b08:	e9 f0 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b0d <vector236>:
.globl vector236
vector236:
  pushl $0
c0102b0d:	6a 00                	push   $0x0
  pushl $236
c0102b0f:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102b14:	e9 e4 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b19 <vector237>:
.globl vector237
vector237:
  pushl $0
c0102b19:	6a 00                	push   $0x0
  pushl $237
c0102b1b:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c0102b20:	e9 d8 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b25 <vector238>:
.globl vector238
vector238:
  pushl $0
c0102b25:	6a 00                	push   $0x0
  pushl $238
c0102b27:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c0102b2c:	e9 cc 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b31 <vector239>:
.globl vector239
vector239:
  pushl $0
c0102b31:	6a 00                	push   $0x0
  pushl $239
c0102b33:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c0102b38:	e9 c0 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b3d <vector240>:
.globl vector240
vector240:
  pushl $0
c0102b3d:	6a 00                	push   $0x0
  pushl $240
c0102b3f:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c0102b44:	e9 b4 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b49 <vector241>:
.globl vector241
vector241:
  pushl $0
c0102b49:	6a 00                	push   $0x0
  pushl $241
c0102b4b:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c0102b50:	e9 a8 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b55 <vector242>:
.globl vector242
vector242:
  pushl $0
c0102b55:	6a 00                	push   $0x0
  pushl $242
c0102b57:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c0102b5c:	e9 9c 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b61 <vector243>:
.globl vector243
vector243:
  pushl $0
c0102b61:	6a 00                	push   $0x0
  pushl $243
c0102b63:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c0102b68:	e9 90 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b6d <vector244>:
.globl vector244
vector244:
  pushl $0
c0102b6d:	6a 00                	push   $0x0
  pushl $244
c0102b6f:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c0102b74:	e9 84 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b79 <vector245>:
.globl vector245
vector245:
  pushl $0
c0102b79:	6a 00                	push   $0x0
  pushl $245
c0102b7b:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102b80:	e9 78 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b85 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102b85:	6a 00                	push   $0x0
  pushl $246
c0102b87:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102b8c:	e9 6c 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b91 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102b91:	6a 00                	push   $0x0
  pushl $247
c0102b93:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102b98:	e9 60 00 00 00       	jmp    c0102bfd <__alltraps>

c0102b9d <vector248>:
.globl vector248
vector248:
  pushl $0
c0102b9d:	6a 00                	push   $0x0
  pushl $248
c0102b9f:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102ba4:	e9 54 00 00 00       	jmp    c0102bfd <__alltraps>

c0102ba9 <vector249>:
.globl vector249
vector249:
  pushl $0
c0102ba9:	6a 00                	push   $0x0
  pushl $249
c0102bab:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102bb0:	e9 48 00 00 00       	jmp    c0102bfd <__alltraps>

c0102bb5 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102bb5:	6a 00                	push   $0x0
  pushl $250
c0102bb7:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102bbc:	e9 3c 00 00 00       	jmp    c0102bfd <__alltraps>

c0102bc1 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102bc1:	6a 00                	push   $0x0
  pushl $251
c0102bc3:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102bc8:	e9 30 00 00 00       	jmp    c0102bfd <__alltraps>

c0102bcd <vector252>:
.globl vector252
vector252:
  pushl $0
c0102bcd:	6a 00                	push   $0x0
  pushl $252
c0102bcf:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102bd4:	e9 24 00 00 00       	jmp    c0102bfd <__alltraps>

c0102bd9 <vector253>:
.globl vector253
vector253:
  pushl $0
c0102bd9:	6a 00                	push   $0x0
  pushl $253
c0102bdb:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102be0:	e9 18 00 00 00       	jmp    c0102bfd <__alltraps>

c0102be5 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102be5:	6a 00                	push   $0x0
  pushl $254
c0102be7:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102bec:	e9 0c 00 00 00       	jmp    c0102bfd <__alltraps>

c0102bf1 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102bf1:	6a 00                	push   $0x0
  pushl $255
c0102bf3:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102bf8:	e9 00 00 00 00       	jmp    c0102bfd <__alltraps>

c0102bfd <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0102bfd:	1e                   	push   %ds
    pushl %es
c0102bfe:	06                   	push   %es
    pushl %fs
c0102bff:	0f a0                	push   %fs
    pushl %gs
c0102c01:	0f a8                	push   %gs
    pushal
c0102c03:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0102c04:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0102c09:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0102c0b:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0102c0d:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0102c0e:	e8 64 f5 ff ff       	call   c0102177 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102c13:	5c                   	pop    %esp

c0102c14 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102c14:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102c15:	0f a9                	pop    %gs
    popl %fs
c0102c17:	0f a1                	pop    %fs
    popl %es
c0102c19:	07                   	pop    %es
    popl %ds
c0102c1a:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c0102c1b:	83 c4 08             	add    $0x8,%esp
    iret
c0102c1e:	cf                   	iret   

c0102c1f <__move_down_stack2>:

.globl __move_down_stack2 
# this function aims to move down the whole stack frame by 2 bytes so that we can insert our fake esp and ss into the trapframe
__move_down_stack2:
    pushl %ebp
c0102c1f:	55                   	push   %ebp
    movl %esp, %ebp
c0102c20:	89 e5                	mov    %esp,%ebp

    pushl %ebx
c0102c22:	53                   	push   %ebx
    pushl %esi
c0102c23:	56                   	push   %esi
    pushl %edi
c0102c24:	57                   	push   %edi

    movl 8(%ebp), %ebx # ebx store the end (higher boundary) of current trapframe
c0102c25:	8b 5d 08             	mov    0x8(%ebp),%ebx
    movl 12(%ebp), %edi
c0102c28:	8b 7d 0c             	mov    0xc(%ebp),%edi
    subl $8, -4(%edi) # fix esp which __alltraps store on stack
c0102c2b:	83 6f fc 08          	subl   $0x8,-0x4(%edi)
    movl %esp, %eax
c0102c2f:	89 e0                	mov    %esp,%eax

    cmpl %eax, %ebx
c0102c31:	39 c3                	cmp    %eax,%ebx
    jle loop_end
c0102c33:	7e 0c                	jle    c0102c41 <loop_end>

c0102c35 <loop_start>:

loop_start:
    movb (%eax), %cl
c0102c35:	8a 08                	mov    (%eax),%cl
    movb %cl, -8(%eax)
c0102c37:	88 48 f8             	mov    %cl,-0x8(%eax)
    addl $1, %eax
c0102c3a:	83 c0 01             	add    $0x1,%eax
    cmpl %eax, %ebx
c0102c3d:	39 c3                	cmp    %eax,%ebx
    jg loop_start
c0102c3f:	7f f4                	jg     c0102c35 <loop_start>

c0102c41 <loop_end>:

loop_end: 
    subl $8, %esp 
c0102c41:	83 ec 08             	sub    $0x8,%esp
    subl $8, %ebp # remember, it is critical to correct all the base pointer store in stack area which is affected by our operations above
c0102c44:	83 ed 08             	sub    $0x8,%ebp
    
    movl %ebp, %eax
c0102c47:	89 e8                	mov    %ebp,%eax
    cmpl %eax, %ebx
c0102c49:	39 c3                	cmp    %eax,%ebx
    jle ebp_loop_end
c0102c4b:	7e 14                	jle    c0102c61 <ebp_loop_end>

c0102c4d <ebp_loop_begin>:

ebp_loop_begin:
    movl (%eax), %ecx
c0102c4d:	8b 08                	mov    (%eax),%ecx

    cmpl $0, %ecx
c0102c4f:	83 f9 00             	cmp    $0x0,%ecx
    je ebp_loop_end
c0102c52:	74 0d                	je     c0102c61 <ebp_loop_end>
    cmpl %ecx, %ebx
c0102c54:	39 cb                	cmp    %ecx,%ebx
    jle ebp_loop_end
c0102c56:	7e 09                	jle    c0102c61 <ebp_loop_end>
    subl $8, %ecx
c0102c58:	83 e9 08             	sub    $0x8,%ecx
    movl %ecx, (%eax)
c0102c5b:	89 08                	mov    %ecx,(%eax)
    movl %ecx, %eax
c0102c5d:	89 c8                	mov    %ecx,%eax
    jmp ebp_loop_begin
c0102c5f:	eb ec                	jmp    c0102c4d <ebp_loop_begin>

c0102c61 <ebp_loop_end>:

ebp_loop_end:

    popl %edi
c0102c61:	5f                   	pop    %edi
    popl %esi
c0102c62:	5e                   	pop    %esi
    popl %ebx
c0102c63:	5b                   	pop    %ebx

    popl %ebp
c0102c64:	5d                   	pop    %ebp
    ret 
c0102c65:	c3                   	ret    

c0102c66 <__move_up_stack2>:
# this function aims to move the trapframe along with all stack frames below up by 2 bytes
# arg1 tf_end 
# arg2 tf
# arg3 user esp
__move_up_stack2:
    pushl %ebp 
c0102c66:	55                   	push   %ebp
    movl %esp, %ebp
c0102c67:	89 e5                	mov    %esp,%ebp

    pushl %ebx
c0102c69:	53                   	push   %ebx
    pushl %edi
c0102c6a:	57                   	push   %edi
    pushl %esi
c0102c6b:	56                   	push   %esi

# first of all, copy every below tf_end to user stack
    movl 8(%ebp), %eax
c0102c6c:	8b 45 08             	mov    0x8(%ebp),%eax
    subl $1, %eax
c0102c6f:	83 e8 01             	sub    $0x1,%eax
    movl 16(%ebp), %ebx # ebx store the user stack pointer 
c0102c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
    
    cmpl %eax, %esp
c0102c75:	39 c4                	cmp    %eax,%esp
    jg copy_loop_end
c0102c77:	7f 0e                	jg     c0102c87 <copy_loop_end>

c0102c79 <copy_loop_begin>:

copy_loop_begin:
    subl $1, %ebx
c0102c79:	83 eb 01             	sub    $0x1,%ebx
    movb (%eax), %cl
c0102c7c:	8a 08                	mov    (%eax),%cl
    movb %cl, (%ebx)
c0102c7e:	88 0b                	mov    %cl,(%ebx)

    subl $1, %eax
c0102c80:	83 e8 01             	sub    $0x1,%eax
    cmpl %eax, %esp
c0102c83:	39 c4                	cmp    %eax,%esp
    jle copy_loop_begin
c0102c85:	7e f2                	jle    c0102c79 <copy_loop_begin>

c0102c87 <copy_loop_end>:

copy_loop_end:

# now we have to fix all ebp on user stack, note that we can calculate the true ebp using their address displacement
    movl %ebp, %eax
c0102c87:	89 e8                	mov    %ebp,%eax
    cmpl %eax, 8(%ebp)
c0102c89:	39 45 08             	cmp    %eax,0x8(%ebp)
    jle fix_ebp_loop_end
c0102c8c:	7e 20                	jle    c0102cae <fix_ebp_loop_end>

c0102c8e <fix_ebp_loop_begin>:

fix_ebp_loop_begin:
    movl %eax, %edi
c0102c8e:	89 c7                	mov    %eax,%edi
    subl 8(%ebp), %edi
c0102c90:	2b 7d 08             	sub    0x8(%ebp),%edi
    addl 16(%ebp), %edi # edi <=> eax
c0102c93:	03 7d 10             	add    0x10(%ebp),%edi

    cmpl (%eax), %esp 
c0102c96:	3b 20                	cmp    (%eax),%esp
    jle normal_condition
c0102c98:	7e 06                	jle    c0102ca0 <normal_condition>
    movl (%eax), %esi
c0102c9a:	8b 30                	mov    (%eax),%esi
    movl %esi, (%edi)
c0102c9c:	89 37                	mov    %esi,(%edi)
    jmp fix_ebp_loop_end
c0102c9e:	eb 0e                	jmp    c0102cae <fix_ebp_loop_end>

c0102ca0 <normal_condition>:

normal_condition:
    movl (%eax), %esi
c0102ca0:	8b 30                	mov    (%eax),%esi
    subl 8(%ebp), %esi
c0102ca2:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
c0102ca5:	03 75 10             	add    0x10(%ebp),%esi
    movl %esi, (%edi)
c0102ca8:	89 37                	mov    %esi,(%edi)
    movl (%eax), %eax
c0102caa:	8b 00                	mov    (%eax),%eax
    jmp fix_ebp_loop_begin
c0102cac:	eb e0                	jmp    c0102c8e <fix_ebp_loop_begin>

c0102cae <fix_ebp_loop_end>:

fix_ebp_loop_end:

# fix the esp which __alltraps store on stack
    movl 12(%ebp), %eax
c0102cae:	8b 45 0c             	mov    0xc(%ebp),%eax
    subl $4, %eax
c0102cb1:	83 e8 04             	sub    $0x4,%eax

    movl %eax, %edi
c0102cb4:	89 c7                	mov    %eax,%edi
    subl 8(%ebp), %edi
c0102cb6:	2b 7d 08             	sub    0x8(%ebp),%edi
    addl 16(%ebp), %edi
c0102cb9:	03 7d 10             	add    0x10(%ebp),%edi

    movl (%eax), %esi
c0102cbc:	8b 30                	mov    (%eax),%esi
    subl 8(%ebp), %esi
c0102cbe:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
c0102cc1:	03 75 10             	add    0x10(%ebp),%esi

    movl %esi, (%edi)
c0102cc4:	89 37                	mov    %esi,(%edi)

    movl 12(%ebp), %eax
c0102cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
    subl 8(%ebp), %eax
c0102cc9:	2b 45 08             	sub    0x8(%ebp),%eax
    addl 16(%ebp), %eax
c0102ccc:	03 45 10             	add    0x10(%ebp),%eax

# switch to user stack
    movl %ebx, %esp
c0102ccf:	89 dc                	mov    %ebx,%esp
    movl %ebp, %esi
c0102cd1:	89 ee                	mov    %ebp,%esi
    subl 8(%ebp), %esi
c0102cd3:	2b 75 08             	sub    0x8(%ebp),%esi
    addl 16(%ebp), %esi
c0102cd6:	03 75 10             	add    0x10(%ebp),%esi
    movl %esi, %ebp
c0102cd9:	89 f5                	mov    %esi,%ebp

    popl %esi
c0102cdb:	5e                   	pop    %esi
    popl %edi
c0102cdc:	5f                   	pop    %edi
    popl %ebx
c0102cdd:	5b                   	pop    %ebx

    popl %ebp
c0102cde:	5d                   	pop    %ebp
c0102cdf:	c3                   	ret    

c0102ce0 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102ce0:	55                   	push   %ebp
c0102ce1:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102ce3:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ce6:	8b 15 98 bf 11 c0    	mov    0xc011bf98,%edx
c0102cec:	29 d0                	sub    %edx,%eax
c0102cee:	c1 f8 02             	sar    $0x2,%eax
c0102cf1:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102cf7:	5d                   	pop    %ebp
c0102cf8:	c3                   	ret    

c0102cf9 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102cf9:	55                   	push   %ebp
c0102cfa:	89 e5                	mov    %esp,%ebp
c0102cfc:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102cff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d02:	89 04 24             	mov    %eax,(%esp)
c0102d05:	e8 d6 ff ff ff       	call   c0102ce0 <page2ppn>
c0102d0a:	c1 e0 0c             	shl    $0xc,%eax
}
c0102d0d:	c9                   	leave  
c0102d0e:	c3                   	ret    

c0102d0f <pa2page>:

static inline struct Page *
pa2page(uintptr_t pa) {
c0102d0f:	55                   	push   %ebp
c0102d10:	89 e5                	mov    %esp,%ebp
c0102d12:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0102d15:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d18:	c1 e8 0c             	shr    $0xc,%eax
c0102d1b:	89 c2                	mov    %eax,%edx
c0102d1d:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c0102d22:	39 c2                	cmp    %eax,%edx
c0102d24:	72 1c                	jb     c0102d42 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0102d26:	c7 44 24 08 b0 6b 10 	movl   $0xc0106bb0,0x8(%esp)
c0102d2d:	c0 
c0102d2e:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0102d35:	00 
c0102d36:	c7 04 24 cf 6b 10 c0 	movl   $0xc0106bcf,(%esp)
c0102d3d:	e8 b2 d6 ff ff       	call   c01003f4 <__panic>
    }
    return &pages[PPN(pa)];
c0102d42:	8b 0d 98 bf 11 c0    	mov    0xc011bf98,%ecx
c0102d48:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d4b:	c1 e8 0c             	shr    $0xc,%eax
c0102d4e:	89 c2                	mov    %eax,%edx
c0102d50:	89 d0                	mov    %edx,%eax
c0102d52:	c1 e0 02             	shl    $0x2,%eax
c0102d55:	01 d0                	add    %edx,%eax
c0102d57:	c1 e0 02             	shl    $0x2,%eax
c0102d5a:	01 c8                	add    %ecx,%eax
}
c0102d5c:	c9                   	leave  
c0102d5d:	c3                   	ret    

c0102d5e <page2kva>:

static inline void *
page2kva(struct Page *page) {
c0102d5e:	55                   	push   %ebp
c0102d5f:	89 e5                	mov    %esp,%ebp
c0102d61:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0102d64:	8b 45 08             	mov    0x8(%ebp),%eax
c0102d67:	89 04 24             	mov    %eax,(%esp)
c0102d6a:	e8 8a ff ff ff       	call   c0102cf9 <page2pa>
c0102d6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d75:	c1 e8 0c             	shr    $0xc,%eax
c0102d78:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102d7b:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c0102d80:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0102d83:	72 23                	jb     c0102da8 <page2kva+0x4a>
c0102d85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d88:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0102d8c:	c7 44 24 08 e0 6b 10 	movl   $0xc0106be0,0x8(%esp)
c0102d93:	c0 
c0102d94:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0102d9b:	00 
c0102d9c:	c7 04 24 cf 6b 10 c0 	movl   $0xc0106bcf,(%esp)
c0102da3:	e8 4c d6 ff ff       	call   c01003f4 <__panic>
c0102da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dab:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0102db0:	c9                   	leave  
c0102db1:	c3                   	ret    

c0102db2 <pte2page>:
kva2page(void *kva) {
    return pa2page(PADDR(kva));
}

static inline struct Page *
pte2page(pte_t pte) {
c0102db2:	55                   	push   %ebp
c0102db3:	89 e5                	mov    %esp,%ebp
c0102db5:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0102db8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102dbb:	83 e0 01             	and    $0x1,%eax
c0102dbe:	85 c0                	test   %eax,%eax
c0102dc0:	75 1c                	jne    c0102dde <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0102dc2:	c7 44 24 08 04 6c 10 	movl   $0xc0106c04,0x8(%esp)
c0102dc9:	c0 
c0102dca:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0102dd1:	00 
c0102dd2:	c7 04 24 cf 6b 10 c0 	movl   $0xc0106bcf,(%esp)
c0102dd9:	e8 16 d6 ff ff       	call   c01003f4 <__panic>
    }
    return pa2page(PTE_ADDR(pte));
c0102dde:	8b 45 08             	mov    0x8(%ebp),%eax
c0102de1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102de6:	89 04 24             	mov    %eax,(%esp)
c0102de9:	e8 21 ff ff ff       	call   c0102d0f <pa2page>
}
c0102dee:	c9                   	leave  
c0102def:	c3                   	ret    

c0102df0 <pde2page>:

static inline struct Page *
pde2page(pde_t pde) {
c0102df0:	55                   	push   %ebp
c0102df1:	89 e5                	mov    %esp,%ebp
c0102df3:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0102df6:	8b 45 08             	mov    0x8(%ebp),%eax
c0102df9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0102dfe:	89 04 24             	mov    %eax,(%esp)
c0102e01:	e8 09 ff ff ff       	call   c0102d0f <pa2page>
}
c0102e06:	c9                   	leave  
c0102e07:	c3                   	ret    

c0102e08 <page_ref>:

static inline int
page_ref(struct Page *page) {
c0102e08:	55                   	push   %ebp
c0102e09:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102e0b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e0e:	8b 00                	mov    (%eax),%eax
}
c0102e10:	5d                   	pop    %ebp
c0102e11:	c3                   	ret    

c0102e12 <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102e12:	55                   	push   %ebp
c0102e13:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102e15:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e18:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102e1b:	89 10                	mov    %edx,(%eax)
}
c0102e1d:	90                   	nop
c0102e1e:	5d                   	pop    %ebp
c0102e1f:	c3                   	ret    

c0102e20 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0102e20:	55                   	push   %ebp
c0102e21:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0102e23:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e26:	8b 00                	mov    (%eax),%eax
c0102e28:	8d 50 01             	lea    0x1(%eax),%edx
c0102e2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e2e:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102e30:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e33:	8b 00                	mov    (%eax),%eax
}
c0102e35:	5d                   	pop    %ebp
c0102e36:	c3                   	ret    

c0102e37 <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0102e37:	55                   	push   %ebp
c0102e38:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0102e3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e3d:	8b 00                	mov    (%eax),%eax
c0102e3f:	8d 50 ff             	lea    -0x1(%eax),%edx
c0102e42:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e45:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0102e47:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e4a:	8b 00                	mov    (%eax),%eax
}
c0102e4c:	5d                   	pop    %ebp
c0102e4d:	c3                   	ret    

c0102e4e <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0102e4e:	55                   	push   %ebp
c0102e4f:	89 e5                	mov    %esp,%ebp
c0102e51:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0102e54:	9c                   	pushf  
c0102e55:	58                   	pop    %eax
c0102e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0102e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0102e5c:	25 00 02 00 00       	and    $0x200,%eax
c0102e61:	85 c0                	test   %eax,%eax
c0102e63:	74 0c                	je     c0102e71 <__intr_save+0x23>
        intr_disable();
c0102e65:	e8 31 ea ff ff       	call   c010189b <intr_disable>
        return 1;
c0102e6a:	b8 01 00 00 00       	mov    $0x1,%eax
c0102e6f:	eb 05                	jmp    c0102e76 <__intr_save+0x28>
    }
    return 0;
c0102e71:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0102e76:	c9                   	leave  
c0102e77:	c3                   	ret    

c0102e78 <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0102e78:	55                   	push   %ebp
c0102e79:	89 e5                	mov    %esp,%ebp
c0102e7b:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0102e7e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102e82:	74 05                	je     c0102e89 <__intr_restore+0x11>
        intr_enable();
c0102e84:	e8 0b ea ff ff       	call   c0101894 <intr_enable>
    }
}
c0102e89:	90                   	nop
c0102e8a:	c9                   	leave  
c0102e8b:	c3                   	ret    

c0102e8c <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0102e8c:	55                   	push   %ebp
c0102e8d:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0102e8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e92:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0102e95:	b8 23 00 00 00       	mov    $0x23,%eax
c0102e9a:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0102e9c:	b8 23 00 00 00       	mov    $0x23,%eax
c0102ea1:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0102ea3:	b8 10 00 00 00       	mov    $0x10,%eax
c0102ea8:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0102eaa:	b8 10 00 00 00       	mov    $0x10,%eax
c0102eaf:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0102eb1:	b8 10 00 00 00       	mov    $0x10,%eax
c0102eb6:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0102eb8:	ea bf 2e 10 c0 08 00 	ljmp   $0x8,$0xc0102ebf
}
c0102ebf:	90                   	nop
c0102ec0:	5d                   	pop    %ebp
c0102ec1:	c3                   	ret    

c0102ec2 <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0102ec2:	55                   	push   %ebp
c0102ec3:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0102ec5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ec8:	a3 c4 be 11 c0       	mov    %eax,0xc011bec4
}
c0102ecd:	90                   	nop
c0102ece:	5d                   	pop    %ebp
c0102ecf:	c3                   	ret    

c0102ed0 <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0102ed0:	55                   	push   %ebp
c0102ed1:	89 e5                	mov    %esp,%ebp
c0102ed3:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0102ed6:	b8 00 80 11 c0       	mov    $0xc0118000,%eax
c0102edb:	89 04 24             	mov    %eax,(%esp)
c0102ede:	e8 df ff ff ff       	call   c0102ec2 <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0102ee3:	66 c7 05 c8 be 11 c0 	movw   $0x10,0xc011bec8
c0102eea:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0102eec:	66 c7 05 28 8a 11 c0 	movw   $0x68,0xc0118a28
c0102ef3:	68 00 
c0102ef5:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0102efa:	0f b7 c0             	movzwl %ax,%eax
c0102efd:	66 a3 2a 8a 11 c0    	mov    %ax,0xc0118a2a
c0102f03:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0102f08:	c1 e8 10             	shr    $0x10,%eax
c0102f0b:	a2 2c 8a 11 c0       	mov    %al,0xc0118a2c
c0102f10:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102f17:	24 f0                	and    $0xf0,%al
c0102f19:	0c 09                	or     $0x9,%al
c0102f1b:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102f20:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102f27:	24 ef                	and    $0xef,%al
c0102f29:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102f2e:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102f35:	24 9f                	and    $0x9f,%al
c0102f37:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102f3c:	0f b6 05 2d 8a 11 c0 	movzbl 0xc0118a2d,%eax
c0102f43:	0c 80                	or     $0x80,%al
c0102f45:	a2 2d 8a 11 c0       	mov    %al,0xc0118a2d
c0102f4a:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102f51:	24 f0                	and    $0xf0,%al
c0102f53:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102f58:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102f5f:	24 ef                	and    $0xef,%al
c0102f61:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102f66:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102f6d:	24 df                	and    $0xdf,%al
c0102f6f:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102f74:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102f7b:	0c 40                	or     $0x40,%al
c0102f7d:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102f82:	0f b6 05 2e 8a 11 c0 	movzbl 0xc0118a2e,%eax
c0102f89:	24 7f                	and    $0x7f,%al
c0102f8b:	a2 2e 8a 11 c0       	mov    %al,0xc0118a2e
c0102f90:	b8 c0 be 11 c0       	mov    $0xc011bec0,%eax
c0102f95:	c1 e8 18             	shr    $0x18,%eax
c0102f98:	a2 2f 8a 11 c0       	mov    %al,0xc0118a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0102f9d:	c7 04 24 30 8a 11 c0 	movl   $0xc0118a30,(%esp)
c0102fa4:	e8 e3 fe ff ff       	call   c0102e8c <lgdt>
c0102fa9:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("cli" ::: "memory");
}

static inline void
ltr(uint16_t sel) {
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0102faf:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0102fb3:	0f 00 d8             	ltr    %ax

    // load the TSS
    ltr(GD_TSS);
}
c0102fb6:	90                   	nop
c0102fb7:	c9                   	leave  
c0102fb8:	c3                   	ret    

c0102fb9 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0102fb9:	55                   	push   %ebp
c0102fba:	89 e5                	mov    %esp,%ebp
c0102fbc:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0102fbf:	c7 05 90 bf 11 c0 20 	movl   $0xc0107620,0xc011bf90
c0102fc6:	76 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0102fc9:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c0102fce:	8b 00                	mov    (%eax),%eax
c0102fd0:	89 44 24 04          	mov    %eax,0x4(%esp)
c0102fd4:	c7 04 24 30 6c 10 c0 	movl   $0xc0106c30,(%esp)
c0102fdb:	e8 bd d2 ff ff       	call   c010029d <cprintf>
    pmm_manager->init();
c0102fe0:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c0102fe5:	8b 40 04             	mov    0x4(%eax),%eax
c0102fe8:	ff d0                	call   *%eax
}
c0102fea:	90                   	nop
c0102feb:	c9                   	leave  
c0102fec:	c3                   	ret    

c0102fed <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c0102fed:	55                   	push   %ebp
c0102fee:	89 e5                	mov    %esp,%ebp
c0102ff0:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0102ff3:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c0102ff8:	8b 40 08             	mov    0x8(%eax),%eax
c0102ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ffe:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103002:	8b 55 08             	mov    0x8(%ebp),%edx
c0103005:	89 14 24             	mov    %edx,(%esp)
c0103008:	ff d0                	call   *%eax
}
c010300a:	90                   	nop
c010300b:	c9                   	leave  
c010300c:	c3                   	ret    

c010300d <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010300d:	55                   	push   %ebp
c010300e:	89 e5                	mov    %esp,%ebp
c0103010:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0103013:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010301a:	e8 2f fe ff ff       	call   c0102e4e <__intr_save>
c010301f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0103022:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c0103027:	8b 40 0c             	mov    0xc(%eax),%eax
c010302a:	8b 55 08             	mov    0x8(%ebp),%edx
c010302d:	89 14 24             	mov    %edx,(%esp)
c0103030:	ff d0                	call   *%eax
c0103032:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0103035:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103038:	89 04 24             	mov    %eax,(%esp)
c010303b:	e8 38 fe ff ff       	call   c0102e78 <__intr_restore>
    return page;
c0103040:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0103043:	c9                   	leave  
c0103044:	c3                   	ret    

c0103045 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0103045:	55                   	push   %ebp
c0103046:	89 e5                	mov    %esp,%ebp
c0103048:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010304b:	e8 fe fd ff ff       	call   c0102e4e <__intr_save>
c0103050:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0103053:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c0103058:	8b 40 10             	mov    0x10(%eax),%eax
c010305b:	8b 55 0c             	mov    0xc(%ebp),%edx
c010305e:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103062:	8b 55 08             	mov    0x8(%ebp),%edx
c0103065:	89 14 24             	mov    %edx,(%esp)
c0103068:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010306a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010306d:	89 04 24             	mov    %eax,(%esp)
c0103070:	e8 03 fe ff ff       	call   c0102e78 <__intr_restore>
}
c0103075:	90                   	nop
c0103076:	c9                   	leave  
c0103077:	c3                   	ret    

c0103078 <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c0103078:	55                   	push   %ebp
c0103079:	89 e5                	mov    %esp,%ebp
c010307b:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c010307e:	e8 cb fd ff ff       	call   c0102e4e <__intr_save>
c0103083:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c0103086:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c010308b:	8b 40 14             	mov    0x14(%eax),%eax
c010308e:	ff d0                	call   *%eax
c0103090:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c0103093:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103096:	89 04 24             	mov    %eax,(%esp)
c0103099:	e8 da fd ff ff       	call   c0102e78 <__intr_restore>
    return ret;
c010309e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01030a1:	c9                   	leave  
c01030a2:	c3                   	ret    

c01030a3 <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01030a3:	55                   	push   %ebp
c01030a4:	89 e5                	mov    %esp,%ebp
c01030a6:	57                   	push   %edi
c01030a7:	56                   	push   %esi
c01030a8:	53                   	push   %ebx
c01030a9:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01030af:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01030b6:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01030bd:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01030c4:	c7 04 24 47 6c 10 c0 	movl   $0xc0106c47,(%esp)
c01030cb:	e8 cd d1 ff ff       	call   c010029d <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c01030d0:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01030d7:	e9 72 01 00 00       	jmp    c010324e <page_init+0x1ab>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c01030dc:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030df:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01030e2:	89 d0                	mov    %edx,%eax
c01030e4:	c1 e0 02             	shl    $0x2,%eax
c01030e7:	01 d0                	add    %edx,%eax
c01030e9:	c1 e0 02             	shl    $0x2,%eax
c01030ec:	01 c8                	add    %ecx,%eax
c01030ee:	8b 50 08             	mov    0x8(%eax),%edx
c01030f1:	8b 40 04             	mov    0x4(%eax),%eax
c01030f4:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01030f7:	89 55 bc             	mov    %edx,-0x44(%ebp)
c01030fa:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01030fd:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103100:	89 d0                	mov    %edx,%eax
c0103102:	c1 e0 02             	shl    $0x2,%eax
c0103105:	01 d0                	add    %edx,%eax
c0103107:	c1 e0 02             	shl    $0x2,%eax
c010310a:	01 c8                	add    %ecx,%eax
c010310c:	8b 48 0c             	mov    0xc(%eax),%ecx
c010310f:	8b 58 10             	mov    0x10(%eax),%ebx
c0103112:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0103115:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0103118:	01 c8                	add    %ecx,%eax
c010311a:	11 da                	adc    %ebx,%edx
c010311c:	89 45 b0             	mov    %eax,-0x50(%ebp)
c010311f:	89 55 b4             	mov    %edx,-0x4c(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.",
c0103122:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103125:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103128:	89 d0                	mov    %edx,%eax
c010312a:	c1 e0 02             	shl    $0x2,%eax
c010312d:	01 d0                	add    %edx,%eax
c010312f:	c1 e0 02             	shl    $0x2,%eax
c0103132:	01 c8                	add    %ecx,%eax
c0103134:	83 c0 14             	add    $0x14,%eax
c0103137:	8b 00                	mov    (%eax),%eax
c0103139:	89 45 84             	mov    %eax,-0x7c(%ebp)
c010313c:	8b 45 b0             	mov    -0x50(%ebp),%eax
c010313f:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103142:	83 c0 ff             	add    $0xffffffff,%eax
c0103145:	83 d2 ff             	adc    $0xffffffff,%edx
c0103148:	89 85 78 ff ff ff    	mov    %eax,-0x88(%ebp)
c010314e:	89 95 7c ff ff ff    	mov    %edx,-0x84(%ebp)
c0103154:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103157:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010315a:	89 d0                	mov    %edx,%eax
c010315c:	c1 e0 02             	shl    $0x2,%eax
c010315f:	01 d0                	add    %edx,%eax
c0103161:	c1 e0 02             	shl    $0x2,%eax
c0103164:	01 c8                	add    %ecx,%eax
c0103166:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103169:	8b 58 10             	mov    0x10(%eax),%ebx
c010316c:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010316f:	89 54 24 1c          	mov    %edx,0x1c(%esp)
c0103173:	8b 85 78 ff ff ff    	mov    -0x88(%ebp),%eax
c0103179:	8b 95 7c ff ff ff    	mov    -0x84(%ebp),%edx
c010317f:	89 44 24 14          	mov    %eax,0x14(%esp)
c0103183:	89 54 24 18          	mov    %edx,0x18(%esp)
c0103187:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010318a:	8b 55 bc             	mov    -0x44(%ebp),%edx
c010318d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103191:	89 54 24 10          	mov    %edx,0x10(%esp)
c0103195:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c0103199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c010319d:	c7 04 24 54 6c 10 c0 	movl   $0xc0106c54,(%esp)
c01031a4:	e8 f4 d0 ff ff       	call   c010029d <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if(memmap->map[i].type == 1){
c01031a9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01031ac:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031af:	89 d0                	mov    %edx,%eax
c01031b1:	c1 e0 02             	shl    $0x2,%eax
c01031b4:	01 d0                	add    %edx,%eax
c01031b6:	c1 e0 02             	shl    $0x2,%eax
c01031b9:	01 c8                	add    %ecx,%eax
c01031bb:	83 c0 14             	add    $0x14,%eax
c01031be:	8b 00                	mov    (%eax),%eax
c01031c0:	83 f8 01             	cmp    $0x1,%eax
c01031c3:	75 0c                	jne    c01031d1 <page_init+0x12e>
            cprintf("可以使用的物理内存空间\n");
c01031c5:	c7 04 24 84 6c 10 c0 	movl   $0xc0106c84,(%esp)
c01031cc:	e8 cc d0 ff ff       	call   c010029d <cprintf>
        }
        if(memmap->map[i].type == 2){
c01031d1:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01031d4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031d7:	89 d0                	mov    %edx,%eax
c01031d9:	c1 e0 02             	shl    $0x2,%eax
c01031dc:	01 d0                	add    %edx,%eax
c01031de:	c1 e0 02             	shl    $0x2,%eax
c01031e1:	01 c8                	add    %ecx,%eax
c01031e3:	83 c0 14             	add    $0x14,%eax
c01031e6:	8b 00                	mov    (%eax),%eax
c01031e8:	83 f8 02             	cmp    $0x2,%eax
c01031eb:	75 0c                	jne    c01031f9 <page_init+0x156>
            cprintf("不能使用的物理内存空间\n");
c01031ed:	c7 04 24 a8 6c 10 c0 	movl   $0xc0106ca8,(%esp)
c01031f4:	e8 a4 d0 ff ff       	call   c010029d <cprintf>
        }
        if (memmap->map[i].type == E820_ARM) {
c01031f9:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01031fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01031ff:	89 d0                	mov    %edx,%eax
c0103201:	c1 e0 02             	shl    $0x2,%eax
c0103204:	01 d0                	add    %edx,%eax
c0103206:	c1 e0 02             	shl    $0x2,%eax
c0103209:	01 c8                	add    %ecx,%eax
c010320b:	83 c0 14             	add    $0x14,%eax
c010320e:	8b 00                	mov    (%eax),%eax
c0103210:	83 f8 01             	cmp    $0x1,%eax
c0103213:	75 36                	jne    c010324b <page_init+0x1a8>
            if (maxpa < end && begin < KMEMSIZE) {
c0103215:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103218:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010321b:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c010321e:	77 2b                	ja     c010324b <page_init+0x1a8>
c0103220:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
c0103223:	72 05                	jb     c010322a <page_init+0x187>
c0103225:	3b 45 b0             	cmp    -0x50(%ebp),%eax
c0103228:	73 21                	jae    c010324b <page_init+0x1a8>
c010322a:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c010322e:	77 1b                	ja     c010324b <page_init+0x1a8>
c0103230:	83 7d bc 00          	cmpl   $0x0,-0x44(%ebp)
c0103234:	72 09                	jb     c010323f <page_init+0x19c>
c0103236:	81 7d b8 ff ff ff 37 	cmpl   $0x37ffffff,-0x48(%ebp)
c010323d:	77 0c                	ja     c010324b <page_init+0x1a8>
                maxpa = end;
c010323f:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103242:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0103245:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0103248:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
    uint64_t maxpa = 0;

    cprintf("e820map:\n");
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c010324b:	ff 45 dc             	incl   -0x24(%ebp)
c010324e:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0103251:	8b 00                	mov    (%eax),%eax
c0103253:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c0103256:	0f 8f 80 fe ff ff    	jg     c01030dc <page_init+0x39>
            if (maxpa < end && begin < KMEMSIZE) {
                maxpa = end;
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010325c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103260:	72 1d                	jb     c010327f <page_init+0x1dc>
c0103262:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0103266:	77 09                	ja     c0103271 <page_init+0x1ce>
c0103268:	81 7d e0 00 00 00 38 	cmpl   $0x38000000,-0x20(%ebp)
c010326f:	76 0e                	jbe    c010327f <page_init+0x1dc>
        maxpa = KMEMSIZE;
c0103271:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0103278:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010327f:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103282:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103285:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0103289:	c1 ea 0c             	shr    $0xc,%edx
c010328c:	a3 a0 be 11 c0       	mov    %eax,0xc011bea0
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c0103291:	c7 45 ac 00 10 00 00 	movl   $0x1000,-0x54(%ebp)
c0103298:	b8 a8 bf 11 c0       	mov    $0xc011bfa8,%eax
c010329d:	8d 50 ff             	lea    -0x1(%eax),%edx
c01032a0:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01032a3:	01 d0                	add    %edx,%eax
c01032a5:	89 45 a8             	mov    %eax,-0x58(%ebp)
c01032a8:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01032ab:	ba 00 00 00 00       	mov    $0x0,%edx
c01032b0:	f7 75 ac             	divl   -0x54(%ebp)
c01032b3:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01032b6:	29 d0                	sub    %edx,%eax
c01032b8:	a3 98 bf 11 c0       	mov    %eax,0xc011bf98

    for (i = 0; i < npage; i ++) {
c01032bd:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01032c4:	eb 2e                	jmp    c01032f4 <page_init+0x251>
        SetPageReserved(pages + i);
c01032c6:	8b 0d 98 bf 11 c0    	mov    0xc011bf98,%ecx
c01032cc:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01032cf:	89 d0                	mov    %edx,%eax
c01032d1:	c1 e0 02             	shl    $0x2,%eax
c01032d4:	01 d0                	add    %edx,%eax
c01032d6:	c1 e0 02             	shl    $0x2,%eax
c01032d9:	01 c8                	add    %ecx,%eax
c01032db:	83 c0 04             	add    $0x4,%eax
c01032de:	c7 45 90 00 00 00 00 	movl   $0x0,-0x70(%ebp)
c01032e5:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01032e8:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01032eb:	8b 55 90             	mov    -0x70(%ebp),%edx
c01032ee:	0f ab 10             	bts    %edx,(%eax)
    extern char end[];

    npage = maxpa / PGSIZE;
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);

    for (i = 0; i < npage; i ++) {
c01032f1:	ff 45 dc             	incl   -0x24(%ebp)
c01032f4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01032f7:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c01032fc:	39 c2                	cmp    %eax,%edx
c01032fe:	72 c6                	jb     c01032c6 <page_init+0x223>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c0103300:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c0103306:	89 d0                	mov    %edx,%eax
c0103308:	c1 e0 02             	shl    $0x2,%eax
c010330b:	01 d0                	add    %edx,%eax
c010330d:	c1 e0 02             	shl    $0x2,%eax
c0103310:	89 c2                	mov    %eax,%edx
c0103312:	a1 98 bf 11 c0       	mov    0xc011bf98,%eax
c0103317:	01 d0                	add    %edx,%eax
c0103319:	89 45 a4             	mov    %eax,-0x5c(%ebp)
c010331c:	81 7d a4 ff ff ff bf 	cmpl   $0xbfffffff,-0x5c(%ebp)
c0103323:	77 23                	ja     c0103348 <page_init+0x2a5>
c0103325:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0103328:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010332c:	c7 44 24 08 cc 6c 10 	movl   $0xc0106ccc,0x8(%esp)
c0103333:	c0 
c0103334:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c010333b:	00 
c010333c:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103343:	e8 ac d0 ff ff       	call   c01003f4 <__panic>
c0103348:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c010334b:	05 00 00 00 40       	add    $0x40000000,%eax
c0103350:	89 45 a0             	mov    %eax,-0x60(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0103353:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010335a:	e9 61 01 00 00       	jmp    c01034c0 <page_init+0x41d>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010335f:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103362:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103365:	89 d0                	mov    %edx,%eax
c0103367:	c1 e0 02             	shl    $0x2,%eax
c010336a:	01 d0                	add    %edx,%eax
c010336c:	c1 e0 02             	shl    $0x2,%eax
c010336f:	01 c8                	add    %ecx,%eax
c0103371:	8b 50 08             	mov    0x8(%eax),%edx
c0103374:	8b 40 04             	mov    0x4(%eax),%eax
c0103377:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010337a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010337d:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0103380:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0103383:	89 d0                	mov    %edx,%eax
c0103385:	c1 e0 02             	shl    $0x2,%eax
c0103388:	01 d0                	add    %edx,%eax
c010338a:	c1 e0 02             	shl    $0x2,%eax
c010338d:	01 c8                	add    %ecx,%eax
c010338f:	8b 48 0c             	mov    0xc(%eax),%ecx
c0103392:	8b 58 10             	mov    0x10(%eax),%ebx
c0103395:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103398:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010339b:	01 c8                	add    %ecx,%eax
c010339d:	11 da                	adc    %ebx,%edx
c010339f:	89 45 c8             	mov    %eax,-0x38(%ebp)
c01033a2:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c01033a5:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01033a8:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01033ab:	89 d0                	mov    %edx,%eax
c01033ad:	c1 e0 02             	shl    $0x2,%eax
c01033b0:	01 d0                	add    %edx,%eax
c01033b2:	c1 e0 02             	shl    $0x2,%eax
c01033b5:	01 c8                	add    %ecx,%eax
c01033b7:	83 c0 14             	add    $0x14,%eax
c01033ba:	8b 00                	mov    (%eax),%eax
c01033bc:	83 f8 01             	cmp    $0x1,%eax
c01033bf:	0f 85 f8 00 00 00    	jne    c01034bd <page_init+0x41a>
            if (begin < freemem) {
c01033c5:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01033c8:	ba 00 00 00 00       	mov    $0x0,%edx
c01033cd:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01033d0:	72 17                	jb     c01033e9 <page_init+0x346>
c01033d2:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c01033d5:	77 05                	ja     c01033dc <page_init+0x339>
c01033d7:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c01033da:	76 0d                	jbe    c01033e9 <page_init+0x346>
                begin = freemem;
c01033dc:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01033df:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01033e2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01033e9:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01033ed:	72 1d                	jb     c010340c <page_init+0x369>
c01033ef:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
c01033f3:	77 09                	ja     c01033fe <page_init+0x35b>
c01033f5:	81 7d c8 00 00 00 38 	cmpl   $0x38000000,-0x38(%ebp)
c01033fc:	76 0e                	jbe    c010340c <page_init+0x369>
                end = KMEMSIZE;
c01033fe:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c0103405:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c010340c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010340f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103412:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103415:	0f 87 a2 00 00 00    	ja     c01034bd <page_init+0x41a>
c010341b:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010341e:	72 09                	jb     c0103429 <page_init+0x386>
c0103420:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c0103423:	0f 83 94 00 00 00    	jae    c01034bd <page_init+0x41a>
                begin = ROUNDUP(begin, PGSIZE);
c0103429:	c7 45 9c 00 10 00 00 	movl   $0x1000,-0x64(%ebp)
c0103430:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0103433:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103436:	01 d0                	add    %edx,%eax
c0103438:	48                   	dec    %eax
c0103439:	89 45 98             	mov    %eax,-0x68(%ebp)
c010343c:	8b 45 98             	mov    -0x68(%ebp),%eax
c010343f:	ba 00 00 00 00       	mov    $0x0,%edx
c0103444:	f7 75 9c             	divl   -0x64(%ebp)
c0103447:	8b 45 98             	mov    -0x68(%ebp),%eax
c010344a:	29 d0                	sub    %edx,%eax
c010344c:	ba 00 00 00 00       	mov    $0x0,%edx
c0103451:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0103454:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0103457:	8b 45 c8             	mov    -0x38(%ebp),%eax
c010345a:	89 45 94             	mov    %eax,-0x6c(%ebp)
c010345d:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0103460:	ba 00 00 00 00       	mov    $0x0,%edx
c0103465:	89 c3                	mov    %eax,%ebx
c0103467:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
c010346d:	89 de                	mov    %ebx,%esi
c010346f:	89 d0                	mov    %edx,%eax
c0103471:	83 e0 00             	and    $0x0,%eax
c0103474:	89 c7                	mov    %eax,%edi
c0103476:	89 75 c8             	mov    %esi,-0x38(%ebp)
c0103479:	89 7d cc             	mov    %edi,-0x34(%ebp)
                if (begin < end) {
c010347c:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010347f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0103482:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c0103485:	77 36                	ja     c01034bd <page_init+0x41a>
c0103487:	3b 55 cc             	cmp    -0x34(%ebp),%edx
c010348a:	72 05                	jb     c0103491 <page_init+0x3ee>
c010348c:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010348f:	73 2c                	jae    c01034bd <page_init+0x41a>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0103491:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0103494:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0103497:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010349a:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010349d:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c01034a1:	c1 ea 0c             	shr    $0xc,%edx
c01034a4:	89 c3                	mov    %eax,%ebx
c01034a6:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01034a9:	89 04 24             	mov    %eax,(%esp)
c01034ac:	e8 5e f8 ff ff       	call   c0102d0f <pa2page>
c01034b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01034b5:	89 04 24             	mov    %eax,(%esp)
c01034b8:	e8 30 fb ff ff       	call   c0102fed <init_memmap>
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);

    for (i = 0; i < memmap->nr_map; i ++) {
c01034bd:	ff 45 dc             	incl   -0x24(%ebp)
c01034c0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01034c3:	8b 00                	mov    (%eax),%eax
c01034c5:	3b 45 dc             	cmp    -0x24(%ebp),%eax
c01034c8:	0f 8f 91 fe ff ff    	jg     c010335f <page_init+0x2bc>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
                }
            }
        }
    }
}
c01034ce:	90                   	nop
c01034cf:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c01034d5:	5b                   	pop    %ebx
c01034d6:	5e                   	pop    %esi
c01034d7:	5f                   	pop    %edi
c01034d8:	5d                   	pop    %ebp
c01034d9:	c3                   	ret    

c01034da <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c01034da:	55                   	push   %ebp
c01034db:	89 e5                	mov    %esp,%ebp
c01034dd:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01034e0:	8b 45 0c             	mov    0xc(%ebp),%eax
c01034e3:	33 45 14             	xor    0x14(%ebp),%eax
c01034e6:	25 ff 0f 00 00       	and    $0xfff,%eax
c01034eb:	85 c0                	test   %eax,%eax
c01034ed:	74 24                	je     c0103513 <boot_map_segment+0x39>
c01034ef:	c7 44 24 0c fe 6c 10 	movl   $0xc0106cfe,0xc(%esp)
c01034f6:	c0 
c01034f7:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01034fe:	c0 
c01034ff:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0103506:	00 
c0103507:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c010350e:	e8 e1 ce ff ff       	call   c01003f4 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c0103513:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c010351a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010351d:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103522:	89 c2                	mov    %eax,%edx
c0103524:	8b 45 10             	mov    0x10(%ebp),%eax
c0103527:	01 c2                	add    %eax,%edx
c0103529:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010352c:	01 d0                	add    %edx,%eax
c010352e:	48                   	dec    %eax
c010352f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103532:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103535:	ba 00 00 00 00       	mov    $0x0,%edx
c010353a:	f7 75 f0             	divl   -0x10(%ebp)
c010353d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103540:	29 d0                	sub    %edx,%eax
c0103542:	c1 e8 0c             	shr    $0xc,%eax
c0103545:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c0103548:	8b 45 0c             	mov    0xc(%ebp),%eax
c010354b:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010354e:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103551:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103556:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c0103559:	8b 45 14             	mov    0x14(%ebp),%eax
c010355c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010355f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103562:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103567:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010356a:	eb 68                	jmp    c01035d4 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010356c:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103573:	00 
c0103574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103577:	89 44 24 04          	mov    %eax,0x4(%esp)
c010357b:	8b 45 08             	mov    0x8(%ebp),%eax
c010357e:	89 04 24             	mov    %eax,(%esp)
c0103581:	e8 81 01 00 00       	call   c0103707 <get_pte>
c0103586:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c0103589:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010358d:	75 24                	jne    c01035b3 <boot_map_segment+0xd9>
c010358f:	c7 44 24 0c 2a 6d 10 	movl   $0xc0106d2a,0xc(%esp)
c0103596:	c0 
c0103597:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c010359e:	c0 
c010359f:	c7 44 24 04 06 01 00 	movl   $0x106,0x4(%esp)
c01035a6:	00 
c01035a7:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01035ae:	e8 41 ce ff ff       	call   c01003f4 <__panic>
        *ptep = pa | PTE_P | perm;
c01035b3:	8b 45 14             	mov    0x14(%ebp),%eax
c01035b6:	0b 45 18             	or     0x18(%ebp),%eax
c01035b9:	83 c8 01             	or     $0x1,%eax
c01035bc:	89 c2                	mov    %eax,%edx
c01035be:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01035c1:	89 10                	mov    %edx,(%eax)
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
    assert(PGOFF(la) == PGOFF(pa));
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    la = ROUNDDOWN(la, PGSIZE);
    pa = ROUNDDOWN(pa, PGSIZE);
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c01035c3:	ff 4d f4             	decl   -0xc(%ebp)
c01035c6:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c01035cd:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c01035d4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035d8:	75 92                	jne    c010356c <boot_map_segment+0x92>
        pte_t *ptep = get_pte(pgdir, la, 1);
        assert(ptep != NULL);
        *ptep = pa | PTE_P | perm;
    }
}
c01035da:	90                   	nop
c01035db:	c9                   	leave  
c01035dc:	c3                   	ret    

c01035dd <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01035dd:	55                   	push   %ebp
c01035de:	89 e5                	mov    %esp,%ebp
c01035e0:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01035e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035ea:	e8 1e fa ff ff       	call   c010300d <alloc_pages>
c01035ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01035f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01035f6:	75 1c                	jne    c0103614 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01035f8:	c7 44 24 08 37 6d 10 	movl   $0xc0106d37,0x8(%esp)
c01035ff:	c0 
c0103600:	c7 44 24 04 12 01 00 	movl   $0x112,0x4(%esp)
c0103607:	00 
c0103608:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c010360f:	e8 e0 cd ff ff       	call   c01003f4 <__panic>
    }
    return page2kva(p);
c0103614:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103617:	89 04 24             	mov    %eax,(%esp)
c010361a:	e8 3f f7 ff ff       	call   c0102d5e <page2kva>
}
c010361f:	c9                   	leave  
c0103620:	c3                   	ret    

c0103621 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c0103621:	55                   	push   %ebp
c0103622:	89 e5                	mov    %esp,%ebp
c0103624:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c0103627:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010362c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010362f:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c0103636:	77 23                	ja     c010365b <pmm_init+0x3a>
c0103638:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010363b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010363f:	c7 44 24 08 cc 6c 10 	movl   $0xc0106ccc,0x8(%esp)
c0103646:	c0 
c0103647:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c010364e:	00 
c010364f:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103656:	e8 99 cd ff ff       	call   c01003f4 <__panic>
c010365b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010365e:	05 00 00 00 40       	add    $0x40000000,%eax
c0103663:	a3 94 bf 11 c0       	mov    %eax,0xc011bf94
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c0103668:	e8 4c f9 ff ff       	call   c0102fb9 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c010366d:	e8 31 fa ff ff       	call   c01030a3 <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0103672:	e8 e5 03 00 00       	call   c0103a5c <check_alloc_page>

    check_pgdir();
c0103677:	e8 ff 03 00 00       	call   c0103a7b <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c010367c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103681:	8d 90 ac 0f 00 00    	lea    0xfac(%eax),%edx
c0103687:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010368c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010368f:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103696:	77 23                	ja     c01036bb <pmm_init+0x9a>
c0103698:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010369b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010369f:	c7 44 24 08 cc 6c 10 	movl   $0xc0106ccc,0x8(%esp)
c01036a6:	c0 
c01036a7:	c7 44 24 04 32 01 00 	movl   $0x132,0x4(%esp)
c01036ae:	00 
c01036af:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01036b6:	e8 39 cd ff ff       	call   c01003f4 <__panic>
c01036bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036be:	05 00 00 00 40       	add    $0x40000000,%eax
c01036c3:	83 c8 03             	or     $0x3,%eax
c01036c6:	89 02                	mov    %eax,(%edx)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c01036c8:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01036cd:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c01036d4:	00 
c01036d5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01036dc:	00 
c01036dd:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01036e4:	38 
c01036e5:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01036ec:	c0 
c01036ed:	89 04 24             	mov    %eax,(%esp)
c01036f0:	e8 e5 fd ff ff       	call   c01034da <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01036f5:	e8 d6 f7 ff ff       	call   c0102ed0 <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01036fa:	e8 18 0a 00 00       	call   c0104117 <check_boot_pgdir>

    print_pgdir();
c01036ff:	e8 91 0e 00 00       	call   c0104595 <print_pgdir>

}
c0103704:	90                   	nop
c0103705:	c9                   	leave  
c0103706:	c3                   	ret    

c0103707 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c0103707:	55                   	push   %ebp
c0103708:	89 e5                	mov    %esp,%ebp
c010370a:	83 ec 38             	sub    $0x38,%esp
    // (4) set page reference
    // (5) get linear address of page
    // (6) clear page content using memset
    // (7) set page directory entry's permission
    // (8) return page table entry
    pde_t *pdep = &pgdir[PDX(la)];
c010370d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103710:	c1 e8 16             	shr    $0x16,%eax
c0103713:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010371a:	8b 45 08             	mov    0x8(%ebp),%eax
c010371d:	01 d0                	add    %edx,%eax
c010371f:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(!(*pdep & PTE_P)){
c0103722:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103725:	8b 00                	mov    (%eax),%eax
c0103727:	83 e0 01             	and    $0x1,%eax
c010372a:	85 c0                	test   %eax,%eax
c010372c:	0f 85 b6 00 00 00    	jne    c01037e8 <get_pte+0xe1>
        struct Page *page;
        if(create == 1 && (page = alloc_page())){
c0103732:	83 7d 10 01          	cmpl   $0x1,0x10(%ebp)
c0103736:	0f 85 a5 00 00 00    	jne    c01037e1 <get_pte+0xda>
c010373c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103743:	e8 c5 f8 ff ff       	call   c010300d <alloc_pages>
c0103748:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010374b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010374f:	0f 84 8c 00 00 00    	je     c01037e1 <get_pte+0xda>
            set_page_ref(page,1);
c0103755:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010375c:	00 
c010375d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103760:	89 04 24             	mov    %eax,(%esp)
c0103763:	e8 aa f6 ff ff       	call   c0102e12 <set_page_ref>
            uintptr_t pa = page2pa(page);
c0103768:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010376b:	89 04 24             	mov    %eax,(%esp)
c010376e:	e8 86 f5 ff ff       	call   c0102cf9 <page2pa>
c0103773:	89 45 ec             	mov    %eax,-0x14(%ebp)
            memset(KADDR(pa), 0, PGSIZE);
c0103776:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103779:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010377c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010377f:	c1 e8 0c             	shr    $0xc,%eax
c0103782:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103785:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c010378a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c010378d:	72 23                	jb     c01037b2 <get_pte+0xab>
c010378f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103792:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103796:	c7 44 24 08 e0 6b 10 	movl   $0xc0106be0,0x8(%esp)
c010379d:	c0 
c010379e:	c7 44 24 04 74 01 00 	movl   $0x174,0x4(%esp)
c01037a5:	00 
c01037a6:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01037ad:	e8 42 cc ff ff       	call   c01003f4 <__panic>
c01037b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01037b5:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01037ba:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c01037c1:	00 
c01037c2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01037c9:	00 
c01037ca:	89 04 24             	mov    %eax,(%esp)
c01037cd:	e8 a9 24 00 00       	call   c0105c7b <memset>
            *pdep = pa | PTE_U | PTE_W | PTE_P;
c01037d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01037d5:	83 c8 07             	or     $0x7,%eax
c01037d8:	89 c2                	mov    %eax,%edx
c01037da:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037dd:	89 10                	mov    %edx,(%eax)
    // (7) set page directory entry's permission
    // (8) return page table entry
    pde_t *pdep = &pgdir[PDX(la)];
    if(!(*pdep & PTE_P)){
        struct Page *page;
        if(create == 1 && (page = alloc_page())){
c01037df:	eb 07                	jmp    c01037e8 <get_pte+0xe1>
            uintptr_t pa = page2pa(page);
            memset(KADDR(pa), 0, PGSIZE);
            *pdep = pa | PTE_U | PTE_W | PTE_P;
        }
        else{
            return NULL;
c01037e1:	b8 00 00 00 00       	mov    $0x0,%eax
c01037e6:	eb 5d                	jmp    c0103845 <get_pte+0x13e>
        }

    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01037e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01037eb:	8b 00                	mov    (%eax),%eax
c01037ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01037f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01037f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01037f8:	c1 e8 0c             	shr    $0xc,%eax
c01037fb:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01037fe:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c0103803:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0103806:	72 23                	jb     c010382b <get_pte+0x124>
c0103808:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010380b:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010380f:	c7 44 24 08 e0 6b 10 	movl   $0xc0106be0,0x8(%esp)
c0103816:	c0 
c0103817:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
c010381e:	00 
c010381f:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103826:	e8 c9 cb ff ff       	call   c01003f4 <__panic>
c010382b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010382e:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103833:	89 c2                	mov    %eax,%edx
c0103835:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103838:	c1 e8 0c             	shr    $0xc,%eax
c010383b:	25 ff 03 00 00       	and    $0x3ff,%eax
c0103840:	c1 e0 02             	shl    $0x2,%eax
c0103843:	01 d0                	add    %edx,%eax
#endif
}
c0103845:	c9                   	leave  
c0103846:	c3                   	ret    

c0103847 <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c0103847:	55                   	push   %ebp
c0103848:	89 e5                	mov    %esp,%ebp
c010384a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c010384d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103854:	00 
c0103855:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103858:	89 44 24 04          	mov    %eax,0x4(%esp)
c010385c:	8b 45 08             	mov    0x8(%ebp),%eax
c010385f:	89 04 24             	mov    %eax,(%esp)
c0103862:	e8 a0 fe ff ff       	call   c0103707 <get_pte>
c0103867:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010386a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c010386e:	74 08                	je     c0103878 <get_page+0x31>
        *ptep_store = ptep;
c0103870:	8b 45 10             	mov    0x10(%ebp),%eax
c0103873:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103876:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c0103878:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010387c:	74 1b                	je     c0103899 <get_page+0x52>
c010387e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103881:	8b 00                	mov    (%eax),%eax
c0103883:	83 e0 01             	and    $0x1,%eax
c0103886:	85 c0                	test   %eax,%eax
c0103888:	74 0f                	je     c0103899 <get_page+0x52>
        return pte2page(*ptep);
c010388a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010388d:	8b 00                	mov    (%eax),%eax
c010388f:	89 04 24             	mov    %eax,(%esp)
c0103892:	e8 1b f5 ff ff       	call   c0102db2 <pte2page>
c0103897:	eb 05                	jmp    c010389e <get_page+0x57>
    }
    return NULL;
c0103899:	b8 00 00 00 00       	mov    $0x0,%eax
}
c010389e:	c9                   	leave  
c010389f:	c3                   	ret    

c01038a0 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c01038a0:	55                   	push   %ebp
c01038a1:	89 e5                	mov    %esp,%ebp
c01038a3:	83 ec 28             	sub    $0x28,%esp
    //(2) find corresponding page to pte
    //(3) decrease page reference
    //(4) and free this page when page reference reachs 0
    //(5) clear second page table entry
    //(6) flush tlb
    if(*ptep & PTE_P){
c01038a6:	8b 45 10             	mov    0x10(%ebp),%eax
c01038a9:	8b 00                	mov    (%eax),%eax
c01038ab:	83 e0 01             	and    $0x1,%eax
c01038ae:	85 c0                	test   %eax,%eax
c01038b0:	74 4d                	je     c01038ff <page_remove_pte+0x5f>
        struct Page *page = pte2page(*ptep);
c01038b2:	8b 45 10             	mov    0x10(%ebp),%eax
c01038b5:	8b 00                	mov    (%eax),%eax
c01038b7:	89 04 24             	mov    %eax,(%esp)
c01038ba:	e8 f3 f4 ff ff       	call   c0102db2 <pte2page>
c01038bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if(page_ref_dec(page) == 0){
c01038c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038c5:	89 04 24             	mov    %eax,(%esp)
c01038c8:	e8 6a f5 ff ff       	call   c0102e37 <page_ref_dec>
c01038cd:	85 c0                	test   %eax,%eax
c01038cf:	75 13                	jne    c01038e4 <page_remove_pte+0x44>
            free_page(page);
c01038d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01038d8:	00 
c01038d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01038dc:	89 04 24             	mov    %eax,(%esp)
c01038df:	e8 61 f7 ff ff       	call   c0103045 <free_pages>
        }
        *ptep = NULL;
c01038e4:	8b 45 10             	mov    0x10(%ebp),%eax
c01038e7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        tlb_invalidate(pgdir, la);
c01038ed:	8b 45 0c             	mov    0xc(%ebp),%eax
c01038f0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01038f4:	8b 45 08             	mov    0x8(%ebp),%eax
c01038f7:	89 04 24             	mov    %eax,(%esp)
c01038fa:	e8 01 01 00 00       	call   c0103a00 <tlb_invalidate>
    }
#endif

}
c01038ff:	90                   	nop
c0103900:	c9                   	leave  
c0103901:	c3                   	ret    

c0103902 <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c0103902:	55                   	push   %ebp
c0103903:	89 e5                	mov    %esp,%ebp
c0103905:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0103908:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010390f:	00 
c0103910:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103913:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103917:	8b 45 08             	mov    0x8(%ebp),%eax
c010391a:	89 04 24             	mov    %eax,(%esp)
c010391d:	e8 e5 fd ff ff       	call   c0103707 <get_pte>
c0103922:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c0103925:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103929:	74 19                	je     c0103944 <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c010392b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010392e:	89 44 24 08          	mov    %eax,0x8(%esp)
c0103932:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103935:	89 44 24 04          	mov    %eax,0x4(%esp)
c0103939:	8b 45 08             	mov    0x8(%ebp),%eax
c010393c:	89 04 24             	mov    %eax,(%esp)
c010393f:	e8 5c ff ff ff       	call   c01038a0 <page_remove_pte>
    }
}
c0103944:	90                   	nop
c0103945:	c9                   	leave  
c0103946:	c3                   	ret    

c0103947 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0103947:	55                   	push   %ebp
c0103948:	89 e5                	mov    %esp,%ebp
c010394a:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c010394d:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0103954:	00 
c0103955:	8b 45 10             	mov    0x10(%ebp),%eax
c0103958:	89 44 24 04          	mov    %eax,0x4(%esp)
c010395c:	8b 45 08             	mov    0x8(%ebp),%eax
c010395f:	89 04 24             	mov    %eax,(%esp)
c0103962:	e8 a0 fd ff ff       	call   c0103707 <get_pte>
c0103967:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c010396a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010396e:	75 0a                	jne    c010397a <page_insert+0x33>
        return -E_NO_MEM;
c0103970:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c0103975:	e9 84 00 00 00       	jmp    c01039fe <page_insert+0xb7>
    }
    page_ref_inc(page);
c010397a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010397d:	89 04 24             	mov    %eax,(%esp)
c0103980:	e8 9b f4 ff ff       	call   c0102e20 <page_ref_inc>
    if (*ptep & PTE_P) {
c0103985:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103988:	8b 00                	mov    (%eax),%eax
c010398a:	83 e0 01             	and    $0x1,%eax
c010398d:	85 c0                	test   %eax,%eax
c010398f:	74 3e                	je     c01039cf <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c0103991:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103994:	8b 00                	mov    (%eax),%eax
c0103996:	89 04 24             	mov    %eax,(%esp)
c0103999:	e8 14 f4 ff ff       	call   c0102db2 <pte2page>
c010399e:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c01039a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01039a4:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01039a7:	75 0d                	jne    c01039b6 <page_insert+0x6f>
            page_ref_dec(page);
c01039a9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039ac:	89 04 24             	mov    %eax,(%esp)
c01039af:	e8 83 f4 ff ff       	call   c0102e37 <page_ref_dec>
c01039b4:	eb 19                	jmp    c01039cf <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c01039b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039b9:	89 44 24 08          	mov    %eax,0x8(%esp)
c01039bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01039c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039c4:	8b 45 08             	mov    0x8(%ebp),%eax
c01039c7:	89 04 24             	mov    %eax,(%esp)
c01039ca:	e8 d1 fe ff ff       	call   c01038a0 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c01039cf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01039d2:	89 04 24             	mov    %eax,(%esp)
c01039d5:	e8 1f f3 ff ff       	call   c0102cf9 <page2pa>
c01039da:	0b 45 14             	or     0x14(%ebp),%eax
c01039dd:	83 c8 01             	or     $0x1,%eax
c01039e0:	89 c2                	mov    %eax,%edx
c01039e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01039e5:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01039e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01039ea:	89 44 24 04          	mov    %eax,0x4(%esp)
c01039ee:	8b 45 08             	mov    0x8(%ebp),%eax
c01039f1:	89 04 24             	mov    %eax,(%esp)
c01039f4:	e8 07 00 00 00       	call   c0103a00 <tlb_invalidate>
    return 0;
c01039f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01039fe:	c9                   	leave  
c01039ff:	c3                   	ret    

c0103a00 <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c0103a00:	55                   	push   %ebp
c0103a01:	89 e5                	mov    %esp,%ebp
c0103a03:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c0103a06:	0f 20 d8             	mov    %cr3,%eax
c0103a09:	89 45 ec             	mov    %eax,-0x14(%ebp)
    return cr3;
c0103a0c:	8b 55 ec             	mov    -0x14(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c0103a0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103a15:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0103a1c:	77 23                	ja     c0103a41 <tlb_invalidate+0x41>
c0103a1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a21:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103a25:	c7 44 24 08 cc 6c 10 	movl   $0xc0106ccc,0x8(%esp)
c0103a2c:	c0 
c0103a2d:	c7 44 24 04 df 01 00 	movl   $0x1df,0x4(%esp)
c0103a34:	00 
c0103a35:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103a3c:	e8 b3 c9 ff ff       	call   c01003f4 <__panic>
c0103a41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103a44:	05 00 00 00 40       	add    $0x40000000,%eax
c0103a49:	39 c2                	cmp    %eax,%edx
c0103a4b:	75 0c                	jne    c0103a59 <tlb_invalidate+0x59>
        invlpg((void *)la);
c0103a4d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0103a50:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0103a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103a56:	0f 01 38             	invlpg (%eax)
    }
}
c0103a59:	90                   	nop
c0103a5a:	c9                   	leave  
c0103a5b:	c3                   	ret    

c0103a5c <check_alloc_page>:

static void
check_alloc_page(void) {
c0103a5c:	55                   	push   %ebp
c0103a5d:	89 e5                	mov    %esp,%ebp
c0103a5f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0103a62:	a1 90 bf 11 c0       	mov    0xc011bf90,%eax
c0103a67:	8b 40 18             	mov    0x18(%eax),%eax
c0103a6a:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0103a6c:	c7 04 24 50 6d 10 c0 	movl   $0xc0106d50,(%esp)
c0103a73:	e8 25 c8 ff ff       	call   c010029d <cprintf>
}
c0103a78:	90                   	nop
c0103a79:	c9                   	leave  
c0103a7a:	c3                   	ret    

c0103a7b <check_pgdir>:

static void
check_pgdir(void) {
c0103a7b:	55                   	push   %ebp
c0103a7c:	89 e5                	mov    %esp,%ebp
c0103a7e:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0103a81:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c0103a86:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0103a8b:	76 24                	jbe    c0103ab1 <check_pgdir+0x36>
c0103a8d:	c7 44 24 0c 6f 6d 10 	movl   $0xc0106d6f,0xc(%esp)
c0103a94:	c0 
c0103a95:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103a9c:	c0 
c0103a9d:	c7 44 24 04 ec 01 00 	movl   $0x1ec,0x4(%esp)
c0103aa4:	00 
c0103aa5:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103aac:	e8 43 c9 ff ff       	call   c01003f4 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0103ab1:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103ab6:	85 c0                	test   %eax,%eax
c0103ab8:	74 0e                	je     c0103ac8 <check_pgdir+0x4d>
c0103aba:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103abf:	25 ff 0f 00 00       	and    $0xfff,%eax
c0103ac4:	85 c0                	test   %eax,%eax
c0103ac6:	74 24                	je     c0103aec <check_pgdir+0x71>
c0103ac8:	c7 44 24 0c 8c 6d 10 	movl   $0xc0106d8c,0xc(%esp)
c0103acf:	c0 
c0103ad0:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103ad7:	c0 
c0103ad8:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0103adf:	00 
c0103ae0:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103ae7:	e8 08 c9 ff ff       	call   c01003f4 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0103aec:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103af1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103af8:	00 
c0103af9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103b00:	00 
c0103b01:	89 04 24             	mov    %eax,(%esp)
c0103b04:	e8 3e fd ff ff       	call   c0103847 <get_page>
c0103b09:	85 c0                	test   %eax,%eax
c0103b0b:	74 24                	je     c0103b31 <check_pgdir+0xb6>
c0103b0d:	c7 44 24 0c c4 6d 10 	movl   $0xc0106dc4,0xc(%esp)
c0103b14:	c0 
c0103b15:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103b1c:	c0 
c0103b1d:	c7 44 24 04 ee 01 00 	movl   $0x1ee,0x4(%esp)
c0103b24:	00 
c0103b25:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103b2c:	e8 c3 c8 ff ff       	call   c01003f4 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0103b31:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103b38:	e8 d0 f4 ff ff       	call   c010300d <alloc_pages>
c0103b3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0103b40:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103b45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103b4c:	00 
c0103b4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b54:	00 
c0103b55:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103b58:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103b5c:	89 04 24             	mov    %eax,(%esp)
c0103b5f:	e8 e3 fd ff ff       	call   c0103947 <page_insert>
c0103b64:	85 c0                	test   %eax,%eax
c0103b66:	74 24                	je     c0103b8c <check_pgdir+0x111>
c0103b68:	c7 44 24 0c ec 6d 10 	movl   $0xc0106dec,0xc(%esp)
c0103b6f:	c0 
c0103b70:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103b77:	c0 
c0103b78:	c7 44 24 04 f2 01 00 	movl   $0x1f2,0x4(%esp)
c0103b7f:	00 
c0103b80:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103b87:	e8 68 c8 ff ff       	call   c01003f4 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0103b8c:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103b91:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103b98:	00 
c0103b99:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103ba0:	00 
c0103ba1:	89 04 24             	mov    %eax,(%esp)
c0103ba4:	e8 5e fb ff ff       	call   c0103707 <get_pte>
c0103ba9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103bac:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103bb0:	75 24                	jne    c0103bd6 <check_pgdir+0x15b>
c0103bb2:	c7 44 24 0c 18 6e 10 	movl   $0xc0106e18,0xc(%esp)
c0103bb9:	c0 
c0103bba:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103bc1:	c0 
c0103bc2:	c7 44 24 04 f5 01 00 	movl   $0x1f5,0x4(%esp)
c0103bc9:	00 
c0103bca:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103bd1:	e8 1e c8 ff ff       	call   c01003f4 <__panic>
    assert(pte2page(*ptep) == p1);
c0103bd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103bd9:	8b 00                	mov    (%eax),%eax
c0103bdb:	89 04 24             	mov    %eax,(%esp)
c0103bde:	e8 cf f1 ff ff       	call   c0102db2 <pte2page>
c0103be3:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103be6:	74 24                	je     c0103c0c <check_pgdir+0x191>
c0103be8:	c7 44 24 0c 45 6e 10 	movl   $0xc0106e45,0xc(%esp)
c0103bef:	c0 
c0103bf0:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103bf7:	c0 
c0103bf8:	c7 44 24 04 f6 01 00 	movl   $0x1f6,0x4(%esp)
c0103bff:	00 
c0103c00:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103c07:	e8 e8 c7 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p1) == 1);
c0103c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103c0f:	89 04 24             	mov    %eax,(%esp)
c0103c12:	e8 f1 f1 ff ff       	call   c0102e08 <page_ref>
c0103c17:	83 f8 01             	cmp    $0x1,%eax
c0103c1a:	74 24                	je     c0103c40 <check_pgdir+0x1c5>
c0103c1c:	c7 44 24 0c 5b 6e 10 	movl   $0xc0106e5b,0xc(%esp)
c0103c23:	c0 
c0103c24:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103c2b:	c0 
c0103c2c:	c7 44 24 04 f7 01 00 	movl   $0x1f7,0x4(%esp)
c0103c33:	00 
c0103c34:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103c3b:	e8 b4 c7 ff ff       	call   c01003f4 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0103c40:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c45:	8b 00                	mov    (%eax),%eax
c0103c47:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103c4c:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c4f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c52:	c1 e8 0c             	shr    $0xc,%eax
c0103c55:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103c58:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c0103c5d:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103c60:	72 23                	jb     c0103c85 <check_pgdir+0x20a>
c0103c62:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c65:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103c69:	c7 44 24 08 e0 6b 10 	movl   $0xc0106be0,0x8(%esp)
c0103c70:	c0 
c0103c71:	c7 44 24 04 f9 01 00 	movl   $0x1f9,0x4(%esp)
c0103c78:	00 
c0103c79:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103c80:	e8 6f c7 ff ff       	call   c01003f4 <__panic>
c0103c85:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c88:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0103c8d:	83 c0 04             	add    $0x4,%eax
c0103c90:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0103c93:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103c98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103c9f:	00 
c0103ca0:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103ca7:	00 
c0103ca8:	89 04 24             	mov    %eax,(%esp)
c0103cab:	e8 57 fa ff ff       	call   c0103707 <get_pte>
c0103cb0:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0103cb3:	74 24                	je     c0103cd9 <check_pgdir+0x25e>
c0103cb5:	c7 44 24 0c 70 6e 10 	movl   $0xc0106e70,0xc(%esp)
c0103cbc:	c0 
c0103cbd:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103cc4:	c0 
c0103cc5:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0103ccc:	00 
c0103ccd:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103cd4:	e8 1b c7 ff ff       	call   c01003f4 <__panic>

    p2 = alloc_page();
c0103cd9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ce0:	e8 28 f3 ff ff       	call   c010300d <alloc_pages>
c0103ce5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0103ce8:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103ced:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0103cf4:	00 
c0103cf5:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103cfc:	00 
c0103cfd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0103d00:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103d04:	89 04 24             	mov    %eax,(%esp)
c0103d07:	e8 3b fc ff ff       	call   c0103947 <page_insert>
c0103d0c:	85 c0                	test   %eax,%eax
c0103d0e:	74 24                	je     c0103d34 <check_pgdir+0x2b9>
c0103d10:	c7 44 24 0c 98 6e 10 	movl   $0xc0106e98,0xc(%esp)
c0103d17:	c0 
c0103d18:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103d1f:	c0 
c0103d20:	c7 44 24 04 fd 01 00 	movl   $0x1fd,0x4(%esp)
c0103d27:	00 
c0103d28:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103d2f:	e8 c0 c6 ff ff       	call   c01003f4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103d34:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103d39:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103d40:	00 
c0103d41:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103d48:	00 
c0103d49:	89 04 24             	mov    %eax,(%esp)
c0103d4c:	e8 b6 f9 ff ff       	call   c0103707 <get_pte>
c0103d51:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d54:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103d58:	75 24                	jne    c0103d7e <check_pgdir+0x303>
c0103d5a:	c7 44 24 0c d0 6e 10 	movl   $0xc0106ed0,0xc(%esp)
c0103d61:	c0 
c0103d62:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103d69:	c0 
c0103d6a:	c7 44 24 04 fe 01 00 	movl   $0x1fe,0x4(%esp)
c0103d71:	00 
c0103d72:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103d79:	e8 76 c6 ff ff       	call   c01003f4 <__panic>
    assert(*ptep & PTE_U);
c0103d7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103d81:	8b 00                	mov    (%eax),%eax
c0103d83:	83 e0 04             	and    $0x4,%eax
c0103d86:	85 c0                	test   %eax,%eax
c0103d88:	75 24                	jne    c0103dae <check_pgdir+0x333>
c0103d8a:	c7 44 24 0c 00 6f 10 	movl   $0xc0106f00,0xc(%esp)
c0103d91:	c0 
c0103d92:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103d99:	c0 
c0103d9a:	c7 44 24 04 ff 01 00 	movl   $0x1ff,0x4(%esp)
c0103da1:	00 
c0103da2:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103da9:	e8 46 c6 ff ff       	call   c01003f4 <__panic>
    assert(*ptep & PTE_W);
c0103dae:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103db1:	8b 00                	mov    (%eax),%eax
c0103db3:	83 e0 02             	and    $0x2,%eax
c0103db6:	85 c0                	test   %eax,%eax
c0103db8:	75 24                	jne    c0103dde <check_pgdir+0x363>
c0103dba:	c7 44 24 0c 0e 6f 10 	movl   $0xc0106f0e,0xc(%esp)
c0103dc1:	c0 
c0103dc2:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103dc9:	c0 
c0103dca:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0103dd1:	00 
c0103dd2:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103dd9:	e8 16 c6 ff ff       	call   c01003f4 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0103dde:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103de3:	8b 00                	mov    (%eax),%eax
c0103de5:	83 e0 04             	and    $0x4,%eax
c0103de8:	85 c0                	test   %eax,%eax
c0103dea:	75 24                	jne    c0103e10 <check_pgdir+0x395>
c0103dec:	c7 44 24 0c 1c 6f 10 	movl   $0xc0106f1c,0xc(%esp)
c0103df3:	c0 
c0103df4:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103dfb:	c0 
c0103dfc:	c7 44 24 04 01 02 00 	movl   $0x201,0x4(%esp)
c0103e03:	00 
c0103e04:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103e0b:	e8 e4 c5 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p2) == 1);
c0103e10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103e13:	89 04 24             	mov    %eax,(%esp)
c0103e16:	e8 ed ef ff ff       	call   c0102e08 <page_ref>
c0103e1b:	83 f8 01             	cmp    $0x1,%eax
c0103e1e:	74 24                	je     c0103e44 <check_pgdir+0x3c9>
c0103e20:	c7 44 24 0c 32 6f 10 	movl   $0xc0106f32,0xc(%esp)
c0103e27:	c0 
c0103e28:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103e2f:	c0 
c0103e30:	c7 44 24 04 02 02 00 	movl   $0x202,0x4(%esp)
c0103e37:	00 
c0103e38:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103e3f:	e8 b0 c5 ff ff       	call   c01003f4 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0103e44:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103e49:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0103e50:	00 
c0103e51:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0103e58:	00 
c0103e59:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0103e5c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0103e60:	89 04 24             	mov    %eax,(%esp)
c0103e63:	e8 df fa ff ff       	call   c0103947 <page_insert>
c0103e68:	85 c0                	test   %eax,%eax
c0103e6a:	74 24                	je     c0103e90 <check_pgdir+0x415>
c0103e6c:	c7 44 24 0c 44 6f 10 	movl   $0xc0106f44,0xc(%esp)
c0103e73:	c0 
c0103e74:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103e7b:	c0 
c0103e7c:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0103e83:	00 
c0103e84:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103e8b:	e8 64 c5 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p1) == 2);
c0103e90:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103e93:	89 04 24             	mov    %eax,(%esp)
c0103e96:	e8 6d ef ff ff       	call   c0102e08 <page_ref>
c0103e9b:	83 f8 02             	cmp    $0x2,%eax
c0103e9e:	74 24                	je     c0103ec4 <check_pgdir+0x449>
c0103ea0:	c7 44 24 0c 70 6f 10 	movl   $0xc0106f70,0xc(%esp)
c0103ea7:	c0 
c0103ea8:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103eaf:	c0 
c0103eb0:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0103eb7:	00 
c0103eb8:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103ebf:	e8 30 c5 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p2) == 0);
c0103ec4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ec7:	89 04 24             	mov    %eax,(%esp)
c0103eca:	e8 39 ef ff ff       	call   c0102e08 <page_ref>
c0103ecf:	85 c0                	test   %eax,%eax
c0103ed1:	74 24                	je     c0103ef7 <check_pgdir+0x47c>
c0103ed3:	c7 44 24 0c 82 6f 10 	movl   $0xc0106f82,0xc(%esp)
c0103eda:	c0 
c0103edb:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103ee2:	c0 
c0103ee3:	c7 44 24 04 06 02 00 	movl   $0x206,0x4(%esp)
c0103eea:	00 
c0103eeb:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103ef2:	e8 fd c4 ff ff       	call   c01003f4 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0103ef7:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103efc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0103f03:	00 
c0103f04:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0103f0b:	00 
c0103f0c:	89 04 24             	mov    %eax,(%esp)
c0103f0f:	e8 f3 f7 ff ff       	call   c0103707 <get_pte>
c0103f14:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103f17:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103f1b:	75 24                	jne    c0103f41 <check_pgdir+0x4c6>
c0103f1d:	c7 44 24 0c d0 6e 10 	movl   $0xc0106ed0,0xc(%esp)
c0103f24:	c0 
c0103f25:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103f2c:	c0 
c0103f2d:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0103f34:	00 
c0103f35:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103f3c:	e8 b3 c4 ff ff       	call   c01003f4 <__panic>
    assert(pte2page(*ptep) == p1);
c0103f41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f44:	8b 00                	mov    (%eax),%eax
c0103f46:	89 04 24             	mov    %eax,(%esp)
c0103f49:	e8 64 ee ff ff       	call   c0102db2 <pte2page>
c0103f4e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103f51:	74 24                	je     c0103f77 <check_pgdir+0x4fc>
c0103f53:	c7 44 24 0c 45 6e 10 	movl   $0xc0106e45,0xc(%esp)
c0103f5a:	c0 
c0103f5b:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103f62:	c0 
c0103f63:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0103f6a:	00 
c0103f6b:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103f72:	e8 7d c4 ff ff       	call   c01003f4 <__panic>
    assert((*ptep & PTE_U) == 0);
c0103f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103f7a:	8b 00                	mov    (%eax),%eax
c0103f7c:	83 e0 04             	and    $0x4,%eax
c0103f7f:	85 c0                	test   %eax,%eax
c0103f81:	74 24                	je     c0103fa7 <check_pgdir+0x52c>
c0103f83:	c7 44 24 0c 94 6f 10 	movl   $0xc0106f94,0xc(%esp)
c0103f8a:	c0 
c0103f8b:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103f92:	c0 
c0103f93:	c7 44 24 04 09 02 00 	movl   $0x209,0x4(%esp)
c0103f9a:	00 
c0103f9b:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103fa2:	e8 4d c4 ff ff       	call   c01003f4 <__panic>

    page_remove(boot_pgdir, 0x0);
c0103fa7:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0103fac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0103fb3:	00 
c0103fb4:	89 04 24             	mov    %eax,(%esp)
c0103fb7:	e8 46 f9 ff ff       	call   c0103902 <page_remove>
    assert(page_ref(p1) == 1);
c0103fbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103fbf:	89 04 24             	mov    %eax,(%esp)
c0103fc2:	e8 41 ee ff ff       	call   c0102e08 <page_ref>
c0103fc7:	83 f8 01             	cmp    $0x1,%eax
c0103fca:	74 24                	je     c0103ff0 <check_pgdir+0x575>
c0103fcc:	c7 44 24 0c 5b 6e 10 	movl   $0xc0106e5b,0xc(%esp)
c0103fd3:	c0 
c0103fd4:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0103fdb:	c0 
c0103fdc:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0103fe3:	00 
c0103fe4:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0103feb:	e8 04 c4 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p2) == 0);
c0103ff0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103ff3:	89 04 24             	mov    %eax,(%esp)
c0103ff6:	e8 0d ee ff ff       	call   c0102e08 <page_ref>
c0103ffb:	85 c0                	test   %eax,%eax
c0103ffd:	74 24                	je     c0104023 <check_pgdir+0x5a8>
c0103fff:	c7 44 24 0c 82 6f 10 	movl   $0xc0106f82,0xc(%esp)
c0104006:	c0 
c0104007:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c010400e:	c0 
c010400f:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104016:	00 
c0104017:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c010401e:	e8 d1 c3 ff ff       	call   c01003f4 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104023:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104028:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c010402f:	00 
c0104030:	89 04 24             	mov    %eax,(%esp)
c0104033:	e8 ca f8 ff ff       	call   c0103902 <page_remove>
    assert(page_ref(p1) == 0);
c0104038:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010403b:	89 04 24             	mov    %eax,(%esp)
c010403e:	e8 c5 ed ff ff       	call   c0102e08 <page_ref>
c0104043:	85 c0                	test   %eax,%eax
c0104045:	74 24                	je     c010406b <check_pgdir+0x5f0>
c0104047:	c7 44 24 0c a9 6f 10 	movl   $0xc0106fa9,0xc(%esp)
c010404e:	c0 
c010404f:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0104056:	c0 
c0104057:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c010405e:	00 
c010405f:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104066:	e8 89 c3 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p2) == 0);
c010406b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010406e:	89 04 24             	mov    %eax,(%esp)
c0104071:	e8 92 ed ff ff       	call   c0102e08 <page_ref>
c0104076:	85 c0                	test   %eax,%eax
c0104078:	74 24                	je     c010409e <check_pgdir+0x623>
c010407a:	c7 44 24 0c 82 6f 10 	movl   $0xc0106f82,0xc(%esp)
c0104081:	c0 
c0104082:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0104089:	c0 
c010408a:	c7 44 24 04 11 02 00 	movl   $0x211,0x4(%esp)
c0104091:	00 
c0104092:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104099:	e8 56 c3 ff ff       	call   c01003f4 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010409e:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01040a3:	8b 00                	mov    (%eax),%eax
c01040a5:	89 04 24             	mov    %eax,(%esp)
c01040a8:	e8 43 ed ff ff       	call   c0102df0 <pde2page>
c01040ad:	89 04 24             	mov    %eax,(%esp)
c01040b0:	e8 53 ed ff ff       	call   c0102e08 <page_ref>
c01040b5:	83 f8 01             	cmp    $0x1,%eax
c01040b8:	74 24                	je     c01040de <check_pgdir+0x663>
c01040ba:	c7 44 24 0c bc 6f 10 	movl   $0xc0106fbc,0xc(%esp)
c01040c1:	c0 
c01040c2:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01040c9:	c0 
c01040ca:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c01040d1:	00 
c01040d2:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01040d9:	e8 16 c3 ff ff       	call   c01003f4 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01040de:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01040e3:	8b 00                	mov    (%eax),%eax
c01040e5:	89 04 24             	mov    %eax,(%esp)
c01040e8:	e8 03 ed ff ff       	call   c0102df0 <pde2page>
c01040ed:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01040f4:	00 
c01040f5:	89 04 24             	mov    %eax,(%esp)
c01040f8:	e8 48 ef ff ff       	call   c0103045 <free_pages>
    boot_pgdir[0] = 0;
c01040fd:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104102:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c0104108:	c7 04 24 e3 6f 10 c0 	movl   $0xc0106fe3,(%esp)
c010410f:	e8 89 c1 ff ff       	call   c010029d <cprintf>
}
c0104114:	90                   	nop
c0104115:	c9                   	leave  
c0104116:	c3                   	ret    

c0104117 <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c0104117:	55                   	push   %ebp
c0104118:	89 e5                	mov    %esp,%ebp
c010411a:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c010411d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104124:	e9 ca 00 00 00       	jmp    c01041f3 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c0104129:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010412c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010412f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104132:	c1 e8 0c             	shr    $0xc,%eax
c0104135:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104138:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c010413d:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0104140:	72 23                	jb     c0104165 <check_boot_pgdir+0x4e>
c0104142:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104145:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104149:	c7 44 24 08 e0 6b 10 	movl   $0xc0106be0,0x8(%esp)
c0104150:	c0 
c0104151:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0104158:	00 
c0104159:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104160:	e8 8f c2 ff ff       	call   c01003f4 <__panic>
c0104165:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104168:	2d 00 00 00 40       	sub    $0x40000000,%eax
c010416d:	89 c2                	mov    %eax,%edx
c010416f:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104174:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010417b:	00 
c010417c:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104180:	89 04 24             	mov    %eax,(%esp)
c0104183:	e8 7f f5 ff ff       	call   c0103707 <get_pte>
c0104188:	89 45 e8             	mov    %eax,-0x18(%ebp)
c010418b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010418f:	75 24                	jne    c01041b5 <check_boot_pgdir+0x9e>
c0104191:	c7 44 24 0c 00 70 10 	movl   $0xc0107000,0xc(%esp)
c0104198:	c0 
c0104199:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01041a0:	c0 
c01041a1:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c01041a8:	00 
c01041a9:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01041b0:	e8 3f c2 ff ff       	call   c01003f4 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c01041b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01041b8:	8b 00                	mov    (%eax),%eax
c01041ba:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01041bf:	89 c2                	mov    %eax,%edx
c01041c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01041c4:	39 c2                	cmp    %eax,%edx
c01041c6:	74 24                	je     c01041ec <check_boot_pgdir+0xd5>
c01041c8:	c7 44 24 0c 3d 70 10 	movl   $0xc010703d,0xc(%esp)
c01041cf:	c0 
c01041d0:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01041d7:	c0 
c01041d8:	c7 44 24 04 20 02 00 	movl   $0x220,0x4(%esp)
c01041df:	00 
c01041e0:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01041e7:	e8 08 c2 ff ff       	call   c01003f4 <__panic>

static void
check_boot_pgdir(void) {
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01041ec:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01041f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01041f6:	a1 a0 be 11 c0       	mov    0xc011bea0,%eax
c01041fb:	39 c2                	cmp    %eax,%edx
c01041fd:	0f 82 26 ff ff ff    	jb     c0104129 <check_boot_pgdir+0x12>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c0104203:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c0104208:	05 ac 0f 00 00       	add    $0xfac,%eax
c010420d:	8b 00                	mov    (%eax),%eax
c010420f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104214:	89 c2                	mov    %eax,%edx
c0104216:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010421b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c010421e:	81 7d e4 ff ff ff bf 	cmpl   $0xbfffffff,-0x1c(%ebp)
c0104225:	77 23                	ja     c010424a <check_boot_pgdir+0x133>
c0104227:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010422a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010422e:	c7 44 24 08 cc 6c 10 	movl   $0xc0106ccc,0x8(%esp)
c0104235:	c0 
c0104236:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c010423d:	00 
c010423e:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104245:	e8 aa c1 ff ff       	call   c01003f4 <__panic>
c010424a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010424d:	05 00 00 00 40       	add    $0x40000000,%eax
c0104252:	39 c2                	cmp    %eax,%edx
c0104254:	74 24                	je     c010427a <check_boot_pgdir+0x163>
c0104256:	c7 44 24 0c 54 70 10 	movl   $0xc0107054,0xc(%esp)
c010425d:	c0 
c010425e:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0104265:	c0 
c0104266:	c7 44 24 04 23 02 00 	movl   $0x223,0x4(%esp)
c010426d:	00 
c010426e:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104275:	e8 7a c1 ff ff       	call   c01003f4 <__panic>

    assert(boot_pgdir[0] == 0);
c010427a:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010427f:	8b 00                	mov    (%eax),%eax
c0104281:	85 c0                	test   %eax,%eax
c0104283:	74 24                	je     c01042a9 <check_boot_pgdir+0x192>
c0104285:	c7 44 24 0c 88 70 10 	movl   $0xc0107088,0xc(%esp)
c010428c:	c0 
c010428d:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0104294:	c0 
c0104295:	c7 44 24 04 25 02 00 	movl   $0x225,0x4(%esp)
c010429c:	00 
c010429d:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01042a4:	e8 4b c1 ff ff       	call   c01003f4 <__panic>

    struct Page *p;
    p = alloc_page();
c01042a9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01042b0:	e8 58 ed ff ff       	call   c010300d <alloc_pages>
c01042b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c01042b8:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c01042bd:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c01042c4:	00 
c01042c5:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c01042cc:	00 
c01042cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01042d0:	89 54 24 04          	mov    %edx,0x4(%esp)
c01042d4:	89 04 24             	mov    %eax,(%esp)
c01042d7:	e8 6b f6 ff ff       	call   c0103947 <page_insert>
c01042dc:	85 c0                	test   %eax,%eax
c01042de:	74 24                	je     c0104304 <check_boot_pgdir+0x1ed>
c01042e0:	c7 44 24 0c 9c 70 10 	movl   $0xc010709c,0xc(%esp)
c01042e7:	c0 
c01042e8:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01042ef:	c0 
c01042f0:	c7 44 24 04 29 02 00 	movl   $0x229,0x4(%esp)
c01042f7:	00 
c01042f8:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01042ff:	e8 f0 c0 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p) == 1);
c0104304:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104307:	89 04 24             	mov    %eax,(%esp)
c010430a:	e8 f9 ea ff ff       	call   c0102e08 <page_ref>
c010430f:	83 f8 01             	cmp    $0x1,%eax
c0104312:	74 24                	je     c0104338 <check_boot_pgdir+0x221>
c0104314:	c7 44 24 0c ca 70 10 	movl   $0xc01070ca,0xc(%esp)
c010431b:	c0 
c010431c:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0104323:	c0 
c0104324:	c7 44 24 04 2a 02 00 	movl   $0x22a,0x4(%esp)
c010432b:	00 
c010432c:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104333:	e8 bc c0 ff ff       	call   c01003f4 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c0104338:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010433d:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0104344:	00 
c0104345:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010434c:	00 
c010434d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104350:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104354:	89 04 24             	mov    %eax,(%esp)
c0104357:	e8 eb f5 ff ff       	call   c0103947 <page_insert>
c010435c:	85 c0                	test   %eax,%eax
c010435e:	74 24                	je     c0104384 <check_boot_pgdir+0x26d>
c0104360:	c7 44 24 0c dc 70 10 	movl   $0xc01070dc,0xc(%esp)
c0104367:	c0 
c0104368:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c010436f:	c0 
c0104370:	c7 44 24 04 2b 02 00 	movl   $0x22b,0x4(%esp)
c0104377:	00 
c0104378:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c010437f:	e8 70 c0 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p) == 2);
c0104384:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104387:	89 04 24             	mov    %eax,(%esp)
c010438a:	e8 79 ea ff ff       	call   c0102e08 <page_ref>
c010438f:	83 f8 02             	cmp    $0x2,%eax
c0104392:	74 24                	je     c01043b8 <check_boot_pgdir+0x2a1>
c0104394:	c7 44 24 0c 13 71 10 	movl   $0xc0107113,0xc(%esp)
c010439b:	c0 
c010439c:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01043a3:	c0 
c01043a4:	c7 44 24 04 2c 02 00 	movl   $0x22c,0x4(%esp)
c01043ab:	00 
c01043ac:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c01043b3:	e8 3c c0 ff ff       	call   c01003f4 <__panic>

    const char *str = "ucore: Hello world!!";
c01043b8:	c7 45 dc 24 71 10 c0 	movl   $0xc0107124,-0x24(%ebp)
    strcpy((void *)0x100, str);
c01043bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01043c2:	89 44 24 04          	mov    %eax,0x4(%esp)
c01043c6:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01043cd:	e8 df 15 00 00       	call   c01059b1 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01043d2:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01043d9:	00 
c01043da:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01043e1:	e8 42 16 00 00       	call   c0105a28 <strcmp>
c01043e6:	85 c0                	test   %eax,%eax
c01043e8:	74 24                	je     c010440e <check_boot_pgdir+0x2f7>
c01043ea:	c7 44 24 0c 3c 71 10 	movl   $0xc010713c,0xc(%esp)
c01043f1:	c0 
c01043f2:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c01043f9:	c0 
c01043fa:	c7 44 24 04 30 02 00 	movl   $0x230,0x4(%esp)
c0104401:	00 
c0104402:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104409:	e8 e6 bf ff ff       	call   c01003f4 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c010440e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104411:	89 04 24             	mov    %eax,(%esp)
c0104414:	e8 45 e9 ff ff       	call   c0102d5e <page2kva>
c0104419:	05 00 01 00 00       	add    $0x100,%eax
c010441e:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c0104421:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c0104428:	e8 2e 15 00 00       	call   c010595b <strlen>
c010442d:	85 c0                	test   %eax,%eax
c010442f:	74 24                	je     c0104455 <check_boot_pgdir+0x33e>
c0104431:	c7 44 24 0c 74 71 10 	movl   $0xc0107174,0xc(%esp)
c0104438:	c0 
c0104439:	c7 44 24 08 15 6d 10 	movl   $0xc0106d15,0x8(%esp)
c0104440:	c0 
c0104441:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c0104448:	00 
c0104449:	c7 04 24 f0 6c 10 c0 	movl   $0xc0106cf0,(%esp)
c0104450:	e8 9f bf ff ff       	call   c01003f4 <__panic>

    free_page(p);
c0104455:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010445c:	00 
c010445d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104460:	89 04 24             	mov    %eax,(%esp)
c0104463:	e8 dd eb ff ff       	call   c0103045 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c0104468:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010446d:	8b 00                	mov    (%eax),%eax
c010446f:	89 04 24             	mov    %eax,(%esp)
c0104472:	e8 79 e9 ff ff       	call   c0102df0 <pde2page>
c0104477:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010447e:	00 
c010447f:	89 04 24             	mov    %eax,(%esp)
c0104482:	e8 be eb ff ff       	call   c0103045 <free_pages>
    boot_pgdir[0] = 0;
c0104487:	a1 e0 89 11 c0       	mov    0xc01189e0,%eax
c010448c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0104492:	c7 04 24 98 71 10 c0 	movl   $0xc0107198,(%esp)
c0104499:	e8 ff bd ff ff       	call   c010029d <cprintf>
}
c010449e:	90                   	nop
c010449f:	c9                   	leave  
c01044a0:	c3                   	ret    

c01044a1 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c01044a1:	55                   	push   %ebp
c01044a2:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c01044a4:	8b 45 08             	mov    0x8(%ebp),%eax
c01044a7:	83 e0 04             	and    $0x4,%eax
c01044aa:	85 c0                	test   %eax,%eax
c01044ac:	74 04                	je     c01044b2 <perm2str+0x11>
c01044ae:	b0 75                	mov    $0x75,%al
c01044b0:	eb 02                	jmp    c01044b4 <perm2str+0x13>
c01044b2:	b0 2d                	mov    $0x2d,%al
c01044b4:	a2 28 bf 11 c0       	mov    %al,0xc011bf28
    str[1] = 'r';
c01044b9:	c6 05 29 bf 11 c0 72 	movb   $0x72,0xc011bf29
    str[2] = (perm & PTE_W) ? 'w' : '-';
c01044c0:	8b 45 08             	mov    0x8(%ebp),%eax
c01044c3:	83 e0 02             	and    $0x2,%eax
c01044c6:	85 c0                	test   %eax,%eax
c01044c8:	74 04                	je     c01044ce <perm2str+0x2d>
c01044ca:	b0 77                	mov    $0x77,%al
c01044cc:	eb 02                	jmp    c01044d0 <perm2str+0x2f>
c01044ce:	b0 2d                	mov    $0x2d,%al
c01044d0:	a2 2a bf 11 c0       	mov    %al,0xc011bf2a
    str[3] = '\0';
c01044d5:	c6 05 2b bf 11 c0 00 	movb   $0x0,0xc011bf2b
    return str;
c01044dc:	b8 28 bf 11 c0       	mov    $0xc011bf28,%eax
}
c01044e1:	5d                   	pop    %ebp
c01044e2:	c3                   	ret    

c01044e3 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01044e3:	55                   	push   %ebp
c01044e4:	89 e5                	mov    %esp,%ebp
c01044e6:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01044e9:	8b 45 10             	mov    0x10(%ebp),%eax
c01044ec:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01044ef:	72 0d                	jb     c01044fe <get_pgtable_items+0x1b>
        return 0;
c01044f1:	b8 00 00 00 00       	mov    $0x0,%eax
c01044f6:	e9 98 00 00 00       	jmp    c0104593 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01044fb:	ff 45 10             	incl   0x10(%ebp)
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
    if (start >= right) {
        return 0;
    }
    while (start < right && !(table[start] & PTE_P)) {
c01044fe:	8b 45 10             	mov    0x10(%ebp),%eax
c0104501:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104504:	73 18                	jae    c010451e <get_pgtable_items+0x3b>
c0104506:	8b 45 10             	mov    0x10(%ebp),%eax
c0104509:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104510:	8b 45 14             	mov    0x14(%ebp),%eax
c0104513:	01 d0                	add    %edx,%eax
c0104515:	8b 00                	mov    (%eax),%eax
c0104517:	83 e0 01             	and    $0x1,%eax
c010451a:	85 c0                	test   %eax,%eax
c010451c:	74 dd                	je     c01044fb <get_pgtable_items+0x18>
        start ++;
    }
    if (start < right) {
c010451e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104521:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104524:	73 68                	jae    c010458e <get_pgtable_items+0xab>
        if (left_store != NULL) {
c0104526:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c010452a:	74 08                	je     c0104534 <get_pgtable_items+0x51>
            *left_store = start;
c010452c:	8b 45 18             	mov    0x18(%ebp),%eax
c010452f:	8b 55 10             	mov    0x10(%ebp),%edx
c0104532:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0104534:	8b 45 10             	mov    0x10(%ebp),%eax
c0104537:	8d 50 01             	lea    0x1(%eax),%edx
c010453a:	89 55 10             	mov    %edx,0x10(%ebp)
c010453d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104544:	8b 45 14             	mov    0x14(%ebp),%eax
c0104547:	01 d0                	add    %edx,%eax
c0104549:	8b 00                	mov    (%eax),%eax
c010454b:	83 e0 07             	and    $0x7,%eax
c010454e:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104551:	eb 03                	jmp    c0104556 <get_pgtable_items+0x73>
            start ++;
c0104553:	ff 45 10             	incl   0x10(%ebp)
    if (start < right) {
        if (left_store != NULL) {
            *left_store = start;
        }
        int perm = (table[start ++] & PTE_USER);
        while (start < right && (table[start] & PTE_USER) == perm) {
c0104556:	8b 45 10             	mov    0x10(%ebp),%eax
c0104559:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010455c:	73 1d                	jae    c010457b <get_pgtable_items+0x98>
c010455e:	8b 45 10             	mov    0x10(%ebp),%eax
c0104561:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0104568:	8b 45 14             	mov    0x14(%ebp),%eax
c010456b:	01 d0                	add    %edx,%eax
c010456d:	8b 00                	mov    (%eax),%eax
c010456f:	83 e0 07             	and    $0x7,%eax
c0104572:	89 c2                	mov    %eax,%edx
c0104574:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104577:	39 c2                	cmp    %eax,%edx
c0104579:	74 d8                	je     c0104553 <get_pgtable_items+0x70>
            start ++;
        }
        if (right_store != NULL) {
c010457b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c010457f:	74 08                	je     c0104589 <get_pgtable_items+0xa6>
            *right_store = start;
c0104581:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0104584:	8b 55 10             	mov    0x10(%ebp),%edx
c0104587:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c0104589:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010458c:	eb 05                	jmp    c0104593 <get_pgtable_items+0xb0>
    }
    return 0;
c010458e:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104593:	c9                   	leave  
c0104594:	c3                   	ret    

c0104595 <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c0104595:	55                   	push   %ebp
c0104596:	89 e5                	mov    %esp,%ebp
c0104598:	57                   	push   %edi
c0104599:	56                   	push   %esi
c010459a:	53                   	push   %ebx
c010459b:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c010459e:	c7 04 24 b8 71 10 c0 	movl   $0xc01071b8,(%esp)
c01045a5:	e8 f3 bc ff ff       	call   c010029d <cprintf>
    size_t left, right = 0, perm;
c01045aa:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01045b1:	e9 fa 00 00 00       	jmp    c01046b0 <print_pgdir+0x11b>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01045b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01045b9:	89 04 24             	mov    %eax,(%esp)
c01045bc:	e8 e0 fe ff ff       	call   c01044a1 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c01045c1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01045c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045c7:	29 d1                	sub    %edx,%ecx
c01045c9:	89 ca                	mov    %ecx,%edx
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01045cb:	89 d6                	mov    %edx,%esi
c01045cd:	c1 e6 16             	shl    $0x16,%esi
c01045d0:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01045d3:	89 d3                	mov    %edx,%ebx
c01045d5:	c1 e3 16             	shl    $0x16,%ebx
c01045d8:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045db:	89 d1                	mov    %edx,%ecx
c01045dd:	c1 e1 16             	shl    $0x16,%ecx
c01045e0:	8b 7d dc             	mov    -0x24(%ebp),%edi
c01045e3:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01045e6:	29 d7                	sub    %edx,%edi
c01045e8:	89 fa                	mov    %edi,%edx
c01045ea:	89 44 24 14          	mov    %eax,0x14(%esp)
c01045ee:	89 74 24 10          	mov    %esi,0x10(%esp)
c01045f2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01045f6:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01045fa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01045fe:	c7 04 24 e9 71 10 c0 	movl   $0xc01071e9,(%esp)
c0104605:	e8 93 bc ff ff       	call   c010029d <cprintf>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
c010460a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010460d:	c1 e0 0a             	shl    $0xa,%eax
c0104610:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104613:	eb 54                	jmp    c0104669 <print_pgdir+0xd4>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c0104615:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104618:	89 04 24             	mov    %eax,(%esp)
c010461b:	e8 81 fe ff ff       	call   c01044a1 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c0104620:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0104623:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104626:	29 d1                	sub    %edx,%ecx
c0104628:	89 ca                	mov    %ecx,%edx
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c010462a:	89 d6                	mov    %edx,%esi
c010462c:	c1 e6 0c             	shl    $0xc,%esi
c010462f:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104632:	89 d3                	mov    %edx,%ebx
c0104634:	c1 e3 0c             	shl    $0xc,%ebx
c0104637:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010463a:	89 d1                	mov    %edx,%ecx
c010463c:	c1 e1 0c             	shl    $0xc,%ecx
c010463f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
c0104642:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104645:	29 d7                	sub    %edx,%edi
c0104647:	89 fa                	mov    %edi,%edx
c0104649:	89 44 24 14          	mov    %eax,0x14(%esp)
c010464d:	89 74 24 10          	mov    %esi,0x10(%esp)
c0104651:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0104655:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0104659:	89 54 24 04          	mov    %edx,0x4(%esp)
c010465d:	c7 04 24 08 72 10 c0 	movl   $0xc0107208,(%esp)
c0104664:	e8 34 bc ff ff       	call   c010029d <cprintf>
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
        size_t l, r = left * NPTEENTRY;
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0104669:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010466e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104671:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104674:	89 d3                	mov    %edx,%ebx
c0104676:	c1 e3 0a             	shl    $0xa,%ebx
c0104679:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010467c:	89 d1                	mov    %edx,%ecx
c010467e:	c1 e1 0a             	shl    $0xa,%ecx
c0104681:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0104684:	89 54 24 14          	mov    %edx,0x14(%esp)
c0104688:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010468b:	89 54 24 10          	mov    %edx,0x10(%esp)
c010468f:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0104693:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104697:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010469b:	89 0c 24             	mov    %ecx,(%esp)
c010469e:	e8 40 fe ff ff       	call   c01044e3 <get_pgtable_items>
c01046a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01046a6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01046aa:	0f 85 65 ff ff ff    	jne    c0104615 <print_pgdir+0x80>
//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
    cprintf("-------------------- BEGIN --------------------\n");
    size_t left, right = 0, perm;
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c01046b0:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c01046b5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01046b8:	8d 55 dc             	lea    -0x24(%ebp),%edx
c01046bb:	89 54 24 14          	mov    %edx,0x14(%esp)
c01046bf:	8d 55 e0             	lea    -0x20(%ebp),%edx
c01046c2:	89 54 24 10          	mov    %edx,0x10(%esp)
c01046c6:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01046ca:	89 44 24 08          	mov    %eax,0x8(%esp)
c01046ce:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01046d5:	00 
c01046d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01046dd:	e8 01 fe ff ff       	call   c01044e3 <get_pgtable_items>
c01046e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01046e5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01046e9:	0f 85 c7 fe ff ff    	jne    c01045b6 <print_pgdir+0x21>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01046ef:	c7 04 24 2c 72 10 c0 	movl   $0xc010722c,(%esp)
c01046f6:	e8 a2 bb ff ff       	call   c010029d <cprintf>
}
c01046fb:	90                   	nop
c01046fc:	83 c4 4c             	add    $0x4c,%esp
c01046ff:	5b                   	pop    %ebx
c0104700:	5e                   	pop    %esi
c0104701:	5f                   	pop    %edi
c0104702:	5d                   	pop    %ebp
c0104703:	c3                   	ret    

c0104704 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0104704:	55                   	push   %ebp
c0104705:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0104707:	8b 45 08             	mov    0x8(%ebp),%eax
c010470a:	8b 15 98 bf 11 c0    	mov    0xc011bf98,%edx
c0104710:	29 d0                	sub    %edx,%eax
c0104712:	c1 f8 02             	sar    $0x2,%eax
c0104715:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c010471b:	5d                   	pop    %ebp
c010471c:	c3                   	ret    

c010471d <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c010471d:	55                   	push   %ebp
c010471e:	89 e5                	mov    %esp,%ebp
c0104720:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0104723:	8b 45 08             	mov    0x8(%ebp),%eax
c0104726:	89 04 24             	mov    %eax,(%esp)
c0104729:	e8 d6 ff ff ff       	call   c0104704 <page2ppn>
c010472e:	c1 e0 0c             	shl    $0xc,%eax
}
c0104731:	c9                   	leave  
c0104732:	c3                   	ret    

c0104733 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0104733:	55                   	push   %ebp
c0104734:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0104736:	8b 45 08             	mov    0x8(%ebp),%eax
c0104739:	8b 00                	mov    (%eax),%eax
}
c010473b:	5d                   	pop    %ebp
c010473c:	c3                   	ret    

c010473d <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c010473d:	55                   	push   %ebp
c010473e:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0104740:	8b 45 08             	mov    0x8(%ebp),%eax
c0104743:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104746:	89 10                	mov    %edx,(%eax)
}
c0104748:	90                   	nop
c0104749:	5d                   	pop    %ebp
c010474a:	c3                   	ret    

c010474b <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c010474b:	55                   	push   %ebp
c010474c:	89 e5                	mov    %esp,%ebp
c010474e:	83 ec 10             	sub    $0x10,%esp
c0104751:	c7 45 fc 9c bf 11 c0 	movl   $0xc011bf9c,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104758:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010475b:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010475e:	89 50 04             	mov    %edx,0x4(%eax)
c0104761:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0104764:	8b 50 04             	mov    0x4(%eax),%edx
c0104767:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010476a:	89 10                	mov    %edx,(%eax)
    list_init(&free_list);
    nr_free = 0;
c010476c:	c7 05 a4 bf 11 c0 00 	movl   $0x0,0xc011bfa4
c0104773:	00 00 00 
}
c0104776:	90                   	nop
c0104777:	c9                   	leave  
c0104778:	c3                   	ret    

c0104779 <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0104779:	55                   	push   %ebp
c010477a:	89 e5                	mov    %esp,%ebp
c010477c:	83 ec 48             	sub    $0x48,%esp
    assert(n > 0);
c010477f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104783:	75 24                	jne    c01047a9 <default_init_memmap+0x30>
c0104785:	c7 44 24 0c 60 72 10 	movl   $0xc0107260,0xc(%esp)
c010478c:	c0 
c010478d:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104794:	c0 
c0104795:	c7 44 24 04 6d 00 00 	movl   $0x6d,0x4(%esp)
c010479c:	00 
c010479d:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01047a4:	e8 4b bc ff ff       	call   c01003f4 <__panic>
    struct Page *p = base;
c01047a9:	8b 45 08             	mov    0x8(%ebp),%eax
c01047ac:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c01047af:	eb 7d                	jmp    c010482e <default_init_memmap+0xb5>
        assert(PageReserved(p));
c01047b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047b4:	83 c0 04             	add    $0x4,%eax
c01047b7:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
c01047be:	89 45 e4             	mov    %eax,-0x1c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01047c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01047c4:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01047c7:	0f a3 10             	bt     %edx,(%eax)
c01047ca:	19 c0                	sbb    %eax,%eax
c01047cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return oldbit != 0;
c01047cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c01047d3:	0f 95 c0             	setne  %al
c01047d6:	0f b6 c0             	movzbl %al,%eax
c01047d9:	85 c0                	test   %eax,%eax
c01047db:	75 24                	jne    c0104801 <default_init_memmap+0x88>
c01047dd:	c7 44 24 0c 91 72 10 	movl   $0xc0107291,0xc(%esp)
c01047e4:	c0 
c01047e5:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01047ec:	c0 
c01047ed:	c7 44 24 04 70 00 00 	movl   $0x70,0x4(%esp)
c01047f4:	00 
c01047f5:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01047fc:	e8 f3 bb ff ff       	call   c01003f4 <__panic>
        p->flags = p->property = 0;
c0104801:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104804:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c010480b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010480e:	8b 50 08             	mov    0x8(%eax),%edx
c0104811:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104814:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0104817:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c010481e:	00 
c010481f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104822:	89 04 24             	mov    %eax,(%esp)
c0104825:	e8 13 ff ff ff       	call   c010473d <set_page_ref>

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c010482a:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c010482e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104831:	89 d0                	mov    %edx,%eax
c0104833:	c1 e0 02             	shl    $0x2,%eax
c0104836:	01 d0                	add    %edx,%eax
c0104838:	c1 e0 02             	shl    $0x2,%eax
c010483b:	89 c2                	mov    %eax,%edx
c010483d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104840:	01 d0                	add    %edx,%eax
c0104842:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104845:	0f 85 66 ff ff ff    	jne    c01047b1 <default_init_memmap+0x38>
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
c010484b:	8b 45 08             	mov    0x8(%ebp),%eax
c010484e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104851:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104854:	8b 45 08             	mov    0x8(%ebp),%eax
c0104857:	83 c0 04             	add    $0x4,%eax
c010485a:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104861:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104864:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0104867:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010486a:	0f ab 10             	bts    %edx,(%eax)
    nr_free += n;
c010486d:	8b 15 a4 bf 11 c0    	mov    0xc011bfa4,%edx
c0104873:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104876:	01 d0                	add    %edx,%eax
c0104878:	a3 a4 bf 11 c0       	mov    %eax,0xc011bfa4
    list_add_before(&free_list, &(base->page_link));
c010487d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104880:	83 c0 0c             	add    $0xc,%eax
c0104883:	c7 45 f0 9c bf 11 c0 	movl   $0xc011bf9c,-0x10(%ebp)
c010488a:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c010488d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104890:	8b 00                	mov    (%eax),%eax
c0104892:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104895:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0104898:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c010489b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010489e:	89 45 d0             	mov    %eax,-0x30(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01048a1:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01048a4:	8b 55 d8             	mov    -0x28(%ebp),%edx
c01048a7:	89 10                	mov    %edx,(%eax)
c01048a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01048ac:	8b 10                	mov    (%eax),%edx
c01048ae:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01048b1:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01048b4:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01048b7:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01048ba:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01048bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01048c0:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01048c3:	89 10                	mov    %edx,(%eax)
}
c01048c5:	90                   	nop
c01048c6:	c9                   	leave  
c01048c7:	c3                   	ret    

c01048c8 <default_alloc_pages>:

static struct Page *
default_alloc_pages(size_t n) {
c01048c8:	55                   	push   %ebp
c01048c9:	89 e5                	mov    %esp,%ebp
c01048cb:	83 ec 68             	sub    $0x68,%esp
    assert(n > 0);
c01048ce:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c01048d2:	75 24                	jne    c01048f8 <default_alloc_pages+0x30>
c01048d4:	c7 44 24 0c 60 72 10 	movl   $0xc0107260,0xc(%esp)
c01048db:	c0 
c01048dc:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01048e3:	c0 
c01048e4:	c7 44 24 04 7c 00 00 	movl   $0x7c,0x4(%esp)
c01048eb:	00 
c01048ec:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01048f3:	e8 fc ba ff ff       	call   c01003f4 <__panic>
    if (n > nr_free) {
c01048f8:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c01048fd:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104900:	73 0a                	jae    c010490c <default_alloc_pages+0x44>
        return NULL;
c0104902:	b8 00 00 00 00       	mov    $0x0,%eax
c0104907:	e9 49 01 00 00       	jmp    c0104a55 <default_alloc_pages+0x18d>
    }
    struct Page *page = NULL;
c010490c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0104913:	c7 45 f0 9c bf 11 c0 	movl   $0xc011bf9c,-0x10(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010491a:	eb 1c                	jmp    c0104938 <default_alloc_pages+0x70>
        struct Page *p = le2page(le, page_link);
c010491c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010491f:	83 e8 0c             	sub    $0xc,%eax
c0104922:	89 45 e8             	mov    %eax,-0x18(%ebp)
        if (p->property >= n) {
c0104925:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104928:	8b 40 08             	mov    0x8(%eax),%eax
c010492b:	3b 45 08             	cmp    0x8(%ebp),%eax
c010492e:	72 08                	jb     c0104938 <default_alloc_pages+0x70>
            page = p;
c0104930:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104933:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0104936:	eb 18                	jmp    c0104950 <default_alloc_pages+0x88>
c0104938:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010493b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010493e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0104941:	8b 40 04             	mov    0x4(%eax),%eax
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0104944:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104947:	81 7d f0 9c bf 11 c0 	cmpl   $0xc011bf9c,-0x10(%ebp)
c010494e:	75 cc                	jne    c010491c <default_alloc_pages+0x54>
        if (p->property >= n) {
            page = p;
            break;
        }
    }
    if (page != NULL) {
c0104950:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104954:	0f 84 f8 00 00 00    	je     c0104a52 <default_alloc_pages+0x18a>
        if (page->property > n) {
c010495a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495d:	8b 40 08             	mov    0x8(%eax),%eax
c0104960:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104963:	0f 86 98 00 00 00    	jbe    c0104a01 <default_alloc_pages+0x139>
            struct Page *p = page + n;
c0104969:	8b 55 08             	mov    0x8(%ebp),%edx
c010496c:	89 d0                	mov    %edx,%eax
c010496e:	c1 e0 02             	shl    $0x2,%eax
c0104971:	01 d0                	add    %edx,%eax
c0104973:	c1 e0 02             	shl    $0x2,%eax
c0104976:	89 c2                	mov    %eax,%edx
c0104978:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010497b:	01 d0                	add    %edx,%eax
c010497d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            p->property = page->property - n;
c0104980:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104983:	8b 40 08             	mov    0x8(%eax),%eax
c0104986:	2b 45 08             	sub    0x8(%ebp),%eax
c0104989:	89 c2                	mov    %eax,%edx
c010498b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010498e:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0104991:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104994:	83 c0 04             	add    $0x4,%eax
c0104997:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
c010499e:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01049a1:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01049a4:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01049a7:	0f ab 10             	bts    %edx,(%eax)
            list_add(&(page->page_link), &(p->page_link));
c01049aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01049ad:	83 c0 0c             	add    $0xc,%eax
c01049b0:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01049b3:	83 c2 0c             	add    $0xc,%edx
c01049b6:	89 55 ec             	mov    %edx,-0x14(%ebp)
c01049b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01049bc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01049bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
c01049c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01049c5:	89 45 c8             	mov    %eax,-0x38(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c01049c8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01049cb:	8b 40 04             	mov    0x4(%eax),%eax
c01049ce:	8b 55 c8             	mov    -0x38(%ebp),%edx
c01049d1:	89 55 c4             	mov    %edx,-0x3c(%ebp)
c01049d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
c01049d7:	89 55 c0             	mov    %edx,-0x40(%ebp)
c01049da:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c01049dd:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01049e0:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c01049e3:	89 10                	mov    %edx,(%eax)
c01049e5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c01049e8:	8b 10                	mov    (%eax),%edx
c01049ea:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01049ed:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c01049f0:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01049f3:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01049f6:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c01049f9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01049fc:	8b 55 c0             	mov    -0x40(%ebp),%edx
c01049ff:	89 10                	mov    %edx,(%eax)
        }
        list_del(&(page->page_link));
c0104a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a04:	83 c0 0c             	add    $0xc,%eax
c0104a07:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104a0a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104a0d:	8b 40 04             	mov    0x4(%eax),%eax
c0104a10:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104a13:	8b 12                	mov    (%edx),%edx
c0104a15:	89 55 b0             	mov    %edx,-0x50(%ebp)
c0104a18:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104a1b:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0104a1e:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0104a21:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104a24:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104a27:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0104a2a:	89 10                	mov    %edx,(%eax)
        nr_free -= n;
c0104a2c:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c0104a31:	2b 45 08             	sub    0x8(%ebp),%eax
c0104a34:	a3 a4 bf 11 c0       	mov    %eax,0xc011bfa4
        ClearPageProperty(page);
c0104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a3c:	83 c0 04             	add    $0x4,%eax
c0104a3f:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104a46:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104a49:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104a4c:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104a4f:	0f b3 10             	btr    %edx,(%eax)
    }
    return page;
c0104a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104a55:	c9                   	leave  
c0104a56:	c3                   	ret    

c0104a57 <default_free_pages>:

static void
default_free_pages(struct Page *base, size_t n) {
c0104a57:	55                   	push   %ebp
c0104a58:	89 e5                	mov    %esp,%ebp
c0104a5a:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0104a60:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0104a64:	75 24                	jne    c0104a8a <default_free_pages+0x33>
c0104a66:	c7 44 24 0c 60 72 10 	movl   $0xc0107260,0xc(%esp)
c0104a6d:	c0 
c0104a6e:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104a75:	c0 
c0104a76:	c7 44 24 04 99 00 00 	movl   $0x99,0x4(%esp)
c0104a7d:	00 
c0104a7e:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104a85:	e8 6a b9 ff ff       	call   c01003f4 <__panic>
    struct Page *p = base;
c0104a8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0104a8d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0104a90:	e9 9d 00 00 00       	jmp    c0104b32 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0104a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a98:	83 c0 04             	add    $0x4,%eax
c0104a9b:	c7 45 c0 00 00 00 00 	movl   $0x0,-0x40(%ebp)
c0104aa2:	89 45 bc             	mov    %eax,-0x44(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104aa5:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104aa8:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0104aab:	0f a3 10             	bt     %edx,(%eax)
c0104aae:	19 c0                	sbb    %eax,%eax
c0104ab0:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c0104ab3:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c0104ab7:	0f 95 c0             	setne  %al
c0104aba:	0f b6 c0             	movzbl %al,%eax
c0104abd:	85 c0                	test   %eax,%eax
c0104abf:	75 2c                	jne    c0104aed <default_free_pages+0x96>
c0104ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104ac4:	83 c0 04             	add    $0x4,%eax
c0104ac7:	c7 45 ec 01 00 00 00 	movl   $0x1,-0x14(%ebp)
c0104ace:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0104ad1:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104ad4:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0104ad7:	0f a3 10             	bt     %edx,(%eax)
c0104ada:	19 c0                	sbb    %eax,%eax
c0104adc:	89 45 b0             	mov    %eax,-0x50(%ebp)
    return oldbit != 0;
c0104adf:	83 7d b0 00          	cmpl   $0x0,-0x50(%ebp)
c0104ae3:	0f 95 c0             	setne  %al
c0104ae6:	0f b6 c0             	movzbl %al,%eax
c0104ae9:	85 c0                	test   %eax,%eax
c0104aeb:	74 24                	je     c0104b11 <default_free_pages+0xba>
c0104aed:	c7 44 24 0c a4 72 10 	movl   $0xc01072a4,0xc(%esp)
c0104af4:	c0 
c0104af5:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104afc:	c0 
c0104afd:	c7 44 24 04 9c 00 00 	movl   $0x9c,0x4(%esp)
c0104b04:	00 
c0104b05:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104b0c:	e8 e3 b8 ff ff       	call   c01003f4 <__panic>
        p->flags=0;
c0104b11:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b14:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0104b1b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b22:	00 
c0104b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104b26:	89 04 24             	mov    %eax,(%esp)
c0104b29:	e8 0f fc ff ff       	call   c010473d <set_page_ref>

static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
c0104b2e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0104b32:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b35:	89 d0                	mov    %edx,%eax
c0104b37:	c1 e0 02             	shl    $0x2,%eax
c0104b3a:	01 d0                	add    %edx,%eax
c0104b3c:	c1 e0 02             	shl    $0x2,%eax
c0104b3f:	89 c2                	mov    %eax,%edx
c0104b41:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b44:	01 d0                	add    %edx,%eax
c0104b46:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104b49:	0f 85 46 ff ff ff    	jne    c0104a95 <default_free_pages+0x3e>
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags=0;
        set_page_ref(p, 0);
    }
    base->property = n;
c0104b4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b52:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104b55:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0104b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0104b5b:	83 c0 04             	add    $0x4,%eax
c0104b5e:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0104b65:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void
set_bit(int nr, volatile void *addr) {
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104b68:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104b6b:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0104b6e:	0f ab 10             	bts    %edx,(%eax)
c0104b71:	c7 45 e8 9c bf 11 c0 	movl   $0xc011bf9c,-0x18(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104b78:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104b7b:	8b 40 04             	mov    0x4(%eax),%eax
    list_entry_t *le = list_next(&free_list);
c0104b7e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104b81:	e9 06 01 00 00       	jmp    c0104c8c <default_free_pages+0x235>
        p = le2page(le, page_link);
c0104b86:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b89:	83 e8 0c             	sub    $0xc,%eax
c0104b8c:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104b8f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104b92:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104b98:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0104b9b:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (base + base->property == p) {
c0104b9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ba1:	8b 50 08             	mov    0x8(%eax),%edx
c0104ba4:	89 d0                	mov    %edx,%eax
c0104ba6:	c1 e0 02             	shl    $0x2,%eax
c0104ba9:	01 d0                	add    %edx,%eax
c0104bab:	c1 e0 02             	shl    $0x2,%eax
c0104bae:	89 c2                	mov    %eax,%edx
c0104bb0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bb3:	01 d0                	add    %edx,%eax
c0104bb5:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104bb8:	75 58                	jne    c0104c12 <default_free_pages+0x1bb>
            base->property += p->property;
c0104bba:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bbd:	8b 50 08             	mov    0x8(%eax),%edx
c0104bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bc3:	8b 40 08             	mov    0x8(%eax),%eax
c0104bc6:	01 c2                	add    %eax,%edx
c0104bc8:	8b 45 08             	mov    0x8(%ebp),%eax
c0104bcb:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0104bce:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bd1:	83 c0 04             	add    $0x4,%eax
c0104bd4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c0104bdb:	89 45 a0             	mov    %eax,-0x60(%ebp)
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void
clear_bit(int nr, volatile void *addr) {
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0104bde:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0104be1:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104be4:	0f b3 10             	btr    %edx,(%eax)
            list_del(&(p->page_link));
c0104be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104bea:	83 c0 0c             	add    $0xc,%eax
c0104bed:	89 45 dc             	mov    %eax,-0x24(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104bf0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0104bf3:	8b 40 04             	mov    0x4(%eax),%eax
c0104bf6:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104bf9:	8b 12                	mov    (%edx),%edx
c0104bfb:	89 55 a8             	mov    %edx,-0x58(%ebp)
c0104bfe:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104c01:	8b 45 a8             	mov    -0x58(%ebp),%eax
c0104c04:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0104c07:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104c0a:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c0104c0d:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0104c10:	89 10                	mov    %edx,(%eax)
        }
        if (p + p->property == base) {
c0104c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c15:	8b 50 08             	mov    0x8(%eax),%edx
c0104c18:	89 d0                	mov    %edx,%eax
c0104c1a:	c1 e0 02             	shl    $0x2,%eax
c0104c1d:	01 d0                	add    %edx,%eax
c0104c1f:	c1 e0 02             	shl    $0x2,%eax
c0104c22:	89 c2                	mov    %eax,%edx
c0104c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c27:	01 d0                	add    %edx,%eax
c0104c29:	3b 45 08             	cmp    0x8(%ebp),%eax
c0104c2c:	75 5e                	jne    c0104c8c <default_free_pages+0x235>
            p->property += base->property;
c0104c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c31:	8b 50 08             	mov    0x8(%eax),%edx
c0104c34:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c37:	8b 40 08             	mov    0x8(%eax),%eax
c0104c3a:	01 c2                	add    %eax,%edx
c0104c3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c3f:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0104c42:	8b 45 08             	mov    0x8(%ebp),%eax
c0104c45:	83 c0 04             	add    $0x4,%eax
c0104c48:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0104c4f:	89 45 94             	mov    %eax,-0x6c(%ebp)
c0104c52:	8b 45 94             	mov    -0x6c(%ebp),%eax
c0104c55:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104c58:	0f b3 10             	btr    %edx,(%eax)
            base = p;
c0104c5b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c5e:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0104c61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104c64:	83 c0 0c             	add    $0xc,%eax
c0104c67:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Note: list_empty() on @listelm does not return true after this, the entry is
 * in an undefined state.
 * */
static inline void
list_del(list_entry_t *listelm) {
    __list_del(listelm->prev, listelm->next);
c0104c6a:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104c6d:	8b 40 04             	mov    0x4(%eax),%eax
c0104c70:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0104c73:	8b 12                	mov    (%edx),%edx
c0104c75:	89 55 9c             	mov    %edx,-0x64(%ebp)
c0104c78:	89 45 98             	mov    %eax,-0x68(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0104c7b:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0104c7e:	8b 55 98             	mov    -0x68(%ebp),%edx
c0104c81:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0104c84:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104c87:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104c8a:	89 10                	mov    %edx,(%eax)
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    list_entry_t *le = list_next(&free_list);
    while (le != &free_list) {
c0104c8c:	81 7d f0 9c bf 11 c0 	cmpl   $0xc011bf9c,-0x10(%ebp)
c0104c93:	0f 85 ed fe ff ff    	jne    c0104b86 <default_free_pages+0x12f>
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
c0104c99:	8b 15 a4 bf 11 c0    	mov    0xc011bfa4,%edx
c0104c9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104ca2:	01 d0                	add    %edx,%eax
c0104ca4:	a3 a4 bf 11 c0       	mov    %eax,0xc011bfa4
c0104ca9:	c7 45 d0 9c bf 11 c0 	movl   $0xc011bf9c,-0x30(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c0104cb0:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104cb3:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c0104cb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c0104cb9:	eb 74                	jmp    c0104d2f <default_free_pages+0x2d8>
        p = le2page(le, page_link);
c0104cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104cbe:	83 e8 0c             	sub    $0xc,%eax
c0104cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c0104cc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cc7:	8b 50 08             	mov    0x8(%eax),%edx
c0104cca:	89 d0                	mov    %edx,%eax
c0104ccc:	c1 e0 02             	shl    $0x2,%eax
c0104ccf:	01 d0                	add    %edx,%eax
c0104cd1:	c1 e0 02             	shl    $0x2,%eax
c0104cd4:	89 c2                	mov    %eax,%edx
c0104cd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cd9:	01 d0                	add    %edx,%eax
c0104cdb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104cde:	77 40                	ja     c0104d20 <default_free_pages+0x2c9>
            assert(base + base->property != p);
c0104ce0:	8b 45 08             	mov    0x8(%ebp),%eax
c0104ce3:	8b 50 08             	mov    0x8(%eax),%edx
c0104ce6:	89 d0                	mov    %edx,%eax
c0104ce8:	c1 e0 02             	shl    $0x2,%eax
c0104ceb:	01 d0                	add    %edx,%eax
c0104ced:	c1 e0 02             	shl    $0x2,%eax
c0104cf0:	89 c2                	mov    %eax,%edx
c0104cf2:	8b 45 08             	mov    0x8(%ebp),%eax
c0104cf5:	01 d0                	add    %edx,%eax
c0104cf7:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104cfa:	75 3e                	jne    c0104d3a <default_free_pages+0x2e3>
c0104cfc:	c7 44 24 0c c9 72 10 	movl   $0xc01072c9,0xc(%esp)
c0104d03:	c0 
c0104d04:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104d0b:	c0 
c0104d0c:	c7 44 24 04 b7 00 00 	movl   $0xb7,0x4(%esp)
c0104d13:	00 
c0104d14:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104d1b:	e8 d4 b6 ff ff       	call   c01003f4 <__panic>
c0104d20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d23:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104d26:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104d29:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c0104d2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
            list_del(&(p->page_link));
        }
    }
    nr_free += n;
    le = list_next(&free_list);
    while (le != &free_list) {
c0104d2f:	81 7d f0 9c bf 11 c0 	cmpl   $0xc011bf9c,-0x10(%ebp)
c0104d36:	75 83                	jne    c0104cbb <default_free_pages+0x264>
c0104d38:	eb 01                	jmp    c0104d3b <default_free_pages+0x2e4>
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            assert(base + base->property != p);
            break;
c0104d3a:	90                   	nop
        }
        le = list_next(le);
    }
    list_add_before(le, &(base->page_link));
c0104d3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0104d3e:	8d 50 0c             	lea    0xc(%eax),%edx
c0104d41:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d44:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c0104d47:	89 55 90             	mov    %edx,-0x70(%ebp)
 * Insert the new element @elm *before* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_before(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm->prev, listelm);
c0104d4a:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d4d:	8b 00                	mov    (%eax),%eax
c0104d4f:	8b 55 90             	mov    -0x70(%ebp),%edx
c0104d52:	89 55 8c             	mov    %edx,-0x74(%ebp)
c0104d55:	89 45 88             	mov    %eax,-0x78(%ebp)
c0104d58:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104d5b:	89 45 84             	mov    %eax,-0x7c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0104d5e:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104d61:	8b 55 8c             	mov    -0x74(%ebp),%edx
c0104d64:	89 10                	mov    %edx,(%eax)
c0104d66:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0104d69:	8b 10                	mov    (%eax),%edx
c0104d6b:	8b 45 88             	mov    -0x78(%ebp),%eax
c0104d6e:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0104d71:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104d74:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0104d77:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0104d7a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0104d7d:	8b 55 88             	mov    -0x78(%ebp),%edx
c0104d80:	89 10                	mov    %edx,(%eax)
}
c0104d82:	90                   	nop
c0104d83:	c9                   	leave  
c0104d84:	c3                   	ret    

c0104d85 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void) {
c0104d85:	55                   	push   %ebp
c0104d86:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0104d88:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
}
c0104d8d:	5d                   	pop    %ebp
c0104d8e:	c3                   	ret    

c0104d8f <basic_check>:

static void
basic_check(void) {
c0104d8f:	55                   	push   %ebp
c0104d90:	89 e5                	mov    %esp,%ebp
c0104d92:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0104d95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0104d9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104d9f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104da2:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104da5:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0104da8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104daf:	e8 59 e2 ff ff       	call   c010300d <alloc_pages>
c0104db4:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104db7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0104dbb:	75 24                	jne    c0104de1 <basic_check+0x52>
c0104dbd:	c7 44 24 0c e4 72 10 	movl   $0xc01072e4,0xc(%esp)
c0104dc4:	c0 
c0104dc5:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104dcc:	c0 
c0104dcd:	c7 44 24 04 c8 00 00 	movl   $0xc8,0x4(%esp)
c0104dd4:	00 
c0104dd5:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104ddc:	e8 13 b6 ff ff       	call   c01003f4 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0104de1:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104de8:	e8 20 e2 ff ff       	call   c010300d <alloc_pages>
c0104ded:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104df0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104df4:	75 24                	jne    c0104e1a <basic_check+0x8b>
c0104df6:	c7 44 24 0c 00 73 10 	movl   $0xc0107300,0xc(%esp)
c0104dfd:	c0 
c0104dfe:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104e05:	c0 
c0104e06:	c7 44 24 04 c9 00 00 	movl   $0xc9,0x4(%esp)
c0104e0d:	00 
c0104e0e:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104e15:	e8 da b5 ff ff       	call   c01003f4 <__panic>
    assert((p2 = alloc_page()) != NULL);
c0104e1a:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104e21:	e8 e7 e1 ff ff       	call   c010300d <alloc_pages>
c0104e26:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0104e29:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104e2d:	75 24                	jne    c0104e53 <basic_check+0xc4>
c0104e2f:	c7 44 24 0c 1c 73 10 	movl   $0xc010731c,0xc(%esp)
c0104e36:	c0 
c0104e37:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104e3e:	c0 
c0104e3f:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0104e46:	00 
c0104e47:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104e4e:	e8 a1 b5 ff ff       	call   c01003f4 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c0104e53:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e56:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c0104e59:	74 10                	je     c0104e6b <basic_check+0xdc>
c0104e5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e5e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104e61:	74 08                	je     c0104e6b <basic_check+0xdc>
c0104e63:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104e66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0104e69:	75 24                	jne    c0104e8f <basic_check+0x100>
c0104e6b:	c7 44 24 0c 38 73 10 	movl   $0xc0107338,0xc(%esp)
c0104e72:	c0 
c0104e73:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104e7a:	c0 
c0104e7b:	c7 44 24 04 cc 00 00 	movl   $0xcc,0x4(%esp)
c0104e82:	00 
c0104e83:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104e8a:	e8 65 b5 ff ff       	call   c01003f4 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c0104e8f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104e92:	89 04 24             	mov    %eax,(%esp)
c0104e95:	e8 99 f8 ff ff       	call   c0104733 <page_ref>
c0104e9a:	85 c0                	test   %eax,%eax
c0104e9c:	75 1e                	jne    c0104ebc <basic_check+0x12d>
c0104e9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104ea1:	89 04 24             	mov    %eax,(%esp)
c0104ea4:	e8 8a f8 ff ff       	call   c0104733 <page_ref>
c0104ea9:	85 c0                	test   %eax,%eax
c0104eab:	75 0f                	jne    c0104ebc <basic_check+0x12d>
c0104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104eb0:	89 04 24             	mov    %eax,(%esp)
c0104eb3:	e8 7b f8 ff ff       	call   c0104733 <page_ref>
c0104eb8:	85 c0                	test   %eax,%eax
c0104eba:	74 24                	je     c0104ee0 <basic_check+0x151>
c0104ebc:	c7 44 24 0c 5c 73 10 	movl   $0xc010735c,0xc(%esp)
c0104ec3:	c0 
c0104ec4:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104ecb:	c0 
c0104ecc:	c7 44 24 04 cd 00 00 	movl   $0xcd,0x4(%esp)
c0104ed3:	00 
c0104ed4:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104edb:	e8 14 b5 ff ff       	call   c01003f4 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c0104ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104ee3:	89 04 24             	mov    %eax,(%esp)
c0104ee6:	e8 32 f8 ff ff       	call   c010471d <page2pa>
c0104eeb:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c0104ef1:	c1 e2 0c             	shl    $0xc,%edx
c0104ef4:	39 d0                	cmp    %edx,%eax
c0104ef6:	72 24                	jb     c0104f1c <basic_check+0x18d>
c0104ef8:	c7 44 24 0c 98 73 10 	movl   $0xc0107398,0xc(%esp)
c0104eff:	c0 
c0104f00:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104f07:	c0 
c0104f08:	c7 44 24 04 cf 00 00 	movl   $0xcf,0x4(%esp)
c0104f0f:	00 
c0104f10:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104f17:	e8 d8 b4 ff ff       	call   c01003f4 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c0104f1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f1f:	89 04 24             	mov    %eax,(%esp)
c0104f22:	e8 f6 f7 ff ff       	call   c010471d <page2pa>
c0104f27:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c0104f2d:	c1 e2 0c             	shl    $0xc,%edx
c0104f30:	39 d0                	cmp    %edx,%eax
c0104f32:	72 24                	jb     c0104f58 <basic_check+0x1c9>
c0104f34:	c7 44 24 0c b5 73 10 	movl   $0xc01073b5,0xc(%esp)
c0104f3b:	c0 
c0104f3c:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104f43:	c0 
c0104f44:	c7 44 24 04 d0 00 00 	movl   $0xd0,0x4(%esp)
c0104f4b:	00 
c0104f4c:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104f53:	e8 9c b4 ff ff       	call   c01003f4 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c0104f58:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f5b:	89 04 24             	mov    %eax,(%esp)
c0104f5e:	e8 ba f7 ff ff       	call   c010471d <page2pa>
c0104f63:	8b 15 a0 be 11 c0    	mov    0xc011bea0,%edx
c0104f69:	c1 e2 0c             	shl    $0xc,%edx
c0104f6c:	39 d0                	cmp    %edx,%eax
c0104f6e:	72 24                	jb     c0104f94 <basic_check+0x205>
c0104f70:	c7 44 24 0c d2 73 10 	movl   $0xc01073d2,0xc(%esp)
c0104f77:	c0 
c0104f78:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104f7f:	c0 
c0104f80:	c7 44 24 04 d1 00 00 	movl   $0xd1,0x4(%esp)
c0104f87:	00 
c0104f88:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104f8f:	e8 60 b4 ff ff       	call   c01003f4 <__panic>

    list_entry_t free_list_store = free_list;
c0104f94:	a1 9c bf 11 c0       	mov    0xc011bf9c,%eax
c0104f99:	8b 15 a0 bf 11 c0    	mov    0xc011bfa0,%edx
c0104f9f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104fa2:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0104fa5:	c7 45 e4 9c bf 11 c0 	movl   $0xc011bf9c,-0x1c(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0104fac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104faf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104fb2:	89 50 04             	mov    %edx,0x4(%eax)
c0104fb5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fb8:	8b 50 04             	mov    0x4(%eax),%edx
c0104fbb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fbe:	89 10                	mov    %edx,(%eax)
c0104fc0:	c7 45 d8 9c bf 11 c0 	movl   $0xc011bf9c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0104fc7:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0104fca:	8b 40 04             	mov    0x4(%eax),%eax
c0104fcd:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c0104fd0:	0f 94 c0             	sete   %al
c0104fd3:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0104fd6:	85 c0                	test   %eax,%eax
c0104fd8:	75 24                	jne    c0104ffe <basic_check+0x26f>
c0104fda:	c7 44 24 0c ef 73 10 	movl   $0xc01073ef,0xc(%esp)
c0104fe1:	c0 
c0104fe2:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0104fe9:	c0 
c0104fea:	c7 44 24 04 d5 00 00 	movl   $0xd5,0x4(%esp)
c0104ff1:	00 
c0104ff2:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0104ff9:	e8 f6 b3 ff ff       	call   c01003f4 <__panic>

    unsigned int nr_free_store = nr_free;
c0104ffe:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c0105003:	89 45 e0             	mov    %eax,-0x20(%ebp)
    nr_free = 0;
c0105006:	c7 05 a4 bf 11 c0 00 	movl   $0x0,0xc011bfa4
c010500d:	00 00 00 

    assert(alloc_page() == NULL);
c0105010:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105017:	e8 f1 df ff ff       	call   c010300d <alloc_pages>
c010501c:	85 c0                	test   %eax,%eax
c010501e:	74 24                	je     c0105044 <basic_check+0x2b5>
c0105020:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c0105027:	c0 
c0105028:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c010502f:	c0 
c0105030:	c7 44 24 04 da 00 00 	movl   $0xda,0x4(%esp)
c0105037:	00 
c0105038:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c010503f:	e8 b0 b3 ff ff       	call   c01003f4 <__panic>

    free_page(p0);
c0105044:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010504b:	00 
c010504c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010504f:	89 04 24             	mov    %eax,(%esp)
c0105052:	e8 ee df ff ff       	call   c0103045 <free_pages>
    free_page(p1);
c0105057:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010505e:	00 
c010505f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105062:	89 04 24             	mov    %eax,(%esp)
c0105065:	e8 db df ff ff       	call   c0103045 <free_pages>
    free_page(p2);
c010506a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105071:	00 
c0105072:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105075:	89 04 24             	mov    %eax,(%esp)
c0105078:	e8 c8 df ff ff       	call   c0103045 <free_pages>
    assert(nr_free == 3);
c010507d:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c0105082:	83 f8 03             	cmp    $0x3,%eax
c0105085:	74 24                	je     c01050ab <basic_check+0x31c>
c0105087:	c7 44 24 0c 1b 74 10 	movl   $0xc010741b,0xc(%esp)
c010508e:	c0 
c010508f:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105096:	c0 
c0105097:	c7 44 24 04 df 00 00 	movl   $0xdf,0x4(%esp)
c010509e:	00 
c010509f:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01050a6:	e8 49 b3 ff ff       	call   c01003f4 <__panic>

    assert((p0 = alloc_page()) != NULL);
c01050ab:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050b2:	e8 56 df ff ff       	call   c010300d <alloc_pages>
c01050b7:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01050ba:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c01050be:	75 24                	jne    c01050e4 <basic_check+0x355>
c01050c0:	c7 44 24 0c e4 72 10 	movl   $0xc01072e4,0xc(%esp)
c01050c7:	c0 
c01050c8:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01050cf:	c0 
c01050d0:	c7 44 24 04 e1 00 00 	movl   $0xe1,0x4(%esp)
c01050d7:	00 
c01050d8:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01050df:	e8 10 b3 ff ff       	call   c01003f4 <__panic>
    assert((p1 = alloc_page()) != NULL);
c01050e4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01050eb:	e8 1d df ff ff       	call   c010300d <alloc_pages>
c01050f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01050f3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c01050f7:	75 24                	jne    c010511d <basic_check+0x38e>
c01050f9:	c7 44 24 0c 00 73 10 	movl   $0xc0107300,0xc(%esp)
c0105100:	c0 
c0105101:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105108:	c0 
c0105109:	c7 44 24 04 e2 00 00 	movl   $0xe2,0x4(%esp)
c0105110:	00 
c0105111:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105118:	e8 d7 b2 ff ff       	call   c01003f4 <__panic>
    assert((p2 = alloc_page()) != NULL);
c010511d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105124:	e8 e4 de ff ff       	call   c010300d <alloc_pages>
c0105129:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010512c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105130:	75 24                	jne    c0105156 <basic_check+0x3c7>
c0105132:	c7 44 24 0c 1c 73 10 	movl   $0xc010731c,0xc(%esp)
c0105139:	c0 
c010513a:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105141:	c0 
c0105142:	c7 44 24 04 e3 00 00 	movl   $0xe3,0x4(%esp)
c0105149:	00 
c010514a:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105151:	e8 9e b2 ff ff       	call   c01003f4 <__panic>

    assert(alloc_page() == NULL);
c0105156:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010515d:	e8 ab de ff ff       	call   c010300d <alloc_pages>
c0105162:	85 c0                	test   %eax,%eax
c0105164:	74 24                	je     c010518a <basic_check+0x3fb>
c0105166:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c010516d:	c0 
c010516e:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105175:	c0 
c0105176:	c7 44 24 04 e5 00 00 	movl   $0xe5,0x4(%esp)
c010517d:	00 
c010517e:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105185:	e8 6a b2 ff ff       	call   c01003f4 <__panic>

    free_page(p0);
c010518a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105191:	00 
c0105192:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105195:	89 04 24             	mov    %eax,(%esp)
c0105198:	e8 a8 de ff ff       	call   c0103045 <free_pages>
c010519d:	c7 45 e8 9c bf 11 c0 	movl   $0xc011bf9c,-0x18(%ebp)
c01051a4:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01051a7:	8b 40 04             	mov    0x4(%eax),%eax
c01051aa:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c01051ad:	0f 94 c0             	sete   %al
c01051b0:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c01051b3:	85 c0                	test   %eax,%eax
c01051b5:	74 24                	je     c01051db <basic_check+0x44c>
c01051b7:	c7 44 24 0c 28 74 10 	movl   $0xc0107428,0xc(%esp)
c01051be:	c0 
c01051bf:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01051c6:	c0 
c01051c7:	c7 44 24 04 e8 00 00 	movl   $0xe8,0x4(%esp)
c01051ce:	00 
c01051cf:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01051d6:	e8 19 b2 ff ff       	call   c01003f4 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c01051db:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01051e2:	e8 26 de ff ff       	call   c010300d <alloc_pages>
c01051e7:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01051ea:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01051ed:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01051f0:	74 24                	je     c0105216 <basic_check+0x487>
c01051f2:	c7 44 24 0c 40 74 10 	movl   $0xc0107440,0xc(%esp)
c01051f9:	c0 
c01051fa:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105201:	c0 
c0105202:	c7 44 24 04 eb 00 00 	movl   $0xeb,0x4(%esp)
c0105209:	00 
c010520a:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105211:	e8 de b1 ff ff       	call   c01003f4 <__panic>
    assert(alloc_page() == NULL);
c0105216:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010521d:	e8 eb dd ff ff       	call   c010300d <alloc_pages>
c0105222:	85 c0                	test   %eax,%eax
c0105224:	74 24                	je     c010524a <basic_check+0x4bb>
c0105226:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c010522d:	c0 
c010522e:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105235:	c0 
c0105236:	c7 44 24 04 ec 00 00 	movl   $0xec,0x4(%esp)
c010523d:	00 
c010523e:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105245:	e8 aa b1 ff ff       	call   c01003f4 <__panic>

    assert(nr_free == 0);
c010524a:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c010524f:	85 c0                	test   %eax,%eax
c0105251:	74 24                	je     c0105277 <basic_check+0x4e8>
c0105253:	c7 44 24 0c 59 74 10 	movl   $0xc0107459,0xc(%esp)
c010525a:	c0 
c010525b:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105262:	c0 
c0105263:	c7 44 24 04 ee 00 00 	movl   $0xee,0x4(%esp)
c010526a:	00 
c010526b:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105272:	e8 7d b1 ff ff       	call   c01003f4 <__panic>
    free_list = free_list_store;
c0105277:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010527a:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010527d:	a3 9c bf 11 c0       	mov    %eax,0xc011bf9c
c0105282:	89 15 a0 bf 11 c0    	mov    %edx,0xc011bfa0
    nr_free = nr_free_store;
c0105288:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010528b:	a3 a4 bf 11 c0       	mov    %eax,0xc011bfa4

    free_page(p);
c0105290:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105297:	00 
c0105298:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010529b:	89 04 24             	mov    %eax,(%esp)
c010529e:	e8 a2 dd ff ff       	call   c0103045 <free_pages>
    free_page(p1);
c01052a3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052aa:	00 
c01052ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01052ae:	89 04 24             	mov    %eax,(%esp)
c01052b1:	e8 8f dd ff ff       	call   c0103045 <free_pages>
    free_page(p2);
c01052b6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01052bd:	00 
c01052be:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01052c1:	89 04 24             	mov    %eax,(%esp)
c01052c4:	e8 7c dd ff ff       	call   c0103045 <free_pages>
}
c01052c9:	90                   	nop
c01052ca:	c9                   	leave  
c01052cb:	c3                   	ret    

c01052cc <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c01052cc:	55                   	push   %ebp
c01052cd:	89 e5                	mov    %esp,%ebp
c01052cf:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c01052d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01052dc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c01052e3:	c7 45 ec 9c bf 11 c0 	movl   $0xc011bf9c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c01052ea:	eb 6a                	jmp    c0105356 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c01052ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052ef:	83 e8 0c             	sub    $0xc,%eax
c01052f2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        assert(PageProperty(p));
c01052f5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01052f8:	83 c0 04             	add    $0x4,%eax
c01052fb:	c7 45 b0 01 00 00 00 	movl   $0x1,-0x50(%ebp)
c0105302:	89 45 ac             	mov    %eax,-0x54(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105305:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0105308:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010530b:	0f a3 10             	bt     %edx,(%eax)
c010530e:	19 c0                	sbb    %eax,%eax
c0105310:	89 45 a8             	mov    %eax,-0x58(%ebp)
    return oldbit != 0;
c0105313:	83 7d a8 00          	cmpl   $0x0,-0x58(%ebp)
c0105317:	0f 95 c0             	setne  %al
c010531a:	0f b6 c0             	movzbl %al,%eax
c010531d:	85 c0                	test   %eax,%eax
c010531f:	75 24                	jne    c0105345 <default_check+0x79>
c0105321:	c7 44 24 0c 66 74 10 	movl   $0xc0107466,0xc(%esp)
c0105328:	c0 
c0105329:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105330:	c0 
c0105331:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
c0105338:	00 
c0105339:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105340:	e8 af b0 ff ff       	call   c01003f4 <__panic>
        count ++, total += p->property;
c0105345:	ff 45 f4             	incl   -0xc(%ebp)
c0105348:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010534b:	8b 50 08             	mov    0x8(%eax),%edx
c010534e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105351:	01 d0                	add    %edx,%eax
c0105353:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105356:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105359:	89 45 e0             	mov    %eax,-0x20(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c010535c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010535f:	8b 40 04             	mov    0x4(%eax),%eax
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c0105362:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105365:	81 7d ec 9c bf 11 c0 	cmpl   $0xc011bf9c,-0x14(%ebp)
c010536c:	0f 85 7a ff ff ff    	jne    c01052ec <default_check+0x20>
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());
c0105372:	e8 01 dd ff ff       	call   c0103078 <nr_free_pages>
c0105377:	89 c2                	mov    %eax,%edx
c0105379:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010537c:	39 c2                	cmp    %eax,%edx
c010537e:	74 24                	je     c01053a4 <default_check+0xd8>
c0105380:	c7 44 24 0c 76 74 10 	movl   $0xc0107476,0xc(%esp)
c0105387:	c0 
c0105388:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c010538f:	c0 
c0105390:	c7 44 24 04 02 01 00 	movl   $0x102,0x4(%esp)
c0105397:	00 
c0105398:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c010539f:	e8 50 b0 ff ff       	call   c01003f4 <__panic>

    basic_check();
c01053a4:	e8 e6 f9 ff ff       	call   c0104d8f <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c01053a9:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01053b0:	e8 58 dc ff ff       	call   c010300d <alloc_pages>
c01053b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
    assert(p0 != NULL);
c01053b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01053bc:	75 24                	jne    c01053e2 <default_check+0x116>
c01053be:	c7 44 24 0c 8f 74 10 	movl   $0xc010748f,0xc(%esp)
c01053c5:	c0 
c01053c6:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01053cd:	c0 
c01053ce:	c7 44 24 04 07 01 00 	movl   $0x107,0x4(%esp)
c01053d5:	00 
c01053d6:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01053dd:	e8 12 b0 ff ff       	call   c01003f4 <__panic>
    assert(!PageProperty(p0));
c01053e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01053e5:	83 c0 04             	add    $0x4,%eax
c01053e8:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
c01053ef:	89 45 a4             	mov    %eax,-0x5c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01053f2:	8b 45 a4             	mov    -0x5c(%ebp),%eax
c01053f5:	8b 55 e8             	mov    -0x18(%ebp),%edx
c01053f8:	0f a3 10             	bt     %edx,(%eax)
c01053fb:	19 c0                	sbb    %eax,%eax
c01053fd:	89 45 a0             	mov    %eax,-0x60(%ebp)
    return oldbit != 0;
c0105400:	83 7d a0 00          	cmpl   $0x0,-0x60(%ebp)
c0105404:	0f 95 c0             	setne  %al
c0105407:	0f b6 c0             	movzbl %al,%eax
c010540a:	85 c0                	test   %eax,%eax
c010540c:	74 24                	je     c0105432 <default_check+0x166>
c010540e:	c7 44 24 0c 9a 74 10 	movl   $0xc010749a,0xc(%esp)
c0105415:	c0 
c0105416:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c010541d:	c0 
c010541e:	c7 44 24 04 08 01 00 	movl   $0x108,0x4(%esp)
c0105425:	00 
c0105426:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c010542d:	e8 c2 af ff ff       	call   c01003f4 <__panic>

    list_entry_t free_list_store = free_list;
c0105432:	a1 9c bf 11 c0       	mov    0xc011bf9c,%eax
c0105437:	8b 15 a0 bf 11 c0    	mov    0xc011bfa0,%edx
c010543d:	89 45 80             	mov    %eax,-0x80(%ebp)
c0105440:	89 55 84             	mov    %edx,-0x7c(%ebp)
c0105443:	c7 45 d0 9c bf 11 c0 	movl   $0xc011bf9c,-0x30(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c010544a:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010544d:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0105450:	89 50 04             	mov    %edx,0x4(%eax)
c0105453:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105456:	8b 50 04             	mov    0x4(%eax),%edx
c0105459:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010545c:	89 10                	mov    %edx,(%eax)
c010545e:	c7 45 d8 9c bf 11 c0 	movl   $0xc011bf9c,-0x28(%ebp)
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
c0105465:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105468:	8b 40 04             	mov    0x4(%eax),%eax
c010546b:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010546e:	0f 94 c0             	sete   %al
c0105471:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0105474:	85 c0                	test   %eax,%eax
c0105476:	75 24                	jne    c010549c <default_check+0x1d0>
c0105478:	c7 44 24 0c ef 73 10 	movl   $0xc01073ef,0xc(%esp)
c010547f:	c0 
c0105480:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105487:	c0 
c0105488:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c010548f:	00 
c0105490:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105497:	e8 58 af ff ff       	call   c01003f4 <__panic>
    assert(alloc_page() == NULL);
c010549c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01054a3:	e8 65 db ff ff       	call   c010300d <alloc_pages>
c01054a8:	85 c0                	test   %eax,%eax
c01054aa:	74 24                	je     c01054d0 <default_check+0x204>
c01054ac:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c01054b3:	c0 
c01054b4:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01054bb:	c0 
c01054bc:	c7 44 24 04 0d 01 00 	movl   $0x10d,0x4(%esp)
c01054c3:	00 
c01054c4:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01054cb:	e8 24 af ff ff       	call   c01003f4 <__panic>

    unsigned int nr_free_store = nr_free;
c01054d0:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c01054d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    nr_free = 0;
c01054d8:	c7 05 a4 bf 11 c0 00 	movl   $0x0,0xc011bfa4
c01054df:	00 00 00 

    free_pages(p0 + 2, 3);
c01054e2:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01054e5:	83 c0 28             	add    $0x28,%eax
c01054e8:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01054ef:	00 
c01054f0:	89 04 24             	mov    %eax,(%esp)
c01054f3:	e8 4d db ff ff       	call   c0103045 <free_pages>
    assert(alloc_pages(4) == NULL);
c01054f8:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c01054ff:	e8 09 db ff ff       	call   c010300d <alloc_pages>
c0105504:	85 c0                	test   %eax,%eax
c0105506:	74 24                	je     c010552c <default_check+0x260>
c0105508:	c7 44 24 0c ac 74 10 	movl   $0xc01074ac,0xc(%esp)
c010550f:	c0 
c0105510:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105517:	c0 
c0105518:	c7 44 24 04 13 01 00 	movl   $0x113,0x4(%esp)
c010551f:	00 
c0105520:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105527:	e8 c8 ae ff ff       	call   c01003f4 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c010552c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010552f:	83 c0 28             	add    $0x28,%eax
c0105532:	83 c0 04             	add    $0x4,%eax
c0105535:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
c010553c:	89 45 9c             	mov    %eax,-0x64(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c010553f:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0105542:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105545:	0f a3 10             	bt     %edx,(%eax)
c0105548:	19 c0                	sbb    %eax,%eax
c010554a:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c010554d:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0105551:	0f 95 c0             	setne  %al
c0105554:	0f b6 c0             	movzbl %al,%eax
c0105557:	85 c0                	test   %eax,%eax
c0105559:	74 0e                	je     c0105569 <default_check+0x29d>
c010555b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010555e:	83 c0 28             	add    $0x28,%eax
c0105561:	8b 40 08             	mov    0x8(%eax),%eax
c0105564:	83 f8 03             	cmp    $0x3,%eax
c0105567:	74 24                	je     c010558d <default_check+0x2c1>
c0105569:	c7 44 24 0c c4 74 10 	movl   $0xc01074c4,0xc(%esp)
c0105570:	c0 
c0105571:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105578:	c0 
c0105579:	c7 44 24 04 14 01 00 	movl   $0x114,0x4(%esp)
c0105580:	00 
c0105581:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105588:	e8 67 ae ff ff       	call   c01003f4 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010558d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0105594:	e8 74 da ff ff       	call   c010300d <alloc_pages>
c0105599:	89 45 c4             	mov    %eax,-0x3c(%ebp)
c010559c:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
c01055a0:	75 24                	jne    c01055c6 <default_check+0x2fa>
c01055a2:	c7 44 24 0c f0 74 10 	movl   $0xc01074f0,0xc(%esp)
c01055a9:	c0 
c01055aa:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01055b1:	c0 
c01055b2:	c7 44 24 04 15 01 00 	movl   $0x115,0x4(%esp)
c01055b9:	00 
c01055ba:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01055c1:	e8 2e ae ff ff       	call   c01003f4 <__panic>
    assert(alloc_page() == NULL);
c01055c6:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01055cd:	e8 3b da ff ff       	call   c010300d <alloc_pages>
c01055d2:	85 c0                	test   %eax,%eax
c01055d4:	74 24                	je     c01055fa <default_check+0x32e>
c01055d6:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c01055dd:	c0 
c01055de:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01055e5:	c0 
c01055e6:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c01055ed:	00 
c01055ee:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01055f5:	e8 fa ad ff ff       	call   c01003f4 <__panic>
    assert(p0 + 2 == p1);
c01055fa:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01055fd:	83 c0 28             	add    $0x28,%eax
c0105600:	3b 45 c4             	cmp    -0x3c(%ebp),%eax
c0105603:	74 24                	je     c0105629 <default_check+0x35d>
c0105605:	c7 44 24 0c 0e 75 10 	movl   $0xc010750e,0xc(%esp)
c010560c:	c0 
c010560d:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105614:	c0 
c0105615:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
c010561c:	00 
c010561d:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105624:	e8 cb ad ff ff       	call   c01003f4 <__panic>

    p2 = p0 + 1;
c0105629:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010562c:	83 c0 14             	add    $0x14,%eax
c010562f:	89 45 c0             	mov    %eax,-0x40(%ebp)
    free_page(p0);
c0105632:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105639:	00 
c010563a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010563d:	89 04 24             	mov    %eax,(%esp)
c0105640:	e8 00 da ff ff       	call   c0103045 <free_pages>
    free_pages(p1, 3);
c0105645:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010564c:	00 
c010564d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0105650:	89 04 24             	mov    %eax,(%esp)
c0105653:	e8 ed d9 ff ff       	call   c0103045 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c0105658:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010565b:	83 c0 04             	add    $0x4,%eax
c010565e:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0105665:	89 45 94             	mov    %eax,-0x6c(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0105668:	8b 45 94             	mov    -0x6c(%ebp),%eax
c010566b:	8b 55 c8             	mov    -0x38(%ebp),%edx
c010566e:	0f a3 10             	bt     %edx,(%eax)
c0105671:	19 c0                	sbb    %eax,%eax
c0105673:	89 45 90             	mov    %eax,-0x70(%ebp)
    return oldbit != 0;
c0105676:	83 7d 90 00          	cmpl   $0x0,-0x70(%ebp)
c010567a:	0f 95 c0             	setne  %al
c010567d:	0f b6 c0             	movzbl %al,%eax
c0105680:	85 c0                	test   %eax,%eax
c0105682:	74 0b                	je     c010568f <default_check+0x3c3>
c0105684:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105687:	8b 40 08             	mov    0x8(%eax),%eax
c010568a:	83 f8 01             	cmp    $0x1,%eax
c010568d:	74 24                	je     c01056b3 <default_check+0x3e7>
c010568f:	c7 44 24 0c 1c 75 10 	movl   $0xc010751c,0xc(%esp)
c0105696:	c0 
c0105697:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c010569e:	c0 
c010569f:	c7 44 24 04 1c 01 00 	movl   $0x11c,0x4(%esp)
c01056a6:	00 
c01056a7:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01056ae:	e8 41 ad ff ff       	call   c01003f4 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c01056b3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01056b6:	83 c0 04             	add    $0x4,%eax
c01056b9:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
c01056c0:	89 45 8c             	mov    %eax,-0x74(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01056c3:	8b 45 8c             	mov    -0x74(%ebp),%eax
c01056c6:	8b 55 bc             	mov    -0x44(%ebp),%edx
c01056c9:	0f a3 10             	bt     %edx,(%eax)
c01056cc:	19 c0                	sbb    %eax,%eax
c01056ce:	89 45 88             	mov    %eax,-0x78(%ebp)
    return oldbit != 0;
c01056d1:	83 7d 88 00          	cmpl   $0x0,-0x78(%ebp)
c01056d5:	0f 95 c0             	setne  %al
c01056d8:	0f b6 c0             	movzbl %al,%eax
c01056db:	85 c0                	test   %eax,%eax
c01056dd:	74 0b                	je     c01056ea <default_check+0x41e>
c01056df:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01056e2:	8b 40 08             	mov    0x8(%eax),%eax
c01056e5:	83 f8 03             	cmp    $0x3,%eax
c01056e8:	74 24                	je     c010570e <default_check+0x442>
c01056ea:	c7 44 24 0c 44 75 10 	movl   $0xc0107544,0xc(%esp)
c01056f1:	c0 
c01056f2:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01056f9:	c0 
c01056fa:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
c0105701:	00 
c0105702:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105709:	e8 e6 ac ff ff       	call   c01003f4 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c010570e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105715:	e8 f3 d8 ff ff       	call   c010300d <alloc_pages>
c010571a:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010571d:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105720:	83 e8 14             	sub    $0x14,%eax
c0105723:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105726:	74 24                	je     c010574c <default_check+0x480>
c0105728:	c7 44 24 0c 6a 75 10 	movl   $0xc010756a,0xc(%esp)
c010572f:	c0 
c0105730:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105737:	c0 
c0105738:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
c010573f:	00 
c0105740:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105747:	e8 a8 ac ff ff       	call   c01003f4 <__panic>
    free_page(p0);
c010574c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105753:	00 
c0105754:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105757:	89 04 24             	mov    %eax,(%esp)
c010575a:	e8 e6 d8 ff ff       	call   c0103045 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c010575f:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0105766:	e8 a2 d8 ff ff       	call   c010300d <alloc_pages>
c010576b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010576e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0105771:	83 c0 14             	add    $0x14,%eax
c0105774:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0105777:	74 24                	je     c010579d <default_check+0x4d1>
c0105779:	c7 44 24 0c 88 75 10 	movl   $0xc0107588,0xc(%esp)
c0105780:	c0 
c0105781:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105788:	c0 
c0105789:	c7 44 24 04 21 01 00 	movl   $0x121,0x4(%esp)
c0105790:	00 
c0105791:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105798:	e8 57 ac ff ff       	call   c01003f4 <__panic>

    free_pages(p0, 2);
c010579d:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c01057a4:	00 
c01057a5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01057a8:	89 04 24             	mov    %eax,(%esp)
c01057ab:	e8 95 d8 ff ff       	call   c0103045 <free_pages>
    free_page(p2);
c01057b0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01057b7:	00 
c01057b8:	8b 45 c0             	mov    -0x40(%ebp),%eax
c01057bb:	89 04 24             	mov    %eax,(%esp)
c01057be:	e8 82 d8 ff ff       	call   c0103045 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c01057c3:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c01057ca:	e8 3e d8 ff ff       	call   c010300d <alloc_pages>
c01057cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01057d2:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01057d6:	75 24                	jne    c01057fc <default_check+0x530>
c01057d8:	c7 44 24 0c a8 75 10 	movl   $0xc01075a8,0xc(%esp)
c01057df:	c0 
c01057e0:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01057e7:	c0 
c01057e8:	c7 44 24 04 26 01 00 	movl   $0x126,0x4(%esp)
c01057ef:	00 
c01057f0:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01057f7:	e8 f8 ab ff ff       	call   c01003f4 <__panic>
    assert(alloc_page() == NULL);
c01057fc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105803:	e8 05 d8 ff ff       	call   c010300d <alloc_pages>
c0105808:	85 c0                	test   %eax,%eax
c010580a:	74 24                	je     c0105830 <default_check+0x564>
c010580c:	c7 44 24 0c 06 74 10 	movl   $0xc0107406,0xc(%esp)
c0105813:	c0 
c0105814:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c010581b:	c0 
c010581c:	c7 44 24 04 27 01 00 	movl   $0x127,0x4(%esp)
c0105823:	00 
c0105824:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c010582b:	e8 c4 ab ff ff       	call   c01003f4 <__panic>

    assert(nr_free == 0);
c0105830:	a1 a4 bf 11 c0       	mov    0xc011bfa4,%eax
c0105835:	85 c0                	test   %eax,%eax
c0105837:	74 24                	je     c010585d <default_check+0x591>
c0105839:	c7 44 24 0c 59 74 10 	movl   $0xc0107459,0xc(%esp)
c0105840:	c0 
c0105841:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105848:	c0 
c0105849:	c7 44 24 04 29 01 00 	movl   $0x129,0x4(%esp)
c0105850:	00 
c0105851:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105858:	e8 97 ab ff ff       	call   c01003f4 <__panic>
    nr_free = nr_free_store;
c010585d:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0105860:	a3 a4 bf 11 c0       	mov    %eax,0xc011bfa4

    free_list = free_list_store;
c0105865:	8b 45 80             	mov    -0x80(%ebp),%eax
c0105868:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010586b:	a3 9c bf 11 c0       	mov    %eax,0xc011bf9c
c0105870:	89 15 a0 bf 11 c0    	mov    %edx,0xc011bfa0
    free_pages(p0, 5);
c0105876:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c010587d:	00 
c010587e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105881:	89 04 24             	mov    %eax,(%esp)
c0105884:	e8 bc d7 ff ff       	call   c0103045 <free_pages>

    le = &free_list;
c0105889:	c7 45 ec 9c bf 11 c0 	movl   $0xc011bf9c,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0105890:	eb 5a                	jmp    c01058ec <default_check+0x620>
        assert(le->next->prev == le && le->prev->next == le);
c0105892:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105895:	8b 40 04             	mov    0x4(%eax),%eax
c0105898:	8b 00                	mov    (%eax),%eax
c010589a:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010589d:	75 0d                	jne    c01058ac <default_check+0x5e0>
c010589f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058a2:	8b 00                	mov    (%eax),%eax
c01058a4:	8b 40 04             	mov    0x4(%eax),%eax
c01058a7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01058aa:	74 24                	je     c01058d0 <default_check+0x604>
c01058ac:	c7 44 24 0c c8 75 10 	movl   $0xc01075c8,0xc(%esp)
c01058b3:	c0 
c01058b4:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c01058bb:	c0 
c01058bc:	c7 44 24 04 31 01 00 	movl   $0x131,0x4(%esp)
c01058c3:	00 
c01058c4:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c01058cb:	e8 24 ab ff ff       	call   c01003f4 <__panic>
        struct Page *p = le2page(le, page_link);
c01058d0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058d3:	83 e8 0c             	sub    $0xc,%eax
c01058d6:	89 45 b4             	mov    %eax,-0x4c(%ebp)
        count --, total -= p->property;
c01058d9:	ff 4d f4             	decl   -0xc(%ebp)
c01058dc:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01058df:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01058e2:	8b 40 08             	mov    0x8(%eax),%eax
c01058e5:	29 c2                	sub    %eax,%edx
c01058e7:	89 d0                	mov    %edx,%eax
c01058e9:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01058ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01058ef:	89 45 b8             	mov    %eax,-0x48(%ebp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
c01058f2:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01058f5:	8b 40 04             	mov    0x4(%eax),%eax

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
c01058f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01058fb:	81 7d ec 9c bf 11 c0 	cmpl   $0xc011bf9c,-0x14(%ebp)
c0105902:	75 8e                	jne    c0105892 <default_check+0x5c6>
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
c0105904:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0105908:	74 24                	je     c010592e <default_check+0x662>
c010590a:	c7 44 24 0c f5 75 10 	movl   $0xc01075f5,0xc(%esp)
c0105911:	c0 
c0105912:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105919:	c0 
c010591a:	c7 44 24 04 35 01 00 	movl   $0x135,0x4(%esp)
c0105921:	00 
c0105922:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105929:	e8 c6 aa ff ff       	call   c01003f4 <__panic>
    assert(total == 0);
c010592e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105932:	74 24                	je     c0105958 <default_check+0x68c>
c0105934:	c7 44 24 0c 00 76 10 	movl   $0xc0107600,0xc(%esp)
c010593b:	c0 
c010593c:	c7 44 24 08 66 72 10 	movl   $0xc0107266,0x8(%esp)
c0105943:	c0 
c0105944:	c7 44 24 04 36 01 00 	movl   $0x136,0x4(%esp)
c010594b:	00 
c010594c:	c7 04 24 7b 72 10 c0 	movl   $0xc010727b,(%esp)
c0105953:	e8 9c aa ff ff       	call   c01003f4 <__panic>
}
c0105958:	90                   	nop
c0105959:	c9                   	leave  
c010595a:	c3                   	ret    

c010595b <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c010595b:	55                   	push   %ebp
c010595c:	89 e5                	mov    %esp,%ebp
c010595e:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105961:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105968:	eb 03                	jmp    c010596d <strlen+0x12>
        cnt ++;
c010596a:	ff 45 fc             	incl   -0x4(%ebp)
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
c010596d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105970:	8d 50 01             	lea    0x1(%eax),%edx
c0105973:	89 55 08             	mov    %edx,0x8(%ebp)
c0105976:	0f b6 00             	movzbl (%eax),%eax
c0105979:	84 c0                	test   %al,%al
c010597b:	75 ed                	jne    c010596a <strlen+0xf>
        cnt ++;
    }
    return cnt;
c010597d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105980:	c9                   	leave  
c0105981:	c3                   	ret    

c0105982 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105982:	55                   	push   %ebp
c0105983:	89 e5                	mov    %esp,%ebp
c0105985:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105988:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c010598f:	eb 03                	jmp    c0105994 <strnlen+0x12>
        cnt ++;
c0105991:	ff 45 fc             	incl   -0x4(%ebp)
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
c0105994:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105997:	3b 45 0c             	cmp    0xc(%ebp),%eax
c010599a:	73 10                	jae    c01059ac <strnlen+0x2a>
c010599c:	8b 45 08             	mov    0x8(%ebp),%eax
c010599f:	8d 50 01             	lea    0x1(%eax),%edx
c01059a2:	89 55 08             	mov    %edx,0x8(%ebp)
c01059a5:	0f b6 00             	movzbl (%eax),%eax
c01059a8:	84 c0                	test   %al,%al
c01059aa:	75 e5                	jne    c0105991 <strnlen+0xf>
        cnt ++;
    }
    return cnt;
c01059ac:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01059af:	c9                   	leave  
c01059b0:	c3                   	ret    

c01059b1 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c01059b1:	55                   	push   %ebp
c01059b2:	89 e5                	mov    %esp,%ebp
c01059b4:	57                   	push   %edi
c01059b5:	56                   	push   %esi
c01059b6:	83 ec 20             	sub    $0x20,%esp
c01059b9:	8b 45 08             	mov    0x8(%ebp),%eax
c01059bc:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01059bf:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c01059c5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01059c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01059cb:	89 d1                	mov    %edx,%ecx
c01059cd:	89 c2                	mov    %eax,%edx
c01059cf:	89 ce                	mov    %ecx,%esi
c01059d1:	89 d7                	mov    %edx,%edi
c01059d3:	ac                   	lods   %ds:(%esi),%al
c01059d4:	aa                   	stos   %al,%es:(%edi)
c01059d5:	84 c0                	test   %al,%al
c01059d7:	75 fa                	jne    c01059d3 <strcpy+0x22>
c01059d9:	89 fa                	mov    %edi,%edx
c01059db:	89 f1                	mov    %esi,%ecx
c01059dd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01059e0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c01059e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c01059e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
c01059e9:	90                   	nop
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c01059ea:	83 c4 20             	add    $0x20,%esp
c01059ed:	5e                   	pop    %esi
c01059ee:	5f                   	pop    %edi
c01059ef:	5d                   	pop    %ebp
c01059f0:	c3                   	ret    

c01059f1 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c01059f1:	55                   	push   %ebp
c01059f2:	89 e5                	mov    %esp,%ebp
c01059f4:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c01059f7:	8b 45 08             	mov    0x8(%ebp),%eax
c01059fa:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c01059fd:	eb 1e                	jmp    c0105a1d <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c01059ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a02:	0f b6 10             	movzbl (%eax),%edx
c0105a05:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a08:	88 10                	mov    %dl,(%eax)
c0105a0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105a0d:	0f b6 00             	movzbl (%eax),%eax
c0105a10:	84 c0                	test   %al,%al
c0105a12:	74 03                	je     c0105a17 <strncpy+0x26>
            src ++;
c0105a14:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105a17:	ff 45 fc             	incl   -0x4(%ebp)
c0105a1a:	ff 4d 10             	decl   0x10(%ebp)
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
    char *p = dst;
    while (len > 0) {
c0105a1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a21:	75 dc                	jne    c01059ff <strncpy+0xe>
        if ((*p = *src) != '\0') {
            src ++;
        }
        p ++, len --;
    }
    return dst;
c0105a23:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105a26:	c9                   	leave  
c0105a27:	c3                   	ret    

c0105a28 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105a28:	55                   	push   %ebp
c0105a29:	89 e5                	mov    %esp,%ebp
c0105a2b:	57                   	push   %edi
c0105a2c:	56                   	push   %esi
c0105a2d:	83 ec 20             	sub    $0x20,%esp
c0105a30:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a33:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105a36:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a39:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCMP
#define __HAVE_ARCH_STRCMP
static inline int
__strcmp(const char *s1, const char *s2) {
    int d0, d1, ret;
    asm volatile (
c0105a3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105a3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105a42:	89 d1                	mov    %edx,%ecx
c0105a44:	89 c2                	mov    %eax,%edx
c0105a46:	89 ce                	mov    %ecx,%esi
c0105a48:	89 d7                	mov    %edx,%edi
c0105a4a:	ac                   	lods   %ds:(%esi),%al
c0105a4b:	ae                   	scas   %es:(%edi),%al
c0105a4c:	75 08                	jne    c0105a56 <strcmp+0x2e>
c0105a4e:	84 c0                	test   %al,%al
c0105a50:	75 f8                	jne    c0105a4a <strcmp+0x22>
c0105a52:	31 c0                	xor    %eax,%eax
c0105a54:	eb 04                	jmp    c0105a5a <strcmp+0x32>
c0105a56:	19 c0                	sbb    %eax,%eax
c0105a58:	0c 01                	or     $0x1,%al
c0105a5a:	89 fa                	mov    %edi,%edx
c0105a5c:	89 f1                	mov    %esi,%ecx
c0105a5e:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105a61:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105a64:	89 55 e4             	mov    %edx,-0x1c(%ebp)
        "orb $1, %%al;"
        "3:"
        : "=a" (ret), "=&S" (d0), "=&D" (d1)
        : "1" (s1), "2" (s2)
        : "memory");
    return ret;
c0105a67:	8b 45 ec             	mov    -0x14(%ebp),%eax
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
c0105a6a:	90                   	nop
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105a6b:	83 c4 20             	add    $0x20,%esp
c0105a6e:	5e                   	pop    %esi
c0105a6f:	5f                   	pop    %edi
c0105a70:	5d                   	pop    %ebp
c0105a71:	c3                   	ret    

c0105a72 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105a72:	55                   	push   %ebp
c0105a73:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105a75:	eb 09                	jmp    c0105a80 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105a77:	ff 4d 10             	decl   0x10(%ebp)
c0105a7a:	ff 45 08             	incl   0x8(%ebp)
c0105a7d:	ff 45 0c             	incl   0xc(%ebp)
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105a80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105a84:	74 1a                	je     c0105aa0 <strncmp+0x2e>
c0105a86:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a89:	0f b6 00             	movzbl (%eax),%eax
c0105a8c:	84 c0                	test   %al,%al
c0105a8e:	74 10                	je     c0105aa0 <strncmp+0x2e>
c0105a90:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a93:	0f b6 10             	movzbl (%eax),%edx
c0105a96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a99:	0f b6 00             	movzbl (%eax),%eax
c0105a9c:	38 c2                	cmp    %al,%dl
c0105a9e:	74 d7                	je     c0105a77 <strncmp+0x5>
        n --, s1 ++, s2 ++;
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105aa0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105aa4:	74 18                	je     c0105abe <strncmp+0x4c>
c0105aa6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa9:	0f b6 00             	movzbl (%eax),%eax
c0105aac:	0f b6 d0             	movzbl %al,%edx
c0105aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ab2:	0f b6 00             	movzbl (%eax),%eax
c0105ab5:	0f b6 c0             	movzbl %al,%eax
c0105ab8:	29 c2                	sub    %eax,%edx
c0105aba:	89 d0                	mov    %edx,%eax
c0105abc:	eb 05                	jmp    c0105ac3 <strncmp+0x51>
c0105abe:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ac3:	5d                   	pop    %ebp
c0105ac4:	c3                   	ret    

c0105ac5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105ac5:	55                   	push   %ebp
c0105ac6:	89 e5                	mov    %esp,%ebp
c0105ac8:	83 ec 04             	sub    $0x4,%esp
c0105acb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ace:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ad1:	eb 13                	jmp    c0105ae6 <strchr+0x21>
        if (*s == c) {
c0105ad3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ad6:	0f b6 00             	movzbl (%eax),%eax
c0105ad9:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105adc:	75 05                	jne    c0105ae3 <strchr+0x1e>
            return (char *)s;
c0105ade:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae1:	eb 12                	jmp    c0105af5 <strchr+0x30>
        }
        s ++;
c0105ae3:	ff 45 08             	incl   0x8(%ebp)
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
c0105ae6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ae9:	0f b6 00             	movzbl (%eax),%eax
c0105aec:	84 c0                	test   %al,%al
c0105aee:	75 e3                	jne    c0105ad3 <strchr+0xe>
        if (*s == c) {
            return (char *)s;
        }
        s ++;
    }
    return NULL;
c0105af0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105af5:	c9                   	leave  
c0105af6:	c3                   	ret    

c0105af7 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105af7:	55                   	push   %ebp
c0105af8:	89 e5                	mov    %esp,%ebp
c0105afa:	83 ec 04             	sub    $0x4,%esp
c0105afd:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b00:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105b03:	eb 0e                	jmp    c0105b13 <strfind+0x1c>
        if (*s == c) {
c0105b05:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b08:	0f b6 00             	movzbl (%eax),%eax
c0105b0b:	3a 45 fc             	cmp    -0x4(%ebp),%al
c0105b0e:	74 0f                	je     c0105b1f <strfind+0x28>
            break;
        }
        s ++;
c0105b10:	ff 45 08             	incl   0x8(%ebp)
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
    while (*s != '\0') {
c0105b13:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b16:	0f b6 00             	movzbl (%eax),%eax
c0105b19:	84 c0                	test   %al,%al
c0105b1b:	75 e8                	jne    c0105b05 <strfind+0xe>
c0105b1d:	eb 01                	jmp    c0105b20 <strfind+0x29>
        if (*s == c) {
            break;
c0105b1f:	90                   	nop
        }
        s ++;
    }
    return (char *)s;
c0105b20:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105b23:	c9                   	leave  
c0105b24:	c3                   	ret    

c0105b25 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105b25:	55                   	push   %ebp
c0105b26:	89 e5                	mov    %esp,%ebp
c0105b28:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105b2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105b32:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105b39:	eb 03                	jmp    c0105b3e <strtol+0x19>
        s ++;
c0105b3b:	ff 45 08             	incl   0x8(%ebp)
strtol(const char *s, char **endptr, int base) {
    int neg = 0;
    long val = 0;

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105b3e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b41:	0f b6 00             	movzbl (%eax),%eax
c0105b44:	3c 20                	cmp    $0x20,%al
c0105b46:	74 f3                	je     c0105b3b <strtol+0x16>
c0105b48:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b4b:	0f b6 00             	movzbl (%eax),%eax
c0105b4e:	3c 09                	cmp    $0x9,%al
c0105b50:	74 e9                	je     c0105b3b <strtol+0x16>
        s ++;
    }

    // plus/minus sign
    if (*s == '+') {
c0105b52:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b55:	0f b6 00             	movzbl (%eax),%eax
c0105b58:	3c 2b                	cmp    $0x2b,%al
c0105b5a:	75 05                	jne    c0105b61 <strtol+0x3c>
        s ++;
c0105b5c:	ff 45 08             	incl   0x8(%ebp)
c0105b5f:	eb 14                	jmp    c0105b75 <strtol+0x50>
    }
    else if (*s == '-') {
c0105b61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b64:	0f b6 00             	movzbl (%eax),%eax
c0105b67:	3c 2d                	cmp    $0x2d,%al
c0105b69:	75 0a                	jne    c0105b75 <strtol+0x50>
        s ++, neg = 1;
c0105b6b:	ff 45 08             	incl   0x8(%ebp)
c0105b6e:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105b75:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105b79:	74 06                	je     c0105b81 <strtol+0x5c>
c0105b7b:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105b7f:	75 22                	jne    c0105ba3 <strtol+0x7e>
c0105b81:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b84:	0f b6 00             	movzbl (%eax),%eax
c0105b87:	3c 30                	cmp    $0x30,%al
c0105b89:	75 18                	jne    c0105ba3 <strtol+0x7e>
c0105b8b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b8e:	40                   	inc    %eax
c0105b8f:	0f b6 00             	movzbl (%eax),%eax
c0105b92:	3c 78                	cmp    $0x78,%al
c0105b94:	75 0d                	jne    c0105ba3 <strtol+0x7e>
        s += 2, base = 16;
c0105b96:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105b9a:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105ba1:	eb 29                	jmp    c0105bcc <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105ba3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105ba7:	75 16                	jne    c0105bbf <strtol+0x9a>
c0105ba9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bac:	0f b6 00             	movzbl (%eax),%eax
c0105baf:	3c 30                	cmp    $0x30,%al
c0105bb1:	75 0c                	jne    c0105bbf <strtol+0x9a>
        s ++, base = 8;
c0105bb3:	ff 45 08             	incl   0x8(%ebp)
c0105bb6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105bbd:	eb 0d                	jmp    c0105bcc <strtol+0xa7>
    }
    else if (base == 0) {
c0105bbf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105bc3:	75 07                	jne    c0105bcc <strtol+0xa7>
        base = 10;
c0105bc5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105bcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bcf:	0f b6 00             	movzbl (%eax),%eax
c0105bd2:	3c 2f                	cmp    $0x2f,%al
c0105bd4:	7e 1b                	jle    c0105bf1 <strtol+0xcc>
c0105bd6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bd9:	0f b6 00             	movzbl (%eax),%eax
c0105bdc:	3c 39                	cmp    $0x39,%al
c0105bde:	7f 11                	jg     c0105bf1 <strtol+0xcc>
            dig = *s - '0';
c0105be0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105be3:	0f b6 00             	movzbl (%eax),%eax
c0105be6:	0f be c0             	movsbl %al,%eax
c0105be9:	83 e8 30             	sub    $0x30,%eax
c0105bec:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105bef:	eb 48                	jmp    c0105c39 <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105bf1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bf4:	0f b6 00             	movzbl (%eax),%eax
c0105bf7:	3c 60                	cmp    $0x60,%al
c0105bf9:	7e 1b                	jle    c0105c16 <strtol+0xf1>
c0105bfb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bfe:	0f b6 00             	movzbl (%eax),%eax
c0105c01:	3c 7a                	cmp    $0x7a,%al
c0105c03:	7f 11                	jg     c0105c16 <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105c05:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c08:	0f b6 00             	movzbl (%eax),%eax
c0105c0b:	0f be c0             	movsbl %al,%eax
c0105c0e:	83 e8 57             	sub    $0x57,%eax
c0105c11:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105c14:	eb 23                	jmp    c0105c39 <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c0105c16:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c19:	0f b6 00             	movzbl (%eax),%eax
c0105c1c:	3c 40                	cmp    $0x40,%al
c0105c1e:	7e 3b                	jle    c0105c5b <strtol+0x136>
c0105c20:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c23:	0f b6 00             	movzbl (%eax),%eax
c0105c26:	3c 5a                	cmp    $0x5a,%al
c0105c28:	7f 31                	jg     c0105c5b <strtol+0x136>
            dig = *s - 'A' + 10;
c0105c2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c2d:	0f b6 00             	movzbl (%eax),%eax
c0105c30:	0f be c0             	movsbl %al,%eax
c0105c33:	83 e8 37             	sub    $0x37,%eax
c0105c36:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c0105c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c3c:	3b 45 10             	cmp    0x10(%ebp),%eax
c0105c3f:	7d 19                	jge    c0105c5a <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0105c41:	ff 45 08             	incl   0x8(%ebp)
c0105c44:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105c47:	0f af 45 10          	imul   0x10(%ebp),%eax
c0105c4b:	89 c2                	mov    %eax,%edx
c0105c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105c50:	01 d0                	add    %edx,%eax
c0105c52:	89 45 f8             	mov    %eax,-0x8(%ebp)
        // we don't properly detect overflow!
    }
c0105c55:	e9 72 ff ff ff       	jmp    c0105bcc <strtol+0xa7>
        }
        else {
            break;
        }
        if (dig >= base) {
            break;
c0105c5a:	90                   	nop
        }
        s ++, val = (val * base) + dig;
        // we don't properly detect overflow!
    }

    if (endptr) {
c0105c5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105c5f:	74 08                	je     c0105c69 <strtol+0x144>
        *endptr = (char *) s;
c0105c61:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c64:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c67:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c0105c69:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0105c6d:	74 07                	je     c0105c76 <strtol+0x151>
c0105c6f:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105c72:	f7 d8                	neg    %eax
c0105c74:	eb 03                	jmp    c0105c79 <strtol+0x154>
c0105c76:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c0105c79:	c9                   	leave  
c0105c7a:	c3                   	ret    

c0105c7b <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0105c7b:	55                   	push   %ebp
c0105c7c:	89 e5                	mov    %esp,%ebp
c0105c7e:	57                   	push   %edi
c0105c7f:	83 ec 24             	sub    $0x24,%esp
c0105c82:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c85:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0105c88:	0f be 45 d8          	movsbl -0x28(%ebp),%eax
c0105c8c:	8b 55 08             	mov    0x8(%ebp),%edx
c0105c8f:	89 55 f8             	mov    %edx,-0x8(%ebp)
c0105c92:	88 45 f7             	mov    %al,-0x9(%ebp)
c0105c95:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c98:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0105c9b:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0105c9e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c0105ca2:	8b 55 f8             	mov    -0x8(%ebp),%edx
c0105ca5:	89 d7                	mov    %edx,%edi
c0105ca7:	f3 aa                	rep stos %al,%es:(%edi)
c0105ca9:	89 fa                	mov    %edi,%edx
c0105cab:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105cae:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c0105cb1:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105cb4:	90                   	nop
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c0105cb5:	83 c4 24             	add    $0x24,%esp
c0105cb8:	5f                   	pop    %edi
c0105cb9:	5d                   	pop    %ebp
c0105cba:	c3                   	ret    

c0105cbb <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c0105cbb:	55                   	push   %ebp
c0105cbc:	89 e5                	mov    %esp,%ebp
c0105cbe:	57                   	push   %edi
c0105cbf:	56                   	push   %esi
c0105cc0:	53                   	push   %ebx
c0105cc1:	83 ec 30             	sub    $0x30,%esp
c0105cc4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cca:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ccd:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105cd0:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cd3:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c0105cd6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cd9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c0105cdc:	73 42                	jae    c0105d20 <memmove+0x65>
c0105cde:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105ce1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105ce4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105ce7:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105cea:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105ced:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105cf0:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105cf3:	c1 e8 02             	shr    $0x2,%eax
c0105cf6:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105cf8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105cfb:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105cfe:	89 d7                	mov    %edx,%edi
c0105d00:	89 c6                	mov    %eax,%esi
c0105d02:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105d04:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c0105d07:	83 e1 03             	and    $0x3,%ecx
c0105d0a:	74 02                	je     c0105d0e <memmove+0x53>
c0105d0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d0e:	89 f0                	mov    %esi,%eax
c0105d10:	89 fa                	mov    %edi,%edx
c0105d12:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c0105d15:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0105d18:	89 45 d0             	mov    %eax,-0x30(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105d1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
#ifdef __HAVE_ARCH_MEMMOVE
    return __memmove(dst, src, n);
c0105d1e:	eb 36                	jmp    c0105d56 <memmove+0x9b>
    asm volatile (
        "std;"
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0105d20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d23:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105d26:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d29:	01 c2                	add    %eax,%edx
c0105d2b:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d2e:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0105d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d34:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
        return __memcpy(dst, src, n);
    }
    int d0, d1, d2;
    asm volatile (
c0105d37:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105d3a:	89 c1                	mov    %eax,%ecx
c0105d3c:	89 d8                	mov    %ebx,%eax
c0105d3e:	89 d6                	mov    %edx,%esi
c0105d40:	89 c7                	mov    %eax,%edi
c0105d42:	fd                   	std    
c0105d43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d45:	fc                   	cld    
c0105d46:	89 f8                	mov    %edi,%eax
c0105d48:	89 f2                	mov    %esi,%edx
c0105d4a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0105d4d:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0105d50:	89 45 c4             	mov    %eax,-0x3c(%ebp)
        "rep; movsb;"
        "cld;"
        : "=&c" (d0), "=&S" (d1), "=&D" (d2)
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
        : "memory");
    return dst;
c0105d53:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c0105d56:	83 c4 30             	add    $0x30,%esp
c0105d59:	5b                   	pop    %ebx
c0105d5a:	5e                   	pop    %esi
c0105d5b:	5f                   	pop    %edi
c0105d5c:	5d                   	pop    %ebp
c0105d5d:	c3                   	ret    

c0105d5e <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0105d5e:	55                   	push   %ebp
c0105d5f:	89 e5                	mov    %esp,%ebp
c0105d61:	57                   	push   %edi
c0105d62:	56                   	push   %esi
c0105d63:	83 ec 20             	sub    $0x20,%esp
c0105d66:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d69:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105d6c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105d6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105d72:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d75:	89 45 ec             	mov    %eax,-0x14(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0105d78:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d7b:	c1 e8 02             	shr    $0x2,%eax
c0105d7e:	89 c1                	mov    %eax,%ecx
#ifndef __HAVE_ARCH_MEMCPY
#define __HAVE_ARCH_MEMCPY
static inline void *
__memcpy(void *dst, const void *src, size_t n) {
    int d0, d1, d2;
    asm volatile (
c0105d80:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105d83:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d86:	89 d7                	mov    %edx,%edi
c0105d88:	89 c6                	mov    %eax,%esi
c0105d8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0105d8c:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0105d8f:	83 e1 03             	and    $0x3,%ecx
c0105d92:	74 02                	je     c0105d96 <memcpy+0x38>
c0105d94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0105d96:	89 f0                	mov    %esi,%eax
c0105d98:	89 fa                	mov    %edi,%edx
c0105d9a:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105d9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0105da0:	89 45 e0             	mov    %eax,-0x20(%ebp)
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
        : "memory");
    return dst;
c0105da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
c0105da6:	90                   	nop
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c0105da7:	83 c4 20             	add    $0x20,%esp
c0105daa:	5e                   	pop    %esi
c0105dab:	5f                   	pop    %edi
c0105dac:	5d                   	pop    %ebp
c0105dad:	c3                   	ret    

c0105dae <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c0105dae:	55                   	push   %ebp
c0105daf:	89 e5                	mov    %esp,%ebp
c0105db1:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c0105db4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105db7:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c0105dba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105dbd:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c0105dc0:	eb 2e                	jmp    c0105df0 <memcmp+0x42>
        if (*s1 != *s2) {
c0105dc2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105dc5:	0f b6 10             	movzbl (%eax),%edx
c0105dc8:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dcb:	0f b6 00             	movzbl (%eax),%eax
c0105dce:	38 c2                	cmp    %al,%dl
c0105dd0:	74 18                	je     c0105dea <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105dd2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105dd5:	0f b6 00             	movzbl (%eax),%eax
c0105dd8:	0f b6 d0             	movzbl %al,%edx
c0105ddb:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0105dde:	0f b6 00             	movzbl (%eax),%eax
c0105de1:	0f b6 c0             	movzbl %al,%eax
c0105de4:	29 c2                	sub    %eax,%edx
c0105de6:	89 d0                	mov    %edx,%eax
c0105de8:	eb 18                	jmp    c0105e02 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c0105dea:	ff 45 fc             	incl   -0x4(%ebp)
c0105ded:	ff 45 f8             	incl   -0x8(%ebp)
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
    const char *s1 = (const char *)v1;
    const char *s2 = (const char *)v2;
    while (n -- > 0) {
c0105df0:	8b 45 10             	mov    0x10(%ebp),%eax
c0105df3:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105df6:	89 55 10             	mov    %edx,0x10(%ebp)
c0105df9:	85 c0                	test   %eax,%eax
c0105dfb:	75 c5                	jne    c0105dc2 <memcmp+0x14>
        if (*s1 != *s2) {
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
        }
        s1 ++, s2 ++;
    }
    return 0;
c0105dfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105e02:	c9                   	leave  
c0105e03:	c3                   	ret    

c0105e04 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c0105e04:	55                   	push   %ebp
c0105e05:	89 e5                	mov    %esp,%ebp
c0105e07:	83 ec 58             	sub    $0x58,%esp
c0105e0a:	8b 45 10             	mov    0x10(%ebp),%eax
c0105e0d:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0105e10:	8b 45 14             	mov    0x14(%ebp),%eax
c0105e13:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c0105e16:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0105e19:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105e1c:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105e1f:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c0105e22:	8b 45 18             	mov    0x18(%ebp),%eax
c0105e25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105e28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105e2b:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105e2e:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105e31:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e37:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e3a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0105e3e:	74 1c                	je     c0105e5c <printnum+0x58>
c0105e40:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e43:	ba 00 00 00 00       	mov    $0x0,%edx
c0105e48:	f7 75 e4             	divl   -0x1c(%ebp)
c0105e4b:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0105e4e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e51:	ba 00 00 00 00       	mov    $0x0,%edx
c0105e56:	f7 75 e4             	divl   -0x1c(%ebp)
c0105e59:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105e5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e62:	f7 75 e4             	divl   -0x1c(%ebp)
c0105e65:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105e68:	89 55 dc             	mov    %edx,-0x24(%ebp)
c0105e6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105e6e:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105e71:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105e74:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105e77:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105e7a:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c0105e7d:	8b 45 18             	mov    0x18(%ebp),%eax
c0105e80:	ba 00 00 00 00       	mov    $0x0,%edx
c0105e85:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105e88:	77 56                	ja     c0105ee0 <printnum+0xdc>
c0105e8a:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
c0105e8d:	72 05                	jb     c0105e94 <printnum+0x90>
c0105e8f:	3b 45 d0             	cmp    -0x30(%ebp),%eax
c0105e92:	77 4c                	ja     c0105ee0 <printnum+0xdc>
        printnum(putch, putdat, result, base, width - 1, padc);
c0105e94:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105e97:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105e9a:	8b 45 20             	mov    0x20(%ebp),%eax
c0105e9d:	89 44 24 18          	mov    %eax,0x18(%esp)
c0105ea1:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105ea5:	8b 45 18             	mov    0x18(%ebp),%eax
c0105ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105eac:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105eaf:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105eb2:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105eb6:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105eba:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ebd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ec1:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec4:	89 04 24             	mov    %eax,(%esp)
c0105ec7:	e8 38 ff ff ff       	call   c0105e04 <printnum>
c0105ecc:	eb 1b                	jmp    c0105ee9 <printnum+0xe5>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105ece:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ed1:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ed5:	8b 45 20             	mov    0x20(%ebp),%eax
c0105ed8:	89 04 24             	mov    %eax,(%esp)
c0105edb:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ede:	ff d0                	call   *%eax
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
c0105ee0:	ff 4d 1c             	decl   0x1c(%ebp)
c0105ee3:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105ee7:	7f e5                	jg     c0105ece <printnum+0xca>
            putch(padc, putdat);
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c0105ee9:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0105eec:	05 bc 76 10 c0       	add    $0xc01076bc,%eax
c0105ef1:	0f b6 00             	movzbl (%eax),%eax
c0105ef4:	0f be c0             	movsbl %al,%eax
c0105ef7:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105efa:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105efe:	89 04 24             	mov    %eax,(%esp)
c0105f01:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f04:	ff d0                	call   *%eax
}
c0105f06:	90                   	nop
c0105f07:	c9                   	leave  
c0105f08:	c3                   	ret    

c0105f09 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c0105f09:	55                   	push   %ebp
c0105f0a:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105f0c:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105f10:	7e 14                	jle    c0105f26 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c0105f12:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f15:	8b 00                	mov    (%eax),%eax
c0105f17:	8d 48 08             	lea    0x8(%eax),%ecx
c0105f1a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f1d:	89 0a                	mov    %ecx,(%edx)
c0105f1f:	8b 50 04             	mov    0x4(%eax),%edx
c0105f22:	8b 00                	mov    (%eax),%eax
c0105f24:	eb 30                	jmp    c0105f56 <getuint+0x4d>
    }
    else if (lflag) {
c0105f26:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f2a:	74 16                	je     c0105f42 <getuint+0x39>
        return va_arg(*ap, unsigned long);
c0105f2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f2f:	8b 00                	mov    (%eax),%eax
c0105f31:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f34:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f37:	89 0a                	mov    %ecx,(%edx)
c0105f39:	8b 00                	mov    (%eax),%eax
c0105f3b:	ba 00 00 00 00       	mov    $0x0,%edx
c0105f40:	eb 14                	jmp    c0105f56 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c0105f42:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f45:	8b 00                	mov    (%eax),%eax
c0105f47:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f4a:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f4d:	89 0a                	mov    %ecx,(%edx)
c0105f4f:	8b 00                	mov    (%eax),%eax
c0105f51:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105f56:	5d                   	pop    %ebp
c0105f57:	c3                   	ret    

c0105f58 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105f58:	55                   	push   %ebp
c0105f59:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105f5b:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c0105f5f:	7e 14                	jle    c0105f75 <getint+0x1d>
        return va_arg(*ap, long long);
c0105f61:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f64:	8b 00                	mov    (%eax),%eax
c0105f66:	8d 48 08             	lea    0x8(%eax),%ecx
c0105f69:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f6c:	89 0a                	mov    %ecx,(%edx)
c0105f6e:	8b 50 04             	mov    0x4(%eax),%edx
c0105f71:	8b 00                	mov    (%eax),%eax
c0105f73:	eb 28                	jmp    c0105f9d <getint+0x45>
    }
    else if (lflag) {
c0105f75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105f79:	74 12                	je     c0105f8d <getint+0x35>
        return va_arg(*ap, long);
c0105f7b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f7e:	8b 00                	mov    (%eax),%eax
c0105f80:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f83:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f86:	89 0a                	mov    %ecx,(%edx)
c0105f88:	8b 00                	mov    (%eax),%eax
c0105f8a:	99                   	cltd   
c0105f8b:	eb 10                	jmp    c0105f9d <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105f8d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f90:	8b 00                	mov    (%eax),%eax
c0105f92:	8d 48 04             	lea    0x4(%eax),%ecx
c0105f95:	8b 55 08             	mov    0x8(%ebp),%edx
c0105f98:	89 0a                	mov    %ecx,(%edx)
c0105f9a:	8b 00                	mov    (%eax),%eax
c0105f9c:	99                   	cltd   
    }
}
c0105f9d:	5d                   	pop    %ebp
c0105f9e:	c3                   	ret    

c0105f9f <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c0105f9f:	55                   	push   %ebp
c0105fa0:	89 e5                	mov    %esp,%ebp
c0105fa2:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105fa5:	8d 45 14             	lea    0x14(%ebp),%eax
c0105fa8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105fab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105fae:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105fb2:	8b 45 10             	mov    0x10(%ebp),%eax
c0105fb5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105fb9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fbc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc3:	89 04 24             	mov    %eax,(%esp)
c0105fc6:	e8 03 00 00 00       	call   c0105fce <vprintfmt>
    va_end(ap);
}
c0105fcb:	90                   	nop
c0105fcc:	c9                   	leave  
c0105fcd:	c3                   	ret    

c0105fce <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c0105fce:	55                   	push   %ebp
c0105fcf:	89 e5                	mov    %esp,%ebp
c0105fd1:	56                   	push   %esi
c0105fd2:	53                   	push   %ebx
c0105fd3:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105fd6:	eb 17                	jmp    c0105fef <vprintfmt+0x21>
            if (ch == '\0') {
c0105fd8:	85 db                	test   %ebx,%ebx
c0105fda:	0f 84 bf 03 00 00    	je     c010639f <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c0105fe0:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105fe3:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105fe7:	89 1c 24             	mov    %ebx,(%esp)
c0105fea:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fed:	ff d0                	call   *%eax
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c0105fef:	8b 45 10             	mov    0x10(%ebp),%eax
c0105ff2:	8d 50 01             	lea    0x1(%eax),%edx
c0105ff5:	89 55 10             	mov    %edx,0x10(%ebp)
c0105ff8:	0f b6 00             	movzbl (%eax),%eax
c0105ffb:	0f b6 d8             	movzbl %al,%ebx
c0105ffe:	83 fb 25             	cmp    $0x25,%ebx
c0106001:	75 d5                	jne    c0105fd8 <vprintfmt+0xa>
            }
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
c0106003:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c0106007:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c010600e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106011:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c0106014:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010601b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010601e:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c0106021:	8b 45 10             	mov    0x10(%ebp),%eax
c0106024:	8d 50 01             	lea    0x1(%eax),%edx
c0106027:	89 55 10             	mov    %edx,0x10(%ebp)
c010602a:	0f b6 00             	movzbl (%eax),%eax
c010602d:	0f b6 d8             	movzbl %al,%ebx
c0106030:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0106033:	83 f8 55             	cmp    $0x55,%eax
c0106036:	0f 87 37 03 00 00    	ja     c0106373 <vprintfmt+0x3a5>
c010603c:	8b 04 85 e0 76 10 c0 	mov    -0x3fef8920(,%eax,4),%eax
c0106043:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0106045:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0106049:	eb d6                	jmp    c0106021 <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c010604b:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010604f:	eb d0                	jmp    c0106021 <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c0106051:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0106058:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010605b:	89 d0                	mov    %edx,%eax
c010605d:	c1 e0 02             	shl    $0x2,%eax
c0106060:	01 d0                	add    %edx,%eax
c0106062:	01 c0                	add    %eax,%eax
c0106064:	01 d8                	add    %ebx,%eax
c0106066:	83 e8 30             	sub    $0x30,%eax
c0106069:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010606c:	8b 45 10             	mov    0x10(%ebp),%eax
c010606f:	0f b6 00             	movzbl (%eax),%eax
c0106072:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0106075:	83 fb 2f             	cmp    $0x2f,%ebx
c0106078:	7e 38                	jle    c01060b2 <vprintfmt+0xe4>
c010607a:	83 fb 39             	cmp    $0x39,%ebx
c010607d:	7f 33                	jg     c01060b2 <vprintfmt+0xe4>
            padc = '0';
            goto reswitch;

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010607f:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
c0106082:	eb d4                	jmp    c0106058 <vprintfmt+0x8a>
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0106084:	8b 45 14             	mov    0x14(%ebp),%eax
c0106087:	8d 50 04             	lea    0x4(%eax),%edx
c010608a:	89 55 14             	mov    %edx,0x14(%ebp)
c010608d:	8b 00                	mov    (%eax),%eax
c010608f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0106092:	eb 1f                	jmp    c01060b3 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0106094:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106098:	79 87                	jns    c0106021 <vprintfmt+0x53>
                width = 0;
c010609a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c01060a1:	e9 7b ff ff ff       	jmp    c0106021 <vprintfmt+0x53>

        case '#':
            altflag = 1;
c01060a6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c01060ad:	e9 6f ff ff ff       	jmp    c0106021 <vprintfmt+0x53>
                ch = *fmt;
                if (ch < '0' || ch > '9') {
                    break;
                }
            }
            goto process_precision;
c01060b2:	90                   	nop
        case '#':
            altflag = 1;
            goto reswitch;

        process_precision:
            if (width < 0)
c01060b3:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01060b7:	0f 89 64 ff ff ff    	jns    c0106021 <vprintfmt+0x53>
                width = precision, precision = -1;
c01060bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01060c0:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01060c3:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c01060ca:	e9 52 ff ff ff       	jmp    c0106021 <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c01060cf:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c01060d2:	e9 4a ff ff ff       	jmp    c0106021 <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01060d7:	8b 45 14             	mov    0x14(%ebp),%eax
c01060da:	8d 50 04             	lea    0x4(%eax),%edx
c01060dd:	89 55 14             	mov    %edx,0x14(%ebp)
c01060e0:	8b 00                	mov    (%eax),%eax
c01060e2:	8b 55 0c             	mov    0xc(%ebp),%edx
c01060e5:	89 54 24 04          	mov    %edx,0x4(%esp)
c01060e9:	89 04 24             	mov    %eax,(%esp)
c01060ec:	8b 45 08             	mov    0x8(%ebp),%eax
c01060ef:	ff d0                	call   *%eax
            break;
c01060f1:	e9 a4 02 00 00       	jmp    c010639a <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01060f6:	8b 45 14             	mov    0x14(%ebp),%eax
c01060f9:	8d 50 04             	lea    0x4(%eax),%edx
c01060fc:	89 55 14             	mov    %edx,0x14(%ebp)
c01060ff:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c0106101:	85 db                	test   %ebx,%ebx
c0106103:	79 02                	jns    c0106107 <vprintfmt+0x139>
                err = -err;
c0106105:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c0106107:	83 fb 06             	cmp    $0x6,%ebx
c010610a:	7f 0b                	jg     c0106117 <vprintfmt+0x149>
c010610c:	8b 34 9d a0 76 10 c0 	mov    -0x3fef8960(,%ebx,4),%esi
c0106113:	85 f6                	test   %esi,%esi
c0106115:	75 23                	jne    c010613a <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c0106117:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c010611b:	c7 44 24 08 cd 76 10 	movl   $0xc01076cd,0x8(%esp)
c0106122:	c0 
c0106123:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106126:	89 44 24 04          	mov    %eax,0x4(%esp)
c010612a:	8b 45 08             	mov    0x8(%ebp),%eax
c010612d:	89 04 24             	mov    %eax,(%esp)
c0106130:	e8 6a fe ff ff       	call   c0105f9f <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0106135:	e9 60 02 00 00       	jmp    c010639a <vprintfmt+0x3cc>
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
                printfmt(putch, putdat, "error %d", err);
            }
            else {
                printfmt(putch, putdat, "%s", p);
c010613a:	89 74 24 0c          	mov    %esi,0xc(%esp)
c010613e:	c7 44 24 08 d6 76 10 	movl   $0xc01076d6,0x8(%esp)
c0106145:	c0 
c0106146:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106149:	89 44 24 04          	mov    %eax,0x4(%esp)
c010614d:	8b 45 08             	mov    0x8(%ebp),%eax
c0106150:	89 04 24             	mov    %eax,(%esp)
c0106153:	e8 47 fe ff ff       	call   c0105f9f <printfmt>
            }
            break;
c0106158:	e9 3d 02 00 00       	jmp    c010639a <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c010615d:	8b 45 14             	mov    0x14(%ebp),%eax
c0106160:	8d 50 04             	lea    0x4(%eax),%edx
c0106163:	89 55 14             	mov    %edx,0x14(%ebp)
c0106166:	8b 30                	mov    (%eax),%esi
c0106168:	85 f6                	test   %esi,%esi
c010616a:	75 05                	jne    c0106171 <vprintfmt+0x1a3>
                p = "(null)";
c010616c:	be d9 76 10 c0       	mov    $0xc01076d9,%esi
            }
            if (width > 0 && padc != '-') {
c0106171:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106175:	7e 76                	jle    c01061ed <vprintfmt+0x21f>
c0106177:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c010617b:	74 70                	je     c01061ed <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c010617d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0106180:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106184:	89 34 24             	mov    %esi,(%esp)
c0106187:	e8 f6 f7 ff ff       	call   c0105982 <strnlen>
c010618c:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010618f:	29 c2                	sub    %eax,%edx
c0106191:	89 d0                	mov    %edx,%eax
c0106193:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0106196:	eb 16                	jmp    c01061ae <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0106198:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c010619c:	8b 55 0c             	mov    0xc(%ebp),%edx
c010619f:	89 54 24 04          	mov    %edx,0x4(%esp)
c01061a3:	89 04 24             	mov    %eax,(%esp)
c01061a6:	8b 45 08             	mov    0x8(%ebp),%eax
c01061a9:	ff d0                	call   *%eax
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
                p = "(null)";
            }
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
c01061ab:	ff 4d e8             	decl   -0x18(%ebp)
c01061ae:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c01061b2:	7f e4                	jg     c0106198 <vprintfmt+0x1ca>
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01061b4:	eb 37                	jmp    c01061ed <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c01061b6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c01061ba:	74 1f                	je     c01061db <vprintfmt+0x20d>
c01061bc:	83 fb 1f             	cmp    $0x1f,%ebx
c01061bf:	7e 05                	jle    c01061c6 <vprintfmt+0x1f8>
c01061c1:	83 fb 7e             	cmp    $0x7e,%ebx
c01061c4:	7e 15                	jle    c01061db <vprintfmt+0x20d>
                    putch('?', putdat);
c01061c6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061c9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061cd:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c01061d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01061d7:	ff d0                	call   *%eax
c01061d9:	eb 0f                	jmp    c01061ea <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c01061db:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061de:	89 44 24 04          	mov    %eax,0x4(%esp)
c01061e2:	89 1c 24             	mov    %ebx,(%esp)
c01061e5:	8b 45 08             	mov    0x8(%ebp),%eax
c01061e8:	ff d0                	call   *%eax
            if (width > 0 && padc != '-') {
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c01061ea:	ff 4d e8             	decl   -0x18(%ebp)
c01061ed:	89 f0                	mov    %esi,%eax
c01061ef:	8d 70 01             	lea    0x1(%eax),%esi
c01061f2:	0f b6 00             	movzbl (%eax),%eax
c01061f5:	0f be d8             	movsbl %al,%ebx
c01061f8:	85 db                	test   %ebx,%ebx
c01061fa:	74 27                	je     c0106223 <vprintfmt+0x255>
c01061fc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106200:	78 b4                	js     c01061b6 <vprintfmt+0x1e8>
c0106202:	ff 4d e4             	decl   -0x1c(%ebp)
c0106205:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0106209:	79 ab                	jns    c01061b6 <vprintfmt+0x1e8>
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c010620b:	eb 16                	jmp    c0106223 <vprintfmt+0x255>
                putch(' ', putdat);
c010620d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106210:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106214:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010621b:	8b 45 08             	mov    0x8(%ebp),%eax
c010621e:	ff d0                	call   *%eax
                }
                else {
                    putch(ch, putdat);
                }
            }
            for (; width > 0; width --) {
c0106220:	ff 4d e8             	decl   -0x18(%ebp)
c0106223:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0106227:	7f e4                	jg     c010620d <vprintfmt+0x23f>
                putch(' ', putdat);
            }
            break;
c0106229:	e9 6c 01 00 00       	jmp    c010639a <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c010622e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106231:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106235:	8d 45 14             	lea    0x14(%ebp),%eax
c0106238:	89 04 24             	mov    %eax,(%esp)
c010623b:	e8 18 fd ff ff       	call   c0105f58 <getint>
c0106240:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106243:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0106246:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106249:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010624c:	85 d2                	test   %edx,%edx
c010624e:	79 26                	jns    c0106276 <vprintfmt+0x2a8>
                putch('-', putdat);
c0106250:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106253:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106257:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c010625e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106261:	ff d0                	call   *%eax
                num = -(long long)num;
c0106263:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106266:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106269:	f7 d8                	neg    %eax
c010626b:	83 d2 00             	adc    $0x0,%edx
c010626e:	f7 da                	neg    %edx
c0106270:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106273:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0106276:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c010627d:	e9 a8 00 00 00       	jmp    c010632a <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0106282:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0106285:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106289:	8d 45 14             	lea    0x14(%ebp),%eax
c010628c:	89 04 24             	mov    %eax,(%esp)
c010628f:	e8 75 fc ff ff       	call   c0105f09 <getuint>
c0106294:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106297:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c010629a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c01062a1:	e9 84 00 00 00       	jmp    c010632a <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c01062a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01062a9:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062ad:	8d 45 14             	lea    0x14(%ebp),%eax
c01062b0:	89 04 24             	mov    %eax,(%esp)
c01062b3:	e8 51 fc ff ff       	call   c0105f09 <getuint>
c01062b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c01062be:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c01062c5:	eb 63                	jmp    c010632a <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c01062c7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062ca:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062ce:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c01062d5:	8b 45 08             	mov    0x8(%ebp),%eax
c01062d8:	ff d0                	call   *%eax
            putch('x', putdat);
c01062da:	8b 45 0c             	mov    0xc(%ebp),%eax
c01062dd:	89 44 24 04          	mov    %eax,0x4(%esp)
c01062e1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c01062e8:	8b 45 08             	mov    0x8(%ebp),%eax
c01062eb:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c01062ed:	8b 45 14             	mov    0x14(%ebp),%eax
c01062f0:	8d 50 04             	lea    0x4(%eax),%edx
c01062f3:	89 55 14             	mov    %edx,0x14(%ebp)
c01062f6:	8b 00                	mov    (%eax),%eax
c01062f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01062fb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0106302:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0106309:	eb 1f                	jmp    c010632a <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c010630b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010630e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106312:	8d 45 14             	lea    0x14(%ebp),%eax
c0106315:	89 04 24             	mov    %eax,(%esp)
c0106318:	e8 ec fb ff ff       	call   c0105f09 <getuint>
c010631d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0106320:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0106323:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c010632a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c010632e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106331:	89 54 24 18          	mov    %edx,0x18(%esp)
c0106335:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0106338:	89 54 24 14          	mov    %edx,0x14(%esp)
c010633c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0106340:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0106343:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0106346:	89 44 24 08          	mov    %eax,0x8(%esp)
c010634a:	89 54 24 0c          	mov    %edx,0xc(%esp)
c010634e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106351:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106355:	8b 45 08             	mov    0x8(%ebp),%eax
c0106358:	89 04 24             	mov    %eax,(%esp)
c010635b:	e8 a4 fa ff ff       	call   c0105e04 <printnum>
            break;
c0106360:	eb 38                	jmp    c010639a <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0106362:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106365:	89 44 24 04          	mov    %eax,0x4(%esp)
c0106369:	89 1c 24             	mov    %ebx,(%esp)
c010636c:	8b 45 08             	mov    0x8(%ebp),%eax
c010636f:	ff d0                	call   *%eax
            break;
c0106371:	eb 27                	jmp    c010639a <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0106373:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106376:	89 44 24 04          	mov    %eax,0x4(%esp)
c010637a:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0106381:	8b 45 08             	mov    0x8(%ebp),%eax
c0106384:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0106386:	ff 4d 10             	decl   0x10(%ebp)
c0106389:	eb 03                	jmp    c010638e <vprintfmt+0x3c0>
c010638b:	ff 4d 10             	decl   0x10(%ebp)
c010638e:	8b 45 10             	mov    0x10(%ebp),%eax
c0106391:	48                   	dec    %eax
c0106392:	0f b6 00             	movzbl (%eax),%eax
c0106395:	3c 25                	cmp    $0x25,%al
c0106397:	75 f2                	jne    c010638b <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0106399:	90                   	nop
        }
    }
c010639a:	e9 37 fc ff ff       	jmp    c0105fd6 <vprintfmt+0x8>
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
            if (ch == '\0') {
                return;
c010639f:	90                   	nop
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
c01063a0:	83 c4 40             	add    $0x40,%esp
c01063a3:	5b                   	pop    %ebx
c01063a4:	5e                   	pop    %esi
c01063a5:	5d                   	pop    %ebp
c01063a6:	c3                   	ret    

c01063a7 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c01063a7:	55                   	push   %ebp
c01063a8:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c01063aa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063ad:	8b 40 08             	mov    0x8(%eax),%eax
c01063b0:	8d 50 01             	lea    0x1(%eax),%edx
c01063b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063b6:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c01063b9:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063bc:	8b 10                	mov    (%eax),%edx
c01063be:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063c1:	8b 40 04             	mov    0x4(%eax),%eax
c01063c4:	39 c2                	cmp    %eax,%edx
c01063c6:	73 12                	jae    c01063da <sprintputch+0x33>
        *b->buf ++ = ch;
c01063c8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063cb:	8b 00                	mov    (%eax),%eax
c01063cd:	8d 48 01             	lea    0x1(%eax),%ecx
c01063d0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01063d3:	89 0a                	mov    %ecx,(%edx)
c01063d5:	8b 55 08             	mov    0x8(%ebp),%edx
c01063d8:	88 10                	mov    %dl,(%eax)
    }
}
c01063da:	90                   	nop
c01063db:	5d                   	pop    %ebp
c01063dc:	c3                   	ret    

c01063dd <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c01063dd:	55                   	push   %ebp
c01063de:	89 e5                	mov    %esp,%ebp
c01063e0:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c01063e3:	8d 45 14             	lea    0x14(%ebp),%eax
c01063e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c01063e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01063ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01063f0:	8b 45 10             	mov    0x10(%ebp),%eax
c01063f3:	89 44 24 08          	mov    %eax,0x8(%esp)
c01063f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01063fa:	89 44 24 04          	mov    %eax,0x4(%esp)
c01063fe:	8b 45 08             	mov    0x8(%ebp),%eax
c0106401:	89 04 24             	mov    %eax,(%esp)
c0106404:	e8 08 00 00 00       	call   c0106411 <vsnprintf>
c0106409:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c010640c:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010640f:	c9                   	leave  
c0106410:	c3                   	ret    

c0106411 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0106411:	55                   	push   %ebp
c0106412:	89 e5                	mov    %esp,%ebp
c0106414:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0106417:	8b 45 08             	mov    0x8(%ebp),%eax
c010641a:	89 45 ec             	mov    %eax,-0x14(%ebp)
c010641d:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106420:	8d 50 ff             	lea    -0x1(%eax),%edx
c0106423:	8b 45 08             	mov    0x8(%ebp),%eax
c0106426:	01 d0                	add    %edx,%eax
c0106428:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010642b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0106432:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0106436:	74 0a                	je     c0106442 <vsnprintf+0x31>
c0106438:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010643b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010643e:	39 c2                	cmp    %eax,%edx
c0106440:	76 07                	jbe    c0106449 <vsnprintf+0x38>
        return -E_INVAL;
c0106442:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0106447:	eb 2a                	jmp    c0106473 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0106449:	8b 45 14             	mov    0x14(%ebp),%eax
c010644c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0106450:	8b 45 10             	mov    0x10(%ebp),%eax
c0106453:	89 44 24 08          	mov    %eax,0x8(%esp)
c0106457:	8d 45 ec             	lea    -0x14(%ebp),%eax
c010645a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010645e:	c7 04 24 a7 63 10 c0 	movl   $0xc01063a7,(%esp)
c0106465:	e8 64 fb ff ff       	call   c0105fce <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c010646a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010646d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0106470:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0106473:	c9                   	leave  
c0106474:	c3                   	ret    
