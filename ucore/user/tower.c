#include <ulib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
// #include "item.h"
// #include "map.h"

#define printf(...)         fprintf(1, __VA_ARGS__)
#define false               0
#define true                1

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
    int x_direction;
    int y_direction;
    int hp;
    int attack;
    int defence;
    int money;
    int red_key_num;
    int blue_key_num;
    int yellow_key_num;
}Hero;

typedef struct Monster {
    int x;
    int y;
    int type;
    int hp;
    int attack;
    int defence;
}Monster;

char map[BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE];
char raw_map[BOARD_SIZE][BOARD_SIZE];
int up_x[3] = {6, 1, 2};
int up_y[3] = {11, 2, 11};
int down_x[3] = {2, 1, 10};
int down_y[3] = {1, 10, 11};
Hero hero = {6, 11, 0, 0, 400, 15, 10, 0, 0, 0, 0};
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
                    print_blue(x + 1, y + 1, "血");
                } else if (RED_BOTTLE == buffer[x]) {                     // 红血瓶
                    print_red(x + 1, y + 1, "血");
                } else if (RED_GATE == buffer[x]) {                       // 红门
                    print_red(x + 1, y + 1, "〓");
                } else if (BLUE_GATE == buffer[x]) {                      // 蓝门
                    print_blue(x + 1, y + 1, "〓");
                } else if (YELLOW_GATE == buffer[x]) {                    // 黄门
                    print_yellow(x + 1, y + 1, "〓");
                } else if (YELLOW_KEY == buffer[x]) {                     // 黄钥匙
                    print_yellow(x + 1, y + 1, "♀ ");
                } else if (BLUE_KEY == buffer[x]) {                       // 蓝钥匙
                    print_blue(x + 1, y + 1, "♀ ");
                } else if (RED_KEY == buffer[x]) {                        // 红钥匙
                    print_red(x + 1, y + 1, "♀ ");
                } else if (BLUE_GEM == buffer[x]) {                       // 蓝宝石
                    print_blue(x + 1, y + 1, "◆ ");
                } else if (RED_GEM == buffer[x]) {                        // 红宝石
                    print_red(x + 1, y + 1, "◆ ");
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
    printf("HP:%d    攻击力:%d    防御力:%d    金钱:%d    层数:%d\n黄钥匙:%d    蓝钥匙:%d    红钥匙:%d\n\n", 
            hero.hp, hero.attack, hero.defence, hero.money, layer, hero.yellow_key_num,
            hero.blue_key_num, hero.red_key_num);
    for (int y = 0; y < BOARD_SIZE; ++y) {
        for (int x = 0; x < BOARD_SIZE; ++x) {
            printf("%s", map[y][x]);
        }
        printf("\n");
    }
}

