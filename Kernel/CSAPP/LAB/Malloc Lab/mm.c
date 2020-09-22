/*
 * mm-naive.c - The fastest, least memory-efficient malloc package.
 * 
 * In this naive approach, a block is allocated by simply incrementing
 * the brk pointer.  A block is pure payload. There are no headers or
 * footers.  Blocks are never coalesced or reused. Realloc is
 * implemented directly using mm_malloc and mm_free.
 *
 * NOTE TO STUDENTS: Replace this header comment with your own header
 * comment that gives a high level description of your solution.
 */
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <unistd.h>
#include <string.h>

#include "mm.h"
#include "memlib.h"

/*********************************************************
 * NOTE TO STUDENTS: Before you do anything else, please
 * provide your team information in the following struct.
 ********************************************************/
team_t team = {
    /* Team name */
    "Resery",
    /* First member's full name */
    "Resery",
    /* First member's email address */
    "1870057065@qq.com",
    /* Second member's full name (leave blank if none) */
    "",
    /* Second member's email address (leave blank if none) */
    ""
};

/* single word (4) or double word (8) alignment */
#define ALIGNMENT 8

/* rounds up to the nearest multiple of ALIGNMENT */
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

static void* start_pos;
static char* start_link_list;
static char* end_link_list;

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


static void *extend_heap(size_t msize){
    size_t size = msize * DSIZE;
    size_t prev_alloc = GET_PREV_ALLOC(HDRP(start_pos));

    if (!prev_alloc) {
        char* prev_ptr = LAST_BLKP(start_pos);
        size_t prev_size = GET_SIZE(HDRP(prev_ptr));
        if (mem_sbrk(size - prev_size) == (void*)-1)
            return NULL;
        start_pos = start_pos + size - prev_size;
        size_t sizeClass = getSizeClass(prev_size);
        delete_node(prev_ptr, sizeClass);
        PUT(HDRP(prev_ptr), PACK(size, 0x2));
        PUT(FTRP(prev_ptr), PACK(size, 0x2));
        PUT(HDRP(start_pos), PACK(0,1));
        add_node(prev_ptr, getSizeClass(size));
        return prev_ptr;
    }
    if (mem_sbrk(size) == (void*)-1)
        return NULL;
    
    void* addr = start_pos;
    start_pos += size;
    PUT(HDRP(addr), PACK(size,0x2));
    PUT(FTRP(addr), PACK(size,0x2));
    PUT(NEXT_PTR(addr), NULL);
    PUT(LAST_PTR(addr), NULL);
    PUT(HDRP(NEXT_BLKP(addr)), PACK(0,1));
    add_node(addr, getSizeClass(size));
    return addr;
}

static void* findFitAndRemove(int size)
{
    char* link_begin = start_link_list + WSIZE * getSizeClass(size);
    while(link_begin != end_link_list) {
        char* cur_node = LINK_NEXT(link_begin);
        while(cur_node != NULL && GET_SIZE(HDRP(cur_node)) < size) {
            cur_node = LINK_NEXT(cur_node);
        }
        if (cur_node != NULL) {
            char* prev_node = LINK_LAST(cur_node);
            char* next_node = LINK_NEXT(cur_node);
            PUT(NEXT_PTR(prev_node), next_node);
            if (next_node != NULL)
                PUT(LAST_PTR(next_node), prev_node);
            PUT(NEXT_PTR(cur_node), NULL);
            PUT(LAST_PTR(cur_node), NULL);
            return cur_node;
        }
        link_begin += WSIZE;
    }
    return NULL;
}

static void delete_node(void* ptr, size_t sizeClass)
{
    char* cur_node = start_link_list + sizeClass * WSIZE;
    char* next_node = LINK_NEXT(cur_node);
    while(cur_node != (char*) ptr) {
        cur_node = next_node;
        next_node = LINK_NEXT(cur_node);
    }
    char* prev_node = LINK_LAST(cur_node);
    PUT(NEXT_PTR(prev_node), next_node);
    if (next_node != NULL)
        PUT(LAST_PTR(next_node), prev_node);
    PUT(NEXT_PTR(ptr), NULL);
    PUT(LAST_PTR(ptr), NULL);
}

