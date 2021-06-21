# Learning Note And Diary

## 内容简介

已经很久都没有更新过这个仓库了，由于中间经历过一些事情变的懒惰了，之后会继续更新这个仓库，会添加一些自己学习的笔记以及每日的简短日记，跟随 Kiprey 的脚步，向 Kiprey 学习，近期应该不会更新与虚拟化和二进制安全方面的内容，更新也可能会跟新很少一部分的内容（可能就是没有），近期主要在做网络编程和 Fuzz 方面的研究也就是写代码，这两部分完成后，可能会再重新写一个 TinyStl，再之后会再开始逐渐的更新与安全有关的内容

## 主要内容

- C/C++ Basis &#8195;[STL CObject](C++/)
- Kernel Basis &#8195;[CSAPP Ucore Makefile](Kernel/)
- Vulnerability &#8195;[DirtyCow IOV CVE-2015-5165 CVE-2015-7504](Vulnerability/)
- CTFs &#8195;&#8195;&#8195;&#8195; [Blizzard Google Confidence Plaid HITB GACTF Qwb(2019) N1CTF](CTFs/)
- Linux and Unix [Unix](Unix/)
- QEMU &#8195;&#8195;&#8195;&#8195;[QEMU](QEMU/)
- LeetCode &#8195; &#8195; [50+](LeetCode)
- Pwnable &#8195;&#8195;&#8195;[start orw calc](Pwnable/)
- Pattern &#8195; &#8195;&#8195; [漏洞模式](Pattern/)
- Homework &#8195;&#8195;[Rdb Relf](Homework/)
- Codeql &#8195; &#8195; &#8195;[Useful CodeQL Queries](Codeql/)

## Dirary

<details>
<summary>第一周  ( 2021.05.31 - 2020.06.06 )  :  WebServer</summary>

- 2021.05.31：

  - [x] select, poll, epoll 三种 IO 多路复用模型的学习
  - [ ] 多线程编程相关知识的学习
  - [ ] Rust 相关内容的学习

- 2021.06.01：

  - [x] select, poll, epoll 三种 IO 多路复用模型的学习

- 2021.06.02：

  - [x] select, poll, epoll 三种 IO 多路复用模型的学习

- 2021.06.03：

  - [x] 更新 WebServer 代码使其支持并发

- 2021.06.04：

  - [x] 重构 WebServer HTTPHandler 部分的代码，覆盖原本的代码，更新状态机模式
  - [x] 编写状态机部分的文档
- 2021.06.05：

  - [x] 由于更新完状态机的部分后出现了一些 bug，所以一直在修 bug，主要 bug 就使用 chrome 浏览器时请求 home.html 页面时本应发起两次请求，第一次请求静态页面，第二次请求页面中的图片，但是实际调试时发现 WebServer 无法获取到第二次请求图片的请求，后面在每次请求之后关闭了对应的文件描述符后可以接受到正常的请求，但是偶尔也会出现请求失败的情况，后面调试过程中发现 chrome 浏览器会发起三次http请求，其中有一次不知是做什么的，而且发送来的内容都是乱码，所以改用了 safari 浏览器就变得正常了，具体是因为什么需要后面再排查
- 2021.06.06：

  - [x] 主要看了一下线程池是如何实现的，然后在理解的同时，也尝试的去写了一个线程池，在写的过程中遇到了诸多 bug，调试花费了很长的时间
</details>

<details>
<summary>第二周  ( 2021.06.07 - 2020.06.13 )  :  WebServer</summary>

- 2021.06.07:

  - [x] 完成 WebServer 线程池部分，并更新了线程池部分的技术文档，后面会再加上计时器和 epoll IO 多路复用来提升性能，争取周三之前结束 WebServer 之后也不会有太大的改动，再改动也就是会更新一些功能，WebServer 结束之后打算重新搞一遍 STL，搞完 STL 之后准备花一周的时间弄一个 patchelf 的轮子出来，加深一下 elf 文件格式以及编译连接的一些理解，再之后看看有无时间搞一搞跟逆向相关的 idapython 和 fuzz，并且预计在冬天时搞一下编译器相关的内容

- 2021.06.08:

  - [x] 将 client 也采取 epoll 

- 2021.06.09:

  - [x] 修 bug 但是修的时候出了好多问题，所以放弃了 client 的 epoll 机制

- 2021.06.10 - 2021.06.13:

  - [x] 端午放假休息

</details>

<details>
<summary>第三周  ( 2021.06.14 - 2021.06.20 )  :  C++</summary>

- 2021.06.14 - 2021.06.20:

  - [x] 这一周主要是重新读了一遍 C++ prime 目前读到第 16 章，对应模版章节，看了一小部分的 Rust 主要是阅读 Rust 的文档，查找一些有用的库函数，目的是为了用 Rust 实现一个简易的 container 来作为出题的题目，看了一点设计模式，之后准备在看完 C++ prime 和 设计模式之后重新写一个工具，工具准备整合 ReadElf 、 checksec 以及一些其他的小工具的功能，预计采用 Rust 和 C++ 实现

  - [x] 看了一下工厂设计模式，但是没有太搞懂工厂设计模式具体的应用场景，以及为什么会有对应的优点以及缺点，理解的不是很好
</details>

<details>
<summary>第四周 ( 2021.06.21 - 2021.06.27 ) : C++ 与 设计模式</summary>

- 2021.06.21:

  - [x] C++ 模版类型转换部分的内容，记录了相应的笔记
  - [x] 与一个工作了的人探讨设计模式在真实的开发场景当中应用是否广泛，以及学习设计模式具体应该学习哪些东西，总结起来就是重点是思想而不是那个固定的模子

- 2021.06.22:

  - [x]

</details>