#include <stdio.h>
#define MXLGH 1000
main(argc, argv)
int argc;
char **argv;
{char pre[MXLGH],a[MXLGH];
 FILE *in;
 int cnt;

   if(argc==1)in=stdin; 
   else{
      in=fopen(argv[1],"r");
      if(in==NULL){printf("can't open %s\n",argv[1]);exit(0);}
   }

   if(fgets(pre,MXLGH,in)==NULL){printf("0\n");fclose(in);exit(0);}
   cnt=1;
   while(fgets(a,MXLGH,in)!=NULL){
      if(strcmp(a,pre)!=0){
         printf("%d\t%s",cnt,pre);fflush(stdout);
         strcpy(pre,a);cnt=1;
      }
      else cnt++;
   }
   printf("%d\t%s",cnt,pre);fflush(stdout);
   fclose(in);
}
