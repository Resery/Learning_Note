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

使用下面的命令来创建一个名为 restaurant 的库

```
cargo new --lib restaurant
```

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

src/main.rs 和 src/lib.rs 叫做 crate 的根

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

路径有两种形式：

- 绝对路径（absolute path）从 crate 根开始，以 crate 名或者字面值 crate 开头。
- 相对路径（relative path）从当前模块开始，以 self、super 或当前模块的标识符开头。

以绝对路径和相对路径调用 front_of_house 模块的子模块 hosting 模块中的 add_to_waitlist 函数示例代码如下：

```rust
mod front_of_house {
	mod hosting {
		fn add_to_waitlist() {}
	}
}

pub fn eat_at_restaurant() {
	// Absolute path
	crate::front_of_house::hosting::add_to_waitlist();
	// Relative path
	front_of_house::hosting::add_towaitlist();
}
```

上面的代码会提示编译错误，这是因为 rust 的私有性边界，也就是说 hosting 模块对我们来说是私有的没有办法访问

模块不仅对于你组织代码很有用。他们还定义了 Rust 的 私有性边界（privacy boundary）：这条界线不允许外部代码了解、调用和依赖被封装的实现细节。所以，如果你希望创建一个私有函数或结构体，你可以将其放入模块。

Rust 中默认所有项（函数、方法、结构体、枚举、模块和常量）都是私有的。父模块中的项不能使用子模块中的私有项，但是子模块中的项可以使用他们父模块中的项。这是因为子模块封装并隐藏了他们的实现详情，但是子模块可以看到他们定义的上下文。

为了解决私有性边界的问题，我们可以使用 pub 关键字来修饰模块，使用 pub 关键字修饰模块之后，其就会变成公有的我们也就可以访问了，示例代码如下：

```rust
mod front_of_house {
	pub mod hosting {
		fn add_to_waitlist() {}
	}
}

pub fn eat_at_restaurant() {
	crate::front_of_house::hosting::add_to_waitlist();

	front_of_house::hosting::add_to_waitlist();
}
```

上面的代码按照这样修改之后还是会报错的，这是因为 hosting 此时对于我们不是私有的了，但是 hosting 中的成员还是私有的，如果想要访问 hosting 的成员仍需使用 pub 关键字来修饰 hosting 的成员，示例代码如下：

```rust
mod front_of_house {
	pub mod hosting {
		pub fn add_to_waitlist() {}
	}
}

pub fn eat_at_restaurant() {
	crate::front_of_house::hosting::add_to_waitlist();

	front_of_house::hosting::add_to_waitlist();
}
```

使用 super 起始的相对路径，super 就相当于文件路径中的 .. 一样，super 就是会指向当前模块的父模块，示例代码如下：

```rust
fn server_order() {}

mod back_of_house() {
	fn fix_incorrect_order() {
		cook_order();
		super::serve_order();
	}

	fn cook_order();
}
```

我们还可以使用 pub 来设计公有的结构体和枚举，不过有一些额外的细节需要注意。如果我们在一个结构体定义的前面使用了 pub ，这个结构体会变成公有的，但是这个结构体的字段仍然是私有的。我们可以根据情况决定每个字段是否公有。示例代码如下：

```rust
mod back_of_house {
	pub struct Breakfast {
		pub toast: String,
		seasonal_fruit: String,
	}

	impl Breakfast {
		pub fn summer(toast: &str) -> Breakfast {
			Breakfast {
				toast: String::from(toast),
				seasonal_fruit: String::from("peaches"),
			}
		}
	}
}

pub fn eat_at_restaurant() {
	let mut meal = back_of_house::Breakfast::summer("Rye");

	meal.toast = String::from("Wheat");
	println!("I'd like {} toast please", meal.toast);
}
```

枚举与结构体不同，如果我们在一个模块中将枚举声明为公有的，那么枚举中的所有成员都会是公有的。示例代码如下：

```rust
mod back_of_house {
	pub enum Appetizer {
		Soup,
		Salad,
	}
}

pub fn eat_at_restaurant() {
	let order1 = back_of_house::Appetizer::Soup;
	let order2 = back_of_house::Appetizer::Salad;
}
```

我们可以使用 use 关键字将路径一次性引入作用域，然后调用该路径中的项，就如同它们是本地项一样。示例代码如下：

```rust
mod front_of_house {
	pub mod hosting {
		pub fn add_to_waitlist() {}
	}
}

use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
	hosting::add_to_waitlist();
	hosting::add_to_waitlist();
	hosting::add_to_waitlist();
}
```

上面的代码中使用的是绝对路径，但是 use 其实也是可以接受一个相对路径的，示例代码如下：

```rust
mod front_of_house {
	pub mod hosting {
		pub fn add_to_waitlist() {}
	}
}

use front_of_house::hosting;

pub fn eat_at_restaurant() {
	hosting::add_to_waitlist();
	hosting::add_to_waitlist();
	hosting::add_to_waitlist();
}
```

使用 use 将两个同名类型引入同一作用域这个问题还有另一个解决办法：在这个类型的路径后面，我们使用 as 指定一个新的本地名称或者别名。示例代码如下：

```rust
use std::fmt::Result;
use std::io::Result as IoResult;

fn function1() -> Result {
	// --snip--
}

fn function2() -> IoResult<()> {
	// --snip--
}
```

当使用 use 关键字将名称导入作用域时，在新作用域中可用的名称是私有的。如果为了让调用你编写的代码的代码能够像在自己的作用域内引用这些类型，可以结合 pub 和 use。这个技术被称为 “重导出（re-exporting）”，因为这样做将项引入作用域并同时使其可供其他代码引入自己的作用域。示例代码如下：

```rust
mod front_of_house {
	pub mod hosting {
		pub fn add_to_waitlist() {}
	}
}

pub use crate::front_of_house::hosting;

pub fn eat_at_restaurant() {
	hosting::add_to_waitlist();
	hosting::add_to_waitlist();
	hosting::add_to_waitlist();
}
```

通过 pub use，现在可以通过新路径 hosting::add_to_waitlist 来调用 add_to_waitlist 函数。如果没有指定 pub use，eat_at_restaurant 函数可以在其作用域中调用 hosting::add_to_waitlist，但外部代码则不允许使用这个新路径。

为了在项目中使用 rand，在 Cargo.toml 中加入了如下行：

文件名: Cargo.toml
```
[dependencies]
rand = "0.5.5"
```

在 Cargo.toml 中加入 rand 依赖告诉了 Cargo 要从 crates.io 下载 rand 和其依赖，并使其可在项目代码中使用。

接着，为了将 rand 定义引入项目包的作用域，我们加入一行 use 起始的包名，它以 rand 包名开头并列出了需要引入作用域的项。回忆一下第二章的 “生成一个随机数” 部分，我们曾将 Rng trait 引入作用域并调用了 rand::thread_rng 函数：

```rust
use rand::Rng;

fn main() {
    let secret_number = rand::thread_rng().gen_range(1, 101);
}
```

