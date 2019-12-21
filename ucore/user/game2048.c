#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <file.h>
#include <error.h>
#include <unistd.h>

#define printf(...)                     fprintf(1, __VA_ARGS__)

void op(int *a) {
    printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
    printf("_____________________\n");
    int i,j;
    for(i=0;i<4;i++) {
        printf("|    |    |    |    |\n|");
        for(j=0;j<4;j++)~a[i*4+j]?printf("%4d|",a[i*4+j]):printf("    |");
        printf("\n|____|____|____|____|\n");
    }
}
int getrand(int *t) {
    *t=(*t)*(*t)+(*t)+3;
    return ((*t) >> 3)&3;
}
int check(int*a,int*t,int*s) {
    int flag=1,i;
    for(i=0;i<16;i++)
        if(a[i]>=2048) {
            op(a);
            printf("win!\n");
            return 1;
        }
    int x=getrand(t),y=getrand(t);
    while(a[x*4+y]!=-1)x=getrand(t),y=getrand(t);
    a[x*4+y]=(getrand(t)==0?4:2);
    for(i=0;i<4;i++)s[i]=0;
    for(i=4;i<16;i++)if(a[i]!=-1&&(a[i]==a[i-4]||a[i-4]==-1))flag=0,s[0]=1;
    for(i=0;i<16;i++)if((i&3)>0&&(a[i]!=-1&&(a[i]==a[i-1]||a[i-1]==-1)))flag=0,s[1]=1;
    for(i=0;i<12;i++)if(a[i]!=-1&&(a[i]==a[i+4]||a[i+4]==-1))flag=0,s[2]=1;
    for(i=0;i<16;i++)if((i&3)<3&&(a[i]!=-1&&(a[i]==a[i+1]||a[i+1]==-1)))flag=0,s[3]=1;
    if(flag==1) {
        op(a);
        printf("game over\n");
        return 1;
    }
    return 0;
}
void move(int*a,int k) {
    int dx[4]={-1,0,1,0},dy[4]={0,-1,0,1};
    int fx[4]={1,0,2,3},fy[4]={0,1,3,2};
    int tx[4]={4,4,-1,-1},ty[4]={4,4,-1,-1};
    int ax[4]={1,1,-1,-1},ay[4]={1,1,-1,-1};
    int i,j,l,b[16];
    for(i=0;i<16;i++)b[i]=(a[i]==-1?0:1);
    for(l=1;l<=3;l++)
        for(i=fx[k];i!=tx[k];i+=ax[k])
            for(j=fy[k];j!=ty[k];j+=ay[k])
                if(b[i*4+j]&&b[(i+dx[k])*4+(j+dy[k])]&&a[i*4+j]==a[(i+dx[k])*4+(j+dy[k])])
                    a[(i+dx[k])*4+(j+dy[k])]+=a[i*4+j],b[(i+dx[k])*4+(j+dy[k])]=0,a[i*4+j]=-1,b[i*4+j]=0;
                else if(a[(i+dx[k])*4+(j+dy[k])]==-1)
                    a[(i+dx[k])*4+(j+dy[k])]=a[i*4+j],b[(i+dx[k])*4+(j+dy[k])]=b[i*4+j],a[i*4+j]=-1,b[i*4+j]=0;
}
int
main(int argc, char **argv) {
    char c;
    int i,j,ret,t=233;                             //t随机数种子
    int a[16],s[4];
    for(i=0;i<4;i++)
        for(j=0;j<4;j++)
            a[i*4+j]=-1;
    printf("\e[1;1H\e[2J");                        //把输入移至第一行
    if(check(a,&t,s))return 0;
    op(a);
    while(1) {
        int flag=0;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
            return 0;
        }
        if(c=='w'&&s[0])move(a,0);
        else if(c=='a'&&s[1])move(a,1);
        else if(c=='s'&&s[2])move(a,2);
        else if(c=='d'&&s[3])move(a,3);             //wasd操控
        else if(c==27)return 0;                     //esc退出
        else flag=1;
        if(flag==0&&check(a,&t,s))return 0;
        op(a);
    }
    return 0;
}
/*
_____________________
|    |    |    |    |
|1234|1234|1234|1234|
|____|____|____|____|
|    |    |    |    |
|1234|1234|1234|1234|
|____|____|____|____|
|    |    |    |    |
|1234|1234|1234|1234|
|____|____|____|____|
|    |    |    |    |
|1234|1234|1234|1234|
|____|____|____|____|
*/