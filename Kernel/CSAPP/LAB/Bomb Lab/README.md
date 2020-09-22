# Bomb Lab

这个没有提供phase的头文件，单单看bomb.c只能看出来一共用6个判断

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-22_13-44-31.png)

所以就需要取逆向汇编代码，我是用gdb动调得到汇编代码，然后逆的

## phase_1

这个很简单，有两个检测，一个是长度检测，即输入的字符长度是否和规定的字符串长度相同，另一个就是检测输入的字符串是否和规定的字符串相同。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-22_13-47-41.png)

phase_1的主要代码很简短，直接走进去看call的两个函数并分析就可以了。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-22_13-51-55.png)
从这块的代码可以看出来它做的操作就是一次遍历然后计数，计算输入的字符串的长度，然后如果说这个长度变为0了就会不进行跳转，就会往下执行，往下就是一个返回，所以说可以直接得到eax就是存储着输入的字符串的长度的。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-22_13-49-33.png)

其实运行到这里也就可以判断出来，输入的字符串应该为Border relations with Canada have never been better.了，但是还是应该跟进去看一下，在这个call结束之后，有一个mov r12d,eax，其中eax存储的就是输入的字符串的长度，然后把他保存在了r12里，然后又执行了一次call，这次call检测的是规定的字符串长度即"Border relations with Canada have never been better."它的长度，检测结束之后，eax就是保存着它的长度，然后有一个cmp执行进行比较，比较r12和eax，如果不符合就直接跳转到退出哪里，如果符合则继续。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-22_14-03-48.png)

然后就是检测每一位是否和规定的字符串一样，一样则成功不一样则失败。

所以说就可以得到phase_1的结果就是"Border relations with Canada have never been better."

## phase_2

```
=> 0x400efc <phase_2>:	    push   rbp
   0x400efd <phase_2+1>:	push   rbx
   0x400efe <phase_2+2>:	sub    rsp,0x28
   0x400f02 <phase_2+6>:	mov    rsi,rsp
   0x400f05 <phase_2+9>:	call   0x40145c <read_six_numbers>
   0x400f0a <phase_2+14>:	cmp    DWORD PTR [rsp],0x1
   0x400f0e <phase_2+18>:	je     0x400f30 <phase_2+52>
   0x400f10 <phase_2+20>:	call   0x40143a <explode_bomb>
   0x400f15 <phase_2+25>:	jmp    0x400f30 <phase_2+52>
   0x400f17 <phase_2+27>:	mov    eax,DWORD PTR [rbx-0x4]
   0x400f1a <phase_2+30>:	add    eax,eax
   0x400f1c <phase_2+32>:	cmp    DWORD PTR [rbx],eax
   0x400f1e <phase_2+34>:	je     0x400f25 <phase_2+41>
   0x400f20 <phase_2+36>:	call   0x40143a <explode_bomb>
   0x400f25 <phase_2+41>:	add    rbx,0x4
   0x400f29 <phase_2+45>:	cmp    rbx,rbp
   0x400f2c <phase_2+48>:	jne    0x400f17 <phase_2+27>
   0x400f2e <phase_2+50>:	jmp    0x400f3c <phase_2+64>
   0x400f30 <phase_2+52>:	lea    rbx,[rsp+0x4]
   0x400f35 <phase_2+57>:	lea    rbp,[rsp+0x18]
   0x400f3a <phase_2+62>:	jmp    0x400f17 <phase_2+27>
   0x400f3c <phase_2+64>:	add    rsp,0x28
   0x400f40 <phase_2+68>:	pop    rbx
   0x400f41 <phase_2+69>:	pop    rbp
   0x400f42 <phase_2+70>:	ret
```

一共就只有一个函数read_six_numbers，所以直接进去看一下read_six_numbers的内容

```
=> 0x40145c <read_six_numbers>:	    sub    rsp,0x18
   0x401460 <read_six_numbers+4>:	mov    rdx,rsi
   0x401463 <read_six_numbers+7>:	lea    rcx,[rsi+0x4]
   0x401467 <read_six_numbers+11>:	lea    rax,[rsi+0x14]
   0x40146b <read_six_numbers+15>:	mov    QWORD PTR [rsp+0x8],rax
   0x401470 <read_six_numbers+20>:	lea    rax,[rsi+0x10]
   0x401474 <read_six_numbers+24>:	mov    QWORD PTR [rsp],rax
   0x401478 <read_six_numbers+28>:	lea    r9,[rsi+0xc]
   0x40147c <read_six_numbers+32>:	lea    r8,[rsi+0x8]
   0x401480 <read_six_numbers+36>:	mov    esi,0x4025c3
   0x401485 <read_six_numbers+41>:	mov    eax,0x0
   0x40148a <read_six_numbers+46>:	call   0x400bf0 <__isoc99_sscanf@plt>
   0x40148f <read_six_numbers+51>:	cmp    eax,0x5
   0x401492 <read_six_numbers+54>:	jg     0x401499 <read_six_numbers+61>
   0x401494 <read_six_numbers+56>:	call   0x40143a <explode_bomb>
   0x401499 <read_six_numbers+61>:	add    rsp,0x18
   0x40149d <read_six_numbers+65>:	ret    
```

