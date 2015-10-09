#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <malloc.h>
#include <ctype.h>
#include <math.h>
#include <unistd.h>
#include <signal.h>


#include "chin_lib.h"

#define NUC_COD_NO 182
static int comp_nt2aa(const void *,const void *);

typedef struct tran_node{
   int idx;
   char nt[4];
   char aa;
} TRAN_NODE;

static char Qty_table[130]={100,100,100,100,100,100,100, 91,100,100,
                            100,100,100,100, 92, 93, 94, 95, 96, 97,
                            100,100,100,100,100,100,100,100,100,100,
                            100,100,100, 98, 99, 78, 79, 80, 81, 82,
                             83, 84, 85, 86, 87, 88, 89, 90,  0,  1,
                              2,  3,  4,  5,  6,  7,  8,  9, 10, 11,
                             12, 13,100, 14, 15, 16, 17, 18, 19, 20,
                             21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
                             31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
                             41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
                             51, 52, 53, 54, 55, 56, 57, 58, 59, 60,
                             61, 62, 63, 64, 65, 66, 67, 68, 69, 70,
                             71, 72, 73, 74, 75, 76, 77,100,100,100};

/* 00 0 01 1   02 2  03 3  04 4   05 5   06 6   07 7   08 8 09 9 */
/* 10 : 11 ;   12 <  13 =  14 ?   15 @   16 A   17 B   18 C 19 D */
/* 20 E 21 F   22 G  23 H  24 I   25 J   26 K   27 L   28 M 29 N */
/* 30 O 31 P   32 Q  33 R  34 S   35 T   36 U   37 V   38 W 39 X */
/* 40 Y 41 Z   42 [  43 \  44 ]   45 ^   46 _   47 `   48 a 49 b */
/* 50 c 51 d   52 e  53 f  54 g   55 h   56 i   57 j   58 k 59 l */
/* 60 m 61 n   62 o  63 p  64 q   65 r   66 s   67 t   68 u 69 v */
/* 70 w 71 x   72 y  73 z  74 {   75 |   76 }   77 ~   78 # 79 $ */
/* 80 % 81 &   82 '  83 (  84 )   85 *   86 +   87 ,   88 - 89 . */
/* 90 / 91 BEL 92 SO 93 SI 94 DLE 95 DC1 96 DC2 97 DC3 98 ! 99 " */

static TRAN_NODE Tran_table[NUC_COD_NO] = {
   {    0,"AAA",'K'}, {    2,"AAC",'N'}, {    6,"AAG",'K'}, {   17,"AAR",'K'},
   {   19,"AAT",'N'}, {   24,"AAY",'N'}, {   52,"ACA",'T'}, {   53,"ACB",'T'},
   {   54,"ACC",'T'}, {   55,"ACD",'T'}, {   58,"ACG",'T'}, {   59,"ACH",'T'},
   {   62,"ACK",'T'}, {   64,"ACM",'T'}, {   65,"ACN",'T'}, {   69,"ACR",'T'},
   {   70,"ACS",'T'}, {   71,"ACT",'T'}, {   73,"ACV",'T'}, {   74,"ACW",'T'},
   {   76,"ACY",'T'}, {  156,"AGA",'R'}, {  158,"AGC",'S'}, {  162,"AGG",'R'},
   {  173,"AGR",'R'}, {  175,"AGT",'S'}, {  180,"AGY",'S'}, {  494,"ATA",'I'},
   {  496,"ATC",'I'}, {  500,"ATG",'M'}, {  501,"ATH",'I'}, {  506,"ATM",'I'},
   {  513,"ATT",'I'}, {  516,"ATW",'I'}, {  518,"ATY",'I'}, { 1352,"CAA",'Q'},
   { 1354,"CAC",'H'}, { 1358,"CAG",'Q'}, { 1369,"CAR",'Q'}, { 1371,"CAT",'H'},
   { 1376,"CAY",'H'}, { 1404,"CCA",'P'}, { 1405,"CCB",'P'}, { 1406,"CCC",'P'},
   { 1407,"CCD",'P'}, { 1410,"CCG",'P'}, { 1411,"CCH",'P'}, { 1414,"CCK",'P'},
   { 1416,"CCM",'P'}, { 1417,"CCN",'P'}, { 1421,"CCR",'P'}, { 1422,"CCS",'P'},
   { 1423,"CCT",'P'}, { 1425,"CCV",'P'}, { 1426,"CCW",'P'}, { 1428,"CCY",'P'},
   { 1508,"CGA",'R'}, { 1509,"CGB",'R'}, { 1510,"CGC",'R'}, { 1511,"CGD",'R'},
   { 1514,"CGG",'R'}, { 1515,"CGH",'R'}, { 1518,"CGK",'R'}, { 1520,"CGM",'R'},
   { 1521,"CGN",'R'}, { 1525,"CGR",'R'}, { 1526,"CGS",'R'}, { 1527,"CGT",'R'},
   { 1529,"CGV",'R'}, { 1530,"CGW",'R'}, { 1532,"CGY",'R'}, { 1846,"CTA",'L'},
   { 1847,"CTB",'L'}, { 1848,"CTC",'L'}, { 1849,"CTD",'L'}, { 1852,"CTG",'L'},
   { 1853,"CTH",'L'}, { 1856,"CTK",'L'}, { 1858,"CTM",'L'}, { 1859,"CTN",'L'},
   { 1863,"CTR",'L'}, { 1864,"CTS",'L'}, { 1865,"CTT",'L'}, { 1867,"CTV",'L'},
   { 1868,"CTW",'L'}, { 1870,"CTY",'L'}, { 4056,"GAA",'E'}, { 4058,"GAC",'D'},
   { 4062,"GAG",'E'}, { 4073,"GAR",'E'}, { 4075,"GAT",'D'}, { 4080,"GAY",'D'},
   { 4108,"GCA",'A'}, { 4109,"GCB",'A'}, { 4110,"GCC",'A'}, { 4111,"GCD",'A'},
   { 4114,"GCG",'A'}, { 4115,"GCH",'A'}, { 4118,"GCK",'A'}, { 4120,"GCM",'A'},
   { 4121,"GCN",'A'}, { 4125,"GCR",'A'}, { 4126,"GCS",'A'}, { 4127,"GCT",'A'},
   { 4129,"GCV",'A'}, { 4130,"GCW",'A'}, { 4132,"GCY",'A'}, { 4212,"GGA",'G'},
   { 4213,"GGB",'G'}, { 4214,"GGC",'G'}, { 4215,"GGD",'G'}, { 4218,"GGG",'G'},
   { 4219,"GGH",'G'}, { 4222,"GGK",'G'}, { 4224,"GGM",'G'}, { 4225,"GGN",'G'},
   { 4229,"GGR",'G'}, { 4230,"GGS",'G'}, { 4231,"GGT",'G'}, { 4233,"GGV",'G'},
   { 4234,"GGW",'G'}, { 4236,"GGY",'G'}, { 4550,"GTA",'V'}, { 4551,"GTB",'V'},
   { 4552,"GTC",'V'}, { 4553,"GTD",'V'}, { 4556,"GTG",'V'}, { 4557,"GTH",'V'},
   { 4560,"GTK",'V'}, { 4562,"GTM",'V'}, { 4563,"GTN",'V'}, { 4567,"GTR",'V'},
   { 4568,"GTS",'V'}, { 4569,"GTT",'V'}, { 4571,"GTV",'V'}, { 4572,"GTW",'V'},
   { 4574,"GTY",'V'}, { 8268,"MGA",'R'}, { 8274,"MGG",'R'}, { 8285,"MGR",'R'},
   {11494,"RAC",'B'}, {11511,"RAT",'B'}, {11516,"RAY",'B'}, {12168,"SAA",'Z'},
   {12174,"SAG",'Z'}, {12185,"SAR",'Z'}, {12844,"TAA",'$'}, {12846,"TAC",'Y'},
   {12850,"TAG",'$'}, {12861,"TAR",'$'}, {12863,"TAT",'Y'}, {12868,"TAY",'Y'},
   {12896,"TCA",'S'}, {12897,"TCB",'S'}, {12898,"TCC",'S'}, {12899,"TCD",'S'},
   {12902,"TCG",'S'}, {12903,"TCH",'S'}, {12906,"TCK",'S'}, {12908,"TCM",'S'},
   {12909,"TCN",'S'}, {12913,"TCR",'S'}, {12914,"TCS",'S'}, {12915,"TCT",'S'},
   {12917,"TCV",'S'}, {12918,"TCW",'S'}, {12920,"TCY",'S'}, {13000,"TGA",'$'},
   {13002,"TGC",'C'}, {13006,"TGG",'W'}, {13019,"TGT",'C'}, {13024,"TGY",'C'},
   {13286,"TRA",'$'}, {13338,"TTA",'L'}, {13340,"TTC",'F'}, {13344,"TTG",'L'},
   {13355,"TTR",'L'}, {13357,"TTT",'F'}, {13362,"TTY",'F'}, {16718,"YTA",'L'},
   {16724,"YTG",'L'}, {16735,"YTR",'L'}
};


/* Skip all blank lines and read next non-blank line. */
/* Also trim the white spaces at the end of the line. */
/* return: length of the line. 0: end of file         */
int nexttext(char *a,FILE *in)
{
   int i;
   *a='\0';
   i=0;
   while(fgets(a,MAX_INPUT_LENGTH,in)!=NULL)
      if((i=trimr(a))!=0)break;
   return(i);
}

/* Read the next line and trim the white spaces at the end of the line. */
/* return: length of the line. -1: end of file                          */
int nextline(char *a,FILE *in)
{
   *a='\0';
   if(fgets(a,MAX_INPUT_LENGTH,in)==NULL)
      return(-1);
   return(trimr(a));
}

/* Trim life and right white spaces of a string */
/* return: the length of the string             */
int pack(char *a)
{
   trimr(a);
   return(triml(a));
}

/* Trim right white spaces of a string */
/* return: the length of the string    */
int trimr(char *a)
{
   char *b;
   if(!a)return(-1);
   b=a;
   while(*b)b++;
   b--;
   while(b>=a&&(*b==' '||*b=='\t'||*b=='\n'||*b=='\r'))b--;
   *(++b)='\0';
   return((int)(b-a));
}

/* Trim left white spaces of a string */
/* return: the length of the string   */
int triml(char *a)
{
   char *b,*c;
   if(!a)return(-1);
   b=c=a;
   while(*c!='\0'&&(*c==' '||*c=='\t'||*c=='\n'||*c=='\r'))c++;
   while(*c!='\0')*(b++)=*(c++);
   *b='\0';
   return((int)(b-a));
}

/* Check if string s is an integer                                 */
/* leading and tailing white spaces are ignored.                   */
/* return value:                                                   */
/*   0: not an integer                                             */
/*   1: integer without comma: 1234 +1234 -1234 0 +0 -0            */
/*   2: integer with comma in proper position: 1,234 +1,234 -1,234 */
int isinteger(char *s)
{int len,i;
 char *p,*q,*r;
  if(s==NULL)return(0);
  p=strdup(s);pack(p);q=p;if((*q)=='+'||(*q)=='-')q++;len=strlen(q);if(len==0){free(p);return(0);}
  i=strspn(q,"0123456789");if(i==len){free(p);return(1);} /* all digits */
  i=strspn(q,",0123456789");if(i!=len){free(p);return(0);} /* contains invalid characters */
  if((*q)==','){free(p);return(0);} /* leading comma */
  r=strrchr(q,',');
  while(r!=NULL){
    if((len-(r-q))%4!=0){free(p);return(0);} /* comma not in proper position */
    (*r)=' ';r=strrchr(q,',');
  }
  for(r=q+len-4;r>=q;r=r-4){if((*r)!=' '){free(p);return(0);}} /* miss , */
  free(p);return(2); /* comma in proper position */
}

/* check if string s is a pure real               */
/* leading and tailing white spaces are ignored.  */
/* a pure real: (1) with a decimal point, and     */
/*              (2) without e nor E, and          */
/*              (3) with or without comma         */
/* return value:                                  */
/*   0: not a pure real                           */
/*   1: pure real without comma                   */
/*   2: pure real with comma in proper position   */
int ispurereal(char *s)
{int len,i;
 char *p,*q,*r;
  if(s==NULL)return(0);
  p=strdup(s);pack(p);q=p;if((*q)=='+'||(*q)=='-')q++;len=strlen(q);if(len==0){free(p);return(0);}
  i=strspn(q,".,0123456789");if(i!=len){free(p);return(0);} /* contains invalid characters */
  r=strchr(q,'.');if(r==NULL){free(p);return(0);} /* no decimal point */
  if(r==q){i=isinteger(r+1);if(i==1){free(p);return(1);}free(p);return(0);}
  if((*(r+1))=='\0'){(*r)='\0';i=isinteger(q);free(p);return(i);}
  i=isinteger(r+1);if(i!=1){free(p);return(0);}
  (*r)='\0';i=isinteger(q);free(p);return(i);
}