crates.io [](https://crates.io/) 上有很多 Rust 社区成员发布的包，将其引入你自己的项目都需要一道相同的步骤：在 Cargo.toml 列出它们并通过 use 将其中定义的项引入项目包的作用域中。

注意标准库（std）对于你的包来说也是外部 crate。因为标准库随 Rust 语言一同分发，无需修改 Cargo.toml 来引入 std，不过需要通过 use 将标准库中定义的项引入项目包的作用域中来引用它们，比如我们使用的 HashMap：

```rust
use std::collections::HashMap;
```

这是一个以标准库 crate 名 std 开头的绝对路径。

我们可以使用嵌套路径将相同的项在一行中引入作用域。这么做需要指定路径的相同部分，接着是两个冒号，接着是大括号中的各自不同的路径部分，示例代码如下所示：

```rust
use std::cmp::Ordering;
use std::io;
	|
	V
use std::{cmp::Ordering, io};

use std::io;
use std::io::Write;
	|
	V
use std::io{self, Write};
```

如果希望将一个路径下 所有 公有项引入作用域，可以指定路径后跟 *，glob 运算符：

```rust
use std::collections::*;
```

这个 use 语句将 std::collections 中定义的所有公有项引入当前作用域。使用 glob 运算符时请多加小心！Glob 会使得我们难以推导作用域中有什么名称和它们是在何处定义的。

## 常见集合

### vector

新建 vector 示例代码如下：

```rust
// 新建一个空的 vector 来存储 i32 类型的值
let v: Vec<i32> = Vec::new();
// 新建一个包含初值的 vector
let v = vec![1, 2, 3];
```

更新一个 vector 示例代码如下：

```rust
let mut v = Vec::new();

v.push(5);
v.push(6);
v.push(7);
v.push(8);
```

读取 vector 的元素示例代码如下：

```rust
let v = vec![1, 2, 3, 4, 5];

let thrid: &i32 = &v[2];
println!("The thrid element is {}", thrid);

match v.get(2) {
	Some(thrid) => println!("The third element is {}", third),
	None => println!("There is no third element."),
}
```

当 get 方法传递了一个数组外的索引时，他不会 panic 而是返回 None。当偶尔出现超过 vector 范围的访问属于正常情况的时候可以考虑它。

不能在相同作用域中同时存在可变和不可变引用，所以当我们获取了 vector 的第一个元素的不可变引用并尝试在 vector 末尾增加一个元素时，这是行不通的：

```rust
let mut v = [1, 2, 3, 4, 5];

let first = &v[0];

v.push(6);

println!("The first element is: {}", first);
```

vector 的工作方式：在 vector 的结尾增加新元素时，在没有足够空间将所有所有元素依次相邻存放的情况下，可能会要求分配新内存并将老的元素拷贝到新的空间中。

遍历 vector 中的元素，示例代码如下：

```rust
let v = vec![1, 2, 3, 4, 5];

// 通过 for 循环遍历 vector 的元素并打印
for i in &v {
	println!("{}", i);
}

let mut v = vec![100, 32, 57];

for i in mut &v {
	*i += 50;
}
```

枚举的成员都被定义为相同的枚举类型，所以当需要在 vector 中储存不同类型值时，我们可以定义并使用一个枚举！，示例代码如下：

```rust
enum SpreadsheetCell {
	Int(i32),
	Float(f64),
	Text(String),
}

let row = vec![
	SpreadsheetCell::Int(3),
	SpreadsheetCell::Text(String::from("blue")),
	SpreadsheetCell::Float(10.12),
];
```

### 字符串

新建字符串示例代码如下：

```rust
let mut s = String::new();

let data = "initial contents";

let s = data.to_string();

let s = "initial contents".to_string();

let s = String::from("initial contents");
```

更新字符串示例代码如下：

```rust
let mut s = String::from("foo");
s.push_str("bar");

let mut s1 = String::from("foo");
let s2 = "bar";
s1.push_str(s2);
println!("s2 is {}", s2);

let mut s = String::from("lo");
s.push('l');
```

使用 + 运算符或 format! 宏拼接字符串

```rust
let s1 = String::from("Hello, ");
let s2 = String::from("world!");
let s3 = s1 + &s2;	// 注意 s1 被移动了，不能继续使用

let s1 = String::from("tic");
let s2 = String::from("tac");
let s3 = String::from("toe");
let s = format!("{}-{}-{}", s1, s2, s3);
```

Rust 的字符串不支持索引。

遍历字符串的方法示例代码如下：

```rust
for c in "नमस्ते".chars() {
    println!("{}", c);
}

output:

न
म
स
्
त
े

for b in "नमस्ते".bytes() {
    println!("{}", b);
}

output:

224
164
// --snip--
165
135
```

### 哈希 map

新建 HashMap 示例代码如下：

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Yellow"), 50);
```

哈希 map 所有的键必须是相同类型，值也必须都是相同类型

另一种新建 HashMap 的方法，示例代码如下：

```rust
use std::collections::HashMap;

let teams = vec![String::from("Blue"), String::from("Yellow")];
let initial_scores = vec![10, 50];

let scores: HashMap<_, _> = teams.iter().zip(initial_scores.iter()).collect();
```

对于像 i32 这样的实现了 copy 的类型，其值可以拷贝进哈希 map。对于像 String 这种有所有权的值，其值被移动而哈希 map 会成为这些值的所有者，示例代码如下：

```rust
use std::collections::HashMap;

let field_name = String::from("Favortie color");
let field_value = String::from("Blue");

let mut map = HashMap::new();
map.insert(field_name, field_value);
```

当 insert 调用将 field_name 和 field_value 移动到哈希 map 之后，将不能使用这两个绑定

如果将值的引用插入哈希 map，这些值本身将不会被移动进哈希 map。但是这些引用指向的值必须至少在哈希 map 有效时也是有效的。

访问哈希 map 中的值

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Yellow", 50));

let team_name = String::from("Blue");
let score = scores.get(&team_name);

let mut scores = HashMap::new();

scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Yellow", 50));

for (key, value) in &scores {
	println!("{}: {}", key, value);
}

output:

Yellow: 50
Blue: 10
```

更新哈希 map 示例代码如下：

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();

scores.insert(String::from("Blue"), 10);
scores.insert(String::from("Blue"), 50);

println!("{:?}", scores);
```

只在键没有对应值时插入：

```rust
use std::collections::HashMap;

let mut scores = HashMap::new();
scores.insert(String::from("Blue"), 10);

scores.entry(String::from("Yellow")).or_insert(50);
scores.entry(String::from("Blue")).or_insert(50);

println!("{:?}", scores);
```

根据旧值更新一个值：

```rust
use std::collections::HashMap;

let text = "hello world wonderful world";

let mut map = HashMap::new();

for word in text.split_whitespace() {
	let count = map.entry(word).or_insert(0);
	*count += 1;
}

println!("{:?}", map);
```

## 错误处理

如果 Result 值是成员 Ok，unwrap 会返回 Ok 中的值。如果 Result 是成员 Err，unwrap 会为我们调用 panic!。示例代码如下：

```rust
use std::fs::File;

fn main() {
	let f = File::open("hello.txt").unwrap();
}

output:

thread 'main' panicked at 'called 'Result::unwrap()' on an 'Err' value: Error {
repr: Os { code: 2, message: "No such file or directory"} }',
src/libcore/result.rs:906:4
```

还有另一个类似于 unwrap 的方法它还允许我们选择 panic! 的错误信息：expect。使用 expect 而不是 unwrap 并提供一个好的错误信息可以表明你的意图并更易于追踪 panic 的根源。expect 的语法看起来像这样：

```rust
use std::fs::File;

