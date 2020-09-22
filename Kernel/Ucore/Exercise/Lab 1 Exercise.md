# Lab 1 Exercise

**tips：想让鼠标移出qemu窗口，按左ctrl+alt+g即可**

## Exercise 1

**问题：**

1. **操作系统镜像文件ucore.img是如何一步一步生成的？(需要比较详细地解释Makefile中每一条相关命令和命令参数的含义，以及说明命令导致的结果)**
2. **一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？**

### 解1：

执行`make "=V"`，可以得到如下编译过程。

```
+ cc kern/init/init.c
gcc -Ikern/init/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/init/init.c -o obj/kern/init/init.o
+ cc kern/libs/stdio.c
gcc -Ikern/libs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/stdio.c -o obj/kern/libs/stdio.o
+ cc kern/libs/readline.c
gcc -Ikern/libs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/readline.c -o obj/kern/libs/readline.o
+ cc kern/debug/panic.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/panic.c -o obj/kern/debug/panic.o
+ cc kern/debug/kdebug.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kdebug.c -o obj/kern/debug/kdebug.o
+ cc kern/debug/kmonitor.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kmonitor.c -o obj/kern/debug/kmonitor.o
+ cc kern/driver/clock.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/clock.c -o obj/kern/driver/clock.o
+ cc kern/driver/console.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/console.c -o obj/kern/driver/console.o
+ cc kern/driver/picirq.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/picirq.c -o obj/kern/driver/picirq.o
+ cc kern/driver/intr.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/intr.c -o obj/kern/driver/intr.o
+ cc kern/trap/trap.c
gcc -Ikern/trap/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/trap.c -o obj/kern/trap/trap.o
+ cc kern/trap/vectors.S
gcc -Ikern/trap/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/vectors.S -o obj/kern/trap/vectors.o
+ cc kern/trap/trapentry.S
gcc -Ikern/trap/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/trapentry.S -o obj/kern/trap/trapentry.o
+ cc kern/mm/pmm.c
gcc -Ikern/mm/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/mm/pmm.c -o obj/kern/mm/pmm.o
+ cc libs/string.c
gcc -Ilibs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/  -c libs/string.c -o obj/libs/string.o
+ cc libs/printfmt.c
gcc -Ilibs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/  -c libs/printfmt.c -o obj/libs/printfmt.o
+ ld bin/kernel
ld -m    elf_i386 -nostdlib -T tools/kernel.ld -o bin/kernel  obj/kern/init/init.o obj/kern/libs/stdio.o obj/kern/libs/readline.o obj/kern/debug/panic.o obj/kern/debug/kdebug.o obj/kern/debug/kmonitor.o obj/kern/driver/clock.o obj/kern/driver/console.o obj/kern/driver/picirq.o obj/kern/driver/intr.o obj/kern/trap/trap.o obj/kern/trap/vectors.o obj/kern/trap/trapentry.o obj/kern/mm/pmm.o  obj/libs/string.o obj/libs/printfmt.o
+ cc boot/bootasm.S
gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o
+ cc boot/bootmain.c
gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootmain.c -o obj/boot/bootmain.o
+ cc tools/sign.c
gcc -Itools/ -g -Wall -O2 -c tools/sign.c -o obj/sign/tools/sign.o
gcc -g -Wall -O2 obj/sign/tools/sign.o -o bin/sign
+ ld bin/bootblock
ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
'obj/bootblock.out' size: 484 bytes
build 512 bytes boot sector: 'bin/bootblock' success!
dd if=/dev/zero of=bin/ucore.img count=10000
dd if=bin/bootblock of=bin/ucore.img conv=notrunc
dd if=bin/kernel of=bin/ucore.img seek=1 conv=notrunc
```

#### 设置环境变量

Makefile文件内容如下：

```
PROJ	:= challenge
EMPTY	:=
SPACE	:= $(EMPTY) $(EMPTY)
SLASH	:= /

CTYPE	:= c S

listf_cc = $(call listf,$(1),$(CTYPE))

add_files_cc = $(call add_files,$(1),$(CC),$(CFLAGS) $(3),$(2),$(4))
create_target_cc = $(call create_target,$(1),$(2),$(3),$(CC),$(CFLAGS))

KINCLUDE	+= kern/debug/ \
			   kern/driver/ \
			   kern/trap/ \
			   kern/mm/

KSRCDIR		+= kern/init \
			   kern/libs \
			   kern/debug \
			   kern/driver \
			   kern/trap \
			   kern/mm

KCFLAGS		+= $(addprefix -I,$(KINCLUDE))

$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))

KOBJS	= $(call read_packet,kernel libs)
```

可以看到1-25行是一些定义和函数定义，27行开始调用函数

1. 首先调用了`$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))`，传递了3个参数，第一个参数为`$(call listf_cc,$(KSRCDIR))`函数的返回值，第二个参数为kernal，第三个参数为`$(KCFLAGS))`，关于第三个参数在第25行有定义`KCFLAGS += $(addprefix -I,$(KINCLUDE))`其中`addprefix `是加前缀的一个函数，意思就是在`$(KINCLUDE) `前面都加上`-I`这个前缀，`$(KINCLUDE) `也有定义在13-16行，所以`$(KCFLAGS) `代表的就是

   ```
   - I kern/debug/
   - I kern/driver/
   - I kern/trap/
   - I kern/mm/
   ```

2. 然后就是`$(call listf_cc,$(KSRCDIR))`这个函数了，这个函数定义在第8行`listf_cc = $(call listf,$(1),$(CTYPE))`可见它又调用了另一个函数`listf`，函数`listf`的定义为`listf = $(filter $(if $(2),$(addprefix %.,$(2)),%), $(wildcard $(addsuffix $(SLASH)*,$(1))))`，其中`filter `函数是过滤函数它的格式是这样的`filter(model,from)`，他会把from中不符合model模式的字符过滤掉，留下符合model模式的，然后对应这条语句`$(if $(2),$(addprefix %.,$(2)),%)`就是model，`$(wildcard $(addsuffix $(SLASH)*,$(1)))`就是from，分别来看`$(if $(2),$(addprefix %.,$(2)),%)`这条语句检测第二个参数存不存在，如果存在就执行`$(addprefix %.,$(2))`，不存在就直接是一个%字符，可以往回看一下，`$(call listf,$(1),$(CTYPE))`第二个参数带有默认参数`$(CTYPE)`且值为`c S`，所以说`$(if $(2),$(addprefix %.,$(2)),%)`执行结束之后的结果就是`%.c %.S`,然后看`$(wildcard $(addsuffix $(SLASH)*,$(1)))`，其中`addsuffix `函数是与`addprefix`函数正好是相对的也就是加后缀，拆开来看`$(SLASH)`的值为`/`，所以说`$(addsuffix $(SLASH)*,$(1))`执行完的结果就是

   ```
   kern/init/*
   kern/libs/*
   kern/debug/*
   kern/driver/*
   kern/trap/*
   kern/mm/*
   ```

   之后就是`wildcard `函数，它是用来获取目录下对应后缀的所有文件的，所以说`wildcard `函数执行完的结果就是获取到上面那些目录下的所有文件，因为没有后缀所以说是全部文件。这样`listf `执行完的结果就是`listf = $(filter %.c %.S,kern/*)`返回到`$(call add_files_cc,$(call listf_cc,$(KSRCDIR)),kernel,$(KCFLAGS))`就是`$(call add_files_cc,/kern/*.c /kern/*.S,kernel,$(KCFLAGS))`

