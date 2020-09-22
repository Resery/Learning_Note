/*
* @Author: resery
* @Date:   2020-08-17 19:42:14
* @Last Modified by:   resery
* @Last Modified time: 2020-08-17 22:31:43
*/
#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>
#include <buddy.h>
//来自参考资料的一些宏定义
#define LEFT_LEAF(index) ((index) * 2 + 1)
#define RIGHT_LEAF(index) ((index) * 2 + 2)
#define PARENT(index) ( ((index) + 1) / 2 - 1)

#define IS_POWER_OF_2(x) (!((x)&((x)-1)))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

#define UINT32_SHR_OR(a,n)      ((a)|((a)>>(n)))//右移n位  

#define UINT32_MASK(a)          (UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(UINT32_SHR_OR(a,1),2),4),8),16))    
//大于a的一个最小的2^k
#define UINT32_REMAINDER(a)     ((a)&(UINT32_MASK(a)>>1))
#define UINT32_ROUND_DOWN(a)    (UINT32_REMAINDER(a)?((a)-UINT32_REMAINDER(a)):(a))//小于a的最大的2^k

static unsigned fixsize(unsigned size) {
	size |= size >> 1;
	size |= size >> 2;
	size |= size >> 4;
	size |= size >> 8;
	size |= size >> 16;
	return size+1;
}

struct buddy2 {
	unsigned size;//表明管理内存
	unsigned longest; 
};
struct buddy2 root[80000];//存放二叉树的数组，用于内存分配

free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)
  
struct allocRecord//记录分配块的信息
{
	struct Page* base;
	int offset;
	size_t nr;//块大小
};
struct allocRecord rec[80000];//存放偏移量的数组
int nr_block;//已分配的块数

static void
buddy_init()
{
    list_init(&free_list);
    nr_free=0;
}

//初始化二叉树上的节点
void
buddy2_new( int size ) {
unsigned node_size;
	int i;
	nr_block=0;
	if (size < 1 || !IS_POWER_OF_2(size))
  		return;

	root[0].size = size;
	node_size = size * 2;
	for (i = 0; i < 2 * size - 1; ++i) {
  	if (IS_POWER_OF_2(i+1))
    	node_size /= 2;
  		root[i].longest = node_size;
	}
	return;
}

//初始化内存映射关系
static void
buddy_init_memmap(struct Page *base, size_t n)
{
    assert(n>0);
    struct Page* p=base;
    for(;p!=base + n;p++)
    {
        assert(PageReserved(p));
        p->flags = 0;
        p->property = 1;
        set_page_ref(p, 0);   
        SetPageProperty(p);
        list_add_before(&free_list,&(p->page_link));     
    }
    nr_free += n;
    int allocpages=UINT32_ROUND_DOWN(n);
    buddy2_new(allocpages);
}

//内存分配
int
buddy2_alloc(struct buddy2* self, int size) {
  unsigned index = 0;//节点的标号
  unsigned node_size;
  unsigned offset = 0;

  if (self==NULL)//无法分配
    return -1;

  if (size <= 0)//分配不合理
    size = 1;
  else if (!IS_POWER_OF_2(size))//不为2的幂时，取比size更大的2的n次幂
    size = fixsize(size);

  if (self[index].longest < size)//可分配内存不足
    return -1;

  for(node_size = self->size; node_size != size; node_size /= 2 ) {
    if (self[LEFT_LEAF(index)].longest >= size)
    {
       if(self[RIGHT_LEAF(index)].longest>=size)
        {
           index=self[LEFT_LEAF(index)].longest <= self[RIGHT_LEAF(index)].longest? LEFT_LEAF(index):RIGHT_LEAF(index);
         //找到两个相符合的节点中内存较小的结点
        }
       else
       {
         index=LEFT_LEAF(index);
       }  
    }
    else
      index = RIGHT_LEAF(index);
  }

  self[index].longest = 0;//标记节点为已使用
  offset = (index + 1) * node_size - self->size;
  while (index) {
    index = PARENT(index);
    self[index].longest = 
      MAX(self[LEFT_LEAF(index)].longest, self[RIGHT_LEAF(index)].longest);
  }
//向上刷新，修改先祖结点的数值
  return offset;
}

