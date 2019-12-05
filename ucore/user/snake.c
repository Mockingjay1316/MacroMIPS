#include <stdio.h>
#include <unistd.h>
#include <ulib.h>
#include <string.h>

#define printf(...)         fprintf(1, __VA_ARGS__)
#define WIDTH               20
#define HEIGHT              20
#define WIN_CONDITION       (WIDTH - 1) * (HEIGHT - 1)
#define INNIT_SNAKE_X       5
#define INIT_SNAKE_Y        5
#define GAME_OVER           1
#define WIN                 2
#define CONTINUE            3

char canvas[HEIGHT][WIDTH];     // 画布
int occupied[HEIGHT-2][WIDTH-2];
int seed = 42;
int snake_length = 2;

struct Snake {
    int m_x;
    int m_y;
};

void init_border() {
    for(int i = 0; i < HEIGHT; ++i) {
        for(int j = 0; j < WIDTH; ++j) {
            if(i == 0 || i == HEIGHT - 1) 
                canvas[i][j] = '-';
            else if(j == 0 || j == WIDTH - 1) 
                canvas[i][j] = '|';
            else
                canvas[i][j] = ' ';
        }
    }
}

void init_variables() {
    init_border();
    memset(occupied, 0, (WIDTH-2)*(HEIGHT-2));
    occupied[INNIT_SNAKE_X-1][INIT_SNAKE_Y-1] = 1;
    occupied[INNIT_SNAKE_X-2][INIT_SNAKE_Y-1] = 1;
}

void draw_canvas() {
    for(int i = 0; i < HEIGHT; ++i) {
        for(int j = 0; j < WIDTH; ++j) 
            printf("%c", canvas[i][j]);
        printf("\n");
    }
}

int randint() {
    int result;

    seed *= 1103515245;
    seed += 12345;
    result = (unsigned int) (seed / 65536) % 2048;

    // seed *= 1103515245;
    // seed += 12345;
    // result <<= 10;
    // result ^= (unsigned int) (seed / 65536) % 1024;

    // seed *= 1103515245;
    // seed += 12345;
    // result <<= 10;
    // result ^= (unsigned int) (seed / 65536) % 1024;

    seed = result;

    return result;
}

void generate_food(int *x_food, int *y_food) {
    int remain = (WIDTH - 2) * (HEIGHT - 2) - snake_length;
    int random_cnt = randint() % remain;
    int current_cnt = 0;
    for(int i = 0; i < WIDTH - 2; ++i) {
        for(int j = 0; j < HEIGHT - 2; ++j) {
            if(occupied[i][j] == 0)
                if(++current_cnt == random_cnt) {
                    *x_food = i + 1;
                    *y_food = j + 1;
                    canvas[*y_food][*x_food] = '*';
                    // printf("x_food:%d y_food:%d", *x_food, *y_food);
                    // draw_canvas();
                    return;
                }
        }
    }
    printf("NOTE!!!Error!!!!!!\n");
}

bool get_user_input(int *x_direction, int *y_direction) {
    // int tmp = getchar_wo_blocking();
    char c;
    int ret;
    bool flag = 0;
    if ((ret = read(0, &c, sizeof(char))) < 0) {
        return flag;
    }
    switch (c)
    {
    case 'w':
    // case 'W':
        if (*y_direction != 1) {
            flag = 1;
            *y_direction = -1;
            *x_direction = 0;
        }
        break;
    case 's':
    // case 'S':
        if (*y_direction != -1) {
            flag = 1;
            *y_direction = 1;
            *x_direction = 0;
        }
        break;
    case 'a':
    // case 'A':
        if (*x_direction != 1) {
            flag = 1;
            *x_direction = -1;
            *y_direction = 0;
        }
        break;
    case 'd':
    // case 'D':
        if (*x_direction != -1) {
            flag = 1;
            *x_direction = 1;
            *y_direction = 0;
        }
        break;
    default:
        break;
    }
    // printf("%c\n", c);
    return flag;
}

