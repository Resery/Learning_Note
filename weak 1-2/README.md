[作业] (homework.md)
# 概述

## 六大组件：

容器(containers)：各种数据结构，vector，list，deque，set，map，用来存放数据

算法(algorithms)：常用的算法如sort，search，copy，erase......

迭代器(iterators)：一套访问容器的接口，行为类似于指针（泛型指针）。它为不同算法提供的相对统一的容器访问方式，使得设计算法时无需关注过多关注数据。（“算法”指广义的算法，操作数据的逻辑代码都可认为是算法）

仿函数(functors)：行为类似函数，可以作为算法的某种策略

配接器(adapters)：用来修饰仿函数，容器或迭代器接口

配置器(allocators)：负责空间管理

## 配置器

配置器定义在\<memory\>中，\<memory\>中包含<stl_construct.h>和<stl_alloc.h>。

其中<stl_construct.h>负责对象的构造与析构，<stl_alloc.h>负责空间的释放与分配。

<stl_construct.h>中定义了两个基本函数：一个是负责构造的construct()，另一个是负责析构的destroy()。


![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-05_23-34-35.png)

### stl_construct.h

<stl_construct.h>代码：

```
#pragma once
#include <new.h>
#include "type_traits.h"
#include "stl_iterator.h"

__STL_BEGIN_NAMESPACE

//传一个 class类型的指针p，和一个常量引用的value，new一块空间，利用_T1(__value)构造初值
template <class _T1, class _T2>
inline void construct(_T1* __p, const _T2& __value) {
	new ((void*)__p) _T1(__value);
}

//传一个 class类型的指针p，当没有给初值的时候，调用默认的构造函数
template <class _T1>
inline void construct(_T1* __p) {
	new ((void*)__p) _T1();
}

//destory第一版本，接受一个指针，然后直接调用析构函数
template <class _Tp>
inline void destroy(_Tp* __pointer) {
	__pointer->~_Tp();
}

//如果有non-trivial destructor，就从first循环到last的去调用第一版本的destory
template <class _ForwardIterator>
void
__destroy_aux(_ForwardIterator __first, _ForwardIterator __last, __false_type)
{
	for (; __first != __last; ++__first)
		destroy(&*__first);
}

//如果有trivial destructor，就不做操作
template <class _ForwardIterator>
inline void __destroy_aux(_ForwardIterator, _ForwardIterator, __true_type) {}

template <class _ForwardIterator, class _Tp>
inline void
__destroy(_ForwardIterator __first, _ForwardIterator __last, _Tp*)
{
	//typename __type_traits<_Tp>::has_trivial_destructor是来声明一个类型，这里直接用class来代替他来理解一下下面的这一句代码，把他换成class之后就变成了typedef class _Trivial_destructor;意思就是起一个class类型的别名，别名的名字叫_Trivial_destructor
	typedef typename __type_traits<_Tp>::has_trivial_destructor
		_Trivial_destructor;
	__destroy_aux(__first, __last, _Trivial_destructor());
}

//destory第二版本，接受两个迭代器，使用__VALUE_TYPE判断元素的数值型别，__VALUE_TYPE包含在头文件"stl_type_traits.h"里面
template <class _ForwardIterator>
inline void destroy(_ForwardIterator __first, _ForwardIterator __last) {
	__destroy(__first, __last, __VALUE_TYPE(__first));
}

//特化的_Destroy，以下类型不执行操作
inline void _Destroy(char*, char*) {}
inline void _Destroy(int*, int*) {}
inline void _Destroy(long*, long*) {}
inline void _Destroy(float*, float*) {}
inline void _Destroy(double*, double*) {}

__STL_END_NAMESPACE
```

STL源码剖析里的这张图可以很好的总结上面的代码

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-06_11-09-47.png)

不过STL源码剖析里面特化的类型没有上面的代码多

> 补充知识点：
>
> trivial destructor和non-trivial destructor：
>
>  如果用户不定义析构函数，而是用系统自带的，则说明，析构函数基本没有什么用（但默认会被调用）我们称之为trivial destructor。反之，如果特定定义了析构函数，则说明需要在释放空间之前做一些事情，则这个析构函数称为non-trivial destructor。
>
> 型别：
>
> 型别指的就是迭代器所指对象的类型。
>
> 迭代器所指对象的类型，称为该迭代器的 value_type

construct()接受一个指针p和一个初始值value，主要的功能就是给指针p指向的空间赋初始值

destroy()有两个版本，第一个版本接受一个指针，然后调用析构函数。第二版本接受两个迭代器，目的是把fist到last范围内的对象析构掉，但是如果范围太大，每次都调用该对象的析构(这里的析构函数指的是用户没有自定义，系统默认的析构函数)基本没什么用，这样就会对效率产生影响。所以第二版本的destroy()首先利用\__VALUE\_TYPE判断一下迭代器指的对象的型别，然后再利用__type_traits\<\_Tp\>判断以下该型别是否为trivial destructor或non-trivial destructor，如果是trivial destructor则不做操作，如果是non-trivial destructor则再返回去调用第一版本的destroy()，对fist到last范围内的对象进行析构。

### traits

这里还需要补充一下关于traits(上面的代码中的判断型别是否为trivial destructor或non-trivial destructor就利用到了traits编程技术，主要用到的点在头文件"type_traits.h"中)的知识点：

> 关于traits这两篇文章写的特别好：
>
> https://blog.csdn.net/qq100440110/article/details/51854673?ops_request_misc=&request_id=&biz_id=102&utm_term=C++%20Traits&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-1-51854673
>
> https://blog.csdn.net/lihao21/article/details/55043881
>
> 这里配合着自己的type_traits说一下，主要部分就是在注释
>
> ```
> #pragma once
> #include "stl_config.h"
> 
> __STL_BEGIN_NAMESPACE
> 
> struct __true_type {
> };
> 
> struct __false_type {
> };
> 
> //定义模板(泛化)
> template <class _Tp>
> struct __type_traits {
> 	typedef __true_type     this_dummy_member_must_be_first;
> 	typedef __false_type    has_trivial_default_constructor;
> 	typedef __false_type    has_trivial_copy_constructor;
> 	typedef __false_type    has_trivial_assignment_operator;
> 	typedef __false_type    has_trivial_destructor;
> 	typedef __false_type    is_POD_type;
> };
> 
> //模板特化，当传进来的是布尔型该怎么做，下面都是一样的
> __STL_TEMPLATE_NULL struct __type_traits<bool> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> 
> __STL_TEMPLATE_NULL struct __type_traits<char> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<signed char> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<unsigned char> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> 
> __STL_TEMPLATE_NULL struct __type_traits<short> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<unsigned short> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<int> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<unsigned int> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<long> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<unsigned long> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> 
> __STL_TEMPLATE_NULL struct __type_traits<float> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<double> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<long double> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<char*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<signed char*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<unsigned char*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<const char*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<const signed char*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> __STL_TEMPLATE_NULL struct __type_traits<const unsigned char*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> //偏特化，对于原生指针应该怎么样
> template <class _Tp>
> struct __type_traits<_Tp*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> 
> //定义另一个模板，这个模板具体是干什么用的还不太清楚，根据给的注释(注释：我们单独进行此操作以减少依赖项的数量)，等到后面写完了，看到有对应的调用的地方再更新
> template <class _Tp> struct _Is_integer {
> 	typedef __false_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<bool> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<char> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<signed char> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<unsigned char> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<short> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<unsigned short> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<int> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<unsigned int> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<long> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_TEMPLATE_NULL struct _Is_integer<unsigned long> {
> 	typedef __true_type _Integral;
> };
> 
> __STL_END_NAMESPACE
> ```
>
> 分开分析：
>
> ```
> struct __true_type {
> };
> 
> struct __false_type {
> };
> 
> //定义模板(泛化)
> template <class _Tp>
> struct __type_traits {
> 	typedef __true_type     this_dummy_member_must_be_first;
> 	typedef __false_type    has_trivial_default_constructor;
> 	typedef __false_type    has_trivial_copy_constructor;
> 	typedef __false_type    has_trivial_assignment_operator;
> 	typedef __false_type    has_trivial_destructor;
> 	typedef __false_type    is_POD_type;
> };
> ```
>
> 定义的模板，我们最开始希望的是他能告诉我们真或者假，但是他的结果不应该只有一个bool值，应该是个有真/假性质的"对象"，因为我们希望利用其响应结果来进行参数推导，而编译器只有面对class object形式的参数，才会做参数推导。为此式子应该传回这样的东西(也就是上面的struct \_\_true\_type {};struct \_\_false\_type {};)这两个空白的class没有任何成员，不会带来额外负担，还能表示真假，满足我们的需求。
>
> 剩下的部分就是对模板进行特化，对每一个类型进行一个特化，然后最后有一个偏特化
>
> ```
> //偏特化，对于原生指针应该怎么样
> template <class _Tp>
> struct __type_traits<_Tp*> {
> 	typedef __true_type    has_trivial_default_constructor;
> 	typedef __true_type    has_trivial_copy_constructor;
> 	typedef __true_type    has_trivial_assignment_operator;
> 	typedef __true_type    has_trivial_destructor;
> 	typedef __true_type    is_POD_type;
> };
> ```
>
> 这个偏特化是考虑到了原生指针。
>
> 然后对于上面的特化中的`__STL_TEMPLATE_NULL`这个是定义在"stl_config.h"里面的。
>
> 下面是"stl_config.h"里面给出的定义：
>
> ```
> #ifdef __STL_CLASS_PARTIAL_SPECIALIZATION
> #	define __STL_TEMPLATE_NULL template<>
> #else
> #	define __STL_TEMPLATE_NULL
> #endif
> ```
>
> 所以说特化中的`__STL_TEMPLATE_NULL`也就是template<>，目的就是为了实现特化。

### stl_alloc.h

然后就是看stl_alloc.h的代码：

