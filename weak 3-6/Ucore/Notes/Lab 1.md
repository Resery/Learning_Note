# Lab 1

## 基础知识

### BIOS启动过程

当计算机加电后，一般不直接执行操作系统，而是执行系统初始化软件完成基本IO初始化和引导加载功能。简单地说，系统初始化软件就是在操作系统内核运行之前运行的一段小软件。通过这段小软件，我们可以初始化硬件设备、建立系统的内存空间映射图，从而将系统的软硬件环境带到一个合适的状态，以便为最终调用操作系统内核准备好正确的环境。最终引导加载程序把操作系统内核映像加载到RAM中，并将系统控制权传递给它。

对于绝大多数计算机系统而言，操作系统和应用软件是存放在磁盘（硬盘/软盘）、光盘、EPROM、ROM、Flash等可在掉电后继续保存数据的存储介质上。计算机启动后，CPU一开始会到一个特定的地址开始执行指令，这个特定的地址存放了系统初始化软件，负责完成计算机基本的IO初始化，这是系统加电后运行的第一段软件代码。对于Intel 80386的体系结构而言，PC机中的系统初始化软件由BIOS (Basic Input Output System，即基本输入/输出系统，其本质是一个固化在主板Flash/CMOS上的软件)和位于软盘/硬盘引导扇区中的OS Boot Loader（在ucore中的bootasm.S和bootmain.c）一起组成。BIOS实际上是被固化在计算机ROM（只读存储器）芯片上的一个特殊的软件，为上层软件提供最底层的、最直接的硬件控制与支持。更形象地说，BIOS就是PC计算机硬件与上层软件程序之间的一个"桥梁"，负责访问和控制硬件。

以Intel 80386为例，计算机加电后，CPU从物理地址0xFFFFFFF0（由初始化的CS：EIP确定，此时CS和IP的值分别是0xF000和0xFFF0)）开始执行。在0xFFFFFFF0这里只是存放了一条跳转指令，通过跳转指令跳到BIOS例行程序起始点。BIOS做完计算机硬件自检和初始化后，会选择一个启动设备（例如软盘、硬盘、光盘等），并且读取该设备的第一扇区(即主引导扇区或启动扇区)到内存一个特定的地址0x7c00处，然后CPU控制权会转移到那个地址继续执行。至此BIOS的初始化工作做完了，进一步的工作交给了ucore的bootloader。

总结一下步骤就是这样的

1. 读取0xFFFFFFF0处的指令
2. 0xFFFFFFF0处的指令为跳转指令，跳转到BIOS程序的起始点
3. BIOS程序执行完计算机硬件自检和初始化后，选择一个启动设备
4. 选择设备后会读取这个设备的第一扇区到内存一个特定的地址0x7c00处
5. 将CPU控制权转移到那个地址，BIOS工作结束

### bootloader启动过程

BIOS将通过读取硬盘主引导扇区到内存，并转跳到对应内存中的位置执行bootloader。bootloader完成的工作包括：

- 切换到保护模式，启用分段机制
- 读磁盘中ELF执行文件格式的ucore操作系统到内存
- 显示字符串信息
- 把控制权交给ucore操作系统

对应其工作的实现文件在lab1中的boot目录下的三个文件asm.h、bootasm.S和bootmain.c。

#### 保护模式和分段机制

(1) 实模式

在bootloader接手BIOS的工作后，当前的PC系统处于实模式（16位模式）运行状态，在这种状态下软件可访问的物理内存空间不能超过1MB，且无法发挥Intel 80386以上级别的32位CPU的4GB内存管理能力。

实模式将整个物理内存看成分段的区域，程序代码和数据位于不同区域，操作系统和用户程序并没有区别对待，而且每一个指针都是指向实际的物理地址。这样，用户程序的一个指针如果指向了操作系统区域或其他用户程序区域，并修改了内容，那么其后果就很可能是灾难性的。通过修改A20地址线可以完成从实模式到保护模式的转换。

> A20 Gate：
>
> Intel早期的8086 CPU提供了20根地址线,可寻址空间范围即0~2^20(00000H~FFFFFH)的 1MB内存空间。但8086的数据处理位宽位16位，无法直接寻址1MB内存空间，所以8086提供了段地址加偏移地址的地址转换机制。段地址加偏移地址就是段地址左移4位然后加上偏移地址，也就是0ffff0h + 0ffffh = 10ffefh（前面的0ffffh是segment=0ffffh并向左移动4位的结果，后面的0ffffh是可能的最大offset），这个计算出的10ffefh是多大呢？大约是1088KB，就是说，segment:offset的地址表示能力，超过了20位地址线的物理寻址能力。所以当寻址到超过1MB的内存时，会发生“回卷”（不会发生异常，回卷也就是相当于溢出了比如说11111111+00000001最后的结果是0一样，回卷也就是这个意思）。但下一代的基于Intel 80286 CPU的PC AT计算机系统提供了24根地址线，这样CPU的寻址范围变为 2^24=16M,同时也提供了保护模式，可以访问到1MB以上的内存了，此时如果遇到“寻址超过1MB”的情况，系统不会再“回卷”了，这就造成了向下不兼容。为了保持完全的向下兼容性，IBM决定在PC AT计算机系统上加个硬件逻辑，来模仿以上的回绕特征，于是出现了A20 Gate。他们的方法就是把A20地址线控制和键盘控制器的一个输出进行AND操作，这样来控制A20地址线的打开（使能）和关闭（屏蔽\禁止）。一开始时A20地址线控制是被屏蔽的（总为0），直到系统软件通过一定的IO操作去打开它（参看bootasm.S）。很显然，在实模式下要访问高端内存区，这个开关必须打开，在保护模式下，由于使用32位地址线，如果A20恒等于0，那么系统只能访问奇数兆的内存（这里是因为没有开启A20的化那就代表还是保护模式，意思就是还是会发生回卷，也就是24根地址总线没有全部用到），即只能访问0--1M、2-3M、4-5M......，这显然是不行的，所以在保护模式下，这个开关也必须打开。
>
> 当A20 地址线控制禁止时，则程序就像在8086中运行，1MB以上的地是不可访问的。在保护模式下A20地址线控制是要打开的。为了使能所有地址位的寻址能力,必须向键盘控制器8042发送一个命令。键盘控制器8042将会将它的的某个输出引脚的输出置高电平，作为 A20 地址线控制的输入。一旦设置成功之后，内存将不会再被绕回(memory wrapping)，这样我们就可以寻址整个 286 的 16M 内存，或者是寻址 80386级别机器的所有 4G 内存了。
>
> 键盘控制器8042的逻辑结构图如下所示。从软件的角度来看，如何控制8042呢？早期的PC机，控制键盘有一个单独的单片机8042，现如今这个芯片已经给集成到了其它大片子中，但其功能和使用方法还是一样，当PC机刚刚出现A20 Gate的时候，估计为节省硬件设计成本，工程师使用这个8042键盘控制器来控制A20 Gate，但A20 Gate与键盘管理没有一点关系。下面先从软件的角度简单介绍一下8042这个芯片。
>
> ![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_9-49-35.png)
>
> 8042键盘控制器的IO端口是0x60～0x6f，实际上IBM PC/AT使用的只有0x60和0x64两个端口（0x61、0x62和0x63用于与XT兼容目的）。8042通过这些端口给键盘控制器或键盘发送命令或读取状态。输出端口P2用于特定目的。位0（P20引脚）用于实现CPU复位操作，位1（P21引脚）用户控制A20信号线的开启与否。系统向输入缓冲（端口0x64）写入一个字节，即发送一个键盘控制器命令。可以带一个参数。参数是通过0x60端口发送的。 命令的返回值也从端口 0x60去读。8042有4个寄存器：
>
> - 1个8-bit长的Input buffer；Write-Only；
> - 1个8-bit长的Output buffer； Read-Only；
> - 1个8-bit长的Status Register；Read-Only；
> - 1个8-bit长的Control Register；Read/Write。
>
> 有两个端口地址：60h和64h，有关对它们的读写操作描述如下：
>
> - 读60h端口，读output buffer
> - 写60h端口，写input buffer
> - 读64h端口，读Status Register
> - 操作Control Register，首先要向64h端口写一个命令（20h为读命令，60h为写命令），然后根据命令从60h端口读出Control Register的数据或者向60h端口写入Control Register的数据（64h端口还可以接受许多其它的命令）。
>
> Status Register的定义（要用bit 0和bit 1）：
>
> | bit  | meaning                                                 |
> | ---- | ------------------------------------------------------- |
> | 0    | output register (60h) 中有数据                          |
> | 1    | input register (60h/64h) 有数据                         |
> | 2    | 系统标志（上电复位后被置为0）                           |
> | 3    | data in input register is command (1) or data (0)       |
> | 4    | 1=keyboard enabled, 0=keyboard disabled (via switch)    |
> | 5    | 1=transmit timeout (data transmit not complete)         |
> | 6    | 1=receive timeout (data transmit not complete)          |
> | 7    | 1=even parity rec'd, 0=odd parity rec'd (should be odd) |
>
> 除了这些资源外，8042还有3个内部端口：Input Port、Outport Port和Test Port，这三个端口的操作都是通过向64h发送命令，然后在60h进行读写的方式完成，其中本文要操作的A20 Gate被定义在Output Port的bit 1上，所以有必要对Outport Port的操作及端口定义做一个说明。
>
> - 读Output Port：向64h发送0d0h命令，然后从60h读取Output Port的内容
> - 写Output Port：向64h发送0d1h命令，然后向60h写入Output Port的数据
> - 禁止键盘操作命令：向64h发送0adh
> - 打开键盘操作命令：向64h发送0aeh
>
> 有了这些命令和知识，就可以实现操作A20 Gate来从实模式切换到保护模式了。 理论上讲，我们只要操作8042芯片的输出端口（64h）的bit 1，就可以控制A20 Gate，但实际上，当你准备向8042的输入缓冲区里写数据时，可能里面还有其它数据没有处理，所以，我们要首先禁止键盘操作，同时等待数据缓冲区中没有数据以后，才能真正地去操作8042打开或者关闭A20 Gate。
>
> 打开A20 Gate的具体步骤大致如下（参考bootasm.S）：
>
> 1. 等待8042 Input buffer为空；
> 2. 发送Write 8042 Output Port （P2）命令到8042 Input buffer；
> 3. 等待8042 Input buffer为空；
> 4. 将8042 Output Port（P2）得到字节的第2位置1，然后写入8042 Input buffer；

