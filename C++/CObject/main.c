#include <stdio.h>
#include "shape.h"
#include "rectangle.h"
#include "circle.h"

int main() {
    Shape s1,s2;
    Rectangle r1,r2;
    Circle c1,c2;

    Shape const *shapes[] =
    {
            &r1.parrent,
            &r2.parrent,
            &c1.parrent,
            &c2.parrent
    };
    Shape const *s;

    shape_ctor(&s1,10,10);
    shape_ctor(&s2,20,20);

    rectangle_ctor(&r1,10,10,20,20);
    rectangle_ctor(&r2,20,20,30,30);

    cicle_ctor(&c1,30,30,30);
    cicle_ctor(&c2,40,40,40);

    s = largestShape(shapes, sizeof(shapes)/sizeof(shapes[0]));
    printf("largetsShape s(x=%d,y=%d)\n", shape_getx(s), shape_gety(s));

    printf("s1.x:%u\ts1.y:%u\n",s1.x,s1.y);
    printf("s2.x:%u\ts2.y:%u\n",s2.x,s2.y);

    shape_add(&s1,5,5);
    shape_add(&s2,5,5);

    printf("\nafter add\n\n");

    printf("s1.x:%u\ts1.y:%u\n",s1.x,s1.y);
    printf("s2.x:%u\ts2.y:%u\n",s2.x,s2.y);

    printf("\nuse get func\n\n");

    printf("s1.x:%u\n",shape_getx(&s1));
    printf("s1.y:%u\n",shape_gety(&s2));
    printf("s2.x:%u\n",shape_getx(&s1));
    printf("s2.y:%u\n",shape_gety(&s2));

    printf("\n");

    drawAllShapes(shapes, sizeof(shapes)/sizeof(shapes[0]));

    return 0;
}