fn main() {
    let f = File::open("hello.txt").expect("Failed to open hello.txt");
}

output:

thread 'main' panicked at 'Failed to open hello.txt: Error { repr: Os { code:
2, message: "No such file or directory" } }', src/libcore/result.rs:906:4
```

当编写一个其实现会调用一些可能会失败的操作的函数时，除了在这个函数中处理错误外，还可以选择让调用者知道这个错误并决定该如何处理。这被称为 传播（propagating）错误，这样能更好的控制代码调用，因为比起你代码所拥有的上下文，调用者可能拥有更多信息或逻辑来决定应该如何处理错误。示例代码如下：

```rust
use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let f = File::open("hello.txt");

    let mut f = match f {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut s = String::new();

    match f.read_to_string(&mut s) {
        Ok(_) => Ok(s),
        Err(e) => Err(e),
    }
}
```

```rust
use std::io;
use std::io::Read;
use std::fs::File;

fn read_username_from_file() -> Result<String, io::Error> {
    let mut f = File::open("hello.txt")?;
    let mut s = String::new();
    f.read_to_string(&mut s)?;
    Ok(s)
}
```

Result 值之后的 ? 被定义为与示例 9-6 中定义的处理 Result 值的 match 表达式有着完全相同的工作方式。如果 Result 的值是 Ok，这个表达式将会返回 Ok 中的值而程序将继续执行。如果值是 Err，Err 中的值将作为整个函数的返回值，就好像使用了 return 关键字一样，这样错误值就被传播给了调用者。

我们还可以使用 ? 运算符来将第一版的代码改成如下形式：

```rust
use std::io;
use std::io::Read;
use std::fd::File;

fn read_username_from_file() -> Result<String, io::Error> {
	let mut s = String::new();

	File::open("hello.txt")?.read_to_string(&mut s)?;

	Ok(s)
}
```

## 泛型

### 泛型数据类型

Rust 类型名的命名规范是骆驼命名法（CamelCase）

声明泛型类型的函数示例代码如下：

```rust
fn largest<T>(list: &[T]) -> T {}
```

结构体中定义的泛型示例代码如下：

```rust
struct Point<T> {
	x: T,
	y: T,
}

fn main() {
	let integer = Point { x: 5, y: 10 };
	let float = Point { x: 1.0, y: 4.0 };
}

struct Point<T, U> {
	x: T,
	y: U,
}

fn main() {
	let both_integer = Point { x: 5, y: 10 };
	let both_float = Point { x: 1.0, y: 4.0 };
	let integer_and_float = Point { x: 5, y: 4.0 };
}
```

枚举定义的泛型示例代码如下：

```rust
enum Option<T> {
	Some(T),
	None,
}

enum Result<T, E> {
	Ok(T),
	Err(E),
}
```

方法定义的泛型示例代码如下：

```rust
struct Point<T> {
	x: T,
	y: T,
}

impl<T> Point<T> {
	fn x(&self) -> &T {
		&self.x
	}
}

fn main() {
	let p = Point { x: 5, y: 10 };
	println!("p.x = {}", p.x());
}
```

方法的泛型特例化示例代码如下：

```rust
impl Point<f32> {
	fn distance_from_origin(&self) -> f32 {
		(self.x.powi(2) + self.y.powi(2)).sqrt()
	}
}
```

方法使用了与结构体定义中不同类型的泛型示例代码如下：

```rust
struct Point<T, U> {
	x: T,
	y: U,
}

impl<T, U> Point<T, U> {
	fn mixup<V, W>(self, other: Point<V, W>) -> Point<T, W> {
		Point {
			x: self.x,
			y: other.y,
		}
	}
}

fn main() {
	let p1 = Point { x: 5, y: 10.4 };
	let p2 = Point { x: "Hello", y: 'c' };

	let p3 = p1.mixup(p2);

	println!("p3.x = {}, p3.y = {}", p3.x, p3.y);
}
```

### trait：定义共享的行为

> 注意：trait 类似于其他语言中的常被称为**接口**的功能，虽然有一些不同。

一个类型的行为由其可供调用的方法构成。如果可以对不同类型调用相同的方法的话，这些类型就可以共享相同的行为了。trait 定义是一种将方法签名组合起来的方法，目的是定义一个实现某些目的所必需的行为的集合。

定义一个 trait 的示例代码如下：

```rust
pub trait Summary {
	fn summarize(&self) -> String;
}
```

在方法签名后跟分号，而不是在大括号中提供其实现。trait 体中可以有多个方法：一行一个方法签名且都以分号结尾。

为类型实现 trait 的示例代码：

```rust
pub struct NewArticle {
	pub headline: String,
	pub location: String,
	pub author: String,
	pub contnet: String,
}

impl Summary for NewsArticle {
	fn summarize(&self) -> String {
		format!("{}, by {} ({})", self.headline, self.author, self.location)
	}
}

pub struct Tweet {
	pub username: String,
	pub content: String,
	pub reply: bool,
	pub retweet: bool,
}

impl Summary for Tweet {
	fn summarize(&self) -> String {
		format!("{}: {}", self.username, self.content);
	}
}

let tweet = Tweet {
	username: String::from("horse_ebooks"),
	content: String::from("of course, as you probably already know, people"),
	reply: false,
	retweet: false,
};

println!("1 new tweet: {}", tweet.summarize());
```

实现 trait 时需要注意的一个限制是，只有当 trait 或者要实现 trait 的类型位于 crate 的本地作用域时，才能为该类型实现 trait。

但是不能为外部类型实现外部 trait。

有时为 trait 中的某些或全部方法提供默认的行为，而不是在每个类型的每个实现中都定义自己的行为是很有用的。这样当为某个特定类型实现 trait 时，可以选择保留或重载每个方法的默认行为。示例代码如下：

```rust
pub trait Summary {
	fn summarize(&self) -> String {
		String::from("(Read more...)")
	}
}