int update_snake(struct Snake *snake, int *x_direction, int *y_direction, int *x_food, int *y_food) {
    struct Snake *tail = snake + snake_length - 1;
    int x_tail = tail->m_x;
    int y_tail = tail->m_y;
    struct Snake *head = snake;
    occupied[tail->m_y-1][tail->m_x-1] = 0;
    canvas[tail->m_y][tail->m_x] = ' ';
    for (int i = snake_length - 1; i > 0; --i) {
        snake[i].m_x = snake[i-1].m_x;
        snake[i].m_y = snake[i-1].m_y;
    }
    head->m_x += *x_direction;
    head->m_y += *y_direction;
    occupied[head->m_y-1][head->m_x-1] = 1;
    if (head->m_x == *x_food && head->m_y == *y_food) {
        snake[snake_length].m_x = x_tail;
        snake[snake_length].m_y = y_tail;
        generate_food(x_food, y_food);
        if(++snake_length == WIN_CONDITION) {
            return WIN;
        }
    }
    for(int i = 1; i < snake_length; ++i) {
        if((snake[i].m_x == head->m_x && snake[i].m_y == head->m_y) || 
            (head->m_x == 0 || head->m_x == WIDTH - 1) || 
            (head->m_y == 0 || head->m_y == HEIGHT - 1))
            return GAME_OVER;
    }


    for(int i = 0; i < snake_length; ++i) {
        int x = snake[i].m_x;
        int y = snake[i].m_y;
        canvas[y][x] = '@';
    }

    return CONTINUE;
}

int main() {
    struct Snake snake[(WIDTH-2)*(HEIGHT-2)];
    snake[0].m_x = 5;
    snake[0].m_y = 5;
    snake[1].m_x = 4;
    snake[1].m_y = 5;
    int x_direction = 1;
    int y_direction = 0;
    int x_food;
    int y_food;

    init_variables();
    printf("\e[1;1H\e[2J");
    generate_food(&x_food, &y_food);
    while(1) {
        printf("%c[%d;%dH",27,1,1);
        printf("贪吃蛇小游戏\n");
        printf("WASD控制上下左右\n");
        printf("蛇头碰触墙壁或身体则游戏结束，按WASD任意键开始\n");

        int fpid=fork();

        if(fpid<0)
        {
            printf("error\n");
        }
        else if(fpid==0)//child
        {
            while(1)
            {
                int game_status = update_snake(snake, &x_direction, &y_direction, &x_food, &y_food);
                printf("%c[%d;%dH",27,1,1);
                printf("贪吃蛇小游戏\n");
                printf("WASD控制上下左右\n");
                printf("蛇头碰触墙壁或身体则游戏结束，按WASD任意键开始\n");printf("X_Direction:%d Y_Direction:%d X_food:%d y_food:%d\n", x_direction, y_direction, x_food, y_food);
                printf("X_Head:%d Y_Head:%d\n", snake[0].m_x, snake[0].m_y);
                switch (game_status)
                {
                case CONTINUE:
                    break;
                case GAME_OVER:
                    printf("%c[%d;%dH",27,1,1);
                    for(int i = 0; i < 5 + HEIGHT; ++i) {
                        for(int j = 0; j < 100; ++j)
                            printf(" ");
                        printf("\n");
                    }
                    printf("%c[%d;%dH",27,1,1);
                    printf("Game Over\n");
                    return 0;
                case WIN:
                    printf("%c[%d;%dH",27,4,1);
                    printf("You Win\n");
                    return 0;
                default:
                    break;
                }

                draw_canvas();

                
                sleep(400);//0.4s
            }
        }
        else//father
        {
            int time=gettime_msec(),move=0;
            int bef_x_direction=x_direction,bef_y_direction=y_direction;

            if (!get_user_input(&x_direction, &y_direction)) {
                continue;
            }


            kill(fpid);
            move=(gettime_msec()-time)/400;
            
            int game_status;
            for(int i=0;i<=move;i++)
            {
                game_status = update_snake(snake, &bef_x_direction, &bef_y_direction, &x_food, &y_food);
                if(game_status==GAME_OVER||game_status==WIN)break;
            }
            printf("%c[%d;%dH",27,1,1);
            printf("贪吃蛇小游戏\n");
            printf("WASD控制上下左右\n");
            printf("蛇头碰触墙壁或身体则游戏结束，按WASD任意键开始\n");
            printf("X_Direction:%d Y_Direction:%d X_food:%d y_food:%d\n", bef_x_direction, bef_y_direction, x_food, y_food);
            printf("X_Head:%d Y_Head:%d\n", snake[0].m_x, snake[0].m_y);
            switch (game_status)
            {
            case CONTINUE:
                break;
            case GAME_OVER:
                printf("%c[%d;%dH",27,1,1);
                for(int i = 0; i < 5 + HEIGHT; ++i) {
                    for(int j = 0; j < 100; ++j)
                        printf(" ");
                    printf("\n");
                }
                printf("%c[%d;%dH",27,1,1);
                printf("Game Over\n");
                return 0;
            case WIN:
                printf("%c[%d;%dH",27,4,1);
                printf("You Win\n");
                return 0;
            default:
                break;
            }

            draw_canvas();
        }
    }
}
