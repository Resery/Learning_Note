# Cache Lab

## Part A

第一部分是要自己写代码模拟cache的运行，然后使用LRU策略，其中的定文件中L S操作都只访问cache一次，而M操作意味着先读再写，要访问cache两次。

代码一共分几部分完成。

第一步定义变量

```
typedef struct{
	int vaild;
	int tag;
	int Time_counter;
}Cache_line;

typedef Cache_line* Cache_set;
typedef Cache_set* Cache;

int verbose = 0;			
int s,E,b;
int S;
int hits,misses,evictions;

char buf[100];

FILE* fp = NULL;
```

首先就要根据cache定义出有效位，标记位，这里没有用到块位，因为使用LRU策略所以还需要设置一个计数的变量。然后就是设置参数对应的变量s,E,b，S是根据s算出来的。最后还剩下存储结果的变量，hits表示命中，misses表示没命中，evictions表示替换。buf用来存储文件中的命令。

第二步接受参数的函数

```
void argument(int argc, char* argv[]){
	int opt;
	if(!argv[1]){
		fprintf(stderr,"./csim: Missing required command line argument\n");
		fprintf(stderr, "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>");
		fprintf(stderr,"Options:\n");
		fprintf(stderr,"  -h         Print this help message.\n");
		fprintf(stderr,"  -v         Optional verbose flag.\n");
		fprintf(stderr,"  -s <num>   Number of set index bits.\n");
		fprintf(stderr,"  -E <num>   Number of lines per set.\n");
		fprintf(stderr,"  -b <num>   Number of block offset bits.\n");
		fprintf(stderr,"  -t <file>  Trace file.\n");
		fprintf(stderr,"\n");
		fprintf(stderr,"Examples:\n");
		fprintf(stderr,"  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
		fprintf(stderr,"  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace\n");
		exit(-1);
	}
	while ((opt = getopt(argc, argv, "s:E:b:t:hv")) != -1) {
		switch (opt) {
		case 'h':
			fprintf(stderr, "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>");
			fprintf(stderr,"Options:\n");
			fprintf(stderr,"  -h         Print this help message.\n");
			fprintf(stderr,"  -v         Optional verbose flag.\n");
			fprintf(stderr,"  -s <num>   Number of set index bits.\n");
			fprintf(stderr,"  -E <num>   Number of lines per set.\n");
			fprintf(stderr,"  -b <num>   Number of block offset bits.\n");
			fprintf(stderr,"  -t <file>  Trace file.\n");
			fprintf(stderr,"\n");
			fprintf(stderr,"Examples:\n");
			fprintf(stderr,"  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
			fprintf(stderr,"  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace\n");
			exit(-1);
		case 'v':
			verbose = 1;
			break;
		case 's':
			s = atoi(optarg);
			break;
		case 'E':
			E = atoi(optarg);
			break;
		case 'b':
			b = atoi(optarg);
			break;
		case 't':
			fp = fopen(optarg, "r");
			if (fp == NULL) {
				fprintf(stderr, "The File is wrong!\n");
				exit(-1);
			}
			break;
		default:
			fprintf(stderr, "Usage: ./csim [-hv] -s <num> -E <num> -b <num> -t <file>");
			fprintf(stderr,"Options:\n");
			fprintf(stderr,"  -h         Print this help message.\n");
			fprintf(stderr,"  -v         Optional verbose flag.\n");
			fprintf(stderr,"  -s <num>   Number of set index bits.\n");
			fprintf(stderr,"  -E <num>   Number of lines per set.\n");
			fprintf(stderr,"  -b <num>   Number of block offset bits.\n");
			fprintf(stderr,"  -t <file>  Trace file.\n");
			fprintf(stderr,"\n");
			fprintf(stderr,"Examples:\n");
			fprintf(stderr,"  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
			fprintf(stderr,"  linux>  ./csim -v -s 8 -E 2 -b 4 -t traces/yi.trace\n");
			exit(-1);
		}
	}
}
```

根据writeup中的提示可以使用getopt来获取参数，其中"s: E: b: ​t: hv"，这里字母后面带有一个冒号就代表说需要再后面跟一个参数，没有冒号则代表参数可有可无。

第三步初始化cache

```
	S = 1 << s;
	cache = ((Cache)malloc(sizeof(Cache_set) * S));
	if (cache == NULL)
		return ;
	for (int i = 0; i < S; i++) {
		cache[i] = ((Cache_set)calloc(E,sizeof(Cache_line)));
		if (cache[i] == NULL)
			return ;
	}
```