let article = NewsArticle {
    headline: String::from("Penguins win the Stanley Cup Championship!"),
    location: String::from("Pittsburgh, PA, USA"),
    author: String::from("Iceburgh"),
    content: String::from("The Pittsburgh Penguins once again are the best
    hockey team in the NHL."),
};

println!("New article available! {}", article.summarize());

output:

New article available! (Read more...)
```

默认实现允许调用相同 trait 中的其他方法，哪怕这些方法没有默认实现。如此，trait 可以提供很多有用的功能而只需要实现指定一小部分内容。示例代码如下：

```rust
pub trait Summary {
	fn summarize_author(&self) -> String;

	fn summarize(&self) -> String {
		format!("(Read more from {}...)", self.summarize_author())
	}
}

impl Summary for Tweet {
	fn summarize_author(&self) -> String {
		format("@{}", self.username)
	}
}

let tweet = Tweet {
	username: String::from("horse_ebooks"),
	content: String::from("of course, as you probably already know, people"),
	reply: false,
	retweet: false,
}

println!("1 new tweet: {}", tweet.summarize());

output:

1 new tweet: (Read more from @horse_ebooks...)
```

trait 作为参数的示例代码如下：

```rust
pub fn notify(item: impl Summary) {
	println!("Breaking news! {}", item.summarize());
}
```

Traint Bound 语法，下面的代码中可以这样理解，该函数接受一个实现了 Summary trait 的类类型，然后在函数体中，调用参数实现的 trait

```rust
pub fn notify<T: Summary>(item: T) {
	println!("Breaking news! {}", item.summarize());
}
```

impl Trait 适用于短小的例子。trait bound 适用于更复杂的场景，示例代码如下：

```rust
pub fn notify(item1: impl Summary, item2: impl Summary) {}

pub fn notify<T: Summary>(item1: T, item2: T) {}
```

通过 + 指定多个 traint bound，意思也就是传入的参数的类类型需要同时实现 Summary 和 Display trait，示例代码如下：

```rust
pub fn notify(item: impl Summary + Display) {}

pub fn notify<T: Summary + Display>(item: T) {}
```

通过 where 简化 trait bound，下面的代码就是接受两个类类型的参数，第一个类类型需要同时实现 Display 和 Clone trait，第二个类类型需要同时实现 Clone 和 Debug trait

```rust
fn some_function<T: Display + Clone, U: Clone + Debug>(t: T, u: U) -> i32 {}

fn some_function<T, U>(t: T, u: U) -> i32 {
	where T: Display + Clone,
	      U: Clone + Debug
}
```

使用 trait bound 有条件地实现方法，通过使用带有 trait bound 的泛型参数的 impl 块，可以有条件地只为那些实现了特定 trait 的类型实现方法。下面的代码中的类型 Pair<T> 总是实现了 new 方法，不过只有那些为 T 类型实现了 PartialOrd trait （来允许比较） 和 Display trait （来启用打印）的 Pair<T> 才会实现 cmp_display 方法：

```rust
use std::fmt::Display;

struct Pair<T> {
	x: T,
	y: T,
}

impl<T> Pair<T> {
	fn new(x: T, y: T) -> Self {
		Self {
			x,
			y,
		}
	}
}

impl<T: Display + PartialOrd> Pair<T> {
	fn cmp_display(&self) {
		if self.x >= self.y {
			println!("The largest member is x = {}", self.x);
		} else {
			println!("The largest member is y = {}", self.y);
		}
	}
}
```

也可以对任何实现了特定 trait 的类型有条件地实现 trait。对任何满足特定 trait bound 的类型实现 trait 被称为 blanket implementations，他们被广泛的用于 Rust 标准库中。例如，标准库为任何实现了 Display trait 的类型实现了 ToString trait。这个 impl 块看起来像这样：

```rust
impl<T: Display> ToString for T {
	// --snip--
}

let s = 3.to_string();
```

### 生命周期与引用有效性

rust 中作用域越大说明它存在的越久

**生命周期注解并不改变任何引用的生命周期的长短。与当函数签名中指定了泛型类型参数后就可以接受任何类型一样，当指定了泛型生命周期后函数也能接受任何生命周期的引用。生命周期注解描述了多个引用生命周期相互的关系，而不影响其生命周期。**

声明生命周期的示例代码如下：

```rust
&i32		// 引用
&'a i32		// 带有显式生命周期的引用
&'a mut i32	// 带有显式生命周期的可变引用
```

单个的生命周期注解本身没有多少意义，因为生命周期注解告诉 Rust 多个引用的泛型生命周期参数如何相互联系的。例如如果函数有一个生命周期 'a 的 i32 的引用的参数 first。还有另一个同样是生命周期 'a 的 i32 的引用的参数 second。这两个生命周期注解意味着引用 first 和 second 必须与这泛型生命周期存在得一样久。

函数签名中的生命周期注解，示例代码如下：

```rust
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
	if x.len() > y.len() {
		x
	} else {
		y
	}
}
```

现在函数签名表明对于某些生命周期 'a，函数会获取两个参数，他们都是与生命周期 'a 存在的一样长的字符串 slice。函数会返回一个同样也与生命周期 'a 存在的一样长的字符串 slice。它的实际含义是 longest 函数返回的引用的生命周期与传入该函数的引用的生命周期的较小者一致。

但是上面的代码编译时是会失败的

**记住通过在函数签名中指定生命周期参数时，我们并没有改变任何传入值或返回值的生命周期，而是指出任何不满足这个约束条件的值都将被借用检查器拒绝。**

**注意 longest 函数并不需要知道 x 和 y 具体会存在多久，而只需要知道有某个可以被 'a 替代的作用域将会满足这个签名。**

**当具体的引用被传递给 longest 时，被 'a 所替代的具体生命周期是 x 的作用域与 y 的作用域相重叠的那一部分。换一种说法就是泛型生命周期 'a 的具体生命周期等同于 x 和 y 的生命周期中较小的那一个。因为我们用相同的生命周期参数 'a 标注了返回的引用值，所以返回的引用值就能保证在 x 和 y 中较短的那个生命周期结束之前保持有效。**

结构体定义中的生命周期注解

目前为止，我们只定义过有所有权类型的结构体。接下来，我们将定义包含引用的结构体，不过这需要为结构体定义中的每一个引用添加生命周期注解。下面的示例代码中有一个存放了一个字符串 slice 的结构体 ImportantExcerpt：

```rust
struct ImportantExcerpt<'a> {
    part: &'a str,
}

fn main() {
    let novel = String::from("Call me Ishmael. Some years ago...");
    let first_sentence = novel.split('.')
        .next()
        .expect("Could not find a '.'");
    let i = ImportantExcerpt { part: first_sentence };
}
```

这个结构体有一个字段，part，它存放了一个字符串 slice，这是一个引用。类似于泛型参数类型，必须在结构体名称后面的尖括号中声明泛型生命周期参数，以便在结构体定义中使用生命周期参数。这个注解意味着 ImportantExcerpt 的实例不能比其 part 字段中的引用存在的更久。

这里的 main 函数创建了一个 ImportantExcerpt 的实例，它存放了变量 novel 所拥有的 String 的第一个句子的引用。novel 的数据在 ImportantExcerpt 实例创建之前就存在。另外，直到 ImportantExcerpt 离开作用域之后 novel 都不会离开作用域，所以 ImportantExcerpt 实例中的引用是有效的。

函数或方法的参数的生命周期被称为 **输入生命周期（input lifetimes）**，而返回值的生命周期被称为 **输出生命周期（output lifetimes）**。

编译器采用三条规则来判断引用何时不需要明确的注解。**第一条规则适用于输入生命周期**，**后两条规则适用于输出生命周期**。如果编译器检查完这三条规则后仍然存在没有计算出生命周期的引用，编译器将会停止并生成错误。这些规则适用于 fn 定义，以及 impl 块。
- 第一条规则是每一个是引用的参数都有它自己的生命周期参数。换句话说就是，有一个引用参数的函数有一个生命周期参数：`fn foo<'a>(x: &'a i32)`，有两个引用参数的函数有两个不同的生命周期参数，`fn foo<'a, 'b>(x: &'a i32, y: &'b i32)`，依此类推。
- 第二条规则是如果只有一个输入生命周期参数，那么它被赋予所有输出生命周期参数：`fn foo<'a>(x: &'a i32) -> &'a i32`。
- 第三条规则是如果方法有多个输入生命周期参数并且其中一个参数是 `&self` 或 `&mut self`，说明是个对象的方法(method)(译者注： 这里涉及rust的面向对象参见17章), 那么所有输出生命周期参数被赋予 `self` 的生命周期。第三条规则使得方法更容易读写，因为只需更少的符号。

