//
// Created by Resery on 2020/10/6.
//

#ifndef C_OBJECT_RECTANGLE_H
#define C_OBJECT_RECTANGLE_H

#include "shape.h"

typedef struct {
    Shape parrent;
    unsigned int width;
    unsigned int height;
}Rectangle;

void rectangle_ctor(Rectangle *const Rectangle,
                    unsigned int x, unsigned int y,
                    unsigned int width, unsigned int height);

#endif //C_OBJECT_RECTANGLE_C
