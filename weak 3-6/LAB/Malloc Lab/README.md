# Malloc Lab

主要是实现动态内存分配器，其次还需要进行优化，增加效率和空间利用率

实验要求（翻译的writeup）

1. 你不应该修改mm.c文件中的任何接口（You should not change any of the interfaces in mm.c. ）
2. 你不能使用任何内存管理的依赖库或者系统调用，但是不包括使用malloc，alloc，free，realloc，sbrk，brk或者这些调用的变体（You should not invoke any memory-management related library calls or system calls. This excludes the use of malloc, calloc, free, realloc, sbrk, brk or any variants of these calls in your code. ）
3. 你不能再你的mm.c文件中定义任何全局或者静态的数据结构像数组，数据结构，树或者链表。然而你可以被允许使用全局变量例如整数，浮点数和指针（You are not allowed to define any global or static compound data structures such as arrays, structs, trees, or lists in your mm.c program. However, you are allowed to declare global scalar variables such as integers, floats, and pointers in mm.c.）
4. 为了与libc中的malloc包一致，返回的块都应该是8字节对齐的，你的分配器返回的指针必须也是8字节对齐的，驱动程序会强制执行此要求（For consistency with the libc malloc package, which returns blocks aligned on 8-byte boundaries, your allocator must always return pointers that are aligned to 8-byte boundaries. The driver will enforce this requirement for you.）

首先就是需要确定一下我们采取什么方法管理空闲链表，书上写了三种管理方法

1. 隐式空闲链表：这种方式最为简单，直接将所有的块(不管是否有分配)串在一起，然后遍历。这种方式可也使得块最小可以达到8 bytes。当然，这种方式效率很低，尤其是当块的数量较多的时候。
2. 显式空闲链表：在每一个free 块中保存两个指针，将所有空闲的块组成一个双向链表。和隐式相比，这种方式最大的好处在于我们不需要遍历已经分配的块，速度上快了很多，当然，由于需要保存指针，所以每一个块最小为16 bytes。
3. 分离式空闲链表：这种方式的特点在于，根据块的不同大小，分成k组，组织成k条双向链表。分类的方式有很多，比如可以采用2的倍数的分类方式，{1},{2},{3~4},{5~8}……大小为6的块放在第四条链中，大小为3的块则放在第三条链中等等。这里采用的分类是{1~16},{17~32},{33~64},{65~128},{129~256},{257,512},{513~1024},{1025~2048},{2049~4096},{4096~…};其实这个应该也是ptmalloc中采取的方法，只不过ptmalloc分的更细，fastbin，smallbin，largebin，unsortbin，tache等。

根据这三种情况可以分别想一下对应的结果

1. 隐式空闲链表，假如说符合要求的块在最后，那么就需要遍历到最后一个块，然后去分配内存，效率相当低下
2. 显式空闲链表，在速度上比隐式空闲链表快很多，但是会导致内部碎片很可能更大
   - 内部碎片，即是已经被分配出去（能明确指出属于哪个进程）却不能被利用的内存空间。比如当前我需要44 bytes的内存，然后malloc的时候分配到了一个48 bytes的块，这样的话，剩下的4bytes的内存尽管我不需要用到，但是其他程序也无法使用，这就是内部碎片。
   - 外部碎片，即还没有被分配出去（不属于任何进程），但由于太小了无法分配给申请内存空间的新进程的内存空闲区域。比如说现在有两个2字节的空闲块，但是不是相邻的，而我现在想要申请一个4字节的块，虽然现在有4字节的空闲块，但是是由两个不相邻的2字节的块组成的，所以就不能使用这两个2字节的块，这就导致了外部碎片。
3. 分离式空闲链表，它就很容易的解决了，效率和碎片化的问题，因为它是按照大小来组织的所以说可以在分配的时候找对应大小的链表中合适的块就会解决碎片化的问题了

所以从上面来看最适合的而且效率和空间利用率最高的就是分离式空闲链表，所以在我们的实验中就采用分离式空闲链表，所以就可以确定出我们的分配块和空闲块的结构图

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-02_13-21-49.png)