静态生命周期：'static，其生命周期能够存活于整个程序期间。所有的字符串字面值都拥有 'static 生命周期，我们也可以选择像下面这样标注出来：

```rust
let s: &'static str = "I have a static lifetime.";
```

结合泛型类型参数、trait bounds 和生命周期，示例代码如下：

```rust
use std::fmt::Display;

fn longest_with_an_announcement<'a, T>(x: &'a str, y: &'a str, ann: T) -> &'a str
    where T: Display
{
    println!("Announcement! {}", ann);
    if x.len() > y.len() {
        x
    } else {
        y
    }
}
```

ann 的类型是泛型 T，它可以被放入任何实现了 where 从句中指定的 Display trait 的类型。这个额外的参数会在函数比较字符串 slice 的长度之前被打印出来，这也就是为什么 Display trait bound 是必须的。因为生命周期也是泛型，所以生命周期参数 'a 和泛型类型参数 T 都位于函数名后的同一尖括号列表中。

## 一个 I/O 项目：构建一个命令行程序

这里就不添加过多的文字解释了，个人感觉多敲一敲才会熟练相应的内容，也可以用 rust 写一下 leetcode 上面的题目来练习一下

```rust
main.rs:

use std::env;
use std::process;

use formatted_print::config::Config;

fn main() {
	let args: Vec<String> = env::args().collect();

	let config = Config::new(&&args).unwrap_or_else( |err| {
		println!("Problem parsing arguments: {}", err);
		process::exit(1);
	});

	println!("Searching for {}", config.query);
	println!("In file {}\n", config.filename);

	formatted_print::config::run(config).unwrap_or_else( |err| {
		println!("Application error: {}", err);
		process::exit(1);
	})
}

lib.rs:

pub mod config {
	use std::collections::HashMap;

	pub struct Config {
		pub query: String,
		pub filename: String,
	}

	impl Config {
		pub fn new(args: &[String]) -> Result<Config, &'static str> {
			if args.len() != 3 {
				return Err("not enough arguments");
			}
			let query = args[1].clone();
			let filename = args[2].clone();

			Ok(Config { query, filename })
		}

	}
	pub fn run(config: Config) -> Result<(), Box<dyn std::error::Error>> {
		let contents = std::fs::read_to_string(config.filename)?;

		for (number , line) in search(&config.query, &contents).iter() {
			println!("{}: {}", number, line);
		}

		Ok(())
	}

	pub fn search<'a>(query: &str, contents: &'a str) -> HashMap<u32 , &'a str> {
		let mut results = HashMap::new();
		let mut number = 1;

		for line in contents.lines() {
			if line.contains(query) {
				results.insert(number, line);
			}

			number += 1;
		}

		results
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn one_result() {
		let query = "fast";
		let contents = "\
Rust:
safe, fast, productive.
Pick three.";

		for (_, line) in config::search(query, contents) {
			assert_eq!(
				"safe, fast, productive.",
				line
			);
		}
	}
}
```

## Rust 中的函数式语言功能：迭代器与闭包

### 闭包：可以捕获其环境的匿名函数

闭包的定义以一对竖线（｜）开始，在竖线中指定闭包的参数；闭包中可以定义多个参数，如果闭包体只有一行则大括号是可以省略的。大括号之后闭包的结尾，需要用于 let 语句的分号。因为闭包体的最后一行是没有分号的和函数体一样，所以闭包体最后一行的返回值作为调用闭包时的返回值，示例代码如下：

```rust
let vars = |var1| {
	// --snip--
};

let elements = |element1, element2| {
	// --snip--
};
```

通常闭包通常很短，并只关联于小范围的上下文而非任意情境。在这些有闲置的上下文中，编译器能可靠的推断参数和返回值的类型，类似于它是如何能够推断大部分变量的类型一样，但是我们也可以手动的为闭包注明参数和返回值的类型：

```rust
let expensive_closure = |num: u32| -> u32 {
	println!("calculating slowly...");
	thread::sleep(Durantion::from_secs(2));
	num
}
```

如下是一个对其参数加一的函数的定义与拥有相同行为闭包语法的纵向对比，示例代码如下：

```rust
let add_one_v1 	 (x: u32) -> u32 { x + 1 }
let add_one_v2 = |x: u32| -> u32 { x + 1 };
let add_one_v3 = |x|			 { x + 1 };
let add_one_v4 = |x|			   x + 1  ;
```

闭包定义回味每个参数和返回值推断一个具体类型，也就是说一个闭包只能用于一种类型的计算

为了让结构体存放闭包，我们需要指定闭包的类型，因为结构体定义需要知道每一个字段的类型。每一个闭包实例有其自己独有的匿名类型：也就是说，即便两个闭包有着相同的签名，它们的类型仍然可以被认为是不同的。为了定义使用闭包的结构体、枚举或函数参数，需要使用泛型和 trait bound

Fn 系列 trait 由标准库提供。所有的闭包都实现了 trait Fn、FnMut 或 FnOnce 中的一个。示例代码如下：

```rust
struct Cacher<T>
	where T: Fn(u32) -> u32 {
		calcuation: T,
		value: Option<u32>,
}
```

上面的代码中定义了一个结构体类型 Cacher，结构体 Cacher 有一个泛型 T 的字段 calculation。T 的 trait bound 指定了 T 是一个使用 Fn 的闭包。任何我们希望存储到 Cacher 实例的 calculation 字段的闭包必须有一个 u32 参数（由 Fn 之后的括号的内容指定）并必须返回一个 u32（由 -> 之后的内容）

注：函数也都实现了这三个 Fn trait。如果不需要捕获环境中的值，则可以使用实现了 Fn trait 的函数而不是闭包

```rust
impl<T> Cacher<T>
	where T: Fn(u32) -> u32 {
	fn new(calcuation: T) -> Cacher<T> {
		Cacher {
			calculation,
			value: None,
		}
	}

	fn value(&mut self, arg: u32) -> u32 {
		match self.value {
			Some(v) => v,
			None => {
				let v = (self.calculation)(arg);
				self.value = Some(v);
				v
			},
		}
	}
}

fn generate_workout(intensity: u32, random_number: u32) {
	let mut expensive_result = Cacher::new(|num| {
		println!("calculating slowly..");
		thread::sleep(Duration::from_secs(2));
		num
	});

	if intensity < 25 {
		println!("Today, do {} pushups!", expensive_result.value(intensity));
		println!("Next, do {} situps!", expensive_result.value(intensity));
	} else {
		if random_numbe == 3 {
			println!("Take a break today! Remember to stay hydrated!");
		} else {
			println!("Today, run for {} minutes!", expensive_result.value(intensity));
		}
	}
}
```

