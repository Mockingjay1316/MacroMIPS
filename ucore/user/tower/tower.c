#include <ulib.h>
#include <string.h>
#include <stdio.h>
// #include "item.h"
// #include "map.h"

#define printf(...)         fprintf(1, __VA_ARGS__)
#define BOARD_SIZE 13
#define MAX_SEQ_SIZE 30

char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE];

void import(char* file_name, char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE]) {
    // FILE* file = fopen(file_name, "r");
    int file = open(file_name, O_RDONLY);
    char buffer[BOARD_SIZE - 1];
    if (file >= 0) {
        int ret;
        for (int i = 0; i < BOARD_SIZE; ++i) {
            strcpy(map[i][0], "██");
            strcpy(map[0][i], "██");
            strcpy(map[BOARD_SIZE-1][i], "██");
            strcpy(map[i][BOARD_SIZE-1], "██");
        }
        int y = 0;
        while ((ret = read(file, buffer, sizeof(buffer))) != 0) {
        // while((ret = fread(buffer, sizeof(char), BOARD_SIZE-1, file)) != 0) {
            for (int x = 0; x < BOARD_SIZE - 2; ++x) {  
                if ('#' == buffer[x]) {                                  // 墙壁
                    strcpy(map[y + 1][x + 1], "██");
                } else if ('l' == buffer[x]) {                           // 蓝血瓶
                    print_blue(map, x + 1, y + 1, "血");
                } else if ('h' == buffer[x]) {                           // 红血瓶
                    print_red(map, x + 1, y + 1, "血");
                } else if ('r' == buffer[x]) {                           // 红门
                    print_red(map, x + 1, y + 1, "〓");
                } else if ('b' == buffer[x]) {                           // 蓝门
                    print_blue(map, x + 1, y + 1, "〓");
                } else if ('y' == buffer[x]) {                           // 黄门
                    print_yellow(map, x + 1, y + 1, "〓");
                } else if ('k' == buffer[x]) {                           // 黄钥匙
                    print_yellow(map, x + 1, y + 1, "♀ ");
                } else if ('e' == buffer[x]) {                           // 蓝钥匙
                    print_blue(map, x + 1, y + 1, "♀ ");
                } else if ('d' == buffer[x]) {                           // 红钥匙
                    print_red(map, x + 1, y + 1, "♀ ");
                } else if ('o' == buffer[x]) {                           // 蓝宝石
                    print_blue(map, x + 1, y + 1, "◆ ");
                } else if ('p' == buffer[x]) {                           // 红宝石
                    print_red(map, x + 1, y + 1, "◆ ");
                } else if ('m' == buffer[x]) {                           // 史莱姆
                    strcpy(map[y + 1][x + 1], "史");
                } else if ('f' == buffer[x]) {                           // 蝙蝠
                    strcpy(map[y + 1][x + 1], "蝠");
                } else if ('g' == buffer[x]) {                           // 骷髅
                    strcpy(map[y + 1][x + 1], "骷");
                } else if ('j' == buffer[x]) {                           // 骷髅将军
                    strcpy(map[y + 1][x + 1], "军");
                } else if ('s' == buffer[x]) {                           // 法师
                    strcpy(map[y + 1][x + 1], "法");
                } else if (' ' == buffer[x]) {                           // 道路
                    strcpy(map[y + 1][x + 1], "  ");
                } else if ('t' == buffer[x]) {                           // 上楼梯
                    strcpy(map[y + 1][x + 1], "↑ ");
                } else if ('w' == buffer[x]) {                           // 下楼梯
                    strcpy(map[y + 1][x + 1], "↓ ");
                }
            }
            ++y;
        }    
    }
}
void draw(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE]){
    printf("%c[%d;%dH",27,1,1);
    for (int y = 0; y < BOARD_SIZE; ++y) {
        for (int x = 0; x < BOARD_SIZE; ++x) {
            printf("%s", map[y][x]);
        }
        printf("\n");
    }
}

void print_red(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c) {
    char buf[20];
    sprintf(buf, "\033[31m%s\033[0m", c);
    strcpy(map[y][x], buf);
}

void print_blue(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c) {
    char buf[20];
    sprintf(buf, "\033[34m%s\033[0m", c);
    strcpy(map[y][x], buf);
}

void print_yellow(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c) {
    char buf[20];
    sprintf(buf, "\033[33m%s\033[0m", c);
    strcpy(map[y][x], buf);
} 

int main() {
    printf("\e[1;1H\e[2J");
    import("maps/map_1.txt", map);
    draw(map);
    // getchar();
    return 0;
}