```
template <int __inst>
class __malloc_alloc_template {

private:
  //这里定义了内存不足的时候的处理函数
  static void* _S_oom_malloc(size_t);
  static void* _S_oom_realloc(void*, size_t);
  
  //如果说没有定义__STL_STATIC_TEMPLATE_MEMBER_BUG就会声明函数指针指向一个处理函数
#ifndef __STL_STATIC_TEMPLATE_MEMBER_BUG
  static void (* __malloc_alloc_oom_handler)();
#endif

public:
  //分配内存
  static void* allocate(size_t __n)
  {
    void* __result = malloc(__n);
    //内存不足,需要进行异常处理,调用处理函数_S_oom_malloc
    if (0 == __result) __result = _S_oom_malloc(__n);
    return __result;
  }
  //释放内存
  static void deallocate(void* __p, size_t /* __n */)
  {
    free(__p);
  }
  //重新分配内存
  static void* reallocate(void* __p, size_t /* old_sz */, size_t __new_sz)
  {
    void* __result = realloc(__p, __new_sz);
    //和上面一样,内存不足,需要进行异常处理,也是调用处理函数_S_oom_realloc
    if (0 == __result) __result = _S_oom_realloc(__p, __new_sz);
    return __result;
  }
  /*这里的定义比较绕,首先
  指定自己的异常处理函数从里往外读:__set_malloc_handler有形参列表,所以是一个函数,参数列表里有一个void (*__f)(),void (*__f)()也有参数列表所以也是一个函数,但是参数列表为空,然后前面有一个*所以说明这是一个函数指针返回值为void类型,然后再往外看,__set_malloc_handler前也有一个指针,说明这也是一个函数指针返回值也为void类型。
  */
  static void (* __set_malloc_handler(void (*__f)()))()
  {
    //把__malloc_alloc_oom_handler传给一个函数指针。
    void (* __old)() = __malloc_alloc_oom_handler;
    //把参数里的函数指针传给__malloc_alloc_oom_handler
    __malloc_alloc_oom_handler = __f;
    return(__old);
  }

};

// malloc_alloc out-of-memory handling

#ifndef __STL_STATIC_TEMPLATE_MEMBER_BUG
template <int __inst>
void (* __malloc_alloc_template<__inst>::__malloc_alloc_oom_handler)() = 0;
#endif
//定义成员函数_S_oom_malloc
template <int __inst>
void*
__malloc_alloc_template<__inst>::_S_oom_malloc(size_t __n)
{
    //定义一个函数指针，和一个空类型的__result
    void (* __my_malloc_handler)();
    void* __result;
	//不断尝试释放，配置，再释放，再配置....
    for (;;) {
        __my_malloc_handler = __malloc_alloc_oom_handler;
        if (0 == __my_malloc_handler) { __THROW_BAD_ALLOC; }
        //调用处理函数，处理函数为用户定义(企图释放内存)
        (*__my_malloc_handler)();
        //再尝试分配
        __result = malloc(__n);
        if (__result) return(__result);
    }
}
//定义成员函数_S_oom_realloc,和_S_oom_malloc类似
template <int __inst>
void* __malloc_alloc_template<__inst>::_S_oom_realloc(void* __p, size_t __n)
{
    void (* __my_malloc_handler)();
    void* __result;

    for (;;) {
        __my_malloc_handler = __malloc_alloc_oom_handler;
        if (0 == __my_malloc_handler) { __THROW_BAD_ALLOC; }
        (*__my_malloc_handler)();
        __result = realloc(__p, __n);
        if (__result) return(__result);
    }
}

typedef __malloc_alloc_template<0> malloc_alloc;
```

```
//对应上面代码中的__THROW_BAD_ALLOC
//如果没有定义__THROW_BAD_ALLOC则执行
#ifndef __THROW_BAD_ALLOC
#  if defined(__STL_NO_BAD_ALLOC) || !defined(__STL_USE_EXCEPTIONS)//检测是否定义了__STL_NO_BAD_ALLOC以及__STL_USE_EXCEPTIONS
#    include <stdio.h>
#    include <stdlib.h>
#    define __THROW_BAD_ALLOC fprintf(stderr, "out of memory\n"); exit(1)//如果没有定义就定义__THROW_BAD_ALLOC的内容为输出一条错误信息
#  else /* Standard conforming out-of-memory handling */ //如果定义了就直接定义__THROW_BAD_ALLOC的内容为抛出定义的异常函数,这里说的定义了其实就是用户自己设计的,如果没有设计就使用默认的
#    include <new>
#    define __THROW_BAD_ALLOC throw std::bad_alloc()
#  endif
#endif
```

上述代码涉及到了一个new handler机制，这个机制简单的一句话来说就是当出现内存不足的时候就调用一个你指定的函数。也就是上面的代码中的`__set_malloc_handler`但是这个`__set_malloc_handler`函数是一个仿真函数，他是模仿`set_new_handler`函数。

然后假如用户没有定义的话就直接抛出一个错误信息，然后exit(1)。

然后就是第二级配置器，第二级配置器考虑到了内存碎片化，但是自己的里面并没有使用第二级配置器，只是用了第一级的。所以就不详细说明(学习)了。

在整个配置器设计中，由于有第一级和第二级配置器，他就会考虑定义的alloc是第一级配置器还是第二级配置器，会通过一个__USE_MALLOC来判断，代码如下：

```
#ifdef __USE_MALLOC
...
typedef __malloc_alloc_template<0> malloc_alloc;
typedef malloc_alloc alloc;    //令alloc为第一级配置器
#else
...
typedef __default_alloc_template<_NODE_ALLOCATOR_THREADS,0> alloc;
#endif /* ! __USE_MALLOC */
```

但是无论alloc是被定义为第一级配置器还是第二级配置器，SGI都会再为它包装一个接口，代码中的simple alloc。

```
template<class _Tp, class _Alloc>
class simple_alloc {

public:
	static _Tp* allocate(size_t __n)
	{
		return 0 == __n ? 0 : (_Tp*)_Alloc::allocate(__n * sizeof(_Tp));
	}
	static _Tp* allocate(void)
	{
		return (_Tp*)_Alloc::allocate(sizeof(_Tp));
	}
	static void deallocate(_Tp* __p, size_t __n)
	{
		if (0 != __n) _Alloc::deallocate(__p, __n * sizeof(_Tp));
	}
	static void deallocate(_Tp* __p)
	{
		_Alloc::deallocate(__p, sizeof(_Tp));
	}
};

typedef malloc_alloc alloc;
```

simple_alloc中的四个成员函数全部都是转调用，转去调用第一或第二级配置器中的成员函数。这个接口还有一个功能就是从bytes转换为个别元素的大小(sizeof(_Tp))。

### 五个全局函数

五个全局函数，前两个是负责构造和析构的construct和destory，上面都已经说过了，剩下的三个是uninitialized_copy()，uninitialized_fill()，uninitialized_fill_n()。这三个属于低层次函数，分别对应于高层次的copy()，fill()，fill_n()。这三个函数位于"stl_uninitialized.h"里面

这三个函数都可以把内存的配置与构造分开。

uninitialized_copy:

```
template <class _InputIter, class _ForwardIter>
inline _ForwardIter
uninitialized_copy(_InputIter __first, _InputIter __last,
	_ForwardIter __result);
```

功能是如果说作为输出目的地的`[__result,__result+(__last-__first)]`范围内的每一个迭代器都指向未初始化区域，则uninitialized_copy()会使用copy constructor，给身为输入来源之[fist，last)范围内的每一个对象产生一个复制品，放进输出范围内，用代码表示就是

```
constructor(&*(__result+(i-first)),*i)
```

翻译过来就是在输入范围内的每一个迭代器i，他就会在输出范围内产生对应的*i的复制品。

uninitialized_fill:

```
template <class _ForwardIter, class _Tp>
inline void uninitialized_fill(_ForwardIter __first,
	_ForwardIter __last,
	const _Tp& __x)
```

功能是如果说`[__first,__last)`范围内的每一个迭代器都指向未初始化的内存，则uninitialized_fill()会在这个范围内产生x的复制品。用代码表示就是

```
constructor(&*i,x)
```

uninitialized_fill_n:

```
template <class _ForwardIter, class _Size, class _Tp>
inline _ForwardIter
uninitialized_fill_n(_ForwardIter __first, _Size __n, const _Tp& __x)
```

功能是如果说`[__first,__last)`范围内的每一个迭代器都指向未初始化的内存，则uninitialized_fill()会在这个范围内产生x的复制品。用代码表示就是

```
constructor(&*i,x)
```

这三个函数都需要具备"commit or rollback"语意，意思就是他要么产生所有必要元素，要么不产生任何元素。如果有任何一个copy constructor丢出异常(execption)，他们都需要把已经产生的元素再都析构掉。

下面就来具体分析这三个函数：

#### uninitialized_fill_n:

```
//是POD型别，直接采取最具有效率的fill
template <class _ForwardIter, class _Size, class _Tp>
inline _ForwardIter
__uninitialized_fill_n_aux(_ForwardIter __first, _Size __n,
	const _Tp& __x, __true_type)
{
	return fill_n(__first, __n, __x);
}

//对区间范围内，进行一个遍历constructor，然后用了一个try来捕获异常，如果出现异常了就要把之前创建出来的元素再都析构掉
template <class _ForwardIter, class _Size, class _Tp>	
_ForwardIter
__uninitialized_fill_n_aux(_ForwardIter __first, _Size __n,
	const _Tp& __x, __false_type)
{
	_ForwardIter __cur = __first;
	__STL_TRY{
	  for (; __n > 0; --__n, ++__cur)
		_Construct(&*__cur, __x);
	  return __cur;
	}
	__STL_UNWIND(_Destroy(__first, __cur));
}

//判断型别是否为POD型别
template <class _ForwardIter, class _Size, class _Tp, class _Tp1>
inline _ForwardIter
__uninitialized_fill_n(_ForwardIter __first, _Size __n, const _Tp& __x, _Tp1*)
{
	typedef typename __type_traits<_Tp1>::is_POD_type _Is_POD;
	return __uninitialized_fill_n_aux(__first, __n, __x, _Is_POD());
}

//取出型别
template <class _ForwardIter, class _Size, class _Tp>
inline _ForwardIter
uninitialized_fill_n(_ForwardIter __first, _Size __n, const _Tp& __x)
{
	return __uninitialized_fill_n(__first, __n, __x, __VALUE_TYPE(__first));
}
```

这个代码第一步先使用\_\_VALUE\_TYPE取出\_\_first的型别，然后判断该型别是否为POD型别。

> 知识点补充：
>
> POD型别：
>
> POD就是标量型别，或传统的C struct型别。POD型别必须拥有 trivial ctor/dtor/copy/assignment函数，所以对POD型别采用最有效率的初值填写手法，对non-POD型别采取最保险最安全的做法。
>
> 还有一个需要补充的就是trivial ctor/dtor/copy/assignment函数这些都是什么东西。
>
> 这些东西就是指构造函数，拷贝构造函数，拷贝赋值函数和析构函数。如果说这些没有定义的话就会由编译器生成一个默认的对应的函数，生成默认的这些函数就是trivial ctor/dtor/copy/assignment函数。

所以看来上面的代码31-36行执行的就是取出\_\_first的型别，23-29执行的就是判断该型别是否为POD型别，然后在根据判断出来的结果去执行1-7或者9-21。

1-7行就是直接填充了从\_\_first开始填充\_\_n个然后填充的内容为\_\_x。

9-21行就更复杂了他对区间范围内，进行一个遍历constructor，然后用了一个try来捕获异常，如果出现异常了就要把之前创建出来的元素再都析构掉。

#### uninitialized_copy:

```
//是POD型别，直接采取最具有效率的copy
template <class _InputIter, class _ForwardIter>
inline _ForwardIter
__uninitialized_copy_aux(_InputIter __first, _InputIter __last,
	_ForwardIter __result,
	__true_type)
{
	return copy(__first, __last, __result);
}

//不是POD型别，循环遍历construct，利用try捕获异常，如果出现异常则把已经初始化的元素全部析构掉
template <class _InputIter, class _ForwardIter>
_ForwardIter
__uninitialized_copy_aux(_InputIter __first, _InputIter __last,
	_ForwardIter __result,
	__false_type)
{
	_ForwardIter __cur = __result;
	__STL_TRY{
	  for (; __first != __last; ++__first, ++__cur)
		_Construct(&*__cur, *__first);
	  return __cur;
	}
	__STL_UNWIND(_Destroy(__result, __cur));
}

//判断型别是否为POD型别
template <class _InputIter, class _ForwardIter, class _Tp>
inline _ForwardIter
__uninitialized_copy(_InputIter __first, _InputIter __last,
	_ForwardIter __result, _Tp*)
{
	typedef typename __type_traits<_Tp>::is_POD_type _Is_POD;
	return __uninitialized_copy_aux(__first, __last, __result, _Is_POD());
}

//取出型别
template <class _InputIter, class _ForwardIter>
inline _ForwardIter
uninitialized_copy(_InputIter __first, _InputIter __last,
	_ForwardIter __result)
{
	return __uninitialized_copy(__first, __last, __result,
		__VALUE_TYPE(__result));
}

//针对char*型别直接使用memmove来复制
inline char* uninitialized_copy(const char* __first, const char* __last,
	char* __result) {
	memmove(__result, __first, __last - __first);
	return __result + (__last - __first);
}

//针对wchar_t*型别直接使用memmove来复制
inline wchar_t* uninitialized_copy(const wchar_t* __first, const wchar_t* __last,wchar_t* __result)
{
	memmove(__result, __first, sizeof(wchar_t) * (__last - __first));
	return __result + (__last - __first);
}
```

uninitialized_copy基本和uninitialized_fill_n一样，先取出型别然后判断是否为POD型别，如果是POD型别就直接copy，如果不是就也是遍历然后一个一个constructor利用try捕获异常，出现异常则把创建出来的元素全部析构掉。

与uninitialized_fill_n不一样的是45-57行，针对char\*和wchar\_t\*两种型别可以直接使用更具效率的memmove来执行复制行为。

#### uninitialized_fill:

```
//是POD型别，直接采取最具有效率的fill
template <class _ForwardIter, class _Tp>
inline void
__uninitialized_fill_aux(_ForwardIter __first, _ForwardIter __last,
	const _Tp& __x, __true_type)
{
	fill(__first, __last, __x);
}

//不是POD型别，循环遍历construct，利用try捕获异常，如果出现异常则把已经初始化的元素全部析构掉
template <class _ForwardIter, class _Tp>
void
__uninitialized_fill_aux(_ForwardIter __first, _ForwardIter __last,
	const _Tp& __x, __false_type)
{
	_ForwardIter __cur = __first;
	__STL_TRY{
	  for (; __cur != __last; ++__cur)
		_Construct(&*__cur, __x);
	}
	__STL_UNWIND(_Destroy(__first, __cur));
}

//判断型别是否为POD型别
template <class _ForwardIter, class _Tp, class _Tp1>
inline void __uninitialized_fill(_ForwardIter __first,
	_ForwardIter __last, const _Tp& __x, _Tp1*)
{
	typedef typename __type_traits<_Tp1>::is_POD_type _Is_POD;
	__uninitialized_fill_aux(__first, __last, __x, _Is_POD());

}

//取出型别
template <class _ForwardIter, class _Tp>
inline void uninitialized_fill(_ForwardIter __first,
	_ForwardIter __last,
	const _Tp& __x)
{
	__uninitialized_fill(__first, __last, __x, __VALUE_TYPE(__first));
}
```

这个基本步骤就和uninitialized_fill_n差不多一样了，先取出型别然后判断是否为POD型别，如果是POD型别就直接fill，如果不是就也是遍历然后一个一个constructor利用try捕获异常，出现异常则把创建出来的元素全部析构掉。

其中uninitialized_fill_n是可以指定初始化空间的大小，uninitialized_fill不能指定初始化空间的大小，而是从first到last全部初始化。

STL源码剖析上这张图描述的特别好：

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-06_18-34-41.png)
## 迭代器

迭代器的五种型别：

1. value type：指迭代器所指对象的型别

2. difference type：用来表示两个迭代器之间的距离，如果说一个泛型算法提供计数功能，则它的返回值必须是difference type类型，如conut函数

   ```
   template <class I,class T>
   typename iterator_traits<I>::difference_type
   count(I first,I last,const &T value)
   {
   	typename iterator_traits<I>::difference_type n =0;
   	for( ; first!= lasy ; ++first)
   	{
   		if(*first == value)
   		++n;
   	}
   	return n;
   }
   ```

   可以直接看到typename 定义了iterator_traits的difference_type类型为返回类型

   difference_type为了支持原生指针，提供了特化版本

   ```
   template <class I>
   struct iterator_traits{
   	typedef typenmae I::difference_type difference_type;
   };
   
   template <class T>
   struct iterator_traits<*T>{
   	typedef ptrdiff_t difference_type;
   };
   
   template <class T>
   struct iterator_traits<const *T>{
   	typedef ptrdiff_t difference_type;
   };
   ```

3. reference type和pointer type：

   简单的就可以理解为reference是指迭代器指向对象的引用，pointer就是迭代器指向对象的指针。

   例如下面的代码：

   ```
   Item& operator*() const {return *ptr;}
   Item* operator->() const {return ptr;}
   ```

   这段代码开始也是理解不太好，分不清哪个是reference type哪个是pointer type，然后后来仔细看了一下，有一个自己的分析方法，先看第一行。

   ```
   Item& operator*() const {return *ptr;}
   ```

   这一行中返回的是一个return *ptr，意思就是返回的是一个指针，哪如果我们现在要让传回来的东西是它的地址，只有传回引用才可以传回它的地址。

   ```
   Item* operator->() const {return ptr;}
   ```

   这一行中返回的是一个ptr，没有了前面的*，现在ptr就是一个地址，哪现在我们要让传回来的东西是一个指向这个地址的指针，所以前面就应该设置传回指针。

   这个解释的也不太好，就能让自己浅显的理解一下。

   这两个型别的特化版：

   ```
   template <class I>
   struct iterator_traits{
   	typedef typenmae I::pointer pointer;
   	typedef typenmae I::reference reference;
   };
   
   template <class T>
   struct iterator_traits<*T>{
   	typedef T* pointer;
   	typedef T& reference;
   };
   
   template <class T>
   struct iterator_traits<const *T>{
   	typedef const T* pointer;
   	typedef const T& reference;
   };
   ```

4. iterator_category:

   说这个型别之前得说一下迭代器的分类

   > 迭代器分为五类：
   >
   > 1. input iterator：输入迭代器，只读，且只能一次读操作，支持操作：++p,p++,!=,==,=*p,p->；
   >
   > 2. output iterator：输出迭代器，只写，且只能一次写操作，支持操作：++p,p++；
   >
   > 3. forward iterator：正向迭代器，可多次读写，支持输入输出迭代器的所有操作；
   >
   > 4. bidirectional iterator：双向迭代器，支持正向迭代器的所有操作，且支持操作：--p,--p；
   >
   > 5. random access iterator：随机访问迭代器，除了支持双向迭代器操作外，还支持：p[n],p+n,n+p,p-n,p+=n,p-=n,p1-p2,p1<p2,p1>p2,p1>=p2,p1<=p2；
   >
   >    这是迭代器分类从属关系
   >
   > ![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-08_19-07-52.png)
   >
   > 设计算法时，如果可能，尽量要针对上图中的某种迭代器提供一个明确定义，并针对更强化的某种迭代器提供另一种定义，这样才能在不同情况下提供最大效率。举个例子就是某个算法可以接受forward iterator，但是你以random access iterator喂给它，它也可以接受，但是不一定是最佳的
   >
   > 以advance()为例，这个函数接受两个参数，一个是迭代器p一个是数值n，功能就是前进n次，下面有三份定义分别是为input iterator、bidirectional iterator和random access iterator设计的
   >
   > ```
   > template <class InputIterator,class Distance>
   > void advance_II(InputIterator& i,Distance n)
   > {
   > 	while(n--)
   > 		++i;
   > }
   > 
   > template <class BidirectionalIterator,class Distance>
   > void advance_BI(BidirectionalIterator& i,Distance n)
   > {
   > 	if(n > 0){
   > 		while(n--)
   > 			++i;
   > 	}
   > 	else{
   > 		while(n++)
   > 			--i;
   > 	}
   > }
   > 
   > template <class RandomAccessIterator,class Distance>
   > void advance_RAI(RandomAccessIterator& i,Distance n)
   > {
   > 	i += n;
   > }
   > ```
   >
   > 但是上面的代码是有缺陷的，即因为效率会导致某些类型的迭代器接受不了，比如说为了效率选择了RandomAccessIterator但是就不能接受IuputIterator了，但是选择了InputIterator又会导致效率低下，所以需要改进，改进的办法就是函数重载。
   >
   > 要执行重载就必须有一个确定的参数，才能进行重载，上面advance的两个参数都不是确定的（不确定的原因是因为他们是模板参数，需要靠编译器来确定具体是哪种型别），所以我们就对应上面的五个类型的迭代器定义五个class
   >
   > ```
   > class input_iterator_tag {};
   > class output_iterator_tag {};
   > class forward_iterator_tag : public input_iterator_tag {};
   > class bidirectional_iterator_tag : public forward_iterator_tag {};
   > class random_access_iterator_tag : public bidirectional_iterator_tag {}；;
   > ```
   >
   > 现在就重新设计一下__advance，加上第三个参数，形成重载。
   >
   > ```
   > template <class InputIterator,class Distance>
   > inline void advance(InputIterator& i,Distance n)
   > {
   > 	return __advance(RandomAccessIterator& i,Distance n,iterator_traits<Iterator>::iterator_category());
   > }
   > 
   > template <class InputIterator,class Distance>
   > void __advance(InputIterator& i,Distance n,input_iterator_tag)
   > {
   > 	while(n--)
   > 		++i;
   > }
   > 
   > template <class ForwardIterator,class Distance>
   > void __advance(ForwardIterator& i,Distance n,forward_iterator_tag)
   > {
   > 	advance(i,n,input_iterator_tag());
   > }
   > 
   > template <class BidirectionalIterator,class Distance>
   > void __advance(BidirectionalIterator& i,Distance n,bidirectional_iterator_tag)
   > {
   > 	if(n > 0){
   > 		while(n--)
   > 			++i;
   > 	}
   > 	else{
   > 		while(n++)
   > 			--i;
   > 	}
   > }
   > 
   > template <class RandomAccessIterator,class Distance>
   > void __advance(RandomAccessIterator& i,Distance n,random_access_iterator_tag)
   > {
   > 	i += n;
   > }
   > 
   > template <class InputIterator,class Distance>
   > inline void advance(InputIterator& i,Distance n)
   > {
   > 	return __advance(RandomAccessIterator& i,Distance n,iterator_traits<Iterator>::iterator_category());
   > }
   > ```
   >
   > 上面的代码中使用到了`iterator_traits<Iterator>::iterator_category()`这句代码，然而这个我们还没有设计，所以需要设计一个iterator_traits。
   >
   > ```
   > template <class _Iterator>
   > struct iterator_traits {
   > 	typedef typename _Iterator::iterator_category iterator_category;
   > 	typedef typename _Iterator::value_type        value_type;
   > 	typedef typename _Iterator::difference_type   difference_type;
   > 	typedef typename _Iterator::pointer           pointer;
   > 	typedef typename _Iterator::reference         reference;
   > };
   > //原生指针特化版
   > template <class _Tp>
   > struct iterator_traits<_Tp*> {
   > 	typedef random_access_iterator_tag iterator_category;
   > 	typedef _Tp                         value_type;
   > 	typedef ptrdiff_t                   difference_type;
   > 	typedef _Tp* 						pointer;
   > 	typedef _Tp& 						reference;
   > };
   > //const原生指针特化版
   > template <class _Tp>
   > struct iterator_traits<const _Tp*> {
   > 	typedef random_access_iterator_tag iterator_category;
   > 	typedef _Tp                         value_type;
   > 	typedef ptrdiff_t                   difference_type;
   > 	typedef const _Tp* 					pointer;
   > 	typedef const _Tp& 					reference;
   > };
   > ```
   >
   > 我在往文章上写下面的这几行代码的时候，也感觉到了不对的地方，advance不应该是可以接受五种类型的迭代器嘛，为什么这个class直接定义成了InputIterator，然后书中给了答案，目的就是消除单纯传递调用的函数，我自己的理解，单纯传递调用的函数就是这个函数没有做什么事情，只做了一件事就是调用另一个函数。但是这个只是我个人的理解不知道是否正确。
   >
   > ```
   > template <class InputIterator,class Distance>
   > inline void advance(InputIterator& i,Distance n)
   > {
   > 	return __advance(RandomAccessIterator& i,Distance n,iterator_traits<Iterator>::iterator_category());
   > }
   > ```
   >
   > 对应着自己的理解，和上面的代码终端这几行
   >
   > ```
   > template <class ForwardIterator,class Distance>
   > void __advance(ForwardIterator& i,Distance n,forward_iterator_tag)
   > {
   > 	advance(i,n,input_iterator_tag());
   > }
   > ```
   >
   > 书上说这个就是单纯传递调用函数，确实没做什么别的操作，只调用了别的函数。
   >
   > 书上给的一个例子也差不多是这样的，例子如下：。
   >
   > ```
   > #include <iostream>
   > 
   > using namespace std;
   > 
   > struct B {};
   > struct D1 : public B {};
   > struct D2 : public D1 {};
   > 
   > template <class I>
   > func(I& p, B){
   > 	cout << "B Version" << endl;
   > }
   > 
   > template <class I>
   > func(I& p, D2){
   > 	cout << "D2 Version" << endl;
   > }
   > 
   > int main(){
   > 	int *p;
   > 	func(p,B());
   > 	func(p,D1());
   > 	func(p,D2());
   > }
   > 
   > 输出结果：
   > B Version
   > B Version
   > D2 Version
   > ```
   >
   > 从上面的代码中的结果来看，由于没有定义D1这个参数的函数重载版本，所以如果调用这个func(p,D1())就会直接去传递它的父类，也就是B，所以就会打印出两个B Version，这个和自己理解的单纯传递调用函数也差不多没有做什么操作，就是调用了别的函数
