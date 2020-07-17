#pragma once

#include "stl_alloc.h"
#include "stl_algobase.h"
#include "stl_construct.h"
#include "stl_config.h"
#include "stl_iterator.h"
#include "stl_pair.h"

__STL_BEGIN_NAMESPACE

typedef bool _Rb_tree_Color_type;
const _Rb_tree_Color_type _S_rb_tree_red = false;	//红为0
const _Rb_tree_Color_type _S_rb_tree_black = true;	//黑为1

struct _Rb_tree_node_base
{
    typedef _Rb_tree_Color_type _Color_type;
    typedef _Rb_tree_node_base* _Base_ptr;

    _Color_type _M_color;		//黑或红 
    _Base_ptr _M_parent;		//指向该节点的父结点
    _Base_ptr _M_left;		//指向该节点的左子结点	
    _Base_ptr _M_right;		//指向该节点的右子结点
    //求红黑树中最小的值，很简单就是判断该结点是否有左子结点，如果有就走到下一个左子结点，然后继续判断，当没有左子结点的时候
    //这个结点的值就是最小的值，由红黑树性质得到
    static _Base_ptr _S_minimum(_Base_ptr __x)
    {
        while (__x->_M_left != 0) __x = __x->_M_left;
        return __x;
    }
    //求红黑树中最大的值，很简单就是判断该结点是否有右子结点，如果有就走到下一个右子结点，然后继续判断，当没有右子结点的时候
    //这个结点的值就是最大的值，由红黑树性质得到
    static _Base_ptr _S_maximum(_Base_ptr __x)
    {
        while (__x->_M_right != 0) __x = __x->_M_right;
        return __x;
    }
};

template <class _Value>
struct _Rb_tree_node : public _Rb_tree_node_base
{
    typedef _Rb_tree_node<_Value>* _Link_type;
    _Value _M_value_field;		//结点的值
};
//
struct _Rb_tree_base_iterator
{
    typedef _Rb_tree_node_base::_Base_ptr _Base_ptr;        //指向结点的指针
    typedef bidirectional_iterator_tag iterator_category;   //类型，双向迭代器
    typedef ptrdiff_t difference_type;                      //距离
    _Base_ptr _M_node;
    
    void _M_increment()
    {
        //如果这个结点含有右子结点，则走到下一个右子结点，然后判断走到的下一个有结点有没有左子结点，如果有则走到下一个左子结点然后继续循环做这个操作，如果没有则不做操作
        //如果这个结点不含有右子结点，检测该结点是否是其父结点的右子结点，如果是的话则走到他的父节点然后继续循环做这个操作，如果说该结点不是其父结点的右子结点则不做操作，
        //然后判断该结点的右子结点是不是父节点，如果不是则走到父节点。
        if (_M_node->_M_right != 0) {
            _M_node = _M_node->_M_right;
            while (_M_node->_M_left != 0)
                _M_node = _M_node->_M_left;
        }
        else {
            _Base_ptr __y = _M_node->_M_parent;
            while (_M_node == __y->_M_right) {
                _M_node = __y;
                __y = __y->_M_parent;
            }
            //这一步是为了应付一种特殊情况，即我们想寻找根节点的下一节点，而此时恰巧根节点没有右子结点，当然这个操作必须配合RB-tree根节点与特殊之header之间的特殊关系  
            if (_M_node->_M_right != __y)
                _M_node = __y;
        }
    }

    void _M_decrement()
    {
        //先判断是不是红色，然后判断该结点的父结点的父结点是不是该结点，如果前述两个条件满足则走到该结点的右子结点
        //这个情况是对应与该结点是header的时候（也就是节点为end()的时候）
        if (_M_node->_M_color == _S_rb_tree_red &&
            _M_node->_M_parent->_M_parent == _M_node)
            _M_node = _M_node->_M_right;
        //判断该结点是否含有左子结点，如果含有则再判断该结点的左子结点是否含有右子节点，如果有则走到下一个右子结点然后循环这个操作直到走到的结点没有右子结点为止
        else if (_M_node->_M_left != 0) {
            _Base_ptr __y = _M_node->_M_left;
            while (__y->_M_right != 0)
                __y = __y->_M_right;
            _M_node = __y;
        }
        //判断该结点是不是其父结点的左子结点，如果是则走到父结点然后循环前面的操作，直到该节点不是其父结点的左子结点
        else {
            _Base_ptr __y = _M_node->_M_parent;
            while (_M_node == __y->_M_left) {
                _M_node = __y;
                __y = __y->_M_parent;
            }
            _M_node = __y;
        }
    }
};

template <class _Value, class _Ref, class _Ptr>
struct _Rb_tree_iterator : public _Rb_tree_base_iterator
{
    typedef _Value value_type;
    typedef _Ref reference;
    typedef _Ptr pointer;
    typedef _Rb_tree_iterator<_Value, _Value&, _Value*>
        iterator;
    typedef _Rb_tree_iterator<_Value, const _Value&, const _Value*>
        const_iterator;
    typedef _Rb_tree_iterator<_Value, _Ref, _Ptr>
        _Self;
    typedef _Rb_tree_node<_Value>* _Link_type;
    //构造函数
    _Rb_tree_iterator() {}
    _Rb_tree_iterator(_Link_type __x) { _M_node = __x; }
    //拷贝构造函数
    _Rb_tree_iterator(const iterator& __it) { _M_node = __it._M_node; }
    //重载*和&操作符
    reference operator*() const { return _Link_type(_M_node)->_M_value_field; }
    pointer operator->() const { return &(operator*()); }

    //重载++操作符，分别对应前置自增和后置自增，都是直接调用父类的_M_increment()函数
    _Self& operator++() { _M_increment(); return *this; }
    _Self operator++(int) {
        _Self __tmp = *this;
        _M_increment();
        return __tmp;
    }
    //重载--操作符，分别对应前置自减和后置自减，都是直接调用父类的_M_decrement()函数
    _Self& operator--() { _M_decrement(); return *this; }
    _Self operator--(int) {
        _Self __tmp = *this;
        _M_decrement();
        return __tmp;
    }
};
//重载==运算符，即检测x和y指向的是不是一个地方
inline bool operator==(const _Rb_tree_base_iterator& __x,
    const _Rb_tree_base_iterator& __y) {
    return __x._M_node == __y._M_node;
}
//重载!=运算符，即检测x和y指向的是不是一个地方
inline bool operator!=(const _Rb_tree_base_iterator& __x,
    const _Rb_tree_base_iterator& __y) {
    return __x._M_node != __y._M_node;
}

inline bidirectional_iterator_tag
iterator_category(const _Rb_tree_base_iterator&) {
    return bidirectional_iterator_tag();
}

inline _Rb_tree_base_iterator::difference_type*
distance_type(const _Rb_tree_base_iterator&) {
    return (_Rb_tree_base_iterator::difference_type*) 0;
}

