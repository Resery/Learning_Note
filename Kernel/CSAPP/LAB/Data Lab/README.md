# Data Lab

## bitXor

```
/* 
 * bitXor - x^y using only ~ and & 
 *   Example: bitXor(4, 5) = 1
 *   Legal ops: ~ &
 *   Max ops: 14
 *   Rating: 1
 */
int bitXor(int x, int y) {
  int notand = ~(x&y);
  int notor = ~((~x)&(~y));
  int result = notand & notor;
  return result;
}
```

这里需要使用~和&来构造^，所以先写出^和|和&的真值表

| x    | y    | &    |
| ---- | ---- | ---- |
| 1    | 1    | 1    |
| 1    | 0    | 0    |
| 0    | 1    | 0    |
| 0    | 0    | 0    |

| x    | y    | \|   |
| ---- | ---- | ---- |
| 1    | 1    | 1    |
| 1    | 0    | 1    |
| 0    | 1    | 1    |
| 0    | 0    | 0    |

| x    | y    | ^    |
| ---- | ---- | ---- |
| 1    | 1    | 0    |
| 1    | 0    | 1    |
| 0    | 1    | 1    |
| 0    | 0    | 0    |

通过真值表可以发现~(x&y)&(x|y)=x^y,但是我们不能使用|所以还需要构造出或来，其实通过真值表可以发现，&的结果是一个1三个0，|的结果是一个0三个1，所以可以利用取反找出他们之间的关系，我们可以让(~x&~y)得到的结果正好与|得到的结果相反，所以再对(~x&~y)取反就可以代表|了所以利用~(x&y)&(x|y)=x^y和(~x&~y)=x|y，就可以只利用~和&来代替^了

## tmin

```
/* 
 * tmin - return minimum two's complement integer 
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 4
 *   Rating: 1
 */
int tmin(void) {
  return 1<<31;
}
```

这个很简单返回最小的二进制补码，那就是符号位为1其余为0即可，直接左移31位就行了

## isTmax

```
/*
 * isTmax - returns 1 if x is the maximum, two's complement number,
 *     and 0 otherwise 
 *   Legal ops: ! ~ & ^ | +
 *   Max ops: 10
 *   Rating: 1
 */
int isTmax(int x) {
  int tmp = x+1;
  return !((~tmp+1)^tmp)&(!!tmp);
}
```

这个是判断是不是最大的，最大值就是符号位为0其余为1，最大值加1就是tmin，然后tmin的相反数还是tmin，可以利用这两个性质来解决问题，先把x加1，然后求相反数再异或看是不是与x加1相同，同时还应该要避免全是1的这种特殊情况。

## addOddbits

```
/* 
 * allOddBits - return 1 if all odd-numbered bits in word set to 1
 *   where bits are numbered from 0 (least significant) to 31 (most significant)
 *   Examples allOddBits(0xFFFFFFFD) = 0, allOddBits(0xAAAAAAAA) = 1
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 2
 */
int allOddBits(int x) {
  int odd = (0xAA << 24) + (0xAA << 16) + (0xAA << 8) + 0xAA;
  return !((x & odd) ^ odd);
}
```

这个是判断所有奇数位是不是为1，首先就是先构造出来奇数位为1的串，而且我们只需要考虑奇数位，偶数位为多少不许要考虑所以说，我们可以直接用构造出来的串与上x，如果说x的奇数为全为1，(x & odd)之后的串仍然奇数位全为1，如果x的奇数为不全为1，就会导致(x & odd)之后的串奇数位含有0，然后进行一个异或，异或就是检验是不是和构造出来的串相同，相同则((x & odd) ^ odd)的值是0，不同是1，但是我们相同返回的应该是1，所以在前面加一个!就可以了

## negate

```
/* 
 * negate - return -x 
 *   Example: negate(1) = -1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 5
 *   Rating: 2
 */
int negate(int x) {
  return ~x+1;
}
```

这个是性质，相反数就是取反之后加1

## isAsciiDigit

```
/* 
 * isAsciiDigit - return 1 if 0x30 <= x <= 0x39 (ASCII codes for characters '0' to '9')
 *   Example: isAsciiDigit(0x35) = 1.
 *            isAsciiDigit(0x3a) = 0.
 *            isAsciiDigit(0x05) = 0.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 15
 *   Rating: 3
 */
int isAsciiDigit(int x) {
  int tmin = 1 << 31;
  return !((x + ~0x30 + 1) & tmin) & !((0x39 + ~x + 1) & tmin);
}
```

这个是判断x是不是在[0x30,0x39]这个区间内的，比较大小就是做减法，然后看结果的正负来判断大小的，但是这里限制我们不能使用减法，所以说就得使用另一种方法，加相反数，这个可以转换成逻辑表达式

```
（x - 0x30 >= 0）&& (0x39 - x >= 0)
```

