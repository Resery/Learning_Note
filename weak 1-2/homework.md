## 思考题：

### 思考题1：

> 在写容器的时候 容器里有很多的成员函数或者非成员函数 。有的容器都有对元素的增删操作 ，那么这些操作在如何不恰当使用的情况下，会造成安全问题请构造出poc来。

1. 其中push_back和pop_back对插入位置的合法性检测的都不够。

   ```
   void pop_back() {
       --_M_finish;
       destroy(_M_finish);
   }
   
   void push_back(const _Tp &__value) {
       if (_M_finish != _M_end_of_storage) {
           construct(_M_finish, __value);
           ++_M_finish;
       } else {
           _M_insert_aux(end(), __value);
       }
   }
   
   void push_back() {
       if (_M_finish != _M_end_of_storage) {
           construct(_M_finish);
           ++_M_finish;
       } else {
           _M_insert_aux(end());
       }
   }
   ```

   可以看到pop_back和push_back就职检测finfish和end_of_storage是不是相等的，即是否还有可用空间，而pop_back都没有检测，直接就执行后退和析构操作。所以可以利用它不检测这个机制，反向移动finish指针，可以使得vector从左闭右开变成左开右闭。就可以对当前vector的上一个块进行修改，意思就是可以修改上一个块的fd和bk以及size（也就是利用unlike机制，也不知道对不对XD），可以达到任意地址写。

   ```
   /*
   * @Author: resery
   * @Date:   2020-07-10 13:31:49
   * @Last Modified by:   resery
   * @Last Modified time: 2020-07-11 09:13:45
   */
   #include <vector>
   #include <iostream>
   #include <cstdlib>
   #include <string>
   
   using namespace std;
   
   int main(){
   
   	vector<int> first(5,1);
       vector<int> second(5,2);
       vector<int> third(5,3);
       vector<int> fourth(8,4);
       vector<int>::iterator first_begin = first.begin();
       vector<int>::iterator first_end = first.end();
       vector<int>::iterator second_begin = second.begin();
       vector<int>::iterator second_end = second.end();
       vector<int>::iterator fourth_begin = fourth.begin();
       vector<int>::iterator fourth_end = fourth.end();
       cout << "-------------------------------" <<endl;
       cout << "---------init------------------" <<endl;
       cout << "first_begin:" << "\t" << &*(first_begin) << endl;
       cout << "first_end:" << "\t" << &*(first_end) << endl;
       cout << "second_1_begin:" << "\t" << &*(second_begin) << endl;
       cout << "second_1_end:" << "\t" << &*(second_end) << endl;
       cout << "fourth_begin:" << "\t" << &*(fourth_begin) << endl;
       cout << "fourth_end:" << "\t" << &*(fourth_end) << endl;
       cout << "The first size : " <<  hex << "0x" << first[-2] << endl;
       cout <<endl;
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second.pop_back();
       second_begin = second.begin();
       second_end = second.end();
       cout << "-------------------------------" <<endl;
       cout << "---------after pop back--------" <<endl;
       cout << "second_2_begin:" << "\t" << &*(second_begin) << endl;
       cout << "second_2_end:" << "\t" << &*(second_end) << endl;
       cout <<endl;
       second.push_back(0x91);
       second_begin = second.begin();
       second_end = second.end();
       cout << "-------------------------------" <<endl;
       cout << "---------after push back-------" <<endl;
       cout << "second_3_begin:" << "\t" << &*(second_begin) << endl;
       cout << "second_3_end:" << "\t" << &*(second_end) << endl;
       cout <<endl;
       cout << "-------------------------------" <<endl;
       cout << "---------result----------------" <<endl;
       cout << "The first size be changed: " <<  hex << "0x" << first[-2] << endl;
       return 0;
       
   }
   ```

   输出结果：

   ```
   -------------------------------
   ---------init------------------
   first_begin:	0xaa7c20
   first_end:	0xaa7c34
   second_1_begin:	0xaa7c40
   second_1_end:	0xaa7c54
   fourth_begin:	0xaa7c80
   fourth_end:	0xaa7ca0
   The first size : 0x21
   
   -------------------------------
   ---------after pop back--------
   second_2_begin:	0xaa7c40
   second_2_end:	0xaa7c18
   
   -------------------------------
   ---------after push back-------
   second_3_begin:	0xaa7c40
   second_3_end:	0xaa7c1c
   
   -------------------------------
   ---------result----------------
   The first size be changed: 0x91
   ```