/* check if string s is an exp real               */
/* leading and tailing white spaces are ignored.  */
/* a exp real: (1) with e or E, and               */
/*             (2) without comma                  */
/* return value:                                  */
/*   0: not an exp real                           */
/*   1: an exp real                               */
int isexpreal(char *s)
{int len,i;
 char *p,*q,*r;
  if(s==NULL)return(0);p=strdup(s);pack(p);q=p;len=strlen(q);
  i=strspn(q,"+-.eE0123456789");if(i!=len){free(p);return(0);} /* contains invalid characters */
  r=strchr(q,'e');if(r==NULL)r=strchr(q,'E');
  if(r==NULL){free(p);return(0);} /* no e nor E found */
  if(isinteger(r+1)!=1){free(p);return(0);} /* exp part is not a pure integer */
  if(r==q){free(p);return(1);} /* e-5 E+1 */
  if(r==q+1&&((*q)=='+'||(*q)=='-')){free(p);return(1);} /* +e-5 -e-5 */
  (*r)='\0';if(ispurereal(q)!=1){free(p);return(0);} /* real part is not a pure real */
  free(p);return(1);
}

/* check if string s is a number                                   */
/* leading and tailing white spaces are ignored.                   */
/* return value:                                                   */
/*   0: invalid value                                              */
/*   1: integer without comma: 1234 +1234 -1234 0 +0 -0            */
/*   2: integer with comma in proper position: 1,234 +1,234 -1,234 */
/*   3: pure real without comma                                    */
/*   4: pure real with comma in proper position                    */
/*   5: an exp real                                                */
int isanumber(char *s)
{int i;
  i=isinteger(s);if(i==1)return(1);if(i==2)return(2);
  i=ispurereal(s);if(i==1)return(3);if(i==2)return(4);
  i=isexpreal(s);if(i==1)return(5);return(0);
}

/* same as atoi(1), but string s may contain commas */
int a2i(char *s)
{
   char t[100],*p,*q;
   int i;

   p=s;
   q=t;
   while(*p){
      if((*p)!=',') *(q++)=(*p); /* ignore commas */
      p++;
   }
   *q='\0';
   i=atoi(t);
   return i;
}

/* same as atol(1), but string s may contain commas */
long a2l(char *s)
{
   char t[100],*p,*q;
   long i;

   p=s;
   q=t;
   while(*p){
      if((*p)!=',') *(q++)=(*p); /* ignore commas */
      p++;
   }
   *q='\0';
   i=atol(t);
   return i;
}

/* same as atof(1), but handle E-10 and commas */
double a2f(char *s)
{
   char x[MAX_INPUT_LENGTH],y[MAX_INPUT_LENGTH],*p,*q;
   double f;
   if(s[0]=='e'||s[0]=='E'){
      strcpy(x,"1");
      strcat(x,s);
   } else strcpy(x,s);
   p=x;
   q=y;
   while(*p){
      if((*p)!=',')*(q++)=(*p); /* ignore commas */
      p++;
   }
   *q='\0';
   f=atof(y);
   return(f);
}

/* reverse string s */
void strrev(char *s)
{
   char c,*p,*q;
   p=q=s;
   while(*q!='\0')q++;
   q--;
   while(p<q){
      c=*p;
      *p++=*q;
      *q--=c;
   }
}

/* Return the length of the last segment of string s1 that   */
/* consists entirely of characters not from string s2.       */
/*                                                           */
/* example:                                                  */
/* s1=abcdwxyz                                               */
/* s2=cde                                                    */
/* strcspn=2 strrcspn=4                                      */
int strrcspn(char *s1,char *s2)
{int i,len;
 char *pt;

  if(s1==NULL||s2==NULL)return(-1);len=strlen(s1);
  for(i=len-1;i>=0;i--){
    pt=strchr(s2,s1[i]);
    if(pt!=NULL)break;
  }return(len-i-1);
}

/* Return the length of the last segment of string s1   */
/* that consists entirely of characters from string s2. */
/*                                                      */
/* example:                                             */
/* s1=abcdwxyz                                          */
/* s2=abxyz                                             */
/* strspn=2 strrspn=4                                   */
int strrspn(char *s1,char *s2)
{int i,len;
 char *pt;

  if(s1==NULL||s2==NULL)return(-1);len=strlen(s1);
  for(i=len-1;i>=0;i--){
    pt=strchr(s2,s1[i]);
    if(pt==NULL)break;
  }return(len-i-1);
}

/* rotate string s for x position        */
/*   x: positive, right rotate           */
/*      negative, left rotate            */
char *strrot(char *s,int x)
{ int i,len;
  char *buf;

  if(s==NULL)return(NULL);
  len=strlen(s);if(len==0||len==1)return(s);
  if(x>=0)i=1;else{i=0;x=0-x;}x=x%len;if(x==0)return(s);if(i==0)x=len-x;
  buf=(char *)malloc((size_t)((len+1)*sizeof(char)));
  for(i=0;i<len;i++)buf[(i+x)%len]=s[i];
  for(i=0;i<len;i++)s[i]=buf[i];
  free(buf);
  return(s);
}

/* point to the last occurrence of s2 in string s1 */
/* return NULL if s2 is not found in s1            */
char *strrstr(char *s1,const char *s2)
{
   char *pt,*nx,*s0;
   pt=NULL;
   s0=s1;
   while((nx=strstr(s0,s2))!=NULL){
      pt=nx;
      s0++;
   }
   return(pt);
}

/* same as strstr but case insensative */
char *strcasestr(char *s1,char *s2)
{
   char *t1,*t2,*pt;
   t1=strdup(s1);
   for(pt=t1;(*pt)!='\0';pt++)
     (*pt)=toupper(*pt);
   t2=strdup(s2);
   for(pt=t2;(*pt)!='\0';pt++)
     (*pt)=toupper(*pt);
   pt=strstr(t1,t2);
   if(pt!=NULL)pt=s1+(pt-t1);
   free(t1);
   free(t2);
   return(pt);
}

/* same as strrstr but case insensative */
char *strcaserstr(char *s1,char *s2)
{
   char *t1,*t2,*pt;
   t1=strdup(s1);
   for(pt=t1;(*pt)!='\0';pt++)(*pt)=toupper(*pt);
   t2=strdup(s2);
   for(pt=t2;(*pt)!='\0';pt++)(*pt)=toupper(*pt);
   pt=strrstr(t1,t2);
   if(pt!=NULL)pt=s1+(pt-t1);
   free(t1);
   free(t2);
   return(pt);
}

/* convert to uppercase */
char *strtoupper(char *s)
{
   char *pt;
   if(s==NULL)return(NULL);
   for(pt=s;(*pt)!='\0';pt++)(*pt)=toupper(*pt);
   return(s);
}

/* convert to lowercase */
char *strtolower(char *s)
{
   char *pt;
   if(s==NULL)return(NULL);
   for(pt=s;(*pt)!='\0';pt++)(*pt)=tolower(*pt);
   return(s);
}

char *strtoken(char *a,const char *b)
{
   char *p,*q,*r; /* memory leak: if a doesn't contain b and a is full */

   if(a==NULL)return(NULL);
   p=a+strspn(a,b);
   if(*p=='\0')return(NULL);
   q=strpbrk(p,b);
   if(q==NULL){
      if(p==a){
         p=a+strlen(a);
         while(p>=a){
            *(p+1)=*p;
            p--;
         }
         *a='\0';
         return(a+1);
      }
      if(p>a+1){
         q=a+1;
         while(*p!='\0')*q++=*p++;
         *q='\0';
      }
      *a='\0';
      return(a+1);
   }
   r=q+strspn(q,b);
   *q='\0';
   if(*r=='\0'){
      if(p==a){
         p++;
         while(q>=a){
            *(q+1)=*q;
            q--;
         }
      }
      *a='\0';
      return(p);
   }
   q=strdup(p);
   p=a;
   while(*r!='\0')*p++=*r++;
   *p++='\0';
   strcpy(p,q);
   free(q);
   return(p);
}

char *strsimpletoken(char *a,char *b)
{
   char *p,*q,*r; /* memory leak: if a doesn't contain b and a is full */
   /* handle something like "///1234/" */

   if(a==NULL)return(NULL);
   if(*a=='\0')return(NULL);
   p=strpbrk(a,b);
   if(p==NULL){
      p=a+strlen(a);
      while(p>=a){
         *(p+1)=*p;
         p--;
      }
      *a='\0';
      return(a+1);
   }
   q=p+1;
   *p='\0';
   if(*q=='\0'){
      while(p>=a){
         *(p+1)=*p;
         p--;
      }
      *a='\0';
      return(a+1);
   }
   p=strdup(a);
   r=a;
   while(*q)*r++=*q++;
   *r++='\0';
   strcpy(r,p);
   free(p);
   return(r);
}

/* replace all "b" to "c" in string "a"               */
/* if "c" is an empty string, all "b" will be removed */
int strreplace(char *a,char *b,char *c)
{
   char *pt,*p,*q,*tmpspc;
   int bl,cl,ct;

   bl=strlen(b);
   cl=strlen(c);
   pt=a;
   ct=0;
   if(bl==cl){
      while((p=strstr(pt,b))!=NULL){
         ct++;
         q=c;
         while(*q)*p++=*q++;
         pt=p;
      }
      return(ct);
   }
   if((q=strstr(pt,b))==NULL)return(0);
   ct++;
   if(bl<cl)tmpspc=pt=strdup(q+bl);
   else pt=q+bl;
y:
   p=c;
   while(*p)*q++=*p++;
   if((p=strstr(pt,b))!=NULL){
      ct++;
      while(pt!=p)*q++=*pt++;
      pt=p+bl;
      goto y;
   }
   while(*pt!='\0')*q++=*pt++;
   *q='\0';
   if(bl<cl)free(tmpspc);
   return(ct);
}

/* same as strreplace but case insensative in searching "b" */
int strcasereplace(char *a,char *b,char *c)
{
   char *pt,*p,*q,*tmpspc;
   int bl,cl,ct;

   bl=strlen(b);
   cl=strlen(c);
   pt=a;
   ct=0;
   if(bl==cl){
      while((p=strcasestr(pt,b))!=NULL){
         ct++;
         q=c;
         while(*q)*p++=*q++;
         pt=p;
      }
      return(ct);
   }
   if((q=strcasestr(pt,b))==NULL)return(0);
   ct++;
   if(bl<cl)tmpspc=pt=strdup(q+bl);
   else pt=q+bl;
y:
   p=c;
   while(*p)*q++=*p++;
   if((p=strcasestr(pt,b))!=NULL){
      ct++;
      while(pt!=p)*q++=*pt++;
      pt=p+bl;
      goto y;
   }
   while(*pt!='\0')*q++=*pt++;
   *q='\0';
   if(bl<cl)free(tmpspc);
   return(ct);
}

char **strsplit(char *a,char *b,int *count)
{
   static int max_item=20,lgh,i;
   static char **buf=NULL,*pt;

   (*count)=0;if(a==NULL)return(NULL);pt=a;
   if(buf==NULL){
     buf=(char **)malloc((size_t)(max_item*sizeof(char *)));
     for(lgh=0;lgh<max_item;lgh++)buf[lgh]=NULL;
   }
   while(*pt!='\0'){
      lgh=strcspn(pt,b);
      if((*count)==max_item-2){
         buf=(char **)realloc(buf,(size_t)((max_item<<1)*sizeof(char *)));
         for(i=max_item;i<max_item<<1;i++)buf[i]=NULL;max_item<<=1;
      }
      if(buf[*count]!=NULL)free(buf[*count]);
      buf[*count]=(char *)malloc((size_t)(lgh+1));
      strncpy(buf[*count],pt,lgh);
      buf[*count][lgh]='\0';
      (*count)++;
      pt+=lgh;
      lgh=strspn(pt,b);
      pt+=lgh;
   }
   if(buf[*count]!=NULL)free(buf[*count]);buf[*count]=NULL;
   return(buf);
}

char **strsimplesplit(char *a,char *b,int *count)
{
   static int max_item=20,lgh,i;
   static char **buf=NULL,*pt;

   (*count)=0;if(a==NULL)return(NULL);pt=a;
   if(buf==NULL){
     buf=(char **)malloc((size_t)(max_item*sizeof(char *)));
     for(lgh=0;lgh<max_item;lgh++)buf[lgh]=NULL;
   }
   while(*pt!='\0'){
      lgh=strcspn(pt,b);
      if((*count)>=max_item-2){
         buf=(char **)realloc(buf,(size_t)((max_item<<1)*sizeof(char *)));
         for(i=max_item;i<max_item<<1;i++)buf[i]=NULL;max_item<<=1;
      }
      if(buf[*count]!=NULL)free(buf[*count]);
      buf[*count]=(char *)malloc((size_t)(lgh+1));
      strncpy(buf[*count],pt,lgh);
      buf[*count][lgh]='\0';
      (*count)++;
      pt+=lgh;
      if((*pt)!='\0'){
        pt++;
        if((*pt)=='\0'){if(buf[*count]!=NULL)free(buf[*count]);buf[*count]=strdup("");(*count)++;break;}
      }
   }
   if(buf[*count]!=NULL)free(buf[*count]);buf[*count]=NULL;
   return(buf);
}

