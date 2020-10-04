#include <stdio.h>

void loop_func() {
    for (int i = 0; i < 10; i++) {
        printf("%d\n", i);
    }
}

void func1() {
    printf("enter func1\n");
    printf("exit func1\n");
}

void func2() {
    printf("enter func2\n");
    func1();
    printf("exit func2\n");
}

void func3() {
    printf("enter func3\n");
    func2();
    printf("exit func3\n");
}

int main() {
    printf("Welcome\n");
    printf("Hello world\n");

    loop_func();

    func3();

    printf("Bye\n");
}
