//
// Created by Resery on 2020/10/6.
//

#ifndef C_OBJECT_RECTANGLE_C
#define C_OBJECT_RECTANGLE_C

#include "rectangle.h"

static unsigned int Rectangle_area_(Shape const * const me);
static void Rectangle_draw_(Shape const * const me);

void rectangle_ctor(Rectangle *const me,
        unsigned int x, unsigned int y,
        unsigned int width, unsigned int height){
    static struct ShapeVtbl const vtbl =
            {
                    &Rectangle_area_,
                    &Rectangle_draw_
            };
    shape_ctor(&me->parrent,x,y);
    me->parrent.vptr = &vtbl;
    me->width = width;
    me->height = height;
}

static unsigned int Rectangle_area_(Shape const * const me)
{
    Rectangle const * const me_ = (Rectangle const *)me; //显示的转换
    return (unsigned int)me_->width * (unsigned int)me_->height;
}

static void Rectangle_draw_(Shape const * const me)
{
    Rectangle const * const me_ = (Rectangle const *)me; //显示的转换
    printf("Rectangle_draw_(x=%d,y=%d,width=%d,height=%d)\n",
           shape_getx(me), shape_gety(me), me_->width, me_->height);
}
#endif //C_OBJECT_RECTANGLE_C