void to_fasta(FILE *fp,char *desc,char *seq)
{ 
   int i;
   char *p;
   pack(desc);
   if(seq==NULL)return;
   if(desc[0]!='>')fprintf(fp,">%s",desc);
   else fprintf(fp,"%s",desc);
   for(p=seq,i=LENGTH_PER_LINE;*p;p++,i++){
      if(i==LENGTH_PER_LINE){
         fputc('\n',fp);
         i=0;
      }
      fputc(*p,fp);
   }
   fputc('\n',fp);
   fflush(fp);
}

void to_qual(FILE *fp,char *desc,char *qt,int lgh)
{ 
   int i,j;
   char *p;
   pack(desc);
   if(desc[0]!='>')fprintf(fp,">%s",desc);
   else fprintf(fp,"%s",desc);
   for(p=qt,i=LENGTH_PER_LINE,j=0;j<lgh;p++,i++,j++){
      while(*p=='|')p++;
      if(i==LENGTH_PER_LINE){
         i=0;
         fprintf(fp,"\n%d",(int)(*p));
      }
      else fprintf(fp," %d",(int)(*p));
   }
   fputc('\n',fp);
   fflush(fp);
}

/***************************************************/
/* Convert an alignment to CIGAR format (for SAM ) */
/***************************************************/
int align_to_cigar(char *qsq,char *hsq,char *cigar,char *md)
{char *pt1,*pt2,op,oq,a[100000],b[100000];
 int dist,count,match;

  pt1=qsq;pt2=hsq;dist=match=0;cigar[0]=md[0]='\0';
  strcpy(md,"MD:Z:");
  if((*pt1)=='\0'||(*pt2)=='\0')return(dist);
  if((*pt1)==(*pt2)){
    if((*pt1)=='-')op='P';
    else{op='M';match++;}
  }
  else if((*pt1)=='-'){
    op='D';dist++;
    sprintf(b,"%d^%c",match,(*pt2));strcat(md,b);match=0;
  }
  else if((*pt2)=='-'){
    op='I';dist++;
  }
  else {
    op='M';dist++;
    sprintf(b,"%d^%c",match,(*pt2));
    strcat(md,b);match=0;
  }
  count=1;pt1++;pt2++;
  while((*pt1)!='\0' && (*pt2)!='\0'){
    if((*pt1)==(*pt2)){
      if((*pt1)=='-')oq='P';
      else{oq='M';match++;}
    }
    else if((*pt1)=='-'){
      oq='D';dist++;
      if(op=='D'){sprintf(b,"%c",(*pt2));strcat(md,b);}
      else{sprintf(b,"%d^%c",match,(*pt2));strcat(md,b);match=0;}
    }
    else if((*pt2)=='-'){
      oq='I';dist++;
    }
    else {
      oq='M';dist++;
      sprintf(b,"%d%c",match,(*pt2));
      strcat(md,b);match=0;
    }
    if(op!=oq){sprintf(b,"%d%c",count,op);strcat(cigar,b);op=oq;count=1;}else count++;
    pt1++;pt2++;
  }
  sprintf(b,"%d%c",count,op);strcat(cigar,b);
  sprintf(b,"%d",match);strcat(md,b);
  return(dist);
}

char *nextfasta_nochange(FILE *fp,char *desc)
{
   static char *sq=NULL;
   static long mx_sq_lgh=MAX_INPUT_LENGTH,mx_ds_lgh=MAX_INPUT_LENGTH;
   char *sp,*dp;
   long sq_lgh,ds_lgh;
   int newline,c;

   /* sq will be allocated and extended by doubling the size in memory */
   if(sq==NULL)sq=(char *)malloc((size_t)mx_sq_lgh);
   sp=sq;
   if(desc==NULL)desc=(char *)malloc((size_t)mx_ds_lgh);
   dp=desc;
   sq[0]=desc[0]='\0';
   sq_lgh=ds_lgh=0;
   while((c=fgetc(fp))!=EOF&&c!='>');
   if(c==EOF)return(NULL);
   while((c=fgetc(fp))!=EOF){
      if(c=='\n'){
         newline=1;
         break;
      }
      *(dp++)=c;
      ds_lgh++;
/*
    if(ds_lgh==mx_ds_lgh){
      desc=(char *)realloc(desc,(size_t)(mx_ds_lgh<<=1));dp=desc+ds_lgh;
    }
*/
   }
   (*dp)='\0';
   if(c==EOF)return(NULL);
   while((c=fgetc(fp))!=EOF){
/*
      if(c>='A'&&c<='Z');
      else if(c>='a'&&c<='z')c+=d;
*/
      if(c=='\n'){
         newline=1;
         continue;
      }
      else if(c=='>'&&newline){
         ungetc(c,fp);
         (*sp)='\0';
         return(sq);
      }
/*
      else{
         newline=0;
         continue;
      }
      if(c=='U')c='T';
*/
      newline=0;
      *(sp++)=c;
      sq_lgh++;
      if(sq_lgh==mx_sq_lgh){
         sq=(char *)realloc(sq,(size_t)(mx_sq_lgh<<=1));
         sp=sq+sq_lgh;
      }
   }
   (*sp)='\0';
   return(sq);
}

/*****************************************************/
/* coding region SNP                                 */
/* return: 0 no amino acid changed, in coding region */
/*         1 amino acid changed                      */
/*         2 frame shift                             */
/*         3 stop before wild type                   */
/*         4 stop after wild type                    */
/*         5 5' UTR                                  */
/*         6 3' UTR                                  */
/*        -1 Error                                   */
/*****************************************************/
int csnp(char *seq,int cd_start,int cd_end,int snp_pos,char *allele,char *wild_type_aa,char *changed_aa)
{ char c;
  int k;

printf("csnp: strlen(seq)=%d\n",strlen(seq));
printf("csnp: snp_pos=%d\n",snp_pos);
fflush(stdout);

  (*wild_type_aa)=(*changed_aa)='\0';
  if(snp_pos<cd_start)return(5);
  if(snp_pos>cd_end)return(6);
  k=(snp_pos-cd_start)%3;
printf("csnp 1:%c%c%c\n",*(seq+snp_pos-k-1),*(seq+snp_pos-k),*(seq+snp_pos-k+1));fflush(stdout);
  (*wild_type_aa)=nt2aa(seq+snp_pos-k-1);
  if(strlen(allele)!=1||allele[0]=='-')return(2);
  c=allele[0];if(c!='a'&&c!='A'&&c!='c'&&c!='C'&&c!='g'&&c!='G'&&c!='t'&&c!='T')return(-1);
  seq[snp_pos-1]=c;
printf("csnp 2:%c%c%c\n",*(seq+snp_pos-k-1),*(seq+snp_pos-k),*(seq+snp_pos-k+1));fflush(stdout);
  (*changed_aa)=nt2aa(seq+snp_pos-k-1);
  if((*wild_type_aa)==(*changed_aa))return(0);
  if((*wild_type_aa)=='$')return(4);
  if((*changed_aa)=='$')return(3);
  return(1);

}

char *nextfasta(FILE *fp,char *desc)
{
   static char *sq=NULL;
   static long mx_sq_lgh=MAX_INPUT_LENGTH,mx_ds_lgh=MAX_INPUT_LENGTH;
   char *sp,*dp;
   long sq_lgh,ds_lgh;
   int newline,c,d='A'-'a';

   /* sq will be allocated and extended by doubling the size in memory */
   if(sq==NULL)sq=(char *)malloc((size_t)mx_sq_lgh);
   sp=sq;
   if(desc==NULL)desc=(char *)malloc((size_t)mx_ds_lgh);
   dp=desc;
   sq[0]=desc[0]='\0';
   sq_lgh=ds_lgh=0;
   while((c=fgetc(fp))!=EOF&&c!='>');
   if(c==EOF)return(NULL);
   while((c=fgetc(fp))!=EOF){
      if(c=='\n'){
         newline=1;
         break;
      }
      *(dp++)=c;
      ds_lgh++;
/*
    if(ds_lgh==mx_ds_lgh){
      desc=(char *)realloc(desc,(size_t)(mx_ds_lgh<<=1));dp=desc+ds_lgh;
    }
*/
   }
   (*dp)='\0';
   if(c==EOF)return(NULL);
   while((c=fgetc(fp))!=EOF){
      if(c>='A'&&c<='Z');
      else if(c>='a'&&c<='z')c+=d;
      else if(c=='\n'){
         newline=1;
         continue;
      }
      else if(c=='>'&&newline){
         ungetc(c,fp);
         (*sp)='\0';
         return(sq);
      }
      else{
         newline=0;
         continue;
      }
      if(c=='U')c='T';
      newline=0;
      *(sp++)=c;
      sq_lgh++;
      if(sq_lgh==mx_sq_lgh){
         sq=(char *)realloc(sq,(size_t)(mx_sq_lgh<<=1));
         sp=sq+sq_lgh;
      }
   }
   (*sp)='\0';
   return(sq);
}

/* Read quality values of the next sequence from file fp.                 */
/* Input: file fp                                                         */
/* Return value: the quality values will be returned in a string,         */
/*               each quality value is a byte.                            */
/*               NULL, if EOF or error.                                   */
/*         desc: description line returned.                               */
/*       qt_lgh: quality length returned. -1, if error.                   */
char *nextqual(FILE *fp,char *desc,long *qt_lgh)
{
   static char *qt=NULL;
   static long mx_qt_lgh=MAX_INPUT_LENGTH,mx_ds_lgh=MAX_INPUT_LENGTH;
   char *qp,*dp;
   long ds_lgh;
   int i,j,k,newline,c;

   /* qt will be allocated and extended by doubling the size in memory */
   if(qt==NULL)qt=(char *)malloc((size_t)mx_qt_lgh);
   qp=qt;
   if(desc==NULL)desc=(char *)malloc((size_t)mx_ds_lgh);
   dp=desc;
   qt[0]=desc[0]='\0';
   *qt_lgh=ds_lgh=0;
   while((c=fgetc(fp))!=EOF&&c!='>');
   if(c==EOF)return(NULL);
   while((c=fgetc(fp))!=EOF){
      if(c=='\n'){
         newline=1;
         break;
      }
      *(dp++)=c;
      ds_lgh++;
   }
   (*dp)='\0';
   if(c==EOF)return(NULL);
   while((c=fgetc(fp))!=EOF){
      if((c<'0'||c>'9')&&c!=' '&&c!='\n'&&c!='\r'&&c!='\t'&&c!='>'){
         *qt_lgh= -1;
         return(NULL);
      }
      if(c=='\n')newline=1;
      else if(c=='>'&&newline){
         ungetc(c,fp);
         (*qp)='\0';
         break;
      }
      else newline=0;
      *(qp++)=c;
      (*qt_lgh)++;
      if((*qt_lgh)==mx_qt_lgh){
         qt=(char *)realloc(qt,(size_t)(mx_qt_lgh<<=1));
         qp=qt+(*qt_lgh);
      }
   }
   (*qp)='\0';
   for(i=(*qt_lgh)=0,qp=qt;sscanf(qp,"%d%n",&j,&k)==1;qp+=k,i++){
      qt[i]=(char)j;
      if(qt[i]>100){*qt_lgh= -1;return(NULL);}
      (*qt_lgh)++;
   }
   return(qt);
}

void convqualhex2dec(FILE *fp1,FILE *fp2)
{
   char *pt,a[MAX_INPUT_LENGTH];
   int x;
   while(nexttext(a,fp1)>0){
      if(a[0]=='>'){
         fprintf(fp2,"%s\n",a);
         continue;
      }
      for(pt=a;*pt!='\0';pt+=2){
         sscanf(pt,"%2x",&x);
         fprintf(fp2,"%d ",x);
      }
      fprintf(fp2,"\n");
   }
   fflush(fp2);
}

void convquallifeseq2dec(FILE *fp1,FILE *fp2)
{
   char *pt,a[MAX_INPUT_LENGTH];
   while(nexttext(a,fp1)>0){
      if(a[0]=='>'){
         fprintf(fp2,"%s\n",a);
         continue;
      }
      for(pt=a;*pt!='\0';pt++){
         if(!isspace(*pt))fprintf(fp2,"%d ",Qty_table[*pt]);
      }
      fprintf(fp2,"\n");
   }
   fflush(fp2);
}

/* Remove argument s from list args.                                     */
void rm_arg(char *args,const char *s)
{
   char *p,*q,*r,*pt;
   int l;
   p=args;
   pack(p);
   l=strlen(s);
   while((pt=strstr(p,s))!=NULL){
      if(*(pt+l)=='\0'){
         (*pt)='\0';
         break;
      }
      if(*(pt+l)!=' '){
         p=pt+l;
         continue;
      }
      q=pt+l+1;
      pack(q);
      r=q;
      while((*r)!='\0'&&(*r)!=' '&&(*r)!='-')r++;
      while((*r)!='\0'&&(*r)==' ')r++;
      q=pt;
      while((*r)!='\0'){
         (*q)=(*r);
         q++;
         r++;
      }
      (*q)='\0';
      p=pt;
   }
   pack(args);
}

