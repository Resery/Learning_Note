#pragma once

#include "stl_config.h"
#include "stl_alloc.h"
#include "stl_algo.h"
#include "stl_algobase.h"
#include "stl_iterator.h
#include "stl_iterator_base.h"
#include "stl_uninitialized.h"
#include "type_traits.h"

__STL_BEGIN_NAMESPACE

template <class _T>
struct _R_list_node
{
	typedef void* voidpointer;
	voidpointer _prev;
	voidpointer _next;
	_T _data;
};

template <class _T,class _Ref,class _Poi>
struct _R_list_iterator {
	
	typedef _R_list_iterator<T, T&, T*> iterator;
	typedef _R_list_iterator<T, _Ref, _Poi> self;

	typedef bidirectional_iterator_tag iterator_category;
	typedef _T value_type;
	typedef size_t size_type;	
	typedef ptrdiff_t difference_type;	

	typedef _R_list_node<_T>* link_type;

	typedef _Ref reference;
	typedef _Poi pointer;

	link_type node;

	_R_list_iterator() {}
	_R_list_iterator(link_type x) : node(x) {}
	_R_list_iterator(const iterator& x) : node(x.node) {}

	bool operator==(const self& x) const { return node == x.node; }
	bool operator!= (const self& x) const { return node != x.node; }

	reference operator*() const { return (*node).data; }
	pointer operator->()const { return &(operator*()); }

	self& operator++() {
		node = (link_type)node->_next;
		return &this;
	}

	self& operator++(int){
		self tmp = *this;
		++* this;
		return tmp;
	}

	self& operator--() {
		node = (link_type)node->_prev;
		return &this;
	}

	self& operator--(int) {
		self tmp = *this;
		--* this;
		return tmp;
	}

};

template <class _T,class _Alloc = alloc>
class list {

//空间配置器--start
protected:
	typedef _R_list_iterator<_T, _T&, _T*>	iterator;
	typedef _R_list_node<class _T> list_node;
	typedef simple_alloc<list_node, _Alloc> list_node_allocator;

	
	typedef size_t size_type;

public:
	typedef list_node* link_type;

protected:
	link_type node;
	
	link_type get_node() { return list_node_allocator::allocator(); }
	void put_node(link_type p) { return list_node_allocator::deallocator(p); }

	link_type create_node(const _T& x ) {
		link_type p = get_node();
		construct(&p->_data，x);
		return p;
	}

	void destory_node(link_type p) {
		destroy(&p->_data);
		put_node(p);
	}
//空间配置器--end

	iterator begin() { return (link_type)node->next; }
	iterator end() { return node; }

	bool empty() { return node == node->_next; }
	size_type size() const {
		size_type result;
		distance(begin(), end(), result);
		return result;
	}
	size_type max_size() const { return size_type(-1); }
	iterator front() { return *begin(); }
	iterator back() { return *(--end()); }

	void swap(list<_T, _Alloc>& __x) { __STL_NAME::swap(node, __x.node); }

public:
	list() { empty_initialize() };

protected:
	void empty_initialize() {
		node = get_node();
		node->_next = node;
		node->_prev = node;
	}

public:
	void push_back(const _T& x) { insert(end(), x); }

	iterator insert(iterator __position, const _T& __x) {
		link_type _tmp = create_node(__x);
		_tmp->_next = __position.node;
		_tmp->_prev = __position.node->_prev;
		__position.node->_prev->_next = _tmp;
		__position.node->_prev = _tmp;
		return _tmp;
	}
	iterator insert(iterator __position) { return insert(__position, _T()); }

	void insert(iterator __position, const _T* __first, const _T* __last);

	void insert(iterator __pos, size_type __n, const _T& __x)
	{
		_M_fill_insert(__pos, __n, __x);
	}
	void _M_fill_insert(iterator __pos, size_type __n, const _T& __x);

	void push_front(const _T& __x) { insert(begin(), __x); }
	void push_front() { insert(begin()); }
	void push_back(const _T& __x) { insert(end(), __x); }
	void push_back() { insert(end()); }

	iterator erase(iterator __position) {
		link_type __next_node = __position.node->_next;
		link_type __prev_node = __position.node->_prev;
		link_type __n = (link_type)__position.node;
		__prev_node->_next = __next_node;
		__next_node->_prev = __prev_node;
		destory(&__n->_data);
		put_node(__n);
		return iterator((link_type)__next_node);
	}
	iterator erase(iterator __first, iterator __last);
	void clear() { list_node::clear(); }

	void resize(size_type __new_size, const _T& __x);
	void resize(size_type __new_size) { this->resize(__new_size, _T()); }