左面是空闲块的结构，size就是这个块的大小，flag就是这个块的分配状态以及前一个块的分配状态，prev就是前一个块，next就是下一个块，content就是块中的填充size大小的部分

右面的是分配快，size就是这个块的大小，flag就是这个块的分配状态以及前一个块的分配状态，content是这个块中的内容

结构和组织方式确定之后，就需要定义一些宏了，方便之后的代码的编写

```
#define ALIGNMENT 8

#define ALIGN(size) (((size) + (ALIGNMENT-1)) & ~0x7)

#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))

#define MAX_LIST_SIZE 16

#define WSIZE 4
#define DSIZE 8
#define CHUNKSIZE (1<<12)

#define MAX(x,y) ((x) > (y) ? (x) : (y))

#define PACK(size,alloc) ((size) | (alloc))

#define GET(p)  (*(unsigned int*)(p))
#define PUT(p, val) (*(unsigned int*)(p) = (unsigned int)(val))
#define ADD(p, val) (*(unsigned int*)(p) += (unsigned int)(val))
#define OR(p, val)  (*(unsigned int*)(p) |= (unsigned int)(val))
#define AND(p, val) (*(unsigned int*)(p) &= (unsigned int)(val))
#define XOR(p, val) (*(unsigned int*)(p) ^= (unsigned int)(val))

#define GET_SIZE(p) (GET(p) & ~0x7)
#define GET_ALLOC(p) (GET(p) & 0x1)
#define GET_PREV_ALLOC(p) (GET(p) & 0x2)

#define HDRP(bp) ((char *)(bp) - WSIZE)
#define FTRP(bp) ((char *)(bp) + GET_SIZE(HDRP(bp)) - DSIZE)

#define NEXT_BLKP(bp) ((char *)(bp) + GET_SIZE(((char *)(bp) - WSIZE)))
#define LAST_BLKP(bp) ((char *)(bp) - GET_SIZE(((char *)(bp) - DSIZE)))

#define NEXT_PTR(bp) ((char*)(bp))
#define LAST_PTR(bp) ((char*)(bp) + WSIZE)

#define LINK_NEXT(bp) ((char *)GET(bp))
#define LINK_LAST(bp) ((char *)GET(bp + WSIZE))

#define SIZE_T_SIZE (ALIGN(sizeof(size_t)))
```

按行解释一下

ALIGNMENT，对齐方式，8字节对齐

ALIGN，变成8字节对齐

SIZE_T_SIZE，返回对齐之后的字节数

MAX_LIST_SIZE，最大链表大小16

WSIZE，DSIZE，单字4字节，双子8字节

CHUNKSIZE，块的最大size，2的12次方

MAX，就是max函数

PACK，分配一个块，size为大小，alloc为分配状态

GET，获取一个块的指针

PUT，ADD，OR，AND，XOR，给这个指针指向的块赋值，其余也就是运算

GET_SIZE，获取一个块的size

GET_ALLOC，获取一个块的分配状态

GET_PREV_ALLOC，获取前一个块的分配状态

HDRP，返回指向头部的指针

FTRP，返回指向脚部的指针

NEXT_BLKP，返回下一个块的块指针

LAST_BLKP，返回上一个块的块指针

NEXT_PTR，返回空闲块中的指向下一个空闲块的指针

LAST_PTR，返回空闲块中的指向上一个空闲块的指针

LINK_NEXT，返回下一个空闲块的指针

LINK_LAST，返回上一个空闲块的指针

宏定义结束之后就是需要想一下，都需要构造哪些函数，首先文件里提供的四个函数

```
int mm_init(void);
void *mm_malloc(size_t size);
void mm_free(void *bp);
void *mm_realloc(void *ptr, size_t size);
```

分别对应初始化，分配，释放，重新分配，其次就是应该我们自己填入的了。根据我们的设定，采用分离式空闲链表的组织方式，不管是什么方式首先它是一个链表所以说增删结点的函数就一定需要，所以就有增删的函数