可以看到执行了scanf之后有一个cmp eax,0x5，eax保存的是scanf的返回值，scanf的返回值应该是正确按指定格式输入变量的个数，如果说eax大于0x5就跳转，咱们本来就应该输入6个数字，所以说只要按照"1 1 1 1 1 1"这种格式输入就可以绕过第一个检测，过了第一个检测就回到了0x400f0a

```
   0x400f0a <phase_2+14>:	cmp    DWORD PTR [rsp],0x1
   0x400f0e <phase_2+18>:	je     0x400f30 <phase_2+52>
```

这里是先直接判断第一个数是不是1，如果不是就退出，所以说第一个数应该为1。

```
   0x400f17 <phase_2+27>:	mov    eax,DWORD PTR [rbx-0x4]
   0x400f1a <phase_2+30>:	add    eax,eax
   0x400f1c <phase_2+32>:	cmp    DWORD PTR [rbx],eax
   0x400f1e <phase_2+34>:	je     0x400f25 <phase_2+41>
   0x400f20 <phase_2+36>:	call   0x40143a <explode_bomb>
   0x400f25 <phase_2+41>:	add    rbx,0x4
   0x400f29 <phase_2+45>:	cmp    rbx,rbp
   0x400f2c <phase_2+48>:	jne    0x400f17 <phase_2+27>
```

这里就是先把第一个数赋给eax然后加一倍，在比较eax和第二个数，如果相同则跳到0x400f25，不同则退出，所以说第二个数应该为2，到了0x400f25有一个rbx+0x4就是让rbx的值变成第二个数，然后比较rbx和rbp也就是看6个数是不是都比完了，然后继续循环。

所以说就可以直接看出来输入的前一个数的一倍应该等于后一个数，所以说6个数就应该是"1 2 4 8 16 32" 

## phase_3

```
=> 0x400f43 <phase_3>:	    sub    rsp,0x18
   0x400f47 <phase_3+4>:	lea    rcx,[rsp+0xc]
   0x400f4c <phase_3+9>:	lea    rdx,[rsp+0x8]
   0x400f51 <phase_3+14>:	mov    esi,0x4025cf
   0x400f56 <phase_3+19>:	mov    eax,0x0
   0x400f5b <phase_3+24>:	call   0x400bf0 <__isoc99_sscanf@plt>
   0x400f60 <phase_3+29>:	cmp    eax,0x1
   0x400f63 <phase_3+32>:	jg     0x400f6a <phase_3+39>
   0x400f65 <phase_3+34>:	call   0x40143a <explode_bomb>
   0x400f6a <phase_3+39>:	cmp    DWORD PTR [rsp+0x8],0x7
   0x400f6f <phase_3+44>:	ja     0x400fad <phase_3+106>
   0x400f71 <phase_3+46>:	mov    eax,DWORD PTR [rsp+0x8]
   0x400f75 <phase_3+50>:	jmp    QWORD PTR [rax*8+0x402470]
   0x400f7c <phase_3+57>:	mov    eax,0xcf
   0x400f81 <phase_3+62>:	jmp    0x400fbe <phase_3+123>
   0x400f83 <phase_3+64>:	mov    eax,0x2c3
   0x400f88 <phase_3+69>:	jmp    0x400fbe <phase_3+123>
   0x400f8a <phase_3+71>:	mov    eax,0x100
   0x400f8f <phase_3+76>:	jmp    0x400fbe <phase_3+123>
   0x400f91 <phase_3+78>:	mov    eax,0x185
   0x400f96 <phase_3+83>:	jmp    0x400fbe <phase_3+123>
   0x400f98 <phase_3+85>:	mov    eax,0xce
   0x400f9d <phase_3+90>:	jmp    0x400fbe <phase_3+123>
   0x400f9f <phase_3+92>:	mov    eax,0x2aa
   0x400fa4 <phase_3+97>:	jmp    0x400fbe <phase_3+123>
   0x400fa6 <phase_3+99>:	mov    eax,0x147
   0x400fab <phase_3+104>:	jmp    0x400fbe <phase_3+123>
   0x400fad <phase_3+106>:	call   0x40143a <explode_bomb>
   0x400fb2 <phase_3+111>:	mov    eax,0x0
   0x400fb7 <phase_3+116>:	jmp    0x400fbe <phase_3+123>
   0x400fb9 <phase_3+118>:	mov    eax,0x137
   0x400fbe <phase_3+123>:	cmp    eax,DWORD PTR [rsp+0xc]
   0x400fc2 <phase_3+127>:	je     0x400fc9 <phase_3+134>
   0x400fc4 <phase_3+129>:	call   0x40143a <explode_bomb>
   0x400fc9 <phase_3+134>:	add    rsp,0x18
   0x400fcd <phase_3+138>:	ret   
```

这里面没有其余的额外的函数了，就是输入一个数，然后检测输入的数字是不是大于1，如果大于则跳到0x400f6a，如果不大于则退出

```
   0x400f6a <phase_3+39>:	cmp    DWORD PTR [rsp+0x8],0x7
   0x400f6f <phase_3+44>:	ja     0x400fad <phase_3+106>
```

这里先比较第一个数和0x7，如果说第一个数大于7就退出，小于7则继续

```
   0x400f71 <phase_3+46>:	mov    eax,DWORD PTR [rsp+0x8]
   0x400f75 <phase_3+50>:	jmp    QWORD PTR [rax*8+0x402470]
```

