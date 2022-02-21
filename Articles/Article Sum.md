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

这篇文章讲述了作者利用 codeql 挖掘漏洞的经历，可以根据他文中的内容学习如何写 ql 。

## 待看文章

一个和污点分析有关的论文：chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Fhomepages.dcc.ufmg.br%2F~fernando%2Fpublications%2Fpapers%2FCC11rimsa.pdf

Xen Fuzzing：chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Fsilentsignal.hu%2Fdocs%2FOffensiveCon22-Case_Studies_of_Fuzzing_with_Xen.pdf

BlackHat Europe Re-route Your Intent for Privilege Escalation：A Universal Way to Exploit Android PendingIntents in High-profile and System Apps：https://www.blackhat.com/eu-21/briefings/schedule/#re-route-your-intent-for-privilege-escalation-a-universal-way-to-exploit-android-pendingintents-in-high-profile-and-system-apps-24340

BlackHat Europe The Bad Guys Win – Analysis of 10,000 Magecart Vulnerabilities：https://www.blackhat.com/eu-21/briefings/schedule/#the-bad-guys-win--analysis-of--magecart-vulnerabilities-24806

BlackHat Europe The Art of Exploiting UAF by Ret2bpf in Android Kernel：chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Fi.blackhat.com%2FEU-21%2FWednesday%2FEU-21-Jin-The-Art-of-Exploiting-UAF-by-Ret2bpf-in-Android-Kernel.pdf

exploiting CVE-2019-2215：https://cutesmilee.github.io/kernel/linux/android/2022/02/17/cve-2019-2215_writeup.html

A Deep Dive into Privacy Dashboard of Top Android Vendors (总结了类似于照明弹等产品的实现方法):chrome-extension://cdonnmffkdaoajfknoeeecmchibpmkmg/assets/pdf/web/viewer.html?file=https%3A%2F%2Fi.blackhat.com%2FEU-21%2FThursday%2FEU-21-Bin-A-Deep-Dive-into-Privacy-Dashboard-of-Top-Android-Vendors.pdf 