template <class _Value, class _Ref, class _Ptr>
inline _Value* value_type(const _Rb_tree_iterator<_Value, _Ref, _Ptr>&) {
    return (_Value*)0;
}
//左旋转
//先把x的右子结点的左子结点赋给x的右子结点，然后判断x的右子结点的左子结点是不是为空，不为空则让x的右子结点的左子结点的父节点指向x
//然后让x的右子结点的父节点指向x的父节点，然后继续判断x与传进来的root是否相等，如果相等则直接让root指向x的右子结点
//然后在判断x的父节点的左子结点是否为x是的话就让x的父节点指向x的右子结点，前面两个条件都不满足的话就把x的右子结点赋给x的父节点的右子结点
//然后再把x赋给y的左子结点让y成为x的父节点
inline void
_Rb_tree_rotate_left(_Rb_tree_node_base* __x, _Rb_tree_node_base*& __root)
{
    _Rb_tree_node_base* __y = __x->_M_right;
    __x->_M_right = __y->_M_left;
    if (__y->_M_left != 0)
        __y->_M_left->_M_parent = __x;
    __y->_M_parent = __x->_M_parent;

    if (__x == __root)
        __root = __y;
    else if (__x == __x->_M_parent->_M_left)
        __x->_M_parent->_M_left = __y;
    else
        __x->_M_parent->_M_right = __y;
    __y->_M_left = __x;
    __x->_M_parent = __y;
}
//右旋转
inline void
_Rb_tree_rotate_right(_Rb_tree_node_base* __x, _Rb_tree_node_base*& __root)
{
    _Rb_tree_node_base* __y = __x->_M_left;
    __x->_M_left = __y->_M_right;
    if (__y->_M_right != 0)
        __y->_M_right->_M_parent = __x;
    __y->_M_parent = __x->_M_parent;

    if (__x == __root)
        __root = __y;
    else if (__x == __x->_M_parent->_M_right)
        __x->_M_parent->_M_right = __y;
    else
        __x->_M_parent->_M_left = __y;
    __y->_M_right = __x;
    __x->_M_parent = __y;
}
//调整颜色以及位置
//一个大循环先判断这个结点的父节点颜色是不是红结点，并且这个结点不是根节点，满足这个要求循环才能继续
//然后又是一个判断，判断一下x的父节点是不是与x的父节点的父节点的左子节点相同，然后再继续判断
//判断x的父节点的父节点的右子结点是不是红而且它存不存在，如果满足则，把它x的父节点和x的父节点的父节点的右子结点的颜色变成黑色，x的父节点的父节点的颜色变成红色，然后让x指向x的父节点的父节点
//然后假如不满足x的父节点的父节点的右子结点是不是红而且它存不存在中的任何一个，就检测x是不是其父节点的右子结点如果是则x指向其父节点然后调用_Rb_tree_rotate_left，调用结束之后，再改变颜色
//分别改变x的父节点的颜色与x的父节点的父节点的颜色，然后再调用一次_Rb_tree_rotate_right
//剩下的那个大块的else就是和上面做相反的操作，就不解释了
inline void
_Rb_tree_rebalance(_Rb_tree_node_base* __x, _Rb_tree_node_base*& __root)
{
    __x->_M_color = _S_rb_tree_red;
    while (__x != __root && __x->_M_parent->_M_color == _S_rb_tree_red) {
        if (__x->_M_parent == __x->_M_parent->_M_parent->_M_left) {
            _Rb_tree_node_base* __y = __x->_M_parent->_M_parent->_M_right;
            if (__y && __y->_M_color == _S_rb_tree_red) {
                __x->_M_parent->_M_color = _S_rb_tree_black;
                __y->_M_color = _S_rb_tree_black;
                __x->_M_parent->_M_parent->_M_color = _S_rb_tree_red;
                __x = __x->_M_parent->_M_parent;
            }
            else {
                if (__x == __x->_M_parent->_M_right) {
                    __x = __x->_M_parent;
                    _Rb_tree_rotate_left(__x, __root);
                }
                __x->_M_parent->_M_color = _S_rb_tree_black;
                __x->_M_parent->_M_parent->_M_color = _S_rb_tree_red;
                _Rb_tree_rotate_right(__x->_M_parent->_M_parent, __root);
            }
        }
        else {
            _Rb_tree_node_base* __y = __x->_M_parent->_M_parent->_M_left;
            if (__y && __y->_M_color == _S_rb_tree_red) {
                __x->_M_parent->_M_color = _S_rb_tree_black;
                __y->_M_color = _S_rb_tree_black;
                __x->_M_parent->_M_parent->_M_color = _S_rb_tree_red;
                __x = __x->_M_parent->_M_parent;
            }
            else {
                if (__x == __x->_M_parent->_M_left) {
                    __x = __x->_M_parent;
                    _Rb_tree_rotate_right(__x, __root);
                }
                __x->_M_parent->_M_color = _S_rb_tree_black;
                __x->_M_parent->_M_parent->_M_color = _S_rb_tree_red;
                _Rb_tree_rotate_left(__x->_M_parent->_M_parent, __root);
            }
        }
    }
    __root->_M_color = _S_rb_tree_black;
}

