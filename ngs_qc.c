#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <search.h>
#include <math.h>

#include "chin_lib.h"

#define MX 5000
#define MX_READ_LENGTH 1000
#define MX_QUALITY 100
#define Q_BASE 33

void usage();

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
  char a[MX],c,*p;
  long A[MX_READ_LENGTH],C[MX_READ_LENGTH],G[MX_READ_LENGTH],T[MX_READ_LENGTH],N[MX_READ_LENGTH],X[MX_READ_LENGTH];
  int read_count[MX_READ_LENGTH],q0[MX_READ_LENGTH],q1[MX_READ_LENGTH],q2[MX_READ_LENGTH],q3[MX_READ_LENGTH],q4[MX_READ_LENGTH];
  double upper_whisker[MX_READ_LENGTH],lower_whisker[MX_READ_LENGTH];
  double mean[MX_READ_LENGTH],stdev[MX_READ_LENGTH],xsum;
  FILE *in,*out;
  int i,j,whisker,max_read_length,mx_qty[MX_READ_LENGTH],nothing;
  long count[MX_READ_LENGTH][MX_QUALITY],ql_count,qu_count,sum,q1_count,q2_count,q3_count,q_count;
  
  whisker=0;max_read_length=0;nothing=0;
  for(i=0;i<MX_READ_LENGTH;i++)for(j=0;j<MX_QUALITY;j++)count[i][j]=0;
  for(i=0;i<MX_READ_LENGTH;i++)read_count[i]=q0[i]=q1[i]=q2[i]=q3[i]=q4[i]=upper_whisker[i]=lower_whisker[i]=mx_qty[i]=mean[i]=stdev[i]=0;
  for(i=0;i<MX_READ_LENGTH;i++)A[i]=C[i]=G[i]=T[i]=N[i]=X[i]=0;
  in=stdin;out=stdout;
  for(i=1;i<argc;i++){
    if(argv[i][0]!='-')continue;c=argv[i][1];
    switch(c){
      case 'i': i++;
                if((in=fopen(argv[i],"r"))==NULL){
                  printf("ERROR: can't open %s\n",argv[i]);exit(0);
                }argv[i-1]=argv[i]=NULL;break;
      case 'o': i++;
                if((out=fopen(argv[i],"w"))==NULL){
                  printf("ERROR: can't open %s\n",argv[i]);exit(0);
                }argv[i-1]=argv[i]=NULL;break;
      case 'w': i++;whisker=atoi(argv[i]);argv[i-1]=argv[i]=NULL;if(whisker<0||whisker>4)whisker=0;break;
      case 'n': nothing=1;argv[i]=NULL;break;
      case 'h': usage();
    }
  }