### 迭代器配接器

迭代器适配器分三种：

1. 反向迭代器
2. 插入迭代器
3. IO流迭代器

#### 插入迭代器

插入迭代器的主要功能为把一个赋值操作转换为把相应的值插入容器的操作。插入迭代器对标准算法库而言尤其重要。算法库对所有在容器上的操作有个承诺：决不修改容器的大小（不插入、不删除）。有了插入迭代器，既使得算法库可以通过迭代器对容器插入新的元素，又不违反这一承诺，即保持了设计上的一致性。

插入迭代器提供了以下几种操作：*itr，itr++，++itr，itr--，--itr，itr = value。但实际上，前五种操作为“空操作”(no-op)，仅仅返回itr，简单来说就是插入迭代器的前进，后退，取值，成员取用操作是没有意义的，甚至是不允许的。第四种操作itr = value才是插入迭代器的核心，这个操作通过调用容器的成员函数（push_back()，push_front()，insert()，取决于插入器类型）把value插入到插入器对应容器的相应的位置上。下面是插入迭代器的代码，以及自己附加的注释。

```
//--------------------------------------------------------------------------
//从容器的尾端插入进去
template <class _Container>
class back_insert_iterator {
protected:
	_Container* container;	//底层容器
public:
	typedef _Container          container_type;
	typedef output_iterator_tag iterator_category;
	typedef void                value_type;
	typedef void                difference_type;
	typedef void                pointer;
	typedef void                reference;

	explicit back_insert_iterator(_Container& __x) : container(&__x) {}		//与容器绑定
	back_insert_iterator<_Container>&		//操作符重载，把赋值运算符重载为push_back
		operator=(const typename _Container::value_type& __value) {
		container->push_back(__value);
		return *this;
	}
	back_insert_iterator<_Container>& operator*() { return *this; }		//操作符重载，不过只是返回指针
	back_insert_iterator<_Container>& operator++() { return *this; }	//操作符重载，不过只是返回指针
	back_insert_iterator<_Container>& operator++(int) { return *this; }		//操作符重载，不过只是返回指针
};

//辅助函数，方便我们使用back_insert_iterator
template <class _Container>
inline back_insert_iterator<_Container> back_inserter(_Container& __x) {
	return back_insert_iterator<_Container>(__x);
}

//--------------------------------------------------------------------------
//从容器的前端插入进去，这个迭代器配接器不适用于vector，因为vector没有提供push_front函数
template <class _Container>
class front_insert_iterator {
protected:
	_Container* container;	//底层容器
public:
	typedef _Container          container_type;
	typedef output_iterator_tag iterator_category;
	typedef void                value_type;
	typedef void                difference_type;
	typedef void                pointer;
	typedef void                reference;

	explicit front_insert_iterator(_Container& __x) : container(&__x) {}	//与容器绑定
	front_insert_iterator<_Container>&		//操作符重载，把赋值运算符重载为push_front	
		operator=(const typename _Container::value_type& __value) {
		container->push_front(__value);
		return *this;
	}
	front_insert_iterator<_Container>& operator*() { return *this; }		//操作符重载，不过只是返回指针
	front_insert_iterator<_Container>& operator++() { return *this; }		//操作符重载，不过只是返回指针
	front_insert_iterator<_Container>& operator++(int) { return *this; }		//操作符重载，不过只是返回指针
};

//辅助函数，方便我们使用front_insert_iterator
template <class _Container>
inline front_insert_iterator<_Container> front_inserter(_Container& __x) {
	return front_insert_iterator<_Container>(__x);
}

//--------------------------------------------------------------------------
//操作修改为插入操作，在指定的位置上进行，并将迭代器右移一个位置
//这样就可以很方便的连续执行，“表面上是赋值（覆写）而实际上是插入”的操作
template <class _Container>
class insert_iterator {
protected:
	_Container* container;	//底层容器
	typename _Container::iterator iter;
public:
	typedef _Container          container_type;
	typedef output_iterator_tag iterator_category;
	typedef void                value_type;
	typedef void                difference_type;
	typedef void                pointer;
	typedef void                reference;

	insert_iterator(_Container& __x, typename _Container::iterator __i)
		: container(&__x), iter(__i) {}
		
	//操作符重载，把赋值重载为insert操作
	insert_iterator<_Container>&
		operator=(const typename _Container::value_type& __value) {
		iter = container->insert(iter, __value);
		++iter;
		return *this;
	}
	insert_iterator<_Container>& operator*() { return *this; }		//操作符重载，不过只是返回指针
	insert_iterator<_Container>& operator++() { return *this; }		//操作符重载，不过只是返回指针
	insert_iterator<_Container>& operator++(int) { return *this; }		//操作符重载，不过只是返回指针
};

//辅助函数，方便我们使用insert_iterator
template <class _Container, class _Iterator>
inline
insert_iterator<_Container> inserter(_Container& __x, _Iterator __i)
{
	typedef typename _Container::iterator __iter;
	return insert_iterator<_Container>(__x, __iter(__i));
}
```

#### 反向迭代器

反向迭代器是一种反向遍历容器的迭代器。也就是，从最后一个元素到第一个元素遍历容器。反向迭代器将自增（和自减）的含义反过来了：对于反向迭代 器，++ 运算将访问前一个元素，而 -- 运算则访问下一个元素。
回想一下，所有容器都定义了 begin 和 end 成员，分别返回指向容器首元素和尾元素下一位置的迭代器。容器还定义了 rbegin 和 rend 成员，分别返回指向容器尾元素和首元素前一位置的反向迭代器。与普通迭代器一样，反向迭代器也有常量（const）和非常量（nonconst）类型。下面是反向迭代器的代码，以及自己附加的注释。

```
//--------------------------------------------------------------------------
//逆反迭代器前进方向
template<class _Iterator>
    class reverse_iterator {
    protected:
        _Iterator current;		//记录对应的正向迭代器
    public:
        typedef typename iterator_traits<_Iterator>::iterator_category
                iterator_category;
        typedef typename iterator_traits<_Iterator>::value_type
                value_type;
        typedef typename iterator_traits<_Iterator>::difference_type
                difference_type;
        typedef typename iterator_traits<_Iterator>::pointer
                pointer;
        typedef typename iterator_traits<_Iterator>::reference
                reference;

        typedef _Iterator iterator_type;		//代表正向迭代器
        typedef reverse_iterator<_Iterator> _Self;		//代表逆向迭代器
    public:
        reverse_iterator() {}
		//这个构造函数将reverse_bidirectional_iterator与某个迭代器x系结起来
        explicit reverse_iterator(iterator_type __x) : current(__x) {}

        reverse_iterator(const _Self &__x) : current(__x.current) {}

        template<class _Iter>
        
        reverse_iterator(const reverse_iterator<_Iter> &__other):current(__other.base()) {}
		//取出正向迭代器
        iterator_type base() const {
            return current;
        }
		//对应的正向迭代器后退一格后取值
        reference operator*() const {
            _Iterator __tmp = current;
            return *--__tmp;
        }
		//对应的正向迭代器后退一格后取值
        pointer operator->() const {
            return &(operator*());
        }
		//把前进重载为后退
        _Self &operator++() {
            --current;
            return *this;
        }
		//把前进重载为后退
        _Self operator++(int) {
            _Self __tmp = *this;
            --current;
            return __tmp;
        }
		//把后退重载为前进
        _Self &operator--() {
            ++current;
            return *this;
        }
		//把后退重载为前进
        _Self operator--(int) {
            _Self __tmp = *this;
            ++current;
            return __tmp;
        }
		//把前进n重载为后退n
        _Self operator+(difference_type __n) const {
            return _Self(current - __n);
        }
		//把后退n重载为前进n
        _Self operator-(difference_type __n) const {
            return _Self(current + __n);
        }
		//把前进n重载为后退n
        _Self &operator+=(difference_type __n) {
            current -= __n;
            return *this;
        }
		//把后退n重载为前进n
        _Self &operator-=(difference_type __n) {
            current += __n;
            return *this;
        }
		//返回当前迭代器+n之后指向地方的值
        reference operator[](difference_type __n) const {
//        base()[-n-1]
            return *(*this + __n);
        }
    };

    template<class _Iterator>
    inline bool operator==(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return __lhs.base() == __rhs.base();
    }

    template<class _Iterator>
    inline bool operator!=(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return !(__lhs == __rhs);
    }

    template<class _Iterator>
    inline bool operator<(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return __rhs.base() < __lhs.base();
    }

    template<class _Iterator>
    inline bool operator>(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return __rhs < __lhs;
    }

    template<class _Iterator>
    inline bool operator<=(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return !(__rhs < __lhs);
    }

    template<class _Iterator>
    inline bool operator>=(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return !(__lhs < __rhs);
    }

    template<class _Iterator>
    reverse_iterator<_Iterator>
    //把前进n重载为后退n
    operator+(typename reverse_iterator<_Iterator>::difference_type __n,
              const reverse_iterator<_Iterator> &__x) {
//    return it + n;
        return reverse_iterator<_Iterator>(__x.base() - __n);
    }

    template<class _Iterator>
    typename reverse_iterator<_Iterator>::difference_type
    //把后退n重载为前进n
    operator-(const reverse_iterator<_Iterator> &__lhs, const reverse_iterator<_Iterator> &__rhs) {
        return __rhs.base() - __lhs.base();
    }
```

