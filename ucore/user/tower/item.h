#ifndef ITEM_H
#define ITEM_H
#include <string>
#include <utility>

using std::string;
using std::pair;

enum COLOR {red, yellow, blue};
enum MONSTER_TYPE {slime, skeleton, skeleton_general, bat, wizard, giant, devil};
// enum PROPERTY_TYPE {red_bottle, blue_bottle, red_gem, blue_gem};
enum STAIR_TYPE {up, down};
// enum GATE_TYPE {red, yellow, blue};

class Item {
public:
    int x;
    int y;
    int type;

    Item() {
        this->x = 0;
        this->y = 0;
    }

    Item(int x, int y) {
        this->x = x;
        this->y = y;
    }

    pair<int, int> get_coordinate();
    int get_type() { return type; }
    bool is_wall() { return false; }
    bool is_bottle() { return false; }
    bool is_gem() { return false; }
    bool is_gate() { return false; }
    bool is_key() { return false; }
    bool is_stair() { return false; }
    bool is_monster() { return false; }
    bool is_hero() { return false; }
};

class Wall : public Item {
public:
    Wall() {
        this->x = -1;
        this->y = -1;
    }

    Wall(int x, int y) {
        this->x = x;
        this->y = y;
    }

    bool is_wall() { return true; }
};

class Bottle : public Item {
    int type;
    int hp_up;

public:
    Bottle() {
        this->type = -1;
        this->hp_up = 0;
    }
    Bottle(int x, int y, int type);
    
    bool is_bottle() { return true; }
};

class Gem : public Item {
    int type;
    int attack_up;
    int defence_up;

public:
    Gem() {
        this->type = -1;
        this->attack_up = 0;
        this->defence_up = 0;
    }
    Gem(int x, int y, int type);

    bool is_gem() { return true; }
};

class Gate : public Item {
    int type;
public:
    Gate() {
        this->x = -1;
        this->y = -1;
        this->type = -1;
    }

    Gate(int x, int y, int type) {
        this->x = x;
        this->y = y;
        this->type = type;
    }

    bool is_gate() { return true; }
};

class Key : public Item {
    int type;
public:
    Key() {
        this->x = -1;
        this->y = -1;
        this->type = -1;
    }

    Key(int x, int y, int type) {
        this->x = x;
        this->y = y;
        this->type = type;
    }

    // static Key* get_key(int x, int y, int type);
    bool is_key() { return true; }
};

class Stair : public Item {
    int type;
public:
    Stair() {}

    Stair(int x, int y, int type) {
        this->x = x;
        this->y = y;
        this->type = type;
    }

    bool is_stair() { return true; }
};

class Monster : public Item {
    int type;
    int hp;
    int attack;
    int defence;
public:
    Monster() {
        this->x = -1;
        this->y = -1;
        this->type = -1;
        this->hp = 0;
        this->attack = 0;
        this->defence = 0;
    }

    Monster(int x, int y, int type);

    // static Monster* get_monster(int x, int y, int type);
    bool update_hp(int delta);
    bool is_monster() { return true; }
    
};

class Hero : public Item {
    int hp;
    int attack;
    int defence;
    int money;
    int red_key_num;
    int blue_key_num;
    int yellow_key_num;

public:
    Hero() : Item(11, 6), hp(400), attack(15), defence(10), money(0),
            red_key_num(0), blue_key_num(0), yellow_key_num(0) {}
    
    bool update_key_num(int type, int delta);
    void update_attack(int delta);
    void update_defence(int delta);
    bool update_hp(int delta);
    bool update_money(int delta);
    bool is_hero() { return true; }

};

#endif