不同于直接将闭包保存进一个变量，我们保存一个新的 Cacher 实例来存放闭包。接着，在每一个需要结果的地方，调用 Cacher 实例的 value 方法。可以调用 value 方法任意多次，或者一次也不调用，而慢计算最多只会运行一次。

闭包会捕获其环境，也就是说闭包可以使用上下文中的环境，换句话说就是上下文中的变量之类的资源，然而函数是不可以的，函数只能使用传递的参数，而不能使用调用处上下文的环境，示例代码如下：

```rust
fn main() {
	let x = 4;

	let equal_to_x = |z| z == x;

	let y = 4;

	assert!(equal_to_x(y));
}
```

当闭包从环境中捕获一个值，闭包会在闭包体中存储这个值以供使用。这会使用内存并产生额外的开销。

闭包可以通过三种方式捕获其环境，它们直接对函数的三种获取参数的方式：获取所有权、可变借用和不可变借用。这三种捕获值的方式被编码为如下三个 Fn trait：
- FnOnce 消费从周围作用域捕获的变量，闭包周围的作用域被称为其**环境**，environment。为了消费捕获到的变量，闭包必须获取其所有权并在定义闭包时将其移动进闭包。其名称的 Once 部分代表了闭包不能多次获取相同变量的所有权的事实，所以它只能被调用一次。
- FnMut 获取可变的借用值所以可以改变其环境
- Fn 从其环境获取不可变的借用值

在上面的代码中 equal_to_x 闭包不可变的借用了 x（所以 equal_to_x 具有 Fn trait），因为闭包体只需要读取 x 的值。

如果你希望强制闭包获取其使用的环境值的所有权，可以在参数列表前使用 move 关键字，示例代码如下：

```rust
fn main() {
	let x = vec![1, 2, 3];

	let equal_to_x = move |z| z == x;

	println!("can't use x here: {:?}", x);

	let y = vec![1, 2, 3];

	assert!(equal_to_x(y));
}
```

上面的代码是不能编译的，因为上面的代码中使用了 move 将 x 的所有权转移到了闭包中，在闭包语句结束后，x 就被释放了，所以之后在 println 中使用 x 是不被允许的

### 迭代器

定义和使用一个迭代器的示例代码如下：

```rust
let v1 = vec![1, 2, 3];

let v1_iter = v1.iter();

for val in v1_iter {
	println!("Got: {}", val);
}
```

iterator trait 和 next 方法，其定义如下所示，其中 type Item 和 Self::Item 它们定义了 trait 的关联类型。现在还不需要知道什么是关联类型，只需要知道这段代码表明实现 Iterator trait 要求同时定义一个 Item 类型，这个 Item 类型被用作 next 方法的返回值类型。换句话说，Item 类型将是迭代器返回元素的类型，其中 next 是 Iterator 实现者被要求定义的唯一方法。next 一次返回迭代器中的一个项，封装在 Some 中，当迭代器结束时，他返回 None。

```rust
pub trait Iterator {
	type Item;

	fn next(&mut self) -> Option<Self::Item>;

	// 此处省略了方法的默认实现
}
```

map 方法使用闭包来调用每个元素以生成新的迭代器，示例代码如下：

```rust
let v1: Vec<i32> = vec![1, 2, 3];

let v2: Vec<_> = v1.iter().map(|x| x + 1).collect();

assert_eq!(v2, vec![2, 3, 4]);
```

因为 map 获取一个闭包，可以指定任何希望在遍历的每个元素上执行的操作。

使用闭包获取环境，示例代码如下：

```rust
#[derive(PartialEq, Debug)]
struct Shoe {
	size: u32,
	style: String,
}

fn shoes_in_my_size(shoes: Vec<Shoe>, shoe_size: u32) -> Vec<Shoe> {
	shoes.into_iter()
		.filter(|s| s.size == shoe_size)
		.collect()
}

#[test]
fn filters_by_size() {
	let shoes = vec![
		Shoe { size: 10, style: String::from("sneaker") },
		Shoe { size: 13, style: String::from("sandal") },
		Shoe { size: 10, style: String::from("boot") },
	];

	let in_my_size = shoes_in_my_size(shoes, 10);

	assert_eq!(
		in_my_size,
		vec![
			Shoe { size: 10, style: String::from("sneaker") },
			Shoe { size: 10, style: String::from("boot") },
		]
	);
}
```

实现 Iterator trait 来创建自定义迭代器，示例代码：

```rust
struct Counter {
	count: 32,
}

impl Counter {
	fn new() -> Counter {
		Counter { count: 0 }
	}
}

impl Iterator for Counter {
	type Item = u32;

	fn next(&mut self) -> Option<Self::Item> {
		self.count += 1;

		if self.count < 6 {
			Some(self.count)
		} else {
			None
		}
	}
}
```

通过定义 next 方法实现 Iterator trait，我们现在就可以使用任何标准库定义的拥有默认实现的 Iterator trait 方法了，因为它们都使用了 next 方法的功能，示例代码如下：

```rust
#[test]
fn using_other_iterator_trait_methods() {
	let sum: u32 = Counter::new().zip(Counter::new().skip(1))
								 .map(|a, b| a * b)
								 .filter(|x| x % 3 == 0)
								 .sum();

	assert_eq!(18, sum);
}
```

## 智能指针

声明并且定义一个智能指针示例代码如下：

```rust
fn main() {
	let b = Box::new(5);
	println!("b = {}", b);
}
```

使用 Box<T> 给递归类型一个已知大小的示例代码：

```rust
enum List {
	Cons(i32, Box<List>),
	Nil,
}

use crate::List::{Cons, Nil};

fn main() {
	let list = Cons(1,
		Box::new(Cons(2,
			Box::new(Cons(3,
				Box::new(Nil))))));
}
```

Box<T> 类型是一个智能指针，因为它实现了 Deref trait，它允许 Box<T> 值被当作引用对待。当 Box<T> 值离开作用域时，由于 Box<T> 类型 Drop trait 的实现，box 所指向的堆数据也会被清除。

通过解引用运算符追踪指针的值的示例代码如下：

```rust
fn main() {
	let x = 5;
	let y = &x;

	assert_eq!(5, x);
	assert_eq!(5, *y);
}
```

像引用一样使用 Box<T>，示例代码如下：

```rust
fn main() {
	let x = 5;
	let y = Box::new(x);

	assert_eq!(5, x);
	assert_eq!(5, *y);
}
```

自定义智能指针的示例代码如下：

```rust
struct MyBox<T>(T);

impl<T> MyBox<T> {
	fn new(x: T) -> MyBox<T> {
		MyBox()
	}
}
```

通过实现 Deref trait 将某些类型像引用一样处理，示例代码如下所示：

```rust
use std::ops::Deref;

impl<T> Deref for MyBox<T> {
	type Target = T;

	fn deref(&self) -> &T {
		&self.0
	}
}
```

