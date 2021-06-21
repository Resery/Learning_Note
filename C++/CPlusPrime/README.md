# C++ Prime Plus 笔记

## 概述

此文档用来记录阅读 C++ Prime Plus 中遇到的一些重点，主要作为自己日后复习的笔记，笔记从模版开始记录，之前的内容会慢慢补充

## 模版

### 模版实参推断

#### 类型转换与模版类型参数

顶层 const 无论是在形参还是在实参中都会被忽略，顶层 const 就是指指针本身是不可改变的 (`int * const p`)

关于 const 的转换，虽然模版被声明为接受 const 类型的形参，但是它也可以接受非 const 类型的实参，只不过在使用时会将其转换成 const 类型

关于数组或函数指针转换，当模版的形参没有被声明为引用类型时，则可以对数组或函数类型的实参应用正常的指针转换。相反如果形参被声明为引用类型时，那么数组或函数类型的实参是不能进行正常的指针转换的

代码示例：

```CPP
template <typenmae T> T fobj(T, T);			// 实参会被拷贝出一份副本
template <typenmae T> T fref(const T &, const T &);	// 实参以引用的形式来进行传递

string s1("value");
const string s2("const value");

fobj(s1, s2);						// 调用 fobj(string, string); const 被忽略
fref(s1, s2);						// 调用 fref(const string &, const string &);
							// 将 s1 转换为 const 是允许的
int a[10], b[42];
fobj(a, b);						// 调用 f(int *, int *)
fref(a, b);						// 错误：数组类型不匹配
```

#### 使用相同模版参数类型的函数形参

这个转换规则的意思就是当我们声明一个模版接受几个同种引用类型的参数，那么传入这个函数的实参类型必须为相同的

举个例子

```CPP
long lng;
compare(lng, 1024);	// 错误：不能实例化 compare(long, int)
```

上面这段代码中，compare 被声明为接受两个引用类型的模版函数，传入实参时 compare 的第一个实参 lng 其类型为 long，第二个实参 1024 为 int，因为两个参数类型不同所以说这条语句时错误的

如果想要传入不同类型的引用实参，解决办法就是在声明模版时参数模版中的类型设置为不同种的类型即可，如下所示：

```CPP
template <typename A, typename B>
int flexibleCompare(const A& v1, const B& v2) {
	if (v1 < v2) return -1;
	if (v2 < v1) return 1;
	return 0;
}
```

#### 正常类型转换应用于普通函数实参

正常类型转换应用与普通函数实参的意思就是声明一个模版函数，其中参数部分一部分是通过模版来获取具体的参数类型，一部分是直接指明了参数的类型，如下所示：

```CPP
template <typename T> ostream & print(ostrean & os, const T & obj) {
	return os << obj;
}
```

### 函数模版显式实参

#### 指定显示模版实参

举个例子，当我们声明一个模版函数时声明了三个模版参数，其中第一个参数作为了函数的返回值，剩余的两个函数作为了函数的参数，也就是像下面这个样子：

```CPP
template <typename T1, typename T2, typenmae T3>
T1 sum(T2, T3);
```

当我们每次调用 sum 时必须显式的指明 T1 的类型， T1 的类型放在尖括号中，位于函数名之后，实参列表之前，如下所示

```CPP
auto val3 = sum<long long>(i, lng);
```

上例中 T1 的类型是显示指明的，T2 和 T3 的值是编译器通过 i 和 lng 推导出来的

对于指定显示模版实参还有一个特殊的例子，也就是让 T3 作为函数的返回值，然后让 T1， T2作为参数，此时在调用 sum 时需要将所有参数的类型都显示的指明，如下所示：

```CPP
template <typename T1, typename T2, typenmae T3>
T3 sum(T2, T1);

auto val2 = sum<long long>(i, lng);			// 错误的，不能推断出前几个模版参数
auto val3 = sum<long long, int, long>(i, lng);		// 正确的，显式指定了所有三个参数
```

#### 正常类型转换应用于显示指定的实参

在我们定义的普通函数中是允许正常的类型转换的，同样我们定义的模版函数也是可以进行正常的类型转换的，只不过想要支持类型转换的话需要显示指明模版函数中的类型而不能靠编译器的推导，如下所示：

```CPP
long lng;
compare(lng, 1024);		// 错误：模版参数不匹配
compare<long long>(lng, 1024);	// 正确：实例化 compare(long, long)
compare<int>(lng, 1024);	// 正确：实例化 compare(int, int)
```

#### 尾置返回类型与类型转换

尾置返回类型主要就是在我们不能确定返回值类型时来进行使用的，因为尾置返回出现在参数列表之后，所以它可以使用函数的参数

以下面的代码为例

```CPP
template <typename It>
??? &fcn(It beg, It end) {
	return *beg;
}

vector<int> vi = {1, 2, 3, 4, 5};
Blob<string> ca = { "hi", "bye" };
auto &i = fcn(vi.begin(), vi.end());	// 应该返回一个 int & 的引用
auto &s = fcn(ca.begin(), ca.end());	// 应该返回一个 string & 的引用
```

下面的代码就展示了如何使用尾置返回类型来解决上面的问题，代码如下：

```CPP
template <typenmae It>
auto & fcn(It beg, It end) -> decltype(*beg) {
	return * beg;
}
```

#### 进行类型转换的标准库模版类

使用标准库模版类的主要目的就是为了返回一个具体的值类型而不是返回一个引用了，上面我们使用尾置返回类型只可以返回引用而不可以返回值，这里使用的是 type_traits 中的 remove_reference 来获取元素类型，代码如下：

```CPP
template <typename It>
auto fcn2(It beg, It end) -> 
	typename remove_reference<decltype(*beg)>::type
{
	return * beg;
}
```

需要注意的是，因为 type 是一个类的成员，而该类依赖于一个模版参数。因此，我们必须在返回类型的声明中使用 typename 来告知编译器，type 表示一个类型

标准类型转换模版如下：

![](img/stand_type_convert_template.png)

#### 函数指针和实参推断

模版函数也可以作为实参传给接受函数指针为参数的函数，只不过在传参的时候需要显示指明模版中的参数类型，并且我们还可以让声明一个函数指针，然后让函数指针指向一个模版函数的实例，如下所示

```CPP
template <typename T> int compare(const T &, const T &);

int (*pf1)(const int &, const int &) = compare;

void func(int(*)(const string &, const string &));
void func(int(*)(const int &, const int &));
func(compare);						// 错误，不知道具体是哪个 compare 实例
func(compare<int>);					// 正确，会以 compare<int> 实例来初始化 func
```

#### 模版实参推断和引用

##### 从左值引用函数参数推断类型

只接受一个左值作为参数，使用如下定义：

```CPP
template <typename> void f1(T&);

f1(i);		// 正确，i 是一个 int，模版参数类型 T 是 int
f1(ci);		// 正确，ci 是一个 const int， 模版参数类型 T 是 const int
fi(5);		// 错误，模版只接受左值作为参数，然后 5 属于右值
```

既可以接受左值，也可以接受右值作为参数，使用如下定义：

```CPP
template <typename> void f2(const T&)

f2(i);		// 正确，i 是一个 int，模版参数类型 T 是 int
f2(ci);		// 正确，ci 是一个 const int，模版参数类型 T 是 const int
f2(5);		// 正确，一个 const & 参数是可以绑定到一个右值上的，T 是 int
```