```
static void delete_node(void* ptr, size_t sizeClass);
static void add_node(void* ptr, size_t sizeClass);
```

之后就要考虑一下8字节对齐，所以说当我们申请的字节数不是8的倍数的时候就需要8字节对齐，所以就需要对应的扩展函数

```
static void* extend_heap(size_t words);
```

然后就是对应malloc的时候我应该选取哪一个块来分配内存，就有了寻找适配的函数

```
static void* findFitAndRemove(int size);
```

找到了合适的位置就是放置了，就有了放置函数

```
static void* place(void* bp, size_t asize);
```

再其次就是我们可以对两个相邻的空闲块进行合并，就可以让他们分配更大的块，就有了合并空闲块的函数

```
static void* coalesced(void *ptr);
```

然后就是一个辅助函数，返回当前的size值对应在第几条链表上

```
static size_t getSizeClass(size_t size);
```

所以就一共需要定义11个函数（包含文件中本来就有的4个）

```
static size_t getSizeClass(size_t size);
static void* extend_heap(size_t words);
static void* findFitAndRemove(int size);
static void delete_node(void* ptr, size_t sizeClass);
static void add_node(void* ptr, size_t sizeClass);
static void* coalesced(void *ptr);
static void* place(void* bp, size_t asize);

int mm_init(void);
void *mm_malloc(size_t size);
void mm_free(void *bp);
void *mm_realloc(void *ptr, size_t size);
```

然后就需要考虑全局变量的问题了，也就是我们现在需要完成初始化的内容了，首先我们需要定义10条链表分别保存不同大小的chunk，然后其次需要一个填充对齐的，我们的链表是定义在堆里面的，然后在空闲链表定义之后就应该初始化堆的定义，也就是两个序言块，和一个结束块，序言块和结束块的图如图所示，整个结构如图所示

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-02_14-07-41.png)

