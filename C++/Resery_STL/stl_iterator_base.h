#pragma once

#include <cstddef>
#include "stl_config.h"

__STL_BEGIN_NAMESPACE
//--------------------------------------------------------------------------
//型别
struct input_iterator_tag {};
struct output_iterator_tag {};
struct forward_iterator_tag : public input_iterator_tag {};
struct bidirectional_iterator_tag : public forward_iterator_tag {};
struct random_access_iterator_tag : public bidirectional_iterator_tag {};\

//--------------------------------------------------------------------------
//tratis
template <class Category, class T, class Distance = ptrdiff_t, 
		  class Pointer = T*, class Reference = T&>
struct iterator{
	typedef Category 	iterator_category;
	typedef T 			value_type;
	typedef Distance 	difference_type;
	typedef Pointer 	pointer;
	typedef Reference 	reference;
};


template <class _Iterator>
struct iterator_traits {
	typedef typename _Iterator::iterator_category iterator_category;
	typedef typename _Iterator::value_type        value_type;
	typedef typename _Iterator::difference_type   difference_type;
	typedef typename _Iterator::pointer           pointer;
	typedef typename _Iterator::reference         reference;
};

//原生指针特化版
template <class _Tp>
struct iterator_traits<_Tp*> {
	typedef random_access_iterator_tag iterator_category;
	typedef _Tp                         value_type;
	typedef ptrdiff_t                   difference_type;
	typedef _Tp* 						pointer;
	typedef _Tp& 						reference;
};

//const原生指针特化版
template <class _Tp>
struct iterator_traits<const _Tp*> {
	typedef random_access_iterator_tag iterator_category;
	typedef _Tp                         value_type;
	typedef ptrdiff_t                   difference_type;
	typedef const _Tp* 					pointer;
	typedef const _Tp& 					reference;
};

template <class _Iterator>
inline typename iterator_traits<_Iterator>::iterator_category
__iterator_category(const _Iterator&){
	typedef typename iterator_traits<_Iterator>::iterator_category category;
	return category();
}

template <class _Iterator>
inline typename iterator_traits<_Iterator>::difference_type*
__distance_type(const _Iterator&){
	return static_cast<typename iterator_traits<_Iterator>::difference_type*>(0);
}

template <class _Iterator>
inline typename iterator_traits<_Iterator>::value_type*
__value_type(const _Iterator&){
	return static_cast<typename iterator_traits<_Iterator>::value_type*>(0);
}
//make sure iterator_category
template <class _Iterator>
inline typename iterator_traits<_Iterator>::iterator_category
iterator_category(const _Iterator& __i) 
{ 
	return __iterator_category(__i); 
}
//make sure difference_type
template <class _Iterator>
inline typename iterator_traits<_Iterator>::difference_type*
distance_type(const _Iterator& __i) 
{ 
	return __distance_type(__i); 
}
//make sure value_type
template <class _Iterator>
inline typename iterator_traits<_Iterator>::value_type*
value_type(const _Iterator& __i) 
{ 
	return __value_type(__i); 
}

//--------------------------------------------------------------------------
//distance

template<class _Inputiterator, class _Distance>
inline void __distance(_Inputiterator first, _Inputiterator last, _Distance &n, input_iterator_tag) {
    while (first != last) {
        ++first;
        ++n;
    }
}

template<class _Inputiterator, class _Distance>
inline void __distance(_Inputiterator first, _Inputiterator last, _Distance &n,
                       random_access_iterator_tag) {
    n += last - first;
}

template<class _Inputiterator, class _Distance>
inline void distance(_Inputiterator first, _Inputiterator last, _Distance &n) {
    __distance(first, last, n, iterator_category(first));
}

#ifdef __STL_CLASS_PARTIAL_SPECIALIZATION

template <class _Inputiterator>
inline typename iterator_traits<_Inputiterator>::difference_type
__distance(_Inputiterator first,_Inputiterator last,input_iterator_tag()){
	typename iterator_traits<_Inputiterator>::difference_type n = 0;
	while(first!=last)
		++first; ++n;
	return n;
}

template <class _Inputiterator>
inline typename iterator_traits<_Inputiterator>::difference_type
__distance(_Inputiterator first,_Inputiterator last,random_access_iterator_tag()){
	typename iterator_traits<_Inputiterator>::difference_type n = 0;
	return last-first;
}

template <class _Inputiterator>
inline typename iterator_traits<_Inputiterator>::iterator_category
distance(_Inputiterator first,_Inputiterator last){
	typedef typename iterator_traits<_Inputiterator>::iterator_category category;
	return __distance(first,last,category());
}

#endif /* __STL_CLASS_PARTIAL_SPECIALIZATION */

//--------------------------------------------------------------------------
//advance

template<class _Inputiterator, class _Distance>
inline void __advance(_Inputiterator &__i, _Distance __n, input_iterator_tag) {
    while (__n--) {
        ++__i;
    }
}

template<class _BidirectionalIterator, class _Distance>
inline void __advance(_BidirectionalIterator &__i, _Distance __n, bidirectional_iterator_tag) {
    if (__n > 0) {
        while (__n--) {
            ++__i;
        }
    } else {
        while (__n++) {
            --__i;
        }
    }
}

template<class _RandomAccessIterator, class _Distance>
inline void __advance(_RandomAccessIterator &__i, _Distance __n, random_access_iterator_tag) {
    __i += __n;
}

template<class _Inputiterator, class _Distance>
inline void advance(_Inputiterator &__i, _Distance __n) {
    __advance(__i, __n, __iterator_category(__i));
}

__STL_END_NAMESPACE
