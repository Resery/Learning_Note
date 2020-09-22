#pragma once
#include "type_traits.h"
#include "stl_iterator_base.h"

__STL_BEGIN_NAMESPACE

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
__STL_END_NAMESPACE