S是代表一共有多少组，然后申请一个cache指针指向他，所以就应该要申请sizeof(Cache_set) \* S)这么大的空间，然后就是每一行了，这里使用了calloc就可以免去自己一个一个填0的步骤了，申请的是E\*sizeof(Cache_line)这个大的空间其中E是一组有多少行

第四步读取文件中的命令

```
	char op;
	unsigned int address;
	int size;

	while (fgets(buf, 1000, fp)) {
		sscanf(buf, " %c %xu,%d", &op, &address, &size);
		switch (op)
		{
		case 'L':
			visit(address);
			break;
		case 'M':
			visit(address);
		case 'S':
			visit(address);
			break;
		}
	}
```

这里writeup中也给了提示说使用sscanf来获取文件中的字符串，其中L和S都是访问一次，M是访问两次，所以说case M后面没有加break，这样就可以执行两次了。

第五步访问

```
void visit(unsigned int address) {
	int set_index = (address >> b) & (S - 1);
	int tag = (address >> b) >> s;

	int evict = 0;
	int empty = -1;
	
	Cache_set Cache_Set = cache[set_index];

	for (int i = 0; i < E; i++) {
		if (Cache_Set[i].vaild) {
			if (Cache_Set[i].tag == tag) {
				hits++;
				Cache_Set[i].Time_counter = 1;
				return;
			}
			Cache_Set[i].Time_counter++;
			if (Cache_Set[evict].Time_counter <= Cache_Set[i].Time_counter) {
				evict = i;
			}
		}
		else {
			empty = i;
		}
	}
	misses++;
	if (empty != -1) {
		Cache_Set[empty].vaild = 1;
		Cache_Set[empty].tag = tag;
		Cache_Set[empty].Time_counter = 1;
		return;
	}
	else {
		Cache_Set[evict].tag = tag;
		Cache_Set[evict].Time_counter = 1;
		evictions++;
		return;
	}
}
```

首先看传进来的地址位的组成

```
-----------------------------------------
|  tag	| set index	|	block offset	|
-----------------------------------------
```

s位是组的索引，b位是块的偏移，tag位的位数就是t-b-s。所以首先根据地址计算出来是哪一组的并且把标记位提取出来。提取出来之后

需要设置以下替换的块，首先默认是第一行第一个。

然后就是开始访问，访问可以归为两大类，一命中，二不命中，命中很简单直接hit++然后直接下一个就可以了，不命中就需要分情况了，如果说有效位为0的不命中则直接把数据填进去，miss++就可以了，如果说是另外一种有效位为1但是标记位不同，这时候就需要替换了，替换的策略是LRU即替换举例最后一次访问时间最长的那一个块。所以就定义了一个evict来存储替换的块。

**测试结果**

```
$ ./test-csim 
                        Your simulator     Reference simulator
Points (s,E,b)    Hits  Misses  Evicts    Hits  Misses  Evicts
     3 (1,1,1)       9       8       6       9       8       6  traces/yi2.trace
     3 (4,2,4)       4       5       2       4       5       2  traces/yi.trace
     3 (2,1,4)       2       3       1       2       3       1  traces/dave.trace
     3 (2,1,3)     167      71      67     167      71      67  traces/trans.trace
     3 (2,2,3)     201      37      29     201      37      29  traces/trans.trace
     3 (2,4,3)     212      26      10     212      26      10  traces/trans.trace
     3 (5,1,5)     231       7       0     231       7       0  traces/trans.trace
     6 (5,1,5)  265189   21775   21743  265189   21775   21743  traces/long.trace
    27

TEST_CSIM_RESULTS=27
```

## Part B

这一部分难度就提升了好多，我们需要优化矩阵转置函数，让他尽量减少miss的次数，cache的大小给的参数是s=5, E=1, b=5，即一共有2^s=32组，E=1每组一行，2^b=32字节，所以说如果存储int型变量一个block就是可以存储8个int。

### 32x32

#### 分块

32x32也就是说一行有32个int，然后一个block可以存8个int，即一行需要4个block，一个cache有32个block，所以说一个cache可以存8行。

意思就是从第8行开始再写B就会和A的第一行占用同一个行，就形成了冲突不命中，所以说我们就使用分块的方法把32x32分成16个8x8的块，这样就避免了冲突不命中。

所以就可以写出第一版的代码

```
for(i = 0; i < 32; i += 8)
	for(j = 0; j < 32; j += 8)
		for(k = i; k < i + 8; k++)
            for(s = j; s < j + 8; s++)
                B[k][s] = A[s][k];
```

