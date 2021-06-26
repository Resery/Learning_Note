# Rust Note

## 概述

此文档主要作为 Rust 的笔记，并且如果说在学习 Rust 期间使用 Rust 写了某些小工具的话，在写的过程中的新的也会记录在这个文档中

## 环境相关内容

rustup 是一个命令行工具，用来管理 rust 的版本以及与 rust 相关的工具

cargo 是一个包管理器，可以很容易的帮助我们构建一个 rust 工程文件，当我们需要一些新的库时，可以在 config.toml 文件中添加上响应库的描述，在第一次编译的时候就可以自动拉取内容并进行下载

## 常见概念

### 变量与可变量

在 rust 中声明变量时，声明的变量默认为不可改变的，也就是说我们不可以对同一个变量进行两次赋值，比如说下面的代码就是错误的

```rust
fn main() {
	let x = 5;
	println!("The value of x is {}", x);
	x = 6;					// 错误，x 为不可变变量，所以这里再次给 x 进行复制会导致一个错误
	println!("The value of x is {}", x);
}
```

如果说我们声明一个变量后续还想要继续修改的话，那么在声明是需要加上 mut 来修饰这个变量，代码如下所示

```rust
fn main() {
	let mut x = 5;
	println!("The value of x is {}", x);
	x = 6;
	println!("The value of x is {}", x);
}
```

常数与不可变变量的区别
1. 不允许对常量使用 mut
2. 声明 const 时使用 const 关键字而不是用 let 关键字，并且声明的常量的类型必须显式的指出
3. 常量只能被设置为表达式，不能用作函数对返回值，换句话说也就是常量不能作为任何其他只能在运行时计算出的值

**rust 中还有隐藏这一个概念**

隐藏用代码举例来说，就是下面代码中对第二个和第三个 `let x = x + 1; let x = x * 2;`，属于是将原先的变量 x 进行了隐藏，换句话说就是每个 x 都是一个新对变量，所以说可以对这种不可变变量进行赋值

```rust
fn main() {
	let x = 5;
	let x = x + 1;
	let x = x * 2;

	println!("The value of x is {}", x);
}
```

下面这段代码就是另一个更为明显对例子

```rust
fn main() {
	let spaces = "Test Message";
	let spaces = spaces.len();		// 正确，因为这里对 spaces 是一个新的变量所以说即使更改了 spaces
						// 的类型也依然正确
	let mut spaces = "Test Message";
	spaces = spaces.len();			// 错误，因为这里 spaces 虽说为一个可变变量，但是这里修改了它的类型，
						// 修改变量类型是不被允许对，所以这里在编译时是会报错的
}
```

### 数据类型

整数

| 长度 | 有符号 | 无符号 |
| ----	| ---- | ---- |
| 8-bit | i8 | u8 |
| 16-bit | i16 | u16 |
| 32-bit | i32 | u32 |
| 64-bit | i64 | u64 |
| 128-bit | i128 | u128 |
| arch | isize | usize |

整形字面值

| 数字字面值 | 例子 |
| ---- | ---- |
| Decimal(十进制) | 98_222 |
| Hex(十六进制) | 0xff |
| Octal(八进制) | 0o77 |
| Binary(二进制) | 0b1111_0000 |
| Byte(单字节字符)(仅限于 u8) | b'A' |

浮点类型

默认为 64 位(f64)，显示指定了的情况下为 32 位(f32)

元组

元组是一个将多个其他类型的值组合进一个复合类型的主要方式。元组长度固定：一旦声明，其长度不会增大或缩小。下面的代码是使用元组的方法

```rust
fn main() {
	let tup: (i32, f64, u8) = (500, 6.4, 1);
	let tup = (500, 6.4, 1);
	let (x, y, z) = tup;

	println!("The value of y is {}", y);

	let x: (i32, f64, u8) = (500, 6.4, 1);
	let five_hundred = x.0;
	let six_point_four = x.1;
	let one = x.3;
}

数组类型

rust 中的数组长度一旦声明就不再可以改变

下面的代码展示了 3 种声明数组的方法

```rust
fn main() {
	let a = [1, 2, 3, 4, 5];		// 直接显示定义5个变量

	let a: [i32; 5] = [1, 2, 3, 4, 5];	// 定义时表明数组的范围并且定义好 5 个值

	let a = [3; 5];				// 此条语句与 let a = [3, 3, 3, 3, 3] 语义相同
}
```

rust 中虽然可以使用变量作为数组下标，并且即使这个变量的值超过了数组的范围也可以编译通过，但是在运行时是会爆出一个错误的，错误的提示信息就是提示用户说下标越界了

### 函数如何工作

定义函数的示例如下，包括接受参数与指定返回值类型：

```rust
fn func(x: i32, y: i32) -> i32 {
	println!("The value of x is {}", x);
	println!("The value of y is {}", y);

	return x + y;
}
```

关于返回值还可以有如下形式的定义，其中第二个 func2 返回的是一个表达式，在 rust 中表达式是可以作为函数的返回值来返回的，并且也可以声明一个代码块，然后在代码块的最后用表达式来作为返回值，然后将表达式的值赋给一个变量

```rust
fn func1() -> i32 { 5 }

