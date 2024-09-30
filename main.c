// #include <glib.h>
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    // printf("GLib version: %d.%d.%d\n", GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION, GLIB_MICRO_VERSION);
    return 0;
}

// gcc -c main.c -o main.o
// gcc main.o -o main

// gcc -c main.c -o main.o $(pkg-config --cflags glib-2.0)
// gcc main.o -o main $(pkg-config --libs glib-2.0)


// pkg-config --variable pc_path pkg-config
// pkg-config --list-all