int aa_wt(int **mtx,char x,char y)
{ 
   x=toupper(x);
   if(x=='J'||x=='O'||x=='U')x='X';
   y=toupper(y);
   if(y=='J'||y=='O'||x=='U')y='X';
   return(mtx[(x>='A'&&x<='Z')?(x)-'A':26][(y>='A'&&y<='Z')?(y)-'A':26]);
}

void remove_html(FILE *in,FILE *out)
{
   int c,n;
   char buf[10];
   while((c=fgetc(in))!=EOF){
      n=0;
      if(c=='<'){
         while((c=fgetc(in))!=EOF&&c!='>');
         if(c==EOF)break;
         continue;
      }
      if(c!='&'){
         fputc(c,out);
         continue;
      }
      buf[n++]=c;
      c=fgetc(in);
      if(c=='l'||c=='L'){
         buf[n++]=c;
         c=fgetc(in);
         if(c=='t'||c=='T'){
            buf[n++]=c;
            c=fgetc(in);
            if(c==';'){
               fputc('<',out);
               continue;
            }
         }
         buf[n]='\0';
         fprintf(out,"%s",buf);
         fputc(c,out);
         continue;
      }
      if(c=='g'||c=='G'){
         buf[n++]=c;
         c=fgetc(in);
         if(c=='t'||c=='T'){
            buf[n++]=c;
            c=fgetc(in);
            if(c==';'){
               fputc('>',out);
               continue;
            }
         }
         buf[n]='\0';
         fprintf(out,"%s",buf);
         fputc(c,out);
         continue;
      }
      if(c=='a'||c=='A'){
         buf[n++]=c;
         c=fgetc(in);
         if(c=='m'||c=='M'){
            buf[n++]=c;
            c=fgetc(in);
            if(c=='p'||c=='P'){
               buf[n++]=c;
               c=fgetc(in);
               if(c==';'){
                  fputc('&',out);
                  continue;
               }
            }
         }
         buf[n]='\0';
         fprintf(out,"%s",buf);
         fputc(c,out);
         continue;
      }
      if(c=='q'||c=='Q'){
         buf[n++]=c;
         c=fgetc(in);
         if(c=='u'||c=='U'){
            buf[n++]=c;
            c=fgetc(in);
            if(c=='o'||c=='O'){
               buf[n++]=c;
               c=fgetc(in);
               if(c=='t'||c=='T'){
                  buf[n++]=c;
                  c=fgetc(in);
                  if(c==';'){
                     fputc('&',out);
                     continue;
                  }
               }
            }
         }
         buf[n]='\0';
         fprintf(out,"%s",buf);
         fputc(c,out);
         continue;
      }
      buf[n]='\0';
      fprintf(out,"%s",buf);
      fputc(c,out);
      continue;
   }
   fflush(out);
}

int get_cgi_s(char *line,char *name,char *val,FILE *log)
{
   char a[200];
   sprintf(a,"name=\"%s\"",name);
   if(strstr(line,a)){
      fgets(a,2000,stdin);
      fgets(val,20000,stdin);
      pack(val);
      if(log)fprintf(log,"%s\n",val);
      return(1);
   }return(0);
}

int get_cgi_i(char *line,char *name,int *val,FILE *log)
{
   char a[200];
   sprintf(a,"name=\"%s\"",name);
   if(strstr(line,a)){
      fgets(a,2000,stdin);
      fgets(a,2000,stdin);
      pack(a);
      if(log)fprintf(log,"%s\n",a);
      *val=a2i(a);
      return(1);
   }return(0);
}

int get_cgi_b(char *line,char *name,int *val,FILE *log)
{
   char a[200];
   sprintf(a,"name=\"%s\"",name);
   if(strstr(line,a)){
      fgets(a,2000,stdin);
      fgets(a,2000,stdin);
      pack(a);
      if(log)fprintf(log,"%s\n",a);
      if(strcasecmp(a,"yes")==0)*val=1;
      else *val=0;
      return(1);
   }return(0);
}

int get_cgi_f(char *line,char *name,double *val,FILE *log)
{
   char a[200];
   sprintf(a,"name=\"%s\"",name);
   if(strstr(line,a)){
      fgets(a,2000,stdin);
      fgets(a,2000,stdin);
      pack(a);
      if(log)fprintf(log,"%s\n",a);
      *val=a2f(a);
      return(1);
   }return(0);
}

/* if the child process is not killed by parent process, kill(child,SIGKIL); */
/* it will kill itself in 3 minutes                                          */
int keep_alive(void)
{
  char a[MAX_INPUT_LENGTH+MAX_INPUT_LENGTH];
  pid_t pid,parent,child;
  FILE *in;
  int i,k;

  parent=getpid();
  switch(pid=fork()) {
    case -1:
      return(-1);  /* something went wrong */
    case 0:
again:
       for(;;){
         sleep(180);
         i=kill(parent,0);
         if(i==-1)exit(0);
         printf("%c",NULL);fflush(stdout);
/*
         sprintf(a,"ps -p %d",parent);
         in=popen(a,"r");
         while(fgets(a,MAX_INPUT_LENGTH,in)!=NULL){
           k=sscanf(a,"%d",&i);
           if(k==1&&i==parent){printf("%c",NULL);fflush(stdout);pclose(in);goto again;}
         }pclose(in);exit(0);
*/
       }
    default: return(pid);
  }
}


/* Translate 3 codon nucleotide to a 1-letter amino acide code */
char nt2aa(char *nt)
{
   TRAN_NODE key,*p; /* for hashing, use 1219 */
   if(toupper(nt[2])=='X')
      key.idx=676*(toupper(nt[0])-'A')+
               26*(toupper(nt[1])-'A')+
               'N'-'A';
   else
      key.idx=676*(toupper(nt[0])-'A')+
               26*(toupper(nt[1])-'A')+
               toupper(nt[2])-'A';
   p=(TRAN_NODE *)bsearch((void *)&key,(void *)Tran_table,(size_t)NUC_COD_NO,(size_t)sizeof(TRAN_NODE),comp_nt2aa);

   if(p==NULL)return('?');
   return(p->aa);
}

static int comp_nt2aa(const void *x,const void *y)
{
   return((int)(((const TRAN_NODE *)x)->idx-((const TRAN_NODE *)y)->idx));
}

/* Translate a DNA sequence to an amino acid sequence by the specific frame */
/* Valid frame: +1, +2, +3, -1, -2, -3. return NULL for error               */
char *translate(char *seq, int frame)
{
   static char *sq=NULL;
   static long mx_sq_lgh=MAX_INPUT_LENGTH;
   char *pt,c;
   long i,k,lgh,sq_idx,off;

   /* sq will be allocated and extended by doubling the size in memory */
   if(sq==NULL)sq=(char *)malloc((size_t)mx_sq_lgh);sq[0]='\0';
   if(frame==0 || frame > 3 || frame < -3 || seq==NULL)return(NULL);

   lgh=strlen(seq);off=lgh%3;
   if(frame>0){k=frame-1;}
   else{
     for(i=0;i<lgh;i++)seq[i]=nt_comp(seq[i]);strrev(seq);
     if     (((0<<1)+off)%3+1==0-frame)k=0;
     else if(((1<<1)+off)%3+1==0-frame)k=1;
     else if(((2<<1)+off)%3+1==0-frame)k=2;
     else {return(NULL);}
   }
   for(pt=seq+(i=k),sq_idx=0;i<lgh;i+=3,pt+=3){
     if((c=nt2aa(pt))=='$')c='*';else if(c=='?')c='X';
     if(sq_idx==mx_sq_lgh-10)sq=(char *)realloc(sq,(size_t)(mx_sq_lgh<<=1));
     sq[sq_idx++]=c;
   }sq[sq_idx]='\0';
   return(sq);
}

/* Return the complement code for nucleotide 'c' */
/* Invalid code will be returned as is.          */
char nt_comp(char c)
{ 
   if(c=='a')return('t');if(c=='A')return('T');
   if(c=='c')return('g');if(c=='C')return('G');
   if(c=='g')return('c');if(c=='G')return('C');
   if(c=='t')return('a');if(c=='T')return('A');
   if(c=='n')return('n');if(c=='N')return('N');
   if(c=='x')return('x');if(c=='X')return('X');
   if(c=='u')return('a');if(c=='U')return('A');
   if(c=='m')return('k');if(c=='M')return('K');
   if(c=='r')return('y');if(c=='R')return('Y');
   if(c=='w')return('w');if(c=='W')return('W');
   if(c=='s')return('s');if(c=='S')return('S');
   if(c=='y')return('r');if(c=='Y')return('R');
   if(c=='k')return('m');if(c=='K')return('M');
   if(c=='v')return('b');if(c=='V')return('B');
   if(c=='h')return('d');if(c=='H')return('D');
   if(c=='d')return('h');if(c=='D')return('H');
   if(c=='b')return('v');if(c=='B')return('V'); return(c);
}

/* Modify and return the reverse-complement of nucleotide sequence "s"  */
/* Invalid code will be returned as '.'                                 */
char *rev_comp(char *s)
{char c,*p,*q;
 long l;

   if(s==NULL)return(NULL);
   l=strlen(s);
   for(p=s,q=s+l-1;p<q;p++,q--){
      c=nt_comp(*p);
      (*p)=nt_comp(*q);
      (*q)=c;
   }
   if(p==q)(*p)=nt_comp(*p);
   return(s);
}

/* Convert the 1 letter code to 3 letter code for amino acid 'a'.  */
/* Stop code will be returned as "Stp"                             */
/* and invalid code will be returned as "???".                     */
/* This function takes a character and returns a string.           */
const char *aa1toaa3(char a)
{ 
   if(a=='A'||a=='a')return("Ala"); if(a=='R'||a=='r')return("Arg");
   if(a=='N'||a=='n')return("Asn"); if(a=='D'||a=='d')return("Asp");
   if(a=='B'||a=='b')return("Asx"); if(a=='C'||a=='c')return("Cys");
   if(a=='Q'||a=='q')return("Gln"); if(a=='E'||a=='e')return("Glu");
   if(a=='Z'||a=='z')return("Glx"); if(a=='G'||a=='g')return("Gly");
   if(a=='H'||a=='h')return("His"); if(a=='I'||a=='i')return("Ile");
   if(a=='L'||a=='l')return("Leu"); if(a=='K'||a=='k')return("Lys");
   if(a=='M'||a=='m')return("Met"); if(a=='F'||a=='f')return("Phe");
   if(a=='P'||a=='p')return("Pro"); if(a=='S'||a=='s')return("Ser");
   if(a=='T'||a=='t')return("Thr"); if(a=='W'||a=='w')return("Trp");
   if(a=='Y'||a=='y')return("Tyr"); if(a=='V'||a=='v')return("Val");
   if(a=='$')return("Stp");
   if(a==' ')return("   ");
   else return("???");
}

const char *aa1toaa1(char a)
{ 
   if(a=='A'||a=='a')return("A"); if(a=='R'||a=='r')return("R");
   if(a=='N'||a=='n')return("N"); if(a=='D'||a=='d')return("D");
   if(a=='B'||a=='b')return("B"); if(a=='C'||a=='c')return("C");
   if(a=='Q'||a=='q')return("Q"); if(a=='E'||a=='e')return("E");
   if(a=='Z'||a=='z')return("Z"); if(a=='G'||a=='g')return("G");
   if(a=='H'||a=='h')return("H"); if(a=='I'||a=='i')return("I");
   if(a=='L'||a=='l')return("L"); if(a=='K'||a=='k')return("K");
   if(a=='M'||a=='m')return("M"); if(a=='F'||a=='f')return("F");
   if(a=='P'||a=='p')return("P"); if(a=='S'||a=='s')return("S");
   if(a=='T'||a=='t')return("T"); if(a=='W'||a=='w')return("W");
   if(a=='Y'||a=='y')return("Y"); if(a=='V'||a=='v')return("V");
   if(a=='$')return("$");
   if(a==' ')return(" ");
   else return("?");
}