## vector

vector和array类似，不过array分配了之后空间就是写死的了就只能这么大，然而vector并不是，它可以动态的调整空间的大小。vector容器有已使用空间和可用空间，已使用空间是指vector容器的大小，可用空间是指vector容器可容纳的最大数据空间capacity。vector容器是占用一段连续线性空间，所以vector容器的迭代器就等价于原生态的指针；vector的实现依赖于内存的配置和内存的初始化，以及迭代器。其中内存的配置是最重要的，因为每当配置内存空间时，可能会发生数据移动，回收旧的内存空间，如果不断地重复这些操作会降低操作效率，所有vector容器在分配内存时，并不是用户数据占多少就分配多少，它会分配一些内存空间留着备用，即是用户可用空间。

### vector容器的数据结构

vector容器采用的是线性连续空间的数据结构，使用两个迭代器来管理这片连续内存空间，这两个迭代器分别是指向目前使用空间的头start和指向目前使用空间的尾finish，两个迭代器的范围[start,finish)表示容器的大小size()。由于为了提高容器的访问效率，为用户分配内存空间时，会分配多余的备用空间，即容器的容量，以迭代器end_of_storage作为可用空间的尾，则容器的容量capacity()为[start,end_of_storage)范围的线性连续空间。

```
template<class _Tp, class _Alloc>
class _Vector_base {
......
protected:
    _Tp *_M_start;
    _Tp *_M_finish;
    _Tp *_M_end_of_storage;
......
}
```

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-09_22-59-00.jpg)

### vector迭代器

vector容器维护的空间的线性连续的，所以普通指针也可以作为迭代器，满足vector的访问操作；如：operator*，operator->，operator++，operator--，operator+，operator-，operator+=，operator-=等操作；同时vector容器支持随机访问，所以，vector提供的是随机访问迭代器。

```
 template<class _Tp, class _Alloc = alloc>
 class vector : protected _Vector_base<_Tp, _Alloc> {
 private:
     typedef _Vector_base<_Tp, _Alloc> _Base;
 public:
     typedef _Tp value_type;
     typedef value_type *pointer;
     typedef const value_type *const_pointer;
     typedef value_type *iterator;
     typedef const value_type *const_iterator;
     typedef value_type &reference;
     typedef const value_type &const_reference;
     typedef size_t size_type;
     typedef ptrdiff_t difference_type;
     typedef typename _Base::allocator_type allocator_type;

......

 public:
     iterator begin() {
         return _M_start;
     }

     const_iterator begin() const {
         return _M_start;
     }

     iterator end() {
         return _M_finish;
     }

     const_iterator end() const {
         return _M_finish;
     }

     reverse_iterator rbegin() {
         return reverse_iterator(end());
     }

     const_reverse_iterator rbegin() const {
         return reverse_iterator(end());
     }

     reverse_iterator rend() {
         return reverse_iterator(begin());
     }

     const_reverse_iterator rend() const {
         return reverse_iterator(begin());
     }
```

### vector的构造函数和析构函数

```
//默认构造函数
explicit vector(const allocator_type &__a = allocator_type()) : _Base(__a) {}
//有初始size和value的构造函数
vector(size_type __n, const _Tp &__value, const allocator_type &__a = allocator_type()) : _Base(__n, __a) {
    _M_finish = uninitialized_fill_n(_M_start, __n, __value);//全局函数，从传过来的迭代器位置，填充n个元素，值为value
}
//只有初始size没有value的构造函数
explicit vector(size_type __n)
        : _Base(__n, allocator_type()) {
    _M_finish = uninitialized_fill_n(_M_start, __n, _Tp());//全局函数，从传过来的迭代器位置，填充n个元素，值为空
}
//没有初始size和value的构造函数
vector(const vector<_Tp, _Alloc> &__x) : _Base(__x.size(), __x.get_allocator()) {
    _M_finish = uninitialized_copy(__x.begin(), __x.end(), _M_start);//全局函数，把begin到end区间内的元素复制到以start开头的地方
}
//以头尾两个迭代器表示大小的构造函数
template<class _InputIterator>
vector(_InputIterator __first, _InputIterator __last, const allocator_type &__a = allocator_type()):_Base(__a) {
    typedef typename _Is_integer<_InputIterator>::_Integral _Integral;
    _M_initialize_aux(__first, __last, _Integral());
}
//若输入为整数，则调用该函数
template<class _Integer>
void _M_initialize_aux(_Integer __n, _Integer __value, __true_type) {
    _M_start = _M_allocate(__n);
    _M_end_of_storage = _M_start + __n;
    _M_finish = uninitialized_fill_n(_M_start, __n, __value);
}
//若输入不是整数，则采用Traits技术继续判断迭代器的类型
template<class _InputIterator>
void _M_initialize_aux(_InputIterator __first, _InputIterator __last, __false_type) {
    _M_range_initialize(__first, __last, __ITERATOR_CATEGORY(__first));
}
//析构函数
~vector() {
    destroy(_M_start, _M_finish);
}
```

### vector容器的成员函数