/*
@HWI-ST222:115:B01AAABXX:1:1101:1245:1958 1:N:0:ACTTGA
NTAGCTACCTATAGCCGGTGGTGATGGTGATGGTGGGTAGTGGTAGGGCA
+
#?AAFFFFFHHHDHHIIIIII@FHGIIFHIIII:DFH8B@8?G9DH1F.@
*/
  while(fgets(a,MX,in)!=NULL){
    fgets(a,MX,in);
    p=a;i=0;
    while((*p)!='\n'&&(*p)!='\0'){
      if     ((*p)=='A')A[i]++;
      else if((*p)=='C')C[i]++;
      else if((*p)=='G')G[i]++;
      else if((*p)=='T')T[i]++;
      else if((*p)=='N')N[i]++;
      else              X[i]++;
      i++;p++;
    }
    if((p-a)>max_read_length)max_read_length=(p-a);
    fgets(a,MX,in);
    fgets(a,MX,in);
    p=a;i=0;
    while((*p)!='\n'&&(*p)!='\0'){
      if(nothing==1){fprintf(out,"%d\t",(*p)-Q_BASE);fflush(out);}
      read_count[i]++;
      if(((*p)-Q_BASE)>mx_qty[i])mx_qty[i]=(*p)-Q_BASE;
      count[i][(*p)-Q_BASE]++;
      i++;p++;
    }
    if(nothing==1){fprintf(out,"\n");fflush(out);}
  }fclose(in);
  if(nothing==1){fclose(out);exit(0);}

  fprintf(out,"Position\tMinimum\tLower_whisker\tQ1\tMedian\tQ3\tUpper_whisker\tMaximum\tMean\tStdev\tA\tC\tG\tT\tN\tX\n");fflush(out);

  for(i=0;i<max_read_length;i++){
/*
printf("read_count=%ld\n",read_count[i]);fflush(out);
*/
    q1_count=read_count[i]*0.25;
    q2_count=read_count[i]*0.5;
    q3_count=read_count[i]*0.75;
    if     (whisker==3){ql_count=read_count[i]*0.10;qu_count=read_count[i]*0.90;}
    else if(whisker==4){ql_count=read_count[i]*0.05;qu_count=read_count[i]*0.95;}
    else if(whisker==5){ql_count=read_count[i]*0.02;qu_count=read_count[i]*0.98;}
    else               {ql_count=0;                 qu_count=read_count[i];}
/*
printf("q1_count=%ld q2_count=%ld q3_count=%ld\n",q1_count,q2_count,q3_count);fflush(out);
*/
    
    for(j=0;j<=mx_qty[i];j++){if(count[i][j]!=0){q0[i]=j;break;}}
    for(j=mx_qty[i];j>=0;j--){if(count[i][j]!=0){q4[i]=j;break;}}
    q_count=sum=0;
    for(j=0;j<=mx_qty[i];j++){
      if(count[i][j]!=0){
        q_count+=count[i][j];sum+=(count[i][j]*j);
        if(q_count>ql_count){j++;break;}
      }
    }
    lower_whisker[i]=j-1;
    for(;j<=mx_qty[i];j++){
      if(count[i][j]!=0){
        q_count+=count[i][j];sum+=(count[i][j]*j);
        if(q_count>q1_count){j++;break;}
      }
    }
    q1[i]=j-1;
    for(;j<=mx_qty[i];j++){
      if(count[i][j]!=0){
        q_count+=count[i][j];sum+=(count[i][j]*j);
        if(q_count>q2_count){j++;break;}
      }
    }
    q2[i]=j-1;
    for(;j<=mx_qty[i];j++){
      if(count[i][j]!=0){
        q_count+=count[i][j];sum+=(count[i][j]*j);
        if(q_count>q3_count){j++;break;}
      }
    }
    q3[i]=j-1;
    for(;j<=mx_qty[i];j++){
      if(count[i][j]!=0){
        q_count+=count[i][j];sum+=(count[i][j]*j);
        if(q_count>qu_count){j++;break;}
      }
    }
    upper_whisker[i]=j-1;

    for(;j<=mx_qty[i];j++){
      if(count[i][j]!=0){
        q_count+=count[i][j];sum+=(count[i][j]*j);
      }
    }
    mean[i]=(double)sum/read_count[i];
    for(xsum=j=0;j<=mx_qty[i];j++){xsum+=(count[i][j]*(j-mean[i])*(j-mean[i]));}
    stdev[i]=sqrt(xsum/(read_count[i]-1));

    if     (whisker==0){lower_whisker[i]=q0[i];upper_whisker[i]=q4[i];}
    else if(whisker==1){
      lower_whisker[i]=q1[i]-1.5*(q3[i]-q1[i]);upper_whisker[i]=q3[i]+1.5*(q3[i]-q1[i]);
      if(lower_whisker[i]<q0[i])lower_whisker[i]=q0[i];
      if(upper_whisker[i]>q4[i])upper_whisker[i]=q4[i];
    }
    else if(whisker==2){
      lower_whisker[i]=mean[i]-stdev[i];upper_whisker[i]=mean[i]+stdev[i];
      if(lower_whisker[i]<q0[i])lower_whisker[i]=q0[i];
      if(upper_whisker[i]>q4[i])upper_whisker[i]=q4[i];
    }
/*
    fprintf(out,"%d q0=%d lower_whisker=%lf q1=%d q2=%d q3=%d upper_whisker=%lf q4=%d mean=%lf stdev=%lf A=%ld C=%ld G=%ld T=%ld N=%ld X=%ld\n",i,q0[i],lower_whisker[i],q1[i],q2[i],q3[i],upper_whisker[i],q4[i],mean[i],stdev[i],A[i],C[i],G[i],T[i],N[i],X[i]);fflush(out);
*/
    fprintf(out,"%d\t%d\t%lf\t%d\t%d\t%d\t%lf\t%d\t%lf\t%lf\t%ld\t%ld\t%ld\t%ld\t%ld\t%ld\n",i+1,q0[i],lower_whisker[i],q1[i],q2[i],q3[i],upper_whisker[i],q4[i],mean[i],stdev[i],A[i],C[i],G[i],T[i],N[i],X[i]);fflush(out);

  }  
}



void usage()
{
  fprintf(stdout,"Usage: ngs_qc [-i in_file] [-o out_file]\n");
  fprintf(stdout,"  -h: help message. \n");
  fprintf(stdout,"  -i: input fastq file. default: stdin\n");
  fprintf(stdout,"  -o: output file. default: stdout\n");
  fprintf(stdout,"  -w: whisker: default: 0\n");
  fprintf(stdout,"      0: minimum/maximum\n");
  fprintf(stdout,"      1: 1.5IQR\n");
  fprintf(stdout,"      2: one standard deviation of mean\n");
  fprintf(stdout,"      3: 10/90 percentile\n");
  fprintf(stdout,"      4: 5/95 percentile\n");
  fprintf(stdout,"      5: 2/98 percentile\n");
  fprintf(stdout,"  -n: do nothing, print qty value only. default: off\n");
  fprintf(stdout,"\nExample: ngs_qc -i read.fq -o read.qc\n");
  exit(0);
}