3. 已经化简成功了一步`$(call add_files_cc,/kern/*.c /kern/*.S,kernel,$(KCFLAGS))`，之后就是看`add_files_cc`这个函数了，在第10行可以看到定义是这样的`add_files_cc = $(call add_files,$(1),$(CC),$(CFLAGS) $(3),$(2),$(4))`，调用了另一个函数`add_files`，这里先简化一下` $(call add_files,/kern/*.c /kern/*.S,gcc,$(CFLAGS) $(KCFLAGS),kernel)`

   其中`add_files`的定义为`$(eval $(call do_add_files_to_packet,$(1),$(2),$(3),$(4),$(5)))`而`do_add_files_to_packet`的定义为：

   ```
   define do_add_files_to_packet
   __temp_packet__ := $(call packetname,$(4))
   ifeq ($$(origin $$(__temp_packet__)),undefined)
   $$(__temp_packet__) :=
   endif
   __temp_objs__ := $(call toobj,$(1),$(5))
   $$(foreach f,$(1),$$(eval $$(call cc_template,$$(f),$(2),$(3),$(5))))
   $$(__temp_packet__) += $$(__temp_objs__)
   endef
   ```

   - packetname的定义为`packetname = $(if $(1),$(addprefix $(OBJPREFIX),$(1)),$(OBJPREFIX))`，其中`$(OBJPREFIX)=__objs_`，而`$(1)=kernal`，因此`__temp_packet_ = __objs_kernal`

- toobj的定义为`toobj = $(addprefix $(OBJDIR)$(SLASH)$(if $(2),$(2)$(SLASH)), $(addsuffix .o,$(basename $(1))))`，`basename`函数是用来去前缀的函数，其中`$(OBJDIR)=obj, $(SLASH)=/`，而输入参数为`$(1)=/kern/*.c /kern/*.S, $(5)=''`，因此`__temp_objs_ = obj/kern/*.o`

  - 综上，执行的最终结果是`__objs_kernal= obj/kern/**/*.o`

  注：还有设置libs的环境变量不过和设置kern的几乎一样，所以不再做解释，生成的结果是`__objs_libs= obj/libs/**/*.o`

#### 生成kernel文件

Makefile文件内容如下：

   ```
   # create kernel target
   kernel = $(call totarget,kernel)
   
   $(kernel): tools/kernel.ld
   
   $(kernel): $(KOBJS)
   	@echo + ld $@
   	$(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
   	@$(OBJDUMP) -S $@ > $(call asmfile,kernel)
   	@$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call symfile,kernel)
   
   $(call create_target,kernel)
   ```

   - 第1行调用了`totarget`函数，函数定义为`totarget = $(addprefix $(BINDIR)$(SLASH),$(1))`，其中`BINDIR := bin `，`SLASH := /`，所以说`kernel = bin/kernel`

   - 第4行指出kernel目标文件需要依赖tools/kernel.ld文件，而kernel.ld文件是一个链接脚本，其中设置了输出的目标文件的入口地址及各个段的一些属性，包括各个段是由输入文件的哪些段组成、各个段的起始地址等。

   - 第6行指出kernal目标文件依赖的obj文件。最终效果为`KOBJS=obj/libs/*.o obj/kern/**/*.o`

     ```
     $(kernel): $(KOBJS)
     KOBJS   = $(call read_packet,kernel libs)
     read_packet = $(foreach p,$(call packetname,$(1)),$($(p)))
     packetname = $(if $(1),$(addprefix $(OBJPREFIX),$(1)),$(OBJPREFIX))
     OBJPREFIX	:= __objs_
     ```

   - 第7行打印出kernal目标文件名

     ```
     @echo + ld $@
     // output: `+ ld bin/kernel
     ```

   - 第8行是链接所有生成的obj文件得到kernel文件

     ```
     $(V)$(LD) $(LDFLAGS) -T tools/kernel.ld -o $@ $(KOBJS)
     V       := @
     LD      := $(GCCPREFIX)ld
     // GCCPREFIX = 'i386-elf-' or ''
     // output: ld -m    elf_i386 -nostdlib -T tools/kernel.ld -o bin/kernel  obj/kern/init/init.o obj/kern/libs/stdio.o obj/kern/libs/readline.o obj/kern/debug/panic.o obj/kern/debug/kdebug.o obj/kern/debug/kmonitor.o obj/kern/driver/clock.o obj/kern/driver/console.o obj/kern/driver/picirq.o obj/kern/driver/intr.o obj/kern/trap/trap.o obj/kern/trap/vectors.o obj/kern/trap/trapentry.o obj/kern/mm/pmm.o  obj/libs/string.o obj/libs/printfmt.o
     ```

   - 第9行是使用objdump工具对kernel目标文件反汇编，以便后续调试。首先toobj返回obj/kernel.o，然后cgtype返回obj/kernel.asm，所以第148行相当于执行`objdump -S bin/kernel > obj/kernel.asm`，objdump的-S选项是交替显示将C源码和汇编代码。

     ```
     @$(OBJDUMP) -S $@ > $(call asmfile,kernel)
     OBJDUMP := $(GCCPREFIX)objdump
     // GCCPREFIX = 'i386-elf-' or ''
     asmfile = $(call cgtype,$(call toobj,$(1)),o,asm)
     cgtype = $(patsubst %.$(2),%.$(3),$(1))
     toobj = $(addprefix $(OBJDIR)$(SLASH)$(if $(2),$(2)$(SLASH)),\
     		$(addsuffix .o,$(basename $(1))))
     OBJDIR	:= obj
     SLASH	:= /
     ```

   - 第10行是使用objdump工具来解析kernel目标文件得到符号表。如果不关注格式处理，实际执行语句等效于`objdump -t bin/kernel > obj/kernel.sym`。

     ```
     @$(OBJDUMP) -t $@ | $(SED) '1,/SYMBOL TABLE/d; s/ .* / /; /^$$/d' > $(call sy    mfile,kernel)
     OBJDUMP := $(GCCPREFIX)objdump
     SED		:= sed
     symfile = $(call cgtype,$(call toobj,$(1)),o,sym)
     ```

   - 第12行是调用create_target函数：`$(call create_target,kernel)`，而create_target的定义为`create_target = $(eval $(call do_create_target,$(1),$(2),$(3),$(4),$(5)))`，可见create_target只是进一步调用了do_create_target的函数：`do_create_target(kernel)`，do_create_target的定义如下。由于只有一个输入参数，temp_objs为空字符串，并且走的是else分支，因此感觉这里的函数调用是直接返回，啥也没干？

   ```
   // add packets and objs to target (target, #packes, #objs[, cc, flags])
   define do_create_target
   __temp_target__ = $(call totarget,$(1))
   __temp_objs__ = $$(foreach p,$(call packetname,$(2)),$$($$(p))) $(3)
   TARGETS += $$(__temp_target__)
   ifneq ($(4),)
   $$(__temp_target__): $$(__temp_objs__) | $$$$(dir $$$$@)
   	$(V)$(4) $(5) $$^ -o $$@
   else
   $$(__temp_target__): $$(__temp_objs__) | $$$$(dir $$$$@)
   endif
   ```

#### 生成bootblock

Makefile文件内容如下：

```
bootfiles = $(call listf_cc,boot)
$(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))