![](https://resery-tuchuang.oss-cn-beijing.aliyuncs.com/2020-08-02_14-08-35.png)

所以我们就需要定义三个全局变量，对于空闲链表需要两个，堆空间需要一个，空闲链表需要一个指向头和尾的指针，堆需要一个指向堆头的指针。所以全局变量就是下面这个样子的

```
static void* start_pos;
static char* start_link_list;
static char* end_link_list;
```



**所有的准备工作都结束，下面就是完善各个函数了**

## mm_init

首先就是init初始化函数，根据上面的图我们就可以知道，我们需要先在堆里申请14\*WSIZE这么大的空间，然后开始构造空闲链表，对其块，序言块，结束块。构造结束之后把对应的指针指向对应的位置，然后初始一个大小为（CHUNKSIZE/DSIZE）的堆空间，初始堆空间就需要用到extend_heap函数了

## extend_heap

第二个完成的就应该是extend_heap函数，因为我们需要8字节对齐，所以每次都应该扩展8的倍数，其次，在拓展的时候，可以有一个小优化。假设我们需要拓展的大小为size。拓展时，我们先查看位于堆顶端的块，如果堆顶端是一个空闲的块，并且大小为msize的话，我们可以只拓展size - msize即可。这样的话可以在一定程度上提高空间利用率(针对某些比较特殊的数据效果很明显)。当然，这样的话也会使得整个程序效率降低(频繁使用mem_sbrk的话对程序性能的影响是很大的，这是一个系统调用)。

初始化和扩展都完善成功了，就是malloc了

## mm_malloc

malloc其实也都是在调用别的函数，首先需要对给的size进行一下操作，判断一下输入的size对齐之后是不是大于16的，如果大于16就malloc对应的size对齐之后的size，如果说不是大于16的就malloc 16个字节，这里就可以用8举例比如malloc(8)，8已经是8字节对齐的了，而且也是8的倍数，但是由于我们需要放置prev，next指针，所以最小应该是16字节，我们就需要让它为16字节。

然后就是调用findFitAndRemove函数，寻找合适的位置，如果说没有找到合适的位置，就是扩展块了，然后在扩展的块中寻找合适的位置，然后再调用place函数，放置块

## findFitAndRemove

上面调用到了findFitAndRemove函数所以就需要完成findFitAndRemove函数，首先需要介绍一下适配方式

1. first fit: 最为直接的办法。扫描所有的块，只要当前块的大小满足要求就使用，速度较快。但容易导致空闲列表中前面的块被不断地细分，而后面的一些块却一直迟迟得不到利用
2. second fit: 扫描的时候，每次从上一次扫描的下一个块开始，这样可以使得整个列表的块都可以被使用，这使得效率更高。然而，实际应用中，作用也很有限，容易产生很大的空间浪费，造成大量碎片
3. best fit：这种方式最大的好处是可以充分地利用空间。找到所有满足要求的块中最小的那一个，这样可以很大程度上避免浪费。当然，这也使得时间成本较高，尤其是如果空间链表的组织方式不太恰当的话，容易导致每次都要遍历一整个列表

这里findFitAndRemove采用的就是best fit，首先确定一下这个size适合在哪个链表插入，然后需要从头到尾遍历，遍历到刚好大于size的那个位置然后看一下现在是不是走到末尾了，如果不是末尾就对当前的块进行赋值，然后在链表中删除这个结点并把原本的前后两个块连起来，结束之后返回插入位置的指针

## place

palce函数的核心思想就是将大的块放在右侧，小的块放在左侧，然后当大的块free掉之后，就能形成一个更大的块来存放。其实更多情况下这更像是一种针对数据造函数的思想，当然，如果数据更改或者是一些顺序更换，这样的写法就有时候反而会导致效率极度下降。

然后该函数中就涉及到了add_node这个函数

## add_node

add_node就是来添加结点的，他这个主要的思想也是大的块放在右侧，小的块放在左侧。然后找到合适位置，构造对应的指针就可以了

## delete_node

与add_node对应的就是delete_node了，也就是删除结点

## getSizeClass

前面的那些函数也都用到它了，这个它是返回这个块属于哪个级别的size

## free

free的时候下一个块的第二个标志位应该清零。以及free的时候，要顺便看下前后能不能合并，可以合并的话应该合并完后再插入到链表当中。合并就涉及到了coalesced函数，其中free的具体操作为先获取这个块的大小，然后是检测前面的块的分配状态，再修改后一个块的flag让他的倒数第二位变成0，之后就是修改指针。之后就是考虑可否合并调用coalesced函数

## coalesced

合并空闲块，合并空闲块就需要分情况了

1. 前一个块和后一个块都是已分配的情况下，直接调用add_node
2. 前一个块是已分配的后一个块是未分配的，那么就是与后一个块合并了
3. 前一个块是未分配的后一个块是分配的，那就是与前一个块合并了
4. 前一个块和后一个块都是未分配的，那么就是分别与后一个块和前一个块合并

后3种情况最后都需要调用一个add_node函数，第一个直接返回插入的指针就可以了

## realloc

关于这个函数，是因为它有比较多的可以优化的地方。trace文件中的最后两个测试如果不采用一定的优化的话，会导致空间利用率很低，甚至Out of memory。

首先，如果realloc的size比之前还小，那么我们不需要进行拷贝，直接返回即可(或者可以考虑对当前块进行分割)

其次，如果下一块是一个空闲块的话，我们可以直接将其占用。这样的话可以很大程度上减少external fragmentation。充分地利用了空闲的块。(前一个块是空闲的话并没有什么作用。还是需要将内容复制过去，因此不讨论)

接着，如果下一个块恰好是堆顶，我们可以考虑直接拓展堆，这样的话就可以避免free和malloc，提高效率。

最后，实在没有办法的情况下，我们再考虑重新malloc一块内存，并且free掉原先的内存块。这里要注意一下malloc和free的顺序，如果直接换过来的话可能导致错误。(free的时候有可能会把predecessor和successor的位置清为NULL，这里具体要看前面的函数是怎么写的。总之要小心一点。)