```
//返回大小
size_type size() const {
    return size_type(end() - begin());
}
//返回最大容量
size_type max_size() const {
    return size_type(-1) / sizeof(_Tp);
}
//返回可用容量大小
size_type capacity() const {
    return size_type(_M_end_of_storage - begin());
}
//返回是否为空
bool empty() const {
    return begin() == end();
}
//返回迭代器所指向地方的值
reference operator[](size_type __n) {
    return *(begin() + __n);
}
//返回迭代器所指向地方的值
const_reference operator[](size_type __n) const {
    return *(begin() + __n);
}
/若用户要求的空间大于可用空间，抛出错去信息，即越界检查
void _M_range_check(size_type __n) const {
    if (__n >= size())
        //todo
    { throw; };
}
//访问指定元素，并且进行越界检查
reference at(size_type __n) {
    _M_range_check(__n);
    return (*this)[__n];
}
//访问指定元素，并且进行越界检查
const_reverse_iterator at(size_type __n) const {
    _M_range_check(__n);
    return (*this)[__n];
}
//改变可用空间内存大小
void reserve(size_type __n) {
    //重新分配大小为n的内存空间，并把原来数据复制到新分配空间
    if (capacity() < __n) {
        const size_type __old_size = size();
        iterator __tmp = _M_allocate_and_copy(__n, _M_start, _M_finish);
        destroy(_M_start, _M_finish);
        //把可用空间全部收回
        _M_deallocate(_M_start, _M_end_of_storage - _M_start);
        //修改指针指向新的内存空间
        _M_start = __tmp;
        _M_finish = __tmp + __old_size;
        _M_end_of_storage = _M_start + __n;
    }
}
//把容器内容替换为n个初始值为value
void assign(size_type __n, const _Tp &__val) {
    _M_fill_assign(__n, __val);
}

void _M_fill_assign(size_type __n, const _Tp &__val);

template<class _InputIterator>
void assign(_InputIterator __first, _InputIterator __last) {
    typedef typename _Is_integer<_InputIterator>::_Integral _Integral;
    _M_assign_dispatch(__first, __last, _Integral());
}

template<class _Integer>
void _M_assign_dispatch(_Integer __n, _Integer __val, __true_type) {
    _M_fill_assign((size_type) __n, (_Tp) __val);
}

template<class _InputIterator>
void _M_assign_dispatch(_InputIterator __first, _InputIterator __last, __false_type) {
    _M_assign_aux(__first, __last, __ITERATOR_CATEGORY(__first));
}

template<class _InputIterator>
void _M_assign_aux(_InputIterator __first, _InputIterator __last, input_iterator_tag);

template<class _ForwardIterator>
void _M_assign_aux(_ForwardIterator __first, _ForwardIterator __last, forward_iterator_tag);
//返回第一个元素
reference front() {
    return *begin();
}
//返回第一个元素
const_reference front() const {
    return *begin();
}
//返回最后一个元素
reference back() {
    return *(end() - 1);
}
//返回最后一个元素
const_reference back() const {
    return *(end() - 1);
}
//在最尾端插入元素
void push_back(const _Tp &__value) {
	//查看是否有可用空间，如果有可用空间则直接构造一个对象然后指针加一即可
	//如果没有可能空间则需要使用_M_insert_aux，扩展可用空间然后插入
    if (_M_finish != _M_end_of_storage) {
        construct(_M_finish, __value);
        ++_M_finish;
    } else {
        _M_insert_aux(end(), __value);
    }
}
//在最尾端插入元素
void push_back() {
	//查看是否有可用空间，如果有可用空间则直接构造一个对象然后指针加一即可
	//如果没有可能空间则需要使用_M_insert_aux，扩展可用空间然后插入
	if (_M_finish != _M_end_of_storage) {
        construct(_M_finish);
        ++_M_finish;
    } else {
        _M_insert_aux(end());
    }
}
//交换容器的内容，直接交换迭代器指的地址
void swap(vector<_Tp, _Alloc> &__x) {
    if (this != &__x) {
        __STL_NAME ::swap(_M_start, __x._M_start);
        __STL_NAME ::swap(_M_finish, __x._M_finish);
        __STL_NAME ::swap(_M_end_of_storage, __x._M_end_of_storage);
    }
}
//把值插入到指定的位置
iterator insert(iterator __position, const _Tp &__x) {
    size_type __n = __position - begin();
    //插入需要分成多种情况考虑
    //第一种是插入到vector的末位
    if (_M_finish != _M_end_of_storage && __position == end()) {
        construct(_M_finish, __x);
        ++_M_finish;
    }
    //插入到其他位置
    else {
        _M_insert_aux(__position, __x);
    }
    return begin() + __n;
}
//检测是不是整数，如果是整数则调用下面的函数
template<class _InputIterator>
void insert(iterator __pos, _InputIterator __first, _InputIterator __last) {
    typedef typename _Is_integer<_InputIterator>::_Integral _Integral;
    _M_insert_dispatch(__pos, __first, __last, _Integral());
}
//传进来的是size和value
template<class _Integer>
void _M_insert_dispatch(iterator __pos, _Integer __n, _Integer __val, __true_type) {
    _M_fill_insert(__pos, (size_type) __n, (_Tp) __val);
}
//传进来的是第一个和最后一个的迭代器
template<class _InputIterator>
void _M_insert_dispatch(iterator __pos, _InputIterator __first, _InputIterator __last, __false_type) {
    _M_range_insert(__pos, __first, __last, __ITERATOR_CATEGORY(__first));
}
//在pos位置连续插入n个初始值为x的元素
void insert(iterator __pos, size_type __n, const _Tp &__x) {
    _M_fill_insert(__pos, __n, __x);
}
//声明函数
void _M_fill_insert(iterator __pos, size_type __n, const _Tp &__x);
//删除最后一个元素
void pop_back() {
    --_M_finish;
    destroy(_M_finish);
}
//擦除指定位置元素
iterator erase(iterator __position) {
    //如果position后面还有元素，需要拷贝;如果position是最后一个元素，则后面没有元素，直接destroy即可
    if (__position + 1 != end()) {
        copy(__position + 1, _M_finish, __position);
    }
    --_M_finish;
    destroy(_M_finish);
    return __position;
}
//擦除两个迭代器区间的元素
iterator erase(iterator __first, iterator __last) {
	//把不擦除的保存起来
    iterator __i = copy(__last, _M_finish, __first);
    //析构
    destroy(__i, _M_finish);
    //调整指针
    _M_finish = _M_finish - (__last - __first);
    return __first;
}
//改变容器中可存储的元素个数，并不会分配新的空间
void resize(size_type __new_size, const _Tp &__x) {
	//如果说新的个数比原先的小则擦除掉多余的
    if (__new_size < size()) {
        erase(begin() + __new_size, end());
    }
    //如果说新的个数比原先的多则直接在原来的末尾新增
    else {
        insert(end(), __new_size - size(), __x);
    }
}

void resize(size_type __new_size) {
    resize(__new_size, _Tp());
}
//清空容器
void clear() {
    erase(begin(), end());
}

protected:
	//先初始化一块空间然后复制，如果复制过程出现异常则把已经复制完成的再都析构掉
    template<class _ForwardIterator>
    iterator _M_allocate_and_copy(size_type __n, _ForwardIterator __first, _ForwardIterator __last) {
        iterator __result = _M_allocate(__n);
        try {
            uninitialized_copy(__first, __last, __result);
            return __result;
        } 
        catch (...) {
            _M_deallocate(__result, __n);
            throw;
        }
    }
	//在last后构造出与原先元素序列相同的元素
    template<class _InputIterator>
    void _M_range_initialize(_InputIterator __first, _InputIterator __last, input_iterator_tag) {
        for (; __first != __last; ++__first) {
            push_back(*__first);
        }
    }

    // This function is only called by the constructor.
    //创建一块新空间让开头结尾，并且把头尾和容量都指向新的空间，然后再把原先的内容复制到新的空间
    template<class _ForwardIterator>
    void _M_range_initialize(_ForwardIterator __first, _ForwardIterator __last, forward_iterator_tag) {
        size_type __n = 0;
        distance(__first, __last, __n);
        _M_start = _M_allocate(__n);
        _M_end_of_storage = _M_start + __n;
        _M_finish = uninitialized_copy(__first, __last, _M_start);
    }
	
    template<class _InputIterator>
    void _M_range_insert(iterator __pos,
                         _InputIterator __first, _InputIterator __last,
                         input_iterator_tag);

    template<class _ForwardIterator>
    void _M_range_insert(iterator __pos,
                         _ForwardIterator __first, _ForwardIterator __last,
                         forward_iterator_tag);
};

	//填充n个val，如果大于容量则申请新空间然后填充，填充之后再把指针交换一下让end_of_storage再指向最大容量的那个地方，如果说在容量内，则直接填充而且这个填充会把整个空间全部填充为val，如果说在size内则先填充，填充完之后把多余的部分直接擦除掉
	template<class _Tp, class _Alloc>
    void vector<_Tp, _Alloc>::_M_fill_assign(size_type __n, const _Tp &__val) {
        if (__n > capacity()) {
            vector<_Tp, _Alloc> __tmp(__n, __val, get_allocator());
            __tmp.swap(*this);
        } else if (__n > size()) {
            fill(begin(), end(), __val);
            _M_finish = uninitialized_fill_n(_M_finish, __n - size(), __val);
        } else {
            //size() >= __n
            erase(fill_n(begin(), __n, __val), end());
        }
    }
	
    template<class _Tp, class _Alloc>
    template<class _InputIter>
    void vector<_Tp, _Alloc>::_M_assign_aux(_InputIter __first, _InputIter __last,
                                            input_iterator_tag) {
        iterator __cur = begin();
        //把first，last之间的内容从开头开始赋值一直赋到与first，last的距离一样
        for (; __first != __last && __cur != end(); ++__cur, ++__first)
            *__cur = *__first;
        //如果first，last相同，则擦除全部元素
        if (__first == __last)
            erase(__cur, end());
        //否则就把end到first中间的内容，插入到last后面
        else
            insert(end(), __first, __last);
    }

    template<class _Tp, class _Alloc>
    template<class _ForwardIter>
    void vector<_Tp, _Alloc>::_M_assign_aux(_ForwardIter __first, _ForwardIter __last, forward_iterator_tag) {
        size_type __len = 0;
        //统计从__First到__last的元素个数
        distance(__first, __last, __len);
        if (__len > capacity()) {
            //重新初始化并拷贝元素从first到last
            iterator __tmp = _M_allocate_and_copy(__len, __first, __last);
            destroy(_M_start, _M_finish);
            _M_deallocate(_M_start, _M_end_of_storage - _M_start);
            _M_start = __tmp;
            _M_end_of_storage = _M_finish = _M_start + __len;
        } else if (size() >= __len) {
            iterator __new_finish = copy(__first, __last, _M_start);
            destroy(__new_finish, _M_finish);
            _M_finish = __new_finish;
        } else {
            // size < __len <=capacity
            _ForwardIter __mid = __first;
            advance(__mid, size());
            copy(__first, __mid, _M_start);
            _M_finish = uninitialized_copy(__mid, __last, _M_finish);
        }
    }

    template<class _Tp, class _Alloc>
    void vector<_Tp, _Alloc>::_M_insert_aux(iterator __position, const _Tp &__x) {
        if (_M_finish != _M_end_of_storage) {
            construct(_M_finish, *(_M_finish - 1));
            ++_M_finish;
            _Tp __x_copy = __x;
            copy_backward(__position, _M_finish - 2, _M_finish - 1);
            *__position = __x_copy;
        } else {
            const size_type __old_size = size();
            const size_type __len = __old_size != 0 ? 2 * __old_size : 1;
            iterator __new_start = _M_allocate(__len);
            iterator __new_finish = __new_start;
            try {
                __new_finish = uninitialized_copy(_M_start, __position, __new_start);
                construct(__new_finish, __x);
                ++__new_finish;
                __new_finish = uninitialized_copy(__position, _M_finish, __new_finish);
            }
            catch (...) {
                destroy(__new_start, __new_finish);
                _M_deallocate(__new_start, __len);
                throw;
            }
            destroy(begin(), end());
            _M_deallocate(_M_start, _M_end_of_storage - _M_start);
            _M_start = __new_start;
            _M_finish = __new_finish;
            _M_end_of_storage = __new_start + __len;
        }
    }

    template<class _Tp, class _Alloc>
    void vector<_Tp, _Alloc>::_M_insert_aux(iterator __position) {
        if (_M_finish != _M_end_of_storage) {
            construct(_M_finish, *(_M_finish - 1));
            ++_M_finish;
            copy_backward(__position, _M_finish - 2, _M_finish - 1);
            *__position = _Tp();
        } else {
            const size_type __old_size = size();
            const size_type __len = __old_size != 0 ? 2 * __old_size : 1;
            iterator __new_start = _M_allocate(__len);
            iterator __new_finish = __new_start;
            try {
                __new_finish = uninitialized_copy(_M_start, __position, __new_start);
                construct(__new_finish);
                ++__new_finish;
                __new_finish = uninitialized_copy(__position, _M_finish, __new_finish);
            }
            catch (...) {
                destroy(__new_start, __new_finish);
                _M_deallocate(__new_start, __len);
                throw;
            }
            destroy(begin(), end());
            _M_deallocate(_M_start, _M_end_of_storage - _M_start);
            _M_start = __new_start;
            _M_finish = __new_finish;
            _M_end_of_storage = __new_start + __len;
        }
    }

    template<class _Tp, class _Alloc>
    void vector<_Tp, _Alloc>::_M_fill_insert(iterator __position, size_type __n,
                                             const _Tp &__x) {
        if (__n != 0) {
            //剩余空间足够，无需重新开辟
            if (size_type(_M_end_of_storage - _M_finish) >= __n) {
                _Tp __x_copy = __x;
                const size_type __elems_after = _M_finish - __position;
                iterator __old_finish = _M_finish;
                if (__elems_after > __n) {
                    uninitialized_copy(_M_finish - __n, _M_finish, _M_finish);
                    _M_finish += __n;
                    copy_backward(__position, __old_finish - __n, __old_finish);
                    fill(__position, __position + __n, __x_copy);
                } else {
                    uninitialized_fill_n(_M_finish, __n - __elems_after, __x_copy);
                    _M_finish += __n - __elems_after;
                    uninitialized_copy(__position, __old_finish, _M_finish);
                    _M_finish += __elems_after;
                    fill(__position, __old_finish, __x_copy);
                }
            } else {
                const size_type __old_size = size();
                const size_type __len = __old_size + max(__old_size, __n);
                iterator __new_start = _M_allocate(__len);
                iterator __new_finish = __new_start;
                try {
                    __new_finish = uninitialized_copy(_M_start, __position, __new_start);
                    __new_finish = uninitialized_fill_n(__new_finish, __n, __x);
                    __new_finish = uninitialized_copy(__position, _M_finish, __new_finish);
                }
                catch (...) {
                    destroy(__new_start, __new_finish);
                    _M_deallocate(__new_start, __len);
                    throw;
                }
                destroy(_M_start, _M_finish);
                _M_deallocate(_M_start, _M_end_of_storage - _M_start);
                _M_start = __new_start;
                _M_finish = __new_finish;
                _M_end_of_storage = __new_finish + __len;
            }
        }
    }

    template<class _Tp, class _Alloc>
    template<class _InputIterator>
    void vector<_Tp, _Alloc>::_M_range_insert(iterator __pos,
                                              _InputIterator __first,
                                              _InputIterator __last,
                                              input_iterator_tag) {
        for (; __first != __last; ++__first) {
            __pos = insert(__pos, *__first);
            ++__pos;
        }
    }

    template<class _Tp, class _Alloc>
    template<class _ForwardIterator>
    void vector<_Tp, _Alloc>::_M_range_insert(iterator __position,
                                              _ForwardIterator __first,
                                              _ForwardIterator __last,
                                              forward_iterator_tag) {
        if (__first != __last) {
            size_type __n = 0;
            distance(__first, __last, __n);
            if (size_type(_M_end_of_storage - _M_finish) >= __n) {
                const size_type __elems_after = _M_finish - __position;
                iterator __old_finish = _M_finish;
                if (__elems_after > __n) {
                    uninitialized_copy(_M_finish - __n, _M_finish, _M_finish);
                    _M_finish += __n;
                    copy_backward(__position, __old_finish - __n, __old_finish);
                    copy(__first, __last, __position);
                } else {
                    _ForwardIterator __mid = __first;
                    advance(__mid, __elems_after);
                    uninitialized_copy(__mid, __last, _M_finish);
                    _M_finish += __n - __elems_after;
                    uninitialized_copy(__position, __old_finish, _M_finish);
                    _M_finish += __elems_after;
                    copy(__first, __mid, __position);
                }
            } else {
                const size_type __old_size = size();
                const size_type __len = __old_size + max(__old_size, __n);
                iterator __new_start = _M_allocate(__len);
                iterator __new_finish = __new_start;
                try {
                    __new_finish = uninitialized_copy(_M_start, __position, __new_start);
                    __new_finish = uninitialized_copy(__first, __last, __new_finish);
                    __new_finish = uninitialized_copy(__position, _M_finish, __new_finish);
                }
                catch (...) {
                    destroy(__new_start, __new_finish);
                    _M_deallocate(__new_start, __len);
                    throw;
                }
                destroy(_M_start, _M_finish);
                _M_deallocate(_M_start, _M_end_of_storage - _M_start);
                _M_start = __new_start;
                _M_finish = __new_finish;
                _M_end_of_storage = __new_start + __len;
            }
        }
    }
```