2. 没有写拷贝构造函数，导致它调用默认的拷贝构造函数，就会出现浅拷贝，出现浅拷贝也就意味着会造成double free或者uaf

   ```
   /*
   * @Author: resery
   * @Date:   2020-07-10 18:10:35
   * @Last Modified by:   resery
   * @Last Modified time: 2020-07-10 19:03:42
   */
   #include <vector>
   #include <iostream>
   #include <string>
   #include <stdio.h>
   #include <unistd.h>
   #include <stdlib.h>
   
   using namespace std;
   
   class no_copy_ctor{
   
   public:
   	no_copy_ctor(string content = " ")
       {
           ptr = new string[10];
           for (int i = 0; i < 10; i++)
               ptr[i] = content;
           cout << &(*ptr) << " constructed." << endl;
       }
       ~no_copy_ctor()
       {
           cout << &(*ptr) << " destroyed." << endl;
           delete[] ptr;
       }
       void print (){
       	cout << &(*ptr) << " printed." << endl;
       }
       void uaf(){
       	system("/bin/sh;");
       }
   
   private:
   	string *ptr;
   
   };
   
   int main(){
   
   	vector<no_copy_ctor> ncc;
       ncc.push_back(no_copy_ctor("Resery"));
       cout << "-----------------------" << endl;
       cout << "----after push back----" << endl;
       cout << "-----------------------" << endl;
       ncc.begin()->print();
       ncc.begin()->uaf();
       return 0;
   
   }
   ```

   输出结果：

   ```
   uaf：
   0xcdbc28 constructed.
   0xcdbc28 destroyed.
   -----------------------
   ----after push back----
   -----------------------
   0xcdbc28 printed.
   # id
   uid=0(root) gid=0(root) groups=0(root)
   # 
   
   double free：
   test constructed.
   test destroyed.
   test destroyed.
   *** Error in `./test': double free or corruption (fasttop): 0x000000000174ac20 ***
   ======= Backtrace: =========
   /lib/x86_64-linux-gnu/libc.so.6(+0x777f5)[0x7f0d79def7f5]
   /lib/x86_64-linux-gnu/libc.so.6(+0x8038a)[0x7f0d79df838a]
   /lib/x86_64-linux-gnu/libc.so.6(cfree+0x4c)[0x7f0d79dfc58c]
   ./test[0x401293]
   ./test[0x4020d8]
   ./test[0x401de4]
   ./test[0x401a72]
   ./test[0x401433]
   ./test[0x40108f]
   /lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xf0)[0x7f0d79d98840]
   ./test[0x400f09]
   ======= Memory map: ========
   00400000-00404000 r-xp 00000000 08:01 404442                             /home/resery/Resery_STL/test
   00603000-00604000 r--p 00003000 08:01 404442                             /home/resery/Resery_STL/test
   00604000-00605000 rw-p 00004000 08:01 404442                             /home/resery/Resery_STL/test
   01739000-0176b000 rw-p 00000000 00:00 0                                  [heap]
   7f0d74000000-7f0d74021000 rw-p 00000000 00:00 0 
   7f0d74021000-7f0d78000000 ---p 00000000 00:00 0 
   7f0d79a6f000-7f0d79b77000 r-xp 00000000 08:01 919100                     /lib/x86_64-linux-gnu/libm-2.23.so
   7f0d79b77000-7f0d79d76000 ---p 00108000 08:01 919100                     /lib/x86_64-linux-gnu/libm-2.23.so
   7f0d79d76000-7f0d79d77000 r--p 00107000 08:01 919100                     /lib/x86_64-linux-gnu/libm-2.23.so
   7f0d79d77000-7f0d79d78000 rw-p 00108000 08:01 919100                     /lib/x86_64-linux-gnu/libm-2.23.so
   7f0d79d78000-7f0d79f38000 r-xp 00000000 08:01 919092                     /lib/x86_64-linux-gnu/libc-2.23.so
   7f0d79f38000-7f0d7a138000 ---p 001c0000 08:01 919092                     /lib/x86_64-linux-gnu/libc-2.23.so
   7f0d7a138000-7f0d7a13c000 r--p 001c0000 08:01 919092                     /lib/x86_64-linux-gnu/libc-2.23.so
   7f0d7a13c000-7f0d7a13e000 rw-p 001c4000 08:01 919092                     /lib/x86_64-linux-gnu/libc-2.23.so
   7f0d7a13e000-7f0d7a142000 rw-p 00000000 00:00 0 
   7f0d7a142000-7f0d7a158000 r-xp 00000000 08:01 920041                     /lib/x86_64-linux-gnu/libgcc_s.so.1
   7f0d7a158000-7f0d7a357000 ---p 00016000 08:01 920041                     /lib/x86_64-linux-gnu/libgcc_s.so.1
   7f0d7a357000-7f0d7a358000 rw-p 00015000 08:01 920041                     /lib/x86_64-linux-gnu/libgcc_s.so.1
   7f0d7a358000-7f0d7a4ca000 r-xp 00000000 08:01 3962                       /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
   7f0d7a4ca000-7f0d7a6ca000 ---p 00172000 08:01 3962                       /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
   7f0d7a6ca000-7f0d7a6d4000 r--p 00172000 08:01 3962                       /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
   7f0d7a6d4000-7f0d7a6d6000 rw-p 0017c000 08:01 3962                       /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21
   7f0d7a6d6000-7f0d7a6da000 rw-p 00000000 00:00 0 
   7f0d7a6da000-7f0d7a700000 r-xp 00000000 08:01 919114                     /lib/x86_64-linux-gnu/ld-2.23.so
   7f0d7a8dd000-7f0d7a8e3000 rw-p 00000000 00:00 0 
   7f0d7a8fe000-7f0d7a8ff000 rw-p 00000000 00:00 0 
   7f0d7a8ff000-7f0d7a900000 r--p 00025000 08:01 919114                     /lib/x86_64-linux-gnu/ld-2.23.so
   7f0d7a900000-7f0d7a901000 rw-p 00026000 08:01 919114                     /lib/x86_64-linux-gnu/ld-2.23.so
   7f0d7a901000-7f0d7a902000 rw-p 00000000 00:00 0 
   7ffcb61b7000-7ffcb61d8000 rw-p 00000000 00:00 0                          [stack]
   7ffcb61da000-7ffcb61dd000 r--p 00000000 00:00 0                          [vvar]
   7ffcb61dd000-7ffcb61df000 r-xp 00000000 00:00 0                          [vdso]
   ffffffffff600000-ffffffffff601000 r-xp 00000000 00:00 0                  [vsyscall]
   [1]    14427 abort (core dumped)  ./test
   ```

3. 然后就是erase进行擦除的时候，只调用最后一个元素的析构函数，如果说函数的析构函数写的不合理，则也可以造成double free或者uaf。

   ```
   iterator erase(iterator __position) {
               //如果position后面还有元素，需要拷贝;如果position是最后一个元素，则后面没有元素，直接destroy即可
               if (__position + 1 != end()) {
                   copy(__position + 1, _M_finish, __position);
               }
               --_M_finish;
               destroy(_M_finish);
               return __position;
           }
   
           iterator erase(iterator __first, iterator __last) {
               iterator __i = copy(__last, _M_finish, __first);
               destroy(__i, _M_finish);
               _M_finish = _M_finish - (__last - __first);
               return __first;
           }
   ```
不过这个poc没有写出来，以后再补

4. 总结：就是一定要避免浅拷贝的情况发生，只要发生浅拷贝就会有double free和uaf出现(个人见解)，其次就是析构函数一定要设计的合理即free或者delete之后一定要置指针为空。

### 思考题2：

>  为什么实现了uninitialized_xxx和copy/fill这样两组不同的函数

这个部分是看了分别看了copy和uninitialized_copy发现出来的，其中copy复制是通过指针一个一个遍历，然后一个一个赋值这样的方法来达到复制的效果的，简单来说也就是指针指向的肯定是一块内存，即copy针对的是已经初始化过的内存。然后看了uninitialized_copy，其中uninitialized_copy他也提供了一个特化版本，直接去调用copy，具体选择copy还是uninitialized_copy是由他是不是POD型别决定的，即是否有构造，拷贝构造，拷贝赋值，析构函数。如果说是POD型别即代表有这些函数，而且在调用uninitialized_copy的时候就已经初始化过了，所以这时候就直接转调用copy，如果说不是POD型别那就代表还没有初始化，uninitialized_copy就会再执行一遍初始化。所以总结来看就是copy针对已经初始化过的内存，uninitialized_copy针对没有初始化过的内存。

### 思考题3：

> 理解每个容器的内存模型。

vector：

也不知道这个自己理解的算不算内存模型。

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-11_15-25-34.png)