当所涉及到当类型定义了 Deref trait，Rust 会分析这些类型并使用任意多次 Deref::deref 调用以获得匹配参数的类型。这些解析都发生在编译时，所以利用解引用强制多态并没有运行时惩罚！

Rust 在发现类型和 trait 实现满足三种情况时会进行解引用强制多态
- 当 T: Deref<Target=U> 时从 &T 到 &U
- 当 T: DerefMut<Target=U> 时从 &mut T 到 &mut U
- 当 T: Deref<Target=U> 时从 &mut T 到 &U

Rust 可以将可变引用强制转换为不可变引用。但是反之是**不可能**的

自行实现 Drop trait 的实例代码如下：

```rust
struct CustomSmartPointer {
	data: String,
}

impl Drop for CustomSmartPointer {
	fn drop(&mut self) {
		println!("Dropping CustomSmartPointer with data {}!")
	}
}

fn main() {
	let c = CustomSmartPointer { data: String::from("my stuff") };
	let d = CustomSmartPointer { data: String::from("other stuff") };
	println!("CustomSmartPointers created.");
}
```

当实例离开作用域 Rust 会自动调用 drop，并调用我们指定当代码。

通过 std::mem::drop 提早丢弃值，不幸的是，我们并不能直截了当的禁用 drop 这个功能。通常也不需要禁用 drop ；整个 Drop trait 存在的意义在于其是自动处理的。然而，有时你可能需要提早清理某个值。一个例子是当使用智能指针管理锁时；你可能希望强制运行 drop 方法来释放锁以便作用域中的其他代码可以获取锁。Rust 并不允许我们主动调用 Drop trait 的 drop 方法；当我们希望在作用域结束之前就强制释放变量的话，我们应该使用的是由标准库提供的 std::mem::drop。示例代码如下：

```rust
fn main() {
	let c = CustomSmartPointer { data: String::from("some data") };
	println!("CustomSmartPointer created.");

	// c.drop(); 是不能编译的，显式调用 Drop trait 时会析构一次分配的实例，但是在 main
	// 结束时还会再调用一次 drop trait，这样会造成 double free ，所以不允许显式的调用
	// Drop trait

	drop(c);
	println!("CustomSmartPointer dropped before the end of main.");
}
```

使用引用计数智能指针的示例代码如下，使用 Rc<T> 共享数据

```rust
enum List {
	Cons(i32, Rc<List>),
	Nil,
}

use crate::List{ Cons, Nil };
use std::rc::Rc;

fn main() {
	let a = Rc::new(Cons(5, Rc::new(Cons(10, Rc::new(Nil)))));
	let b = Cons(3, Rc::clone(&a));
	let c = Cons(4, Rc::clone(&a));
}
```

Rc::clone 只会增加引用计数，而 clone 方法是会进行深拷贝，所以 clone 会比 Rc::clone 更耗时

Rc::strong_count 函数会返回当前的引用计数，示例代码如下：

```rust
fn main() {
	let a = Rc::new(Cons(5, Rc::new(10, Rc::new(Nil))));
	println!("count after creating a = {}", Rc::strong_count(&a));

	let b = Cons(3, Rc::clone(&a));
	println!("count after creating b = {}", Rc::strong_count(&a));

	{
		let c = Cons(4, Rc::clone(&a));
		println!("count after creating c = {}", Rc::strong_count(&a));
	}

	println!("count after c goes out of scope = {}", Rc::strong_count(&a));

}

output:

count after creating a = 1
count after creating b = 2
count after creating c = 3
count after c goes out of scope = 2
```

RefCell<T> 于 Box<T> 和 引用的区别

对于引用和 Box<T>，借用规则的不可变性作用于编译时。对于 RefCell<T>，这些不可变性作用于 运行时。对于引用，如果违反这些规则，会得到一个编译错误。而对于 RefCell<T>，如果违反这些规则程序会 panic 并退出。

Box<T> Ref<T> RefCell<T> 的应用场景：
- Rc<T> 允许相同数据有多个所有者；Box<T> 和 RefCell<T> 有单一所有者。
- Box<T> 允许在编译时执行不可变或可变借用检查；Rc<T>仅允许在编译时执行不可变借用检查；RefCell<T> 允许在运行时执行不可变或可变借用检查。
- 因为 RefCell<T> 允许在运行时执行可变借用检查，所以我们可以在即便 RefCell<T> 自身是不可变的情况下修改其内部的值。

在不可变值内部改变值就是 **内部可变性** 模式。

RefCell<T> 在运行时记录借用，当创建不可变和可变引用时，我们分别使用 & 和 &mut 语法。对于 RefCell<T> 来说，则是 borrow 和 borrow_mut 方法，这属于 RefCell<T> 安全 API 的一部分。borrow 方法返回 Ref<T> 类型的智能指针，borrow_mut 方法返回 RefMut 类型的智能指针。这两个类型都实现了 Deref，所以可以当作常规引用对待。

RefCell<T> 记录当前有多少个活动的 Ref<T> 和 RefMut<T> 智能指针。每次调用 borrow，RefCell<T> 将活动的不可变借用计数加一。当 Ref<T> 值离开作用域时，不可变借用计数减一。就像编译时借用规则一样，RefCell<T> 在任何时候只允许有多个不可变借用或一个可变借用。

### 结合 Rc<T> 和 RefCell<T> 来拥有多个可变数据所有者

Rc<T> 允许对相同数据有多个所有者，不过只能提供数据的不可变访问。如果有一个储存了 RefCell<T> 的 Rc<T> 的话，就可以得到有多个所有者 并且 可以修改的值了！示例代码如下：

```rust
#[derive(Debug)]
enum List {
	Cons(Rc<RefCell<i32>>, Rc<List>),
	Nil,
}

use crate::List::{Cons, Nil};
use std::rc::Rc;
use std::cell::RefCell;

fn main() {
	let value = Rc::new(RefCell::new(5));

	let a = Rc::new(Cons(Rc::clone(&value), Rc::new(Nil)));

	let b = Cons(Rc::new(RefCell::new(6), Rc::clone(&a)));
	let c = Cons(Rc::new(RefCell::new(10), Rc::clone(&a)));

	*value.borrow_mut() += 10;

	println!("a after = {:?}", a);
	println!("b after = {:?}", b);
	println!("c after = {:?}", c);
}

output:

a after = Cons(RefCell { value: 15 }, Nil)
b after = Cons(RefCell { value: 6 }, Cons(RefCell { value: 15 }, Nil))
c after = Cons(RefCell { value: 10 }, Cons(RefCell { value: 15 }, Nil))
```