fn func2(x: i32) -> i32 { x + 1 }

fn main() {
	let x = 5;
	let y = {
		let x = 3;
		x + 1;
	}

	println!("The value of y is: {}", y);
}
```

### 注释

```rust
// 行注释

/* 
 * 多行注释
 */

```

## 认识所有权

### 什么是所有权

rust 中的 string 类型由三部分组成：一个指向存放字符串内容内存的指针，一个长度，和一个容量

rust 永远都不会自动地创建数据的“深拷贝”

rust 中的克隆，当我们不知道这个类型具体能存储多大内存的数据时，我们将这个类型的变量赋值给同种类型的变量时必须使用 clone 来复制出一份拷贝，但是当我们知道类型的大小时就可以不使用 clone 直接将变量赋值给另一个变量即可，示例如下：

```rust
fn main() {
	let x = String::from("Hello World!");
	let y = x.clone();

	let x = 5;
	let y = x;
}
```

所有权与函数

直接看下面的例子即可，根据例子即可知道所有权在函数调用中是如何传递的：

> Rust 有一个叫做 Copy trait 的特殊注解，可以用在类似整型这样的存储在栈上的类型上。如果一个类型拥有 Copy trait，一个旧的变量在将其赋值给其他变量后仍然可用。Rust 不允许自身或其任何部分实现了 Drop trait 的类型使用 Copy trait。如果我们对其值离开作用域时需要特殊处理的类型使用 Copy 注解，将会出现一个编译时错误。

```rust
	fn main() {
	let s = String::from("hello");

	takes_ownership(s);

	println!("The value of s is {}", s);	// 这里会报错，因为调用函数时，s 的所有权被传入到了参数中
						// 并且在函数调用结束后，会自动释放参数的内存，所以说 s
						// 在函数调用后属于无效状态

	let x = 5;

	makes_copy(x);

	println!("The value of x is {}", x);	// 这里是不会报错的，因为这里 x 为 i32 类型并且 i32 为
						// Copy 的，所以在函数调用结束后依然可以继续使用
}

fn takes_ownership(some_string: String) {
	println!("{}", some_string);
}

fn makes_copy(some_integer: i32) {
	println!("{}", some_integer);
}
```

所有权与返回值

返回值也可以用来转移所有权，示例如下：

```rust
fn main() {
	let s1 = give_ownership();

	println!("The value of s1 is {}", s1);

	let s2 = String::from("hello");

	let s3 = takes_and_gives_back(s2);

	println!("The value of s3 is {}", s3);
}

fn give_ownership() -> String {
	let some_string = String::from("hello");
	some_string
}

fn takes_and_gives_back(a_string: String) -> String {
	a_string
}
```

### 引用与借用

Rust 的官方文档中写的 & 为引用的意思，但是其还有一个称为 ref 的关键字，并且文档中指明如果 & 用作为函数参数，那么这个 & 是作为借用来使用的，示例如下：

```rust
fn main() {
	let s1 = String::from("hello");

	let len = calculate_length(&s1);

	println!("The length of '{}' is {}.", s1, len);
}

fn calculate_length(s: &String) -> usize {
	s.len()
}
```

但是我们是无法修改借用的值的也就是说下面这样的代码在编译时是会报错的

```rust
fn main() {
	let s = String::from("hello");

	change(&s);
}

fn change(some_string: &String) {
	some_string.push_str(", world");	// 错误，无法修改借用的值
}
```

如果想要修改引用的值的话需要将其声明为可变引用，不过可变引用有一个限制，就是在特定作用域内只能有一个可变引用，比如下面的代码就是错误的

```rust
let mut s = String::from("hello");

let r1 = &mut s;
let r2 = &mut s;	// 错误，在这个作用域内只能有一个 s 的可变引用

println!("{}, {}", r1, r2);
```

类似的下面这段代码也是错误的，因为我们也不能同时拥有可变引用与不可变引用

```rust
let mut s = String::from("hello");

let r1 = &s;
let r2 = &s;
let r3 = &mut s;

println!("{}, {}, and {}", r1, r2, r3);
```

一个引用的作用域从声明的地方开始一直持续到最后一次使用为止，所以说上面的代码按照下面更改之后就不会报错了

```rust
let mut s = String::from("hello");

let r1 = &s;
let r2 = &s;
println!("{}, {}", r1, r2);