首先手动计算以下理想情况下的miss次数。正常情况下就只有每次读入和写入一行的时候会miss一次，所以说一个8x8的miss次数就是8次，一共有16个8x8那就是16x8=128次，A的就是128次，B的次数应该和A相同，所以说一共就是128x2=256次。用图表示就是，下面这样的

```
A：
	--------------------------------------------------------------------
0	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
1	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
2	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
3	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
4	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
5	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
6	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
7	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
8	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
9	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
10	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
11	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
12	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
13	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
14	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
15	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
16	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
17	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
18	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
19	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
20	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
21	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
22	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
23	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
24	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
25	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
26	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
27	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
28	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
29	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
30	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
31	|*| | | | | | | ||*| | | | | | | ||*| | | | | | | ||*| | | | | | | |
	--------------------------------------------------------------------
```

但是验证了发现miss次数是324次，没有达到标准，和计算的理想的次数也差了很多。这里主要是因为对角线上的冲突造成的。

原本的思想是这样的

```
A:
	-----------------
0	|0|0|0|0|0|0|0|0|
1	|1|1|1|1|1|1|1|1|
2	|2|2|2|2|2|2|2|2|
3	|3|3|3|3|3|3|3|3|
4	|4|4|4|4|4|4|4|4|
5	|5|5|5|5|5|5|5|5|
6	|6|6|6|6|6|6|6|6|
7	|7|7|7|7|7|7|7|7|
	-----------------
	
			↓
			
B:
	-----------------
0	|0|1|2|3|4|5|6|7|
1	|0|1|2|3|4|5|6|7|
2	|0|1|2|3|4|5|6|7|
3	|0|1|2|3|4|5|6|7|
4	|0|1|2|3|4|5|6|7|
5	|0|1|2|3|4|5|6|7|
6	|0|1|2|3|4|5|6|7|
7	|0|1|2|3|4|5|6|7|
	-----------------
```

但是在转换的过程中以A\[1\]\[1\]和B\[1\]\[1\]举例，原本cache中就是A[1]这一行，因为要写入B所以说cache中就是B\[1\]了,然后第一个B\[1\]\[1\]就正常的写进去了，到了B\[1\]\[1\],由于和A\[1\]\[1\]冲突所以说需要把A重新加载到cache里然后再写入，统计下来就是原本开始写的时候加载了一次A，写对角线的时候又加载了一次A，所以说对角线上就会造成两次的miss。最后一行和第一行情况有些不一样： 第一行B被加载到缓存中是第一次，应该算在那 2x8次中， 但是同样会发生A的重新加载， 所以额外产生的 miss 次数为 1。 最后一行A 被取代， 但是复制已经完成，不需要再将 A 加载进内存，所以额外的 miss 也为 1。对应图就应该是这样的

```
	-----------------
0	|*| | | | | | | |
1	|*|*| | | | | | |
2	|*| |*| | | | | |
3	|*| | |*| | | | |
4	|*| | | |*| | | |
5	|*| | | | |*| | |
6	|*| | | | | |*| |
7	|*| | | | | | |*|
```

#### 缓存分块

所以为了避免上面的对角线冲突，我们就把寄存器当做一个缓存，使用寄存器当一个中介，A存到寄存器中，再从寄存器存到B中这样就避免了A替换B造成的冲突不命中。

首先分析一下，除了对角线上的块他们的miss'次数依然还是8x12=96次，对于在对角线上的块，把A存进寄存器的时候会取代B，然后写入的时候会再把B取出，所以就会造成多7次miss，第一行没有miss所以对角线上的miss次数就是15x4=60次。再加上A的16x8=128次就是284次。和实际的结果差3次已经很接近了。

```
for (i = 0; i < 32; i += 8) {
    for (j = 0; j < 32; j += 8) {
        for (k = i; k < i + 8; k++) {
            t0 = A[k][j];
            t1 = A[k][j + 1];
            t2 = A[k][j + 2];
            t3 = A[k][j + 3];
            t4 = A[k][j + 4];
            t5 = A[k][j + 5];
            t6 = A[k][j + 6];
            t7 = A[k][j + 7];
            B[j][k] = t0;
            B[j + 1][k] = t1;
            B[j + 2][k] = t2;
            B[j + 3][k] = t3;
            B[j + 4][k] = t4;
            B[j + 5][k] = t5;
            B[j + 6][k] = t6;
            B[j + 7][k] = t7;
        }
    }
}
```