(2) 保护模式

只有在保护模式下，80386的全部32根地址线有效，可寻址高达4G字节的线性地址空间和物理地址空间，可访问64TB（有2^14个段，每个段最大空间为2^32字节）的逻辑地址空间，可采用分段存储管理机制和分页存储管理机制。这不仅为存储共享和保护提供了硬件支持，而且为实现虚拟存储提供了硬件支持。通过提供4个特权级和完善的特权检查机制，既能实现资源共享又能保证代码数据的安全及任务的隔离。

> 【补充】保护模式下，有两个段表：GDT（Global Descriptor Table）和LDT（Local Descriptor Table），每一张段表可以包含8192 (2^13)个描述符[1]，因而最多可以同时存在2 * 2^13 = 2^14个段。虽然保护模式下可以有这么多段，逻辑地址空间看起来很大，但实际上段并不能扩展物理地址空间，很大程度上各个段的地址空间是相互重叠的。目前所谓的64TB（2^(14+32)=2^46）逻辑地址空间是一个理论值，没有实际意义。在32位保护模式下，真正的物理空间仍然只有2^32字节那么大。注：在ucore lab中只用到了GDT，没有用LDT。

(3) 分段存储管理机制

只有在保护模式下才能使用分段存储管理机制。分段机制将内存划分成以起始地址和长度限制这两个二维参数表示的内存块，这些内存块就称之为段（Segment）。编译器把源程序编译成执行程序时用到的代码段、数据段、堆和栈等概念在这里可以与段联系起来，二者在含义上是一致的。

分段机涉及4个关键内容：逻辑地址、段描述符（描述段的属性）、段描述符表（包含多个段描述符的“数组”）、段选择子（段寄存器，用于定位段描述符表中表项的索引）。转换逻辑地址（Logical Address,应用程序员看到的地址）到物理地址（Physical Address, 实际的物理内存地址）分以下两步：

[1] 分段地址转换：CPU把逻辑地址（由段选择子selector和段偏移offset组成）中的段选择子的内容作为段描述符表的索引，找到表中对应的段描述符，然后把段描述符中保存的段基址加上段偏移值，形成线性地址（Linear Address）。如果不启动分页存储管理机制，则线性地址等于物理地址。 [2] 分页地址转换，这一步中把线性地址转换为物理地址。（注意：这一步是可选的，由操作系统决定是否需要。在后续试验中会涉及。

上述转换过程对于应用程序员来说是不可见的。线性地址空间由一维的线性地址构成，线性地址空间和物理地址空间对等。线性地址32位长，线性地址空间容量为4G字节。分段地址转换的基本过程如下图所示。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_20-58-35.png)

分段存储管理机制需要在启动保护模式的前提下建立。从上图可以看出，为了使得分段存储管理机制正常运行，需要建立好段描述符和段描述符表（参看bootasm.S，mmu.h，pmm.c）。

**段描述符**

在分段存储管理机制的保护模式下，每个段由如下三个参数进行定义：段基地址(Base Address)、段界限(Limit)和段属性(Attributes)。在ucore中的kern/mm/mmu.h中的struct segdesc 数据结构中有具体的定义。

- 段基地址：规定线性地址空间中段的起始地址。在80386保护模式下，段基地址长32位。因为基地址长度与寻址地址的长度相同，所以任何一个段都可以从32位线性地址空间中的任何一个字节开始，而不像实模式下规定的边界必须被16整除。
- 段界限：规定段的大小。在80386保护模式下，段界限用20位表示，而且段界限可以是以字节为单位或以4K字节为单位。
- 段属性：确定段的各种性质。
  - 段属性中的粒度位（Granularity），用符号G标记。G=0表示段界限以字节位位单位，20位的界限可表示的范围是1字节至1M字节，增量为1字节；G=1表示段界限以4K字节为单位，于是20位的界限可表示的范围是4K字节至4G字节，增量为4K字节。
  - 类型（TYPE）：用于区别不同类型的描述符。可表示所描述的段是代码段还是数据段，所描述的段是否可读/写/执行，段的扩展方向等。
  - 描述符特权级（Descriptor Privilege Level）（DPL）：用来实现保护机制。
  - 段存在位（Segment-Present bit）：如果这一位为0，则此描述符为非法的，不能被用来实现地址转换。如果一个非法描述符被加载进一个段寄存器，处理器会立即产生异常。图5-4显示了当存在位为0时，描述符的格式。操作系统可以任意的使用被标识为可用（AVAILABLE）的位。
  - 已访问位（Accessed bit）：当处理器访问该段（当一个指向该段描述符的选择子被加载进一个段寄存器）时，将自动设置访问位。操作系统可清除该位。

上述参数通过段描述符来表示，段描述符的结构如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_20-59-35.png)

**全局描述符表**

全局描述符表的是一个保存多个段描述符的“数组”，其起始地址保存在全局描述符表寄存器GDTR中。GDTR长48位，其中高32位为基地址，低16位为段界限。由于GDT 不能有GDT本身之内的描述符进行描述定义，所以处理器采用GDTR为GDT这一特殊的系统段。注意，全部描述符表中第一个段描述符设定为空段描述符。GDTR中的段界限以字节为单位。对于含有N个描述符的描述符表的段界限通常可设为8*N-1。在ucore中的boot/bootasm.S中的gdt地址处和kern/mm/pmm.c中的全局变量数组gdt[]分别有基于汇编语言和C语言的全局描述符表的具体实现。

**选择子**

线性地址部分的选择子是用来选择哪个描述符表和在该表中索引一个描述符的。选择子可以做为指针变量的一部分，从而对应用程序员是可见的，但是一般是由连接加载器来设置的。选择子的格式如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_21-00-35.png)