这里就是把第一个数赋给eax，然后根据[rax*8+0x402470]这个运算的值来判断jmp到那里，我第一次输入的是1，所以就会跳转到0x400fb9这里

```
   0x400fb9 <phase_3+118>:	mov    eax,0x137
   0x400fbe <phase_3+123>:	cmp    eax,DWORD PTR [rsp+0xc]
   0x400fc2 <phase_3+127>:	je     0x400fc9 <phase_3+134>
```

这里是把0x137赋给eax，然后看第二个数是不是等于0x137，所以说第二个数也就确认了是0x137也就是311

所以输入"1 311"就可以了

## phase_4

```
=> 0x40100c <phase_4>:	    sub    rsp,0x18
   0x401010 <phase_4+4>:	lea    rcx,[rsp+0xc]
   0x401015 <phase_4+9>:	lea    rdx,[rsp+0x8]
   0x40101a <phase_4+14>:	mov    esi,0x4025cf
   0x40101f <phase_4+19>:	mov    eax,0x0
   0x401024 <phase_4+24>:	call   0x400bf0 <__isoc99_sscanf@plt>
   0x401029 <phase_4+29>:	cmp    eax,0x2
   0x40102c <phase_4+32>:	jne    0x401035 <phase_4+41>
   0x40102e <phase_4+34>:	cmp    DWORD PTR [rsp+0x8],0xe
   0x401033 <phase_4+39>:	jbe    0x40103a <phase_4+46>
   0x401035 <phase_4+41>:	call   0x40143a <explode_bomb>
   0x40103a <phase_4+46>:	mov    edx,0xe
   0x40103f <phase_4+51>:	mov    esi,0x0
   0x401044 <phase_4+56>:	mov    edi,DWORD PTR [rsp+0x8]
   0x401048 <phase_4+60>:	call   0x400fce <func4>
   0x40104d <phase_4+65>:	test   eax,eax
   0x40104f <phase_4+67>:	jne    0x401058 <phase_4+76>
   0x401051 <phase_4+69>:	cmp    DWORD PTR [rsp+0xc],0x0
   0x401056 <phase_4+74>:	je     0x40105d <phase_4+81>
   0x401058 <phase_4+76>:	call   0x40143a <explode_bomb>
   0x40105d <phase_4+81>:	add    rsp,0x18
   0x401061 <phase_4+85>:	ret
```

这里有一个func4函数，先输入两个数，如果说输入的正确格式的数不等2就退出，等于2则继续。所以说就应该输入两个数字。

```
   0x40102e <phase_4+34>:	cmp    DWORD PTR [rsp+0x8],0xe
   0x401033 <phase_4+39>:	jbe    0x40103a <phase_4+46>
```

这有一个比较，主要比较的是第一个数是不是小于等于14，如果说小于等于14就跳转到0x40103a这里，如果不小于等于14则退出。

```
   0x40103a <phase_4+46>:	mov    edx,0xe
   0x40103f <phase_4+51>:	mov    esi,0x0
   0x401044 <phase_4+56>:	mov    edi,DWORD PTR [rsp+0x8]
   0x401048 <phase_4+60>:	call   0x400fce <func4>
```

然后就是传参数，第一个参数是edi(第一个数)，第二个参数是esi(0)，第三个参数是edx(0xe)，然后就进入到func4里面了

```
=> 0x400fce <func4>:	sub    rsp,0x8
   0x400fd2 <func4+4>:	mov    eax,edx
   0x400fd4 <func4+6>:	sub    eax,esi
   0x400fd6 <func4+8>:	mov    ecx,eax
   0x400fd8 <func4+10>:	shr    ecx,0x1f
   0x400fdb <func4+13>:	add    eax,ecx
   0x400fdd <func4+15>:	sar    eax,1
   0x400fdf <func4+17>:	lea    ecx,[rax+rsi*1]
   0x400fe2 <func4+20>:	cmp    ecx,edi
   0x400fe4 <func4+22>:	jle    0x400ff2 <func4+36>
   0x400fe6 <func4+24>:	lea    edx,[rcx-0x1]
   0x400fe9 <func4+27>:	call   0x400fce <func4>
   0x400fee <func4+32>:	add    eax,eax
   0x400ff0 <func4+34>:	jmp    0x401007 <func4+57>
   0x400ff2 <func4+36>:	mov    eax,0x0
   0x400ff7 <func4+41>:	cmp    ecx,edi
   0x400ff9 <func4+43>:	jge    0x401007 <func4+57>
   0x400ffb <func4+45>:	lea    esi,[rcx+0x1]
   0x400ffe <func4+48>:	call   0x400fce <func4>
   0x401003 <func4+53>:	lea    eax,[rax+rax*1+0x1]
   0x401007 <func4+57>:	add    rsp,0x8
   0x40100b <func4+61>:	ret    
```

这里1-9行执行结束后ecx等于7，然后它与edi作比较，如果说ecx小于等于edi就会跳转到0x400ff2，如果说ecx不小于edi就会递归调用func4。

```
   0x400ff7 <func4+41>:	cmp    ecx,edi
   0x400ff9 <func4+43>:	jge    0x401007 <func4+57>
```

这里在比较ecx和edi，这回比较的就是ecx是不是大于等于edi，如果大于等于就会跳转到0x401007跳出这个函数，如果说不大于等于就会继续执行下面的递归调用func4。

所以说为了满足小于等于7和大于等于7，第一个数就必须等于7才可以。然后就跳回主函数