	void pop_front() { erase(begin()); }
	void pop_back() {
		iterator __tmp = end();
		erase(--__tmp);
	}
	//五种构造方式，分别是构造一个空结点，构造n个空结点，构造n个值为value的结点，给出一个范围first，last以这个范围构造，还有一个是拷贝构造
	list(size_type __n, const _T& __value,
		const allocator_type& __a = allocator_type())
		: list_node(__a)
	{
		insert(begin(), __n, __value);
	}
	explicit list(size_type __n)
		: list_node(allocator_type())
	{
		insert(begin(), __n, _Tp());
	}
	list(const _T* __first, const _T* __last,
		const allocator_type& __a = allocator_type())
		: list_node(__a)
	{
		this->insert(begin(), __first, __last);
	}

	list(const list<_T, _Alloc>& __x) : list_node(__x.get_allocator())
	{
		insert(begin(), __x.begin(), __x.end());
	}
	//拷贝赋值
	list<_T, _Alloc>& operator=(const list<_T, _Alloc>& __x);
	//析构函数
	~list() { }
	
	void assign(size_type __n, const _T& __val) { _M_fill_assign(__n, __val); }

	void _M_fill_assign(size_type __n, const _T& __val);

protected:
	void transfer(iterator __position, iterator __first, iterator __last) {
		if (__position != __last) {
			// Remove [first, last) from its old position.
			((link_type)((*__last.node)._prev))->_next = __position.node;
			((link_type)((*__first.node)._prev))->_next = __last.node;
			((link_type)((*__position.node)._prev))->_next = __first.node;

			// Splice [first, last) into its new position.
			link_type __tmp = (link_type)((__position.node)._prev);
			(*__position.node)._prev = (*__last.node)._prev;
			(*__last.node)._prev = (*__first.node)._prev;
			(*__first.node)._prev = __tmp;
		}
	}

public:
	//第一种情况，传递一个pos和一个list x，即在pos前插入整个x
	void splice(iterator __position, list& __x) {
		if (!__x.empty())
			this->transfer(__position, __x.begin(), __x.end());
	}
	//第二种情况，传递一个pos和一个i，所以就是在pos前插入i，其中j的作用就是左闭右开区间的右面那个区间，意思就是[0,1)和这个差不多的意思
	void splice(iterator __position, list&, iterator __i) {
		iterator __j = __i;
		++__j;
		if (__position == __i || __position == __j) return;
		this->transfer(__position, __i, __j);
	}
	//第三种情况，传递一个first和一个last，意思就是在pos前插入first到last范围内的东西
	void splice(iterator __position, list&, iterator __first, iterator __last) {
		if (__first != __last)
			this->transfer(__position, __first, __last);
	}
	void remove(const _T& __value);
	void unique();
	void merge(list& __x);
	void reverse();
	void sort();

	template <class _Predicate> void remove_if(_Predicate);
	template <class _BinaryPredicate> void unique(_BinaryPredicate);
	template <class _StrictWeakOrdering> void merge(list&, _StrictWeakOrdering);
	template <class _StrictWeakOrdering> void sort(_StrictWeakOrdering);
	
};