- 索引（Index）：在描述符表中从8192个描述符中选择一个描述符。处理器自动将这个索引值乘以8（描述符的长度），再加上描述符表的基址来索引描述符表，从而选出一个合适的描述符。
- 表指示位（Table Indicator，TI）：选择应该访问哪一个描述符表。0代表应该访问全局描述符表（GDT），1代表应该访问局部描述符表（LDT）。
- 请求特权级（Requested Privilege Level，RPL）：保护机制，在后续试验中会进一步讲解。

全局描述符表的第一项是不能被CPU使用，所以当一个段选择子的索引（Index）部分和表指示位（Table Indicator）都为0的时（即段选择子指向全局描述符表的第一项时），可以当做一个空的选择子（见mmu.h中的SEG_NULL）。当一个段寄存器被加载一个空选择子时，处理器并不会产生一个异常。但是，当用一个空选择子去访问内存时，则会产生异常。

(4) 保护模式下的特权级

在保护模式下，特权级总共有4个，编号从0（最高特权）到3（最低特权）。有3种主要的资源受到保护：内存，I/O端口以及执行特殊机器指令的能力。在任一时刻，x86 CPU都是在一个特定的特权级下运行的，从而决定了代码可以做什么，不可以做什么。这些特权级经常被称为为保护环（protection ring），最内的环（ring 0）对应于最高特权0，最外面的环（ring 3）一般给应用程序使用，对应最低特权3。在ucore中，CPU只用到其中的2个特权级：0（内核态）和3（用户态）。

有大约15条机器指令被CPU限制只能在内核态执行，这些机器指令如果被用户模式的程序所使用，就会颠覆保护模式的保护机制并引起混乱，所以它们被保留给操作系统内核使用。如果企图在ring 0以外运行这些指令，就会导致一个一般保护异常（general-protection exception）。对内存和I/O端口的访问也受类似的特权级限制。

数据段选择子的整个内容可由程序直接加载到各个段寄存器（如SS或DS等）当中。这些内容里包含了请求特权级（Requested Privilege Level，简称RPL）字段。然而，代码段寄存器（CS）的内容不能由装载指令（如MOV）直接设置，而只能被那些会改变程序执行顺序的指令（如JMP、INT、CALL）间接地设置。而且CS拥有一个由CPU维护的当前特权级字段（Current Privilege Level，简称CPL）。二者结构如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_21-01-35.png)

代码段寄存器中的CPL字段（2位）的值总是等于CPU的当前特权级，所以只要看一眼CS中的CPL，你就可以知道此刻的特权级了。

CPU会在两个关键点上保护内存：当一个段选择符被加载时，以及，当通过线性地址访问一个内存页时。因此，保护也反映在内存地址转换的过程之中，既包括分段又包括分页。当一个数据段选择符被加载时，就会发生下述的检测过程：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_21-02-35.png)

因为越高的数值代表越低的特权，上图中的MAX()用于选择CPL和RPL中特权最低的一个，并与描述符特权级（Descriptor Privilege Level，简称DPL）比较。如果DPL的值大于等于它，那么这个访问可正常进行了。RPL背后的设计思想是：允许内核代码加载特权较低的段。比如，你可以使用RPL=3的段描述符来确保给定的操作所使用的段可以在用户模式中访问。但堆栈段寄存器是个例外，它要求CPL，RPL和DPL这3个值必须完全一致，才可以被加载。下面再总结一下CPL、RPL和DPL：

- CPL：当前特权级（Current Privilege Level) 保存在CS段寄存器（选择子）的最低两位，CPL就是当前活动代码段的特权级，并且它定义了当前所执行程序的特权级别）
- DPL：描述符特权（Descriptor Privilege Level） 存储在段描述符中的权限位，用于描述对应段所属的特权等级，也就是段本身真正的特权级。
- RPL：请求特权级RPL(Request Privilege Level) RPL保存在选择子的最低两位。RPL说明的是进程对段访问的请求权限，意思是当前进程想要的请求权限。RPL的值由程序员自己来自由的设置，并不一定RPL>=CPL，但是当RPL<CPL时，实际起作用的就是CPL了，因为访问时的特权检查是判断：max(RPL,CPL)<=DPL是否成立，所以RPL可以看成是每次访问时的附加限制，RPL=0时附加限制最小，RPL=3时附加限制最大。

#### 地址空间

分段机制涉及4个关键内容：逻辑地址（Logical Address,应用程序员看到的地址，在操作系统原理上称为虚拟地址，以后提到虚拟地址就是指逻辑地址）、物理地址（Physical Address, 实际的物理内存地址）、段描述符表（包含多个段描述符的“数组”）、段描述符（描述段的属性，及段描述符表这个“数组”中的“数组元素”）、段选择子（即段寄存器中的值，用于定位段描述符表中段描述符表项的索引）

(1) 逻辑地址空间 从应用程序的角度看，逻辑地址空间就是应用程序员编程所用到的地址空间，比如下面的程序片段： int val=100; int * point=&val;

其中指针变量point中存储的即是一个逻辑地址。在基于80386的计算机系统中，逻辑地址有一个16位的段寄存器（也称段选择子，段选择子）和一个32位的偏移量构成。

(2) 物理地址空间 从操作系统的角度看，CPU、内存硬件（通常说的“内存条”）和各种外设是它主要管理的硬件资源而内存硬件和外设分布在物理地址空间中。物理地址空间就是一个“大数组”，CPU通过索引（物理地址）来访问这个“大数组”中的内容。物理地址是指CPU提交到内存总线上用于访问计算机内存和外设的最终地址。

物理地址空间的大小取决于CPU实现的物理地址位数，在基于80386的计算机系统中，CPU的物理地址空间为4GB，如果计算机系统实际上有1GB物理内存（即我们通常说的内存条），而其他硬件设备的IO寄存器映射到起始物理地址为3GB的256MB大小的地址空间，则该计算机系统的物理地址空间如下所示：

```
+------------------+ <- 0xFFFFFFFF (4GB) 
|     无效空间      | 
|                  | 
+------------------+ <- addr:3G+256M 
|      256MB       | 
|   IO外设地址空间   | 
|                  | 
+------------------+ <- 0xC0000000(3GB) 
|                  | 
/\/\/\/\/\/\/\/\/\/\
/\/\/\/\/\/\/\/\/\/\
|     无效空间      |
+------------------+  <- 0x40000000(1GB)
|                  |
|    实际有效内存    |
|                  |
+------------------+  <- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000
```

(3) 线性地址空间

一台计算机只有一个物理地址空间，但在操作系统的管理下，每个程序都认为自己独占整个计算机的物理地址空间。为了让多个程序能够有效地相互隔离和使用物理地址空间，引入线性地址空间（也称虚拟地址空间）的概念。线性地址空间的大小取决于CPU实现的线性地址位数，在基于80386的计算机系统中，CPU的线性地址空间为4GB。线性地址空间会被映射到某一部分或整个物理地址空间，并通过索引（线性地址）来访问其中的内容。线性地址又称虚拟地址，是进行逻辑地址转换后形成的地址索引，用于寻址线性地址空间。但CPU未启动分页机制时，线性地址等于物理地址；当CPU启动分页机制时，线性地址还需经过分页地址转换形成物理地址后，CPU才能访问内存硬件和外设。三种地址的关系如下所示：

- 启动分段机制，未启动分页机制：逻辑地址 → (分段地址转换) → 线性地址==物理地址
- 启动分段和分页机制：逻辑地址 → (分段地址转换) → 线性地址 → 分页地址转换) → 物理地址

在操作系统的管理下，采用灵活的内存管理机制，在只有一个物理地址空间的情况下，可以存在多个线性地址空间。一个典型的线性地址空间

#### 硬盘访问概述

bootloader让CPU进入保护模式后，下一步的工作就是从硬盘上加载并运行OS。考虑到实现的简单性，bootloader的访问硬盘都是LBA模式的PIO（Program IO）方式，即所有的IO操作是通过CPU访问硬盘的IO地址寄存器完成。

