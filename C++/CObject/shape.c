//
// Created by Resery on 2020/10/6.
//
#include "shape.h"
#include <assert.h>

static unsigned int Shape_area_(Shape const * const me);
static void Shape_draw_(Shape const * const me);

void shape_ctor(Shape *const me, unsigned int x, unsigned int y){
    static struct ShapeVtbl const vtbl =
            {
                    &Shape_area_,
                    &Shape_draw_
            };
    me->vptr = &vtbl;

    me->x = x;
    me->y = y;
}

void shape_add(Shape *const me, unsigned int x, unsigned int y){
    me->x += x;
    me->y += y;
}

unsigned int shape_getx(Shape const *const me){
    return me->x;
}

unsigned int shape_gety(Shape const *const me){
    return me->y;
}

// Shape 类的虚函数实现
static unsigned int Shape_area_(Shape const * const me)
{
    assert(0); // 类似纯虚函数
    return 0U; // 避免警告
}

static void Shape_draw_(Shape const * const me)
{
    assert(0); // 纯虚函数不能被调用
}


Shape const *largestShape(Shape const *shapes[], unsigned int nShapes)
{
    Shape const *s = (Shape *)0;
    unsigned int max = 0U;
    unsigned int i;
    for (i = 0U; i < nShapes; ++i)
    {
        unsigned int area = Shape_area(shapes[i]);// 虚函数调用
        if (area > max)
        {
            max = area;
            s = shapes[i];
        }
    }
    return s;
}


void drawAllShapes(Shape const *shapes[], unsigned int nShapes)
{
    unsigned int i;
    for (i = 0U; i < nShapes; ++i)
    {
        Shape_draw(shapes[i]); // 虚函数调用
    }
}