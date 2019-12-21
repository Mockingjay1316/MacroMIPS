//PC Logo
#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <file.h>
#include <error.h>
#include <unistd.h>

#define printf(...)                     fprintf(1, __VA_ARGS__)
#define putc(c)                         printf("%c", c)

int Cos[360]={65536,65526,65496,65446,65376,65286,65176,65047,64898,64729,64540,64331,64103,63856,63589,63302,62997,62672,62328,61965,61583,61183,60763,60326,59870,59395,58903,58393,57864,57319,56755,56175,55577,54963,54331,53683,53019,52339,51643,50931,50203,49460,48702,47929,47142,46340,45525,44695,43852,42995,42125,41243,40347,39440,38521,37589,36647,35693,34728,33753,32768,31772,30767,29752,28729,27696,26655,25606,24550,23486,22414,21336,20251,19160,18064,16961,15854,14742,13625,12504,11380,10252,9120,7986,6850,5711,4571,3429,2287,1143,0,-1143,-2287,-3429,-4571,-5711,-6850,-7986,-9120,-10252,-11380,-12504,-13625,-14742,-15854,-16961,-18064,-19160,-20251,-21336,-22414,-23486,-24550,-25606,-26655,-27696,-28729,-29752,-30767,-31772,-32767,-33753,-34728,-35693,-36647,-37589,-38521,-39440,-40347,-41243,-42125,-42995,-43852,-44695,-45525,-46340,-47142,-47929,-48702,-49460,-50203,-50931,-51643,-52339,-53019,-53683,-54331,-54963,-55577,-56175,-56755,-57319,-57864,-58393,-58903,-59395,-59870,-60326,-60763,-61183,-61583,-61965,-62328,-62672,-62997,-63302,-63589,-63856,-64103,-64331,-64540,-64729,-64898,-65047,-65176,-65286,-65376,-65446,-65496,-65526,-65536,-65526,-65496,-65446,-65376,-65286,-65176,-65047,-64898,-64729,-64540,-64331,-64103,-63856,-63589,-63302,-62997,-62672,-62328,-61965,-61583,-61183,-60763,-60326,-59870,-59395,-58903,-58393,-57864,-57319,-56755,-56175,-55577,-54963,-54331,-53683,-53019,-52339,-51643,-50931,-50203,-49460,-48702,-47929,-47142,-46340,-45525,-44695,-43852,-42995,-42125,-41243,-40347,-39440,-38521,-37589,-36647,-35693,-34728,-33753,-32768,-31772,-30767,-29752,-28729,-27696,-26655,-25606,-24550,-23486,-22414,-21336,-20251,-19160,-18064,-16961,-15854,-14742,-13625,-12504,-11380,-10252,-9120,-7986,-6850,-5711,-4571,-3429,-2287,-1143,0,1143,2287,3429,4571,5711,6850,7986,9120,10252,11380,12504,13625,14742,15854,16961,18064,19160,20251,21336,22414,23486,24550,25606,26655,27696,28729,29752,30767,31772,32768,33753,34728,35693,36647,37589,38521,39440,40347,41243,42125,42995,43852,44695,45525,46340,47142,47929,48702,49460,50203,50931,51643,52339,53019,53683,54331,54963,55577,56175,56755,57319,57864,58393,58903,59395,59870,60326,60763,61183,61583,61965,62328,62672,62997,63302,63589,63856,64103,64331,64540,64729,64898,65047,65176,65286,65376,65446,65496,65526};
int Sin[360]={0,1143,2287,3429,4571,5711,6850,7986,9120,10252,11380,12504,13625,14742,15854,16961,18064,19160,20251,21336,22414,23486,24550,25606,26655,27696,28729,29752,30767,31772,32767,33753,34728,35693,36647,37589,38521,39440,40347,41243,42125,42995,43852,44695,45525,46340,47142,47929,48702,49460,50203,50931,51643,52339,53019,53683,54331,54963,55577,56175,56755,57319,57864,58393,58903,59395,59870,60326,60763,61183,61583,61965,62328,62672,62997,63302,63589,63856,64103,64331,64540,64729,64898,65047,65176,65286,65376,65446,65496,65526,65536,65526,65496,65446,65376,65286,65176,65047,64898,64729,64540,64331,64103,63856,63589,63302,62997,62672,62328,61965,61583,61183,60763,60326,59870,59395,58903,58393,57864,57319,56755,56175,55577,54963,54331,53683,53019,52339,51643,50931,50203,49460,48702,47929,47142,46340,45525,44695,43852,42995,42125,41243,40347,39440,38521,37589,36647,35693,34728,33753,32767,31772,30767,29752,28729,27696,26655,25606,24550,23486,22414,21336,20251,19160,18064,16961,15854,14742,13625,12504,11380,10252,9120,7986,6850,5711,4571,3429,2287,1143,0,-1143,-2287,-3429,-4571,-5711,-6850,-7986,-9120,-10252,-11380,-12504,-13625,-14742,-15854,-16961,-18064,-19160,-20251,-21336,-22414,-23486,-24550,-25606,-26655,-27696,-28729,-29752,-30767,-31772,-32768,-33753,-34728,-35693,-36647,-37589,-38521,-39440,-40347,-41243,-42125,-42995,-43852,-44695,-45525,-46340,-47142,-47929,-48702,-49460,-50203,-50931,-51643,-52339,-53019,-53683,-54331,-54963,-55577,-56175,-56755,-57319,-57864,-58393,-58903,-59395,-59870,-60326,-60763,-61183,-61583,-61965,-62328,-62672,-62997,-63302,-63589,-63856,-64103,-64331,-64540,-64729,-64898,-65047,-65176,-65286,-65376,-65446,-65496,-65526,-65536,-65526,-65496,-65446,-65376,-65286,-65176,-65047,-64898,-64729,-64540,-64331,-64103,-63856,-63589,-63302,-62997,-62672,-62328,-61965,-61583,-61183,-60763,-60326,-59870,-59395,-58903,-58393,-57864,-57319,-56755,-56175,-55577,-54963,-54331,-53683,-53019,-52339,-51643,-50931,-50203,-49460,-48702,-47929,-47142,-46340,-45525,-44695,-43852,-42995,-42125,-41243,-40347,-39440,-38521,-37589,-36647,-35693,-34728,-33753,-32768,-31772,-30767,-29752,-28729,-27696,-26655,-25606,-24550,-23486,-22414,-21336,-20251,-19160,-18064,-16961,-15854,-14742,-13625,-12504,-11380,-10252,-9120,-7986,-6850,-5711,-4571,-3429,-2287,-1143};
int len,ln,l;								//len: length of input  ln: number of name
char com[123456];							//input
int nx,ny,ang,col,is_down;					//nx ny: now x y  ang: angle  is_down: about pen
char name[1234][123];						//name<=>id
int func_place[1234];						//place of functions
int variable_value[1234][123],topv[1234];
int tmp_variable[1234][123],lv[1234];
int return_stack[1234],topr;
int oper_stack[1234],topo,num_stack[1234],topn;
int Mx,My,Map[800][600];

