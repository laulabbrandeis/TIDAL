#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "chin_lib.h"

void usage();

#define MX 1000000
#define MX_FLD 1000

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
  char *a,major_delimiter[2],minor_delimiter[2],*buf,c,*pt,**pp,**pre, *last_point;
  FILE *in,*out;
  int i,k,m,n,prek,count,n_comp,n_aggr,print_count,comp[MX_FLD],aggr[MX_FLD],group_on_same_field,bin_row;



  a=(char *)malloc((size_t)(sizeof(char)*MX*MX_FLD));
  last_point=buf=(char *)malloc((size_t)(sizeof(char)*MX*MX_FLD));buf[0]='\0';
  pre=(char **)malloc((size_t)(sizeof(char *)*MX_FLD));
  for(i=0;i<MX_FLD;i++)pre[i]=(char *)malloc((size_t)(sizeof(char)*MX));
  in=stdin;out=stdout;
  major_delimiter[0]='\t'; major_delimiter[1]='\0';
  minor_delimiter[0]='\t'; minor_delimiter[1]='\0';
  n_comp=MX_FLD; n_aggr=0; bin_row=0;
  group_on_same_field=1;
  for(i=0;i<MX_FLD;i++)comp[i]=i;
  print_count=1;
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
      case 'c': print_count=0;argv[i]=NULL;break;
      case 'D': i++;major_delimiter[0]=argv[i][0];argv[i-1]=argv[i]=NULL;break;
      case 'd': i++;minor_delimiter[0]=argv[i][0];argv[i-1]=argv[i]=NULL;break;
      case 'b': i++;bin_row=atoi(argv[i][0]);argv[i-1]=argv[i]=NULL;break;
      case 'g': i++;
                n_comp=0;pt=strtok(argv[i],",");
                while(pt!=NULL){
                  k=sscanf(pt,"%d-%d",&m,&n);
                  if(k<1||k>2){printf("ERR: invalid comp: %s\n",pt);exit(0);}
                  if(k==1){
                    comp[n_comp++]=m++;
                    if(pt[strlen(pt)-1]=='-'){
                      for(;n_comp<MX_FLD;n_comp++)comp[n_comp]=m++;break;
                    }
                  }else for(k=m;k<=n;k++)comp[n_comp++]=k;
                  pt=strtok(NULL,",");
                }argv[i-1]=argv[i]=NULL;break;
      case 'a': i++;
                pt=strtok(argv[i],",");
                while(pt!=NULL){
                  k=sscanf(pt,"%d-%d",&m,&n);
                  if(k<1||k>2){printf("ERR: invalid aggr.: %s\n",pt);exit(0);}
                  if(k==1){
                    aggr[n_aggr++]=m++;
                    if(pt[strlen(pt)-1]=='-'){
                      for(;n_aggr<MX_FLD;n_aggr++)aggr[n_aggr]=m++;break;
                    }
                  }else for(k=m;k<=n;k++)aggr[n_aggr++]=k;
                  pt=strtok(NULL,",");
                }argv[i-1]=argv[i]=NULL;break;
      case 'x': group_on_same_field=0;argv[i]=NULL;break;
      case 'h': usage();
    }
  }
  if(fgets(a,MX,in)==NULL){fclose(in);fclose(out);exit(0);}
  i=strlen(a)-1;while(i>=0&&(a[i]=='\r'||a[i]=='\n'))a[i--]='\0';
  pp=strsimplesplit(a,major_delimiter,&k);
  prek=imin(n_comp,k);count=1;
  for(i=0;i<prek;i++){
    if(comp[i]>=k)continue;
/*  strcat(buf,pp[comp[i]]);strcat(buf,major_delimiter); */  /* use last_point for better preformance */
    strcpy(last_point,pp[comp[i]]);m=strlen(pp[comp[i]]);last_point+=m;strcpy(last_point,major_delimiter);last_point++;
    strcpy(pre[i],pp[comp[i]]);
  }
  for(i=0;i<n_aggr;i++){
    if(aggr[i]>=k)continue;
/*  strcat(buf,pp[aggr[i]]);strcat(buf,minor_delimiter); */  /* use last_point for better preformance */
    strcpy(last_point,pp[aggr[i]]);m=strlen(pp[aggr[i]]);last_point+=m;strcpy(last_point,minor_delimiter);last_point++;
  }
  while(fgets(a,MX,in)!=NULL){
    i=strlen(a)-1;while(i>=0&&(a[i]=='\r'||a[i]=='\n'))a[i--]='\0';
    pp=strsimplesplit(a,major_delimiter,&k);
    for(i=0;i<prek;i++){
      if(comp[i]>=k)goto ne;
      if(strcmp(pre[i],pp[comp[i]])!=0){
        if(group_on_same_field==1) goto ne;
        else goto ct;
      }
    }
    for(i=prek;i<n_comp;i++)if(comp[i]<k)goto ne;
    if(group_on_same_field==0) goto ne;
ct: count++;
    if(group_on_same_field==0){
      for(i=0;i<prek;i++){
        if(comp[i]>=k)continue;
/*      strcat(buf,pp[comp[i]]);strcat(buf,major_delimiter); */  /* use last_point for better preformance */
        strcpy(last_point,pp[comp[i]]);m=strlen(pp[comp[i]]);last_point+=m;strcpy(last_point,major_delimiter);last_point++;
      }
    }
    for(i=0;i<n_aggr;i++){
      if(aggr[i]>=k)continue;
/*    strcat(buf,pp[aggr[i]]);strcat(buf,minor_delimiter); */  /* use last_point for better preformance */
      strcpy(last_point,pp[aggr[i]]);m=strlen(pp[aggr[i]]);last_point+=m;strcpy(last_point,minor_delimiter);last_point++;
    }
    continue;
ne: /* pack(buf); */
    while(last_point>buf && ((*(last_point-1))==' ' || (*(last_point-1))=='\t' || (*(last_point-1))=='\r' || (*(last_point-1))=='\n')){(*(last_point-1))='\0';last_point--;}
    if(print_count)fprintf(out,"%d%s%s\n",count,major_delimiter,buf);
    else fprintf(out,"%s\n",buf);
    fflush(out);buf[0]='\0';count=1;last_point=buf;
    for(prek=0;prek<n_comp;prek++){
      if(comp[prek]>=k)break;
/*    strcat(buf,pp[comp[prek]]);strcat(buf,major_delimiter); */  /* use last_point for better preformance */
      strcpy(last_point,pp[comp[prek]]);m=strlen(pp[comp[prek]]);last_point+=m;strcpy(last_point,major_delimiter);last_point++;
      strcpy(pre[prek],pp[comp[prek]]);
    }
    for(i=0;i<n_aggr;i++){
      if(aggr[i]>=k)continue;
/*    strcat(buf,pp[aggr[i]]);strcat(buf,minor_delimiter); */  /* use last_point for better preformance */
      strcpy(last_point,pp[aggr[i]]);m=strlen(pp[aggr[i]]);last_point+=m;strcpy(last_point,minor_delimiter);last_point++;
    }
  }
