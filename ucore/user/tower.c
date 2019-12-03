#include <ulib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
// #include "item.h"
// #include "map.h"

#define printf(...)         fprintf(1, __VA_ARGS__)
#define BOARD_SIZE          13
#define MAX_SEQ_SIZE        30

#define WALL                '#'
#define BLUE_BOTTLE         'l'
#define RED_BOTTLE          'h'
#define RED_GATE            'r'
#define BLUE_GATE           'b'
#define YELLOW_GATE         'y'
#define YELLOW_KEY          'k'
#define BLUE_KEY            'e'
#define RED_KEY             'd'
#define BLUE_GEM            'o'
#define RED_GEM             'p'
#define SLIME               'm'
#define BAT                 'f'
#define SKELETON            'g'
#define SKELETON_GENERAL    'j'
#define WIZARD              's'
#define ROAD                ' '
#define UP_STAIR            't'
#define DOWN_STAIR          'w'

typedef struct Hero {
    int x;
    int y;
    int hp;
    int attack;
    int defence;
    int money;
    int red_key_num;
    int blue_key_num;
    int yellow_key_num;
}Hero;

char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE];
char raw_map[BOARD_SIZE][BOARD_SIZE];
Hero hero = {6, 11, 400, 15, 10, 0, 0, 0, 0};
int layer = 1;

void import(char* file_name) {
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
            raw_map[i][0] = WALL;
            raw_map[0][i] = WALL;
            raw_map[BOARD_SIZE-1][i] = WALL;
            raw_map[i][BOARD_SIZE-1] = WALL;
        }
        int y = 0;
        while ((ret = read(file, buffer, sizeof(buffer))) != 0) {
        // while((ret = fread(buffer, sizeof(char), BOARD_SIZE-1, file)) != 0) {
            for (int x = 0; x < BOARD_SIZE - 2; ++x) {  
                raw_map[y + 1][x + 1] = buffer[x];
                if (WALL == buffer[x]) {                                  // 墙壁
                    strcpy(map[y + 1][x + 1], "██");
                } else if (BLUE_BOTTLE == buffer[x]) {                    // 蓝血瓶
                    print_blue(map, x + 1, y + 1, "血");
                } else if (RED_BOTTLE == buffer[x]) {                     // 红血瓶
                    print_red(map, x + 1, y + 1, "血");
                } else if (RED_GATE == buffer[x]) {                       // 红门
                    print_red(map, x + 1, y + 1, "〓");
                } else if (BLUE_GATE == buffer[x]) {                      // 蓝门
                    print_blue(map, x + 1, y + 1, "〓");
                } else if (YELLOW_GATE == buffer[x]) {                    // 黄门
                    print_yellow(map, x + 1, y + 1, "〓");
                } else if (YELLOW_KEY == buffer[x]) {                     // 黄钥匙
                    print_yellow(map, x + 1, y + 1, "♀ ");
                } else if (BLUE_KEY == buffer[x]) {                       // 蓝钥匙
                    print_blue(map, x + 1, y + 1, "♀ ");
                } else if (RED_KEY == buffer[x]) {                        // 红钥匙
                    print_red(map, x + 1, y + 1, "♀ ");
                } else if (BLUE_GEM == buffer[x]) {                       // 蓝宝石
                    print_blue(map, x + 1, y + 1, "◆ ");
                } else if (RED_GEM == buffer[x]) {                        // 红宝石
                    print_red(map, x + 1, y + 1, "◆ ");
                } else if (SLIME == buffer[x]) {                          // 史莱姆
                    strcpy(map[y + 1][x + 1], "史");
                } else if (BAT == buffer[x]) {                            // 蝙蝠
                    strcpy(map[y + 1][x + 1], "蝠");
                } else if (SKELETON == buffer[x]) {                       // 骷髅
                    strcpy(map[y + 1][x + 1], "骷");
                } else if (SKELETON_GENERAL == buffer[x]) {               // 骷髅将军
                    strcpy(map[y + 1][x + 1], "军");
                } else if (WIZARD == buffer[x]) {                         // 法师
                    strcpy(map[y + 1][x + 1], "法");
                } else if (ROAD == buffer[x]) {                           // 道路
                    strcpy(map[y + 1][x + 1], "  ");
                } else if (UP_STAIR == buffer[x]) {                       // 上楼梯
                    strcpy(map[y + 1][x + 1], "↑ ");
                } else if (DOWN_STAIR == buffer[x]) {                     // 下楼梯
                    strcpy(map[y + 1][x + 1], "↓ ");
                }
            }
            ++y;
        }    
    }
}
void draw(){
    printf("%c[%d;%dH",27,1,1);
    printf("HP:%d\t攻击力:%d\t防御力:%d\n金钱:%d\t层数:%d\n黄钥匙:%d\t蓝钥匙:%d\t红钥匙:%d\n\n", 
            hero.hp, hero.attack, hero.defence, hero.money, layer, hero.yellow_key_num,
            hero.blue_key_num, hero.red_key_num);
    for (int y = 0; y < BOARD_SIZE; ++y) {
        for (int x = 0; x < BOARD_SIZE; ++x) {
            printf("%s", map[y][x]);
        }
        printf("\n");
    }
}

void print_red(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[31m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[31m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[y][x], buf);
}

void print_blue(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[34m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[34m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[y][x], buf);
}

void print_yellow(char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE], int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[33m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[33m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[y][x], buf);
} 

bool get_user_input(int *x_direction, int *y_direction) {
    char c;
    int ret;
    bool flag = 0;
    if ((ret = read(0, &c, sizeof(char))) < 0) {
        return flag;
    }
    switch (c)
    {
    case 'w':
        if (*y_direction != 1) {
            flag = 1;
            *y_direction = -1;
            *x_direction = 0;
        }
        break;
    case 's':
        if (*y_direction != -1) {
            flag = 1;
            *y_direction = 1;
            *x_direction = 0;
        }
        break;
    case 'a':
        if (*x_direction != 1) {
            flag = 1;
            *x_direction = -1;
            *y_direction = 0;
        }
        break;
    case 'd':
        if (*x_direction != -1) {
            flag = 1;
            *x_direction = 1;
            *y_direction = 0;
        }
        break;
    default:
        break;
    }
    return flag;
}

int main() {
    printf("\e[1;1H\e[2J");
    import("map_1.txt");
    draw();
    
    return 0;
}