一般主板有2个IDE通道，每个通道可以接2个IDE硬盘。访问第一个硬盘的扇区可设置IO地址寄存器0x1f0-0x1f7实现的，具体参数见下表。一般第一个IDE通道通过访问IO地址0x1f0-0x1f7来实现，第二个IDE通道通过访问0x170-0x17f实现。每个通道的主从盘的选择通过第6个IO偏移地址寄存器来设置。

表一 磁盘IO地址和对应功能

第6位：为1=LBA模式；0 = CHS模式 第7位和第5位必须为1

如图所示

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_21-03-35.png)

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-04_21-04-35.png)

| I/o地址 | 功能                                                         |
| ------- | ------------------------------------------------------------ |
| 0x1f0   | 数据寄存器，读写数据都必须通过这个寄存器。读数据，当0x1f7不为忙状态时，可以读 |
| 0x1f1   | 错误寄存器，每一位代表一类错误。全零表示操作成功。           |
| 0x1f2   | 与读写的扇区数量，每次读写前，都需要表明要读写几个扇区       |
| 0x1f3   | 如果是LBA格式，就是读LBA参数的0~7位                          |
| 0x1f4   | 如果是LBA格式，就是读LBA参数的8~15位                         |
| 0x1f5   | 如果是LBA格式，就是读LBA参数的16~23位                        |
| 0x1f6   | 第0~3位：如果是LBA模式就是24-27位 第4位：为0主盘；为1从盘 第5-7位：必须为1 |
| 0x1f7   | 状态和命令寄存器。操作时先给命令，再读取，如果不是忙状态就从0x1f0端口读数据。读取时，它第三位为 1 时表示硬盘做好数据交换准备，最高位为 1 时表示忙。写入时，写入 0x20 表示请求硬盘读。 bit 7 = 1  控制器忙               bit 6 = 1  驱动器就绪               bit 5 = 1  设备错误               bit 4        N/A               bit 3 = 1  扇区缓冲区错误               bit 2 = 1  磁盘已被读校验               bit 1        N/A               bit 0 = 1  上一次命令执行失败 |

#### ELF文件格式概述

ELF(Executable and linking format)文件格式是Linux系统下的一种常用目标文件(object file)格式，有三种主要类型:

- 用于执行的可执行文件(executable file)，用于提供程序的进程映像，加载的内存执行。 这也是本实验的OS文件类型。
- 用于连接的可重定位文件(relocatable file)，可与其它目标文件一起创建可执行文件和共享目标文件。
- 共享目标文件(shared object file),连接器可将它与其它可重定位文件和共享目标文件连接成其它的目标文件，动态连接器又可将它与可执行文件和其它共享目标文件结合起来创建一个进程映像。

这里只分析与本实验相关的ELF可执行文件类型。ELF header在文件开始处描述了整个文件的组织。ELF的文件头包含整个执行文件的控制结构，其定义在elf.h中：

```
struct elfhdr {
  uint magic;  // must equal ELF_MAGIC
  uchar elf[12];
  ushort type;
  ushort machine;
  uint version;
  uint entry;  // 程序入口的虚拟地址
  uint phoff;  // program header 表的位置偏移
  uint shoff;
  uint flags;
  ushort ehsize;
  ushort phentsize;
  ushort phnum; //program header表中的入口数目
  ushort shentsize;
  ushort shnum;
  ushort shstrndx;
};
```

program header描述与程序执行直接相关的目标文件结构信息，用来在文件中定位各个段的映像，同时包含其他一些用来为程序创建进程映像所必需的信息。可执行文件的程序头部是一个program header结构的数组， 每个结构描述了一个段或者系统准备程序执行所必需的其它信息。目标文件的 “段” 包含一个或者多个 “节区”（section） ，也就是“段内容（Segment Contents）” 。程序头部仅对于可执行文件和共享目标文件有意义。可执行目标文件在ELF头部的e_phentsize和e_phnum成员中给出其自身程序头部的大小。程序头部的数据结构如下表所示：

```
struct proghdr {
  uint type;   // 段类型
  uint offset;  // 段相对文件头的偏移值
  uint va;     // 段的第一个字节将被放到内存中的虚拟地址
  uint pa;
  uint filesz;
  uint memsz;  // 段在内存映像中占用的字节数
  uint flags;
  uint align;
};
```

根据elfhdr和proghdr的结构描述，bootloader就可以完成对ELF格式的ucore操作系统的加载过程（参见boot/bootmain.c中的bootmain函数）。

### 操作系统启动过程

当bootloader通过读取硬盘扇区把ucore在系统加载到内存后，就转跳到ucore操作系统在内存中的入口位置（kern/init.c中的kern_init函数的起始地址），这样ucore就接管了整个控制权。当前的ucore功能很简单，只完成基本的内存管理和外设中断管理。ucore主要完成的工作包括：

- 初始化终端；
- 显示字符串；
- 显示堆栈中的多层函数调用关系；
- 切换到保护模式，启用分段机制；
- 初始化中断控制器，设置中断描述符表，初始化时钟中断，使能整个系统的中断机制；
- 执行while（1）死循环。

以后的实验中会大量涉及各个函数直接的调用关系，以及由于中断处理导致的异步现象，可能对大家实现操作系统和改正其中的错误有很大影响。而理解好函数调用关系的建立机制和中断处理机制，对后续实验会有很大帮助。下面就练习5涉及的函数栈调用关系和练习6中的中断机制的建立进行阐述。

#### 函数堆栈

栈是一个很重要的编程概念（编译课和程序设计课都讲过相关内容），与编译器和编程语言有紧密的联系。理解调用栈最重要的两点是：栈的结构，EBP寄存器的作用。一个函数调用动作可分解为：零到多个PUSH指令（用于参数入栈），一个CALL指令。CALL指令内部其实还暗含了一个将返回地址（即CALL指令下一条指令的地址）压栈的动作（由硬件完成）。几乎所有本地编译器都会在每个函数体之前插入类似如下的汇编指令：

```
pushl   %ebp
movl   %esp , %ebp
```

这样在程序执行到一个函数的实际指令前，已经有以下数据顺序入栈：参数、返回地址、ebp寄存器。由此得到类似如下的栈结构（参数入栈顺序跟调用方式有关，这里以C语言默认的CDECL为例）：

```
 |  栈底方向      | 高位地址
 |    ...        |
 |    ...        |
 |  参数3         |
 |  参数2         |
 |  参数1         |
 |  返回地址       |
 |  上一层[ebp]    | <-------- [ebp]
 |  局部变量       |  低位地址
```

这两条汇编指令的含义是：首先将ebp寄存器入栈，然后将栈顶指针esp赋值给ebp。“mov ebp esp”这条指令表面上看是用esp覆盖ebp原来的值，其实不然。因为给ebp赋值之前，原ebp值已经被压栈（位于栈顶），而新的ebp又恰恰指向栈顶。此时ebp寄存器就已经处于一个非常重要的地位，该寄存器中存储着栈中的一个地址（原ebp入栈后的栈顶），从该地址为基准，向上（栈底方向）能获取返回地址、参数值，向下（栈顶方向）能获取函数局部变量值，而该地址处又存储着上一层函数调用时的ebp值。

一般而言，ss:[ebp+4]处为返回地址，ss:[ebp+8]处为第一个参数值（最后一个入栈的参数值，此处假设其占用4字节内存），ss:[ebp-4]处为第一个局部变量，ss:[ebp]处为上一层ebp值。由于ebp中的地址处总是“上一层函数调用时的ebp值”，而在每一层函数调用中，都能通过当时的ebp值“向上（栈底方向）”能获取返回地址、参数值，“向下（栈顶方向）”能获取函数局部变量值。如此形成递归，直至到达栈底。这就是函数调用栈。

#### 中断与异常

中断：由CPU外部设备引起的外部事件如I/O中断、时钟中断、控制台中断等是异步产生的（即产生的时刻不确定），与CPU的执行无关，称为异步中断也称外部中断,简称中断(interrupt)。

异常：在CPU执行指令期间检测到不正常的或非法的条件(如除零错、地址访问越界)所引起的内部事件称作同步中断(synchronous interrupt)，也称内部中断，简称异常(exception)。