/*pack(buf); */
  while(last_point>buf && ((*(last_point-1))==' ' || (*(last_point-1))=='\t' || (*(last_point-1))=='\r' || (*(last_point-1))=='\n')){(*(last_point-1))='\0';last_point--;}
  if(print_count)fprintf(out,"%d%s%s\n",count,major_delimiter,buf);else fprintf(out,"%s\n",buf);
  fclose(in);
  fclose(out);
}

void usage()
{
  printf("Usage: group [-c] [-D major delimiter] [-d minor delimiter] [-g compare_field_list] [-a aggregate_field_list] [-i in_file] [-o out_file] [-x]\n");
  printf("  -h: help message. \n");
  printf("  -c: do not display count. default: display count.\n");
  printf("  -D: set major delimiter. default: [tab]\n");
  printf("  -d: set minor delimiter. default: [tab]\n");
  printf("  -g: field(s) to be compared. default: all fields\n");
  printf("  -b: group by # row. exclusive to -g. default: turn off\n");
  printf("  -a: field(s) to be aggregated. default: no aggregation\n");
  printf("  -i: input file name. default: stdin\n");
  printf("  -o: output file name. default: stdout\n");
  printf("  -x: group on different field(s). default: off (group on same field(s))\n");
  printf("\nExample: group -d ' ' -g 3-5 -a 1,2 -i my_input -o my_output\n");
  exit(0);
}