bootblock = $(call totarget,bootblock)

$(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)
	@echo + ld $@
	$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)
	@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)
	@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)
	@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)

$(call create_target,bootblock)
```

1. 第1行：`bootfiles = $(call listf_cc,boot)`，前面已经知道listf_cc函数是过滤出对应目录下的.c和.S文件，因此`bootfiles=boot/\*.c boot/\*.S`

2. 第2行：从字面含义也可以看出是编译bootfiles生成.o文件。

   ```
   $(foreach f,$(bootfiles),$(call cc_compile,$(f),$(CC),$(CFLAGS) -Os -nostdinc))
   cc_compile = $(eval $(call do_cc_compile,$(1),$(2),$(3),$(4)))
   define do_cc_compile
   $$(foreach f,$(1),$$(eval $$(call cc_template,$$(f),$(2),$(3),$(4))))
   endef
   ```

   cc_template的定义为

   ```
   // cc compile template, generate rule for dep, obj: (file, cc[, flags, dir])
   define cc_template
   $$(call todep,$(1),$(4)): $(1) | $$$$(dir $$$$@)
     @$(2) -I$$(dir $(1)) $(3) -MM $$< -MT "$$(patsubst %.d,%.o,$$@) $$@"> $$@
   $$(call toobj,$(1),$(4)): $(1) | $$$$(dir $$$$@)
     @echo + cc $$<
     $(V)$(2) -I$$(dir $(1)) $(3) -c $$< -o $$@
   ALLOBJS += $$(call toobj,$(1),$(4))
   endef
   ```

3. 第3行：`bootblock = $(call totarget,bootblock)`，前面已经知道totarget函数是给输入参数增加前缀"bin/"，因此`bootblock="bin/bootblock"`

4. 第6行声明bin/bootblock依赖于obj/boot/*.o 和bin/sign文件：`$(bootblock): $(call toobj,$(bootfiles)) | $(call totarget,sign)`。注意toobj函数的作用是给输入参数增加前缀obj/，并将文件后缀名改为.o

5. 第8行链接所有.o文件以生成obj/bootblock.o：`$(V)$(LD) $(LDFLAGS) -N -e start -Ttext 0x7C00 $^ -o $(call toobj,bootblock)`。这里要注意链接选项中的`-e start -Ttext 0x7C00`，大致意思是设置bootblock的入口地址为start标签，而且start标签的地址为0x7C00.（未理解-Ttext的含义）

6. 第9行反汇编obj/bootblock.o文件得到obj/bootblock.asm文件：`@$(OBJDUMP) -S $(call objfile,bootblock) > $(call asmfile,bootblock)`

7. 第10行使用objcopy将obj/bootblock.o转换生成obj/bootblock.out文件，其中-S表示转换时去掉重定位和符号信息：`@$(OBJCOPY) -S -O binary $(call objfile,bootblock) $(call outfile,bootblock)`

8. 第11行使用bin/sign工具将obj/bootblock.out转换生成bin/bootblock目标文件：`@$(call totarget,sign) $(call outfile,bootblock) $(bootblock)`，从tools/sign.c代码中可知sign工具其实只做了一件事情：将输入文件拷贝到输出文件，控制输出文件的大小为512字节，并将最后两个字节设置为0x55AA（也就是ELF文件的magic number）

9. 第12行调用了create_target函数`$(call create_target,bootblock)`，根据上文的分析，由于只有一个输入参数，此处函数调用应该也是直接返回，啥也没干。

#### 生成sign工具

Makefile文件内容如下：

```
$(call add_files_host,tools/sign.c,sign,sign)
$(call create_target_host,sign,sign)
```

1. 第1行调用了add_files_host函数：`$(call add_files_host,tools/sign.c,sign,sign)`

   add_files_host的定义为`add_files_host = $(call add_files,$(1),$(HOSTCC),$(HOSTCFLAGS),$(2),$(3))`，可见是调用了add_files函数：`add_files(tools/sign.c, gcc, $(HOSTCFLAGS), sign, sign)`

   add_files的定义为`add_files = $(eval $(call do_add_files_to_packet,$(1),$(2),$(3),$(4),$(5)))`，根据前面的分析，do_add_files_to_packet的作用是生成obj文件，因此这里调用add_files的作用是设置`__objs_sign = obj/sign/tools/sign.o`

2. 第2行调用了create_target_host函数：`$(call create_target_host,sign,sign)`

3. create_target_host的定义为`create_target_host = $(call create_target,$(1),$(2),$(3),$(HOSTCC),$(HOSTCFLAGS))`，可见是调用了create_target函数：`create_target(sign, sign, gcc, $(HOSTCFLAGS))`

4. create_target的定义为`create_target = $(eval $(call do_create_target,$(1),$(2),$(3),$(4),$(5)))`。根据前面的分析，do_create_target的作用是生成目标文件，因此这里调用create_target的作用是生成`obj/sign/tools/sign.o`

#### 生成ucore.img

Makefile文件内容如下：

```
UCOREIMG	:= $(call totarget,ucore.img)