陷阱：在程序中使用请求系统服务的系统调用而引发的事件，称作陷入中断(trap interrupt)，也称软中断(soft interrupt)，系统调用(system call)简称trap。

本实验只描述保护模式下的处理过程。当CPU收到中断（通过8259A完成，有关8259A的信息请看附录A）或者异常的事件时，它会暂停执行当前的程序或任务，通过一定的机制跳转到负责处理这个信号的相关处理例程中，在完成对这个事件的处理后再跳回到刚才被打断的程序或任务中。中断向量和中断服务例程的对应关系主要是由IDT（中断描述符表）负责。操作系统在IDT中设置好各种中断向量对应的中断描述符，留待CPU在产生中断后查询对应中断服务例程的起始地址。而IDT本身的起始地址保存在idtr寄存器中。

(1) 中断描述符表（Interrupt Descriptor Table） 中断描述符表把每个中断或异常编号和一个指向中断服务例程的描述符联系起来。同GDT一样，IDT是一个8字节的描述符数组，但IDT的第一项可以包含一个描述符。CPU把中断（异常）号乘以8做为IDT的索引。IDT可以位于内存的任意位置，CPU通过IDT寄存器（IDTR）的内容来寻址IDT的起始地址。指令LIDT和SIDT用来操作IDTR。两条指令都有一个显示的操作数：一个6字节表示的内存地址。指令的含义如下：

- LIDT（Load IDT Register）指令：使用一个包含线性地址基址和界限的内存操作数来加载IDT。操作系统创建IDT时需要执行它来设定IDT的起始地址。这条指令只能在特权级0执行。（可参见libs/x86.h中的lidt函数实现，其实就是一条汇编指令）
- SIDT（Store IDT Register）指令：拷贝IDTR的基址和界限部分到一个内存地址。这条指令可以在任意特权级执行。

IDT和IDTR寄存器的结构和关系如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_19-47-26.png)

在保护模式下，最多会存在256个Interrupt/Exception Vectors。范围[0，31]内的32个向量被异常Exception和NMI使用，但当前并非所有这32个向量都已经被使用，有几个当前没有被使用的，请不要擅自使用它们，它们被保留，以备将来可能增加新的Exception。范围[32，255]内的向量被保留给用户定义的Interrupts。Intel没有定义，也没有保留这些Interrupts。用户可以将它们用作外部I/O设备中断（8259A IRQ），或者系统调用（System Call 、Software Interrupts）等。

(2) IDT gate descriptors

Interrupts/Exceptions应该使用Interrupt Gate和Trap Gate，它们之间的唯一区别就是：当调用Interrupt Gate时，Interrupt会被CPU自动禁止；而调用Trap Gate时，CPU则不会去禁止或打开中断，而是保留它原来的样子。

> 【补充】所谓“自动禁止”，指的是CPU跳转到interrupt gate里的地址时，在将EFLAGS保存到栈上之后，清除EFLAGS里的IF位，以避免重复触发中断。在中断处理例程里，操作系统可以将EFLAGS里的IF设上,从而允许嵌套中断。但是必须在此之前做好处理嵌套中断的必要准备，如保存必要的寄存器等。二在ucore中访问Trap Gate的目的是为了实现系统调用。用户进程在正常执行中是不能禁止中断的，而当它发出系统调用后，将通过Trap Gate完成了从用户态（ring 3）的用户进程进了核心态（ring 0）的OS kernel。如果在到达OS kernel后禁止EFLAGS里的IF位，第一没意义（因为不会出现嵌套系统调用的情况），第二还会导致某些中断得不到及时响应，所以调用Trap Gate时，CPU则不会去禁止中断。总之，interrupt gate和trap gate之间没有优先级之分，仅仅是CPU在处理中断时有不同的方法，供操作系统在实现时根据需要进行选择。

在IDT中，可以包含如下3种类型的Descriptor：

- Task-gate descriptor （这里没有使用）
- Interrupt-gate descriptor （中断方式用到）
- Trap-gate descriptor（系统调用用到）

下图图显示了80386的任务门描述符、中断门描述符、陷阱门描述符的格式：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_19-48-26.png)

(3) 中断处理中硬件负责完成的工作

中断服务例程包括具体负责处理中断（异常）的代码是操作系统的重要组成部分。需要注意区别的是，有两个过程由硬件完成：

- 硬件中断处理过程1（起始）：从CPU收到中断事件后，打断当前程序或任务的执行，根据某种机制跳转到中断服务例程去执行的过程。其具体流程如下：
  - CPU在执行完当前程序的每一条指令后，都会去确认在执行刚才的指令过程中中断控制器（如：8259A）是否发送中断请求过来，如果有那么CPU就会在相应的时钟脉冲到来时从总线上读取中断请求对应的中断向量；
  - CPU根据得到的中断向量（以此为索引）到IDT中找到该向量对应的中断描述符，中断描述符里保存着中断服务例程的段选择子；
  - CPU使用IDT查到的中断服务例程的段选择子从GDT中取得相应的段描述符，段描述符里保存了中断服务例程的段基址和属性信息，此时CPU就得到了中断服务例程的起始地址，并跳转到该地址；
  - CPU会根据CPL和中断服务例程的段描述符的DPL信息确认是否发生了特权级的转换。比如当前程序正运行在用户态，而中断程序是运行在内核态的，则意味着发生了特权级的转换，这时CPU会从当前程序的TSS信息（该信息在内存中的起始地址存在TR寄存器中）里取得该程序的内核栈地址，即包括内核态的ss和esp的值，并立即将系统当前使用的栈切换成新的内核栈。这个栈就是即将运行的中断服务程序要使用的栈。紧接着就将当前程序使用的用户态的ss和esp压到新的内核栈中保存起来；
  - CPU需要开始保存当前被打断的程序的现场（即一些寄存器的值），以便于将来恢复被打断的程序继续执行。这需要利用内核栈来保存相关现场信息，即依次压入当前被打断程序使用的eflags，cs，eip，errorCode（如果是有错误码的异常）信息；
  - CPU利用中断服务例程的段描述符将其第一条指令的地址加载到cs和eip寄存器中，开始执行中断服务例程。这意味着先前的程序被暂停执行，中断服务程序正式开始工作。
- 硬件中断处理过程2（结束）：每个中断服务例程在有中断处理工作完成后需要通过iret（或iretd）指令恢复被打断的程序的执行。CPU执行IRET指令的具体过程如下：
  - 程序执行这条iret指令时，首先会从内核栈里弹出先前保存的被打断的程序的现场信息，即eflags，cs，eip重新开始执行；
  - 如果存在特权级转换（从内核态转换到用户态），则还需要从内核栈中弹出用户态栈的ss和esp，这样也意味着栈也被切换回原先使用的用户态的栈了；
  - 如果此次处理的是带有错误码（errorCode）的异常，CPU在恢复先前程序的现场时，并不会弹出errorCode。这一步需要通过软件完成，即要求相关的中断服务例程在调用iret返回之前添加出栈代码主动弹出errorCode。

下图显示了从中断向量到GDT中相应中断服务程序起始位置的定位方式:

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_19-49-26.png)

(4) 中断产生后的堆栈栈变化

下图显示了给出相同特权级和不同特权级情况下中断产生后的堆栈栈变化示意图：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_19-50-26.png)

(5) 中断处理的特权级转换

中断处理得特权级转换是通过门描述符（gate descriptor）和相关指令来完成的。一个门描述符就是一个系统类型的段描述符，一共有4个子类型：调用门描述符（call-gate descriptor），中断门描述符（interrupt-gate descriptor），陷阱门描述符（trap-gate descriptor）和任务门描述符（task-gate descriptor）。与中断处理相关的是中断门描述符和陷阱门描述符。这些门描述符被存储在中断描述符表（Interrupt Descriptor Table，简称IDT）当中。CPU把中断向量作为IDT表项的索引，用来指出当中断发生时使用哪一个门描述符来处理中断。中断门描述符和陷阱门描述符几乎是一样的。中断发生时实施特权检查的过程如下图所示：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_19-51-26.png)

