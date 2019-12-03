#ifndef MAP_H
#define MAP_H
// #include <fstream>
#include <stdio.h>
#include <string.h>
// #include <map>
// #include <set>
// using std::map;
// using std::set;
// using std::ifstream;
// using std::string;

#define BOARD_SIZE 13
#define MAX_SEQ_SIZE 30

// struct Map {
    // char map[BOARD_SIZE][BOARD_SIZE][20];
    // Item items[BOARD_SIZE][BOARD_SIZE];
    // void print_color(int type, char c);
//     void print_red(char* c) {
//         char buf[20];
//         sprintf(buf, "\033[31m%s\033[0m", c);
//         strcpy(c, buf);
//         // return string(buf);
//     };
//     void print_blue(char* c) {
//         char buf[20];
//         sprintf(buf, "\033[34m%s\033[0m", c);
//         strcpy(c, buf);
//         // return string(buf);
//     }
//     void print_yellow(char* c) {
//         char buf[20];
//         sprintf(buf, "\033[33m%s\033[0m", c);
//         strcpy(c, buf);
//         // return string(c);
//     }
// public:
//     void import(string file_name);
//     void draw();
// };

void import(char* file_name, char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE]);
void draw(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE]);
void print_red(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c);
void print_blue(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c);
void print_yellow(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c);

#endif