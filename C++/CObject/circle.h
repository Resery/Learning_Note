//
// Created by Resery on 2020/10/6.
//

#ifndef C_OBJECT_CIRCLE_H
#define C_OBJECT_CIRCLE_H

#include "shape.h"

typedef struct{
    Shape parrent;
    unsigned r;
}Circle;

void cicle_ctor(Circle *const me, unsigned int x, unsigned int y, unsigned int r);

#endif //C_OBJECT_CIRCLE_H
