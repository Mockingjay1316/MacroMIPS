#ifndef ITEM_H
#define ITEM_H

#define RED                 0
#define YELLOW              1
#define BLUE                2

#define SLIME               0
#define SKELETON            1
#define SKELETON_GENERAL    2
#define BAT                 3
#define WIZARD              4
#define GIANT               5
#define DEVIL               6

#define UP                  0
#define DOWN                1

typedef struct Wall {
    int x;
    int y;
}Wall;

typedef struct Bottle {
    int x;
    int y;
    int type;
    int hp_up;
}Bottle;

typedef struct Gem {
    int x;
    int y;
    int type;
    int attack_up;
    int defence_up;
}Gem;

typedef struct Gate {
    int x;
    int y;
    int type;
}Gate;

typedef struct Key {
    int x;
    int y;
    int type;
}Key;

typedef struct Stair {
    int x;
    int y;
    int type;
}Stair;

typedef struct Monster {
    int x;
    int y;
    int type;
    int hp;
    int attack;
    int defence;
}Monster;

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

#endif