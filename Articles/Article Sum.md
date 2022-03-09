# Article Summary

## Finding a Kernel 0-day in VMware vCenter Converter via Static Reverse Engineering

链接：https://www.signal-labs.com/blog/vmware-driver-0day-reversing

此文主要内容和逆向有关，但是通过逆向逆出来的洞漏洞模式很简单，感觉此类的洞可以写一个 codeql 扫出来。漏洞模式：数据用户可控，数据后面会作为除数，在作为除数时用户控制其值为 0 导致拒绝服务，这类的洞可以通过污点分析来挖掘，首先判断值是否为用户可控，如果可控则找是否有作为除数的 Sink 即可。

## Parallels Desktop 虚拟机逃逸

链接：https://dawnslab.jd.com/pd-exploit-blog1/#more

这篇文章好处在于不仅分享了技术还分享了挖掘漏洞的经历以及心路历程，总结下来就是模式简单的洞现在很难挖到，但是 toctou 类型的洞很容易产生，通过这篇文章也学习到了 toctou 这种漏洞类型，以及怎么挖掘这类漏洞，这类漏洞的利用方法还需要进一步的探索。

## MINDSHARE: WHEN MYSQL CLUSTER ENCOUNTERS TAINT ANALYSIS (利用 clang 和 codeql 进行污点追踪)

链接：https://www.zerodayinitiative.com/blog/2022/2/10/mindshare-when-mysql-cluster-encounters-taint-analysis

此文主要讲述如何利用 clang 和 codeql 进行污点分析以挖掘使用可控数据作为索引或者 memcpy 参数类型的洞，这种类型的漏洞想要通过审计直接审计出来很困难，不过利用污点追踪之后就可以很轻松的来扫描出来。

可以利用 clang 进行污点追踪，相比与 codeql ，使用 clang 进行污点追踪很方便，只需要在将 Source 替换为 clang 的一个变量，然后在 clang 的配置文件中配置 Sink 即可。

利用 codeql 污点追踪就没有 clang 那么轻松，不过 codeql 相比于 clang 既有优点也有缺点，有点就是在 ql 写的足够好的时候能查出很全的结果，但是如果 ql 写的差那得到的结果就很差，所以 codeql 能得到什么结果取决与 ql 。ql 的编写也有一定的难度，需要多看一些别人写的 ql 总结一下经验最后在自己上手写，同样的漏洞看自己能否写出 ql 查到这个漏洞。

## 漏洞复现 -- 条件竞争 -- TOCTOU

链接：https://www.cnblogs.com/crybaby/p/13195054.html

这篇文章讲述了如何利用 TOCTOU 漏洞，对 TOCTOU 漏洞有了一个基础的认识，之后需要再看几篇和 TOCTOU 有关的文章，然后尝试挖掘这种类型的漏洞。

TOCTOU 漏洞，全称为 Time of check Time of use 意思就是在检测和使用之间有一个时间差，利用这个时间差把检测成功后的内容给替换掉，这样检测就相当与不复存在。

## runC TOCTOU

链接：https://www.anquanke.com/post/id/250747#h2-10

这篇文章介绍了 runC 中的一个 TOCTOU 漏洞的利用方法。

## Binary ninja 污点分析

链接：https://www.zerodayinitiative.com/blog/2022/2/14/static-taint-analysis-using-binary-ninja-a-case-study-of-mysql-cluster-vulnerabilities

这篇文章有很多跟编译原理有关的内容，主要是使用 SSA 来进行污点分析，相比于 clang 和 codeql 其分析难度会更大。

## Use codeql to dig apple's bug

链接：https://securitylab.github.com/research/apple-xnu-dtrace-CVE-2017-13782/

这篇文章讲述了作者利用 codeql 挖掘漏洞的经历，可以从他的思路中学习如何写 ql ，并且根据项目的不同需要针对性的写 ql 。

## Breaking Down Binary Ninja’s Low Level IL

链接：https://blog.trailofbits.com/2017/01/31/breaking-down-binary-ninjas-low-level-il/

这篇文章主要介绍了 Binary ninja 中的 LLIL ，以及如何利用 Binary ninja 中的 api 来获取函数，指令以及基本块等内容。

## Vulnerability Modeling with Binary Ninja
链接：https://blog.trailofbits.com/2018/04/04/vulnerability-modeling-with-binary-ninja/
这篇文章利用 Binary ninja 进行污点追踪，文中使用 Openssl 的心脏滴血漏洞作为示例，最后通过污点追踪成功的确定漏洞处的 size 是否为用户可控的。

## Rooting 三星 Q60T 智能电视

链接：https://sec.today/pulses/ded07c3d-6209-4e1a-967c-9fa2fcacf999/