x-0x30和0x39 - x容易表示就是(x + ~0x30 + 1)，(0x39 + ~x + 1)，但是大于等于0就不太好表示了，不过也可以这样想大于等于0即代表是正数，正数的符号位就肯定为0，所以正数的符号位与1还是0，负数的符号位与1是1，然后我们就可以通过判断正负来确定满不满足条件了

## conditional

```
/* 
 * conditional - same as x ? y : z 
 *   Example: conditional(2,4,5) = 4
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 16
 *   Rating: 3
 */
int conditional(int x, int y, int z) {
  int p_or_n = !!x;
  int all_one_number = ~p_or_n + 1;
  return (all_one_number & y) ^ ((~all_one_number) & z);
}
```

这个是要模仿x ? y : z ，这个就是需要判断x的正负了，x是正则输出y，x是负则输出z，但是要想形成这种要么正要么负的判断则需要保留一个舍弃一个，舍弃就可以直接&0就直接舍弃掉了，但是保留就不能&1了，&1会导致值保留了最后，所以要想保留就需要一个全为1的串，舍弃就是全为0的串，然后通过~来转换选择保留哪一个舍弃哪一个

## isLessOrEqual

```
/* 
 * isLessOrEqual - if x <= y  then return 1, else return 0 
 *   Example: isLessOrEqual(4,5) = 1.
 *   Legal ops: ! ~ & ^ | + << >>
 *   Max ops: 24
 *   Rating: 3
 */
int isLessOrEqual(int x, int y) {
  int p_or_n_x = (x>>31) & 0x1;
  int p_or_n_y = (y>>31) & 0x1;
  int same_or_not_same_sing = p_or_n_x ^ p_or_n_y;
  int z = y + ~x +1;
  int p_or_n_z = (z>>31) & 0x1;
  return (~p_or_n_y & p_or_n_x) ^ ((!same_or_not_same_sing) & (!p_or_n_z));
}
```

这个是模仿小于等于，这就也需要分情况了，如果说同号，则进行相减看正负，如果说异号就正数为大，就可以转换成逻辑表达式

```
(y>=0 && x<=0) || ((x*y>=0) && (y-x)>=0) 
```

这个可以转换为真值表分别为异号和同号，正为0，异为1

| 异号 |      |      |
| ---- | ---- | ---- |
| 0    | 1    | 1    |
| 1    | 0    | 0    |

同号就需要判断差值是正是负了，同号为1，异号为0

| 同号 | 差值正负 |      |
| ---- | -------- | ---- |
| 1    | 1        | 1    |
| 1    | 0        | 0    |
| 0    | 1        | 0    |
| 0    | 0        | 0    |

所以说根据真值表可以看出来异号的时候y为正x为负就是大于，但是真值表并不符合&、^、|这三种运算中的一个，所以需要转换，~y&x就可以这样表示了。

然后是同号的时候，首先同号的时候符号位异或是等于0的，所以可以利用这个判断是否同号，如果同号了，就再判断差值的正负，根据真值表可以看出来，同号并且差值为正为1，否则其余三种情况全为0，&运算刚好就可以表示。

所有的东西都表示出来了，组合起来就可以了

## logicalNeg

```
/* 
 * logicalNeg - implement the ! operator, using all of 
 *              the legal operators except !
 *   Examples: logicalNeg(3) = 0, logicalNeg(0) = 1
 *   Legal ops: ~ & ^ | + << >>
 *   Max ops: 12
 *   Rating: 4 
 */
int logicalNeg(int x) {
  int sign_opposite = (~x + 1);
  return  ((~(x | sign_opposite)) >> 31) & 1;
}
```

这个是模仿!运算，需要主义两个特殊的数，分别是0和0x80000000，我最起初的想法是判断正负，负数的相反数全部为1，然后正数再分情况，当等于0的时候等于1，但是这样就忽略掉了0x80000000，！0x80000000应该是0，所以说这个就是需要获取到相反数的符号位来判断正负。

## howManyBits

```
/* howManyBits - return the minimum number of bits required to represent x in
 *             two's complement
 *  Examples: howManyBits(12) = 5
 *            howManyBits(298) = 10
 *            howManyBits(-5) = 4
 *            howManyBits(0)  = 1
 *            howManyBits(-1) = 1
 *            howManyBits(0x80000000) = 32
 *  Legal ops: ! & ^ | + << >>
 *  Max ops: 90
 *  Rating: 4
 */
int howManyBits(int x) {
  int h16,h8,h4,h2,h1,h0;
  int sign = (x >> 31) & 0x1;
  x = (sign<<31)>>31 ^ x;

  h16 = !!(x >> 16) <<  4;
  x = x >> h16;
  h8 = !!(x >> 8) << 3;
  x = x >> h8;
  h4 = !!(x >> 4) << 2;
  x = x >> h4;
  h2 = !!(x >> 2) << 1;
  x = x >> h2;
  h1 = !!(x >> 1);
  x = x >> h1;
  h0 = x;
  return h16 + h8 + h4 + h2 + h1 + h0 + 1;
}
```