```
   0x401051 <phase_4+69>:	cmp    DWORD PTR [rsp+0xc],0x0
   0x401056 <phase_4+74>:	je     0x40105d <phase_4+81>
```

然后就是比较第二个数是不是等于0，所以说第二个应该是0。所以输入"7 0"即可

## phase_5

```
=> 0x401062 <phase_5>:	push   rbx
   0x401063 <phase_5+1>:	sub    rsp,0x20
   0x401067 <phase_5+5>:	mov    rbx,rdi
   0x40106a <phase_5+8>:	mov    rax,QWORD PTR fs:0x28
   0x401073 <phase_5+17>:	mov    QWORD PTR [rsp+0x18],rax
   0x401078 <phase_5+22>:	xor    eax,eax
   0x40107a <phase_5+24>:	call   0x40131b <string_length>
   0x40107f <phase_5+29>:	cmp    eax,0x6
   0x401082 <phase_5+32>:	je     0x4010d2 <phase_5+112>
   0x401084 <phase_5+34>:	call   0x40143a <explode_bomb>
   0x401089 <phase_5+39>:	jmp    0x4010d2 <phase_5+112>
   0x40108b <phase_5+41>:	movzx  ecx,BYTE PTR [rbx+rax*1]
   0x40108f <phase_5+45>:	mov    BYTE PTR [rsp],cl
   0x401092 <phase_5+48>:	mov    rdx,QWORD PTR [rsp]
   0x401096 <phase_5+52>:	and    edx,0xf
   0x401099 <phase_5+55>:	movzx  edx,BYTE PTR [rdx+0x4024b0]
   0x4010a0 <phase_5+62>:	mov    BYTE PTR [rsp+rax*1+0x10],dl
   0x4010a4 <phase_5+66>:	add    rax,0x1
   0x4010a8 <phase_5+70>:	cmp    rax,0x6
   0x4010ac <phase_5+74>:	jne    0x40108b <phase_5+41>
   0x4010ae <phase_5+76>:	mov    BYTE PTR [rsp+0x16],0x0
   0x4010b3 <phase_5+81>:	mov    esi,0x40245e
   0x4010b8 <phase_5+86>:	lea    rdi,[rsp+0x10]
   0x4010bd <phase_5+91>:	call   0x401338 <strings_not_equal>
   0x4010c2 <phase_5+96>:	test   eax,eax
   0x4010c4 <phase_5+98>:	je     0x4010d9 <phase_5+119>
   0x4010c6 <phase_5+100>:	call   0x40143a <explode_bomb>
   0x4010cb <phase_5+105>:	nop    DWORD PTR [rax+rax*1+0x0]
   0x4010d0 <phase_5+110>:	jmp    0x4010d9 <phase_5+119>
   0x4010d2 <phase_5+112>:	mov    eax,0x0
   0x4010d7 <phase_5+117>:	jmp    0x40108b <phase_5+41>
   0x4010d9 <phase_5+119>:	mov    rax,QWORD PTR [rsp+0x18]
   0x4010de <phase_5+124>:	xor    rax,QWORD PTR fs:0x28
   0x4010e7 <phase_5+133>:	je     0x4010ee <phase_5+140>
   0x4010e9 <phase_5+135>:	call   0x400b30 <__stack_chk_fail@plt>
   0x4010ee <phase_5+140>:	add    rsp,0x20
   0x4010f2 <phase_5+144>:	pop    rbx
   0x4010f3 <phase_5+145>:	ret    
```

这里一共有两个函数string_length和strings_not_equal，先看第一个函数

```
=> 0x40131b <string_length>:	cmp    BYTE PTR [rdi],0x0
   0x40131e <string_length+3>:	je     0x401332 <string_length+23>
   0x401320 <string_length+5>:	mov    rdx,rdi
   0x401323 <string_length+8>:	add    rdx,0x1
   0x401327 <string_length+12>:	mov    eax,edx
   0x401329 <string_length+14>:	sub    eax,edi
   0x40132b <string_length+16>:	cmp    BYTE PTR [rdx],0x0
   0x40132e <string_length+19>:	jne    0x401323 <string_length+8>
   0x401330 <string_length+21>:	repz ret 
   0x401332 <string_length+23>:	mov    eax,0x0
   0x401337 <string_length+28>:	ret
```

和phase_1里面检测长度的代码差不多，最后返回的就是输入的字符串的长度，返回之后会有一个cmp

```
   0x40107f <phase_5+29>:	cmp    eax,0x6
   0x401082 <phase_5+32>:	je     0x4010d2 <phase_5+112>
```

如果输入的长度不为6就会直接退出，所以说应该输入6个字符，过了这个验证应该会跳到0x40108b这里

```
   0x40108b <phase_5+41>:	movzx  ecx,BYTE PTR [rbx+rax*1]
   0x40108f <phase_5+45>:	mov    BYTE PTR [rsp],cl
   0x401092 <phase_5+48>:	mov    rdx,QWORD PTR [rsp]
   0x401096 <phase_5+52>:	and    edx,0xf
   0x401099 <phase_5+55>:	movzx  edx,BYTE PTR [rdx+0x4024b0]
   0x4010a0 <phase_5+62>:	mov    BYTE PTR [rsp+rax*1+0x10],dl
   0x4010a4 <phase_5+66>:	add    rax,0x1
   0x4010a8 <phase_5+70>:	cmp    rax,0x6
   0x4010ac <phase_5+74>:	jne    0x40108b <phase_5+41>
```