int abs(int x)
{   return x>0?x:-x;
}
int getsign(int x)
{	return x<0?1:0;
}
int division(int a, int b)//https://blog.csdn.net/ojshilu/article/details/11179911
{	if(b==0)return 0;
	int flag=1;
	if(getsign(a)==getsign(b))flag=0;
	a=abs(a);
	b=abs(b);
	int n=0;
	a=a-b;
	while(a>=0)
	{	n=n+1;
		a=a-b;
	}
	if(flag)n=-n;
	return n;
}
void op()
{	printf("\e[1;1H\e[2J");                        //把输入移至第一行
    int i,j,k,l;
    for(j=My-1;j>=0;j-=10){
		for(i=0;i<Mx;i+=10)
		{	int tmp=255;
			for(k=0;k<10;k++)
				for(l=0;l<10;l++)
					tmp=tmp<Map[i+k][j-l]?tmp:Map[i+k][j-l];
			//tmp=division(tmp,100);//tmp/=100;
			if(tmp==0)printf("#");
			else if(tmp==1)printf("$");
			else if(tmp==2)printf("&");
			else if(tmp==3)printf("*");
			else if(tmp==4)printf(".");
			else printf(" ");
		}
		printf("\n");
	}
}
void readAll() {
    int ret, i = 0, j = 0, x = 0;						//添加x用于记录光标位于倒数第x的位置 
    int flag = 0;                                       //0:init  1:get 27  2:get 91
    const char deleteKey = 127;
    const char dir_27 = 27;                             //输入方向键会依次得到27/91/65~68
    const char dir_91 = 91;
    const char leftKey = 'D';
    const char rightKey = 'C';
    while (1) {
        char c;
        if ((ret = read(0, &c, sizeof(char))) < 0) {
            exit(1);
        }
        else if (ret == 0) {
            if (i > 0) {
                com[i] = '\0';
                break;
            }
            return;
        }
        if (c == 3) {
            return;
        }
        else if (c == '#') {
            len = ++i;
            break;
        }
        else if (c == dir_27 && flag==0) {
            flag=1;
        }
        else if (c == dir_91 && flag==1) {
            flag=2;
        }
        else if ((c == deleteKey) && i > 0 && x < i) {
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i;j++)
                if(com[j]=='\n')printf("\n");
                else printf(" ");
            for(j=x;j>0;j--)com[i-j-1]=com[i-j];
			i--;
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
            for(j=0;j<i;j++)printf("%c",com[j]);
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i-x;j++)
                if(com[j]=='\n')printf("\n");
                else printf("%c",com[j]);
        }
        else if ((c == '\b') && i > 0 && x < i) {
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i;j++)
                if(com[j]=='\n')printf("\n");
                else printf(" ");
            for(j=x;j>0;j--)com[i-j-1]=com[i-j];
			i--;
			printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
            for(j=0;j<i;j++)printf("%c",com[j]);
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i-x;j++)
                if(com[j]=='\n')printf("\n");
                else printf("%c",com[j]);
        }
        else if ((c==leftKey)&&flag==2) {
            flag=0;
            if(x<i)	x++;
			printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
            for(j=0;j<i;j++)printf("%c",com[j]);
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i-x;j++)
                if(com[j]=='\n')printf("\n");
                else printf("%c",com[j]);
		}
        else if ((c==rightKey)&&flag==2) {
            flag=0;
            if(x>0) x--;
			printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
            for(j=0;j<i;j++)printf("%c",com[j]);
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i-x;j++)
                if(com[j]=='\n')printf("\n");
                else printf("%c",com[j]);
		}
        else if (flag==2) {
            flag=0;
        }
        else if (c >= ' ' && c < deleteKey && i < 100000 - 1) {
            if(x==0) {
				com[i++]=c;
				printf("%c",com[i-1]);
			} else {
				for(j=0;j<x;j++)com[i-j]=com[i-j-1];
				com[i-x] = c;
				i++;
				printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
				for(j=0;j<i;j++)printf("%c",com[j]);
				printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
				for(j=0;j<i-x;j++)
					if(com[j]=='\n')printf("\n");
					else printf("%c",com[j]);
			}
        }
        else if ((c == '\n' || c == '\r') && i < 100000 - 1) {
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i;j++)
                if(com[j]=='\n')printf("\n");
                else printf(" ");
            for(j=0;j<x;j++)com[i-j]=com[i-j-1];
            com[i-x] = '\n';
            i++;
			printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
            for(j=0;j<i;j++)printf("%c",com[j]);
            printf("%c[%d;%dH",27,1,1);                    //把光标跳至第i行第j列
		    for(j=0;j<i-x;j++)
                if(com[j]=='\n')printf("\n");
                else printf("%c",com[j]);
        }
        else {
        }
    }
    return;
}
void paint(int x,int y,int z)
{	Map[x][y]=z;
}
void init()
{	nx=ny=col=ln=len=l=topr=topo=topn=0,is_down=1,ang=90;
	Mx=800,My=600;
	memset(com,0,sizeof(com));
	memset(name,0,sizeof(name));
	memset(func_place,0,sizeof(func_place));
	memset(variable_value,0,sizeof(variable_value));
	memset(topv,0,sizeof(topv));
	memset(return_stack,0,sizeof(return_stack));
	memset(oper_stack,0,sizeof(oper_stack));
	memset(num_stack,0,sizeof(num_stack));
	int i,j;for(i=0;i<Mx;i++)for(j=0;j<My;j++)paint(i,j,255);//Map[i][j]=255;
    printf("\e[1;1H\e[2J");                        //把输入移至第一行
    readAll();
	com[--len]='\0';
//printf("%c[%d;%dH",27,1,1);
}
void draw_line(int x0,int y0,int x1,int y1,int z)
{	int i,x,y,dx,dy,e;
	x0+=Mx>>1,y0+=My>>1,x1+=Mx>>1,y1+=My>>1;
	if (abs(x1-x0)>=abs(y1-y0))
	{	dx=abs(x1-x0),dy=abs(y1-y0),e=-dx;
		x=x0,y=y0;
		for(i=0;i<=dx;i++)
		{	paint(x,y,z);
			x+=x1>x0?1:-1,e+=2*dy;
			if(e>=0)y+=y1>y0?1:-1,e-=2*dx;
		}
	}
	else
	{	dx=abs(x1-x0),dy=abs(y1-y0),e=-dy;
		x=x0,y=y0;
		for(i=0;i<=dy;i++)
		{	paint(x,y,z);
			y+=y1>y0?1:-1,e+=2*dx;
			if(e>=0)x+=x1>x0?1:-1,e-=2*dy;
		}
	}
}
void skip_space()							//skip_space space and enter
{	while(l<len&&(com[l]==' '||com[l]=='\n'||com[l]=='\r'||com[l]=='\t'))l++;
}
int getname()								//get length of name(start at l)
{	int len=1;
	skip_space();
	if(com[l]>='a'&&com[l]<='z'||com[l]>='A'&&com[l]<='Z')
	{	while(com[l+len]>='a'&&com[l+len]<='z'||
			  com[l+len]>='A'&&com[l+len]<='Z'||
			  com[l+len]>='0'&&com[l+len]<='9')len++;
		return len;
	}
	else if(com[l]>='0'&&com[l]<='9')
	{	while(com[l+len]>='0'&&com[l+len]<='9')len++;
		return len;
	}
	else
	{	if(com[l]=='>'&&com[l+1]=='=')return 2;
		if(com[l]=='<'&&com[l+1]=='=')return 2;
		if(com[l]=='<'&&com[l+1]=='>')return 2;
		return len;
	}
}
int getid()							//get id of name(start at l)
{	int i,j,tmp;
	tmp=getname();
	for(i=0;i<ln;i++)
	{	int flag=1;
		for(j=0;j<tmp;j++)
			if(name[i][j]!=com[l+j])
				flag=0,j=tmp;
		if(name[i][tmp]=='\0'&&flag)
		{	l+=tmp;
			return i;
		}
	}
	for(j=0;j<tmp;j++)name[ln][j]=com[l+j];
	name[ln][tmp]='\0';
	l+=tmp;
	return ln++;
}
int getnumber()						//parse a int or variable(start at l)
{	int i,tmp,res=0;
	skip_space();
	if(com[l]==':')
	{	l++;
		tmp=getid();
		return variable_value[tmp][topv[tmp]-1];
	}
	else
	{	tmp=getname();
		for(i=0;i<tmp;i++)res=(res<<3)+(res<<1)+com[l++]-48;
		return res<<16;
	}
}
int getres(int a,int x,int b)
{	if(x==8)return (a>>8)*(b>>8);
	if(x==9)return division(a,b>>16);//a/(b>>16);
	if(x==16)return a+b;
	if(x==17)return a-b;
	if(x==24)return a>=b?1:0;
	if(x==25)return a<=b?1:0;
	if(x==26)return (a>>8)!=(b>>8)?1:0;
	if(x==27)return a>b?1:0;
	if(x==28)return a<b?1:0;
	if(x==29)return (a>>8)==(b>>8)?1:0;
	if(x==32)return (a>>8)!=0&&(b>>8)!=0?1:0;
	if(x==40)return (a>>8)!=0||(b>>8)!=0?1:0;
}
int getexpr()
{	int last_is_num=0;
	for(skip_space();;skip_space())
	{	if(!last_is_num&&(com[l]>='0'&&com[l]<='9'||com[l]==':'))
		{	num_stack[topn]=getnumber();
			topn++;
			last_is_num=1;
		}
		else if(last_is_num&&(com[l]=='*'||com[l]=='/'))//8 9
		{	while(topo>0&&(oper_stack[topo-1]>>3)<=1)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			oper_stack[topo]=com[l]=='*'?8:9;
			topo++;
			l+=1;
			last_is_num=0;
		}
		else if(last_is_num&&(com[l]=='+'||com[l]=='-'))//16 17
		{	while(topo>0&&(oper_stack[topo-1]>>3)<=2)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			oper_stack[topo]=com[l]=='+'?16:17;
			topo++;
			l+=1;
			last_is_num=0;
		}
		else if(last_is_num&&(com[l]=='>'&&com[l+1]=='='||com[l]=='<'&&com[l+1]=='='||com[l]=='<'&&com[l+1]=='>'))//24 25 26
		{	while(topo>0&&(oper_stack[topo-1]>>3)<=3)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			if(com[l]=='>'&&com[l+1]=='=')oper_stack[topo]=24;
			else if(com[l]=='<'&&com[l+1]=='=')oper_stack[topo]=25;
			else if(com[l]=='<'&&com[l+1]=='>')oper_stack[topo]=26;
			topo++;
			l+=2;
			last_is_num=0;
		}
		else if(last_is_num&&(com[l]=='>'||com[l]=='<'||com[l]=='='))//27 28 29
		{	while(topo>0&&(oper_stack[topo-1]>>3)<=3)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			if(com[l]=='>')oper_stack[topo]=27;
			else if(com[l]=='<')oper_stack[topo]=28;
			else if(com[l]=='=')oper_stack[topo]=29;
			topo++;
			l+=1;
			last_is_num=0;
		}
		else if(last_is_num&&(getname()==3&&com[l]=='a'&&com[l+1]=='n'&&com[l+2]=='d'))//32
		{	while(topo>0&&(oper_stack[topo-1]>>3)<=4)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			oper_stack[topo]=32;
			topo++;
			l+=3;
			last_is_num=0;
		}
		else if(last_is_num&&(getname()==2&&com[l]=='o'&&com[l+1]=='r'))//40
		{	while(topo>0&&(oper_stack[topo-1]>>3)<=5)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			oper_stack[topo]=40;
			topo++;
			l+=2;
			last_is_num=0;
		}
		else if(!last_is_num&&com[l]=='(')//48
		{	oper_stack[topo]=48;
			topo++;
			l+=1;
			last_is_num=0;
		} 
		else if(last_is_num&&com[l]==')')//49
		{	while(topo>0&&oper_stack[topo-1]!=48)
			{	int tmp;
				tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
				topo--;
				topn--;
				num_stack[topn-1]=tmp;
			}
			topo--;
			l+=1;
			last_is_num=1;
		}
		else break;
	}
	while(topo>0)
	{	int tmp;
		tmp=getres(num_stack[topn-2],oper_stack[topo-1],num_stack[topn-1]);
		topo--;
		topn--;
		num_stack[topn-1]=tmp;
	}
	topn--;
	return num_stack[0];
}
void getcomm()
{	int i,j,tmp;
	tmp=getname();
	if(tmp==1)
	{	if(com[l]=='[')
		{	l++;
			while(com[l]!=']')
				getcomm(),skip_space();
			l++;
			return;
		}
	}
	else if(tmp==2)
	{	if(com[l]=='f'&&com[l+1]=='d')
		{	l+=2;
			int x,tmpx,tmpy;
			x=getexpr();
			tmpx=nx,tmpy=ny;
            if(x>=(1<<23))
            {   nx+=(x>>16)*Cos[ang];
			    ny+=(x>>16)*Sin[ang];
            }
			else
            {   nx+=(x>>8)*Cos[ang]>>8;
			    ny+=(x>>8)*Sin[ang]>>8;
            }
			if(is_down)draw_line(tmpx+32768>>16,tmpy+32768>>16,nx+32768>>16,ny+32768>>16,col);
			return;
		}
		else if(com[l]=='b'&&com[l+1]=='k')
		{	l+=2;
			int x,tmpx,tmpy;
			x=getexpr();
			tmpx=nx,tmpy=ny;
            if(x>=(1<<23))
            {   nx-=(x>>16)*Cos[ang];
			    ny-=(x>>16)*Sin[ang];
            }
			else
            {   nx-=(x>>8)*Cos[ang]>>8;
			    ny-=(x>>8)*Sin[ang]>>8;
            }
			if(is_down)draw_line(tmpx+32768>>16,tmpy+32768>>16,nx+32768>>16,ny+32768>>16,col);
			return;
		}
		else if(com[l]=='r'&&com[l+1]=='t')
		{	l+=2;
			int x;
			x=getexpr();
			ang-=(x>>16);
			while(ang<0)ang+=360;
			while(ang>=360)ang-=360;
			return;
		}
		else if(com[l]=='l'&&com[l+1]=='t')
		{	l+=2;
			int x;
			x=getexpr();
			ang+=(x>>16);
			while(ang<0)ang+=360;
			while(ang>=360)ang-=360;
			return;
		}
		else if(com[l]=='i'&&com[l+1]=='f')
		{	l+=2;
			int x;
			x=getexpr();
			if(getname()==4&&com[l]=='t'&&com[l+1]=='h'&&com[l+2]=='e'&&com[l+3]=='n')
			{	l+=4;
				if(x!=0)
				{	while((getname()!=4||com[l]!='e'||com[l+1]!='l'||com[l+2]!='s'||com[l+3]!='e')&&
						  (getname()!=5||com[l]!='e'||com[l+1]!='n'||com[l+2]!='d'||com[l+3]!='i'||com[l+4]!='f'))
						getcomm();
					if(getname()==4&&com[l]=='e'&&com[l+1]=='l'&&com[l+2]=='s'&&com[l+3]=='e')
					{	l+=4;
						while(getname()!=5||com[l]!='e'||com[l+1]!='n'||com[l+2]!='d'||com[l+3]!='i'||com[l+4]!='f')
							l+=getname();
					}
					l+=5;
				}
				else
				{	while((getname()!=4||com[l]!='e'||com[l+1]!='l'||com[l+2]!='s'||com[l+3]!='e')&&
						  (getname()!=5||com[l]!='e'||com[l+1]!='n'||com[l+2]!='d'||com[l+3]!='i'||com[l+4]!='f'))
						l+=getname();
					if(getname()==4&&com[l]=='e'&&com[l+1]=='l'&&com[l+2]=='s'&&com[l+3]=='e')
					{	l+=4;
						while(getname()!=5||com[l]!='e'||com[l+1]!='n'||com[l+2]!='d'||com[l+3]!='i'||com[l+4]!='f')
							getcomm();
					}
					l+=5;
				}
			}
			return;
		}
        else if(com[l]=='p'&&com[l+1]=='u')
		{	l+=2;
			is_down=0;
			return;
		}
        else if(com[l]=='p'&&com[l+1]=='d')
		{	l+=2;
			is_down=1;
			return;
		}
	}
	else if(tmp==3)
	{	if(com[l]=='e'&&com[l+1]=='n'&&com[l+2]=='d')
		{	for(i=0;i<lv[topr-1];i++)
				topv[tmp_variable[topr-1][i]]--;
			lv[topr-1]=0;
			l=return_stack[--topr];
			return;
		}
	}
	else if(tmp==4)
	{	if(com[l]=='m'&&com[l+1]=='a'&&com[l+2]=='k'&&com[l+3]=='e')
		{	l+=4;
			skip_space();
			//com[l]=='"'
			l++;
			tmp=getid();
			int x;
			x=getexpr();
			variable_value[tmp][topv[tmp]-1]=x;
			return;
		}
	}
	else if(tmp==5)
	{	if(com[l]=='c'&&com[l+1]=='o'&&com[l+2]=='l'&&com[l+3]=='o'&&com[l+4]=='r')
		{	l+=5;
			skip_space();
			int x;
			x=getexpr();
			col=(x>>16);
			return;
		}
	}
	else if(tmp==6)
	{	if(com[l]=='r'&&com[l+1]=='e'&&com[l+2]=='p'&&com[l+3]=='e'&&com[l+4]=='a'&&com[l+5]=='t')
		{	l+=6;
			skip_space();
			int x;
			x=getexpr();
			skip_space();
			int tmpl=l; 
			for(i=0;i<(x>>16);i++)
			{	l=tmpl;
				getcomm();
			}
			return;
		}
	}
	tmp=getid();
	return_stack[topr++]=l;
	l=func_place[tmp];
	while(getname()==1&&com[l]==':')
	{	l++; 
		tmp=getid();
		tmp_variable[topr-1][lv[topr-1]++]=tmp;
		int x,tmpl;
		tmpl=l;
		l=return_stack[topr-1];
		x=getexpr();
		return_stack[topr-1]=l;
		l=tmpl;
		variable_value[tmp][topv[tmp]++]=x;
	}
}
void getfunc()
{	l+=2;
	skip_space();
	int x=getid();
	skip_space();
	func_place[x]=l;
	while(getname()!=3||com[l]!='e'||com[l+1]!='n'||com[l+2]!='d')l+=getname();
	l+=getname();
	return;
}
void work()
{	skip_space();
	if(getname()==2&&com[l]=='t'&&com[l+1]=='o')getfunc();
	else getcomm();
}
int main(int argc, char **argv)
{   init();
	for(skip_space();l<len;)work(),skip_space();
	op();
	return 0;
}