static void add_node(void* ptr, size_t sizeClass)
{
    char* cur_node = start_link_list + sizeClass * WSIZE;
    char* next_node = LINK_NEXT(cur_node);
    size_t size = GET_SIZE(HDRP(ptr));
    while(next_node != NULL && GET_SIZE(HDRP(next_node)) < size) {
        cur_node = next_node;
        next_node = LINK_NEXT(cur_node);
    }
    PUT(NEXT_PTR(cur_node), ptr);
    PUT(NEXT_PTR(ptr), next_node);
    PUT(LAST_PTR(ptr), cur_node);
    if (next_node != NULL)
        PUT(LAST_PTR(next_node), ptr);
}

static void* coalesced(void *ptr)
{
    int prev_alloc = GET_PREV_ALLOC(HDRP(ptr));
    int next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(ptr)));
    size_t size = GET_SIZE(HDRP(ptr));
    if (prev_alloc && next_alloc) {
        add_node(ptr, getSizeClass(size));
        return ptr;
    }
    
    if (prev_alloc && !next_alloc) {
        void* next_ptr = NEXT_BLKP(ptr);
        size_t incr_size = GET_SIZE(HDRP(next_ptr));
        size += incr_size;
        delete_node(next_ptr, getSizeClass(incr_size));
        PUT(HDRP(ptr), PACK(size, prev_alloc));
        PUT(FTRP(ptr), PACK(size, prev_alloc));
    }
    else if (next_alloc && !prev_alloc) {
        void* prev_ptr = LAST_BLKP(ptr);
        size_t incr_size = GET_SIZE(HDRP(prev_ptr));
        size += incr_size;
        delete_node(prev_ptr, getSizeClass(incr_size));
        ptr = prev_ptr;
        PUT(HDRP(ptr), PACK(size, 0x2));
        PUT(FTRP(ptr), PACK(size, 0x2));
    }
    else {
        void* next_ptr = NEXT_BLKP(ptr);
        size_t incr_next = GET_SIZE(HDRP(next_ptr));
        delete_node(next_ptr, getSizeClass(incr_next));
        
        void* prev_ptr = LAST_BLKP(ptr);
        size_t incr_prev = GET_SIZE(HDRP(prev_ptr));
        delete_node(prev_ptr, getSizeClass(incr_prev));
        
        size = size + incr_next + incr_prev;
        ptr = prev_ptr;
        PUT(HDRP(ptr), PACK(size, 0x2));
        PUT(FTRP(ptr), PACK(size, 0x2));
    }
    add_node(ptr, getSizeClass(size));
    return ptr;
}

static void* place(void* ptr, size_t size)
{
    size_t all_size = GET_SIZE(HDRP(ptr)), res_size = all_size - size;
    if (res_size < 16) {
        OR(HDRP(NEXT_BLKP(ptr)), 0x2);
        size = all_size;
        PUT(HDRP(ptr), PACK(size, 0x3));
    }
    else if (size < 96) {
        char* new_block = (char*)ptr + size;
        PUT(HDRP(new_block), PACK(res_size, 0x2));
        PUT(FTRP(new_block), PACK(res_size, 0x2));
        PUT(NEXT_PTR(new_block), NULL);
        PUT(LAST_PTR(new_block), NULL);
        add_node(new_block, getSizeClass(res_size));
        PUT(HDRP(ptr), PACK(size, 0x3));
    } else {
        char* new_block = (char*)ptr + res_size;
        PUT(HDRP(ptr), PACK(res_size, 0x2));
        PUT(FTRP(ptr), PACK(res_size, 0x2));
        PUT(NEXT_PTR(ptr), NULL);
        PUT(LAST_PTR(ptr), NULL);
        add_node(ptr, getSizeClass(res_size));
        PUT(HDRP(new_block), PACK(size, 0x3));
        ptr = new_block;
        OR(HDRP(NEXT_BLKP(ptr)), 0x2);
    }

    return ptr;
}

static size_t getSizeClass(size_t size)
{
    size--;
    size>>=4;
    size_t ans = 0;
    while(size) {
        size >>= 1;
        ans++;
    }
    return ans <= 9 ? ans : 9;
}


/* 
 * mm_init - initialize the malloc package.
 */
