#ifndef Resery_STL_STL_ALLOC_H
#define Resery_STL_STL_ALLOC_H

#include <cstddef>
#include <cstdlib>
#include <cstdio>
#include <iostream>
#include "stl_config.h"
#include "stl_construct.h"

__STL_BEGIN_NAMESPACE
/*__malloc_alloc_template 是 SGI STL的第一级配置器,
只是对系统的malloc，realloc，free函数的一个简单封装，并考虑到了分配失败后的异常处理
*/
//这里去除了上面用户自定义的异常处理函数,全部改为系统默认的输出一条错误信息。
template <int __inst>  //这是一个非类型模板，相关知识在另一篇博客C++ 学习笔记中
class __malloc_alloc_template {
public:
	//分配内存,除了异常处理改成了默认以外其余和SGI_STL一致
	static void* allocate(size_t __n)
	{
		void* __result = malloc(__n);
		if (0 == __result) {
			fprintf(stderr, "out of memory\n");
			exit(1);
		}
		return __result;
	}
	//释放内存和SGI_STL一致
	static void deallocate(void* __p, size_t /* __n */)
	{
		free(__p);
	}
	//重新分配内存,除了异常处理改成了默认以外其余和SGI_STL一致
	static void* reallocate(void* __p, size_t /* old_sz */, size_t __new_sz)
	{
		void* __result = realloc(__p, __new_sz);
		if (0 == __result) {
			fprintf(stderr, "out of memory\n");
			exit(1);
		}
		return __result;
	}
};

typedef __malloc_alloc_template<0> malloc_alloc;


//把上面的第一或第二级配置器封装起来，但是我的这里面只有第一级配置器，其内部的四个成员函数也是在调用第一级配置器对应的成员函数，还有一个作用是把bytes转换成个别元素的大小(sizeof(_Tp))
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

__STL_END_NAMESPACE