let r3 = &mut s;
println!("{}", r3);
```

悬垂引用

悬垂引用的一个实例就是我们的函数在内部声明了一个变量，并且这个变量作为返回值来进行返回，但是由于变量是在函数内部进行声明的，所以在函数调用结束后就会将这个变量相应的内存给释放掉，也就导致我们会返回一个引用，但是引用中的内容已经不受我们控制了，如下所示

```rust
fn main() {
	let reference_to_nothing = dangle();
}

fn dangle() -> &String {
	let s = String::from("hello");

	&s	// 错误
}
```

解决上面问题的方法就是返回 s 而不是返回引用，因为返回 s 时我们返回的就是 s 的所有权，也就意味着所有权进行了转移，如下所示

```rust
fn main() {
	let reference_to_nothing = dangle();
}

fn dangle() -> String {
	let s = String::from("hello");

	s
}
```

### Slices

Slice 和 python 中的切片用法基本一致，简单的使用示例代码如下：

```rust
fn main() {
    let s = String::from("hello world");

    let hello = &s[0..5];
    let world = &s[6..11];

    println!("{}", hello);
    println!("{}", world);

    println!("{}", &s[..2]);
    println!("{}", &s[2..]);

    println!("{}", &s[0..s.len()]);
    println!("{}", &s[..]);
}
```

字符串字面值就是 slice ，例如下面代码中的 s 的类型是 &s，他是一个指向二进制程序特定位置的 slice。这也就是为什么字符串字面值是不可变的；&str 是不可变引用

```rust
let s = "hello world";
```

数组也可以使用 slice，代码示例如下：

```rust
```

## 使用结构体来组织相关联的数据

### 定义并实例化结构体

声明与定义一个结构体示例代码如下：

```rust
struct User {
	username: String,
	email: String,
	sign_in_count: u64,
	active: bool,
}

let user1 = User {
	email: String::from("resery.email@gmail.com"),
	username: String::from("resery"),
	active: true,
	sign_in_count: 1,
}

let mut user1 = User {
	email: String::from("resery.email@gmail.com"),
	username: String::from("resery"),
	active: true,
	sign_in_count: 1,
};

user1.email = String::from("18700057065@qq.com");
```

rust 不允许只将某个字段标记为可变

另一个利用变量与字段同名时的字段初始化简写语法

```rust
fn build_user(email: String, username: String) -> User {
	User {
		email,
		username,
		active: true,
		sign_in_count: 1,
	}
}
```

利用另一个结构体来初始化新的结构体示例代码如下：

```rust
let user2 = User {
	email: String::from("resery.email@gmail.com"),
	username: String::from("resery"),
	active: user1.active,
	sign_in_count: user1.sign_in_count,
}

let user2 = User {
	email: String::from("resery.email@gmail.com"),
	username: String::from("resery"),
	..user1
}
```

定义元组结构体示例代码如下：

```rust
struct Color(i32, i32, i32);
struct Point(i32, i32, i32);

let black = Color(0, 0, 0);
let orign = Point(0, 0, 0);

// 注意 black 和 origin 的值类型是不同的，因为他们是不同的元祖结构体实例。你定义的每一个结构体
// 有其自己的类型，即使结构体中的字段有着相同的类型。
```

关于结构体的输出，使用 '{:?}' 会让 println 用一种 Debug 的输出格式来进行输出，Debug 是一个 trait，它允许我们以一种开发者有帮助的方式打印结构体，使用 '{:#?}' 和上面功能相同只不过会以一种更漂亮的形式进行输出，示例代码如下：

```rust
#[derive(Debug)]
struct Rectangle {
	width: u32,
	height: u32,
}

fn main() {
	let rect1 = Rectangle { width: 30, height: 50 };

	println!("rect1 is {:?}", rect1);
	println!("rect1 is {:#?}", rect1);
}

output:

rect1 is Rectangle { width: 30, height: 50 }
rect1 is Rectangle {
    width: 30,
    height: 50,
}
```

### 方法语法

示例代码如下：

```rust
#[derive(Debug)]
struct Rectangle {
	width: u32,
	height: u32,
}

impl Rectangle {
    fn area(&self) -> u32 {
        self.width * self.height
    }
}

fn main() {
	let rect1 = Rectangle { width: 30, height: 50 };

	println!("The area of the rectangel is {} square pixels.", rect1.area());
}
```

使用方法替换函数，除了可使用方法语法和不需要在每个函数签名中重复 self 类型之外，其主要好处在于组织性。我们将某个类型示例所能做的所有事情都一起放入一个 impl 块中，而不是让将来的用户在我们的库中到处寻找 Rectangle 的功能

rust 中没有 -> 运算符。相反，rust 中有一个叫 自动引用和解引用的功能

impl 块的另一个有用的功能是：允许在 impl 块中定义不以 self 作为参数的函数。这被称为关联函数，它们仍是函数而不是方法，因为它们并不作用于一个结构体的实例，示例代码如下：

```CPP
impl Rectangle {
	fn square(size: u32) -> Rectangle {
		Rectangle { width: size, height: size }
	}
}