//操作符重载
//相等判断的就是链表里从头到尾的每一个指针是不是相同的，指针相同代表所指的东西相同
template <class _Tp, class _Alloc>
inline bool
operator==(const list<_Tp, _Alloc>& __x, const list<_Tp, _Alloc>& __y)
{
	typedef typename list<_Tp, _Alloc>::const_iterator const_iterator;
	const_iterator __end1 = __x.end();
	const_iterator __end2 = __y.end();

	const_iterator __i1 = __x.begin();
	const_iterator __i2 = __y.begin();
	while (__i1 != __end1 && __i2 != __end2 && *__i1 == *__i2) {
		++__i1;
		++__i2;
	}
	return __i1 == __end1 && __i2 == __end2;
}
//小于的判断就是调用了算法里的lexicographical_compare，也就是对头尾遍历，比较所指的内容的大小
template <class _Tp, class _Alloc>
inline bool operator<(const list<_Tp, _Alloc>& __x,
	const list<_Tp, _Alloc>& __y)
{
	return lexicographical_compare(__x.begin(), __x.end(),
		__y.begin(), __y.end());
}
//这里因为重载了==运算符，所以直接进行上面重载的==操作，即相同就返回!1也就是0，不相同就返回!0也就是1
template <class _Tp, class _Alloc>
inline bool operator!=(const list<_Tp, _Alloc>& __x,
	const list<_Tp, _Alloc>& __y) {
	return !(__x == __y);
}
//这里也是直接使用上面重载过的<运算符，和上面不同的是上面比较的是x<y而这里是y<x
template <class _Tp, class _Alloc>
inline bool operator>(const list<_Tp, _Alloc>& __x,
	const list<_Tp, _Alloc>& __y) {
	return __y < __x;
}
//这个也是使用上面重载过的<运算符，如果说上面的<操作返回的是0，也就代表两个列表所有元素不小于，即有可能x>y或者x=y
//因为这里比较的是y<x所以说也就变成了y>=x也就是x<=y
template <class _Tp, class _Alloc>
inline bool operator<=(const list<_Tp, _Alloc>& __x,
	const list<_Tp, _Alloc>& __y) {
	return !(__y < __x);
}
//这个也是使用上面重载过的<运算符，如果说上面的<操作返回的是0，也就代表两个列表所有元素不小于，即有可能x>y或者x=y
template <class _Tp, class _Alloc>
inline bool operator>=(const list<_Tp, _Alloc>& __x,
	const list<_Tp, _Alloc>& __y) {
	return !(__x < __y);
}
//这个直接调用上面list里面定义过的swap
template <class _Tp, class _Alloc>
inline void
swap(list<_Tp, _Alloc>& __x, list<_Tp, _Alloc>& __y)
{
	__x.swap(__y);
}
//插入，从first遍历到last，在pos处插入first的值
template <class _Tp, class _Alloc>
void
list<_Tp, _Alloc>::insert(iterator __position,
	const _Tp* __first, const _Tp* __last)
{
	for (; __first != __last; ++__first)
		insert(__position, *__first);
}
//插入，从first遍历到last，在pos处插入x的值
template <class _Tp, class _Alloc>
void
list<_Tp, _Alloc>::_M_fill_insert(iterator __position,
	size_type __n, const _Tp& __x)
{
	for (; __n > 0; --__n)
		insert(__position, __x);
}
//从头删除到尾
template <class _Tp, class _Alloc>
typename list<_Tp, _Alloc>::iterator list<_Tp, _Alloc>::erase(iterator __first,
	iterator __last)
{
	while (__first != __last)
		erase(__first++);
	return __last;
}
//更改size，如果新的size为0直接删除头到尾，否则就是做一个循环从头走到尾部，记录下长度，然后用新的size剪掉这个长度在新增这么多个值为x的结点
template <class _Tp, class _Alloc>
void list<_Tp, _Alloc>::resize(size_type __new_size, const _Tp& __x)
{
	iterator __i = begin();
	size_type __len = 0;
	for (; __i != end() && __len < __new_size; ++__i, ++__len)
		;
	if (__len == __new_size)
		erase(__i, end());
	else                          // __i == end()
		insert(end(), __new_size - __len, __x);
}
//重载赋值操作符，从头遍历到尾把相应的值赋给x对应地方的，然后如果说有一个到了尽头，就进行检测，检测哪一个列表到头了
//如果=右面的到头了，就把=左面的列表剩余的部分删除掉，如果=左面到头了，就把=右面的全部插入到=左面的尾部
template <class _Tp, class _Alloc>
list<_Tp, _Alloc>& list<_Tp, _Alloc>::operator=(const list<_Tp, _Alloc>& __x)
{
	if (this != &__x) {
		iterator __first1 = begin();
		iterator __last1 = end();
		iterator __first2 = __x.begin();
		iterator __last2 = __x.end();
		while (__first1 != __last1 && __first2 != __last2)
			*__first1++ = *__first2++;
		if (__first2 == __last2)
			erase(__first1, __last1);
		else
			insert(__last1, __first2, __last2);
	}
	return *this;
}
//填充，填充n个value
template <class _Tp, class _Alloc>
void list<_Tp, _Alloc>::_M_fill_assign(size_type __n, const _Tp& __val) {
	iterator __i = begin();
	for (; __i != end() && __n > 0; ++__i, --__n)
		*__i = __val;
	if (__n > 0)
		insert(end(), __n, __val);
	else
		erase(__i, end());
}

//从头循环到尾，如果说值等于value则删除
template <class _Tp, class _Alloc>
void list<_Tp, _Alloc>::remove(const _Tp& __value)
{
	iterator __first = begin();
	iterator __last = end();
	while (__first != __last) {
		iterator __next = __first;
		++__next;
		if (*__first == __value) erase(__first);
		__first = __next;
	}
}
//从头遍历到尾，删除list中重复的元素
template <class _Tp, class _Alloc>
void list<_Tp, _Alloc>::unique()
{
	iterator __first = begin();
	iterator __last = end();
	if (__first == __last) return;
	iterator __next = __first;
	while (++__next != __last) {
		if (*__first == *__next)
			erase(__next);
		else
			__first = __next;
		__next = __first;
	}
}
//从头遍历到尾，把list2中小于list1的值插入到当前first的，然后如果说list1遍历结束，而list2还有内容，则直接把list2的剩余部分拼接到list1尾部
//所以说如果两个列表都是有序的话，merge操作之后生成的新的列表也会是有序的，如果说两个列表都是无序的或者是一个有序一个无序则会形成一个相对有序的链表
template <class _Tp, class _Alloc>
void list<_Tp, _Alloc>::merge(list<_Tp, _Alloc>& __x)
{
	iterator __first1 = begin();
	iterator __last1 = end();
	iterator __first2 = __x.begin();
	iterator __last2 = __x.end();
	while (__first1 != __last1 && __first2 != __last2)
		if (*__first2 < *__first1) {
			iterator __next = __first2;
			transfer(__first1, __first2, ++__next);
			__first2 = __next;
		}
		else
			++__first1;
	if (__first2 != __last2) transfer(__last1, __first2, __last2);
}

