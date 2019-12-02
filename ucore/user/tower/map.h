#ifndef MAP_H
#define MAP_H
#include <fstream>
#include <stdio.h>
#include <map>
#include <set>
#include "item.h"
using std::map;
using std::set;
using std::ifstream;
using std::string;

#define BOARD_SIZE 13

class Map {
    string map[BOARD_SIZE][BOARD_SIZE];
    // Item items[BOARD_SIZE][BOARD_SIZE];
    void print_color(int type, char c);
    string print_red(string c) {
        char buf[20];
        sprintf(buf, "\033[31m%s\033[0m", c.c_str());
        return string(buf);
    };
    string print_blue(string c) {
        char buf[20];
        sprintf(buf, "\033[34m%s\033[0m", c.c_str());
        return string(buf);
    }
    string print_yellow(string c) {
        char buf[20];
        sprintf(buf, "\033[33m%s\033[0m", c.c_str());
        return string(buf);
    }
public:
    void import(string file_name);
    void draw();
};

#endif