门中的DPL和段选择符一起控制着访问，同时，段选择符结合偏移量（Offset）指出了中断处理例程的入口点。内核一般在门描述符中填入内核代码段的段选择子。产生中断后，CPU一定不会将运行控制从高特权环转向低特权环，特权级必须要么保持不变（当操作系统内核自己被中断的时候），或被提升（当用户态程序被中断的时候）。无论哪一种情况，作为结果的CPL必须等于目的代码段的DPL。如果CPL发生了改变，一个堆栈切换操作（通过TSS完成）就会发生。如果中断是被用户态程序中的指令所触发的（比如软件执行INT n生产的中断），还会增加一个额外的检查：门的DPL必须具有与CPL相同或更低的特权。这就防止了用户代码随意触发中断。如果这些检查失败，会产生一个一般保护异常（general-protection exception）。

#### lab1中对中断的处理实现

(1) 外设基本初始化设置

Lab1实现了中断初始化和对键盘、串口、时钟外设进行中断处理。串口的初始化函数serial_init（位于/kern/driver/console.c）中涉及中断初始化工作的很简单：

```
......
// 使能串口1接收字符后产生中断
    outb(COM1 + COM_IER, COM_IER_RDI);
......
// 通过中断控制器使能串口1中断
pic_enable(IRQ_COM1);
```

键盘的初始化函数kbd_init（位于kern/driver/console.c中）完成了对键盘的中断初始化工作，具体操作更加简单：

```
......
// 通过中断控制器使能键盘输入中断
pic_enable(IRQ_KBD);
```

时钟是一种有着特殊作用的外设，其作用并不仅仅是计时。在后续章节中将讲到，正是由于有了规律的时钟中断，才使得无论当前CPU运行在哪里，操作系统都可以在预先确定的时间点上获得CPU控制权。这样当一个应用程序运行了一定时间后，操作系统会通过时钟中断获得CPU控制权，并可把CPU资源让给更需要CPU的其他应用程序。时钟的初始化函数clock_init（位于kern/driver/clock.c中）完成了对时钟控制器8253的初始化：

```
    ......
//设置时钟每秒中断100次
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);
// 通过中断控制器使能时钟中断
    pic_enable(IRQ_TIMER);
```

(2) 中断初始化设置

操作系统如果要正确处理各种不同的中断事件，就需要安排应该由哪个中断服务例程负责处理特定的中断事件。系统将所有的中断事件统一进行了编号（0～255），这个编号称为中断向量。以ucore为例，操作系统内核启动以后，会通过 idt_init 函数初始化 idt 表 (参见trap.c)，而其中 vectors 中存储了中断处理程序的入口地址。vectors 定义在 vector.S 文件中，通过一个工具程序 vector.c 生成。其中仅有 System call 中断的权限为用户权限 (DPL_USER)，即仅能够使用 int 0x30 指令。此外还有对 tickslock 的初始化，该锁用于处理时钟中断。

vector.S 文件通过 vectors.c 自动生成，其中定义了每个中断的入口程序和入口地址 (保存在 vectors 数组中)。其中，中断可以分成两类：一类是压入错误编码的 (error code)，另一类不压入错误编码。对于第二类， vector.S 自动压入一个 0。此外，还会压入相应中断的中断号。在压入两个必要的参数之后，中断处理函数跳转到统一的入口 alltraps 处。

(3) 中断的处理过程

trap函数（定义在trap.c中）是对中断进行处理的过程，所有的中断在经过中断入口函数__alltraps预处理后 (定义在 trapasm.S中) ，都会跳转到这里。在处理过程中，根据不同的中断类型，进行相应的处理。在相应的处理过程结束以后，trap将会返回，被中断的程序会继续运行。整个中断处理流程大致如下：

| trapasm.S                                                    | trap.c                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| 1)产生中断后，CPU 跳转到相应的中断处理入口 (vectors)，并在桟中压入相应的 error_code（是否存在与异常号相关） 以及 trap_no，然后跳转到 alltraps 函数入口： 注意：此处的跳转是 jmp 过程(high)...产生中断时的 eip →eiperror_codeesp →trap_no(low)... 在栈中保存当前被打断程序的 trapframe 结构(参见过程trapasm.S)。设置 kernel (内核) 的数据段寄存器，最后压入 esp，作为 trap 函数参数(struct trapframe * tf) 并跳转到中断处理函数 trap 处：Struct trapframe { uint edi; uint esi; uint ebp; … ushort es; ushort padding1; ushort ds; ushort padding2; uint trapno; uint err; uint eip; ... }观察 trapframe 结构与中断产生过程的压桟顺序。 需要明确 pushal 指令都保存了哪些寄存器，按照什么顺序？    ← trap_no ← trap_error ← 产生中断处的 eip  注意：此时的跳转是 call 调用，会压入返回地址 eip，注意区分此处eip与trapframe中eip： trapframe的结构为： 进入 trap 函数，对中断进行相应的处理： |                                                              |
|                                                              | 2)详细的中断分类以及处理流程如下： 根据中断号对不同的中断进行处理。其中，若中断号是IRQ_OFFSET + IRQ_TIMER 为时钟中断，则把ticks 将增加一。 若中断号是IRQ_OFFSET + IRQ_COM1 为串口中断，则显示收到的字符。 若中断号是IRQ_OFFSET + IRQ_KBD 为键盘中断，则显示收到的字符。 若为其他中断且产生在内核状态，则挂起系统； |
| 3)结束 trap 函数的执行后，通过 ret 指令返回到 alltraps 执行过程。 从栈中恢复所有寄存器的值。 调整 esp 的值：跳过栈中的 trap_no 与 error_code，使esp指向中断返回 eip，通过 iret 调用恢复 cs、eflag以及 eip，继续执行。 |                                                              |
|                                                              |                                                              |

## 代码分析

### bootasm.S

#### 宏定义以及实模式下的初始化

对应这一些初始化的内容

```
#include <asm.h>

# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

.set PROT_MODE_CSEG,        0x8                     # kernel code segment selector
.set PROT_MODE_DSEG,        0x10                    # kernel data segment selector
.set CR0_PE_ON,             0x1                     # protected mode enable flag

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
.globl start
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    cld                                             # String operations increment

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment

    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.
```

其中cli指令是禁止中断发生，cld指令是使DF复位

然后初始就是执行的寄存器初始化为0，包括数据段寄存器ds，额外段寄存器es，栈段寄存器ss

#### 实模式转换保护模式

首先第一步完成的是实模式转换成保护模式，总的来说可以分成两大步，开启A20和准备GDT

开启A20具体步骤如下

1. 等待8042 Input buffer为空；

   ```
   seta20.1:
       inb $0x64, %al
       testb $0x2, %al
       jnz seta20.1
   ```

   这三行代码对应的就是等待8042 Input buffer为空，检测它是否为空就是检测倒数第二位是不是为1，如果为1则继续循环，不为1则往下执行。具体步骤如下

   - 其中具体执行的就是从0x64这个端口取内容，放到寄存器中
   - 然后检测倒数第二位是不是1，这里是因为0x64对应的是状态寄存器，状态寄存器的倒数第二位就是用来检测input buffer是不是空的
   - 最后根据检测结果判断是否继续循环或者跳转

2. 发送Write 8042 Output Port （P2）命令到8042 Input buffer；

   ```
    movb $0xd1, %al
    outb %al, $0x64
   ```

   0x64端口存储的也就是对其余端口的命令，所以我们的目的是要往Output Port写入东西。根据之前说的步骤就是向64h发送0d1h命令，然后把数据写入到60h，60h就会再把数据写入Output Port，具体步骤如下

   - 把0xd1命令送到寄存器中
   - 然后把寄存器终端内容传送到0x64端口

   这样写output的命令就传送结束了，下面就只需要把要传送的数据写入到0x60就可以了

3. 等待8042 Input buffer为空；

   这一步和第一步一样代码也是一样的

   ```
   seta20.2:
       inb $0x64, %al
       testb $0x2, %al
       jnz seta20.2
   ```