inline _Rb_tree_node_base*
_Rb_tree_rebalance_for_erase(_Rb_tree_node_base* __z,
    _Rb_tree_node_base*& __root,
    _Rb_tree_node_base*& __leftmost,
    _Rb_tree_node_base*& __rightmost)
{
    _Rb_tree_node_base* __y = __z;
    _Rb_tree_node_base* __x = 0;
    _Rb_tree_node_base* __x_parent = 0;
    if (__y->_M_left == 0)     // __z has at most one non-null child. y == z.
        __x = __y->_M_right;     // __x might be null.
    else
        if (__y->_M_right == 0)  // __z has exactly one non-null child. y == z.
            __x = __y->_M_left;    // __x is not null.
        else {                   // __z has two non-null children.  Set __y to
            __y = __y->_M_right;   //   __z's successor.  __x might be null.
            while (__y->_M_left != 0)
                __y = __y->_M_left;
            __x = __y->_M_right;
        }
    if (__y != __z) {          // relink y in place of z.  y is z's successor
        __z->_M_left->_M_parent = __y;
        __y->_M_left = __z->_M_left;
        if (__y != __z->_M_right) {
            __x_parent = __y->_M_parent;
            if (__x) __x->_M_parent = __y->_M_parent;
            __y->_M_parent->_M_left = __x;      // __y must be a child of _M_left
            __y->_M_right = __z->_M_right;
            __z->_M_right->_M_parent = __y;
        }
        else
            __x_parent = __y;
        if (__root == __z)
            __root = __y;
        else if (__z->_M_parent->_M_left == __z)
            __z->_M_parent->_M_left = __y;
        else
            __z->_M_parent->_M_right = __y;
        __y->_M_parent = __z->_M_parent;
        __STD::swap(__y->_M_color, __z->_M_color);
        __y = __z;
        // __y now points to node to be actually deleted
    }
    else {                        // __y == __z
        __x_parent = __y->_M_parent;
        if (__x) __x->_M_parent = __y->_M_parent;
        if (__root == __z)
            __root = __x;
        else
            if (__z->_M_parent->_M_left == __z)
                __z->_M_parent->_M_left = __x;
            else
                __z->_M_parent->_M_right = __x;
        if (__leftmost == __z)
            if (__z->_M_right == 0)        // __z->_M_left must be null also
                __leftmost = __z->_M_parent;
        // makes __leftmost == _M_header if __z == __root
            else
                __leftmost = _Rb_tree_node_base::_S_minimum(__x);
        if (__rightmost == __z)
            if (__z->_M_left == 0)         // __z->_M_right must be null also
                __rightmost = __z->_M_parent;
        // makes __rightmost == _M_header if __z == __root
            else                      // __x == __z->_M_left
                __rightmost = _Rb_tree_node_base::_S_maximum(__x);
    }
    if (__y->_M_color != _S_rb_tree_red) {
        while (__x != __root && (__x == 0 || __x->_M_color == _S_rb_tree_black))
            if (__x == __x_parent->_M_left) {
                _Rb_tree_node_base* __w = __x_parent->_M_right;
                if (__w->_M_color == _S_rb_tree_red) {
                    __w->_M_color = _S_rb_tree_black;
                    __x_parent->_M_color = _S_rb_tree_red;
                    _Rb_tree_rotate_left(__x_parent, __root);
                    __w = __x_parent->_M_right;
                }
                if ((__w->_M_left == 0 ||
                    __w->_M_left->_M_color == _S_rb_tree_black) &&
                    (__w->_M_right == 0 ||
                        __w->_M_right->_M_color == _S_rb_tree_black)) {
                    __w->_M_color = _S_rb_tree_red;
                    __x = __x_parent;
                    __x_parent = __x_parent->_M_parent;
                }
                else {
                    if (__w->_M_right == 0 ||
                        __w->_M_right->_M_color == _S_rb_tree_black) {
                        if (__w->_M_left) __w->_M_left->_M_color = _S_rb_tree_black;
                        __w->_M_color = _S_rb_tree_red;
                        _Rb_tree_rotate_right(__w, __root);
                        __w = __x_parent->_M_right;
                    }
                    __w->_M_color = __x_parent->_M_color;
                    __x_parent->_M_color = _S_rb_tree_black;
                    if (__w->_M_right) __w->_M_right->_M_color = _S_rb_tree_black;
                    _Rb_tree_rotate_left(__x_parent, __root);
                    break;
                }
            }
            else {                  // same as above, with _M_right <-> _M_left.
                _Rb_tree_node_base* __w = __x_parent->_M_left;
                if (__w->_M_color == _S_rb_tree_red) {
                    __w->_M_color = _S_rb_tree_black;
                    __x_parent->_M_color = _S_rb_tree_red;
                    _Rb_tree_rotate_right(__x_parent, __root);
                    __w = __x_parent->_M_left;
                }
                if ((__w->_M_right == 0 ||
                    __w->_M_right->_M_color == _S_rb_tree_black) &&
                    (__w->_M_left == 0 ||
                        __w->_M_left->_M_color == _S_rb_tree_black)) {
                    __w->_M_color = _S_rb_tree_red;
                    __x = __x_parent;
                    __x_parent = __x_parent->_M_parent;
                }
                else {
                    if (__w->_M_left == 0 ||
                        __w->_M_left->_M_color == _S_rb_tree_black) {
                        if (__w->_M_right) __w->_M_right->_M_color = _S_rb_tree_black;
                        __w->_M_color = _S_rb_tree_red;
                        _Rb_tree_rotate_left(__w, __root);
                        __w = __x_parent->_M_left;
                    }
                    __w->_M_color = __x_parent->_M_color;
                    __x_parent->_M_color = _S_rb_tree_black;
                    if (__w->_M_left) __w->_M_left->_M_color = _S_rb_tree_black;
                    _Rb_tree_rotate_right(__x_parent, __root);
                    break;
                }
            }
        if (__x) __x->_M_color = _S_rb_tree_black;
    }
    return __y;
}

// Base class to encapsulate the differences between old SGI-style
// allocators and standard-conforming allocators.  In order to avoid
// having an empty base class, we arbitrarily move one of rb_tree's
// data members into the base class.

#ifdef __STL_USE_STD_ALLOCATORS

// _Base for general standard-conforming allocators.
template <class _Tp, class _Alloc, bool _S_instanceless>
class _Rb_tree_alloc_base {
public:
    typedef typename _Alloc_traits<_Tp, _Alloc>::allocator_type allocator_type;
    allocator_type get_allocator() const { return _M_node_allocator; }

    _Rb_tree_alloc_base(const allocator_type& __a)
        : _M_node_allocator(__a), _M_header(0) {}

protected:
    typename _Alloc_traits<_Rb_tree_node<_Tp>, _Alloc>::allocator_type
        _M_node_allocator;
    _Rb_tree_node<_Tp>* _M_header;

    _Rb_tree_node<_Tp>* _M_get_node()
    {
        return _M_node_allocator.allocate(1);
    }
    void _M_put_node(_Rb_tree_node<_Tp>* __p)
    {
        _M_node_allocator.deallocate(__p, 1);
    }
};

// Specialization for instanceless allocators.
template <class _Tp, class _Alloc>
class _Rb_tree_alloc_base<_Tp, _Alloc, true> {
public:
    typedef typename _Alloc_traits<_Tp, _Alloc>::allocator_type allocator_type;
    allocator_type get_allocator() const { return allocator_type(); }

    _Rb_tree_alloc_base(const allocator_type&) : _M_header(0) {}

protected:
    _Rb_tree_node<_Tp>* _M_header;

    typedef typename _Alloc_traits<_Rb_tree_node<_Tp>, _Alloc>::_Alloc_type
        _Alloc_type;

    _Rb_tree_node<_Tp>* _M_get_node()
    {
        return _Alloc_type::allocate(1);
    }
    void _M_put_node(_Rb_tree_node<_Tp>* __p)
    {
        _Alloc_type::deallocate(__p, 1);
    }
};

template <class _Tp, class _Alloc>
struct _Rb_tree_base
    : public _Rb_tree_alloc_base<_Tp, _Alloc,
    _Alloc_traits<_Tp, _Alloc>::_S_instanceless>
{
    typedef _Rb_tree_alloc_base<_Tp, _Alloc,
        _Alloc_traits<_Tp, _Alloc>::_S_instanceless>
        _Base;
    typedef typename _Base::allocator_type allocator_type;

    _Rb_tree_base(const allocator_type& __a)
        : _Base(__a) {
        _M_header = _M_get_node();
    }
    ~_Rb_tree_base() { _M_put_node(_M_header); }

};