这里是计算一个数的补码可以最少用几位表示，这里采用了二分法，即先右移16位，判断高位有没有1，如果有1，则它至少需要16位，然后把这个数左移4这个数现在就是16了，如果说它高16位没有1的话下面的右移移动的也就是0位，如果说有1才会右移移动16位，就这样每一次判断缩小一半的范围，范围就从32->16->8->4->2->1,然后把他们都想加，就得到了最少用多少位，但是这里没有考虑到符号位，所以还需要加一位符号位

## floatScale2

```
//float
/* 
 * floatScale2 - Return bit-level equivalent of expression 2*f for
 *   floating point argument f.
 *   Both the argument and result are passed as unsigned int's, but
 *   they are to be interpreted as the bit-level representation of
 *   single-precision floating point values.
 *   When argument is NaN, return argument
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
unsigned floatScale2(unsigned uf) {
  int exponent  = (uf & 0x7f800000) >> 23;
  int sign = uf&(1<<31);

  if(exponent ==0) 
    return (uf << 1) ^ sign;
  if(exponent ==255) 
    return uf;

  exponent ++;
  if(exponent ==255) 
    return 0x7f800000|sign;

  return (exponent <<23)|(uf&0x807fffff);
}
```

这个是要求2乘一个浮点数，首先就要考虑集中特殊情况，即正无穷和负无穷、0和非数

正无穷是011111111000...0

负无穷是111111111000...0

0是00000000....0

非数是0111111111111..1

非数就是阶码全为1，而且尾数里面不全为0。

无穷大和非数都只需要返回参数

```
2*∞=∞
2*非数=非数
```

无穷小和0只需要将原数乘二再加上符号位就行了（并不会越界）。

然后就是正常情况下的规格化数了，乘2就相当于阶码加1，所以说如果加1之后正好是255那就需要返回无穷大了，简单点说就是正常的一个数已经非常接近正无穷了，再乘2那就是又扩大了一倍那就一定是正无穷了，然后其余的就直接返回阶码+1后的原符号数就可以了，exponent <<23是阶码加1，uf&0x807fffff是排除了阶码的原符号数，然后直接|就可以了

## floatFloat2Int

```
/* 
 * floatFloat2Int - Return bit-level equivalent of expression (int) f
 *   for floating point argument f.
 *   Argument is passed as unsigned int, but
 *   it is to be interpreted as the bit-level representation of a
 *   single-precision floating point value.
 *   Anything out of range (including NaN and infinity) should return
 *   0x80000000u.
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. also if, while
 *   Max ops: 30
 *   Rating: 4
 */
int floatFloat2Int(unsigned uf) {
  int exponent = ((uf >> 23) & 0xFF) - 127;
  int sign = uf >> 31;
  int frac = (uf & 0x7FFFFF) | 0x800000;

  if(exponent < 0) 
    return 0;
  
  if(exponent >31) 
    return 0x80000000u;

  if(exponent > 23) 
    frac = frac << (exponent - 23);
  else 
    frac = frac >> (23 - exponent);
  
  if(sign){
    if(frac >> 31)
      return 0x80000000u;
    else
      return ~frac + 1;
  }
  else{
    if(frac >> 31)
      return 0x80000000u;
    else
      return frac;
  }
}
```

这个是把float转换成int，首先考虑特殊情况：如果原浮点值为0则返回0；如果真实指数大于31（frac部分是大于等于1的，1<<31位会覆盖符号位），返回规定的溢出值0x80000000u；如果 exp<0（1右移x位,x>0，结果为0）则返回0。剩下的情况：首先把小数部分（23位）转化为整数（和23比较），然后判断是否溢出：如果和原符号相同则直接返回，否则如果结果为负（原来为正）则溢出返回越界指定值0x80000000u，否则原来为负，结果为正，则需要返回其补码（相反数）。

## floatPower2

```
/* 
 * floatPower2 - Return bit-level equivalent of the expression 2.0^x
 *   (2.0 raised to the power x) for any 32-bit integer x.
 *
 *   The unsigned value that is returned should have the identical bit
 *   representation as the single-precision floating-point number 2.0^x.
 *   If the result is too small to be represented as a denorm, return
 *   0. If too large, return +INF.
 * 
 *   Legal ops: Any integer/unsigned operations incl. ||, &&. Also if, while 
 *   Max ops: 30 
 *   Rating: 4
 */
unsigned floatPower2(int x) {
  int exp = x + 127;
  
  if(exp <= 0){
    return 0;
  }

  if(exp >= 0xFF){
    return 0x7f800000;
  }
  
  return exp << 23;
}
```

这个是求2.0^x，2.0的位级表示为是 1.0 * 2 ^1，然后2.0^x的位级表示为是 1.0 * 2 ^x，所以说我们可以直接把给的数字，按照正常的转换阶码的方法求出来阶（x+127），然后2.0的尾数部分全为0，就可以不用管了，当然如果说阶码小于等于0的话就代表是0.几的小数转换成int就可以直接舍成0了，还有如果说阶码全为1的话就返回正无穷了，其余的情况正常返回就可以了