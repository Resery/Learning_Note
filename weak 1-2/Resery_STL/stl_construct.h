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