这里第1-3行做的是把输入的第一个字符存在rdx这里，然后第4行是只留下最后一位，举个例子就是输入的第一个字符的值为0x43，执行完第4行之后edx的值就是0x3。然后会从[rdx+0x4024b0]取出来一个值赋到[rsp+rax\*1+0x10]这里，[rdx+0x4024b0]这存放着一个固定的字符串"maduiersnfotvbyl"，[rsp+rax\*1+0x10]这里是空的，然后rax会加一，也就指向第二个数了，执行6次，把得到的值都存在[rsp+rax\*1+0x10]这里了。

```
   0x4010ae <phase_5+76>:	mov    BYTE PTR [rsp+0x16],0x0
   0x4010b3 <phase_5+81>:	mov    esi,0x40245e
   0x4010b8 <phase_5+86>:	lea    rdi,[rsp+0x10]
   0x4010bd <phase_5+91>:	call   0x401338 <strings_not_equal>
```

然后就是执行这里，rdi是第一个参数，它保存的其实就是[rsp+rax\*1+0x10]这里的值，esi是第二个参数，所以就需要进入到strings_not_equal看看了

```
 ► 0x4010bd <phase_5+91>     call   strings_not_equal <0x401338>
        rdi: 0x7fffffffe4c0 ◂— 0x666465756564 /* 'deuedf' */
        rsi: 0x40245e ◂— insb   byte ptr [rdi], dx /* 'flyers' */
        rdx: 0x66
        rcx: 0x79
```

其实可以直接看到，我们输入的字符被转换成了'deuedf'，然后其实可以猜测转换后的字符应该是'flyers'，但是还是需要进去看一下

```
=> 0x401338 <strings_not_equal>:	push   r12
   0x40133a <strings_not_equal+2>:	push   rbp
   0x40133b <strings_not_equal+3>:	push   rbx
   0x40133c <strings_not_equal+4>:	mov    rbx,rdi
   0x40133f <strings_not_equal+7>:	mov    rbp,rsi
   0x401342 <strings_not_equal+10>:	call   0x40131b <string_length>
   0x401347 <strings_not_equal+15>:	mov    r12d,eax
   0x40134a <strings_not_equal+18>:	mov    rdi,rbp
   0x40134d <strings_not_equal+21>:	call   0x40131b <string_length>
   0x401352 <strings_not_equal+26>:	mov    edx,0x1
   0x401357 <strings_not_equal+31>:	cmp    r12d,eax
   0x40135a <strings_not_equal+34>:	jne    <strings_not_equal+99>
   0x40135c <strings_not_equal+36>:	movzx  eax,BYTE PTR [rbx]
   0x40135f <strings_not_equal+39>:	test   al,al
   0x401361 <strings_not_equal+41>:	je     0x401388 <strings_not_equal+80>
   0x401363 <strings_not_equal+43>:	cmp    al,BYTE PTR [rbp+0x0]
   0x401366 <strings_not_equal+46>:	je     0x401372 <strings_not_equal+58>
   0x401368 <strings_not_equal+48>:	jmp    0x40138f <strings_not_equal+87>
   0x40136a <strings_not_equal+50>:	cmp    al,BYTE PTR [rbp+0x0]
   0x40136d <strings_not_equal+53>:	nop    DWORD PTR [rax]
   0x401370 <strings_not_equal+56>:	jne    0x401396 <strings_not_equal+94>
   0x401372 <strings_not_equal+58>:	add    rbx,0x1
   0x401376 <strings_not_equal+62>:	add    rbp,0x1
   0x40137a <strings_not_equal+66>:	movzx  eax,BYTE PTR [rbx]
   0x40137d <strings_not_equal+69>:	test   al,al
   0x40137f <strings_not_equal+71>:	jne    0x40136a <strings_not_equal+50>
   0x401381 <strings_not_equal+73>:	mov    edx,0x0
   0x401386 <strings_not_equal+78>:	jmp    0x40139b <strings_not_equal+99>
   0x401388 <strings_not_equal+80>:	mov    edx,0x0
   0x40138d <strings_not_equal+85>:	jmp    0x40139b <strings_not_equal+99>
   0x40138f <strings_not_equal+87>:	mov    edx,0x1
   0x401394 <strings_not_equal+92>:	jmp    0x40139b <strings_not_equal+99>
   0x401396 <strings_not_equal+94>:	mov    edx,0x1
   0x40139b <strings_not_equal+99>:	mov    eax,edx
   0x40139d <strings_not_equal+101>:	pop    rbx
   0x40139e <strings_not_equal+102>:	pop    rbp
   0x40139f <strings_not_equal+103>:	pop    r12
   0x4013a1 <strings_not_equal+105>:	ret
```

可以看到前两个string_length分别是检测转换后的字符和给定的字符的长度，然后比较两个字符长度是不是一样的，不一样就会直接跳出这个函数，一样才会继续执行

```
   0x401363 <strings_not_equal+43>:	cmp    al,BYTE PTR [rbp+0x0]
   0x401366 <strings_not_equal+46>:	je     0x401372 <strings_not_equal+58>
```