4. 将8042 Output Port（P2）得到字节的第2位置1，然后写入8042 Input buffer；

   ```
    movb $0xdf, %al
    outb %al, $0x60
   ```

   这就是把指令写入到0x60中，然后0x60再把数据写入到output port，具体步骤如下

   - 把指令0xdf传送到寄存器中
   - 把寄存器中的指令传到0x60端口

   这里0xdf是一条特定指令，用来打开a20

准备GDT的具体步骤如下

首先要说一下定义的几个宏

```
gdt:
    SEG_NULLASM
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)
    SEG_ASM(STA_W, 0x0, 0xffffffff)

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt
```

   其中gdt中包含SEG_NULLASM，SEG_ASM这两个宏定义，其具体信息为

```
#define SEG_NULLASM                                             \
    .word 0, 0;                                                 \
    .byte 0, 0, 0, 0

#define SEG_ASM(type,base,lim)                                  \
    .word (((lim) >> 12) & 0xffff), ((base) & 0xffff);          \
    .byte (((base) >> 16) & 0xff), (0x90 | (type)),             \
        (0xC0 | (((lim) >> 28) & 0xf)), (((base) >> 24) & 0xff)

#define STA_X       0x8		//可执行段
#define STA_E       0x4		//向下展开（不可执行的段）
#define STA_C       0x4		//符合代码段（仅可执行）
#define STA_W       0x2		//可写（不可执行的段）
#define STA_R       0x2		//可读（可执行段）
#define STA_A       0x1		//已访问
```

  上面第一块代码中每行对视对应着一个段描述符，其中SEG_NULLASM对应的是空段，SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)对应的是代码段，SEG_ASM(STA_W, 0x0, 0xffffffff)对应的是数据段

详细展开就是这样的以代码段和数据段举例

```
gdt:
	.word 0xffff, 0;
	.byte 0, 0x9a, 0xcf, 0
	.word 0xffff, 0x0000;
	.byte 0x00, 0x92, 0xcf, 0x00
```

 对应的具体结构是这样的第一个图是代码段，第二个图是数据段

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_14-25-06.png)

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_14-25-22.png)

其中每个字符的意义如下

- P:       0 本段不在内存中
- DPL:     访问该段内存所需权限等级 00 — 11，0为最大权限级别
- S:       1 代表数据段、代码段或堆栈段，0 代表系统段如中断门或调用门
- E:       1 代表代码段，可执行标记，0 代表数据段
- ED:      0 代表忽略特权级，1 代表遵守特权级
- RW:      如果是数据段（E=0）则1 代表可写入，0 代表只读；
      如果是代码段（E=1）则1 代表可读取，0 代表不可读取
- A:       1 表示该段内存访问过，0 表示没有被访问过
- G:       1 表示 20 位段界限单位是 4KB，最大长度 4GB；
      0 表示 20 位段界限单位是 1 字节，最大长度 1MB
- DB:      1 表示地址和操作数是 32 位，0 表示地址和操作数是 16 位
- XX:      保留位永远是 0
- AA:      给系统提供的保留位

**下面即使正式的进入保护模式了**

1. 第一步是把上面设定好的gdt的位置告诉CPU，CPU 单独为我们准备了一个寄存器叫做 GDTR 用来保存我们 GDT 在内存中的位置和我们 GDT 的长度。GDTR 寄存器一共 48 位，其中高 32 位用来存储我们的 GDT 在内存中的位置，其余的低 16 位用来存我们的 GDT 有多少个段描述符。lgdt指令就是把gdtdesc里的内容和长度加载到GDTR寄存器中

   ```
   lgdt   gdtdesc
   
   gdtdesc:
       .word 0x17
       .long gdt
   ```

2. 想要进入“保护模式”我们也需要打开一个开关，这个开关叫“控制寄存器”，x86 的控制寄存器一共有 4 个分别是 CR0、CR1、CR2、CR3，而控制进入“保护模式”的开关在 CR0 上，这四个寄存器都是 32 位的，我们看一下 CR0 上和保护模式有关的位段描述表初始化

   ![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-05_14-51-26.png)

   - PG    为 0 时代表只使用分段式，不使用分页式
         为 1 是启用分页式
   - PE    为 0 时代表关闭保护模式，运行在实模式下
         为 1 则开启保护模式

   所以对应的操作就是需要把PE位设置为1

   ```
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0
   ```

   先把cr0的值放进寄存器里，然后和CR0_PE_ON进行异或，CR0_PE_ON的值为1，也就是让PE位为1，然后把寄存器中的值再传回去就可以了，此时PG的值为0，意思就是我们不使用分页机制。

3. 现在就已经是保护模式了，但是还是16位的保护模式，所以就需要切换成32位的保护模式，首先执行的是一个跳转命令

   ```
   ljmp $PROT_MODE_CSEG, $protcseg
   ```

   这是一个跳转语句，通知 CPU 跳转到指定位置继续执行指令。 ucore在这时就准备跳转到用 C 写成的代码处去继续运行了。这个跳转语句的两个参数就是我们之前一直再讲的典型的“基地址” + “偏移量”的方式告诉 CPU 要跳转到内存的什么位置去继续执行指令。

   PROT_MODE_CSEG的值为8，对应二进制就是0000000000001000

   这里这个 16 位的“段基址”的高13位代表 GDT 表的下标（学名应该叫“段选择子”），这里高 13 位刚好是 1，而我们的 GDT 里下标位 1 的内存段正好是我们的“代码段”，而“代码段”我们在 GDT 的“段描述符”中设置了它的其实内存地址是 0x00000000 ，内存段长度是 0xfffff，这是完整的 4GB 内存。

   所以这里的跳转语句选择了“代码段”，由于“代码段”的起始内存地址是 0x00000000 ，长度是完整的 4GB，所以后面的“偏移量”仍然相当于是实际的内存地址，所以这里“偏移量”直接用了 $protcseg，也就是 protcseg直接对应的代码位置。通过这个跳转实际上 CPU 就会跳转到 bootasm.S 文件的 protcseg标识符处继续执行了。也就是如下代码处：

   ```
   .code32
   protcseg:
       # Set up the protected-mode data segment registers
       movw $PROT_MODE_DSEG, %ax
       movw %ax, %ds
       movw %ax, %es
       movw %ax, %fs
       movw %ax, %gs
       movw %ax, %ss
   
       movl $0x0, %ebp
       movl $start, %esp
       call bootmain
   
       # If bootmain returns (it shouldn't), loop.
   spin:
       jmp spin
   ```

   用数据段的地址来初始化各个寄存器，然后初始化esp，ebp，esp的初始值应该为0x7c00这里$start对应的值就是7c00，ebp的初始值为0，然后直接跳转取执行bootmain函数，bootmain函数是bootmain.c文件中的一个函数。

至此实模式转换保护模式也就结束了

### bootmain.c

#### 从硬盘加载并运行OS

整体代码

```
#include <defs.h>
#include <x86.h>
#include <elf.h>

#define SECTSIZE        512
#define ELFHDR          ((struct elfhdr *)0x10000)      // scratch space

static void
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}

static void
readsect(void *dst, uint32_t secno) {
    waitdisk();

    outb(0x1F2, 1);
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20); 

    waitdisk();

    insl(0x1F0, dst, SECTSIZE / 4);
}

static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;
    
    va -= offset % SECTSIZE;

    uint32_t secno = (offset / SECTSIZE) + 1;

    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}

void
bootmain(void) {
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }

    struct proghdr *ph, *eph;

    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
    eph = ph + ELFHDR->e_phnum;
    for (; ph < eph; ph ++) {
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    while (1);
}
```

调用的第一个函数readseg

```
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;

    // translate from bytes to sectors; kernel starts at sector 1
    uint32_t secno = (offset / SECTSIZE) + 1;

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}
```

这个函数首先设置end_va的值为0x11000，然后设置va为0x10000，secno设置的是扇区号值为1，下标为1的扇区对应的就是内核的扇区，然后进行循环，循环调用了另一个函数`readsect((void *)va, secno);`对应代码如下

```
static void
readsect(void *dst, uint32_t secno) {
	//dst = 0x10000 secno = 1
    // wait for disk to be ready
    waitdisk();

    outb(0x1F2, 1);
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}
```

