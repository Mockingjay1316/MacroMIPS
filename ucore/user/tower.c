#include <ulib.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
// #include "item.h"
// #include "map.h"

#define printf(...)         fprintf(1, __VA_ARGS__)
#define false               0
#define true                1

// 尺寸
#define BOARD_SIZE          13
#define MAX_SEQ_SIZE        14

// 地图
#define WALL                '#'
#define FAKE_WALL           '@'
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
#define DEVIL               'z'
#define ROAD                ' '
#define UP_STAIR            't'
#define DOWN_STAIR          'w'
#define SHOP                'i'
#define OLD_MAN             'q'
#define SHOP_MAN            'u'
#define SWORD               'a'
#define SHIELD              'c'
#define UPDOWN              'x'
#define BAR                 'n'
#define SPECIAL_GATE        'v'
#define HERO                '*'
#define GUARD               '$'
#define THIEF               '%'

#define PIC_BAR             0
#define PIC_BAT             1
#define PIC_BLUE_BOTTLE     2
#define PIC_BLUE_GATE       3
#define PIC_BLUE_GEM        4
#define PIC_BLUE_KEY        5
#define PIC_DEVIL           6
#define PIC_DOWN_STAIR      7
#define PIC_GENERAL         8
#define PIC_GUARD           9
#define PIC_HERO            10
#define PIC_OLDMAN          11
#define PIC_RED_BOTTLE      12
#define PIC_RED_GATE        13
#define PIC_RED_GEM         14
#define PIC_RED_KEY         15
#define PIC_ROAD            16
#define PIC_SHIELD          17
#define PIC_SHOPMAN         18
#define PIC_SHOP_LEFT       19
#define PIC_SHOP_MID        20
#define PIC_SHOP_RIGHT      21
#define PIC_SKELETON        22
#define PIC_SLIME           23
#define PIC_SPECIAL_DOOR    24
#define PIC_SWORD           25
#define PIC_THIEF           26
#define PIC_UPDOWN          27
#define PIC_UP_STAIR        28
#define PIC_WALL            29
#define PIC_WIZARD          30
#define PIC_YELLOW_GATE     31
#define PIC_YELLOW_KEY      32

// 道具
#define UP_LAYER            0       // 快速上楼
#define DOWN_LAYER          1       // 快速下楼
#define MANUAL              2       // 怪物手册

// 怪物编号
#define MONSTER_SLIME               0
#define MONSTER_BAT                 1
#define MONSTER_SKELETON            2
#define MONSTER_SKELETON_GENERAL    3
#define MONSTER_WIZARD              4

char maps[9][121] = {
    "t mmm      ########## h  y #pk #  g # #oh # #y## ###y# k  # yfsf#  j # ##### #y##          ##y###y#h k#k  # f hxk#   #mlm", 
    "w b          ##     ## ##### #### #kk#   # q #k n   n   ####   ### @  #   # u #  n   n   ####   ### #ll#   #  t#l n   n  ",
    "ko#klk# # h h#lkl# yf s #kek# ###y### ## # q  f   m    y##   # ##@g ## ## # h k#   # yskhp#   # ####### ##m#  w     # y t",
    " e #i  # q h k#   #k l   #   # j #y###b###y# s y m  g     ########m m        y##y###y##y # f # s #  #m k#p h# t#kmk# m #w",
    "t# my #  y  #  #k#mm#m ym # #kk# ###y#f#kk# k s # #### k  f# m    #j### ####m    #m#    okh # #y######## # #  w     # @ a",
    "w#kk# s km  #kk# ####y ##m# #h g  yy y #u  f #### #####  ms k gj  ##### #### s  q# yy y  f o# ##m#my#### #  #  m  g #hh#t",
    "t#p# u #k#m #h#   #k#m #f#m#j#h#m # # # # # y#y#b#y#g#y j s       y#y#y#y#j#y # # # # #  # #f#m#l# m#m#k#f#k#  m #k#l#k#w",
    "w yy t #k k  ##  m# d y####y##l h #kkk  ##r#h#####s#    mmm # #   ####y#f##y#   f g s   y#########ym #pk#eh# g fbko#k yj ",
    "  gy w ym h k #   # m j####b####  k #k kyy  o fy p ##@#######m#  jk yjk# #c# j #  # ###yy###y# #k s h# g#f# g   b  y ys h"
};
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
    bool has_sword;
    bool has_shield;
}Hero;

typedef struct Monster {
    int x;
    int y;
    char name[15];
    int hp;
    int attack;
    int defence;
    int money;
}Monster;