inline void __List_base_reverse(_List_node_base* __p)
{
	_List_node_base* __tmp = __p;
	do {
		Resery_STL::swap(__tmp->_next, __tmp->_prev);
		__tmp = __tmp->_prev;     // Old next node is now prev.
	} while (__tmp != __p);
}

template <class _Tp, class _Alloc>
inline void list<_Tp, _Alloc>::reverse()
{
	__List_base_reverse(this->node);
}
//排序，采用的是快速排序，快速排序就是以最左边的数为基数，然后从右往左找小于基数的，再从左往右找大于基数的，然后当移动的指针碰头了，则和基数交换，交换的数变成基数，循环下去
template <class _Tp, class _Alloc>
void list<_Tp, _Alloc>::sort()
{
	// Do nothing if the list has length 0 or 1.
	if (_M_node->_M_next != _M_node && _M_node->_M_next->_M_next != _M_node) {
		list<_Tp, _Alloc> __carry;
		list<_Tp, _Alloc> __counter[64];
		int __fill = 0;
		while (!empty()) {
			__carry.splice(__carry.begin(), *this, begin());
			int __i = 0;
			while (__i < __fill && !__counter[__i].empty()) {
				__counter[__i].merge(__carry);
				__carry.swap(__counter[__i++]);
			}
			__carry.swap(__counter[__i]);
			if (__i == __fill) ++__fill;
		}

		for (int __i = 1; __i < __fill; ++__i)
			__counter[__i].merge(__counter[__i - 1]);
		swap(__counter[__fill - 1]);
	}
}
//第二版本，使用的是pred仿函数
template <class _Tp, class _Alloc> template <class _Predicate>
void list<_Tp, _Alloc>::remove_if(_Predicate __pred)
{
	iterator __first = begin();
	iterator __last = end();
	while (__first != __last) {
		iterator __next = __first;
		++__next;
		if (__pred(*__first)) erase(__first);
		__first = __next;
	}
}
//第二版本，使用的是binary_pred仿函数
template <class _Tp, class _Alloc> template <class _BinaryPredicate>
void list<_Tp, _Alloc>::unique(_BinaryPredicate __binary_pred)
{
	iterator __first = begin();
	iterator __last = end();
	if (__first == __last) return;
	iterator __next = __first;
	while (++__next != __last) {
		if (__binary_pred(*__first, *__next))
			erase(__next);
		else
			__first = __next;
		__next = __first;
	}
}
//第二版本，使用的是comp仿函数
template <class _Tp, class _Alloc> template <class _StrictWeakOrdering>
void list<_Tp, _Alloc>::merge(list<_Tp, _Alloc>& __x,
	_StrictWeakOrdering __comp)
{
	iterator __first1 = begin();
	iterator __last1 = end();
	iterator __first2 = __x.begin();
	iterator __last2 = __x.end();
	while (__first1 != __last1 && __first2 != __last2)
		if (__comp(*__first2, *__first1)) {
			iterator __next = __first2;
			transfer(__first1, __first2, ++__next);
			__first2 = __next;
		}
		else
			++__first1;
	if (__first2 != __last2) transfer(__last1, __first2, __last2);
}
//第二版本，使用的是comp仿函数
template <class _Tp, class _Alloc> template <class _StrictWeakOrdering>
void list<_Tp, _Alloc>::sort(_StrictWeakOrdering __comp)
{
	// Do nothing if the list has length 0 or 1.
	if (_M_node->_M_next != _M_node && _M_node->_M_next->_M_next != _M_node) {
		list<_Tp, _Alloc> __carry;
		list<_Tp, _Alloc> __counter[64];
		int __fill = 0;
		while (!empty()) {
			__carry.splice(__carry.begin(), *this, begin());
			int __i = 0;
			while (__i < __fill && !__counter[__i].empty()) {
				__counter[__i].merge(__carry, __comp);
				__carry.swap(__counter[__i++]);
			}
			__carry.swap(__counter[__i]);
			if (__i == __fill) ++__fill;
		}

		for (int __i = 1; __i < __fill; ++__i)
			__counter[__i].merge(__counter[__i - 1], __comp);
		swap(__counter[__fill - 1]);
	}
}


__STL_END_NAMESPACE
