// #include "item.h"

// void get_coordinate() {
//     return pair<int, int>(x, y);
// }

// Bottle::Bottle(int x, int y, int type) : Bottle() {
//     this->x = x;
//     this->y = y;
//     this->type = type;
//     switch (type)
//     {
//     case COLOR::red:
//         this->hp_up = 50;
//         break;
//     case COLOR::blue:
//         this->hp_up = 100;
//         break;
//     default:
//         break;
//     }
// }

// Gem::Gem(int x, int y, int type) : Gem() {
//     this->x = x;
//     this->y = y;
//     this->type = type;
//     switch (type)
//     {
//     case COLOR::red:
//         this->attack_up = 5;
//         break;
//     case COLOR::blue:
//         this->defence_up = 5;
//         break;
//     default:
//         break;
//     }
// }

// Monster::Monster(int x, int y, int type) {
//     this->x = x;
//     this->y = y;
//     this->type = type;
//     switch (type)
//     {
//     case MONSTER_TYPE::slime:
//         this->hp = 50;
//         this->attack = 20;
//         this->defence = 1;
//         break;
//     case MONSTER_TYPE::skeleton:
//         this->hp = 110;
//         this->attack = 25;
//         this->defence = 5;
//         break;
//     case MONSTER_TYPE::bat:
//         this->hp = 100;
//         this->attack = 20;
//         this->defence = 5;
//         break;
//     case MONSTER_TYPE::skeleton_general:
//         this->hp = 150;
//         this->attack = 50;
//         this->defence = 20;
//         break;
//     case MONSTER_TYPE::giant:
//         this->hp = 450;
//         this->attack = 150;
//         this->defence = 90;
//         break;
//     case MONSTER_TYPE::devil:
//         this->hp = 1000;
//         this->attack = 400;
//         this->defence = 300;
//         break;
//     default:
//         break;
//     }
// }


// bool Monster::update_hp(int delta){
//     hp += delta;
//     return hp > 0;
// }

// bool Hero::update_key_num(int type, int delta) {
//     bool flag = false;
//     switch (type)
//     {
//     case COLOR::red:
//         if (red_key_num < -delta)
//             return false;
//         red_key_num += delta;
//         break;
//     case COLOR::blue:
//         if (blue_key_num < -delta)
//             return false;
//         blue_key_num += delta;
//         break;
//     case COLOR::yellow:
//         if (yellow_key_num < -delta)
//             return false;
//         yellow_key_num += delta;
//         break;    
//     default:
//         return false;
//     }
//     return true;
// }

// void Hero::update_attack(int delta) {
//     attack += delta;
// }

// void Hero::update_defence(int delta) {
//     defence += delta;
// }

// bool Hero::update_hp(int delta) {
//     hp += delta;
//     return hp > 0;
// }

// bool Hero::update_money(int delta) {
//     if (money < -delta)
//         return false;
//     else {
//         money += delta;
//         return true;
//     }
// }