### vector的操作符重载

```
//判断容器是否相等，即大小和内部的元素是否相同
template<class _Tp, class _Alloc>
inline bool operator==(const vector<_Tp, _Alloc> &__x, const vector<_Tp, _Alloc> &__y) {
    return __x.size() == __y.size() && equal(__x.begin(), __x.end(), __y.begin());
}
//比大小则两个内部的元素的大小相比
template<class _Tp, class _Alloc>
inline bool operator<(const vector<_Tp, _Alloc> &__x, const vector<_Tp, _Alloc> &__y) {
    return lexicographical_compare(__x.begin(), __x.end(), __y.begin(), __y.end());
}
//重载赋值操作，先判断两个容器的迭代器是否是一样的，然后判断两个迭代器的容量以及大小，来做出不同的操作
template<class _Tp, class _Alloc>
vector<_Tp, _Alloc> &
vector<_Tp, _Alloc>::operator=(const vector<_Tp, _Alloc> &__x) {
    if (this != &__x) {
        const size_type __xlen = __x.size();
        if (__xlen > capacity()) {
            iterator __tmp = _M_allocate_and_copy(__xlen, __x.begin(), __x.end());
            destroy(_M_start, _M_finish);
            destroy(_M_start, _M_finish);
            _M_deallocate(_M_start, _M_end_of_storage - _M_start);
            _M_start = __tmp;
            _M_end_of_storage = _M_start + __xlen;
        } else if (__xlen <= size()) {
            iterator __i = copy(__x.begin(), __x.end(), begin());
            destroy(__i, _M_finish);
        } else {
            //size()<__xlen<=capacity()
            copy(__x.begin(), __x.begin() + size(), _M_start);
            uninitialized_copy(__x.begin() + size(), __x.end(), _M_finish);
        }
        _M_finish = _M_start + __xlen;
    }
    return *this;
}
```

## 算法

stl_algobase.h这个头文件中的算法是基本算法，包括equal，fill，fill_n，swap，iter_swap，lexicographical_compare，max，min，mismatch，copy，copy_backward。

equal：

```
//第一版本，缺省采用元素型别所提供的equality操作符来进行大小比较
template <class _InputIter1, class _InputIter2>
inline bool equal(_InputIter1 __first1, _InputIter1 __last1,
	_InputIter2 __first2) {
	for (; __first1 != __last1; ++__first1, ++__first2)
		if (*__first1 != *__first2)
			return false;
	return true;
}
//第二版本，允许我们使用仿函数pred作为比较依据
template <class _InputIter1, class _InputIter2, class _BinaryPredicate>
inline bool equal(_InputIter1 __first1, _InputIter1 __last1,
	_InputIter2 __first2, _BinaryPredicate __binary_pred) {
	for (; __first1 != __last1; ++__first1, ++__first2)
		if (!__binary_pred(*__first1, *__first2))
			return false;
	return true;
}
```

fill：

```
//这个就是很简单了，从头遍历到尾，然后把value赋值进去，就完成了操作
template <class _ForwardIter, class _Tp>
void fill(_ForwardIter __first, _ForwardIter __last, const _Tp& __value) {
	for (; __first != __last; ++__first)
		* __first = __value;
}
//针对传进来的是字符型的指针得话，提供以下的偏特化版本，为了效率直接调用memset
inline void fill(unsigned char* __first, unsigned char* __last,
	const unsigned char& __c) {
	unsigned char __tmp = __c;
	memset(__first, __tmp, __last - __first);
}

inline void fill(signed char* __first, signed char* __last,
	const signed char& __c) {
	signed char __tmp = __c;
	memset(__first, static_cast<unsigned char>(__tmp), __last - __first);
}

inline void fill(char* __first, char* __last, const char& __c) {
	char __tmp = __c;
	memset(__first, static_cast<unsigned char>(__tmp), __last - __first);
}


```

fill_n：

```
//从头开始遍历，一直遍历n个，然后填充value
template <class _OutputIter, class _Size, class _Tp>
_OutputIter fill_n(_OutputIter __first, _Size __n, const _Tp& __value) {
	for (; __n > 0; --__n, ++__first)
		* __first = __value;
	return __first;
}
```

swap：

```
//这个很简单直接就能看出来，是交换
template <class _Tp>
inline void swap(_Tp& __a, _Tp& __b) {
	_Tp __tmp = __a;
	__a = __b;
	__b = __tmp;
}
```

iter_swap：

```
//这个是针对指针的swap，是指针的话，就交换指的内容
template <class _ForwardIter1, class _ForwardIter2, class _Tp>
inline void __iter_swap(_ForwardIter1 __a, _ForwardIter2 __b, _Tp*) {
	_Tp __tmp = *__a;
	*__a = *__b;
	*__b = __tmp;
}
//接口
template <class _ForwardIter1, class _ForwardIter2>
inline void iter_swap(_ForwardIter1 __a, _ForwardIter2 __b) {
	__iter_swap(__a, __b, __VALUE_TYPE(__a));
}
```

lexicographical_compare：

```
//循环遍历，一一比较第一序列和第二序列的元素值，如果说可以进行到最后的return，就证明第一或第二序列头到尾与另一个序列里的元素全部相等，最后的返回值是看两个序列是否到达队尾，如果第一序列到达队尾，然后第二队列没有到达，就证明第一序列小于第二队列。反之同理
template <class _InputIter1, class _InputIter2>
bool lexicographical_compare(_InputIter1 __first1, _InputIter1 __last1,
	_InputIter2 __first2, _InputIter2 __last2) {
	for (; __first1 != __last1 && __first2 != __last2
		; ++__first1, ++__first2) {
		if (*__first1 < *__first2)
			return true;
		if (*__first2 < *__first1)
			return false;
	}
	return __first1 == __last1 && __first2 != __last2;
}
//这是第二版本，允许使用仿函数comp来取代<操作符
template <class _InputIter1, class _InputIter2, class _Compare>
bool lexicographical_compare(_InputIter1 __first1, _InputIter1 __last1,
	_InputIter2 __first2, _InputIter2 __last2,
	_Compare __comp) {
	for (; __first1 != __last1 && __first2 != __last2
		; ++__first1, ++__first2) {
		if (__comp(*__first1, *__first2))
			return true;
		if (__comp(*__first2, *__first1))
			return false;
	}
	return __first1 == __last1 && __first2 != __last2;
}
//针对原生指针的特化版，其中使用了更具效率的memcmp，其中先比较了以下len1和len2，然后比较min出来的这块长度中的元素，如果比较出来的是0，则再判断len1和len2这块说白了起始就是如果result返回0则说明第一序列和第二序列相等
inline bool
lexicographical_compare(const unsigned char* __first1,
	const unsigned char* __last1,
	const unsigned char* __first2,
	const unsigned char* __last2)
{
	const size_t __len1 = __last1 - __first1;
	const size_t __len2 = __last2 - __first2;
	const int __result = memcmp(__first1, __first2, min(__len1, __len2));
	return __result != 0 ? __result < 0 : __len1 < __len2;
}
//针对有符号型的特化版本
inline bool lexicographical_compare(const char* __first1, const char* __last1,
	const char* __first2, const char* __last2)
{
	return lexicographical_compare((const signed char*)__first1,
		(const signed char*)__last1,
		(const signed char*)__first2,
		(const signed char*)__last2);
}
```

max和min：

```
//第一版本，这就很简单，直接条件运算符判断就行了
template <class _Tp>
inline const _Tp& min(const _Tp& __a, const _Tp& __b) {
	return __b < __a ? __b : __a;
}
//第一版本，同上
template <class _Tp>
inline const _Tp& max(const _Tp& __a, const _Tp& __b) {
	return  __a < __b ? __b : __a;
}
//第二版本，使用仿函数替代操作符<
template <class _Tp, class _Compare>
inline const _Tp& min(const _Tp& __a, const _Tp& __b, _Compare __comp) {
	return __comp(__b, __a) ? __b : __a;
}
//第二版本，同上
template <class _Tp, class _Compare>
inline const _Tp& max(const _Tp& __a, const _Tp& __b, _Compare __comp) {
	return __comp(__a, __b) ? __b : __a;
}
```

mismatch：

```
//第一版本，平行比较两个序列，返回第一个不相同的点在哪
template <class _InputIter1, class _InputIter2>
pair<_InputIter1, _InputIter2> mismatch(_InputIter1 __first1,
	_InputIter1 __last1,
	_InputIter2 __first2) {
	while (__first1 != __last1 && *__first1 == *__first2) {
		++__first1;
		++__first2;
	}
	return pair<_InputIter1, _InputIter2>(__first1, __first2);
}
//第二版本，使用仿函数替代==操作符
template <class _InputIter1, class _InputIter2, class _BinaryPredicate>
pair<_InputIter1, _InputIter2> mismatch(_InputIter1 __first1,
	_InputIter1 __last1,
	_InputIter2 __first2,
	_BinaryPredicate __binary_pred) {
	while (__first1 != __last1 && __binary_pred(*__first1, *__first2)) {
		++__first1;
		++__first2;
	}
	return pair<_InputIter1, _InputIter2>(__first1, __first2);
}
```

copy和copy_backward：