void print_red(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[31m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[31m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[y][x], buf);
}

void print_blue(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[34m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[34m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[y][x], buf);
}

void print_yellow(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[33m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[33m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[y][x], buf);
} 

void print_green(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[36m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[36m", c, buf);
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
        flag = 1;
        *y_direction = -1;
        *x_direction = 0;
        break;
    case 's':
        flag = 1;
        *y_direction = 1;
        *x_direction = 0;
        break;
    case 'a':
        flag = 1;
        *x_direction = -1;
        *y_direction = 0;
        break;
    case 'd':
        flag = 1;
        *x_direction = 1;
        *y_direction = 0;
        break;
    default:
        break;
    }
    return flag;
}

// 可以战斗，且战斗完毕返回true;无法战斗返回false
bool battle(char m) {
    Monster monster;
    monster.type = m;
    switch (m)
    {
    case SLIME:
        monster.hp = 50;
        monster.attack = 50;
        monster.defence = 1;
        break;
    case SKELETON:
        monster.hp = 110;
        monster.attack = 25;
        monster.defence = 5;
        break;
    case SKELETON_GENERAL:
        monster.hp = 150;
        monster.attack = 50;
        monster.defence = 20;
        break;
    case BAT:
        monster.hp = 100;
        monster.attack = 20;
        monster.defence = 5;
        break;
    case WIZARD:
        monster.hp = 450;
        monster.attack = 150;
        monster.defence = 90;
        break;
    default:
        break;
    }
    if (hero.attack <= monster.defence)     // 如果英雄的攻击没办法破防，就没办法打
        return false;
    if (hero.defence >= monster.attack)     // 如果怪物的攻击没办法破放，无伤通过
        return true;
    int round_hero = hero.hp / (monster.attack - hero.defence);     // 英雄死亡所需回合
    int round_monster = monster.hp / (hero.attack - monster.defence);    // 怪物死亡所需回合
    if (round_hero <= round_monster)      // 如果英雄先死，不能打
        return false;
    hero.hp -= round_monster * (monster.attack - hero.defence);
    return true;
}

// 如果钥匙足够，则返回true并打开门，如果钥匙不够，返回false
bool open_door(char door) {
    bool flag = false;
    if (door == RED_GATE && hero.red_key_num > 0) {
        hero.red_key_num--;
        flag = true;
    }
    else if (door == BLUE_GATE && hero.blue_key_num > 0) { 
        hero.blue_key_num--;
        flag = true;
    }
    else if (door == YELLOW_GATE && hero.yellow_key_num > 0) {
        hero.yellow_key_num--;
        flag = true;
    }
    return flag;
}

void add_key_num(char key) {
    if (key == RED_KEY)
        hero.red_key_num++;
    else if (key == BLUE_KEY)
        hero.blue_key_num++;
    else if (key == YELLOW_KEY) 
        hero.yellow_key_num++;
}

bool update_hp(int delta) {
    if (hero.hp < -delta)
        return false;
    hero.hp += delta;
    return true;
}

void update_attack(int delta) {
    hero.attack += delta;
}

void update_defence(int delta) {
    hero.defence += delta;
}

void update_layer(int delta) {
    layer += delta;
    char file_name[15];
    char tmp[2];
    tmp[0] = '0' + layer;
    tmp[1] = '\0';
    strcat("map_", tmp, file_name);
    strcat(file_name, ".txt", file_name);
    import(file_name);
    if (delta > 0) {
        hero.x = up_x[layer - 1];
        hero.y = up_y[layer - 1];
    } else {
        hero.x = down_x[layer - 1];
        hero.y = down_y[layer - 1];
    }
    print_green(hero.x, hero.y, "勇");
}


// 战斗就返回true，否则false
bool move() {
    int x = hero.x;
    int y = hero.y;
    int x_result = x + hero.x_direction;
    int y_result = y + hero.y_direction;
    bool can_move = true;
    bool update = false;
    bool ret = false;
    bool new_layer = false;
    switch (raw_map[y_result][x_result])
    {
    case SLIME:
    case SKELETON:
    case SKELETON_GENERAL:
    case WIZARD:
    case BAT:
        if (!battle(raw_map[y_result][x_result])) {
            printf("\n与其战斗将会死亡           \n");
            printf("%c[%d;%dH",27,18,1);
            can_move = false;
        } else {
            ret = true;
            update = true;
        }
        break;
    case RED_GATE:
    case BLUE_GATE:
    case YELLOW_GATE:
        if (!open_door(raw_map[y_result][x_result])){
            printf("\n钥匙数量不足              \n");
            printf("%c[%d;%dH",27,18,1);
            can_move = false;
        } else {
            update = true;
        }
        break;
    case YELLOW_KEY:
    case BLUE_KEY:
    case RED_KEY:
        add_key_num(raw_map[y_result][x_result]);
        raw_map[y_result][x_result] = ROAD;
        strcpy(map[y_result][x_result], "  ");
        update = true;
        break;
    case RED_BOTTLE:
        update_hp(50);
        update = true;
        break;
    case BLUE_BOTTLE:
        update_hp(100);
        update = true;
        break;
    case RED_GEM:
        update_attack(5);
        update = true;
        break;
    case BLUE_GEM:
        update_defence(5);
        update = true;
        break;
    case UP_STAIR:
        update_layer(1);
        new_layer = true;
        break;
    case DOWN_STAIR:
        update_layer(-1);
        new_layer = true;
        break;
    case WALL:
        can_move = false;
        break;
    default:
        break;
    }
    if (update) {
        strcpy(map[y_result][x_result], "  ");
        raw_map[y_result][x_result] = ROAD;
        if (ret) {
            char buf[10];
            strcpy(buf, map[y_result][x_result]);
            print_yellow(x_result, y_result, "✦ ");
            draw();
            sleep(150);
            strcpy(map[y_result][x_result], buf);
            draw();
            sleep(150);
            print_yellow(x_result, y_result, "✦ ");
            draw();
            sleep(150);
            print_green(x_result, y_result, "勇");
        }
    }
    if (can_move && !new_layer) {
        hero.x = x_result;
        hero.y = y_result;
        strcpy(map[y][x], "  ");
        if (!ret && !new_layer)
            print_green(x_result, y_result, "勇");
        printf("\n                                \n"); 
    }
    return ret;
}

int main() {
    printf("\e[1;1H\e[2J");
    import("map_1.txt");
    print_green(hero.x, hero.y, "勇");
    draw();
    while(1) {
        if (!get_user_input(&hero.x_direction, &hero.y_direction)) {
            continue;
        }
        printf("X:%d, Y:%d\n", hero.x, hero.y);
        move();
        draw();
    }
    return 0;
}