$(UCOREIMG): $(kernel) $(bootblock)
	$(V)dd if=/dev/zero of=$@ count=10000
	$(V)dd if=$(bootblock) of=$@ conv=notrunc
	$(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc

$(call create_target,ucore.img)
```

1. 第1行设置了ucore.img的目标名：`UCOREIMG := $(call totarget,ucore.img)`，前面已经知道totarget的作用是添加bin/前缀，因此`UCOREIMG = bin/ucore.img`

2. 第3行指出bin/ucore.img依赖于bin/kernel和bin/bootblock：`$(UCOREIMG): $(kernel) $(bootblock)`

3. 第4行：`$(V)dd if=/dev/zero of=$@ count=10000`。这里为bin/ucore.img分配10000个block的内存空间，并全部初始化为0。由于没指定block的大小，因此为默认值512字节，则总大小为5000M，约5G。

   > 备注：在类UNIX 操作系统中, /dev/zero 是一个特殊的文件，当你读它的时候，它会提供无限的空字符(NULL, ASCII NUL, 0x00)。其中的一个典型用法是用它提供的字符流来覆盖信息，另一个常见用法是产生一个特定大小的空白文件。BSD就是通过mmap把/dev/zero映射到虚地址空间实现共享内存的。可以使用mmap将/dev/zero映射到一个虚拟的内存空间，这个操作的效果等同于使用一段匿名的内存（没有和任何文件相关）。

4. 第5行：`$(V)dd if=$(bootblock) of=$@ conv=notrunc`。这里将bin/bootblock复制到bin/ucore.img

5. 第6行：`$(V)dd if=$(kernel) of=$@ seek=1 conv=notrunc`。继续将bin/kernel复制到bin/ucore.img，这里使用了选项`seek=1`，意思是：复制时跳过bin/ucore.img的第一个block，从第2个block也就是第512个字节后面开始拷贝bin/kernel的内容。原因是显然的：ucore.img的第1个block已经用来保存bootblock的内容了。

6. 第8行：`$(call create_target,ucore.img)`，由于只有一个输入参数，因此这里会直接返回。

#### 总结：

这一次再来看一下执行`make "=V"`，为什么会得到以下编译过程

```
+ cc kern/init/init.c
gcc -Ikern/init/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/init/init.c -o obj/kern/init/init.o
+ cc kern/libs/stdio.c
gcc -Ikern/libs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/stdio.c -o obj/kern/libs/stdio.o
+ cc kern/libs/readline.c
gcc -Ikern/libs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/libs/readline.c -o obj/kern/libs/readline.o
+ cc kern/debug/panic.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/panic.c -o obj/kern/debug/panic.o
+ cc kern/debug/kdebug.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kdebug.c -o obj/kern/debug/kdebug.o
+ cc kern/debug/kmonitor.c
gcc -Ikern/debug/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/debug/kmonitor.c -o obj/kern/debug/kmonitor.o
+ cc kern/driver/clock.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/clock.c -o obj/kern/driver/clock.o
+ cc kern/driver/console.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/console.c -o obj/kern/driver/console.o
+ cc kern/driver/picirq.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/picirq.c -o obj/kern/driver/picirq.o
+ cc kern/driver/intr.c
gcc -Ikern/driver/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/driver/intr.c -o obj/kern/driver/intr.o
+ cc kern/trap/trap.c
gcc -Ikern/trap/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/trap.c -o obj/kern/trap/trap.o
+ cc kern/trap/vectors.S
gcc -Ikern/trap/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/vectors.S -o obj/kern/trap/vectors.o
+ cc kern/trap/trapentry.S
gcc -Ikern/trap/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/trap/trapentry.S -o obj/kern/trap/trapentry.o
+ cc kern/mm/pmm.c
gcc -Ikern/mm/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/mm/pmm.c -o obj/kern/mm/pmm.o
+ cc libs/string.c
gcc -Ilibs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/  -c libs/string.c -o obj/libs/string.o
+ cc libs/printfmt.c
gcc -Ilibs/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/  -c libs/printfmt.c -o obj/libs/printfmt.o
+ ld bin/kernel
ld -m    elf_i386 -nostdlib -T tools/kernel.ld -o bin/kernel  obj/kern/init/init.o obj/kern/libs/stdio.o obj/kern/libs/readline.o obj/kern/debug/panic.o obj/kern/debug/kdebug.o obj/kern/debug/kmonitor.o obj/kern/driver/clock.o obj/kern/driver/console.o obj/kern/driver/picirq.o obj/kern/driver/intr.o obj/kern/trap/trap.o obj/kern/trap/vectors.o obj/kern/trap/trapentry.o obj/kern/mm/pmm.o  obj/libs/string.o obj/libs/printfmt.o
+ cc boot/bootasm.S
gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootasm.S -o obj/boot/bootasm.o
+ cc boot/bootmain.c
gcc -Iboot/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Os -nostdinc -c boot/bootmain.c -o obj/boot/bootmain.o
+ cc tools/sign.c
gcc -Itools/ -g -Wall -O2 -c tools/sign.c -o obj/sign/tools/sign.o
gcc -g -Wall -O2 obj/sign/tools/sign.o -o bin/sign
+ ld bin/bootblock
ld -m    elf_i386 -nostdlib -N -e start -Ttext 0x7C00 obj/boot/bootasm.o obj/boot/bootmain.o -o obj/bootblock.o
'obj/bootblock.out' size: 484 bytes
build 512 bytes boot sector: 'bin/bootblock' success!
dd if=/dev/zero of=bin/ucore.img count=10000
dd if=bin/bootblock of=bin/ucore.img conv=notrunc
dd if=bin/kernel of=bin/ucore.img seek=1 conv=notrunc
```

1. 1-32行全部都是对kern/和libs/下的.c文件进行编译，而具体是那部分导致了执行这些指令呢，具体就是生成kern那一步。随便拿一条1-32行的执行举例

   ```
   + cc kern/init/init.c
   gcc -Ikern/init/ -march=i686 -fno-builtin -fno-PIC -Wall -ggdb -m32 -gstabs -nostdinc  -fno-stack-protector -Ilibs/ -Ikern/debug/ -Ikern/driver/ -Ikern/trap/ -Ikern/mm/ -c kern/init/init.c -o obj/kern/init/init.o
   ```

   可以看到它有多个-Ikern/*和-Ilibs/而这些定义都是在生成kernel那一步进行的。

2. 33-34行，也是在生成kernel那一步进行的，做的就是链接工作

3. 35-41行，就是编译boot/和sign/下的文件了，对应的也就是生成bootblock和生成sign

4. 42-43行，是在生成bootblock那步做的，主要的功能也就是链接

5. 45行，是利用sign工具将bin/bootblock.out文件转化为512字节的bin/bootblock文件，并将bin/bootblock的最后两个字节设置为0x55AA

6. 46行，是给ucore.img分配空间，在生成ucore.img那步进行

7. 47-48行，是把bootblock和kernal复制到ucore.img的第一块和第二块去

整体步骤就是

1. 编译libs和kern目录下所有的.c和.S文件，生成.o文件，并链接得到bin/kernel文件
2. 编译boot目录下所有的.c和.S文件，生成.o文件，并链接得到bin/bootblock.out文件
3. 编译tools/sign.c文件，得到bin/sign文件
4. 利用bin/sign工具将bin/bootblock.out文件转化为512字节的bin/bootblock文件，并将bin/bootblock的最后两个字节设置为0x55AA
5. 为bin/ucore.img分配5000MB的内存空间，并将bin/bootblock复制到bin/ucore.img的第一个block，紧接着将bin/kernel复制到bin/ucore.img第二个block开始的位置

### 解2：

可以看到上一个问题中的整体步骤的第4步，转换512字节的文件，和最后两个字节设置为0x55AA，所以说sign的源文件中的代码就可以很好的解释"一个被系统认为是符合规范的硬盘主引导扇区的特征是什么？"

代码如下：

```
char buf[512];
memset(buf, 0, sizeof(buf));
FILE *ifp = fopen(argv[1], "rb");
int size = fread(buf, 1, st.st_size, ifp);
if (size != st.st_size) {
    fprintf(stderr, "read '%s' error, size is %d.\n", argv[1], size);
    return -1;
}
fclose(ifp);
buf[510] = 0x55;
buf[511] = 0xAA;
```

可以看到4到5行的代码功能就是读取st.st_size字节到buf中，然后检查函数返回值是不是与st.st_size相等也就是512，如果说不相等则反汇一个错误输出然后直接结束，如果符合就关闭之前打开的文件

10-11行很清楚的也就是设置最后两个字节为0X55AA

所以说答案就是，设置主引导扇区必须有512字节，而且最后两个字节应该是0X55AA

## Exercise 2

**问题：**

1. **从CPU加电后执行的第一条指令开始，单步跟踪BIOS的执行。**
2. **在初始化位置0x7c00设置实地址断点,测试断点正常。**
3. **从0x7c00开始跟踪代码运行,将单步跟踪反汇编得到的代码与bootasm.S和 bootblock.asm进行比较。**
4. **自己找一个bootloader或内核中的代码位置，设置断点并进行测试。**

### 解1：

这里首先需要修改一下tools/gdbinit中的内容，修改的内容如下：

```
file bin/kernel
target remote 127.0.0.1:1234
set architecture i8086
```

然后就直接qemu启动，然后gdb远程连接上去就可以了，这里我使用的是peda插件，经过测试pwndbg会出现错误的现象，所以就转用了peda和gef，还有就是有一个问题需要注意

现再CPU处于实模式，所以地址都是16位的，然而我们第一条指令的位置为0xffff0，就会导致回滚，所以在peda和gef里面显示的第一条指令的位置为0xfff0，不过执行的指令内容还是0xffff0处的。

先看一下0xffff0处的代码

```
   0xffff0:     jmp    0xf000:0xe05b
```

也就是跳转到0xf0e05,然后直接看一下0xfe05b处的代码

```
   0xfe05b:     cmp    DWORD PTR cs:0x6c48,0x0
   0xfe062:     jne    0xfd2e1
   0xfe066:     xor    dx,dx
   0xfe068:     mov    ss,dx
   0xfe06a:     mov    esp,0x7000
   0xfe070:     mov    edx,0xf3691
   0xfe076:     jmp    0xfd165
   0xfe079:     push   ebp
   0xfe07b:     push   edi
   0xfe07d:     push   esi
```

可以看到做的就是服一些初值等等，然后调用转0xfd165，所以接着看0xfd165处的代码

```
   0xfd165:     mov    ecx,eax                                                                           
   0xfd168:     cli
   0xfd169:     cld
   0xfd16a:     mov    eax,0x8f
   0xfd170:     out    0x70,al                                                                           
   0xfd172:     in     al,0x71                                                                           
   0xfd174:     in     al,0x92                                                                           
   0xfd176:     or     al,0x2
   0xfd178:     out    0x92,al                                                                           
   0xfd17a:     lidtw  cs:0x6c38
   0xfd180:     lgdtw  cs:0x6bf4
   0xfd186:     mov    eax,cr0
   0xfd189:     or     eax,0x1
   0xfd18d:     mov    cr0,eax
   0xfd190:     jmp    0x8:0xfd198
```

第2-3行：cli是禁止中断，cld指令是使DF复位

第4-6行：这里 mov 0x8f 到 eax 中, 然后将值导入 0x70 端口, 是为了能通过 0x71 端口访问存储单元 0xf 的值(`in al,0x71`), 并且关闭 NMI 中断. 但是 al 的值并没有被利用. **所以认为这三行是用来关闭 NMI 中断的.**

第7-9行：这三行的作用就是将 0x92 端口的 bit1 修改为 1.
0x92 控制的是 PS/2 系统控制接口 A, 而 bit 1= 1 indicates A20 active, 即 bit1 是 A20 位, 即第 21 个地址线被使能. **A20 地址线被激活时, 系统工作在保护模式.** 但是 boot loader 程序中计算机仍需要工作在实模式下. 所以这里应该只是测试可用内存空间.

第10行：将从地址 0x6c38 起始的后面 6 个字节数据读入 IDTR （中断向量表寄存器）中

第11行：将从地址 0x6bf4 起始的后面 6 个字节数据读入 GDTR（全局描述符表格寄存器）中

第12-14行：要想进入保护模式还需要把cr0上的开关打开以保证可以进入保护模式，不过由于不能直接对cr0进行操作就使用寄存器暂时保存一下然后修改好对应的值，再通过寄存器传回cr0处

第15行：跳转到0xfd198地址处，并且此时已经变成了保护模式，可以使用超过16位的地址了

然后就是0xfd198这块的代码了

```
   0xfd198:     mov    ax,0x10                                                                           
   0xfd19b:     add    BYTE PTR [bx+si],al                                                               
   0xfd19d:     mov    ds,ax                                                                             
   0xfd19f:     mov    es,ax                                                                             
   0xfd1a1:     mov    ss,ax                                                                             
   0xfd1a3:     mov    fs,ax                                                                             
   0xfd1a5:     mov    gs,ax                                                                             
   0xfd1a7:     mov    ax,cx                                                                             
   0xfd1a9:     jmp    dx 
```

可以看到这是在初始化各个段寄存器，然后跳转到dx，然而dx是16位的，所以跳转到的是一个16位的地址0x3691，但是实际上跳转到的还是0xf3691（这里具体是因为什么不太懂），对应的代码如下

```
   0xf3691:     push   bx
   0xf3692:     sub    sp,0x20
   0xf3695:     push   0x5cf8
   0xf369a:     push   0x4770
   0xf369f:     call   0xf0cc7
```

这里实际调试的时候和反汇编给的代码不一致，上面的代码是调试的时候给出的代码，两个push分别是push进去了两个字符串

`Ubuntu-1.8.2-1ubuntu1`和`SeaBIOS (version %s)\n`然后就转去调用0xf0cc7函数，对应的代码如下：

```
   0xf0cc9:     lea    cx,[si+0x24]
   0xf0ccd:     mov    dx,WORD PTR [si+0x24]
   0xf0cd1:     mov    ax,0x5cf4
   0xf0cd6:     call   0xf0852
```

执行的功能就是把`Ubuntu-1.8.2-1ubuntu1`赋给ecx，`SeaBIOS (version %s)\n`赋给edx，ax赋的是0然后又去调用0xf0852。

再之后的就是输出一些字符串。就不做分析了

### 解2：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-06_15-36-48.png)

断点无异常

### 解3：

下面这段代码是gdb反汇编得到的代码，代码内容如下:

```
   0x7c00:      cli    
   0x7c01:      cld    
   0x7c02:      xor    ax,ax
   0x7c04:      mov    ds,ax
   0x7c06:      mov    es,ax
   0x7c08:      mov    ss,ax
   0x7c0a:      in     al,0x64
   0x7c0c:      test   al,0x2
   0x7c0e:      jne    0x7c0a
   0x7c10:      mov    al,0xd1
   0x7c12:      out    0x64,al
   0x7c14:      in     al,0x64
   0x7c16:      test   al,0x2
   0x7c18:      jne    0x7c14
   0x7c1a:      mov    al,0xdf
   0x7c1c:      out    0x60,al
   0x7c1e:      lgdtw  ds:0x7c6c
   0x7c23:      mov    eax,cr0
   0x7c26:      or     eax,0x1
   0x7c2a:      mov    cr0,eax
   0x7c2d:      jmp    0x8:0x7c32
   0x7c32:      mov    eax,0xd88e0010
   0x7c38:      mov    es,ax
   0x7c3a:      mov    fs,ax
   0x7c3c:      mov    gs,ax
   0x7c3e:      mov    ss,ax
   0x7c40:      mov    bp,0x0
   0x7c43:      add    BYTE PTR [bx+si],al
   0x7c45:      mov    sp,0x7c00
   0x7c48:      add    BYTE PTR [bx+si],al
   0x7c4a:      call   0x7d07
```

下面这个是bootasm.S的代码内容：

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
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042's P2 port

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2's A20 bit(the 1 bit) to 1

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    lgdt gdtdesc
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg

.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp
    call bootmain

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin

# Bootstrap GDT
.p2align 2                                          # force 4 byte alignment
gdt:
    SEG_NULLASM                                     # null seg
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt

```

得出结论：反汇编的代码也就是从0x7c00起始的代码与bootloader.S中的汇编代码相同。

### 解4：

动调得到的反汇编代码：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-06_18-34-16.png)

