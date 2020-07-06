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
