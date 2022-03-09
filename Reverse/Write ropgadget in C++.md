# Write ropgadget in C++ and Rust

## 前言

由于最近在学习污点分析相关的知识，就买了一本与污点分析有关的书，拿到书之后发现书中还包含反汇编部分的内容，书中主要解释了反汇编的原理以及如何利用 capstone 去写一个 ropgadget 。所以此篇文章用来记录反汇编相关的知识，以及如何写一个 ropgadget 。由于最近也在学 rust 所以之后可能还会添加用 rust 实现的 ropgadget 。

## Loder

在进行反汇编之前我们需要写一个自己的 Binary Loader ，写 Loader 的目的主要是为了使二进制分析工具加载二进制代码的过程尽可能简单。Loader 包装了 libbfd(用于读取和解析二进制文件的库) 中的基础实现，将 libbfd 提供的部分接口整合为一个新功能方便调用。

代码部分并不是很复杂，创建了三个类，分别代表 binary 、 binary 中的所有 sections 和 binary 中的所有 symbol 信息。声明了两个函数分别用于加载和卸载 binary 。

loader.c 中大部分内容都是在调用 libbfd 提供的接口，然后将获取到的信息存到 binary 对象中。不过笔者并没有深究 libbfd 的实现原理，如果之后时间充裕会补上。

这样就借用 libbfd 实现了一个最简单的 Binary Loader 。代码路径为 loader.h 和 loader.cc 。

## Disassembler

## Ropgadget

## 总结

## 参考资料

<< Practical Binary Anaysis>>