这里就是开始检测了，检测转换后的字符和给定的字符是不是一样的，一样则继续，不一样就直接跳出这个函数。所以就直接可以看出来就是在比较转换后的字符和给定的字符，再总结一下上面的逻辑，上面是首先会根据输入的字符的尾数作为下标取对应的字符"maduiersnfotvbyl"，存储起来，然后转换后的字符和给定的字符应该是相同的，所以说我们只需要让转换的字符是'flyers'就可以了，也就是尾数分别应该为，0x9，0xf，0xe，0x5，0x6，0x7。所以找出对应的尾数是这些的字符就可以了。

可以是"9ONEFG"

## phase_6

```
=> 0x4010f4 <phase_6>:	    push   r14
   0x4010f6 <phase_6+2>:	push   r13
   0x4010f8 <phase_6+4>:	push   r12
   0x4010fa <phase_6+6>:	push   rbp
   0x4010fb <phase_6+7>:	push   rbx
   0x4010fc <phase_6+8>:	sub    rsp,0x50
   0x401100 <phase_6+12>:	mov    r13,rsp
   0x401103 <phase_6+15>:	mov    rsi,rsp
   0x401106 <phase_6+18>:	call   0x40145c <read_six_numbers>
   0x40110b <phase_6+23>:	mov    r14,rsp
   0x40110e <phase_6+26>:	mov    r12d,0x0
   0x401114 <phase_6+32>:	mov    rbp,r13
   0x401117 <phase_6+35>:	mov    eax,DWORD PTR [r13+0x0]
   0x40111b <phase_6+39>:	sub    eax,0x1
   0x40111e <phase_6+42>:	cmp    eax,0x5
   0x401121 <phase_6+45>:	jbe    0x401128 <phase_6+52>
   0x401123 <phase_6+47>:	call   0x40143a <explode_bomb>
   0x401128 <phase_6+52>:	add    r12d,0x1
   0x40112c <phase_6+56>:	cmp    r12d,0x6
   0x401130 <phase_6+60>:	je     0x401153 <phase_6+95>
   0x401132 <phase_6+62>:	mov    ebx,r12d
   0x401135 <phase_6+65>:	movsxd rax,ebx
   0x401138 <phase_6+68>:	mov    eax,DWORD PTR [rsp+rax*4]
   0x40113b <phase_6+71>:	cmp    DWORD PTR [rbp+0x0],eax
   0x40113e <phase_6+74>:	jne    0x401145 <phase_6+81>
   0x401140 <phase_6+76>:	call   0x40143a <explode_bomb>
   0x401145 <phase_6+81>:	add    ebx,0x1
   0x401148 <phase_6+84>:	cmp    ebx,0x5
   0x40114b <phase_6+87>:	jle    0x401135 <phase_6+65>
   0x40114d <phase_6+89>:	add    r13,0x4
   0x401151 <phase_6+93>:	jmp    0x401114 <phase_6+32>
   0x401153 <phase_6+95>:	lea    rsi,[rsp+0x18]
   0x401158 <phase_6+100>:	mov    rax,r14
   0x40115b <phase_6+103>:	mov    ecx,0x7
   0x401160 <phase_6+108>:	mov    edx,ecx
   0x401162 <phase_6+110>:	sub    edx,DWORD PTR [rax]
   0x401164 <phase_6+112>:	mov    DWORD PTR [rax],edx
   0x401166 <phase_6+114>:	add    rax,0x4
   0x40116a <phase_6+118>:	cmp    rax,rsi
   0x40116d <phase_6+121>:	jne    0x401160 <phase_6+108>
   0x40116f <phase_6+123>:	mov    esi,0x0
   0x401174 <phase_6+128>:	jmp    0x401197 <phase_6+163>
   0x401176 <phase_6+130>:	mov    rdx,QWORD PTR [rdx+0x8]
   0x40117a <phase_6+134>:	add    eax,0x1
   0x40117d <phase_6+137>:	cmp    eax,ecx
   0x40117f <phase_6+139>:	jne    0x401176 <phase_6+130>
   0x401181 <phase_6+141>:	jmp    0x401188 <phase_6+148>
   0x401183 <phase_6+143>:	mov    edx,0x6032d0
   0x401188 <phase_6+148>:	mov    QWORD PTR [rsp+rsi*2+0x20],rdx
   0x40118d <phase_6+153>:	add    rsi,0x4
   0x401191 <phase_6+157>:	cmp    rsi,0x18
   0x401195 <phase_6+161>:	je     0x4011ab <phase_6+183>
   0x401197 <phase_6+163>:	mov    ecx,DWORD PTR [rsp+rsi*1]
   0x40119a <phase_6+166>:	cmp    ecx,0x1
   0x40119d <phase_6+169>:	jle    0x401183 <phase_6+143>
   0x40119f <phase_6+171>:	mov    eax,0x1
   0x4011a4 <phase_6+176>:	mov    edx,0x6032d0
   0x4011a9 <phase_6+181>:	jmp    0x401176 <phase_6+130>
   0x4011ab <phase_6+183>:	mov    rbx,QWORD PTR [rsp+0x20]
   0x4011b0 <phase_6+188>:	lea    rax,[rsp+0x28]
   0x4011b5 <phase_6+193>:	lea    rsi,[rsp+0x50]
   0x4011ba <phase_6+198>:	mov    rcx,rbx
   0x4011bd <phase_6+201>:	mov    rdx,QWORD PTR [rax]
   0x4011c0 <phase_6+204>:	mov    QWORD PTR [rcx+0x8],rdx
   0x4011c4 <phase_6+208>:	add    rax,0x8
   0x4011c8 <phase_6+212>:	cmp    rax,rsi
   0x4011cb <phase_6+215>:	je     0x4011d2 <phase_6+222>
   0x4011cd <phase_6+217>:	mov    rcx,rdx
   0x4011d0 <phase_6+220>:	jmp    0x4011bd <phase_6+201>
   0x4011d2 <phase_6+222>:	mov    QWORD PTR [rdx+0x8],0x0
   0x4011da <phase_6+230>:	mov    ebp,0x5
   0x4011df <phase_6+235>:	mov    rax,QWORD PTR [rbx+0x8]
   0x4011e3 <phase_6+239>:	mov    eax,DWORD PTR [rax]
   0x4011e5 <phase_6+241>:	cmp    DWORD PTR [rbx],eax
   0x4011e7 <phase_6+243>:	jge    0x4011ee <phase_6+250>
   0x4011e9 <phase_6+245>:	call   0x40143a <explode_bomb>
   0x4011ee <phase_6+250>:	mov    rbx,QWORD PTR [rbx+0x8]
   0x4011f2 <phase_6+254>:	sub    ebp,0x1
   0x4011f5 <phase_6+257>:	jne    0x4011df <phase_6+235>
   0x4011f7 <phase_6+259>:	add    rsp,0x50
   0x4011fb <phase_6+263>:	pop    rbx
   0x4011fc <phase_6+264>:	pop    rbp
   0x4011fd <phase_6+265>:	pop    r12
   0x4011ff <phase_6+267>:	pop    r13
   0x401201 <phase_6+269>:	pop    r14
   0x401203 <phase_6+271>:	ret  
```

