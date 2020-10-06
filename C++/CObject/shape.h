//
// Created by Resery on 2020/10/6.
//

#ifndef C_OBJECT_SHAPE_H
#define C_OBJECT_SHAPE_H

#include <stdio.h>

typedef struct{
    struct ShapeVtbl const *vptr;
    unsigned int x;
    unsigned int y;
}Shape;

struct ShapeVtbl {
    unsigned long (*fun_addr[20])();
    unsigned int (*area)(Shape const * const me);
    void (*draw)(Shape const * const me);
};

void shape_ctor(Shape *const me, unsigned int x, unsigned int y);
void shape_add(Shape *const me, unsigned int x, unsigned int y);
unsigned int shape_getx(Shape const *const me);
unsigned int shape_gety(Shape const *const me);

static inline unsigned int Shape_area(Shape const * const me)
{
    return (*me->vptr->fun_addr[0])(me);
}

static inline void Shape_draw(Shape const * const me)
{
    (*me->vptr->fun_addr[1])(me);
}

Shape const *largestShape(Shape const *shapes[], unsigned int nShapes);
void drawAllShapes(Shape const *shapes[], unsigned int nShapes);

#endif //C_OBJECT_SHAPE_H