static struct Page*
buddy_alloc_pages(size_t n){
	assert(n>0);
	if(n>nr_free)
		return NULL;

	struct Page* page = NULL;
	struct Page* p;
	int allocpages;
	list_entry_t *le = &free_list;
	list_entry_t *len;
	rec[nr_block].offset = buddy2_alloc(root,n);//记录偏移量

	for(int i = 0;i < rec[nr_block].offset + 1;i++)
   		le = list_next(le);
	page = le2page(le,page_link);
	
	if(!IS_POWER_OF_2(n))
  		allocpages = fixsize(n);
	else
   		allocpages = n;

	//根据需求n得到块大小
	rec[nr_block].base = page;//记录分配块首页
	rec[nr_block].nr = allocpages;//记录分配的页数
	nr_block++;
  	for(int i = 0;i < allocpages;i++)
  	{
    	len = list_next(le);
    	p = le2page(le,page_link);
    	ClearPageProperty(p);
    	le = len;
  	}//修改每一页的状态
  	nr_free -= allocpages;//减去已被分配的页数
  	page->property = n;
  	return page;
}

void
buddy_free_pages(struct Page* base, size_t n) {
  unsigned node_size, index = 0;
  unsigned left_longest, right_longest;
  struct buddy2* self = root;
  
  list_entry_t *le = list_next(&free_list);
  int i = 0;
  for(i = 0;i < nr_block;i++)//找到块
  {
    if(rec[i].base == base)
     break;
  }
  int offset = rec[i].offset;
  int pos = i;//暂存i
  i = 0;
  while(i < offset)
  {
    le = list_next(le);
    i++;
  }
  int allocpages;
  if(!IS_POWER_OF_2(n))
   allocpages = fixsize(n);
  else
  {
     allocpages = n;
  }
  assert(self && offset >= 0 && offset < self->size);//是否合法
  node_size = 1;
  index = offset + self->size - 1;
  nr_free += allocpages;//更新空闲页的数量
  struct Page* p;
  self[index].longest = allocpages;
  for(i = 0;i < allocpages;i++)//回收已分配的页
  {
     p = le2page(le,page_link);
     p->flags = 0;
     p->property = 1;
     SetPageProperty(p);
     le = list_next(le);
  }
  while (index) {//向上合并，修改先祖节点的记录值
    index = PARENT(index);
    node_size *= 2;

    left_longest = self[LEFT_LEAF(index)].longest;
    right_longest = self[RIGHT_LEAF(index)].longest;
    
    if (left_longest + right_longest == node_size) 
      self[index].longest = node_size;
    else
      self[index].longest = MAX(left_longest, right_longest);
  }
  for(i = pos;i < nr_block-1;i++)//清除此次的分配记录
  {
    rec[i] = rec[i+1];
  }
  nr_block--;//更新分配块数的值
}

static size_t
buddy_nr_free_pages(void) {
    return nr_free;
}

static void
buddy_check(void) {
    struct Page *p0, *A, *B,*C,*D;
    p0 = A = B = C = D =NULL;

    assert((p0 = alloc_page()) != NULL);
    assert((A = alloc_page()) != NULL);
    assert((B = alloc_page()) != NULL);

    assert(p0 != A && p0 != B && A != B);
    assert(page_ref(p0) == 0 && page_ref(A) == 0 && page_ref(B) == 0);
    free_page(p0);
    free_page(A);
    free_page(B);
    
    A=alloc_pages(500);
    B=alloc_pages(500);
    cprintf("A %p\n",A);
    cprintf("B %p\n",B);
    free_pages(A,250);
    free_pages(B,500);
    free_pages(A+250,250);
    
    p0=alloc_pages(1024);
    cprintf("p0 %p\n",p0);
    assert(p0 == A);
    //以下是根据链接中的样例测试编写的
    A=alloc_pages(70);  
    B=alloc_pages(35);
    assert(A+128==B);//检查是否相邻
    cprintf("A %p\n",A);
    cprintf("B %p\n",B);
    C=alloc_pages(80);
    assert(A+256==C);//检查C有没有和A重叠
    cprintf("C %p\n",C);
    free_pages(A,70);//释放A
    cprintf("B %p\n",B);
    D=alloc_pages(60);
    cprintf("D %p\n",D);
    assert(B+64==D);//检查B，D是否相邻
    free_pages(B,35);
    cprintf("D %p\n",D);
    free_pages(D,60);
    cprintf("C %p\n",C);
    free_pages(C,80);
    free_pages(p0,1000);//全部释放
}

const struct pmm_manager default_pmm_manager = {
    .name = "buddy_system",
    .init = buddy_init,
    .init_memmap = buddy_init_memmap,
    .alloc_pages = buddy_alloc_pages,
    .free_pages = buddy_free_pages,
    .nr_free_pages = buddy_nr_free_pages,
    .check = buddy_check,
};
