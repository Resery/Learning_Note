# 《qemu/kvm 源码解析与应用》阅读建议

## 第一章

建议先做一下confidence ctf 2020 kvm 或者 阅读一遍这篇文章https://lwn.net/Articles/658511/  然后再开始阅读第一章

## 第二章

### 2.1.1小节：

建议先阅读一下I/O的五种模型（[参考链接](https://juejin.im/post/6844903782094995470)）、Glib事件循环机制（这篇文章的前半部分涉及了glib事件循环机制并且有一个demo可以方便理解Glib事件循环机制:[参考链接](https://blog.csdn.net/huang987246510/article/details/90738137)）、也可以再去了解一下libc、glibc、glib的区别

### 2.1.2小节：

最后有一部分涉及到了vnc_listen_io下断点，使用的命令应该是gdb --args qemu-system-x86_64 -m 1024 -smp 4 -hda centos.img --enable-kvm -vnc :0进入到gdb中之后在vnc_listen_io下断点，之后直接run，run完之后需要使用vnc的客户端去连接虚拟机，vnc客户端下载地址：https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.529-Linux-x64.deb，然后直接连接本地gdb中就会断下来了

### 2.1.3小节：

这一小节没什么需要注意的了，唯一需要注意的就是看源码的时候可能一个函数同时在好几个文件里，但是我们应该注重看结尾是posix的文件，以win32结尾的文件是对应windows下使用的

### 2.1.4小节：

这里不建议直接看源码，最好动调跟着调试，并且观察运行的时候的各个结构体中的值，加深对这些结构体的印象

### 2.1.5小节：

不同人的机器使用不同的参数会产生相应的偏差，并且在调查各个fd的源头的时候最好是先在main-loop.c下断点，然后观察gpollfds数组，然后看对应有哪些fd，观察结束之后需要在g_source_add_poll处下断点重新运行，然后才可以看到这些fd是经过哪些函数调用得到的，前面步结束之后没法看到glib库自己创建的fd的生成过程，这里需要在eventfd下断点然后重新运行，断点断下之后需要使用finsh命令完成当前函数的执行，然后查看rax寄存器的值，当rax的值为对用的fd的时候，堆栈溯源，可以看到这个fd是由glib库自己创建使用的

### 注

**------------------------------------------------------------------------------------------------------------------------------**

**书中使用了glib库，相关函数功能可以在这个网站上查到：**[**https://developer.gnome.org/search?q=gst_structure_foreach**](https://developer.gnome.org/search?q=gst_structure_foreach)**安装glib环境的时候建议直接使用python的pip安装(python版本在3.6以上)，命令如下：**

```
git clone https://gitlab.gnome.org/GNOME/glib
python3 -m pip install meson
python3 -m pip install ninja
进入到glib目录下
meson _build
ninja -C _build
ninja -C _build install
glib包含下面这些库
glib.h, glib-object.h, gio.h，gmodule.h, glib-unix.h, glib/gi18n-lib.h or glib/gi18n.h, glib/gprintf.h and glib/gstdio.h
编译命令
gcc main.c `pkg-config --cflags glib-2.0 --libs glib-2.0
```

**------------------------------------------------------------------------------------------------------------------------------**