#### 先复制再转置

这个我觉着是最容易理解，而且也是最快的，由于前面分块转置，我们都是行复制列写入，就会导致对角线冲突的问题，但是如果我们直接把A完整的复制给B，也就是按行复制，miss次数就是16x8x2=256次，但是这样复制完成之后，并没有达到转置的效果，但是复制完成之后我们可以在B中进行转置，此时B的8行全部都在cache中，进行转置就不再涉及到重新加载A和加载B的步骤了，就减少了对角线冲突的miss，为最优解。

```
for (i = 0; i < M; i += len) {
    for (j = 0; j < M; j += len) {
        for (k = i, s = j; k < i + len; k++, s++) {
            t0 = A[k][j];
            t1 = A[k][j + 1];
            t2 = A[k][j + 2];
            t3 = A[k][j + 3];
            t4 = A[k][j + 4];
            t5 = A[k][j + 5];
            t6 = A[k][j + 6];
            t7 = A[k][j + 7];
            B[s][i] = t0;
            B[s][i + 1] = t1;
            B[s][i + 2] = t2;
            B[s][i + 3] = t3;
            B[s][i + 4] = t4;
            B[s][i + 5] = t5;
            B[s][i + 6] = t6;
            B[s][i + 7] = t7;
        }
        for (k = 0; k < len; k++) {
            for (s = k + 1; s < len; s++) {
                t0 = B[k + j][s + i];
                B[k + j][s + i] = B[s + j][k + i];
                B[s + j][k + i] = t0;
            }
        }
    }
}
```

### 64x64

64x64就是一行需要64个int，也就是8个block，那么存储了4行就会有重复了。显然直接按照8x8的分块来做，同一个矩阵内的缓存块就会发生冲突。按照 4x4 分块，没能充分利用加载进入缓存内的部分，测试结果也不能达到满分的要求。为了满分，我们要充分利用上面提到的两个思路：用本地变量做缓存，先复制后转置。

还是按照8x8的分块，在8x8分块中再分成4个4x4的分块，首先把A的前四行复制到B的前四行中，复制到B有两种选择一是先复制再转置，二是复制并转置。

然后把A的左下角的块的第一列元素存进寄存器中，A的右下角的块的第一列元素也存进寄存器中。

目前B的前四行只有左上角是正确转置之后的样子，右上角应该是转置之后的左下角，然后A的左下角应该是在B的右上角，A的右下角是在B的右下角。

然后我们的主要目的就是把寄存器中的内容放进B中，然后让B中就拥有了全部元素，然后B在其内部进行转换就可以了。

具体的步骤

1. 首先把A的左下角的寄存器中的内容和A的右上角进行交换，因为本来A的左下应该是B的右上，B的右上应该是B的左下，所以交换元素，就可以实现他们在正确的位置了 
2. 然后是A的右下存进B的右下
3. 然后是把寄存器中的元素存到B的左下，因为之前交换，只是交换的内容，B的左下还没有元素，所以需要把寄存器中的元素存到B的左下
4. 然后重复上面的步骤就可以了

图示如下

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-07-26_19-24-00.jpg)

对于在对角线上的块，如果前四行是复制加转置的话就会造成3次miss，后面的存寄存器，B右上交换B左下，A右下存B右下的步骤都会有额外的7次miss，加起来miss的次数就是(3+7)\*8 + 64\*8\*2=1104。

然后如果说前四行是先复制再转置的话3次miss就会被消除掉，总的次数就是1104-3*8=1083次

