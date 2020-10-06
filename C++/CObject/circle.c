//
// Created by Resery on 2020/10/6.
//

#ifndef C_OBJECT_CIRCLE_C
#define C_OBJECT_CIRCLE_C

#include "circle.h"

static unsigned int cicle_area_(Shape const * const me);
static void cicle_draw_(Shape const * const me);

void cicle_ctor(Circle *const me, unsigned int x, unsigned int y, unsigned int r){
    static struct ShapeVtbl const vtbl =
            {
                    &cicle_area_,
                    &cicle_draw_
            };
    shape_ctor(&me->parrent,x,y);
    me->parrent.vptr = &vtbl;
    me->r = r;
}

static unsigned int cicle_area_(Shape const * const me)
{
    Circle const * const me_ = (Circle const *)me; //显示的转换
    return (unsigned int)me_->r * (unsigned int)me_->r * 3;
}

static void cicle_draw_(Shape const * const me)
{
    Circle const * const me_ = (Circle const *)me; //显示的转换
    printf("Rectangle_draw_(x=%d,y=%d,r=%d)\n",
           shape_getx(me), shape_gety(me), me_->r);
}

#endif //C_OBJECT_CIRCLE_C