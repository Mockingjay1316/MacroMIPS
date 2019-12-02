#include <stdio.h>
#include <utility>
#include <stdlib.h>
#include "item.h"
#include "map.h"

int main() {
    printf("\e[1;1H\e[2J");
    Map map;
    map.import("maps/map_1.txt");
    map.draw();
    // system("pause");
    getchar();
    return 0;
}