#include <string>
#include <map>
#include "map.h"

using std::string;

map<string, string> char2name = {{"#", "wall"}, {"l", "blue bottle"}, {"h", "red bottle"}, {"r", "red gate"}, 
                                {"b", "blue gate"}, {"y", "yellow gate"}, {"k", "yellow key"}, {"e", "blue key"},
                                {"d", "red key"}, {"o", "blue gem"}, {"p", "red gem"}, {"m", "slime"},
                                {"f", "bat"}, {"g", "skeleton"}, {"j", "skeleton general"}, {"s", "wizard"},
                                {" ", "space"}, {"t", "up stair"}, {"w", "down stair"}};
map<string, string> print_name = {{"wall", "██"}, {"blue bottle", "血"}, {"red bottle", "血"}, {"red gate", "〓"}, 
                                {"blue gate", "〓"}, {"yellow gate", "〓"}, {"yellow key", "♀ "}, {"blue key", "♀ "},
                                {"red key", "♀ "}, {"blue gem", "◆ "}, {"red gem", "◆ "}, {"slime", "姆"},
                                {"bat", "蝠"}, {"skeleton", "骷"}, {"skeleton general", "军"}, {"wizard", "法"},
                                {"space", "  "}, {"up stair", "↑ "}, {"down stair", "↓ "}};

void Map::import(string file_name) {
    ifstream stream(file_name);
    int y = 0;
    string line;
    for (int i = 0; i < BOARD_SIZE; ++i) {
        map[0][i] = "██";
        map[i][0] = "██";
        map[BOARD_SIZE - 1][i] = "██";
        map[i][BOARD_SIZE - 1] = "██";
        // items[0][i] = Wall(i, 0);
        // items[i][0] = Wall(0, i);
    }
    while (1) {
        getline(stream, line);
        if (stream.eof())
            break;
        for (int x = 0; x < line.length(); ++x) {
            string name = char2name[line.substr(x, 1)];
            string p = print_name[name];
            if (name == "blue bottle") {         //蓝血瓶 
                // items[y + 1][x + 1] = Bottle(x + 1, y + 1, COLOR::blue);
                map[y + 1][x + 1] = print_blue(p);
            } else if (name == "red bottle") {          //红血瓶 
                // items[y + 1][x + 1] = Bottle(x + 1, y + 1, COLOR::red);
                map[y + 1][x + 1] = print_red(p);
            } else if (name == "red gate") {            //红色门 
                // items[y + 1][x + 1] = Gate(x + 1, y + 1, COLOR::red);
                map[y + 1][x + 1] = print_red(p);
            } else if (name == "blue gate") {           //蓝色门
                // items[y + 1][x + 1] = Gate(x + 1, y + 1, COLOR::blue);
                map[y + 1][x + 1] = print_blue(p);
            } else if (name == "yellow gate") {         //黄色门
                // items[y + 1][x + 1] = Gate(x + 1, y + 1, COLOR::yellow);
                map[y + 1][x + 1] = print_yellow(p);
            } else if (name == "yellow key") {          //黄钥匙
                // items[y + 1][x + 1] = Key(x + 1, y + 1, COLOR::yellow);
                map[y + 1][x + 1] = print_yellow(p);
            } else if (name == "blue key") {            //蓝钥匙
                // items[y + 1][x + 1] = Key(x + 1, y + 1, COLOR::blue);
                map[y + 1][x + 1] = print_blue(p);
            } else if (name == "red key") {             //红钥匙
                // items[y + 1][x + 1] = Key(x + 1, y + 1, COLOR::red);
                map[y + 1][x + 1] = print_red(p);
            } else if (name == "blue gem") {            //蓝宝石
                // items[y + 1][x + 1] = Gem(x + 1, y + 1, COLOR::blue);
                map[y + 1][x + 1] = print_blue(p);
            } else if (name == "red gem") {             //红宝石
                // items[y + 1][x + 1] = Gem(x + 1, y + 1, COLOR::red);
                map[y + 1][x + 1] = print_red(p);
            // } else if (name == "slime") {               //史莱姆
            //     // items[y + 1][x + 1] = Monster(x + 1, y + 1, MONSTER_TYPE::slime);
            // } else if (name == "bat") {                 //小蝙蝠
            //     items[y + 1][x + 1] = Monster(x + 1, y + 1, MONSTER_TYPE::bat);
            // } else if (name == "skeleton") {            //骷髅怪
            //     items[y + 1][x + 1] = Monster(x + 1, y + 1, MONSTER_TYPE::skeleton);
            // } else if (name == "skeleton general") {    //骷髅将军
            //     items[y + 1][x + 1] = Monster(x + 1, y + 1, MONSTER_TYPE::skeleton_general);
            // } else if (name == "wizard") {              //暗黑法师
            //     items[y + 1][x + 1] = Monster(x + 1, y + 1, MONSTER_TYPE::wizard);
            // } else if (name == "up stair") {            //上楼梯
            //     items[y + 1][x + 1] = Stair(x + 1, y + 1, STAIR_TYPE::up);
            // } else if (name == "down stair") {          //下楼梯
            //     items[y + 1][x + 1] = Stair(x + 1, y + 1, STAIR_TYPE::down);
            // }
            } else {
                map[y + 1][x + 1] = p;
            }
            // map[y + 1][x + 1] = print_name[name];
        }
        y += 1;
    }
}

// void Map::print_color(int type, string c) {
//     switch (type)
//     {
//     case COLOR::red:
//         print_red(c);
//         break;
//     case COLOR::blue:
//         print_blue(c);
//         break;
//     case COLOR::yellow:
//         print_yellow(c);
//         break;
//     default:
//         break;
//     }
// }

void Map::draw() {
    printf("%c[%d;%dH",27,1,1);
    for (int y = 0; y < BOARD_SIZE; ++y) {
        for (int x = 0; x < BOARD_SIZE; ++x) {
            // if (items[y][x].is_wall()) {                       //墙壁 
            //     printf("%c", map[y][x]);
            // } else if (items[y][x].is_bottle()) {         //蓝血瓶 
            //     print_color(items[y][x].get_type(), map[y][x]);
            // } else if (items[y][x].is_gem()) {          //红血瓶 
            //     print_color(items[y][x].get_type(), map[y][x]);
            // } else if (items[y][x].is_gate()) {            //红色门 
            //     print_color(items[y][x].get_type(), map[y][x]);
            // } else if (items[y][x].is_key()) {           //蓝色门
            //     print_color(items[y][x].get_type(), map[y][x]);
            // } else if (items[y][x].is_monster()) {         //黄色门
            //     printf("%c", map[y][x]);
            // } else if (items[y][x].is_stair()) {          //黄钥匙
            //     printf("%c", map[y][x]);
            // }
            printf("%s", map[y][x].c_str());
        }
        printf("\n");
    }
}