char map[9][BOARD_SIZE][BOARD_SIZE][MAX_SEQ_SIZE];
char raw_map[9][BOARD_SIZE][BOARD_SIZE];
bool has_prop[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
bool map_has_load[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};
bool layer_visited[9] = {1, 0, 0, 0, 0, 0, 0, 0, 0};
Monster monsters[5];
int up_x[10] = {6, 1, 2, 11, 2, 1, 11, 1, 6, 1};
int up_y[10] = {11, 2, 11, 10, 11, 2, 10, 2, 2, 10};
int down_x[10] = {2, 1, 10, 1, 1, 11, 1, 6, 1};
int down_y[10] = {1, 10, 11, 10, 2, 10, 2, 2, 10};
Hero hero = {6, 11, 0, 0, 1000, 100, 100, 4, 0, 0, 0, 1, 1};
// Hero hero = {6, 11, 0, 0, 40000, 1500, 1000, 10000, 100, 100, 100, 0, 0};
int layer = 1;
int shop_cost = 20;
bool meet = true;   // 是否要遇到大魔王
int *ucore_status;
int *vga_output;

void move_print(int line) {
    printf("%c[%d;%dH",27,line,1);
}

void screen_clear() {
    printf("\e[1;1H\e[2J");
}

void init_game() {
    int pid = fork();
    if (pid == 0) {
        printf("````````````````````````````````````````````````````````````````````````````\n\
`````````````````````jjjjjjjjjj``a~`````````````````````````````````````````\n\
`````````````````````@@@@@~@@@@``a~`````````````````````````````````````````\n\
`````````````````````````E#``````a~`````````````````````````````````````````\n\
`````````````````````````E#``````a~``,;,```````,;;``````````````````````````\n\
`````````````````````````E#``````a~`g~~~1`````a@~~a,````````````````````````\n\
`````````````````````````E#``````a~g*??@@,```g#?'^#g````````````````````````\n\
`````````````````````````E#``````a~!```?~i``y~\"```~g_```````````````````````\n\
`````````````````````````E#``````a~````\"~[``##`````gL```````````````````````\n\
`````````````````````````E#``````a~````v~[``EggggggEL```````````````````````\n\
`````````````````````````E#``````a~````v~[``~R777777^```````````````````````\n\
`````````````````````````E#``````a~````v~[``#&``````````````````````````````\n\
`````````````````````````E#``````a~````v~[``T~_`````````````````````````````\n\
`````````````````````````E#``````a~````v~[``~@#/``,z````````````````````````\n\
`````````````````````````E#``````a~````v~[```^#~gg~#````````````````````````\n\
`````````````````````````''``````''````~''````~^7!^`````````````````````````\n\
````````````````````````````````````````````````````````````````````````````\n\
```$@***#~***M~L````````````````````````````````````````````````````````````\n\
```R@```T~```v~p```````,,,```````````````````````````,,,````````````````;;,`\n\
```#@```T~```v~p`````yg~~~gu````gggga`````ggggz````wg~~~gu``````gggg``wg~~#_\n\
```##```T~```v~4````gM#*7H@~g,`~#~@$F````~QQ~@k```gg#*7*@~a````~QQ#~`d~@Q~~[\n\
```##```T~```v~*```g~F````~Q~&``~~#````,````~[```g~P````~Q~L``````T~d@[```7`\n\
```''```T~````'```j~#``````~#~,``$~(``a#_``j~'``_~#``````~@@``````T~#(``````\n\
````````T~````````g~[```````T~[``?~i``#~*``g#```a~yjjjjjjjE~(`````T~\"```````\n\
````````T~````````#~(```````?~4``~~&``~Z#``EP```$~~g~~~~~~~~.`````T~````````\n\
````````T~````````$~(```````j~L```$E`j#\"~,_~!```$~['''''''''``````T~````````\n\
````````T~````````T~p```````d~!```?~_g*~~+T@````T~p```````````````T~````````\n\
````````T~````````\"~@;`````j~#````v~pE!`$&#F````\"~#,``````_w,`````T~````````\n\
`````_jjd~ujj,`````Tg#u,,,w@~!`````$~~``T~~I`````T~#j,,,_g~~'```jjd~jjjj_```\n\
`````$~~~~~M~p``````7@~~~~~#!``````T~#``\"~~``````~Xg~~~~~~F^```$~~~~~~~~@```\n\
````````````````````````````````````````````````````````````````````````````\n");
        while(1) {
            // screen_clear();
            move_print(31);
            printf("\
$F**#y````````````````````````````j[```````````````````g```````````````j[```\n\
$[``~~(```;;``,;,````;;```,;,`````T[````,;,```````;;,``E`````;;``````;`T[```\n\
$[```#.`@j#*`w#H#_`v#*#1`j#*#+```T@@E(`w#Q@l`````dFQ#`#~E@`y@M#k``$\\@QT@@E(`\n\
$[``_@``@P```#```&`a[`~``#(`~`````a[```#```@,```v@`````g```~``\"E``$#```a[```\n\
$ggg#!``@```aL;;;E`Xgj,``T&j``````a[``aL```$[```~@y;```g`````_jE``$[```a[```\n\
$[''````@```$F****``^Q#_`~?Qg/````a[``$[```Tp````'7@y``g```j#7~@``$[```a[```\n\
$[``````@```Tp````````?#````T4````T[``T4```g!``````~#x`g```@```@``$[```T[```\n\
$[``````@```~#u,__`s/,jF`y;,y*````T&,,~@u,j#````vu,,#'`@i,v@/,w~``$[```T&,,`\n\
*+``````*````^Q#F^`^Q@*~~?Q#*`````~Q$+`^Q@*'````'7#$7``?#$`7#F^*``*+```~Q$+`\n");
            sleep(1000);
            // screen_clear();
            move_print(31);
            printf("\
``@**Q@i````````````````````````````g````````````````````$```````````````g``\n\
`_#```T4````;```;;````;;````;;``````#`````;;```````,;,``j*````;;,`````;,`#``\n\
`j*```a[`a[@Q`jg*#l``g*Q4``g*Qp```j#~E*`jgM@y`````w#H#'g@EE`vgM#g``j[g$U#~E*\n\
`a[``_#'`@P``_#``\"#`a[````g!`~`````TL``v#'`~~,````@``'``@``````v~``a#```TL``\n\
`#ggg#(``@```g[;;;#`Tg/```9b/``````#!``g!```E(```v@u,```@````,jw@``#!```#!``\n\
`@'''```\"#```~****7`~7#a``~7#a`````@```~````@'````^Q#l`\"F```a*!?#``@````@```\n\
_#``````T*``v~````````~E(```~@`````@``v~```j#```````7#`T*``a[``T*`_#````@```\n\
j*``````a[```#[,,l`wj,_#`a/,v#````\"#,,`#L,j#\"````y,,y[`TL,`$i,j#[`j*```\"#,,`\n\
X!``````*'````Q#F^`^Q@*~`?Q#*'````~Q$[``Q#*~````~7#$7``^#$`?#F[*'`X!```~Q$[`\n");
            sleep(1000);
        }
    } else {
        get_user_input();
        kill(pid);
        // screen_clear();
        // move_print(100);
        // printf("这是一个很古老的故事\n\n");
        // sleep(3000);
        // printf("在很久很久以前，在遥远的西方大地上，有着这样一个王国，王国虽小但全国的人们都生活得幸福快乐。\n\n");
        // sleep(3000);
        // printf("突然有一天，从天空飞来了一群可怕的怪物，它们来到王宫，抢走了国王唯一的女儿。\n\n");
        // sleep(3000);
        // printf("第二天，国王便向全国下达了紧急令，只要谁能将公主给找回来，他便将王位让给他。\n\n");
        // sleep(3000);
        // printf("于是，全国的勇士们都出发了，他们的足迹遍布了全国的各个角落，可一点儿线索也没有找到，时间很快就过去了一个月。\n\n");
        // sleep(3000);
        // printf("终于，在国王下达命令的第三十一天，一个从远方归来的人告诉国王，说在海边的一座小岛上，曾看到一群怪物出现过。\n\n");
        // sleep(3000);
        // printf("勇士们又出发了，可是，却几乎没有一个人可以回来，有幸回来的，都再也不敢去了。\n\n");
        // sleep(3000);
        // printf("而我们的故事，便是从这里开始。\n\n");
        // sleep(3000);
        // printf("任意键继续......\n");
        // get_user_input();
    }
}

void init_monsters() {
    monsters[MONSTER_SLIME].hp = 35;
    monsters[MONSTER_SLIME].attack = 18;
    monsters[MONSTER_SLIME].defence = 1;
    monsters[MONSTER_SLIME].money = 2;
    strcpy(monsters[MONSTER_SLIME].name, "史莱姆");

    monsters[MONSTER_BAT].hp = 35;
    monsters[MONSTER_BAT].attack = 38;
    monsters[MONSTER_BAT].defence = 3;
    monsters[MONSTER_BAT].money = 3;
    strcpy(monsters[MONSTER_BAT].name, "小蝙蝠");

    monsters[MONSTER_SKELETON].hp = 50;
    monsters[MONSTER_SKELETON].attack = 42;
    monsters[MONSTER_SKELETON].defence = 6;
    monsters[MONSTER_SKELETON].money = 6;
    strcpy(monsters[MONSTER_SKELETON].name, "骷髅人");

    monsters[MONSTER_SKELETON_GENERAL].hp = 55;
    monsters[MONSTER_SKELETON_GENERAL].attack = 52;
    monsters[MONSTER_SKELETON_GENERAL].defence = 12;
    monsters[MONSTER_SKELETON_GENERAL].money = 8;
    strcpy(monsters[MONSTER_SKELETON_GENERAL].name, "骷髅战士");

    monsters[MONSTER_WIZARD].hp = 60;
    monsters[MONSTER_WIZARD].attack = 32;
    monsters[MONSTER_WIZARD].defence = 8;
    monsters[MONSTER_WIZARD].money = 5;
    strcpy(monsters[MONSTER_WIZARD].name, "初级法师");
}

void print_conversation(char* words) {
    screen_clear();
    move_print(11);
    printf("%s", words);
}

void import() {
    // FILE* file = fopen(file_name, "r");
    // int file = open(file_name, O_RDONLY);
    // char buffer[BOARD_SIZE - 1];
    // if (file >= 0) {
    int ret;
    for (int i = 0; i < BOARD_SIZE; ++i) {
        strcpy(map[layer-1][i][0], "██");
        strcpy(map[layer-1][0][i], "██");
        strcpy(map[layer-1][BOARD_SIZE-1][i], "██");
        strcpy(map[layer-1][i][BOARD_SIZE-1], "██");
        raw_map[layer-1][i][0] = WALL;
        raw_map[layer-1][0][i] = WALL;
        raw_map[layer-1][BOARD_SIZE-1][i] = WALL;
        raw_map[layer-1][i][BOARD_SIZE-1] = WALL;
    }
    int y = 0;
    // while ((ret = read(file, buffer, sizeof(buffer))) != 0) {
    // while((ret = fread(buffer, sizeof(char), BOARD_SIZE-1, file)) != 0) {
        // printf("%d\n", y);
    int *output = vga_output;
    for (int y = 0; y < BOARD_SIZE - 2; ++y) 
        for (int x = 0; x < BOARD_SIZE - 2; ++x) {  
            char curr = maps[layer - 1][y * (BOARD_SIZE - 2) + x];
            raw_map[layer-1][y + 1][x + 1] = curr;
            if (WALL == curr || FAKE_WALL == curr) {        // 墙壁或假墙壁
                strcpy(map[layer-1][y + 1][x + 1], "██");
                // *(output++) = PIC_WALL;
            } else if (BLUE_BOTTLE == curr) {                    // 蓝血瓶
                print_blue(x + 1, y + 1, "血");
                // *(output++) = PIC_BLUE_BOTTLE
            } else if (RED_BOTTLE == curr) {                     // 红血瓶
                print_red(x + 1, y + 1, "血");
                // *(output++) = PIC_RED_BOTTLE;
            } else if (RED_GATE == curr) {                       // 红门
                print_red(x + 1, y + 1, "〓");
                // *(output++) = PIC_RED_GATE;
            } else if (BLUE_GATE == curr) {                      // 蓝门
                print_blue(x + 1, y + 1, "〓");
                // *(output++) = PIC_BLUE_GATE;
            } else if (YELLOW_GATE == curr) {                    // 黄门
                print_yellow(x + 1, y + 1, "〓");
                // *(output++) = PIC_YELLOW_GATE;
            } else if (SPECIAL_GATE == curr) {                   // 特殊门
                print_green(x + 1, y + 1, "〓");
                // *(output++) = PIC_SPECIAL_DOOR;
            } else if (YELLOW_KEY == curr) {                     // 黄钥匙
                print_yellow(x + 1, y + 1, "♀ ");
                // *(output++) = PIC_YELLOW_KEY;
            } else if (BLUE_KEY == curr) {                       // 蓝钥匙
                print_blue(x + 1, y + 1, "♀ ");
                // *(output++) = PIC_BLUE_KEY;
            } else if (RED_KEY == curr) {                        // 红钥匙
                print_red(x + 1, y + 1, "♀ ");
                // *(output++) = PIC_RED_KEY;
            } else if (BLUE_GEM == curr) {                       // 蓝宝石
                print_blue(x + 1, y + 1, "◆ ");
                // *(output++) = PIC_BLUE_GEM;
            } else if (RED_GEM == curr) {                        // 红宝石
                print_red(x + 1, y + 1, "◆ ");
                // *(output++) = PIC_RED_GEM;
            } else if (SLIME == curr) {                          // 史莱姆
                strcpy(map[layer-1][y + 1][x + 1], "史");
                // *(output++) = PIC_SLIME;
            } else if (BAT == curr) {                            // 蝙蝠
                strcpy(map[layer-1][y + 1][x + 1], "蝠");
                // *(output++) = PIC_BAT;
            } else if (SKELETON == curr) {                       // 骷髅
                strcpy(map[layer-1][y + 1][x + 1], "骷");
                // *(output++) = PIC_SKELETON;
            } else if (SKELETON_GENERAL == curr) {               // 骷髅将军
                strcpy(map[layer-1][y + 1][x + 1], "军");
                // *(output++) = PIC_GENERAL;
            } else if (WIZARD == curr) {                         // 法师
                strcpy(map[layer-1][y + 1][x + 1], "法");
                // *(output++) = PIC_WIZARD;
            } else if (ROAD == curr) {                           // 道路
                strcpy(map[layer-1][y + 1][x + 1], "  ");
                // *(output++) = PIC_ROAD;
            } else if (UP_STAIR == curr) {                       // 上楼梯
                strcpy(map[layer-1][y + 1][x + 1], "↑ ");
                // *(output++) = PIC_UP_STAIR;
            } else if (DOWN_STAIR == curr) {                     // 下楼梯
                strcpy(map[layer-1][y + 1][x + 1], "↓ ");
                // *(output++) = PIC_DOWN_STAIR;
            } else if (SHOP == curr) {
                print_green(x + 1, y + 1, "大");
                print_green(x + 2, y + 1, "商");
                print_green(x + 3, y + 1, "店");
                // *(output++) = PIC_SHOP_LEFT;
                // *(output++) = PIC_SHOP_MID;
                // *(output++) = PIC_SHOP_RIGHT;
                x += 2;
            } else if (SWORD == curr) {
                print_green(x + 1, y + 1, "⚔ ");
                // *(output++) = PIC_SWORD;
            } else if (SHIELD == curr) {
                print_green(x + 1, y + 1, "⍟ ");
                // *(output++) = PIC_SHIELD;
            } else if (OLD_MAN == curr) {
                print_green(x + 1, y + 1, "老");
                // *(output++) = PIC_OLDMAN;
            } else if (SHOP_MAN == curr) {
                print_green(x + 1, y + 1, "商");
                // *(output++) = PIC_SHOPMAN;
            } else if (UPDOWN == curr) {
                print_green(x + 1, y + 1, "⇅ ");
                // *(output++) = PIC_UPDOWN;
            } else if (BAR == curr) {
                strcpy(map[layer-1][y+1][x+1], "栅");
                // *(output++) = PIC_BAR;
            }
        }
    map_has_load[layer - 1] = true;
}

void print_prop() {
    printf("道具: ");
    if (has_prop[0])
        printf("1.上升一层\t");
    if (has_prop[1])
        printf("2.下降一层\t");
    if (has_prop[2])
        printf("3.怪物手册\t");
    printf("\n");
}

void update_vga() {
    int *output = vga_output;
    for (int y = 0; y < BOARD_SIZE; ++y) {
        for (int x = 0; x < BOARD_SIZE; ++x) {
            switch (raw_map[layer-1][y][x])
            {
            case WALL:
            case FAKE_WALL:
                *(output++) = PIC_WALL;
                break;
            case BLUE_BOTTLE:
                *(output++) = PIC_BLUE_BOTTLE;
                break;
            case RED_BOTTLE:
                *(output++) = PIC_RED_BOTTLE;
                break;
            case RED_GATE:
                *(output++) = PIC_RED_GATE;
                break;
            case BLUE_GATE:
                *(output++) = PIC_BLUE_GATE;
                break;
            case YELLOW_GATE:
                *(output++) = PIC_YELLOW_GATE;
                break;
            case YELLOW_KEY:
                *(output++) = PIC_YELLOW_KEY;
                break;
            case BLUE_KEY:
                *(output++) = PIC_BLUE_KEY;
                break;
            case RED_KEY:
                *(output++) = PIC_RED_KEY;
                break;
            case BLUE_GEM:
                *(output++) = PIC_BLUE_GEM;
                break;
            case RED_GEM:
                *(output++) = PIC_RED_GEM;
                break;
            case SLIME:
                *(output++) = PIC_SLIME;
                break;
            case BAT:
                *(output++) = PIC_BAT;
                break;
            case SKELETON:
                *(output++) = PIC_SKELETON;
                break;
            case SKELETON_GENERAL:
                *(output++) = PIC_GENERAL;
                break;
            case WIZARD:
                *(output++) = PIC_WIZARD;
                break;
            case DEVIL:
                *(output++) = PIC_DEVIL;
                break;
            case ROAD:
                *(output++) = PIC_ROAD;
                break;
            case UP_STAIR:
                *(output++) = PIC_UP_STAIR;
                break;
            case DOWN_STAIR:
                *(output++) = PIC_DOWN_STAIR;
                break;
            case SHOP:
                *(output++) = PIC_SHOP_LEFT;
                *(output++) = PIC_SHOP_MID;
                *(output++) = PIC_SHOP_RIGHT;
                break;
            case OLD_MAN:
                *(output++) = PIC_OLDMAN;
                break;
            case SHOP_MAN:
                *(output++) = PIC_SHOPMAN;
                break;
            case SWORD:
                *(output++) = PIC_SWORD;
                break;
            case SHIELD:
                *(output++) = PIC_SHIELD;
                break;
            case UPDOWN:
                *(output++) = PIC_UPDOWN;
                break;
            case BAR:
                *(output++) = PIC_BAR;
                break;
            case SPECIAL_GATE:
                *(output++) = PIC_SPECIAL_DOOR;
                break;
            case HERO:
                *(output++) = PIC_HERO;
                break;
            case GUARD:
                *(output++) = PIC_GUARD;
                break;
            case THIEF:
                *(output++) = PIC_THIEF;
                break;
            default:
                break;
            }
        }
    }
}

void draw(){
    screen_clear();
    move_print(1);
    printf("HP:%d    攻击力:%d    防御力:%d    金钱:%d    层数:%d\n黄钥匙:%d    蓝钥匙:%d    红钥匙:%d\n", 
            hero.hp, hero.attack, hero.defence, hero.money, layer, hero.yellow_key_num,
            hero.blue_key_num, hero.red_key_num);
    if (hero.has_sword)
        printf("武器: 剑    ");
    else
        printf("武器: 无    ");
    if (hero.has_shield)
        printf("防器: 盾\n");
    else
        printf("防器: 无\n");
    print_prop();
    printf("\n");
    for (int y = 0; y < BOARD_SIZE; ++y) {
        for (int x = 0; x < BOARD_SIZE; ++x) {
            printf("%s", map[layer-1][y][x]);
        }
        printf("\n");
    }
    update_vga();
}

void print_red(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[31m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[31m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[layer-1][y][x], buf);
}

void print_blue(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[34m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[34m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[layer-1][y][x], buf);
}

void print_yellow(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[33m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[33m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[layer-1][y][x], buf);
} 

void print_green(int x, int y, char* c) {
    char buf[20];
    // sprintf(buf, "\033[36m%s\033[0m", c);
    // strcpy(map[y][x], buf);
    strcat("\033[36m", c, buf);
    strcat(buf, "\033[0m", buf);
    strcpy(map[layer-1][y][x], buf);
} 


// 如果是wasd，返回0，否则返回字符unicode编码
int get_user_input() {
    char c;
    int ret;
    int flag = -1;
    if ((ret = read(0, &c, sizeof(char))) < 0) {
        return flag;
    }
    switch (c)
    {
        case 'w':
            flag = 0;
            hero.y_direction = -1;
            hero.x_direction = 0;
            break;
        case 's':
            flag = 0;
            hero.y_direction = 1;
            hero.x_direction = 0;
            break;
        case 'a':
            flag = 0;
            hero.x_direction = -1;
            hero.y_direction = 0;
            break;
        case 'd':
            flag = 0;
            hero.x_direction = 1;
            hero.y_direction = 0;
            break;
        default:
            flag = c;
            break;
    }
    return flag;
}

int compute_hp_loss(Monster monster) {
    if (hero.attack <= monster.defence)     // 如果英雄的攻击没办法破防，就没办法打
        return -1;
    if (hero.defence >= monster.attack) {     // 如果怪物的攻击没办法破放，无伤通过
        // update_money(monster.money);
        // return true;
        return 0;
    }
    // int round_hero = 0;
    // int round_monster = 0;
    int hero_hp = hero.hp;
    int monster_hp = monster.hp;
    while (1) {
        if (monster_hp > (hero.attack - monster.defence)) {
            // ++round_monster;
            monster_hp -= (hero.attack - monster.defence);
        } else {
            return hero.hp - hero_hp;
        }
        if (hero_hp > (monster.attack - hero.defence)) {
            // ++round_hero;
            hero_hp -= (monster.attack - hero.defence);
        } else {
            return -1;
        }
        // int round_hero = hero.hp / (monster.attack - hero.defence);     // 英雄死亡所需回合
        // int round_monster = monster.hp / (hero.attack - monster.defence);    // 怪物死亡所需回合
    }
    // if (round_hero <= round_monster)      // 如果英雄先死，不能打
    //     return -1;
    // return round_monster * (monster.attack - hero.defence);
}

// 可以战斗，且战斗完毕返回true;无法战斗返回false
bool battle(char m) {
    Monster monster;
    switch (m)
    {
    case SLIME:
        monster = monsters[MONSTER_SLIME];
        break;
    case SKELETON:
        monster = monsters[MONSTER_SKELETON];
        break;
    case SKELETON_GENERAL:
        monster = monsters[MONSTER_SKELETON_GENERAL];
        break;
    case BAT:
        monster = monsters[MONSTER_BAT];
        break;
    case WIZARD:
        monster = monsters[MONSTER_WIZARD];
        break;
    default:
        break;
    }
    if (hero.attack <= monster.defence)     // 如果英雄的攻击没办法破防，就没办法打
        return false;
    if (hero.defence >= monster.attack) {     // 如果怪物的攻击没办法破放，无伤通过
        update_money(monster.money);
        return true;
    }
    int hp_loss = compute_hp_loss(monster);
    if (hp_loss < 0)
        return false;
    else
    {
        update_money(monster.money);
        update_hp(-hp_loss);
        return true;
    }
    
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
    strcpy(map[layer-1][hero.y][hero.x], "  ");
    raw_map[layer-1][hero.y][hero.x] = ROAD;
    layer += delta;
    char file_name[15];
    char tmp[2];
    tmp[0] = '0' + layer;
    tmp[1] = '\0';
    if (!map_has_load[layer - 1]) {
        // strcat("map_", tmp, file_name);
        // strcat(file_name, ".txt", file_name);
        import();
    }
    if (delta > 0) {
        hero.x = up_x[layer - 1];
        hero.y = up_y[layer - 1];
    } else {
        hero.x = down_x[layer - 1];
        hero.y = down_y[layer - 1];
    }
    print_green(hero.x, hero.y, "勇");
    raw_map[layer-1][hero.y][hero.x] = HERO;
}

bool update_money(int delta) {
    if (hero.money < -delta) {
        return false;
    }
    hero.money += delta;
    return true;
}

void buy() {
    printf("你若给我%d个金币，我就帮你提升以下一种能力。\n", shop_cost);
    printf("1. 攻击力+2\n");
    printf("2. 防御力+4\n");
    printf("3. HP+100\n");
    int ret;
    while ((ret = get_user_input()) != 0) {
        bool success = false;
        switch (ret)
        {
            case '1':
                if ((success = update_money(-shop_cost)) == true)
                    shop_cost *= 2;
                    update_attack(2);
                break;
            case '2':
                if ((success = update_money(-shop_cost)) == true)
                    shop_cost *= 2;
                    update_defence(4);
                break;
            case '3':
                if ((success = update_money(-shop_cost)) == true)
                    shop_cost *= 2;
                    update_hp(100);
                break;
            default:
                break;
        }
        if (!success) {
            printf("金钱不足\n");
            get_user_input();
        }
        draw();
    }
    screen_clear();
}

void talk_to_shop_man() {
    if (layer == 6) {
        print_conversation("商人：魔塔一共50层，每一层为一个区域。\n如果不打败此区域的头目就不能到更高的地方。");
    } else if (layer == 7) {
        print_conversation("商人：在商店里你最好选择提升防御，只有在\n攻击力低于敌人的防御力时才提升攻击力");
    }
    get_user_input();
}

void talk_to_old_man() {
    if (layer == 3) {
        print_conversation("老者：我可以给你怪物手册，你可以用快捷键3去使用它。\n它能预测出当前楼层各类怪物对你的伤害");
        has_prop[MANUAL] = true;
    } else if (layer == 4) {
        print_conversation("老者：有些门不能用钥匙打开，只有当你打败它的守卫后\n才会自动打开。");
    } else if (layer == 6) {
        print_conversation("老者：你购买了礼物后再与商人对话，\n他会告诉你一些重要的消息。");
    }
    get_user_input();
}

void use_prop(int id) {
    if (!has_prop[id - '1'])
        return;
    screen_clear();
    move_print(5);
    if (id == '1') {              // 快速上楼
        if (layer < 9 && layer_visited[layer])
            update_layer(1);
    } else if (id == '2') {       // 快速下楼
        if (layer > 1)
            update_layer(-1);
    } else if (id == '3') {       // 怪物手册
        for (int i = 0; i < 5; ++i) {
            int hp_loss = compute_hp_loss(monsters[i]);
            Monster monster = monsters[i];
            printf("%s HP:%d 攻击:%d 防御:%d 金钱:%d\n", monster.name, monster.hp, monster.attack, monster.defence, monster.money);
            if (hp_loss >= 0)
                printf("攻击它将损失%dHP\n\n", hp_loss);
            else
                printf("无法进行攻击\n\n");
        }
        get_user_input();
    }
}

void meet_king(int x, int y) {
    if (layer == 3 && x == 5 && y == 9 && meet) {
        char c;
        print_yellow(x, y - 2, "魔");
        raw_map[layer-1][y - 2][x] = DEVIL;
        draw();
        sleep(1500);
        print_conversation("魔王：欢迎来到魔塔，你是第一百位挑战者。你若能打败我所有的手下，我就与你一对一的决斗。\n现在，你必须接受我的安排！");
        get_user_input();
        print_blue(x - 1, y, "士");
        print_blue(x + 1, y, "士");
        print_blue(x, y - 1, "士");
        print_blue(x, y + 1, "士");
        raw_map[layer-1][y][x - 1] = GUARD;
        raw_map[layer-1][y][x + 1] = GUARD;
        raw_map[layer-1][y - 1][x] = GUARD;
        raw_map[layer-1][y + 1][x] = GUARD;
        draw();
        sleep(1000);
        print_conversation("什么？");
        get_user_input();
        char buf[10];
        strcpy(buf, map[layer-1][y][x]);
        print_yellow(x, y, "✦ ");
        draw();
        sleep(500);
        strcpy(map[layer-1][y][x], buf);
        draw();
        sleep(500);
        print_yellow(x, y, "✦ ");
        draw();
        meet = false;
        strcpy(map[layer-1][y-2][x], "  ");
        strcpy(map[layer-1][y][x-1], "  ");
        strcpy(map[layer-1][y][x+1], "  ");
        strcpy(map[layer-1][y-1][x], "  ");
        strcpy(map[layer-1][y+1][x], "  ");
        raw_map[layer-1][y-2][x] = ROAD;
        raw_map[layer-1][y][x-1] = ROAD;
        raw_map[layer-1][y][x+1] = ROAD;
        raw_map[layer-1][y-1][x] = ROAD;
        raw_map[layer-1][y-1][x] = ROAD;
        sleep(1500);
        print_conversation("");
        sleep(2000);
        print_conversation("........");
        get_user_input();
        print_conversation("........喂！醒醒！");
        get_user_input();
        update_layer(-1);
        strcpy(map[layer-1][hero.y][hero.x], "  ");
        raw_map[layer-1][hero.y][hero.x] = ROAD;
        hero.x = 3;
        hero.y = 8;
        hero.hp = 400;
        hero.attack = 10;
        hero.defence = 10;
        hero.has_shield = false;
        hero.has_sword = false;
        print_green(hero.x, hero.y, "勇");
        print_green(hero.x, hero.y - 1, "偷");
        raw_map[layer-1][hero.y][hero.x] = HERO;
        raw_map[layer-1][hero.y-1][hero.x] = THIEF;
        draw();
        sleep(2000);
        print_conversation("小偷：你清醒了吗？你到监狱时还处在昏迷中，魔法警卫把你扔到了我这个房间。\n但你很幸运，我刚完成逃跑的暗道你就清醒了，我们一起越狱吧。");
        get_user_input();
        // sleep(500);
        print_conversation("小偷：你的剑和盾被警卫拿走了，你必须先找到武器。我知道铁剑在5楼，铁盾在9楼，你最好先取到他们。\n我现在有事要做没法帮你，再见。");
        get_user_input();
        strcpy(map[layer-1][hero.y-1][hero.x], "  ");
        strcpy(map[layer-1][hero.y-1][hero.x-1], "  ");
        raw_map[layer-1][hero.y-1][hero.x] = ROAD;
        raw_map[layer-1][hero.y-1][hero.x-1] = ROAD;
        print_green(hero.x - 1, hero.y - 1, "偷");
        raw_map[layer-1][hero.y-1][hero.x-1] = THIEF;
        draw();
        sleep(500);
        strcpy(map[layer-1][hero.y-1][hero.x-1], "  ");
        strcpy(map[layer-1][hero.y-1][hero.x-2], "  ");
        raw_map[layer-1][hero.y-1][hero.x-1] = ROAD;
        raw_map[layer-1][hero.y-1][hero.x-2] = ROAD;
        print_green(hero.x - 2, hero.y - 1, "偷");
        raw_map[layer-1][hero.y-1][hero.x-2] = THIEF;
        draw();
        sleep(500);
        strcpy(map[layer-1][hero.y-1][hero.x-2], "  ");
        strcpy(map[layer-1][hero.y][hero.x-2], "  ");
        raw_map[layer-1][hero.y-1][hero.x-2] = ROAD;
        raw_map[layer-1][hero.y][hero.x-2] = ROAD;
        print_green(hero.x - 2, hero.y, "偷");
        raw_map[layer-1][hero.y][hero.x-2] = THIEF;
        draw();
        sleep(500);
        strcpy(map[layer-1][hero.y][hero.x-2], "  ");
        strcpy(map[layer-1][hero.y+1][hero.x-2], "  ");
        raw_map[layer-1][hero.y][hero.x-2] = ROAD;
        raw_map[layer-1][hero.y+1][hero.x-2] = ROAD;
        print_green(hero.x - 2, hero.y + 1, "偷");
        raw_map[layer-1][hero.y+1][hero.x-2] = THIEF;
        draw();
        sleep(500);
        strcpy(map[layer-1][hero.y+1][hero.x-2], "  ");
        strcpy(map[layer-1][hero.y+2][hero.x-2], "  ");
        raw_map[layer-1][hero.y+1][hero.x-2] = ROAD;
        raw_map[layer-1][hero.y+2][hero.x-2] = ROAD;
        print_green(hero.x - 2, hero.y + 2, "偷");
        raw_map[layer-1][hero.y+2][hero.x-2] = THIEF;
        draw();
        sleep(500);
        strcpy(map[layer-1][hero.y+2][hero.x-2], "  ");
        raw_map[layer-1][hero.y+2][hero.x-2] = ROAD;
        draw();
        sleep(500);
    }
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
    // meet_king(x_result, y_result);
    switch (raw_map[layer-1][y_result][x_result])
    {
    case SLIME:
    case SKELETON:
    case SKELETON_GENERAL:
    case WIZARD:
    case BAT:
        if (!battle(raw_map[layer-1][y_result][x_result])) {
            print_conversation("血量不足，与其战斗将会死亡\n");
            get_user_input();
            move_print(19);
            // printf("%c[%d;%dH",27,19,1);
            can_move = false;
        } else {
            ret = true;
            update = true;
            can_move = false;
        }
        break;
    case RED_GATE:
    case BLUE_GATE:
    case YELLOW_GATE:
        if (!open_door(raw_map[layer-1][y_result][x_result])){
            // printf("\n钥匙数量不足              \n");
            print_conversation("钥匙数量不足\n");
            get_user_input();
            move_print(19);
            can_move = false;
        } else {
            can_move = false;
            update = true;
        }
        break;
    case YELLOW_KEY:
    case BLUE_KEY:
    case RED_KEY:
        add_key_num(raw_map[layer-1][y_result][x_result]);
        raw_map[layer-1][y_result][x_result] = ROAD;
        strcpy(map[layer-1][y_result][x_result], "  ");
        update = true;
        break;
    case RED_BOTTLE:
        update_hp(50);
        update = true;
        break;
    case BLUE_BOTTLE:
        update_hp(200);
        update = true;
        break;
    case RED_GEM:
        update_attack(1);
        update = true;
        break;
    case BLUE_GEM:
        update_defence(1);
        update = true;
        break;
    case UP_STAIR:
        if (layer < 9)
            layer_visited[layer] = true;
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
    case SWORD:
        update_attack(10);
        hero.has_sword = true;
        break;
    case SHIELD:
        update_defence(10);
        hero.has_shield = true;
        break;
    case SHOP:
        buy();
        can_move = false;
        break;
    case SHOP_MAN:
        talk_to_shop_man();
        strcpy(map[layer-1][y_result][x_result], "  ");
        raw_map[layer-1][y_result][x_result] = ROAD;
        can_move = false;
        break;
    case OLD_MAN:
        talk_to_old_man();
        strcpy(map[layer-1][y_result][x_result], "  ");
        raw_map[layer-1][y_result][x_result] = ROAD;
        can_move = false;
        break;
    case FAKE_WALL:
        break;
    case UPDOWN:
        has_prop[UP_LAYER] = true;
        has_prop[DOWN_LAYER] = true;
        break;
    case BAR:
        can_move = false;
        break;
    case SPECIAL_GATE:
        print_conversation("你需要打败两个守卫才能打开门");
        can_move = false;
        break;
    default:
        if (raw_map[layer-1][y_result][x_result-1] == SHOP || raw_map[layer-1][y_result][x_result-2] == SHOP) {
            buy();
            can_move = false;
        }
        break;
    }
    if (update) {
        strcpy(map[layer-1][y_result][x_result], "  ");
        raw_map[layer-1][y_result][x_result] = ROAD;
        if (ret) {
            char buf[10];
            strcpy(buf, map[layer-1][y_result][x_result]);
            print_yellow(x_result, y_result, "✦ ");
            draw();
            sleep(150);
            strcpy(map[layer-1][y_result][x_result], buf);
            draw();
            sleep(150);
            print_yellow(x_result, y_result, "✦ ");
            draw();
            sleep(150);
            print_green(x_result, y_result, "  ");
        }
    }
    if (can_move && !new_layer) {
        hero.x = x_result;
        hero.y = y_result;
        strcpy(map[layer-1][y][x], "  ");
        raw_map[layer-1][y][x] = ROAD;
        if (!ret && !new_layer) {
            print_green(x_result, y_result, "勇");
            raw_map[layer-1][hero.y][hero.x] = HERO;
        }
    }
    return ret;
}

int main() {
    // (*ucore_status) = 1;
    screen_clear();
    // init_game();
    import();
    print_green(hero.x, hero.y, "勇");
    raw_map[layer-1][hero.y][hero.x] = HERO;
    // screen_clear();
    draw();
    int input;
    init_monsters();
    while(1) {
        // printf("Pos\n");
        if ((input = get_user_input()) == -1) {
            continue;
        }
        if (input == 'q')
            break;
        if (input == 0)
            move();
        else   
            use_prop(input);
        draw();
        meet_king(hero.x, hero.y);
    }
    // (*ucore_status) = 0;
    return 0;
}