int mm_init(void)
{
    char* start;
    if ((start = (char*) mem_sbrk(14 * WSIZE)) == (char*) -1)
        return -1;
    PUT(start, 0);                   // size <= 16
    PUT(start + 1 * WSIZE, 0);       // size <= 32
    PUT(start + 2 * WSIZE, 0);       // size <= 64
    PUT(start + 3 * WSIZE, 0);       // size <= 128
    PUT(start + 4 * WSIZE, 0);       // size <= 256
    PUT(start + 5 * WSIZE, 0);       // size <= 512
    PUT(start + 6 * WSIZE, 0);       // size <= 1024
    PUT(start + 7 * WSIZE, 0);       // size <= 2048
    PUT(start + 8 * WSIZE, 0);       // size <= 4096
    PUT(start + 9 * WSIZE, 0);       // size > 4096
    PUT(start + 10 * WSIZE, 0);         // for alignment
    PUT(start + 11 * WSIZE, PACK(8,1)); // the prologue block
    PUT(start + 12 * WSIZE, PACK(8,1));
    PUT(start + 13 * WSIZE, PACK(0,3)); // the epilogue block
    start_pos = start + 14 * WSIZE;
    start_link_list = start;
    end_link_list = start + 10 * WSIZE;
    
    if (extend_heap(CHUNKSIZE / DSIZE) == NULL)
        return -1;
    
    return 0;
}

/* 
 * mm_malloc - Allocate a block by incrementing the brk pointer.
 *     Always allocate a block whose size is a multiple of the alignment.
 */
void *mm_malloc(size_t size)
{
    size_t newsize = MAX(ALIGN(size + WSIZE), 16), incr;
    void* addr;
    if ((addr = findFitAndRemove(newsize)) == NULL) {
        incr = MAX(CHUNKSIZE, newsize);
        extend_heap(incr / DSIZE);
        addr = findFitAndRemove(newsize);
    }
    return place(addr, newsize);
}

/*
 * mm_free - Freeing a block does nothing.
 */
void mm_free(void *ptr)
{
    size_t size = GET_SIZE(HDRP(ptr));
    size_t prev_alloc = GET_PREV_ALLOC(HDRP(ptr));
    AND(HDRP(NEXT_BLKP(ptr)), ~0x2);
    PUT(HDRP(ptr), PACK(size, prev_alloc));
    PUT(FTRP(ptr), PACK(size, prev_alloc));
    PUT(NEXT_PTR(ptr), NULL);
    PUT(LAST_PTR(ptr), NULL);
    coalesced(ptr);
}

/*
 * mm_realloc - Implemented simply in terms of mm_malloc and mm_free
 */
void *mm_realloc(void *ptr, size_t size)
{
    if (size == 0)
    {
        mm_free(ptr);
        return NULL;
    }
    
    if (ptr == NULL)
    {
        return mm_malloc(size);
    }
    
    size_t oldBlockSize = GET_SIZE(HDRP(ptr));
    size_t oldSize = oldBlockSize - WSIZE;
    
    
    if (oldSize >= size) {
        // todo : spilt the block.
        return ptr;
    } else {
        size_t next_alloc = GET_ALLOC(HDRP(NEXT_BLKP(ptr)));
        size_t next_size = GET_SIZE(HDRP(NEXT_BLKP(ptr)));
        if (!next_alloc && next_size + oldSize >= size) {
            delete_node(ptr + oldBlockSize, getSizeClass(next_size));
            OR(HDRP(NEXT_BLKP(NEXT_BLKP(ptr))), 0x2);
            PUT(HDRP(ptr), PACK(next_size + oldBlockSize, GET_PREV_ALLOC(HDRP(ptr)) | 0x1));
            return ptr;
        }
        if (NEXT_BLKP(ptr) == start_pos) {
            size_t newsize = ALIGN(size - oldSize);
            if (mem_sbrk(newsize) == (void*)-1)
                return NULL;
            PUT(HDRP(ptr), PACK(oldBlockSize + newsize, GET_PREV_ALLOC(HDRP(ptr)) | 0x1));
            start_pos += newsize;
            PUT(HDRP(start_pos), PACK(0, 0x3));
            return ptr;
        }
        void *newptr = mm_malloc(size);
        if (newptr == NULL)
            return NULL;
        memcpy(newptr, ptr, oldSize);
        mm_free(ptr);
        return newptr;
    }
}