这个代码是最长的，首先调用了一次read_six_numbers这个和之前的read_six_numbers一样，接受6个数字，然后就有一个检测

```
   0x40110b <phase_6+23>:	mov    r14,rsp
   0x40110e <phase_6+26>:	mov    r12d,0x0
   0x401114 <phase_6+32>:	mov    rbp,r13
   0x401117 <phase_6+35>:	mov    eax,DWORD PTR [r13+0x0]
   0x40111b <phase_6+39>:	sub    eax,0x1
   0x40111e <phase_6+42>:	cmp    eax,0x5
   0x401121 <phase_6+45>:	jbe    0x401128 <phase_6+52>
```

这个是检测输入的数减一是不是小于等于5的，如果不是就退出。过了这个检测之后，会执行

```
   0x40114d <phase_6+89>:	add    r13,0x4
   0x401151 <phase_6+93>:	jmp    0x401114 <phase_6+32>
```

然后r13就指向的就是第二个数字，然后跳转到0x401114这里

```
   0x401114 <phase_6+32>:	mov    rbp,r13
   0x401117 <phase_6+35>:	mov    eax,DWORD PTR [r13+0x0]
   0x40111b <phase_6+39>:	sub    eax,0x1
   0x40111e <phase_6+42>:	cmp    eax,0x5
   0x401121 <phase_6+45>:	jbe    0x401128 <phase_6+52>
```

和上面的操作一样也是判断是不是减一小于等于5，只不过上面是从第一个数开始判断，这个是从第二个数开始判断，然后又执行add    r13,0x4跳到另一个地方执行相同的操作，一直执行到最后一个数结束，搞不懂套娃干嘛。结束了这些判断之后就进入到0x401153这块

```
   0x401153 <phase_6+95>:	lea    rsi,[rsp+0x18]
   0x401158 <phase_6+100>:	mov    rax,r14
   0x40115b <phase_6+103>:	mov    ecx,0x7
   0x401160 <phase_6+108>:	mov    edx,ecx
   0x401162 <phase_6+110>:	sub    edx,DWORD PTR [rax]
   0x401164 <phase_6+112>:	mov    DWORD PTR [rax],edx
   0x401166 <phase_6+114>:	add    rax,0x4
   0x40116a <phase_6+118>:	cmp    rax,rsi
   0x40116d <phase_6+121>:	jne    0x401160 <phase_6+108>
```

这里会把用7减去每个数然后替换这个数，举个例子就是输入的是"1 2 3 4 5 6"，经过这些运算之后，就应该是"6 5 4 3 2 1",然后执行0x40116f

```
   0x40116f <phase_6+123>:	mov    esi,0x0
   0x401174 <phase_6+128>:	jmp    0x401197 <phase_6+163>
```

也是给esi赋0然后就跳转到0x401197了

```
   0x401197 <phase_6+163>:	mov    ecx,DWORD PTR [rsp+rsi*1]
   0x40119a <phase_6+166>:	cmp    ecx,0x1
   0x40119d <phase_6+169>:	jle    0x401183 <phase_6+143>
```

我第一次输入的不满足这个条件就向下执行了

```
   0x40119f <phase_6+171>:	mov    eax,0x1
   0x4011a4 <phase_6+176>:	mov    edx,0x6032d0
   0x4011a9 <phase_6+181>:	jmp    0x401176 <phase_6+130>
```

然后给eax，edx分别赋值，然后跳转到0x401176这里，这里是把第一个数赋给rdx然后eax加一，比较eax和ecx的值，此时ecx的值为3