#else /* __STL_USE_STD_ALLOCATORS */

template <class _Tp, class _Alloc>
struct _Rb_tree_base
{
    typedef _Alloc allocator_type;
    allocator_type get_allocator() const { return allocator_type(); }
    //构造函数
    _Rb_tree_base(const allocator_type&)
        : _M_header(0) {
        _M_header = _M_get_node();
    }
    //析构函数
    ~_Rb_tree_base() { _M_put_node(_M_header); }

protected:
    _Rb_tree_node<_Tp>* _M_header;

    typedef simple_alloc<_Rb_tree_node<_Tp>, _Alloc> _Alloc_type;
    //get_node和put_node
    _Rb_tree_node<_Tp>* _M_get_node()
    {
        return _Alloc_type::allocate(1);
    }
    void _M_put_node(_Rb_tree_node<_Tp>* __p)
    {
        _Alloc_type::deallocate(__p, 1);
    }
};

#endif /* __STL_USE_STD_ALLOCATORS */

template <class _Key, class _Value, class _KeyOfValue, class _Compare,
    class _Alloc = __STL_DEFAULT_ALLOCATOR(_Value) >
    class _Rb_tree : protected _Rb_tree_base<_Value, _Alloc> {
    typedef _Rb_tree_base<_Value, _Alloc> _Base;
    protected:
        typedef _Rb_tree_node_base* _Base_ptr;
        typedef _Rb_tree_node<_Value> _Rb_tree_node;
        typedef _Rb_tree_Color_type _Color_type;
    public:
        typedef _Key key_type;
        typedef _Value value_type;
        typedef value_type* pointer;
        typedef const value_type* const_pointer;
        typedef value_type& reference;
        typedef const value_type& const_reference;
        typedef _Rb_tree_node* _Link_type;
        typedef size_t size_type;
        typedef ptrdiff_t difference_type;

        typedef typename _Base::allocator_type allocator_type;
        allocator_type get_allocator() const { return _Base::get_allocator(); }

    protected:
#ifdef __STL_USE_NAMESPACES
        using _Base::_M_get_node;
        using _Base::_M_put_node;
        using _Base::_M_header;
#endif /* __STL_USE_NAMESPACES */

    protected:
        //创建一个结点，结点的值为x
        _Link_type _M_create_node(const value_type& __x)
        {
            _Link_type __tmp = _M_get_node();
            __STL_TRY{
              construct(&__tmp->_M_value_field, __x);
            }
            __STL_UNWIND(_M_put_node(__tmp));
            return __tmp;
        }
        //复制一个结点，调用create_node创建一个结点，结点的值为x结点的值，然后把创建的结点的颜色也赋给克隆的结点，然后没有左子结点和右子结点
        _Link_type _M_clone_node(_Link_type __x)
        {
            _Link_type __tmp = _M_create_node(__x->_M_value_field);
            __tmp->_M_color = __x->_M_color;
            __tmp->_M_left = 0;
            __tmp->_M_right = 0;
            return __tmp;
        }
        //销毁一个结点，即调用析构，把值给删除掉，然后再删除掉这个结点
        void destroy_node(_Link_type __p)
        {
            destroy(&__p->_M_value_field);
            _M_put_node(__p);
        }

    protected:
        size_type _M_node_count; // keeps track of size of tree
        _Compare _M_key_compare;
        //返回根节点
        _Link_type& _M_root() const
        {
            return (_Link_type&)_M_header->_M_parent;
        }
        //返回最左子结点
        _Link_type& _M_leftmost() const
        {
            return (_Link_type&)_M_header->_M_left;
        }
        //返回最右子结点
        _Link_type& _M_rightmost() const
        {
            return (_Link_type&)_M_header->_M_right;
        }
        //返回左子结点
        static _Link_type& _S_left(_Link_type __x)
        {
            return (_Link_type&)(__x->_M_left);
        }
        //返回右子结点
        static _Link_type& _S_right(_Link_type __x)
        {
            return (_Link_type&)(__x->_M_right);
        }
        //返回父结点
        static _Link_type& _S_parent(_Link_type __x)
        {
            return (_Link_type&)(__x->_M_parent);
        }
        //返回值
        static reference _S_value(_Link_type __x)
        {
            return __x->_M_value_field;
        }
        //返回键值
        static const _Key& _S_key(_Link_type __x)
        {
            return _KeyOfValue()(_S_value(__x));
        }
        //返回是红还是黑
        static _Color_type& _S_color(_Link_type __x)
        {
            return (_Color_type&)(__x->_M_color);
        }
        //和上面一样只是使用的指针不同，上面的使用的是node_base指针，下面使用的是node指针
        static _Link_type& _S_left(_Base_ptr __x)
        {
            return (_Link_type&)(__x->_M_left);
        }
        static _Link_type& _S_right(_Base_ptr __x)
        {
            return (_Link_type&)(__x->_M_right);
        }
        static _Link_type& _S_parent(_Base_ptr __x)
        {
            return (_Link_type&)(__x->_M_parent);
        }
        static reference _S_value(_Base_ptr __x)
        {
            return ((_Link_type)__x)->_M_value_field;
        }
        static const _Key& _S_key(_Base_ptr __x)
        {
            return _KeyOfValue()(_S_value(_Link_type(__x)));
        }
        static _Color_type& _S_color(_Base_ptr __x)
        {
            return (_Color_type&)(_Link_type(__x)->_M_color);
        }
        //返回最小，调用_Rb_tree_node_base的成员函数_S_minimum
        static _Link_type _S_minimum(_Link_type __x)
        {
            return (_Link_type)_Rb_tree_node_base::_S_minimum(__x);
        }
        //返回最大，调用_Rb_tree_node_base的成员函数_S_maximum
        static _Link_type _S_maximum(_Link_type __x)
        {
            return (_Link_type)_Rb_tree_node_base::_S_maximum(__x);
        }

    public:
        typedef _Rb_tree_iterator<value_type, reference, pointer> iterator;
        typedef _Rb_tree_iterator<value_type, const_reference, const_pointer>
            const_iterator;

#ifdef __STL_CLASS_PARTIAL_SPECIALIZATION
        typedef reverse_iterator<const_iterator> const_reverse_iterator;
        typedef reverse_iterator<iterator> reverse_iterator;
#else /* __STL_CLASS_PARTIAL_SPECIALIZATION */
        typedef reverse_bidirectional_iterator<iterator, value_type, reference,
            difference_type>
            reverse_iterator;
        typedef reverse_bidirectional_iterator<const_iterator, value_type,
            const_reference, difference_type>
            const_reverse_iterator;
#endif /* __STL_CLASS_PARTIAL_SPECIALIZATION */ 

    private:
        //声明增加，删除，复制三个函数
        iterator _M_insert(_Base_ptr __x, _Base_ptr __y, const value_type& __v);
        _Link_type _M_copy(_Link_type __x, _Link_type __p);
        void _M_erase(_Link_type __x);

    public:
        //构造函数，都是直接调用了_M_empty_initialize函数
        _Rb_tree()
            : _Base(allocator_type()), _M_node_count(0), _M_key_compare()
        {
            _M_empty_initialize();
        }
        _Rb_tree(const _Compare& __comp)
            : _Base(allocator_type()), _M_node_count(0), _M_key_compare(__comp)
        {
            _M_empty_initialize();
        }

        _Rb_tree(const _Compare& __comp, const allocator_type& __a)
            : _Base(__a), _M_node_count(0), _M_key_compare(__comp)
        {
            _M_empty_initialize();
        }
        //拷贝构造函数，如果说没有根节点，就直接调用_M_empty_initialize，如果说有根节点则执行复制，赋最大最小值
        _Rb_tree(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x)
            : _Base(__x.get_allocator()),
            _M_node_count(0), _M_key_compare(__x._M_key_compare)
        {
            if (__x._M_root() == 0)
                _M_empty_initialize();
            else {
                _S_color(_M_header) = _S_rb_tree_red;
                _M_root() = _M_copy(__x._M_root(), _M_header);
                _M_leftmost() = _S_minimum(_M_root());
                _M_rightmost() = _S_maximum(_M_root());
            }
            _M_node_count = __x._M_node_count;
        }
        //析构函数
        ~_Rb_tree() { clear(); }
        _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>&
            operator=(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x);

    private:
        //构造函数中调用的函数，初始化一个空的树
        void _M_empty_initialize() {
            _S_color(_M_header) = _S_rb_tree_red; // used to distinguish header from 
                                                  // __root, in iterator.operator++
            _M_root() = 0;
            _M_leftmost() = _M_header;
            _M_rightmost() = _M_header;
        }

    public:
        // accessors:
        //返回键值比较
        _Compare key_comp() const { return _M_key_compare; }
        //返回最左子结点
        iterator begin() { return _M_leftmost(); }
        const_iterator begin() const { return _M_leftmost(); }
        //返回header
        iterator end() { return _M_header; }
        const_iterator end() const { return _M_header; }
        //返回header，也就是反向的begin
        reverse_iterator rbegin() { return reverse_iterator(end()); }
        const_reverse_iterator rbegin() const {
            return const_reverse_iterator(end());
        }
        //返回根节点，也就是反向的end
        reverse_iterator rend() { return reverse_iterator(begin()); }
        const_reverse_iterator rend() const {
            return const_reverse_iterator(begin());
        }
        //判断空不空就是判断_M_node_count计的数为不为0
        bool empty() const { return _M_node_count == 0; }
        //返回size即返回_M_node_count计的数
        size_type size() const { return _M_node_count; }
        //返回最大size
        size_type max_size() const { return size_type(-1); }
        //交换
        void swap(_Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __t) {
            __STD::swap(_M_header, __t._M_header);
            __STD::swap(_M_node_count, __t._M_node_count);
            __STD::swap(_M_key_compare, __t._M_key_compare);
        }

    public:
        // insert/erase
        //插入一个结点保证这个结点的值是唯一的
        pair<iterator, bool> insert_unique(const value_type& __x);
        //插入一个结点保这个节点的值是可以重复的
        iterator insert_equal(const value_type& __x);

        iterator insert_unique(iterator __position, const value_type& __x);
        iterator insert_equal(iterator __position, const value_type& __x);

#ifdef __STL_MEMBER_TEMPLATES  
        template <class _InputIterator>
        void insert_unique(_InputIterator __first, _InputIterator __last);
        template <class _InputIterator>
        void insert_equal(_InputIterator __first, _InputIterator __last);
#else /* __STL_MEMBER_TEMPLATES */
        void insert_unique(const_iterator __first, const_iterator __last);
        void insert_unique(const value_type* __first, const value_type* __last);
        void insert_equal(const_iterator __first, const_iterator __last);
        void insert_equal(const value_type* __first, const value_type* __last);
#endif /* __STL_MEMBER_TEMPLATES */
        //声明各种类型的erase
        void erase(iterator __position);
        size_type erase(const key_type& __x);
        void erase(iterator __first, iterator __last);
        void erase(const key_type* __first, const key_type* __last);
        //clear函数调用erase把根节点删除并且置0，然后把根节点设置为_M_header，再把count置0
        void clear() {
            if (_M_node_count != 0) {
                _M_erase(_M_root());
                _M_leftmost() = _M_header;
                _M_root() = 0;
                _M_rightmost() = _M_header;
                _M_node_count = 0;
            }
        }

    public:
        // set operations:
        //声明find count lower_bound upper_bound equal_range这五个函数
        iterator find(const key_type& __x);
        const_iterator find(const key_type& __x) const;
        size_type count(const key_type& __x) const;
        iterator lower_bound(const key_type& __x);
        const_iterator lower_bound(const key_type& __x) const;
        iterator upper_bound(const key_type& __x);
        const_iterator upper_bound(const key_type& __x) const;
        pair<iterator, iterator> equal_range(const key_type& __x);
        pair<const_iterator, const_iterator> equal_range(const key_type& __x) const;

    public:
        // Debugging.
        //这个函数应该是返回这个结点是黑还是红
        bool __rb_verify() const;
};
//重载==操作符，判断size是否相同然后在调用equal函数，同时满足才返回1
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline bool
    operator==(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y)
{
    return __x.size() == __y.size() &&
        equal(__x.begin(), __x.end(), __y.begin());
}
//重载<操作符，直接调用lexicographical_compare函数满足则返回1
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline bool
    operator<(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y)
{
    return lexicographical_compare(__x.begin(), __x.end(),
        __y.begin(), __y.end());
}
//上面重载用到的两个函数都是定义在alogbase里面的
#ifdef __STL_FUNCTION_TMPL_PARTIAL_ORDER

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline bool
    operator!=(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y) {
    return !(__x == __y);
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline bool
    operator>(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y) {
    return __y < __x;
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline bool
    operator<=(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y) {
    return !(__y < __x);
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline bool
    operator>=(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y) {
    return !(__x < __y);
}


template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline void
    swap(_Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x,
        _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __y)
{
    __x.swap(__y);
}

#endif /* __STL_FUNCTION_TMPL_PARTIAL_ORDER */

//重载赋值操作符，先判断左值和右值是否是相同的，相同则不做操作
//然后先清空左值的树，然后先count赋为0然后把x的键值赋给左值的键值，然后再进行判断x是不是空的，如果是空的，则直接构造一个空的树就可以了
//如果x不是空的，则把x的根结点header复制过来，把count，最小和最大也赋值过来
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>&
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::operator=(const _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>& __x)
{
    if (this != &__x) {
        // Note that _Key may be a constant type.
        clear();
        _M_node_count = 0;
        _M_key_compare = __x._M_key_compare;
        if (__x._M_root() == 0) {
            _M_root() = 0;
            _M_leftmost() = _M_header;
            _M_rightmost() = _M_header;
        }
        else {
            _M_root() = _M_copy(__x._M_root(), _M_header);
            _M_leftmost() = _S_minimum(_M_root());
            _M_rightmost() = _S_maximum(_M_root());
            _M_node_count = __x._M_node_count;
        }
    }
    return *this;
}
//insert函数
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::_M_insert(_Base_ptr __x_, _Base_ptr __y_, const _Value& __v)
{   //x是新插入点，y是插入点的父结点
    _Link_type __x = (_Link_type)__x_;
    _Link_type __y = (_Link_type)__y_;
    _Link_type __z;
    //先判断插入点的父结点是否是header或者新插入点是不是为空再或者_M_key_compare返回的值为一
    //如果满足上面的两个要求中的一个则执行下面的操作，即创建一个值为v的结点，然后把这个结点赋给插入点的父结点的左子结点，意思就是让插入点的父结点的左子结点指向新创建的这个结点
    //然后判断插入点的父结点是不是header，如果是就让最有子结点的指针指向z
    //如果上面的条件没有满足则判断插入点的父结点是不是最左子结点，如果是就让最左子结点的指针值指向z
    if (__y == _M_header || __x != 0 ||
        _M_key_compare(_KeyOfValue()(__v), _S_key(__y))) {
        __z = _M_create_node(__v);
        _S_left(__y) = __z;               // also makes _M_leftmost() = __z 
                                          //    when __y == _M_header
        if (__y == _M_header) {
            _M_root() = __z;
            _M_rightmost() = __z;
        }
        else if (__y == _M_leftmost())
            _M_leftmost() = __z;   // maintain _M_leftmost() pointing to min node
    }
    //如果说上面的第一个条件没有满足，也是创建一个值为v的结点，然后把z赋给插入点的父结点的右子结点，然后判断插入点的父结点是不是最有子结点，让最有子结点的指针指向z
    else {
        __z = _M_create_node(__v);
        _S_right(__y) = __z;
        if (__y == _M_rightmost())
            _M_rightmost() = __z;  // maintain _M_rightmost() pointing to max node
    }
    //经过上面的操作之后，让y称为新插入点的父结点。插入点的左右子结点为空
    _S_parent(__z) = __y;
    _S_left(__z) = 0;
    _S_right(__z) = 0;
    //调整新插入结点的颜色以及让他满足红黑树的规定，参数一为新增节点，参数二为根节点
    _Rb_tree_rebalance(__z, _M_header->_M_parent);
    //节点数加一
    ++_M_node_count;
    return iterator(__z);
}
//添加新值，可以重复
//这个很简单，从根节点开始，_M_key_compare遇大则往左遇小于或等于则往右,找到合适的位置之后直接调用插入就可以了
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::insert_equal(const _Value& __v)
{
    _Link_type __y = _M_header;
    _Link_type __x = _M_root();
    while (__x != 0) {
        __y = __x;
        __x = _M_key_compare(_KeyOfValue()(__v), _S_key(__x)) ?
            _S_left(__x) : _S_right(__x);
    }
    return _M_insert(__x, __y, __v);
}

//添加新值，不可以重复
//和上面一样也是从根节点开始，遇大则往左遇小于或等于则往右，while循环结束之后，y指向的就是要插入点的父结点
//然后检测comp如果说是1则代表是大于，就要插入到右侧，在判断插入点的父结点是否为最左子节点，如果是的话直接调用插入，如果不是的话调整j准备之后测试
//上面不满足的话就比较一下插入点的父结点的值与插入值的大小，如果大于就插入到右侧，小于就插入到左侧，也是直接调用插入
//如果说运行到了最后一个return则说明插入的值一定会与树中的值重复然后就放弃这次插入
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    pair<typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator,
    bool>
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::insert_unique(const _Value& __v)
{
    _Link_type __y = _M_header;
    _Link_type __x = _M_root();
    bool __comp = true;
    while (__x != 0) {
        __y = __x;
        __comp = _M_key_compare(_KeyOfValue()(__v), _S_key(__x));
        __x = __comp ? _S_left(__x) : _S_right(__x);
    }
    iterator __j = iterator(__y);
    if (__comp)
        if (__j == begin())
            return pair<iterator, bool>(_M_insert(__x, __y, __v), true);
        else
            --__j;
    if (_M_key_compare(_S_key(__j._M_node), _KeyOfValue()(__v)))
        return pair<iterator, bool>(_M_insert(__x, __y, __v), true);
    return pair<iterator, bool>(__j, false);
}

//上面的重载版本，当参数为一个迭代器和一个值的时候
//先判断要插入的点是不是最左子结点如果是就再判断树的大小是不是不为零而且插入值大于插入点的值如果满足则直接调用插入，不满足就直接调用第一版本的insert_unique
//上面的条件不满足就判断插入点是不是end，如果是就接着判断最右子节点的值是不是大于插入值如果是则直接调用插入，不满足就直接调用第一版本的insert_unique
//上面两个条件都不满足，则比较插入点的父结点的值是不是大于插入值和插入值是否大于插入点的值如果满足就再判断一下插入点的父结点是不是右子结点是不是为空，为空则直接插入，不满足就直接调用第一版本的insert_unique
template <class _Key, class _Val, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Val, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Val, _KeyOfValue, _Compare, _Alloc>
    ::insert_unique(iterator __position, const _Val& __v)
{
    if (__position._M_node == _M_header->_M_left) { // begin()
        if (size() > 0 &&
            _M_key_compare(_KeyOfValue()(__v), _S_key(__position._M_node)))
            return _M_insert(__position._M_node, __position._M_node, __v);
        // first argument just needs to be non-null 
        else
            return insert_unique(__v).first;
    }
    else if (__position._M_node == _M_header) { // end()
        if (_M_key_compare(_S_key(_M_rightmost()), _KeyOfValue()(__v)))
            return _M_insert(0, _M_rightmost(), __v);
        else
            return insert_unique(__v).first;
    }
    else {
        iterator __before = __position;
        --__before;
        if (_M_key_compare(_S_key(__before._M_node), _KeyOfValue()(__v))
            && _M_key_compare(_KeyOfValue()(__v), _S_key(__position._M_node))) {
            if (_S_right(__before._M_node) == 0)
                return _M_insert(0, __before._M_node, __v);
            else
                return _M_insert(__position._M_node, __position._M_node, __v);
            // first argument just needs to be non-null 
        }
        else
            return insert_unique(__v).first;
    }
}
//第二版本的equal，和第二版本的unique差不多就是少了判断唯一
template <class _Key, class _Val, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Val, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Val, _KeyOfValue, _Compare, _Alloc>
    ::insert_equal(iterator __position, const _Val& __v)
{
    if (__position._M_node == _M_header->_M_left) { // begin()
        if (size() > 0 &&
            !_M_key_compare(_S_key(__position._M_node), _KeyOfValue()(__v)))
            return _M_insert(__position._M_node, __position._M_node, __v);
        // first argument just needs to be non-null 
        else
            return insert_equal(__v);
    }
    else if (__position._M_node == _M_header) {// end()
        if (!_M_key_compare(_KeyOfValue()(__v), _S_key(_M_rightmost())))
            return _M_insert(0, _M_rightmost(), __v);
        else
            return insert_equal(__v);
    }
    else {
        iterator __before = __position;
        --__before;
        if (!_M_key_compare(_KeyOfValue()(__v), _S_key(__before._M_node))
            && !_M_key_compare(_S_key(__position._M_node), _KeyOfValue()(__v))) {
            if (_S_right(__before._M_node) == 0)
                return _M_insert(0, __before._M_node, __v);
            else
                return _M_insert(__position._M_node, __position._M_node, __v);
            // first argument just needs to be non-null 
        }
        else
            return insert_equal(__v);
    }
}

#ifdef __STL_MEMBER_TEMPLATES  

template <class _Key, class _Val, class _KoV, class _Cmp, class _Alloc>
template<class _II>
void _Rb_tree<_Key, _Val, _KoV, _Cmp, _Alloc>
::insert_equal(_II __first, _II __last)
{
    for (; __first != __last; ++__first)
        insert_equal(*__first);
}

template <class _Key, class _Val, class _KoV, class _Cmp, class _Alloc>
template<class _II>
void _Rb_tree<_Key, _Val, _KoV, _Cmp, _Alloc>
::insert_unique(_II __first, _II __last) {
    for (; __first != __last; ++__first)
        insert_unique(*__first);
}

#else /* __STL_MEMBER_TEMPLATES */
//下面的equal和unique都是直接调用insert_equal
template <class _Key, class _Val, class _KoV, class _Cmp, class _Alloc>
void
_Rb_tree<_Key, _Val, _KoV, _Cmp, _Alloc>
::insert_equal(const _Val* __first, const _Val* __last)
{
    for (; __first != __last; ++__first)
        insert_equal(*__first);
}

template <class _Key, class _Val, class _KoV, class _Cmp, class _Alloc>
void
_Rb_tree<_Key, _Val, _KoV, _Cmp, _Alloc>
::insert_equal(const_iterator __first, const_iterator __last)
{
    for (; __first != __last; ++__first)
        insert_equal(*__first);
}

template <class _Key, class _Val, class _KoV, class _Cmp, class _Alloc>
void
_Rb_tree<_Key, _Val, _KoV, _Cmp, _Alloc>
::insert_unique(const _Val* __first, const _Val* __last)
{
    for (; __first != __last; ++__first)
        insert_unique(*__first);
}

template <class _Key, class _Val, class _KoV, class _Cmp, class _Alloc>
void _Rb_tree<_Key, _Val, _KoV, _Cmp, _Alloc>
::insert_unique(const_iterator __first, const_iterator __last)
{
    for (; __first != __last; ++__first)
        insert_unique(*__first);
}

#endif /* __STL_MEMBER_TEMPLATES */
//删除函数，先调用_Rb_tree_rebalance_for_erase函数进行调整，调整之后直接删除这个结点
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline void _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::erase(iterator __position)
{
    _Link_type __y =
        (_Link_type)_Rb_tree_rebalance_for_erase(__position._M_node,
            _M_header->_M_parent,
            _M_header->_M_left,
            _M_header->_M_right);
    destroy_node(__y);
    --_M_node_count;
}
//第二版本，先找到树中与x相等的结点，然后直接对相等的结点操作就可以了
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::size_type
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::erase(const _Key& __x)
{
    pair<iterator, iterator> __p = equal_range(__x);
    size_type __n = 0;
    distance(__p.first, __p.second, __n);
    erase(__p.first, __p.second);
    return __n;
}
//复制函数
template <class _Key, class _Val, class _KoV, class _Compare, class _Alloc>
typename _Rb_tree<_Key, _Val, _KoV, _Compare, _Alloc>::_Link_type
_Rb_tree<_Key, _Val, _KoV, _Compare, _Alloc>
::_M_copy(_Link_type __x, _Link_type __p)
{
    // structural copy.  __x and __p must be non-null.
    _Link_type __top = _M_clone_node(__x);
    __top->_M_parent = __p;

    __STL_TRY{
      if (__x->_M_right)
        __top->_M_right = _M_copy(_S_right(__x), __top);
      __p = __top;
      __x = _S_left(__x);

      while (__x != 0) {
        _Link_type __y = _M_clone_node(__x);
        __p->_M_left = __y;
        __y->_M_parent = __p;
        if (__x->_M_right)
          __y->_M_right = _M_copy(_S_right(__x), __y);
        __p = __y;
        __x = _S_left(__x);
      }
    }
    __STL_UNWIND(_M_erase(__top));

    return __top;
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    void _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::_M_erase(_Link_type __x)
{
    // erase without rebalancing
    while (__x != 0) {
        _M_erase(_S_right(__x));
        _Link_type __y = _S_left(__x);
        destroy_node(__x);
        __x = __y;
    }
}
//另一个版本，如果说first和last正好都分别指向的header和最左子节点则直接clear
//如果说不满足上面的条件就直接遍历first到last然后一次erase
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    void _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::erase(iterator __first, iterator __last)
{
    if (__first == begin() && __last == end())
        clear();
    else
        while (__first != __last) erase(__first++);
}
//直接遍历first到last然后一次erase
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    void _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::erase(const _Key* __first, const _Key* __last)
{
    while (__first != __last) erase(*__first++);
}
//find函数，先检测根节点是不是为空，然后比较根节点的值与查找的值，如果根节点的值大于查找到值则向左走，如果小于则向右走
//经过while之后y应该只想大是查找到的点的父结点，return里还会有检测，检测y是不是header，还有就是检测查找的值与查找到的节点的父节点的大小
//如果查找值大于父节点的值则返回父节点，如果小于则返回end
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::find(const _Key& __k)
{
    _Link_type __y = _M_header;      // Last node which is not less than __k. 
    _Link_type __x = _M_root();      // Current node. 

    while (__x != 0)
        if (!_M_key_compare(_S_key(__x), __k))
            __y = __x, __x = _S_left(__x);
        else
            __x = _S_right(__x);

    iterator __j = iterator(__y);
    return (__j == end() || _M_key_compare(__k, _S_key(__j._M_node))) ?
        end() : __j;
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::const_iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::find(const _Key& __k) const
{
    _Link_type __y = _M_header; /* Last node which is not less than __k. */
    _Link_type __x = _M_root(); /* Current node. */

    while (__x != 0) {
        if (!_M_key_compare(_S_key(__x), __k))
            __y = __x, __x = _S_left(__x);
        else
            __x = _S_right(__x);
    }
    const_iterator __j = const_iterator(__y);
    return (__j == end() || _M_key_compare(__k, _S_key(__j._M_node))) ?
        end() : __j;
}
//计数函数
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::size_type
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::count(const _Key& __k) const
{
    pair<const_iterator, const_iterator> __p = equal_range(__k);
    size_type __n = 0;
    distance(__p.first, __p.second, __n);
    return __n;
}
//从根结点出发然后遇大则向左，遇到小最向右执行玩循环之后直接返回就可以
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::lower_bound(const _Key& __k)
{
    _Link_type __y = _M_header; /* Last node which is not less than __k. */
    _Link_type __x = _M_root(); /* Current node. */

    while (__x != 0)
        if (!_M_key_compare(_S_key(__x), __k))
            __y = __x, __x = _S_left(__x);
        else
            __x = _S_right(__x);

    return iterator(__y);
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::const_iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::lower_bound(const _Key& __k) const
{
    _Link_type __y = _M_header; /* Last node which is not less than __k. */
    _Link_type __x = _M_root(); /* Current node. */

    while (__x != 0)
        if (!_M_key_compare(_S_key(__x), __k))
            __y = __x, __x = _S_left(__x);
        else
            __x = _S_right(__x);

    return const_iterator(__y);
}
//从根结点出发然后遇大则向右，遇到小最向左执行玩循环之后直接返回就可以
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::upper_bound(const _Key& __k)
{
    _Link_type __y = _M_header; /* Last node which is greater than __k. */
    _Link_type __x = _M_root(); /* Current node. */

    while (__x != 0)
        if (_M_key_compare(__k, _S_key(__x)))
            __y = __x, __x = _S_left(__x);
        else
            __x = _S_right(__x);

    return iterator(__y);
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::const_iterator
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::upper_bound(const _Key& __k) const
{
    _Link_type __y = _M_header; /* Last node which is greater than __k. */
    _Link_type __x = _M_root(); /* Current node. */

    while (__x != 0)
        if (_M_key_compare(__k, _S_key(__x)))
            __y = __x, __x = _S_left(__x);
        else
            __x = _S_right(__x);

    return const_iterator(__y);
}

template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    inline
    pair<typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator,
    typename _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::iterator>
    _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
    ::equal_range(const _Key& __k)
{
    return pair<iterator, iterator>(lower_bound(__k), upper_bound(__k));
}

template <class _Key, class _Value, class _KoV, class _Compare, class _Alloc>
inline
pair<typename _Rb_tree<_Key, _Value, _KoV, _Compare, _Alloc>::const_iterator,
    typename _Rb_tree<_Key, _Value, _KoV, _Compare, _Alloc>::const_iterator>
    _Rb_tree<_Key, _Value, _KoV, _Compare, _Alloc>
    ::equal_range(const _Key& __k) const
{
    return pair<const_iterator, const_iterator>(lower_bound(__k),
        upper_bound(__k));
}
//检测这个结点是否为空，然后就递归判断也就是从node走到root检测有多少个black
inline int
__black_count(_Rb_tree_node_base* __node, _Rb_tree_node_base* __root)
{
    if (__node == 0)
        return 0;
    else {
        int __bc = __node->_M_color == _S_rb_tree_black ? 1 : 0;
        if (__node == __root)
            return __bc;
        else
            return __bc + __black_count(__node->_M_parent, __root);
    }
}
//检测是否为空如果为空就返回1
//满足不空的条件之后，就先计算一下从最左子结点到根节点的黑结点个数，然后从最左子节点遍历到header
//先检测这个节点的颜色是否为红，如果为红则再判断它的左右子结点是否为红，如果为红则返回false
//然后检验是否有左子结点并且该节点的值需要大于左子结点的值
//然后检验是否有右子结点并且该节点的值要小于右子结点的值
//然后就是没有左右子结点，也就代表到达叶子结点了，就检测从这个叶子结点到根节点的这条路径中的黑结点个数与之前计算的最左子结点到根节点的黑结点个数是否相同
//再检测一下最左最右子结点是不是最小和最大的
template <class _Key, class _Value, class _KeyOfValue,
    class _Compare, class _Alloc>
    bool _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>::__rb_verify() const
{
    if (_M_node_count == 0 || begin() == end())
        return _M_node_count == 0 && begin() == end() &&
        _M_header->_M_left == _M_header && _M_header->_M_right == _M_header;

    int __len = __black_count(_M_leftmost(), _M_root());
    for (const_iterator __it = begin(); __it != end(); ++__it) {
        _Link_type __x = (_Link_type)__it._M_node;
        _Link_type __L = _S_left(__x);
        _Link_type __R = _S_right(__x);

        if (__x->_M_color == _S_rb_tree_red)
            if ((__L && __L->_M_color == _S_rb_tree_red) ||
                (__R && __R->_M_color == _S_rb_tree_red))
                return false;

        if (__L && _M_key_compare(_S_key(__x), _S_key(__L)))
            return false;
        if (__R && _M_key_compare(_S_key(__R), _S_key(__x)))
            return false;

        if (!__L && !__R && __black_count(__x, _M_root()) != __len)
            return false;
    }

    if (_M_leftmost() != _Rb_tree_node_base::_S_minimum(_M_root()))
        return false;
    if (_M_rightmost() != _Rb_tree_node_base::_S_maximum(_M_root()))
        return false;

    return true;
}

// Class rb_tree is not part of the C++ standard.  It is provided for
// compatibility with the HP STL.

template <class _Key, class _Value, class _KeyOfValue, class _Compare,
    class _Alloc = __STL_DEFAULT_ALLOCATOR(_Value) >
    struct rb_tree : public _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc>
{
    typedef _Rb_tree<_Key, _Value, _KeyOfValue, _Compare, _Alloc> _Base;
    typedef typename _Base::allocator_type allocator_type;

    rb_tree(const _Compare& __comp = _Compare(),
        const allocator_type& __a = allocator_type())
        : _Base(__comp, __a) {}

    ~rb_tree() {}
};

#if defined(__sgi) && !defined(__GNUC__) && (_MIPS_SIM != _MIPS_SIM_ABI32)
#pragma reset woff 1375
#endif

__STL_END_NAMESPACE