可以看到这就对应着源代码中bootmain.c调用的第一个函数，这些内容就是在制造参数然后把参数压入栈中

## Exercise 3

**问题：如何从实模式切换到保护模式**

### 解：

**第一步：宏定义以及实模式下的初始化**

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

**第二步：实模式转换保护模式**

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

## Exercise 4

**问题：**

- **bootloader如何读取硬盘扇区的？**
- **bootloader是如何加载ELF格式的OS？**

### 解1：

**源码分析：**

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

### 解2：

**现再内核就已经从磁盘上加载到内存中了，之后就是运行内核了，跳转到对应位置去运行内核之前，还需要做一些准备工作，也就是怎么加载ELF格式的OS**

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

## Exercise 5

**问题：**

**在lab1中完成kdebug.c中函数print_stackframe的实现，可以通过函数print_stackframe来跟踪函数调用堆栈中记录的返回地址。在如果能够正确实现此函数，可在lab1中执行 “make qemu”后，在qemu模拟器中得到类似如下的输出：**

### 解：

```
void
print_stackframe(void) {
     /* LAB1 YOUR CODE : STEP 1 */
     /* (1) call read_ebp() to get the value of ebp. the type is (uint32_t);
      * (2) call read_eip() to get the value of eip. the type is (uint32_t);
      * (3) from 0 .. STACKFRAME_DEPTH
      *    (3.1) printf value of ebp, eip
      *    (3.2) (uint32_t)calling arguments [0..4] = the contents in address (uint32_t)ebp +2 [0..4]
      *    (3.3) cprintf("\n");
      *    (3.4) call print_debuginfo(eip-1) to print the C calling function name and line number, etc.
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
    uint32_t ebp = read_ebp();
    uint32_t eip = read_eip();
    uint32_t arg0;
    uint32_t arg1;
    uint32_t arg2;
    uint32_t arg3;
    for(int i = 0; i < STACKFRAME_DEPTH && ebp != 0; i++){
        cprintf("ebp:0x%08x eip:0x%08x ",ebp,eip);
        arg0 = *((uint32_t *)ebp + 2);
        arg1 = *((uint32_t *)ebp + 3);
        arg2 = *((uint32_t *)ebp + 4);
        arg3 = *((uint32_t *)ebp + 5);
        cprintf("args:0x%08x 0x%08x 0x%08x 0x%08x",arg0,arg1,arg2,arg3);
        cprintf("\n");
        print_debuginfo(eip);
        eip = *((uint32_t *)ebp + 1);
        ebp = *((uint32_t *)ebp);
    }
}
```