```
   0x401176 <phase_6+130>:	mov    rdx,QWORD PTR [rdx+0x8]
   0x40117a <phase_6+134>:	add    eax,0x1
   0x40117d <phase_6+137>:	cmp    eax,ecx
   0x40117f <phase_6+139>:	jne    0x401176 <phase_6+130>
```

不等于ecx，这里ecx的值是你输入的第二个数的值，然后就继续循环，直到eax等于ecx，然后此时可以看到，rdx的值等与一个`0x6032f0 (node3) ◂— 0x30000039c`然后就会执行下面的代码，把rdx赋到栈上去，再继续执行循环，这个循环指的是这个大循环

```
   0x401188 <phase_6+148>:	mov    QWORD PTR [rsp+rsi*2+0x20],rdx
   0x40118d <phase_6+153>:	add    rsi,0x4
   0x401191 <phase_6+157>:	cmp    rsi,0x18
   0x401195 <phase_6+161>:	je     0x4011ab <phase_6+183>
```

然后栈上的内容就是这里举个例子，比如你输入的是1 2 3 4 5 6，此时栈上的内容就是

```
node6	0x6000001bb
node5	0x5000001dd
node4	0x4000002b3
node3	0x30000039c
node2	0x2000000a8
node1	0x10000014c
```

然后就跳到0x4011ab了

```
   0x4011ab <phase_6+183>:	mov    rbx,QWORD PTR [rsp+0x20]
   0x4011b0 <phase_6+188>:	lea    rax,[rsp+0x28]
   0x4011b5 <phase_6+193>:	lea    rsi,[rsp+0x50]
   0x4011ba <phase_6+198>:	mov    rcx,rbx
   0x4011bd <phase_6+201>:	mov    rdx,QWORD PTR [rax]
   0x4011c0 <phase_6+204>:	mov    QWORD PTR [rcx+0x8],rdx
   0x4011c4 <phase_6+208>:	add    rax,0x8
   0x4011c8 <phase_6+212>:	cmp    rax,rsi
   0x4011cb <phase_6+215>:	je     0x4011d2 <phase_6+222>
```

这里对每个栈上的每个值进行了操作，然后跳转到0x4011d2

```
   0x4011d2 <phase_6+222>:	mov    QWORD PTR [rdx+0x8],0x0
   0x4011da <phase_6+230>:	mov    ebp,0x5
   0x4011df <phase_6+235>:	mov    rax,QWORD PTR [rbx+0x8]
   0x4011e3 <phase_6+239>:	mov    eax,DWORD PTR [rax]
   0x4011e5 <phase_6+241>:	cmp    DWORD PTR [rbx],eax
   0x4011e7 <phase_6+243>:	jge    0x4011ee <phase_6+250>
```

这里就开始判断，栈上的内容了，简单而言就是栈上的node后面的数字，应该是从大到小排列的，不满足这个就会退出，所以说我们只需找出从大到小的顺序对应的数字然后用7减掉这个数字就是我们应该输入的数字。顺序如下

```
node3	0x30000039c
node4	0x4000002b3
node5	0x5000001dd
node6	0x6000001bb
node1	0x10000014c
node2	0x2000000a8
```

所以说对应的输入顺序就应该是4 3 2 1 6 5。

## 懒人脚本

```
# -*- coding: utf-8 -*-
# @Author: resery
# @Date:   2020-07-22 15:49:06
# @Last Modified by:   resery
# @Last Modified time: 2020-07-22 19:20:15
from pwn import *
from LibcSearcher import LibcSearcher

#context.log_level="debug"

if sys.argv[1]=="debug":
	sh = process("./bomb")
elif sys.argv[1]=="remote":
	sh = remote("node3.buuoj.cn",)

elf = ELF("./bomb")

ru = lambda x:sh.recvuntil(x)
rv = lambda x:sh.recv(x)
ra = lambda x:sh.recvall(x)
sl = lambda x:sh.sendline(x)
sd = lambda x:sh.send(x) 
sla = lambda x,y:sh.sendlineafter(x,y)
lg = lambda x:log.success(x)

def dbg():
	gdb.attach(sh)

sh.recv();
sl("Border relations with Canada have never been better.")
sh.recv()
sl("1 2 4 8 16 32")
sh.recv()
sl("1 311")
sh.recv()
sl("7 0")
sh.recv()
sl("9ONEFG")
sh.recv()
sl("4 3 2 1 6 5")

sh.interactive()
```

## 结果

输入结果：

```
Welcome to my fiendish little bomb. You have 6 phases with
which to blow yourself up. Have a nice day!
Border relations with Canada have never been better.
Phase 1 defused. How about the next one?
1 2 4 8 16 32
That's number 2.  Keep going!
1 311
Halfway there!
7 0
So you got that one.  Try this one.
9ONEFG
Good work!  On to the next...
4 3 2 1 6 5
Congratulations! You've defused the bomb!
```

脚本结果：

```
$ python exp.py debug
[+] Starting local process './bomb': pid 5247
[*] '/home/resery/CSAPP/bomb/bomb'
    Arch:     amd64-64-little
    RELRO:    Partial RELRO
    Stack:    Canary found
    NX:       NX enabled
    PIE:      No PIE (0x400000)
    FORTIFY:  Enabled
[*] Switching to interactive mode
[*] Process './bomb' stopped with exit code 0 (pid 5247)
Congratulations! You've defused the bomb!
```

