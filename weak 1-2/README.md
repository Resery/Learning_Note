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

   