输出结果：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-06_19-03-38.png)

## Exercise 6

**问题：**

1. **中断描述符表（也可简称为保护模式下的中断向量表）中一个表项占多少字节？其中哪几位代表中断处理代码的入口？**
2. **请编程完善kern/trap/trap.c中对中断向量表进行初始化的函数idt_init。在idt_init函数中，依次对所有中断入口进行初始化。使用mmu.h中的SETGATE宏，填充idt数组内容。每个中断的入口由tools/vectors.c生成，使用trap.c中声明的vectors数组即可。**
3. **请编程完善trap.c中的中断处理函数trap，在对时钟中断进行处理的部分填写trap函数中处理时钟中断的部分，使操作系统每遇到100次时钟中断后，调用print_ticks子程序，向屏幕上打印一行文字”100 ticks”。**

### 解1：

一个表项占64位即8字节，2、3字节是段选择子，0、1字节和6、7字节拼成位移， 两者联合便是中断处理程序的入口地址。

### 解2：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-06_19-04-38.png)

根据这张图就可以写出对应的代码，而且文件中也给了提示，代码如下：

```
/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
     /* LAB1 YOUR CODE : STEP 2 */
     /* (1) Where are the entry addrs of each Interrupt Service Routine (ISR)?
      *     All ISR's entry addrs are stored in __vectors. where is uintptr_t __vectors[] ?
      *     __vectors[] is in kern/trap/vector.S which is produced by tools/vector.c
      *     (try "make" command in lab1, then you will find vector.S in kern/trap DIR)
      *     You can use  "extern uintptr_t __vectors[];" to define this extern variable which will be used later.
      * (2) Now you should setup the entries of ISR in Interrupt Description Table (IDT).
      *     Can you see idt[256] in this file? Yes, it's IDT! you can use SETGATE macro to setup each item of IDT
      * (3) After setup the contents of IDT, you will let CPU know where is the IDT by using 'lidt' instruction.
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    for(int i = 0; i < 256 ; i++){
        if(i == 121){
            SETGATE(idt[i],0,8,__vectors[i],3);
        }
        else{
            SETGATE(idt[i],0,8,__vectors[i],0);
        }        
        //first     idt[i] for store descriptors
        //second    istrap: 1 for a trap (= exception) gate, 0 for an interrupt gate
        //third     sel: Code segment selector for interrupt/trap handler kenal's sel=1<<3=8
        //fourth    off: Offset in code segment for interrupt/trap handler
        //fifth     dpl: Descriptor Privilege Level - the privilege level required
        //          for software to invoke this interrupt/trap gate explicitly
        //          using an int instruction.
    }

    lidt(&idt_pd);
}
```

**英文提示为解题关键**

### 解3：

根据文件中的英文提示和trap.h那个头文件就可以写出代码，代码如下：

```
/* *
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    int count; ;
    if(tf->tf_trapno == 33){
        char c;
        c = cons_getc();
        cprintf("kbd [%03d] %c\n", c, c);
    }
    if(tf->tf_trapno == 32){
        count++;
        if(count % 100 == 0){
            count = 0;
            print_ticks();
        }
    }
    
}
```

**英文提示为解题关键**

## Extend Exercise

**问题：**

1. **增加syscall功能，即增加一用户态函数，当内核初始完毕后，可从内核态返回到用户态的函数，而用户态的函数又通过系统调用得到内核态的服务**
2. **用键盘实现用户模式内核模式切换。具体目标是：“键盘输入3时切换到用户模式，键盘输入0时切换到内核模式”。 基本思路是借鉴软中断(syscall功能)的代码，并且把trap.c中软中断处理的设置语句拿过来。**

### 解1：