/* Convert the 3 letter code to 1 letter code for amino acid "a".             */
/* Stop code will be returned as "$" and invalid code will be returned as "?" */
/* This function rakes a string and returns a string.                         */
const char *aa3toaa1(char *a)
{ 
   if(strcasecmp(a,"ala"))return("A"); if(strcasecmp(a,"arg"))return("R");
   if(strcasecmp(a,"asn"))return("N"); if(strcasecmp(a,"asp"))return("D");
   if(strcasecmp(a,"asx"))return("B"); if(strcasecmp(a,"cys"))return("C");
   if(strcasecmp(a,"gln"))return("Q"); if(strcasecmp(a,"glu"))return("E");
   if(strcasecmp(a,"glx"))return("Z"); if(strcasecmp(a,"gly"))return("G");
   if(strcasecmp(a,"his"))return("H"); if(strcasecmp(a,"ile"))return("I");
   if(strcasecmp(a,"leu"))return("L"); if(strcasecmp(a,"lys"))return("K");
   if(strcasecmp(a,"met"))return("M"); if(strcasecmp(a,"phe"))return("F");
   if(strcasecmp(a,"pro"))return("P"); if(strcasecmp(a,"ser"))return("S");
   if(strcasecmp(a,"thr"))return("T"); if(strcasecmp(a,"trp"))return("W");
   if(strcasecmp(a,"tyr"))return("Y"); if(strcasecmp(a,"val"))return("V");
   if(strcasecmp(a,"stp"))return("$"); if(strcasecmp(a,"   "))return(" ");
   else return("?");
}

/* Convert a list of nucleotide code to IUPAC code. */
const char nttont(char *a)
{
 char *p,c,sum;
  sum=0;if(a==NULL)return('.');
  for(p=a;(*p)!='\0';p++){
    c=(*p);
    if     (c=='a'||c=='A')sum|=(1);       /* A */
    else if(c=='c'||c=='C')sum|=(2);       /* C */
    else if(c=='g'||c=='G')sum|=(4);       /* G */
    else if(c=='t'||c=='T')sum|=(8);       /* T */
    else if(c=='u'||c=='U')sum|=(8);       /* U */
    else if(c=='m'||c=='M')sum|=(1+2);     /* A | C */
    else if(c=='r'||c=='R')sum|=(1+4);     /* A | G */
    else if(c=='w'||c=='W')sum|=(1+8);     /* A | T */
    else if(c=='s'||c=='S')sum|=(2+4);     /* C | G */
    else if(c=='y'||c=='Y')sum|=(2+8);     /* C | T */
    else if(c=='k'||c=='K')sum|=(4+8);     /* G | T */
    else if(c=='v'||c=='V')sum|=(1+2+4);   /* A | C | G */
    else if(c=='h'||c=='H')sum|=(1+2+8);   /* A | C | T */
    else if(c=='d'||c=='D')sum|=(1+4+8);   /* A | G | T */
    else if(c=='b'||c=='B')sum|=(2+4+8);   /* C | G | T */
    else if(c=='x'||c=='X')sum|=(1+2+4+8); /* A | C | G | T */
    else if(c=='n'||c=='N')sum|=(1+2+4+8); /* A | C | G | T */
  }
  if(sum== 1)return('A');
  if(sum== 2)return('C');
  if(sum== 3)return('M');
  if(sum== 4)return('G');
  if(sum== 5)return('R');
  if(sum== 6)return('S');
  if(sum== 7)return('V');
  if(sum== 8)return('T');
  if(sum== 9)return('W');
  if(sum==10)return('Y');
  if(sum==11)return('H');
  if(sum==12)return('K');
  if(sum==13)return('D');
  if(sum==14)return('B');
  if(sum==15)return('N');
  return('.');
}

/* Return the hydrophobicity value of the amino acid 'a'. */
/* Return -1 if 'a' is not a valid amino acid code.       */
double aa1tohydrophobicity(char a)
{ 
  if(a=='A'||a=='a')return((double)6.3); if(a=='R'||a=='r')return((double)0.0);
  if(a=='N'||a=='n')return((double)1.0); if(a=='D'||a=='d')return((double)1.0);
  if(a=='B'||a=='b')return((double)1.0); if(a=='C'||a=='c')return((double)7.0);
  if(a=='Q'||a=='q')return((double)1.0); if(a=='E'||a=='e')return((double)1.0);
  if(a=='Z'||a=='z')return((double)1.0); if(a=='G'||a=='g')return((double)4.1);
  if(a=='H'||a=='h')return((double)1.3); if(a=='I'||a=='i')return((double)9.0);
  if(a=='L'||a=='l')return((double)8.2); if(a=='K'||a=='k')return((double)0.6);
  if(a=='M'||a=='m')return((double)6.4); if(a=='F'||a=='f')return((double)7.2);
  if(a=='P'||a=='p')return((double)2.9); if(a=='S'||a=='s')return((double)3.6);
  if(a=='T'||a=='t')return((double)3.8); if(a=='W'||a=='w')return((double)3.6);
  if(a=='Y'||a=='y')return((double)3.2); if(a=='V'||a=='v')return((double)8.7);
  if(a=='X'||a=='x')return((double)4.5); else return((double)(-1));
/*

Author(s): Kyte J., Doolittle R.F. 
Reference: J. Mol. Biol. 157:105-132(1982). 

Ala:  1.800  Arg: -4.500  
Asn: -3.500  Asp: -3.500  
Cys:  2.500  Gln: -3.500  
Glu: -3.500  Gly: -0.400  
His: -3.200  Ile:  4.500  
Leu:  3.800  Lys: -3.900  
Met:  1.900  Phe:  2.800  
Pro: -1.600  Ser: -0.800  
Thr: -0.700  Trp: -0.900  
Tyr: -1.300  Val:  4.200  
*/

}

/* Print number 1 to n in the vertical way.                              */
/* Leave m space to the left in every row.                               */
/* This function is primarily used for debugging in sequence alignment.  */
/* The print out looks like this:                                        */
/*          111111111122222222223333333333444444444455555555556          */
/* 123456789012345678901234567890123456789012345678901234567890          */
void pt_index(int m,int n)
{
   int i,j,k;

   for(i=(int)log10((double)n);i>=0;i--){
      for(k=0;k<m;k++)
         printf(" ");
      for(k=1,j=0;j<i;j++)
         k*=10;
      printf(" ");
      for(j=1;j<=n;j++)
         printf("%d",(int)j/k%10);
      printf("\n");
   }
}


/**************************************************************/
/* http://www.ics.uci.edu/~dan/class/161/notes/6/Dynamic.html */
/* LONGEST COMMON SUBSTRING(A,m,B,n)                          */
/*    for i := 0 to m do Li,0 := 0                            */
/*    for j := 0 to n do L0,j := 0                            */
/*    len := 0                                                */
/*    answer := <0,0>                                         */
/*    for i := 1 to m do                                      */
/*       for j := 1 to n do                                   */
/*          if Ai != Bj then                                  */
/*             Li,j := 0                                      */
/*          else                                              */
/*             Li,j := 1 + Li-1,j-1                           */
/*             if Li,j > len then                             */
/*                len := Li,j                                 */
/*                answer = <i,j>                              */
/**************************************************************/
int longest_common_substring(char *a,char *b,int *a1,int *b1)
{int **mx,lgha,lghb,i,j,k,len;

  lgha=strlen(a); lghb=strlen(b);
  if((mx=(int **)malloc((size_t)((lgha+1)*sizeof(int *))))==NULL)return(-1);
  for(i=0;i<=lgha;i++){
     if((mx[i]=(int *)malloc((size_t)((lghb+1)*sizeof(int))))==NULL)return(-1);
  }
  mx[0][0]=0;
  for(i=1;i<=lgha;i++)mx[i][0]=0;
  for(i=1;i<=lghb;i++)mx[0][i]=0;
  len=0;
  (*a1)=0;(*b1)=0;
  for(i=1;i<=lgha;i++){
    for(j=1;j<=lghb;j++){
      if(a[i-1]!=b[j-1])mx[i][j]=0;
      else{
        mx[i][j]=1+mx[i-1][j-1];
        if(mx[i][j]>len){len=mx[i][j];(*a1)=i;(*b1)=j;}
      }
    }
  }(*a1)-=len;(*b1)-=len;for(i=0;i<=lgha;i++)free(mx[i]);free(mx);return(len);
}



/* Optimal sequence alignment. (user defined award)                      */
/*   Maximize award                                                      */
/* Input: sq1 and sq2. No * is needed (allowed)                          */
/*        award: the award for match                                     */
/*               negative award will give unpredicted result             */
/*        which: the award is for which seq. 1 or 2                      */
/* Output: aligned sequences in al1 and al2                              */
/* Return value: the award between sq1 and sq2                           */
/*               -1, not enough memory for dynamic programming           */
double seq_align_user_award(char *sq1,char *sq2,char *al1,char *al2,double *award, int which)
{ int i,j,k,lgh1,lgh2;
  double **mx,w,x,y,z;
  char c;
   lgh1=strlen(sq1); lgh2=strlen(sq2);
   if((mx=(double **)malloc((size_t)((lgh1+1)*sizeof(double *))))==NULL)return(-1);
   for(i=0;i<=lgh1;i++){
      if((mx[i]=(double *)malloc((size_t)((lgh2+1)*sizeof(double))))==NULL)return(-1);
   }
   mx[0][0]=0;
   for(i=1;i<=lgh1;i++)mx[i][0]=0;
   for(i=1;i<=lgh2;i++)mx[0][i]=0;
   if(which==1){
     for(i=1;i<=lgh1;i++){
       c=sq1[i-1];
       for(j=1;j<=lgh2;j++){
         if(sq2[j-1]==c){
           x=mx[i][j-1];y=mx[i-1][j];z=mx[i-1][j-1]+award[i-1];
         }
         else {
           x=mx[i][j-1];y=mx[i-1][j];z=mx[i-1][j-1];
         }
         if(x>y){ w=x; k=0; } else{ w=y; k=1; }
         if(z>w){ w=z; k=2; } mx[i][j]=w; mx[i-1][j-1]=k;
       }
     }
   }
   else { /* which == 2 */
     for(i=1;i<=lgh1;i++){
       c=sq1[i-1];
       for(j=1;j<=lgh2;j++){
         if(sq2[j-1]==c){
           x=mx[i][j-1];y=mx[i-1][j];z=mx[i-1][j-1]+award[j-1];
         }
         else {
           x=mx[i][j-1];y=mx[i-1][j];z=mx[i-1][j-1];
         }
         if(x>y){ w=x; k=0; } else{ w=y; k=1; }
         if(z>w){ w=z; k=2; } mx[i][j]=w; mx[i-1][j-1]=k;
       }
     }
   }
   i=lgh1-1; j=lgh2-1; k=0;
   while(i>=0&&j>=0){
      if((z=mx[i][j])==2){ al1[k]=sq1[i--]; al2[k]=sq2[j--]; }
      else if(z==1){ al1[k]=sq1[i--]; al2[k]='-'; }
      else { al1[k]='-'; al2[k]=sq2[j--]; } k++;
   }
   while(i>=0){ al1[k]=sq1[i--]; al2[k]='-'; k++; }
   while(j>=0){ al1[k]='-'; al2[k]=sq2[j--]; k++; }
   al1[k]=al2[k]='\0'; strrev(al1); strrev(al2);
   x=mx[lgh1][lgh2];for(j=0;j<=lgh1;j++)free(mx[j]);free(mx);return(x);
}

/* Optimal sequence alignment. (user defined penalty)                    */
/*   Minimize penalty                                                    */
/* Input: sq1 and sq2. No * is needed (allowed)                          */
/*        penalty: the penalty for mismatch and gap                      */
/*                 negative penalty will give unpredicted result         */
/*        which: the penalty is for which seq. 1 or 2                    */
/* Output: aligned sequences in al1 and al2                              */
/* Return value: the distance between sq1 and sq2                        */
/*               -1, not enough memory for dynamic programming           */
double seq_align_user_penalty(char *sq1,char *sq2,char *al1,char *al2,double *penalty, int which)
{ int i,j,k,lgh1,lgh2;
  double **mx,w,x,y,z;
  char c;
   lgh1=strlen(sq1); lgh2=strlen(sq2);
   if((mx=(double **)malloc((size_t)((lgh1+1)*sizeof(double *))))==NULL)return(-1);
   for(i=0;i<=lgh1;i++){
      if((mx[i]=(double *)malloc((size_t)((lgh2+1)*sizeof(double))))==NULL)return(-1);
   }
   if(which==1){
     mx[0][0]=0;for(i=1;i<=lgh1;i++)mx[i][0]=penalty[i-1]+mx[i-1][0];
     for(i=1;i<=lgh2;i++)mx[0][i]=0;
     for(i=1;i<=lgh1;i++){
       c=sq1[i-1];
       for(j=1;j<=lgh2;j++){
         if(sq2[j-1]==c){
           x=mx[i][j-1];y=mx[i-1][j]+penalty[i-1];z=mx[i-1][j-1];
         }
         else {
           x=mx[i][j-1];y=mx[i-1][j]+penalty[i-1];z=mx[i-1][j-1]+penalty[i-1];
         }
         if(x<y){ w=x; k=0; } else{ w=y; k=1; }
         if(z<w){ w=z; k=2; } mx[i][j]=w; mx[i-1][j-1]=k;
       }
     }
   }
   else { /* which == 2 */
     mx[0][0]=0;for(i=1;i<=lgh2;i++)mx[0][i]=penalty[i-1]+mx[0][i-1];
     for(i=1;i<=lgh1;i++)mx[i][0]=0;
     for(i=1;i<=lgh1;i++){
       c=sq1[i-1];
       for(j=1;j<=lgh2;j++){
         if(sq2[j-1]==c){
           x=mx[i][j-1];y=mx[i-1][j]+penalty[j-1];z=mx[i-1][j-1];
         }
         else {
           x=mx[i][j-1];y=mx[i-1][j]+penalty[j-1];z=mx[i-1][j-1]+penalty[j-1];
         }
         if(x<y){ w=x; k=0; } else{ w=y; k=1; }
         if(z<w){ w=z; k=2; } mx[i][j]=w; mx[i-1][j-1]=k;
       }
     }
   }
   i=lgh1-1; j=lgh2-1; k=0;
   while(i>=0&&j>=0){
      if((z=mx[i][j])==2){ al1[k]=sq1[i--]; al2[k]=sq2[j--]; }
      else if(z==1){ al1[k]=sq1[i--]; al2[k]='-'; }
      else { al1[k]='-'; al2[k]=sq2[j--]; } k++;
   }
   while(i>=0){ al1[k]=sq1[i--]; al2[k]='-'; k++; }
   while(j>=0){ al1[k]='-'; al2[k]=sq2[j--]; k++; }
   al1[k]=al2[k]='\0'; strrev(al1); strrev(al2);
   x=mx[lgh1][lgh2];for(j=0;j<=lgh1;j++)free(mx[j]);free(mx);return(x);
}

