#pragma once
#include "stl_config.h"
#include "stl_construct.h"
#include "stl_iterator.h"
#include "stl_algo.h"
#include <cstring>

__STL_BEGIN_NAMESPACE

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
inline wchar_t*
uninitialized_copy(const wchar_t* __first, const wchar_t* __last,
	wchar_t* __result)
{
	memmove(__result, __first, sizeof(wchar_t) * (__last - __first));
	return __result + (__last - __first);
}

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

__STL_END_NAMESPACE