这个问题其实就是对应着知识点里，中断发生特权级转换都应该做什么，使用代码把具体内容实现了就可以了

其中trapframe存储着中断信息，即发生中断时对应的各个寄存器的值，以用户态切换内核态为例子，用户态切换成内核态首先就是需要更改段寄存器，因为内核段和用户段的代码位置肯定不一样，所以说就需要设置当前的cs寄存器为内核段的cs，然后就是剩余的寄存器也需要切换成内核段下的，然后进行正常的中断返回，由于iret指令发现CPL和保存在栈上的cs的CPL均为0，因此不会进行特权级的切换，因此自然而不会切换栈和将栈上保存的ss和esp弹出。这就产生了中断返回之后，栈上的内容没能够正常恢复的问题，因此需要在中断返回之后将栈上保存的原本应当被恢复的esp给pop回到esp上去，这样才算是完整地完成了从用户态切换到内核态的要求；

```c
case T_SWITCH_TOK:
    tf->tf_cs = KERNEL_CS;
    tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = KERNEL_DS;
        break;

static void // 从用户态切换到内核态的函数
lab1_switch_to_kernel(void) { 
	asm volatile (
	        "int %0\n\t" // 使用int指令产生软中断
	        "popl %%esp" // 恢复esp
	        :
	        : "i"(T_SWITCH_TOK)
	    );
}	
```

同理就是内核态切换回用户态了，也是一样的操作修改对应的各个段寄存器，然后恢复对应的栈，但是也是有一些细小的不一样的地方，就是在内核中触发软中断，不会产生特权级交换，也就是不会保存ss和esp，但是在从中断处理函数返回的时候我们需要返回到原来的地方去，但是栈里的内容和原先的不一样了，所以我们需要代替中断处理函数完成这个操作，首先就是把ss和sp保存到一个数据区域，然后在触发中断之前，把他们压入到栈里面，还有一个需要注意的地方就是为了使得程序在低CPL的情况下仍然能够使用IO，需要将eflags中对应的IOPL位置成表示用户态的3，代码如下：

```c
asm volatile (
            "movw %%ss, %0\n\t"
            "movl %%esp, %1"
            : "=a"(ss), "=b"(esp)
         );
    
asm volatile (
        "pushl %0\n\t"
        "pushl %1\n\t"
        "int %2"
        :
        : "a"(ss), "b"(esp), "i"(T_SWITCH_TOU)
     );

case T_SWITCH_TOU:
        tf->tf_eflags |= FL_IOPL_MASK;
        tf->tf_cs = USER_CS;
        tf->tf_ds = tf->tf_es = tf->tf_gs = tf->tf_ss = tf->tf_fs = USER_DS;
        break;
```

### 解2：

根据题干给的提示说**基本思路是借鉴软中断(syscall功能)的代码，并且把trap.c中软中断处理的设置语句拿过来。**

所以这里就直接修改trap.c中case IRQ_OFFSET + IRQ_KBD的代码就可以了，也就是在trap.c中定义两个函数，分别是init.c中对应的lab1_switch_to_kernel和lab1_switch_to_user，然后加两个if判断，如果是按3或者按0就去执行对应的软中断即可，代码如下

```
case IRQ_OFFSET + IRQ_KBD:
c = cons_getc();
if (c == '3') {
    switch_to_user();
    print_trapframe(tf);
} else if (c == '0') {
    switch_to_kernel();
    print_trapframe(tf);
}
cprintf("kbd [%03d] %c\n", c, c);
break;
```

这个第二个问题，网上很多的代码都不正确，有的虽然可以正确输出，但是输出出来的值都是不对的，所以就找了个最贴近正确的。如下：

> 作者：AmadeusChan
> 链接：https://www.jianshu.com/p/2f95d38afa1d

拓展练习2的内容为实现“键盘输入3的时候切换到用户模式，输入0的时候进入内核模式”, 该功能的实现基本思路与拓展练习1较为类似，但是具体实现却要困难需要，原因在于拓展1的软中断是故意在某一个特定的函数中触发的，因此可以在触发中断之前对堆栈进行设置以及在中断返回之后对堆栈内容进行修复，但是如果要在触发键盘中断的时候切换特权级，由于键盘中断是异步的，无法确定究竟是在哪个指令处触发了键盘中断，因此在触发中断前对堆栈的设置以及在中断返回之后对堆栈的修复也无从下手；（需要对堆栈修复的原因在于，使用iret来切换特权级的本质在于伪造一个从某个指定特权级产生中断所导致的现场对CPU进行欺骗，而是否存在特权级的切换会导致硬件是否在堆栈上额外压入ss和esp以及进行堆栈的切换，这使得两者的堆栈结构存在不同）

因此需要考虑在ISR中在修改trapframe的同时对栈进行更进一步的伪造，比如在从内核态返回到用户态的时候，在trapframe里额外插入原本不存在的ss和esp，在用户态返回到内核态的时候，将trapframe中的esp和ss删去等，更加具体的实现方法如下所示：

- 首先考虑从内核态切换到用户态的方法：
  - 从内核态切换到用户态的关键在于“欺骗”ISR中的最后一条指令iret，让CPU错以为原本该中断是发生在用户态下的，因此在最终中断返回的时候进行特权级的切换，切换到用户态，根据lab代码的内容，可以发现具体的每一个中断的处理是在trap_dispatch函数中统一进行的分类处理，而其中键盘中断的中断号为IRQ_OFFSET+IRQ_KBD，找到该中断号对应的case语句，在正常的处理流程之后，额外插入伪造栈上信息的代码，具体方法如下：
    - 将trapframe的地址保存到一个静态变量中，防止在接下来修改堆栈的时候破坏了堆栈，导致获取不到正确的trapframe地址；
    - 将整个trapframe以及trapframe以下（低地址部分）的堆栈上的内容向低地址部分平移8个字节，这使得trapframe的高地址部分空出来两个双字的空间，可以用于保存伪造的esp和ss的数值，这部分代码由于在操作过程中不能够使用到堆栈上的信息，为了保险起见，是在由汇编代码编写成的函数中完成的，具体为kern/trap/trapentry.S文件中的__move_down_stack2函数，该函数接受两个参数，分别为trapframe在高、低地址处的边界；
    - 由于上述操作对一整块区域进行向低地址部分的平移，这就会使得这块区域中保存的动态连信息出现错误（保存在栈上的ebp的数值），因此需要沿着动态链修复这些栈上的ebp的数值，具体方式为对其减8；
    - 然后需要对ebp和esp寄存器分别减8，得到真正的ebp和esp的数值；
    - 最后，由于__alltraps函数在栈上保存了该函数调用trap函数前的esp数值，因此也需要将该esp数值修改成与平移过后的栈一致的数值，也就是平移过后的trapframe的低地址边界；
    - 上述三个操作为了保险起见，均使用汇编代码编写在函数__move_down_stack2中；
    - 然后在完成了堆栈平移，为伪造的ss和esp空出空间之后，按照拓展1的方法，对trapframe的内容进行修改，并且将伪造的esp和ss的数值填入其中；
    - 接下来正常中断返回，硬件由于原先的trapframe上的cs中的CPL是3，因此可以顺利切换到用户态，并且由于上述对堆栈的维护操作，在返回用户态之后仍然可以继续正常执行代码；