这个函数又调用了一个`waitdisk();`函数，对应代码如下

```
static void
waitdisk(void) {
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}
```

所以按这个调用来看正常的步骤就是这样的

1. 执行waitdisk函数，从0x1f7读数据检测第7位是不是为0和第6为是不是为1，满足跳出循环，说明现再不是忙碌状态

2. 然后开始写数据，第一次写的是第二扇区（内核所在的扇区，下标为1）对应的就是6个outb函数，翻译过来就是

   ```
    outb(0x1F2, 1);                         //读一个扇区
    outb(0x1F3, secno & 0xFF);				 //扇区 LBA 地址的 0-7 位
    outb(0x1F4, (secno >> 8) & 0xFF);		 //扇区 LBA 地址的 8-15 位
    outb(0x1F5, (secno >> 16) & 0xFF);		 //扇区 LBA 地址的 16-23 位
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);//5-7：保证高3位必须位1，4：主硬盘，1-3：扇区 LBA 地址的 24-27 位
    outb(0x1F7, 0x20);                      //0x20为读，0x30为写
   ```

3. 再次执行waitdisk函数，等待磁盘再次处于不忙状态

4. 然后执行insl函数，把磁盘扇区数据读到指定内存

**现再内核就已经从磁盘上加载到内存中了，之后就是运行内核了，跳转到对应位置去运行内核之前，还需要做一些准备工作**

```
if (ELFHDR->e_magic != ELF_MAGIC) {
    goto bad;
}

struct proghdr *ph, *eph;

// load each program segment (ignores ph flags)
ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff);
eph = ph + ELFHDR->e_phnum;
for (; ph < eph; ph ++) {
    readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
}

// call the entry point from the ELF header
// note: does not return
((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

/* do nothing */
while (1);
```

首先检测加载到内核里的内核的magic字段是不是规定的ELF的magic字段，如果不是就跳转去执行bad段的代码就是往0x8A00地址处，写东西。

然后读取程序头部表中的每个项数到内存中

然后去执行代码加载地址的内容，也就是内核部分的代码了

### 总结 1

在执行 `bootmain.c` 之前 `bootasm.S` 汇编代码已经将栈的栈顶设置在了 `0x7C00` 处。之前我们了解过 x86 架构计算机的启动过程，BIOS 会将引导扇区的引导程序加载到 `0x7C00` 处并引导 CPU 从此处开始运行，故栈顶即被设置在了和引导程序一致的内存位置上。我们知道栈是自栈顶开始向下增长的，所以这里栈会逐渐远离引导程序，所以这里这样安置栈顶的位置并无什么问题。

最后放一张简单的内存布局示意图

```
0x00000000 
+------------------------------------------------------------------------—+ 
|        0x7c00      0x7d00         0x10000                               | 
|    栈    |  引导程序  |                |    内核                          | 
+-------------------------------------------------------------------------+
                                                                 0xffffffff 
```

**至此内核就已经完全加载到内存中了，已经开始准备运行内核代码了。**

## 项目组成

lab1的整体目录结构如下所示：

```
.
├── boot
│   ├── asm.h
│   ├── bootasm.S
│   └── bootmain.c
├── kern
│   ├── debug
│   │   ├── assert.h
│   │   ├── kdebug.c
│   │   ├── kdebug.h
│   │   ├── kmonitor.c
│   │   ├── kmonitor.h
│   │   ├── panic.c
│   │   └── stab.h
│   ├── driver
│   │   ├── clock.c
│   │   ├── clock.h
│   │   ├── console.c
│   │   ├── console.h
│   │   ├── intr.c
│   │   ├── intr.h
│   │   ├── kbdreg.h
│   │   ├── picirq.c
│   │   └── picirq.h
│   ├── init
│   │   └── init.c
│   ├── libs
│   │   ├── readline.c
│   │   └── stdio.c
│   ├── mm
│   │   ├── memlayout.h
│   │   ├── mmu.h
│   │   ├── pmm.c
│   │   └── pmm.h
│   └── trap
│       ├── trap.c
│       ├── trapentry.S
│       ├── trap.h
│       └── vectors.S
├── libs
│   ├── defs.h
│   ├── elf.h
│   ├── error.h
│   ├── printfmt.c
│   ├── stdarg.h
│   ├── stdio.h
│   ├── string.c
│   ├── string.h
│   └── x86.h
├── Makefile
└── tools
    ├── function.mk
    ├── gdbinit
    ├── grade.sh
    ├── kernel.ld
    ├── sign.c
    └── vector.c

10 directories, 48 files
```

其中一些比较重要的文件说明如下：

**bootloader部分**

- boot/bootasm.S ：定义并实现了bootloader最先执行的函数start，此函数进行了一定的初始化，完成了从实模式到保护模式的转换，并调用bootmain.c中的bootmain函数。
- boot/bootmain.c：定义并实现了bootmain函数实现了通过屏幕、串口和并口显示字符串。bootmain函数加载ucore操作系统到内存，然后跳转到ucore的入口处执行。
- boot/asm.h：是bootasm.S汇编文件所需要的头文件，主要是一些与X86保护模式的段访问方式相关的宏定义。

**ucore操作系统部分**

系统初始化部分：

- kern/init/init.c：ucore操作系统的初始化启动代码

内存管理部分：

- kern/mm/memlayout.h：ucore操作系统有关段管理（段描述符编号、段号等）的一些宏定义
- kern/mm/mmu.h：ucore操作系统有关X86 MMU等硬件相关的定义，包括EFLAGS寄存器中各位的含义，应用/系统段类型，中断门描述符定义，段描述符定义，任务状态段定义，NULL段声明的宏SEG_NULL, 特定段声明的宏SEG，设置中 断门描述符的宏SETGATE（在练习6中会用到）
- kern/mm/pmm.[ch]：设定了ucore操作系统在段机制中要用到的全局变量：任务状态段ts，全局描述符表 gdt[]，加载全局描述符表寄存器的函数lgdt，临时的内核栈stack0；以及对全局描述符表和任务状态段的初始化函数gdt_init

外设驱动部分：

- kern/driver/intr.[ch]：实现了通过设置CPU的eflags来屏蔽和使能中断的函数；
- kern/driver/picirq.[ch]：实现了对中断控制器8259A的初始化和使能操作；
- kern/driver/clock.[ch]：实现了对时钟控制器8253的初始化操作；- kern/driver/console.[ch]：实现了对串口和键盘的中断方式的处理操作；

中断处理部分：

- kern/trap/vectors.S：包括256个中断服务例程的入口地址和第一步初步处理实现。注意，此文件是由tools/vector.c在编译ucore期间动态生成的；
- kern/trap/trapentry.S：紧接着第一步初步处理后，进一步完成第二步初步处理；并且有恢复中断上下文的处理，即中断处理完毕后的返回准备工作；
- kern/trap/trap.[ch]：紧接着第二步初步处理后，继续完成具体的各种中断处理操作；

内核调试部分：

- kern/debug/kdebug.[ch]：提供源码和二进制对应关系的查询功能，用于显示调用栈关系。其中补全print_stackframe函数是需要完成的练习。其他实现部分不必深究。
- kern/debug/kmonitor.[ch]：实现提供动态分析命令的kernel monitor，便于在ucore出现bug或问题后，能够进入kernel monitor中，查看当前调用关系。实现部分不必深究。
- kern/debug/panic.c | assert.h：提供了panic函数和assert宏，便于在发现错误后，调用kernel monitor。大家可在编程实验中充分利用assert宏和panic函数，提高查找错误的效率。

**公共库部分**

- libs/defs.h：包含一些无符号整型的缩写定义。
- Libs/x86.h：一些用GNU C嵌入式汇编实现的C函数（由于使用了inline关键字，所以可以理解为宏）。

**工具部分**

- Makefile和function.mk：指导make完成整个软件项目的编译，清除等工作。
- sign.c：一个C语言小程序，是辅助工具，用于生成一个符合规范的硬盘主引导扇区。
- tools/vector.c：生成vectors.S，此文件包含了中断向量处理的统一实现。