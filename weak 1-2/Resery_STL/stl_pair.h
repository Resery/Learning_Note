#pragma once

#include "stl_config.h"

__STL_BEGIN_NAMESPACE
template<class _T1, class _T2>
struct pair {
    typedef _T1 first_type;     
    typedef _T2 second_type;
    _T1 first;
    _T2 second;
    //构造函数
    pair() : first(_T1()), second(_T2()) {}
    //构造函数
    pair(const _T1& __a, const _T2& __b) : first(__a), second(__b) {}
    //拷贝构造函数
    template<class _U1, class _U2>
    pair(const pair<_U1, _U2>& __p) : first(__p.first), second(__p.second) {}
};
//==操作符重载，即判断x和y的first和sencond是否相等
template<class _T1, class _T2>
inline bool operator==(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) {
    return __x.first == __y.first && __x.second == __y.second;
}
//<操作符重载，这个只要x的first或这second有一个小于y的first或者second即返回1也就是小于
template<class _T1, class _T2>
inline bool operator<(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) {
    return __x.first < __y.first ||
        (!(__y.first < __x.first) && __x.second < __y.second);
}
//!=操作符重载，利用上面的==操作符重载
template<class _T1, class _T2>
inline bool operator!=(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) {
    return !(__x == __y);
}
//>操作符重载，利用上面的<操作符重载
template<class _T1, class _T2>
inline bool operator>(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) {
    return __y < __x;
}
//>操作符重载，利用上面的<操作符重载
template<class _T1, class _T2>
inline bool operator<=(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) {
    return !(__y < __x);
}
//>操作符重载，利用上面的<操作符重载
template<class _T1, class _T2>
inline bool operator>=(const pair<_T1, _T2>& __x, const pair<_T1, _T2>& __y) {
    return !(__x < __y);
}
//构造一个pair
template<class _T1, class _T2>
inline pair<_T1, _T2> make_pair(const _T1& __x, const _T2& __y) {
    return pair<_T1, _T2>(__x, __y);
}
__STL_END_NAMESPACE