这篇文章讲述了作者在 2021 Pwn2own 比赛上 root 三星电视的利用过程，主要就是通过浏览器的历史漏洞拿到一定的权限，再通过 Linux Kernel 的历史漏洞提升至 root 权限，提升至 root 权限之后再通过与 TrustZone 进行交互解密被加密的固件。

## exploting CVE-2019-2215

链接：https://cutesmilee.github.io/kernel/linux/android/2022/02/17/cve-2019-2215_writeup.html

漏洞复现文章，主要看了一下漏洞模式，利用部分没有细看。

## A Deep Dive into Privacy Dashboard of Top Android Vendors

链接：https%3A%2F%2Fi.blackhat.com%2FEU-21%2FThursday%2FEU-21-Bin-A-Deep-Dive-into-Privacy-Dashboard-of-Top-Android-Vendors.pdf 

字节 2021 年投的 Blackhat 议题，主要介绍了 Google 是如何实现类似与小米隐私照明弹同样功能的细节。

## CLANG CHECKERS AND CODEQL QUERIES FOR DETECTING UNTRUSTED POINTER DEREFS AND TAINTED LOOP CONDITIONS

链接：https://www.zerodayinitiative.com/blog/2022/2/22/clang-checkers-and-codeql-queries-for-detecting-untrusted-pointer-derefs-and-tainted-loop-conditions

继上篇使用 clang 和 codeql 进行污点追踪的续作，针对 clang 和 codeql 分别使用了与先前文章中所描述的方法截然不同的方法，针对 clang 添加了一个 checker 利用 checker 可以检测内存读写，针对 codeql 使用了 codeql 的 ir ，通过分析 codeql 的 ir 来确定 source 和 sink 。

文章主要检测两类漏洞，一类为针对不可信数据解引用，一类为没有检测循环条件。

针对 clang 和 codeql 应该还会有更多可以用来污点分析的方法，之后有时间准备研究研究。

## BrokenPrint: A Netgear stack overflow

链接：https://research.nccgroup.com/2022/02/28/brokenprint-a-netgear-stack-overflow/

iot 漏洞，漏洞不是很难，很好审计出来，攻击面可用作参考，挖掘这类漏洞要么对功能熟悉要么用一些其他方法来确定参数是否可控，如果针对一些复杂数据处理库来说如果之前没有做过相关工作则挖掘这类漏洞还是比较困难。

## CVE-2021-26709 Exploit

链接：https://a13xp0p0v.github.io/2021/02/09/CVE-2021-26708.html

简单的看了一下，利用有些复杂了，利用条件竞争弄了一个 uaf ，利用 uaf 将内核中其他模块分配到可控的位置，修改模块中的指针再调用使用该模块的函数，可以达到 arb read。

具体的利用细节，还需要再看，不过很可能鸽了，不过掌握了一个新的漏洞模式。

## CVE-2022-0185: A Case Study

链接：https://www.hackthebox.com/blog/CVE-2022-0185:_A_case_study

漏洞是用 syzkaller 挖到的，漏洞原理不是很难，利用无符号溢出绕过 check ，然后利用溢出的值可以 oobw ，主要是用到了几个特殊的技术来完成最后的利用，准备复现一下这个漏洞添加到日程中。

## Hacking LG webOS TV

链接：https://blog.recurity-labs.com/2022-03-02/webOS_Pt2.html

Web 漏洞，代码中验证组件是否有特殊权限的部分仅是检测首个字符串是否为指定的字符串。我们可以通过嵌套调用绕过，来执行高权限命令。

## 待看文章

游戏开发中 Rust 代码的设计模式：https://kyren.github.io/2018/09/14/rustconf-talk.html

利用 Partially Recompilable Decompilation 技术重写 x86 二进制程序实现无源码程序的漏洞 Mitigation：chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Farxiv.org%2Fpdf%2F2202.12336.pdf

CVE-2021-26708 (Linux kernel) with sshd （一个 cve 的另一种利用方法）：https://hardenedvault.net/2022/03/01/poc-cve-2021-26708.html

Bluehat intel mte 技术议题：https://sec.today/pulses/ed078ddd-c513-4c8e-8870-dc209d3d9d43/

内核中内存洞的一个利用技巧，利用 msg 结构可以使原本无法利用的 uaf 以及 内存洞达到提权的效果：https://www.willsroot.io/2021/08/corctf-2021-fire-of-salvation-writeup.html

Vulnerability hunting with Semmle QL, part 1：https://msrc-blog.microsoft.com/2018/08/16/vulnerability-hunting-with-semmle-ql-part-1/

Vulnerability hunting with Semmle QL, part 2：https://msrc-blog.microsoft.com/2019/03/19/vulnerability-hunting-with-semmle-ql-part-2/

An Analysis of Speculative Type Confusion Vulnerabilities in the Wild(讲类型冲突漏洞的一篇文章)：https%3A%2F%2Fwww.usenix.org%2Fsystem%2Ffiles%2Fsec21-kirzner.pdf