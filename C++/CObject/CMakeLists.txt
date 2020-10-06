cmake_minimum_required(VERSION 3.13)
project(C_Object C)

set(CMAKE_C_STANDARD 99)

add_executable(C_Object main.c shape.h shape.c "rectangle.c" rectangle.h circle.h circle.c)