解析一下上面的代码
- 首先声明了一个 value 变量，value 变量存储的是一个智能指针，该指针会指向一个可以被多可变引用的 int 类型数据
- 然后声明了一个 a 变量，a 变量也是一个智能指针该指针指向一个可被多不可变引用的 Cons 类型数据，并且这个数据是来自 value 的不可变引用
- 其次声明了一个 b 变量，b 变量是一个链表，该表中存储了一个智能指针，该指针指向一个可变引用的 int 类型数据和一个 a 的不可变引用
- 最后声明了一个 c 变量，c 变量也是一个链表，该表中存储了一个智能指针，该指针指向一个可变引用的 int 类型数据和一个 a 的不可变引用
- 这里分析一下 a 其实是一个指针指向了一个 Cons 类型的变量，然后变量中的第一个值来自于对 value 的引用，b 和 c 同样只不过 b 和 c 不是指针，但是这两个变量的第二个值都来自于对 a 的引用，换句话说也就是 a 的第一个值和 value 的值相同，b 和 c 的第二个值指向的链表的第一个值和 value 的值相同

### 引用循环和内存泄漏

创建引用循环的可能性是存在的。这会造成内存泄漏，因为每一项的引用计数永远也到不了 0，其值也永远不会被丢弃。

创建引用循环的示例代码如下：

```rust
fn main() {}
use std::rc::Rc;
use std::cell::RefCell;
use crate::List::{Cons, Nil};

#[derive(Debug)]
enum List {
    Cons(i32, RefCell<Rc<List>>),
    Nil,
}

impl List {
    fn tail(&self) -> Option<&RefCell<Rc<List>>> {
        match self {
            Cons(_, item) => Some(item),
            Nil => None,
        }
    }
}

use crate::List::{Cons, Nil};
use std::rc::Rc;
use std::cell::RefCell;
#[derive(Debug)]
enum List {
    Cons(i32, RefCell<Rc<List>>),
    Nil,
}

impl List {
    fn tail(&self) -> Option<&RefCell<Rc<List>>> {
        match self {
            Cons(_, item) => Some(item),
            Nil => None,
        }
    }
}

fn main() {
    let a = Rc::new(Cons(5, RefCell::new(Rc::new(Nil))));

    println!("a initial rc count = {}", Rc::strong_count(&a));
    println!("a next item = {:?}", a.tail());

    let b = Rc::new(Cons(10, RefCell::new(Rc::clone(&a))));

    println!("a rc count after b creation = {}", Rc::strong_count(&a));
    println!("b initial rc count = {}", Rc::strong_count(&b));
    println!("b next item = {:?}", b.tail());

    if let Some(link) = a.tail() {
        *link.borrow_mut() = Rc::clone(&b);
    }

    println!("b rc count after changing a = {}", Rc::strong_count(&b));
    println!("a rc count after changing a = {}", Rc::strong_count(&a));

    // Uncomment the next line to see that we have a cycle;
    // it will overflow the stack
    // println!("a next item = {:?}", a.tail());
}

output:

a initial rc count = 1
a next item = Some(RefCell { value: Nil })
a rc count after b creation = 2
b initial rc count = 1
b next item = Some(RefCell { value: Cons(5, RefCell { value: Nil }) })
b rc count after changing a = 2
a rc count after changing a = 2
```

解析一下上面的代码
- 首先声明变量 a，变量 a 是一个指针指向了一个 Cons 类型的数据，并且指向的数据的第二个元素同时指向了一个可以修改并且可以多次引用的变量
- 此时输出 a 的引用计数为 1，a 的第二个元素为 Some(RefCell { value: Nil })
- 然后声明变量 b，变量 b 同样也是一个指针指向了一个 Cons 类型的数据，指向的数据的第二个元素是 a 的引用，并且该引用是可以被多次引用且修改的
- 此时输出 a 的引用计数位 2，b 的引用计数为 1，b 的第二个元素为 Some(RefCell { value: Cons(5, RefCell { value: Nil }) })
- 因为 a 的第二个元素是一个可以被修改且多次引用的变量，所以我们在这里可以让其引用 b
- 这时再输出 a 的引用技术则为 2，b 的引用计数也为 2，因为 a 和 b 的第二个元素都指向彼此

### 避免引用：将 Rc<T> 替换为 Weak<T>

调用 Rc::clone 会增加 Rc<T> 实例的 strong_count，和只在其 strong_count 为 0 时才会被清理的 Rc<T> 实例。但是我们可以通过调用 Rc::downgrade 并传递 Rc<T> 实例的引用来创建其值的 **弱引用（weak reference）**。调用 Rc::downgrade 时会得到 Weak<T> 类型的智能指针。不同于将 Rc<T> 实例的 strong_count 加1，调用 Rc::downgrade 会将 weak_count 加1。Rc<T> 类型使用 weak_count 来记录其存在多少个 Weak 引用，类似于 strong_count。其区别在于 weak_count 无需计数为 0 就能使 Rc<T> 实例被清理。

**强引用代表如何共享 Rc<T> 实例的所有权，但弱引用并不属于所有权关系。**

因为 Weak<T> 引用的值可能已经被丢弃了，为了使用 Weak<T> 所指向的值，我们必须确保其值仍然有效。为此可以调用 Weak<T> 实例的 upgrade 方法，这会返回 Option<Rc<T>>。如果 Rc<T> 值还未被丢弃，则结果是 Some；如果 Rc<T> 已被丢弃，则结果是 None。因为 upgrade 返回一个 Option<T>，我们确信 Rust 会处理 Some 和 None 的情况，所以它不会返回非法指针。

创建树形数据结构：带有子节点的 Node，会使用 Weak<T> 作为父节点的类型而不是 Rc<T>，示例代码如下：

```rust
use std::rc::{Rc, Week};
use std::cell::RefCell;

#[derive(Debug)]
struct Node {
	value: i32,
	parent: RefCell<Weak<Node>>,
	children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());

    let branch = Rc::new(Node {
        value: 5,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![Rc::clone(&leaf)]),
    });

    *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
}

output:

leaf parent = None
leaf parent = Some(Node { value: 5, parent: RefCell { value: (Weak) },
```

可视化 strong_count 和 weak_count 的改变，示例代码如下：

```rust
use std::rc::{Rc, Weak};
use std::cell::RefCell;

#[derive(Debug)]
struct Node {
    value: i32,
    parent: RefCell<Weak<Node>>,
    children: RefCell<Vec<Rc<Node>>>,
}

fn main() {
    let leaf = Rc::new(Node {
        value: 3,
        parent: RefCell::new(Weak::new()),
        children: RefCell::new(vec![]),
    });

    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    );

    {
        let branch = Rc::new(Node {
            value: 5,
            parent: RefCell::new(Weak::new()),
            children: RefCell::new(vec![Rc::clone(&leaf)]),
        });

        *leaf.parent.borrow_mut() = Rc::downgrade(&branch);

        println!(
            "branch strong = {}, weak = {}",
            Rc::strong_count(&branch),
            Rc::weak_count(&branch),
        );

        println!(
            "leaf strong = {}, weak = {}",
            Rc::strong_count(&leaf),
            Rc::weak_count(&leaf),
        );
    }

    println!("leaf parent = {:?}", leaf.parent.borrow().upgrade());
    println!(
        "leaf strong = {}, weak = {}",
        Rc::strong_count(&leaf),
        Rc::weak_count(&leaf),
    );
}

output:

leaf strong = 1, weak = 0
branch strong = 1, weak = 1
leaf strong = 2, weak = 0
leaf parent = None
leaf strong = 1, weak = 0
```