/* Optimal sequence alignment. (fixed GAP/MISMATCH penalty)              */
/*   Minimize penalty                                                    */
/* Input: sq1 and sq2. sq2 could be the pattern sequence with '*'        */
/* Output: aligned sequences in al1 and al2                              */
/* Return value: the distance between sq1 and sq2                        */
/*               -1, not enough memory for dynamic programming           */
/* Alignment will not performed if any of al1 or al2 is NULL.            */
int seq_align(char *sq1,char *sq2,char *al1,char *al2)
{ int **mx,i,j,u,v,x,y,z,lgh1,lgh2;
  char c;
   lgh1=strlen(sq1); lgh2=strlen(sq2);
   if((mx=(int **)malloc((size_t)((lgh1+1)*sizeof(int *))))==NULL)return(-1);
   for(i=0;i<=lgh1;i++){if((mx[i]=(int *)malloc((size_t)((lgh2+1)*sizeof(int))))==NULL)return(-1);}
   for(i=0;i<=lgh1;i++)mx[i][0]=i*GAP;
   for(i=1;i<=lgh2;i++)if(sq2[i-1]=='*')mx[0][i]=mx[0][i-1]; else mx[0][i]=mx[0][i-1]+GAP;

   for(i=1;i<=lgh1;i++){
      c=sq1[i-1];
      for(j=1;j<=lgh2;j++){
         if(sq2[j-1]=='*')u=v=0; else if(sq2[j-1]==c){ u=0; v=GAP; }
         else { u=MISMATCH; v=GAP; }
         x=mx[i][j-1]+v; y=mx[i-1][j]+v; z=mx[i-1][j-1]+u;
/*       if(x<=y){ v=x; u=0; } else{ v=y; u=1; }           */
/*       if(z<=v){ v=z; u=2; } mx[i][j]=v; mx[i-1][j-1]=u; */
         if(x< y){ v=x; u=0; } else{ v=y; u=1; }
         if(z< v){ v=z; u=2; } mx[i][j]=v; mx[i-1][j-1]=u;
      }
   }
   if(al1==NULL||al2==NULL){
     i=mx[lgh1][lgh2];for(j=0;j<=lgh1;j++)free(mx[j]);free(mx);return(i);
   }
   i=lgh1-1; j=lgh2-1; x=0;
   while(i>=0&&j>=0){
      if((z=mx[i][j])==2){ al1[x]=sq1[i--]; al2[x]=sq2[j--]; }
      else if(z==1){ al1[x]=sq1[i--]; al2[x]='-'; } else { al1[x]='-'; al2[x]=sq2[j--]; } x++;
   }
   while(i>=0){ al1[x]=sq1[i--]; al2[x]='-'; x++; } while(j>=0){ al1[x]='-'; al2[x]=sq2[j--]; x++; }
   al1[x]=al2[x]='\0'; strrev(al1); strrev(al2);
   i=mx[lgh1][lgh2];for(j=0;j<=lgh1;j++)free(mx[j]);free(mx);return(i);
}

/* Optimal sequence alignment. (fixed GAP/MISMATCH/OPENGAP penalty)      */
/*   Minimize penalty                                                    */
/* Input: sq1 and sq2. sq2 could be the pattern sequence with '*'        */
/* Output: aligned sequences in al1 and al2                              */
/* Return value: the distance between sq1 and sq2                        */
/*               -1, not enough memory for dynamic programming           */
/* Alignment will not performed if any of al1 or al2 is NULL.            */
int seq_align_open(char *sq1,char *sq2,char *al1,char *al2)
{ int **mx,i,j,u,v,w,x,y,z,lgh1,lgh2;
  char c;
   lgh1=strlen(sq1); lgh2=strlen(sq2);
   if((mx=(int **)malloc((size_t)((lgh1+1)*sizeof(int *))))==NULL)return(-1);
   for(i=0;i<=lgh1;i++){if((mx[i]=(int *)malloc((size_t)((lgh2+1)*sizeof(int))))==NULL)return(-1);}
   mx[0][0]=OPENGAP;
   for(i=1;i<=lgh1;i++)mx[i][0]=mx[i-1][0]+GAP;
   for(i=1;i<=lgh2;i++)if(sq2[i-1]=='*')mx[0][i]=mx[0][i-1]; else mx[0][i]=mx[0][i-1]+GAP;
   mx[0][0]=0;

/*
printf("      ");printf("   ");for(i=0;i<lgh2;i++)printf("  %c",sq2[i]);printf("\n");
printf("      ");for(i=0;i<=lgh2;i++)printf("%3d",i);printf("\n");
printf("     0");for(i=0;i<=lgh2;i++)printf("%3d",mx[0][i]);printf("\n");
*/
   for(i=1;i<=lgh1;i++){
/*
printf("  %c%3d%3d",sq1[i-1],i,mx[i][0]);

     (i-1,j-1)      (i-1,j)
             u\    |v
              2\   |1
               z\  |y
                 \ V
     (i,j-1) ---->(i,j)
             w0x
*/
      c=sq1[i-1];
      for(j=1;j<=lgh2;j++){
         if(sq2[j-1]=='*')u=v=w=0;
         else{
           if(sq2[j-1]==c)u=0;else u=MISMATCH;
           if(i==1){v=GAP;}else {if(mx[i-2][j-1]==1)v=GAP;else v=GAP+OPENGAP;}
           if(j==1){w=GAP;}else {if(mx[i-1][j-2]==0)w=GAP;else w=GAP+OPENGAP;}
         }
         x=mx[i][j-1]+w; y=mx[i-1][j]+v; z=mx[i-1][j-1]+u;
         if(x<y){ v=x; u=0; } else{ v=y; u=1; }
         if(z<v){ v=z; u=2; } mx[i][j]=v; mx[i-1][j-1]=u;
      }
   }
   if(al1==NULL||al2==NULL){
     i=mx[lgh1][lgh2];for(j=0;j<=lgh1;j++)free(mx[j]);free(mx);return(i);
   }
   i=lgh1-1; j=lgh2-1; x=0;
   while(i>=0&&j>=0){
      if((z=mx[i][j])==2){ al1[x]=sq1[i--]; al2[x]=sq2[j--]; }
      else if(z==1){ al1[x]=sq1[i--]; al2[x]='-'; } else { al1[x]='-'; al2[x]=sq2[j--]; } x++;
   }
   while(i>=0){ al1[x]=sq1[i--]; al2[x]='-'; x++; } while(j>=0){ al1[x]='-'; al2[x]=sq2[j--]; x++; }
   al1[x]=al2[x]='\0'; strrev(al1); strrev(al2);
   i=mx[lgh1][lgh2];for(j=0;j<=lgh1;j++)free(mx[j]);free(mx);return(i);
}

/* Calculate the edit distance between 2 sequences by dynamic programming */
/* Try to speed up as much as possible.                                   */
/* Input: sq1 and sq2. sq2 could be the pattern sequence with '*'         */
/* Return value: the distance between sq1 and sq2                         */
/*               -1, not enough memory for dynamic programming            */
int seq_distance(char *sq1,char *sq2)
{
   register int n,i,j,r,t,m1,m2,m3,m12,di_1,TE;
   static int *E=NULL,m=0;

   n=strlen(sq1);
   if(E==NULL){
     m=strlen(sq2);
     if((E=(int *)malloc((size_t)((m+1)*sizeof(int))))==NULL)return(-1);
   }
   E[0]=0; for(i=1;i<=m;i++) if(sq2[i-1]=='*')E[i]=E[i-1]; else E[i]=E[i-1]+1;
   for(i=1;i<=n;i++){
      E[0]=i;
      TE=i-1;
      di_1=sq1[TE];
      for(j=1;j<=m;j++){
         if(sq2[j-1]=='*')r=t=0;
         else if(sq2[j-1]==di_1){
            r=0;
            t=1;
         } else r=t=1;
         m1=TE+r; 
         TE=E[j];
         m2=TE+t;
         m3=E[j-1]+t;
         m12=imin(m1,m2);
         E[j]=imin(m12,m3);
      }
   }
   i=E[m];
   free(E);E=NULL;
   return(i);
}

#define push(x) {if(top==stack_size){stack=(int *)realloc(stack,(size_t)((stack_size<<=1)*sizeof(int)));if(stack==NULL){printf("ERROR: out of memory - chin_lib.c realloc(stack)\n");fflush(stdout);}}stack[top++]=(x);}
#define pop() (stack[--top])

int **combination(int m,int n1,int n2,char w[COMBINATIONMX][COMBINATIONMX],int *n_item)
{int *stack,top,*list,stack_size;
 int **item,max_item;
 int i,j,k,l;

  top=(*n_item)=0;l=1;
  if(n1>n2){i=n1;n1=n2;n2=i;}
  max_item=stack_size=COMBINATIONMX*COMBINATIONMX;
  if((stack=(int *)malloc((size_t)(stack_size*sizeof(int))))==NULL)return(NULL);
  if((list=(int *)malloc((size_t)(m*n2*sizeof(int))))==NULL)return(NULL);
  if((item=(int **)malloc((size_t)(max_item*sizeof(int *))))==NULL)return(NULL);
  
  list[0]=0-1;
  for(i=m-1;i>=0;i--){push(i);}
  while(top>0){
    k=pop();
    if(k==list[l-1]){l--;continue;}
    list[l++]=k;
    if(l-1>=n1){
      /* one combination */
      if((*n_item)==max_item-1){
        item=(int **)realloc(item,(size_t)((max_item<<=1)*sizeof(int *)));if(item==NULL)return(NULL);
      }
      item[*n_item]=(int *)malloc((size_t)((l+1)*sizeof(int)));item[*n_item][0]=l-1;
      for(i=1;i<l;i++)item[*n_item][i]=list[i];(*n_item)++;
      /* one combination */
    }
    if((l-1)==n2)l--;
    else{
      push(list[l-1]);
      for(i=m-1;i>list[l-1];i--){
        if(w==NULL){push(i);}
        else{
          for(j=0;j<l;j++)if(w[list[j]][i]==1)break;
          if(j==l){push(i);}
        }
      }
    }
  }
  return(item);
}


int generate_combination(int m,int n1,int n2,char w[COMBINATIONMX][COMBINATIONMX],int (*Next_combination)(int *picked,int n_picked))
{int *stack,top,*list,stack_size;
 int i,j,k,l,count;

  count=top=0;l=1;stack_size=COMBINATIONMX*COMBINATIONMX*10;
  if(n1>n2){i=n1;n1=n2;n2=i;}
  if((stack=(int *)malloc((size_t)(stack_size*sizeof(int))))==NULL)return(-1);
  if((list=(int *)malloc((size_t)(m*n2*sizeof(int))))==NULL)return(-1);

  list[0]=0-1;
  for(i=m-1;i>=0;i--){push(i);}
  while(top>0){
    k=pop();
    if(k==list[l-1]){l--;continue;}
    list[l++]=k;
    if(l-1>=n1){
      /* one combination */
      count++;
      if((*Next_combination)(list+1,l-1)==0)return(count);
      /* one combination */
    }
    if((l-1)==n2)l--;
    else{
      push(list[l-1]);
      for(i=m-1;i>list[l-1];i--){
        if(w==NULL){push(i);}
        else{
          for(j=0;j<l;j++)if(w[list[j]][i]==1)break;
          if(j==l){push(i);}
        }
      }
    }
  }
  return(count);
}

/*********************/
/*             m!    */
/* C(m,n) = -------- */
/*          n!(m-n)! */
/*********************/
long comb(int m, int n)
{long x;
 int i,k;
  if(m<n || n<=0)return(0);
  if(n<m-n)n=m-n;k=m-n;x=1;
  for(i=1;i<=k;i++){
    x*=((n+i)/i);
if((n+i)%i!=0)printf("fff\n");
  }
  return(x);
}