let sq = Rectangle::square(3);
```

每个结构体可以拥有多个 impl 块，比如上面的代码也可以写成这样：

```rust
impl Rectangle {
	fn area(&self) -> u32 {
		self.width * self.height
	}
}

impl Rectangle {
	fn can_hold(&self, Other: &Rectangle) -> bool {
		self.width > Other.width && self.height > Other.height
	}
}
```

## 枚举于模式匹配

声明于定义枚举示例代码如下：

```rust
enum IpAddr {
	V4(u8, u8, u8, u8),
	V6(String),
}

let home = IpAddr::V4(127, 0, 0, 1);
let loopback = IpAddr::V6(String::from("::1"));
```

标准库中定义 IpAddr 的代码如下，下面的代码展示了可以将任意类型的数据放入枚举成员中：例如字符串、数字类型或者结构体。甚至可以包含另一个枚举

```rust
struct Ipv4Addr {
	// --snip--
}

struct Ipv6Addr {
	// --snip--
}

enum IpAddr {
	V4(Ipv4Addr),
	V6(Ipv6Addr),
}
```

```rust
enum Message {
	Quit,
	Move { x: i32, y: i32},
	Write(String),
	ChangeColor(i32, i32, i32),
}
```

枚举和结构体一样都可以使用 impl 来为自己定义方法，示例代码如下：

```rust
impl Message {
	fn call(&self) {
		// 在这里定义方法
	}
}

let m = Message::Write(String::from("hello"));
m.call();
```

Option<T> 枚举的使用示例代码如下：

```rust
enum Option<T> {
	Some(T),
	None,
}

let some_number = Some(5);
let some_string = Some("a string");

let absent_number: Option<i32> = None;

let x: i8 = 5;
let y: Option<i8> = None;

let sum = x + y;  	// 错误，因为他尝试将 Option<i8> 与 i8 相加
```

match 的示例代码如下：

```rust
enum Coin {
	Penny,
	Nickel,
	Dime,
	Quarter,
}

fn value_in_cents(coin: Coin) -> u8 {
	match coin {
		Coin::Penny => {
			println!("Lucky penny!");
			1
		},
		Coin::Nickel => 5,
		Coin::Dime => 10,
		Coin::Quarter => 25,
	}
}
```

匹配分支的另一个有用的功能是可以绑定匹配的模式的部分值，示例代码如下：

```rust
#[derive(Debug)]
enum UsState {
	Alabama,
	Alaska,
	// --snip--
}

enum Coin {
	Penny,
	Nickel,
	Dime,
	Quarter(UsState),
}
```

Rust 中匹配是穷尽的：必须穷举到最后的可能性来使代码有效，示例代码如下：

```rust
fn plus_one(x: Option<i32>) -> Option<i32> {
	match x {
		None => None,
		Some(i) => Some(i + 1),
	}
}
```

Rust 也提供了一个模式用于不想列举出所有可能值的场景。例如 u8 可以拥有 0 到 255 范围的值，如果我们只关心1、3、5、7这几个值，就不必列出0、2、4、6、8、9 一直到 255 范围内的值。这里我们可以使用 `_` 替代：

```rust
let some_u8_value = 0u8;

match some_u8_value {
	1 => println!("one"),
	3 => println!("three"),
	5 => println!("five"),
	7 => println!("seven"),
	_ => (),
}
```

if let 示例代码如下：

```rust
let mut count = 0;
if let Coin::Quarter(state) = coin {
	println!("State qurater from {:?}!", state);
} else {
	count += 1;
}
```

## 使用包、Crate 和模块管理不断增长的项目

- 包（Packages）： Cargo 的一个功能，它允许你构建、测试和分享 crate。
- Crates ：一个模块的树形结构，它形成了库或二进制项目。
- 模块（Modules）和 use： 允许你控制作用域和路径的私有性。
- 路径（path）：一个命名例如结构体、函数或模块等项的方式

模块示例代码如下：

```rust
mod front_of_house {
	mod hosting {
		fn add_to_waitlist() {}
		fn seat_at_table() {}
	}

	mod serving {
		fn take_over() {}
		fn server_order() {}
		fn take_payment() {}
	}
}

// 对应的模块树的结构
crate
 └── front_of_house
     ├── hosting
     │   ├── add_to_waitlist
     │   └── seat_at_table
     └── serving
         ├── take_order
         ├── serve_order
         └── take_payment
```