```
for (i = 0; i < M; i += len) {
    for (j = 0; j < N; j += len) {
        for (k = 0; k < len / 2; k++) {

            t0 = A[k + i][j];
            t1 = A[k + i][j + 1];
            t2 = A[k + i][j + 2];
            t3 = A[k + i][j + 3];
            t4 = A[k + i][j + 4];
            t5 = A[k + i][j + 5];
            t6 = A[k + i][j + 6];
            t7 = A[k + i][j + 7];

            B[j][k + i] = t0;
            B[j + 1][k + i] = t1;
            B[j + 2][k + i] = t2;
            B[j + 3][k + i] = t3;

            B[j][k + 4 + i] = t4;
            B[j + 1][k + 4 + i] = t5;
            B[j + 2][k + 4 + i] = t6;
            B[j + 3][k + 4 + i] = t7;
        }

        for (k = 0; k < len / 2; k++) {

            t0 = A[i + 4][k + j];
            t1 = A[i + 5][k + j];
            t2 = A[i + 6][k + j];
            t3 = A[i + 7][k + j];

            t4 = A[i + 4][k + 4 + j];
            t5 = A[i + 5][k + 4 + j];
            t6 = A[i + 6][k + 4 + j];
            t7 = A[i + 7][k + 4 + j];

            tmp = B[k + j][i + 4];
            B[k + j][i + 4] = t0;
            t0 = tmp;

            tmp = B[k + j][i + 5];
            B[k + j][i + 5] = t1;
            t1 = tmp;

            tmp = B[k + j][i + 6];
            B[k + j][i + 6] = t2;
            t2 = tmp;

            tmp = B[k + j][i + 7];
            B[k + j][i + 7] = t3;
            t3 = tmp;

            B[k + j +4][i] = t0;
            B[k + j +4][i + 1] = t1;
            B[k + j +4][i + 2] = t2;
            B[k + j +4][i + 3] = t3;

            B[k + j +4][i + 4] = t4;
            B[k + j +4][i + 5] = t5;
            B[k + j +4][i + 6] = t6;
            B[k + j +4][i + 7] = t7;

        }
    }
}
```

### 61x67

直接16x16分块，17x17分块即可，就可以过了验证，分块的组合有挺多16x16、17x17、8x23，直接分块之后就可以过了，8x23可以继续优化，使用寄存器当中介进行转换而且也可以先复制再转置

```
//8x23
for (i = 0; i < N; i += 8) {
    for (j = 0; j < M; j += 23) {
        if (i + 8 <= N && j + 23 <= M) {
            for (s = j; s < j + 23; s++) {
                t0 = A[i][s];
                t1 = A[i + 1][s];
                t2 = A[i + 2][s];
                t3 = A[i + 3][s];
                t4 = A[i + 4][s];
                t5 = A[i + 5][s];
                t6 = A[i + 6][s];
                t7 = A[i + 7][s];
                B[s][i + 0] = t0;
                B[s][i + 1] = t1;
                B[s][i + 2] = t2;
                B[s][i + 3] = t3;
                B[s][i + 4] = t4;
                B[s][i + 5] = t5;
                B[s][i + 6] = t6;
                B[s][i + 7] = t7;
            }
        } 
        else {
            for (k = i; k < min(i + 8, N); k++) {
                for (s = j; s < min(j + 23, M); s++) {
                    B[s][k] = A[k][s];
                }
            }
        }
    }
}
//17x17
for (i = 0; i < N; i+=17)
{
    for (j = 0; j < M; j+=17)
    {
        for (k = i; k < i + 17 && k < N; k++)
        {
            for (s = j; s < j + 17 && s < M; s++)
            {
                B[s][k] = A[k][s];
            }
        }
    }
}
```

## 测试结果

```
$ python driver.py 
Part A: Testing cache simulator
Running ./test-csim
                        Your simulator     Reference simulator
Points (s,E,b)    Hits  Misses  Evicts    Hits  Misses  Evicts
     3 (1,1,1)       9       8       6       9       8       6  traces/yi2.trace
     3 (4,2,4)       4       5       2       4       5       2  traces/yi.trace
     3 (2,1,4)       2       3       1       2       3       1  traces/dave.trace
     3 (2,1,3)     167      71      67     167      71      67  traces/trans.trace
     3 (2,2,3)     201      37      29     201      37      29  traces/trans.trace
     3 (2,4,3)     212      26      10     212      26      10  traces/trans.trace
     3 (5,1,5)     231       7       0     231       7       0  traces/trans.trace
     6 (5,1,5)  265189   21775   21743  265189   21775   21743  traces/long.trace
    27


Part B: Testing transpose function
Running ./test-trans -M 32 -N 32
Running ./test-trans -M 64 -N 64
Running ./test-trans -M 61 -N 67

Cache Lab summary:
                        Points   Max pts      Misses
Csim correctness          27.0        27
Trans perf 32x32           8.0         8         259
Trans perf 64x64           8.0         8        1107
Trans perf 61x67          10.0        10        1950
          Total points    53.0        53

```

## 参考链接

https://zhuanlan.zhihu.com/p/33846811

https://www.bilibili.com/read/cv2955433/

https://zhuanlan.zhihu.com/p/142942823	

https://yangtau.me/computer-system/csapp-cache.html#_3

https://zhuanlan.zhihu.com/p/138881600（这篇文章写的很详细，关于为什么分块、缓存分块会优化miss次数，写的比较清楚的）