/************************************************************************/
/* NOTICE:  Copyright 1991-2006, Phillip Paul Fuchs                     */
/* http://www.geocities.com/permute_it/01example.html                   */
/* permutation                                                          */
/************************************************************************/
static int (*Permutation_handler)(int n,int *permutation_array)=NULL;
void permutation_handler_register(int(*f)(int n,int *permutation_array)){Permutation_handler=f;}

void permutation(int n)
{  int *a,*p;
   register unsigned int i, j, tmp; /* Upper Index i; Lower Index j */

   if(Permutation_handler==NULL || n<1)return;
   a=(int *)malloc((size_t)(sizeof(int)*n));
   p=(int *)malloc((size_t)(sizeof(int)*(n+1)));

   for(i=0;i<n;i++){                /* initialize arrays; a[N] can be any type */
      a[i]=i+1;p[i]=i;              /* a[i] value is not revealed and can be arbitrary */
   }
   p[n] = n;                        /* p[N] > 0 controls iteration and the index boundary for i */
   tmp=(*Permutation_handler)(n,a);if(tmp==0)return;
                                    /* remove comment to display array a[] */
   i = 1;                           /* setup first swap points to be 1 and 0 respectively (i & j) */
   while(i < n){
      p[i]--;                       /* decrease index "weight" for i by one */
      j = i % 2 * p[i];             /* IF i is odd then j = p[i] otherwise j = 0 */
      tmp = a[j];                   /* swap(a[j], a[i]) */
      a[j] = a[i];
      a[i] = tmp;
      tmp=(*Permutation_handler)(n,a);if(tmp==0)return;
                                    /* remove comment to display target array a[] */
      i = 1;                        /* reset index i to 1 (assumed) */
      while (!p[i]){                /* while (p[i] == 0) */
         p[i]=i;i++;                /* reset p[i] zero value, set new index value for i (increase by one) */
      }
   }
}
/************************************************************************/
/* NOTICE:  Copyright 1991-2006, Phillip Paul Fuchs                     */
/* http://www.geocities.com/permute_it/01example.html                   */
/* permutation                                                          */
/************************************************************************/





/**********************************************************************************/
/* Simple algorithm for removing a tail                                           */
/* Reference: MacDonald CC, Redondo JL.                                           */
/*            Reexamining the polyadenylation signal: were we wrong about AAUAAA? */
/*            Mol Cell Endocrinol. 2002 Apr 25;190(1-2):1-8.                      */
/**********************************************************************************/
int remove_tail_a(char *mrna)
{ char *b;
  int count;

  if(!mrna)return(-1);
  b=mrna;count=0;while(*b)b++;b--;
  while(b>=mrna && ((*b)=='a' || (*b)=='A')){(*b)='\0';count++;b--;}
  return(count);
}

/**********************************************************************************/
/* Simple algorithm for removing poly t tail                                      */
/* Reference: MacDonald CC, Redondo JL.                                           */
/*            Reexamining the polyadenylation signal: were we wrong about AAUAAA? */
/*            Mol Cell Endocrinol. 2002 Apr 25;190(1-2):1-8.                      */
/**********************************************************************************/
int remove_poly_t(char *mrna)
{ char *a,*b;
  int count;

  if(!mrna)return(-1);
  a=b=mrna;count=0;
  while((*b)!='\0' && ((*b)=='t' || (*b)=='T')){count++;b++;}
  if(a!=b){for(;(*b)!='\0';a++,b++)(*a)=(*b);(*a)='\0';}
  return(count);
}

/**********************************************************************************/
/* Algorithm for removing poly a tail by recognizing AATAAA or ATTAAA pattern     */
/* Reference: MacDonald CC, Redondo JL.                                           */
/*            Reexamining the polyadenylation signal: were we wrong about AAUAAA? */
/*            Mol Cell Endocrinol. 2002 Apr 25;190(1-2):1-8.                      */
/* return: -1, NULL string or error.                                              */
/*         otherwise, number of base pair being removed.                          */
/*  intial=14;extend=30;ratio=90;portion=50;    */
/*  min_cleavage_site=10; max_cleavage_site=40; */
/**********************************************************************************/
int remove_poly_a(char *mrna)
{ char intial_a[100],*pt,*p,*q;
  int i,a_count,count,intial,extend,ratio,min_cleavage_site,max_cleavage_site,length,portion;

  if(!mrna)return(-1);
    intial=14;extend=30;ratio=95;portion=80;
/*  intial=10;extend=20;ratio=95;portion=70; */
/*  intial= 8;extend=15;ratio=90;portion=30; */
  min_cleavage_site=10; max_cleavage_site=40;
  for(i=0;i<intial;i++)intial_a[i]='A';intial_a[i]='\0';
  length=strlen(mrna);
  q=mrna;
l1:if((*q)=='\0')goto nx;
  if((pt=strstr(q,"AATAAA"))!=NULL){
    p=strstr(pt+6,intial_a);
    if(p!=NULL && 100*(length-(p-mrna))<portion*length){
      if((p-pt)>max_cleavage_site||(p-pt)<min_cleavage_site){q=pt+6;goto l1;}
      for(a_count=count=i=intial;i<extend;i++){
        if((*(p+i))=='\0')break;
        if((*(p+i))=='A')a_count++;
        count++;
      }
      if(a_count*100/count>=ratio){
        count=strlen(p); (*p)='\0'; return(count);
      }else{q=pt+6;goto l1;}
    }else goto nx;
  }
nx:q=mrna;
l2:if((*q)=='\0')return(0);
  if((pt=strstr(q,"ATTAAA"))!=NULL){
    p=strstr(pt+6,intial_a);
    if(p!=NULL && 100*(length-(p-mrna))<portion*length){
      if((p-pt)>max_cleavage_site||(p-pt)<min_cleavage_site){q=pt+6;goto l2;}
      for(a_count=count=i=intial;i<extend;i++){
        if((*(p+i))=='\0')break;
        if((*(p+i))=='A')a_count++;
        count++;
      }
      if(a_count*100/count>=ratio){
        count=strlen(p); (*p)='\0'; return(count);
      }else{q=pt+6;goto l2;}
    }
  }
  return(0);
}

/**********************************************************************************/
/* Algorithm for removing poly a tail                                             */
/* return: -1, NULL string or error.                                              */
/*         otherwise, number of base pair being removed.                          */
/**********************************************************************************/
int remove_poly_a2(char *mrna,int a_length,int max_dist)
{ char sq2[50000],al1[50000],al2[50000],*p;
  int i,len,start;

  if(!mrna)return(-1);
  sq2[0]='*';for(i=1;i<=a_length;i++)sq2[i]='A';sq2[i]='*';sq2[i+1]='\0';
/*  if((i=seq_align(mrna,sq2,al1,al2))>max_dist)return(0);*/
  i=seq_align(mrna,sq2,al1,al2);
  if(i>max_dist)return(0);
  len=strlen(mrna);
  for(p=al2;(*p)!='\0'&&((*p)=='*'||(*p)=='-');p++);start=p-al2;
  for(i=start;i>=0;i--)if(al1[i]=='*'||al1[i]=='-')start--;
  mrna[start]='\0';
  return(len-start);
}

int read_psipred_ss2(FILE *fp,char *struc, float *C, float *H, float *E)
/*  1 M C   0.965  0.047  0.027 */
{ char a[MAX_INPUT_LENGTH],c;
  int i,k,len;
  len=0;
  while(fgets(a,MAX_INPUT_LENGTH,fp)!=NULL){
    k=sscanf(a,"%d %c %c %f %f %f",&i,&c,struc+len,C+len,H+len,E+len);
    if(k!=6||i!=len+1)return(-1);
    len++;
  }
  struc[len]='\0';return(len);
}

int read_garnier(FILE *fp,char *struc)
{ int i,len,query_len;
  char query[MAX_INPUT_LENGTH],helix[MAX_INPUT_LENGTH],sheet[MAX_INPUT_LENGTH],turns[MAX_INPUT_LENGTH],coils[MAX_INPUT_LENGTH];
  while(strncmp(fgets(query,MAX_INPUT_LENGTH,fp),"           .   10",17)!=0);
  len=0;
lp:fgets(query,MAX_INPUT_LENGTH,fp); query_len=strlen(query)-8;
  fgets(helix,MAX_INPUT_LENGTH,fp);
  fgets(sheet,MAX_INPUT_LENGTH,fp);
  fgets(turns,MAX_INPUT_LENGTH,fp);
  fgets(coils,MAX_INPUT_LENGTH,fp);
  for(i=0;i<query_len;i++){
    if     (helix[i+7]!=' ')struc[len+i]='H';
    else if(sheet[i+7]!=' ')struc[len+i]='E';
    else if(turns[i+7]!=' ')struc[len+i]='T';
    else if(coils[i+7]!=' ')struc[len+i]='C';
    else return(-1);
  }
  len+=query_len;
  fgets(query,MAX_INPUT_LENGTH,fp);
  fgets(query,MAX_INPUT_LENGTH,fp);
  if(strncmp(query," Residue",8)==0){struc[len]='\0';return(len);}
  goto lp;
}

/************** General tree functions ***********************/
/* create an empty node and return the pointer */
GTREE_NODE *gtree_create(int idx)
{GTREE_NODE *buf;
   buf=(GTREE_NODE *)malloc((size_t)(sizeof(GTREE_NODE)));
   if(buf!=NULL){buf->id=idx;buf->ch=buf->sb=NULL;buf->pr=NULL;}return(buf);
}

/* insert q (and its subtrees) as the right most child of p */
void gtree_insert_right_child(GTREE_NODE *p, GTREE_NODE *q)
{GTREE_NODE *pt;
   if(p==NULL||q==NULL)return;
   if(p->ch==NULL){p->ch=q;q->pr=p;return;}
   pt=p->ch;while(pt->sb!=NULL)pt=pt->sb;pt->sb=q;q->pr=p;return;
}

/* insert q (and its subtrees) as the left most child of p */
void gtree_insert_left_child(GTREE_NODE *p, GTREE_NODE *q)
{
   if(p==NULL||q==NULL)return;
   if(p->ch==NULL){p->ch=q;q->pr=p;return;}
   q->sb=p->ch;p->ch=q;q->pr=p;return;
}

/* insert q (and its subtrees) as the right sibling of p */
void gtree_insert_right_sibling(GTREE_NODE *p, GTREE_NODE *q)
{GTREE_NODE *pt;
   if(p==NULL||q==NULL)return;
   pt=p;while(pt->sb!=NULL)pt=pt->sb;{pt->sb=q;q->pr=pt->pr;return;}
}

/* insert q (and its subtrees) as the left sibling of p */
void gtree_insert_left_sibling(GTREE_NODE *p, GTREE_NODE *q)
{GTREE_NODE *pt;
   if(p==NULL||q==NULL)return;
   pt=p->pr;if(pt->ch==p){q->sb=p;pt->ch=q;q->pr=pt;return;}
   pt=pt->ch;while(pt->sb!=p)pt=pt->sb;q->sb=p;pt->sb=q;q->pr=p->pr;return;
}

/* depth first search item d under tree p */
GTREE_NODE *gtree_dsf_search(GTREE_NODE *p, int d)
{GTREE_NODE *pt;
   if(p==NULL)return(NULL);pt=p;
ax:if(pt->id==d)return(pt);
   if(pt->ch!=NULL){pt=pt->ch;goto ax;}
   if(pt->sb!=NULL){pt=pt->sb;goto ax;}
bx:if(pt==p)return(NULL);
   if(pt->pr->sb!=NULL){pt=pt->pr->sb;goto ax;}
   pt=pt->pr;goto bx;
}

/* depth first search next item d after, not including, p */
GTREE_NODE *gtree_dsf_next_search(GTREE_NODE *p, int d)
{GTREE_NODE *pt;
   if(p==NULL)return(NULL);pt=p;goto cx;
ax:if(pt->id==d)return(pt);
cx:if(pt->ch!=NULL){pt=pt->ch;goto ax;}
   if(pt->sb!=NULL){pt=pt->sb;goto ax;}
bx:if(pt==NULL)return(NULL);
   if(pt->pr->sb!=NULL){pt=pt->pr->sb;goto ax;}
   pt=pt->pr;goto bx;
}

/* print tree p */
/**** having bug *****
void gtree_dsf_print(GTREE_NODE *p, FILE *out)
{GTREE_NODE *pt;
 int i,base,depth,style;

   style=0; ##  1st child at the same level ##
   style=1; ##  1st child at the next level ##
   base=depth=0;if(p==NULL)return;pt=p;
ax:
   for(i=base;i<depth;i++)fprintf(out,"...");
   if(style==0){
     fprintf(out,"%3d",pt->id);base=depth;
   }
   else{
     fprintf(out,"%3d\n",pt->id);base= -1;
   }
   if(pt->ch!=NULL){pt=pt->ch;depth++;base++;goto ax;}
   if(pt->sb!=NULL){
     pt=pt->sb;
     if(pt->pr==p->pr){
       if(style==0)fprintf(out,"\n");
       fflush(out);return;
     }
     if(style==0)fprintf(out,"\n");
     base=0;goto ax;
   }
bx:
   if(pt==p){
     if(style==0)fprintf(out,"\n");
     fflush(out);return;
   }
   if(pt->pr==p){
     if(style==0)fprintf(out,"\n");
     fflush(out);return;
   }
   if(pt->pr->sb!=NULL){
     pt=pt->pr->sb;depth--;
     if(style==0)fprintf(out,"\n");
     base=0;goto ax;
   }
   pt=pt->pr;depth--;base--;
   goto bx;
}
**** having bug *****/

