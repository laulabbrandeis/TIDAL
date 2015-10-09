#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <search.h>

#include "chin_lib.h"

#define MXLGH	1000000
void usage();
int nd_cmp(const void *x,const void *y);
void action(const void *nodep, const VISIT which, const int depth);
void remove_node(const void *x);

typedef struct pattern_node{
  char   *pattern;
  int    count_all;
  int    count_seq;
}PATTERN_NODE;

long Total_length,Total_read;

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
  char a[MXLGH],b[MXLGH],c,*seq;
  int i,j,pattern_size,lgh,seq_count;
  FILE *in,*out;
  PATTERN_NODE *ptr=NULL;
  void *root1=NULL,*root2=NULL,*p=NULL;

  pattern_size=5;in=stdin;out=stdout;Total_length=Total_read=0;

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
      case 'w': i++;pattern_size=atoi(argv[i]);if(pattern_size<1)pattern_size=5;
                argv[i-1]=argv[i]=NULL;break;
      case 'h': usage();
    }
  }
  while((seq=nextfasta(in,a))){
    lgh=strlen(seq);Total_length+=(lgh-pattern_size+1);Total_read++;
/* printf("%s %d %s\n",a,lgh,seq);fflush(stdout); */
    for(i=0;i<=lgh-pattern_size;i++){
      for(j=0;j<pattern_size;j++)a[j]=seq[i+j];a[j]='\0';
      ptr=(PATTERN_NODE *)malloc((size_t)sizeof(PATTERN_NODE));
      if(ptr==NULL){fprintf(out,"error: malloc==NULL, memory full at point A. Total_read=%ld, Total_length=%ld\n",Total_read,Total_length);exit(0);}
      ptr->pattern=strdup(a);ptr->count_all=ptr->count_seq=0;
      p=tsearch((void *)ptr,&root2,nd_cmp);
      if(p==NULL){fprintf(out,"error: p==NULL %s\n",ptr->pattern);exit(0);}
      if((*(PATTERN_NODE **)p)==ptr){
        seq_count=1;
/* printf("new %s\n",ptr->pattern);fflush(stdout); */
      }
      else{
       seq_count=0;
/* printf("old %s\n",ptr->pattern);fflush(stdout); */
       free(ptr->pattern);free(ptr);
      }

      ptr=(PATTERN_NODE *)malloc((size_t)sizeof(PATTERN_NODE));
      if(ptr==NULL){fprintf(out,"error: malloc==NULL, memory full at point B. Total_read=%ld, Total_length=%ld\n",Total_read,Total_length);exit(0);}
      ptr->pattern=strdup(a);ptr->count_all=ptr->count_seq=1;
      p=tsearch((void *)ptr,&root1,nd_cmp);
      if(p==NULL){fprintf(out,"error: p==NULL %s\n",ptr->pattern);exit(0);}
      if((*(PATTERN_NODE **)p)==ptr){
        ptr->count_seq=ptr->count_all=1;
      }
      else{
        (*(PATTERN_NODE **)p)->count_all++;
        (*(PATTERN_NODE **)p)->count_seq+=seq_count;
        free(ptr->pattern);free(ptr);
      }

    }
    tdestroy(root2,remove_node);root2=NULL;
  }
  twalk(root1,action);
}

int nd_cmp(const void *x,const void *y)
{
  return(strcmp( ((PATTERN_NODE *)x)->pattern,((PATTERN_NODE *)y)->pattern) );
}

void remove_node(const void *x)
{
/* printf("remove: %s\n",((PATTERN_NODE *)x)->pattern);fflush(stdout); */
  free(((PATTERN_NODE *)x)->pattern); free((PATTERN_NODE *)x);
}

void action(const void *nodep, const VISIT which, const int depth) 
{
  PATTERN_NODE *datap;
  int i,j,clusterbegin;
  double sump,sumn,sum,clustersum,clustersump,clustersumn,cluster_cutoff,pre_sum,max_sum;
  double uniq_sum,cluster_uniq_sum;
  cluster_cutoff=0.1;

  switch(which){
    case postorder:
    case leaf:
      datap = *(PATTERN_NODE **)nodep;
      printf("%s\t%d\t%d\t%.10f\n",datap->pattern,datap->count_all,datap->count_seq,datap->count_all/(float)Total_length);
      break;
    case preorder:
    case endorder: break;
  }
}


void usage()
{  printf("generate_pattern [-i input_fasta_file] [-o output_file]\n");
   printf("  -i: input fasta file. default: stdin\n");
   printf("  -o: output file. default: stdout\n");
   printf("  -w: pattern size. default: 5\n");
   printf("\nExample: generate_pattern -i input.fasta -o pattern_count\n");
   exit(2);
}