```
template <class _InputIter, class _OutputIter, class _Distance>
inline _OutputIter __copy(_InputIter __first, _InputIter __last,
                          _OutputIter __result,
                          input_iterator_tag, _Distance*)
{
  for ( ; __first != __last; ++__result, ++__first)
    *__result = *__first;
  return __result;
}

template <class _RandomAccessIter, class _OutputIter, class _Distance>
inline _OutputIter
__copy(_RandomAccessIter __first, _RandomAccessIter __last,
       _OutputIter __result, random_access_iterator_tag, _Distance*)
{
  for (_Distance __n = __last - __first; __n > 0; --__n) {
    *__result = *__first;
    ++__first;
    ++__result;
  }
  return __result;
}

template <class _Tp>
inline _Tp*
__copy_trivial(const _Tp* __first, const _Tp* __last, _Tp* __result) {
  memmove(__result, __first, sizeof(_Tp) * (__last - __first));
  return __result + (__last - __first);
}

#if defined(__STL_FUNCTION_TMPL_PARTIAL_ORDER)

template <class _InputIter, class _OutputIter>
inline _OutputIter __copy_aux2(_InputIter __first, _InputIter __last,
                               _OutputIter __result, __false_type) {
  return __copy(__first, __last, __result,
                __ITERATOR_CATEGORY(__first),
                __DISTANCE_TYPE(__first));
}

template <class _InputIter, class _OutputIter>
inline _OutputIter __copy_aux2(_InputIter __first, _InputIter __last,
                               _OutputIter __result, __true_type) {
  return __copy(__first, __last, __result,
                __ITERATOR_CATEGORY(__first),
                __DISTANCE_TYPE(__first));
}

#ifndef __USLC__

template <class _Tp>
inline _Tp* __copy_aux2(_Tp* __first, _Tp* __last, _Tp* __result,
                        __true_type) {
  return __copy_trivial(__first, __last, __result);
}

#endif /* __USLC__ */

template <class _Tp>
inline _Tp* __copy_aux2(const _Tp* __first, const _Tp* __last, _Tp* __result,
                        __true_type) {
  return __copy_trivial(__first, __last, __result);
}


template <class _InputIter, class _OutputIter, class _Tp>
inline _OutputIter __copy_aux(_InputIter __first, _InputIter __last,
                              _OutputIter __result, _Tp*) {
  typedef typename __type_traits<_Tp>::has_trivial_assignment_operator
          _Trivial;
  return __copy_aux2(__first, __last, __result, _Trivial());
}

template <class _InputIter, class _OutputIter>
inline _OutputIter copy(_InputIter __first, _InputIter __last,
                        _OutputIter __result) {
  __STL_REQUIRES(_InputIter, _InputIterator);
  __STL_REQUIRES(_OutputIter, _OutputIterator);
  return __copy_aux(__first, __last, __result, __VALUE_TYPE(__first));
}

// Hack for compilers that don't have partial ordering of function templates
// but do have partial specialization of class templates.
#elif defined(__STL_CLASS_PARTIAL_SPECIALIZATION)

template <class _InputIter, class _OutputIter, class _BoolType>
struct __copy_dispatch {
  static _OutputIter copy(_InputIter __first, _InputIter __last,
                          _OutputIter __result) {
    typedef typename iterator_traits<_InputIter>::iterator_category _Category;
    typedef typename iterator_traits<_InputIter>::difference_type _Distance;
    return __copy(__first, __last, __result, _Category(), (_Distance*) 0);
  }
};

template <class _Tp>
struct __copy_dispatch<_Tp*, _Tp*, __true_type>
{
  static _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) {
    return __copy_trivial(__first, __last, __result);
  }
};

template <class _Tp>
struct __copy_dispatch<const _Tp*, _Tp*, __true_type>
{
  static _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) {
    return __copy_trivial(__first, __last, __result);
  }
};

template <class _InputIter, class _OutputIter>
inline _OutputIter copy(_InputIter __first, _InputIter __last,
                        _OutputIter __result) {
  __STL_REQUIRES(_InputIter, _InputIterator);
  __STL_REQUIRES(_OutputIter, _OutputIterator);
  typedef typename iterator_traits<_InputIter>::value_type _Tp;
  typedef typename __type_traits<_Tp>::has_trivial_assignment_operator
          _Trivial;
  return __copy_dispatch<_InputIter, _OutputIter, _Trivial>
    ::copy(__first, __last, __result);
}

// Fallback for compilers with neither partial ordering nor partial
// specialization.  Define the faster version for the basic builtin
// types.
#else /* __STL_CLASS_PARTIAL_SPECIALIZATION */

template <class _InputIter, class _OutputIter>
inline _OutputIter copy(_InputIter __first, _InputIter __last,
                        _OutputIter __result)
{
  return __copy(__first, __last, __result,
                __ITERATOR_CATEGORY(__first),
                __DISTANCE_TYPE(__first));
}

#define __SGI_STL_DECLARE_COPY_TRIVIAL(_Tp)                                \
  inline _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) { \
    memmove(__result, __first, sizeof(_Tp) * (__last - __first));          \
    return __result + (__last - __first);                                  \
  }

__SGI_STL_DECLARE_COPY_TRIVIAL(char)
__SGI_STL_DECLARE_COPY_TRIVIAL(signed char)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned char)
__SGI_STL_DECLARE_COPY_TRIVIAL(short)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned short)
__SGI_STL_DECLARE_COPY_TRIVIAL(int)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned int)
__SGI_STL_DECLARE_COPY_TRIVIAL(long)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned long)
#ifdef __STL_HAS_WCHAR_T
__SGI_STL_DECLARE_COPY_TRIVIAL(wchar_t)
#endif
#ifdef _STL_LONG_LONG
__SGI_STL_DECLARE_COPY_TRIVIAL(long long)
__SGI_STL_DECLARE_COPY_TRIVIAL(unsigned long long)
#endif 
__SGI_STL_DECLARE_COPY_TRIVIAL(float)
__SGI_STL_DECLARE_COPY_TRIVIAL(double)
__SGI_STL_DECLARE_COPY_TRIVIAL(long double)

#undef __SGI_STL_DECLARE_COPY_TRIVIAL
#endif /* __STL_CLASS_PARTIAL_SPECIALIZATION */

//--------------------------------------------------
// copy_backward

template <class _BidirectionalIter1, class _BidirectionalIter2, 
          class _Distance>
inline _BidirectionalIter2 __copy_backward(_BidirectionalIter1 __first, 
                                           _BidirectionalIter1 __last, 
                                           _BidirectionalIter2 __result,
                                           bidirectional_iterator_tag,
                                           _Distance*)
{
  while (__first != __last)
    *--__result = *--__last;
  return __result;
}

template <class _RandomAccessIter, class _BidirectionalIter, class _Distance>
inline _BidirectionalIter __copy_backward(_RandomAccessIter __first, 
                                          _RandomAccessIter __last, 
                                          _BidirectionalIter __result,
                                          random_access_iterator_tag,
                                          _Distance*)
{
  for (_Distance __n = __last - __first; __n > 0; --__n)
    *--__result = *--__last;
  return __result;
}

#ifdef __STL_CLASS_PARTIAL_SPECIALIZATION 

// This dispatch class is a workaround for compilers that do not 
// have partial ordering of function templates.  All we're doing is
// creating a specialization so that we can turn a call to copy_backward
// into a memmove whenever possible.

template <class _BidirectionalIter1, class _BidirectionalIter2,
          class _BoolType>
struct __copy_backward_dispatch
{
  typedef typename iterator_traits<_BidirectionalIter1>::iterator_category 
          _Cat;
  typedef typename iterator_traits<_BidirectionalIter1>::difference_type
          _Distance;

  static _BidirectionalIter2 copy(_BidirectionalIter1 __first, 
                                  _BidirectionalIter1 __last, 
                                  _BidirectionalIter2 __result) {
    return __copy_backward(__first, __last, __result, _Cat(), (_Distance*) 0);
  }
};

template <class _Tp>
struct __copy_backward_dispatch<_Tp*, _Tp*, __true_type>
{
  static _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) {
    const ptrdiff_t _Num = __last - __first;
    memmove(__result - _Num, __first, sizeof(_Tp) * _Num);
    return __result - _Num;
  }
};

template <class _Tp>
struct __copy_backward_dispatch<const _Tp*, _Tp*, __true_type>
{
  static _Tp* copy(const _Tp* __first, const _Tp* __last, _Tp* __result) {
    return  __copy_backward_dispatch<_Tp*, _Tp*, __true_type>
      ::copy(__first, __last, __result);
  }
};

template <class _BI1, class _BI2>
inline _BI2 copy_backward(_BI1 __first, _BI1 __last, _BI2 __result) {
  __STL_REQUIRES(_BI1, _BidirectionalIterator);
  __STL_REQUIRES(_BI2, _Mutable_BidirectionalIterator);
  __STL_CONVERTIBLE(typename iterator_traits<_BI1>::value_type,
                    typename iterator_traits<_BI2>::value_type);
  typedef typename __type_traits<typename iterator_traits<_BI2>::value_type>
                        ::has_trivial_assignment_operator
          _Trivial;
  return __copy_backward_dispatch<_BI1, _BI2, _Trivial>
              ::copy(__first, __last, __result);
}

#else /* __STL_CLASS_PARTIAL_SPECIALIZATION */

template <class _BI1, class _BI2>
inline _BI2 copy_backward(_BI1 __first, _BI1 __last, _BI2 __result) {
  return __copy_backward(__first, __last, __result,
                         __ITERATOR_CATEGORY(__first),
                         __DISTANCE_TYPE(__first));
}

#endif /* __STL_CLASS_PARTIAL_SPECIALIZATION */

//--------------------------------------------------
// copy_n (not part of the C++ standard)

template <class _InputIter, class _Size, class _OutputIter>
pair<_InputIter, _OutputIter> __copy_n(_InputIter __first, _Size __count,
                                       _OutputIter __result,
                                       input_iterator_tag) {
  for ( ; __count > 0; --__count) {
    *__result = *__first;
    ++__first;
    ++__result;
  }
  return pair<_InputIter, _OutputIter>(__first, __result);
}

template <class _RAIter, class _Size, class _OutputIter>
inline pair<_RAIter, _OutputIter>
__copy_n(_RAIter __first, _Size __count,
         _OutputIter __result,
         random_access_iterator_tag) {
  _RAIter __last = __first + __count;
  return pair<_RAIter, _OutputIter>(__last, copy(__first, __last, __result));
}

template <class _InputIter, class _Size, class _OutputIter>
inline pair<_InputIter, _OutputIter>
__copy_n(_InputIter __first, _Size __count, _OutputIter __result) {
  return __copy_n(__first, __count, __result,
                  __ITERATOR_CATEGORY(__first));
}

template <class _InputIter, class _Size, class _OutputIter>
inline pair<_InputIter, _OutputIter>
copy_n(_InputIter __first, _Size __count, _OutputIter __result) {
  __STL_REQUIRES(_InputIter, _InputIterator);
  __STL_REQUIRES(_OutputIter, _OutputIterator);
  return __copy_n(__first, __count, __result);
}
```

这个copy和copy_backward很长还没有分析完，不过copy和copy_backward都是采用极致的效率进行复制的。下面的图可以简单理解下，个人理解它之所以效率特别高，主要是因为它没有构造的操作，而是直接对已存在的内存进行移动，少去了创建空间的步骤，所以效率就会快。

需要注意的是copy采用的是遍历区间一个一个赋值的方法，来赋值的，如果说使用copy的时候有区间覆盖的话，就会得出不一样的错误结果。所以这条更可以确定copy是对已经创建出来的内存空间进行操作。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-11_13-34-12.png)

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-11_13-37-45.png)
   