void gtree_dsf_print(GTREE_NODE *p, FILE *out)
{GTREE_NODE *pt;
 int i,base,depth,style;

   style=0; /* 1st child at the same level */
   style=1; /* 1st child at the next level */
   base=depth=0;if(p==NULL)return;pt=p;
ax:
   for(i=base;i<depth;i++)fprintf(out,"...");
   if(style==0){
     fprintf(out,"%3d",pt->id);base=depth;
   }
   else{
     fprintf(out,"%3d\n",pt->id);base= -1;
   }
   if(pt->ch!=NULL){pt=pt->ch;depth++;base++;goto ax;}
bx:if(pt==p){
     if(style==0)fprintf(out,"\n");
     fflush(out);return;
   }
   if(pt->sb!=NULL){
     pt=pt->sb;
     if(style==0)fprintf(out,"\n");
     base=0;goto ax;
   }
   pt=pt->pr;depth--;base--;
   goto bx;
}




/* action on tree p */
/**** having bug *****
void gtree_dsf_action(GTREE_NODE *p, int(*f)(GTREE_NODE *q,int depth))
{GTREE_NODE *pt;
 int step;

   step=0;if(p==NULL)return;pt=p;
ax:
   if((*f)(pt,step)!=1)return;
   if(pt->ch!=NULL){pt=pt->ch;step++;goto ax;}
   if(pt->sb!=NULL){
     pt=pt->sb;
     if(pt->pr==p->pr)return;
     goto ax;
   }
bx:
   if(pt==p)return;
   if(pt->pr==p)return;
   if(pt->pr->sb!=NULL){
     pt=pt->pr->sb;step--;
     goto ax;
   }
   pt=pt->pr;step--;
   goto bx;
}
**** having bug *****/

void gtree_dsf_action(GTREE_NODE *p, int(*f)(GTREE_NODE *q,int depth))
{GTREE_NODE *pt;
 int step;

   step=0;if(p==NULL)return;pt=p;
ax:if((*f)(pt,step)!=1)return;
   if(pt->ch!=NULL){pt=pt->ch;step++;goto ax;}
bx:if(pt==p)return;
   if(pt->sb!=NULL){pt=pt->sb;goto ax;}
   pt=pt->pr;step--;
   goto bx;
}



/* convert a number to a color map with RGB values  */
/*


                          Blue 0000FF     Aqua
                          +--------------+00FFFF
                         /|             /|
                        / |            / |
                       /  |           /  |
                      /   |          /   |
                     /    |         /    |
             Magenta+--------------+     |Green
              FF00FF|     +--------|-----+00FF00
                    |    /Black    |    /
                    |   / FFFFFF   |   /
                    |  /           |  /
                    | /            | /
                    |/             |/
                    +--------------+
                    Red            Yellow
                    FF0000         FFFF00

*/
#define RGB_BIN  4
#define RGB_BINLEN  ((val_high-val_low)/RGB_BIN)
typedef struct rgb_cell{short r;short g;short b;}RGB_CELL;
RGB_CELL RGB_Color[RGB_BIN+1];
int rgb(float val,int *r,int *g,int *b,float val_high,float val_low)
{int bin;
 float ra;
 static int called=0;
   if(val<val_low){(*r)=(*g)=(*b)=0;return(0);}if(val>val_high){(*r)=(*g)=(*b)=255;return(16777215);}
   if(called==0){
     called=1;
/* black -> blue -> green -> yellow -> white  RGB_BIN=4 */
/*
     RGB_Color[0].r=  0;RGB_Color[0].g=  0;RGB_Color[0].b=  0;
     RGB_Color[1].r=  0;RGB_Color[1].g=  0;RGB_Color[1].b=255;
     RGB_Color[2].r=  0;RGB_Color[2].g=255;RGB_Color[2].b=  0;
     RGB_Color[3].r=255;RGB_Color[3].g=255;RGB_Color[3].b=  0;
     RGB_Color[4].r=255;RGB_Color[4].g=255;RGB_Color[4].b=255;
*/
/* black -> blue -> green -> yellow -> red -> white  RGB_BIN=5 */
/*
     RGB_Color[0].r=  0;RGB_Color[0].g=  0;RGB_Color[0].b=  0;
     RGB_Color[1].r=  0;RGB_Color[1].g=  0;RGB_Color[1].b=255;
     RGB_Color[2].r=  0;RGB_Color[2].g=255;RGB_Color[2].b=  0;
     RGB_Color[3].r=255;RGB_Color[3].g=255;RGB_Color[3].b=  0;
     RGB_Color[4].r=255;RGB_Color[4].g=  0;RGB_Color[4].b=  0;
     RGB_Color[5].r=255;RGB_Color[5].g=255;RGB_Color[5].b=255;
*/
/* black -> blue -> green -> yellow -> red  RGB_BIN=4 */
     RGB_Color[0].r=  0;RGB_Color[0].g=  0;RGB_Color[0].b=  0;
     RGB_Color[1].r=  0;RGB_Color[1].g=  0;RGB_Color[1].b=255;
     RGB_Color[2].r=  0;RGB_Color[2].g=255;RGB_Color[2].b=  0;
     RGB_Color[3].r=255;RGB_Color[3].g=255;RGB_Color[3].b=  0;
     RGB_Color[4].r=255;RGB_Color[4].g=  0;RGB_Color[4].b=  0;
   }
   bin=(val-val_low)/RGB_BINLEN;ra=((val-val_low)-(bin*RGB_BINLEN))/(float)RGB_BINLEN;
   (*r)=RGB_Color[bin].r+(RGB_Color[bin+1].r-RGB_Color[bin].r)*ra;
   (*g)=RGB_Color[bin].g+(RGB_Color[bin+1].g-RGB_Color[bin].g)*ra;
   (*b)=RGB_Color[bin].b+(RGB_Color[bin+1].b-RGB_Color[bin].b)*ra;
   return((*r)*65536+(*g)*256+(*b));
}

/******************************************************/
/** input: a pair of strings a and b                 **/
/** output: a pair of string, a and b, with all      **/
/**         singleton edges be removed               **/
/** This algorithm prepares for 2-edge connected     **/
/** component. Apply cluster after this will give    **/
/** you a 2-edge connected graph.                    **/
/******************************************************/
int eliminate_singleton(char **a,char **b,int n)
{char **id,*p;
 int i,j,n_id,*ct,max_id,change;

  /* put x,y in order. eliminate (x,x) edges */
  for(i=0;i<n;i++){
    pack(a[i]);pack(b[i]);
    if(strcmp(a[i],b[i])<0){p=a[i];a[i]=b[i];b[i]=p;continue;}
    if(strcmp(a[i],b[i])==0){n--;free(a[i]);free(b[i]);a[i]=a[n];b[i]=b[n];a[n]=b[n]=NULL;i--;}
  }
  /* eliminate identical edges */
  for(i=0;i<n;i++){
    for(j=i+1;j<n;j++){
      if(strcmp(a[i],a[j])==0 && strcmp(b[i],b[j])==0){
        n--;free(a[j]);free(b[j]);a[j]=a[n];b[j]=b[n];a[n]=b[n]=NULL;j--;
      }
    }
  }
  max_id=100000;
  id=(char **)malloc((size_t)(max_id*sizeof(char *)));if(id==NULL){n=-1;goto xy;}
  ct=(int   *)malloc((size_t)(max_id*sizeof(int   )));if(ct==NULL){n=-1;goto xy;}
lp:
  n_id=0;
  for(i=0;i<n;i++){
    for(j=0;j<n_id;j++){if(strcmp(a[i],id[j])==0)break;}
    if(j==n_id){
      id[j]=strdup(a[i]);ct[j]=1;n_id++;
      if(n_id>=max_id-10){
        id=(char **)realloc(id,(size_t)((max_id<<=1)*sizeof(char *)));if(id==NULL){n=-1;goto xy;}
        ct=(int   *)realloc(ct,(size_t)((max_id    )*sizeof(int   )));if(ct==NULL){n=-1;goto xy;}
      }
    }else{ct[j]++;}

    for(j=0;j<n_id;j++){if(strcmp(b[i],id[j])==0)break;}
    if(j==n_id){
      id[j]=strdup(b[i]);ct[j]=1;n_id++;
      if(n_id>=max_id-10){
        id=(char **)realloc(id,(size_t)((max_id<<=1)*sizeof(char *)));if(id==NULL){n=-1;goto xy;}
        ct=(int   *)realloc(ct,(size_t)((max_id    )*sizeof(int   )));if(ct==NULL){n=-1;goto xy;}
      }
    }else{ct[j]++;}
  }

  for(change=i=0;i<n_id;i++){
    if(ct[i]>1)continue;
    for(j=0;j<n;j++){
      if(strcmp(id[i],a[j])==0||strcmp(id[i],b[j])==0){
        n--;free(a[j]);free(b[j]);a[j]=a[n];b[j]=b[n];a[n]=b[n]=NULL;j--;change=1;
      }
    }
  }
  for(i=0;i<n_id;i++)free(id[i]);
  if(change==1)goto lp;
xy:
  if(id!=NULL)free(id);if(ct!=NULL)free(ct);
  return(n);
}



/*****************************************************/
/** input: string a and b                           **/
/** output: string a and b                          **/
/**   any substring b in a will be added tag        **/
/**   <FONT COLOR=FF0000> and </FONT>               **/
/** a needs enough space to add the tags.           **/
/** This function will NOT check space.             **/
/** (potential memory leak if not handle carefully) **/
/*****************************************************/
int highlight_keyword(char *a,char *b)
{int i,k,lgh,count,max_lgh;
 char *p0,*p1,*p2,*p3,*buf;
/* p0: search next keyword from here */
/* p1: pointer to the next keyword   */
/* p2: pointer to the next '<'       */
/* p3: pointer to the next '>'       */

  if(a==NULL||b==NULL)return(0);
  max_lgh=strlen(a)*50;buf=(char *)malloc((size_t)(max_lgh*sizeof(char)));
  lgh=strlen(b);count=0;k=0;p0=a;p1=strcasestr(p0,b);
  while(p1!=NULL){
    p2=strchr(a,'<');
    if(p2!=NULL && p2<=p1){
      p3=strchr(p2+1,'>');
      if(p3!=NULL && p1<=p3){p0=p3+1;goto nx;}
    }
    while(p0<p1)buf[k++]=(*p0++);
    buf[k++]='<';buf[k++]='F';buf[k++]='O';buf[k++]='N';buf[k++]='T';buf[k++]=' ';buf[k++]='C';
    buf[k++]='O';buf[k++]='L';buf[k++]='O';buf[k++]='R';buf[k++]='=';buf[k++]='F';buf[k++]='F';
    buf[k++]='0';buf[k++]='0';buf[k++]='0';buf[k++]='0';buf[k++]='>';
    for(i=0;i<lgh;i++)buf[k++]=(*p1++);
    buf[k++]='<';buf[k++]='/';buf[k++]='F';buf[k++]='O';buf[k++]='N';buf[k++]='T';buf[k++]='>';
    p0=p1;count++;
nx: p1=strcasestr(p0,b);
  }while((*p0)!='\0')buf[k++]=(*p0++);buf[k]='\0';strcpy(a,buf);return(count);
}
/* 3D 

http://www.programmerworld.net/resources/c_library.htm
http://www.zegraph.com/z-script/zegraph-reference.html
http://stommel.tamu.edu/~baum/graphics-graph-libraries.html

*/

void endian_swap2(unsigned short *x)
{
    (*x) = ((*x)>>8) | 
        ((*x)<<8);
}

void endian_swap4(unsigned int *x)
{
    (*x) = ((*x)>>24) | 
        (((*x)<<8) & 0x00FF0000) |
        (((*x)>>8) & 0x0000FF00) |
        ((*x)<<24);
}

/* __int64 for MSVC, "long long" for gcc */
void endian_swap8(unsigned long long *x)
{
    (*x) = ((*x)>>56) | 
        (((*x)<<40) & 0x00FF000000000000) |
        (((*x)<<24) & 0x0000FF0000000000) |
        (((*x)<<8)  & 0x000000FF00000000) |
        (((*x)>>8)  & 0x00000000FF000000) |
        (((*x)>>24) & 0x0000000000FF0000) |
        (((*x)>>40) & 0x000000000000FF00) |
        ((*x)<<56);
}
