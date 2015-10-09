#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "chin_lib.h"

#define MXLGH	1000000
void usage();

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
  char a[MXLGH],c,*seq,desc[MXLGH],*p;
  int i,a_count,c_count,g_count,n_count,t_count,x_count;
  FILE *in,*out;
  double cutoff,n,x;

  out=stdout;in=stdin;cutoff=0.8;
  for(i=1;i<argc;i++){
    if(argv[i][0]!='-')continue;c=argv[i][1];
    switch(c){
      case 'o': i++;
                if((out=fopen(argv[i],"w"))==NULL){
                  fprintf(stderr, "Can't open output file %s\n",argv[i]);exit(2);
                }argv[i-1]=argv[i]=NULL;break;
      case 'i': i++;
                if((in=fopen(argv[i],"r"))==NULL){
                  fprintf(stderr, "Can't open input file %s\n",argv[i]);exit(2);
                }argv[i-1]=argv[i]=NULL;break;
      case 'x': i++; cutoff=atof(argv[i]);argv[i-1]=argv[i]=NULL;break;
      case 'h': usage();
    }
  }
  if(cutoff<0||cutoff>1)cutoff=0.8;
  while((seq=nextfasta(in,desc))){
    a_count=c_count=g_count=n_count=t_count=x_count=0;
    for(p=seq;*p!='\0';p++){
      if(*p=='A')a_count++;
      else if(*p=='C')c_count++;
      else if(*p=='G')g_count++;
      else if(*p=='N')n_count++;
      else if(*p=='T')t_count++;
      else x_count++;
    }
    n=a_count+c_count+g_count+n_count+t_count+x_count;x=cutoff*n-n_count;
    if(a_count<=x&&c_count<=x&&g_count<=x&&t_count<=x)to_fasta(out,desc,seq);
  }
/*  fclose(in);fclose(out); */
}

void usage()
{  printf("remove_poly_n [-i input_fasta_file] [-o output_fasta_file] [-x cutoff]\n");
   printf("  -i: input fasta format file. default: stdin\n");
   printf("      if -i is specified, ile. default: stdin\n");
   printf("  -o: output fasta format file. default: stdout\n");
   printf("  -x: cutoff. default: 0.8\n");
   printf("\nExample: remove_poly_n -i my.seq -o my.out -x 0.9\n");
   exit(2);
}
