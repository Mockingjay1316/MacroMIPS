#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <file.h>
#include <error.h>
#include <unistd.h>

#define printf(...)                     fprintf(1, __VA_ARGS__)
#define putc(c)                         printf("%c", c)

void colprintf(char*s, int col)
{   int l=strlen(s),i;
    for(i=0;i<l;i++)
        sleep(100),*(int*)(0xbfd003f8) = (1 << 16) + (col << 8) + s[i];
}
int main(int argc, char **argv)
{   colprintf("red\n",224);
    colprintf("orange\n",224+12);
    colprintf("yellow\n",224+28);
    colprintf("green\n",28);
    colprintf("cyan\n",28+3);
    colprintf("blue\n",3);
    colprintf("purple\n",224+3);
	return 0;
}