- 接下来考虑从用户态切换到内核态的方法：
  - 从用户态切换回内核态的关键仍然在于“伪造”一个现场来欺骗硬件，使得硬件误认为原先就是在内核态发生的中断，因此不会切换回用户态，具体实现方法如下：
    - 为了使得中断返回之后能够正常执行原先被打断的程序，不烦考虑在事实上为用户态的栈上进行现场伪造，首先将被保存在内核态上的自trapframe及以下（低地址）的所有内容都复制到原先用户态的栈上面去；（注意不要复制trapframe上的ss和esp）
    - 与切换到用户态相似的，对伪造的栈上的动态链（ebp）信息进行修复；
    - 对__alltraps函数压入栈的esp信息进行修复；
    - 上述代码为了保险期间，使用汇编语言实现，具体为trapentry.S文件的__move_up_stack2函数中；
    - 将伪造的栈上的段寄存器进行修改，使其指向DPL为0的相应段描述符；
    - 进行正常的中断返回，此时由于栈上的cs的CPL为内核态，因此硬件不会进行特权级的切换，从而使得中断返回之后也保持在内核态，从而完成了从用户态到内核态的切换；
- 实现本拓展所使用的汇编代码较为烦杂，因此未在实验报告中列出，要了解具体实现细节可以参考提交的代码文件；为了方便呈现实验效果，对init.c文件中的入口函数中的while (1)循环语句进行了修改，使得其可以在每个一段时间就打印出一次当前的CPU状态（包括特权级），然后得到的实验结果如下图所示。从图中可以看出当按下键盘数字3的时候，特权级切换到3（用户态），再按下键盘数字0的时候，特权级被切换到0（内核态）；即最终实验结果符合实验要求。

**注：最终提交的代码中，为了防止上述while (1)循环中打印状态的输出对其他实验内容的输出结果产生干扰，已经将相关打印的代码注释掉了，因此如果需要获得下图的输出效果，如要将init.c中kern_init函数的while (1)循环中打印状态的语句的注释解除掉;**

```
case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
        cprintf("kbd [%03d] %c\n", c, c);
        if (c == 0x30) { // switch to kernel mode
            saved_tf = __move_up_stack2((uint32_t)(tf) + sizeof(struct trapframe) - 8, (uint32_t) tf, tf->tf_esp);
            saved_tf->tf_cs = KERNEL_CS;
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_gs = KERNEL_DS;
            saved_tf->tf_trapno = 0x21;
            asm volatile (
                "movw %0, %%ss"
                :
                : "r"(KERNEL_DS)
                 );
            print_trapframe(tf);
        }

        if (c == 0x33) { // switch to user mode
            saved_tf = (struct trapname*) ((uint32_t)(tf) - 8);
    
            __move_down_stack2( (uint32_t)(tf) + sizeof(struct trapframe) - 8 , (uint32_t) tf );

            saved_tf->tf_eflags |= FL_IOPL_MASK;
            saved_tf->tf_cs = USER_CS;
            saved_tf->tf_ds = saved_tf->tf_es = saved_tf->tf_fs = saved_tf->tf_ss = saved_tf->tf_gs = USER_DS;
            saved_tf->tf_esp = (uint32_t)(saved_tf + 1);
            saved_tf->tf_trapno = 0x21;
            print_trapframe(tf);
        }   
        break;
        
.globl __move_down_stack2 
# this function aims to move down the whole stack frame by 2 bytes so that we can insert our fake esp and ss into the trapframe
__move_down_stack2:
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx
    pushl %esi
    pushl %edi

    movl 8(%ebp), %ebx # ebx store the end (higher boundary) of current trapframe
    movl 12(%ebp), %edi
    subl $8, -4(%edi) # fix esp which __alltraps store on stack
    movl %esp, %eax

    cmpl %eax, %ebx
    jle loop_end

loop_start:
    movb (%eax), %cl
    movb %cl, -8(%eax)
    addl $1, %eax
    cmpl %eax, %ebx
    jg loop_start

loop_end: 
    subl $8, %esp 
    subl $8, %ebp # remember, it is critical to correct all the base pointer store in stack area which is affected by our operations above
    
    movl %ebp, %eax
    cmpl %eax, %ebx
    jle ebp_loop_end

ebp_loop_begin:
    movl (%eax), %ecx

    cmpl $0, %ecx
    je ebp_loop_end
    cmpl %ecx, %ebx
    jle ebp_loop_end
    subl $8, %ecx
    movl %ecx, (%eax)
    movl %ecx, %eax
    jmp ebp_loop_begin

ebp_loop_end:

    popl %edi
    popl %esi
    popl %ebx

    popl %ebp
    ret 

.globl __move_up_stack2
# this function aims to move the trapframe along with all stack frames below up by 2 bytes
# arg1 tf_end 
# arg2 tf
# arg3 user esp
__move_up_stack2:
    pushl %ebp 
    movl %esp, %ebp

    pushl %ebx
    pushl %edi
    pushl %esi

# first of all, copy every below tf_end to user stack
    movl 8(%ebp), %eax
    subl $1, %eax
    movl 16(%ebp), %ebx # ebx store the user stack pointer 
    
    cmpl %eax, %esp
    jg copy_loop_end

copy_loop_begin:
    subl $1, %ebx
    movb (%eax), %cl
    movb %cl, (%ebx)

    subl $1, %eax
    cmpl %eax, %esp
    jle copy_loop_begin

copy_loop_end:

# now we have to fix all ebp on user stack, note that we can calculate the true ebp using their address displacement
    movl %ebp, %eax
    cmpl %eax, 8(%ebp)
    jle fix_ebp_loop_end

fix_ebp_loop_begin:
    movl %eax, %edi
    subl 8(%ebp), %edi
    addl 16(%ebp), %edi # edi <=> eax

    cmpl (%eax), %esp 
    jle normal_condition
    movl (%eax), %esi
    movl %esi, (%edi)
    jmp fix_ebp_loop_end

normal_condition:
    movl (%eax), %esi
    subl 8(%ebp), %esi
    addl 16(%ebp), %esi
    movl %esi, (%edi)
    movl (%eax), %eax
    jmp fix_ebp_loop_begin

fix_ebp_loop_end:

# fix the esp which __alltraps store on stack
    movl 12(%ebp), %eax
    subl $4, %eax

    movl %eax, %edi
    subl 8(%ebp), %edi
    addl 16(%ebp), %edi

    movl (%eax), %esi
    subl 8(%ebp), %esi
    addl 16(%ebp), %esi

    movl %esi, (%edi)

    movl 12(%ebp), %eax
    subl 8(%ebp), %eax
    addl 16(%ebp), %eax

# switch to user stack
    movl %ebx, %esp
    movl %ebp, %esi
    subl 8(%ebp), %esi
    addl 16(%ebp), %esi
    movl %esi, %ebp

    popl %esi
    popl %edi
    popl %ebx

    popl %ebp
    ret
```

