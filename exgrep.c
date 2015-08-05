#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <regex.h>
#include <malloc.h>


#include "chin_lib.h"

void usage();

#define MX 1000000

main(argc, argv, envp)
int argc;
char **argv, **envp;
{
  char a[MX],delimiter[1000],**pattern,*buf,c,*pt;
  FILE *in,*out,*complement;
  int i,k,del_pos,inverse,casesensitive,n_file,delimiter_length;
  int mx_buf_size,buf_size,found,n_pattern,mx_pattern,order;
int count=0;
  regex_t *re;
  
  in=stdin;out=stdout;complement=NULL;
  mx_pattern=1000;
  pattern=(char **)malloc((size_t)mx_pattern*sizeof(char *));
  delimiter[0]='\0';
  del_pos= -1;
  n_pattern=inverse=n_file=found=order=0;
  casesensitive=1;
  mx_buf_size=MX;
  buf=malloc((size_t)mx_buf_size);
  buf[0]='\0';

  for(i=1;i<argc;i++){
    if(argv[i][0]!='-'){
      if(n_pattern==0){pattern[n_pattern++]=strdup(argv[i]);argv[i]=NULL;}
      else n_file++;
      continue;
    }
    c=argv[i][1];
    switch(c){
      case 'b': i++;if(del_pos==0){printf("ERROR: either -b or -e, can not be both\n");usage();}
                del_pos=1;strcpy(delimiter,argv[i]);argv[i-1]=argv[i]=NULL;break;
      case 'e': i++;if(del_pos==1){printf("ERROR: either -b or -e, can not be both\n");usage();}
                del_pos=0;strcpy(delimiter,argv[i]);argv[i-1]=argv[i]=NULL;break;
      case 'v': inverse=1;argv[i]=NULL;break;
      case 'i': casesensitive=0;argv[i]=NULL;break;
      case 'o': order=1;argv[i]=NULL;break;
      case 'f': if(n_pattern!=0){
                  printf("ERROR: command line pattern and pattern file are mutually exclusive.\n");
                  printf("       Or, you should not put target files before -f.\n\n");usage();
                }i++;
                if((in=fopen(argv[i],"r"))==NULL){printf("ERROR: can't open %s\n",argv[i]);usage();}
                while(fgets(a,MX,in)!=NULL){
                  a[strlen(a)-1]='\0';
                  if(n_pattern>=mx_pattern){
                    pattern=(char **)realloc(pattern,(size_t)(mx_pattern<<=1)*sizeof(char *));
                  }
                  pattern[n_pattern++]=strdup(a);
                }
                fclose(in);argv[i-1]=argv[i]=NULL;break;
      case 'x': i++;
                if((complement=fopen(argv[i],"w"))==NULL){printf("ERROR: can't open %s\n",argv[i]);usage();}
                argv[i-1]=argv[i]=NULL;break;
      case 'h': usage();
    }
  }
  delimiter_length=strlen(delimiter);
  if(n_pattern==0){printf("ERROR: please specify the pattern\n");usage();}
  re=(regex_t *)malloc((size_t)((sizeof(regex_t))*n_pattern));
/*
printf("'%s'\n",pattern);fflush(stdout);
printf("'REG_NOMATCH %d'\n",REG_NOMATCH);fflush(stdout);
printf("'REG_BADPAT %d'\n",REG_BADPAT);fflush(stdout);
printf("'REG_ECOLLATE %d'\n",REG_ECOLLATE);fflush(stdout);
printf("'REG_ECTYPE %d'\n",REG_ECTYPE);fflush(stdout);
printf("'REG_EESCAPE %d'\n",REG_EESCAPE);fflush(stdout);
printf("'REG_ESUBREG %d'\n",REG_ESUBREG);fflush(stdout);
printf("'REG_EBRACK %d'\n",REG_EBRACK);fflush(stdout);
printf("'REG_ENOSYS %d'\n",REG_ENOSYS);fflush(stdout);
printf("'REG_EPAREN %d'\n",REG_EPAREN);fflush(stdout);
printf("'REG_EBRACE %d'\n",REG_EBRACE);fflush(stdout);
printf("'REG_BADBR %d'\n",REG_BADBR);fflush(stdout);
printf("'REG_ERANGE %d'\n",REG_ERANGE);fflush(stdout);
printf("'REG_ESPACE %d'\n",REG_ESPACE);fflush(stdout);
printf("'REG_BADRPT %d'\n",REG_BADRPT);fflush(stdout);
*/
  if(casesensitive==0)k=REG_EXTENDED|REG_NOSUB|REG_NEWLINE|REG_ICASE;
  else k=REG_EXTENDED|REG_NOSUB|REG_NEWLINE;
  for(i=0;i<n_pattern;i++){
     if(regcomp(re+i,pattern[i],k)!=0){
       printf("ERROR: illegal pattern '%s'\n",pattern[i]);exit(0);
     }
  }
  if(n_file==0){i=argc;in=stdin;goto sk;}
  for(i=1;i<argc;i++){
    if(argv[i]==NULL)continue;
    if((in=fopen(argv[i],"r"))==NULL){printf("ERROR: can't open %s\n",argv[i]);continue;}
sk: if(del_pos<0){ /* line grep */
      k= -1;
      while(fgets(a,MX,in)!=NULL){
        if(order==1)k++;else k=0;
        for(;k<n_pattern;k++){
          if(regexec(re+k,a,(size_t)0,NULL,0)==0){
            if(!inverse){fprintf(out,"%s",a);fflush(out);}
            else if(complement!=NULL){fprintf(complement,"%s",a);fflush(complement);}
            break;
          }
        }
        if(inverse && k==n_pattern){fprintf(out,"%s",a);fflush(out);}
        else if(complement!=NULL){fprintf(complement,"%s",a);fflush(complement);}
      }
    }
    else if(del_pos>0){ /*  begin of a record */
      buf[0]='\0';buf_size=0;found=0;k= -1;
x0:   pt=fgets(a,MX,in);
      if(pt==NULL)goto x1;
      if(strncmp(a,delimiter,delimiter_length)==0)goto x1;
      if(order==1)k++;else k=0;
      for(;k<n_pattern && found==0;k++){
        if(regexec(re+k,a,(size_t)0,NULL,0)==0){found=1;break;}
      }
      buf_size+=strlen(a);
      if(buf_size>=mx_buf_size){
count++;
fprintf(stderr,"%d\n",count);
fflush(stderr);
        buf=realloc(buf,(size_t)(mx_buf_size<<=1));
      }
if(buf==NULL){printf("OUT OF MEMORY\n");exit(0);}
      strcat(buf,a);goto x0;
x1:   if(found!=inverse){fprintf(out,"%s",buf);fflush(out);}
      else if(complement!=NULL){fprintf(complement,"%s",buf);fflush(complement);}
      buf[0]='\0';buf_size=0;found=0;
      if(pt==NULL){fclose(in);continue;}
      strcpy(buf,a);buf_size=strlen(a);
      if(order==1)k++;else k=0;
      for(;k<n_pattern && found==0;k++){
        if(regexec(re+k,a,(size_t)0,NULL,0)==0){found=1;break;}
      }
      goto x0;
    }
    else { /* end of a record */
      buf[0]='\0';buf_size=0;found=0;k= -1;
y0:   pt=fgets(a,MX,in);
      if(pt==NULL){
        if(found!=inverse){fprintf(out,"%s",buf);fflush(out);}
        else if(complement!=NULL){fprintf(complement,"%s",buf);fflush(complement);}
        fclose(in);continue;
      }
      if(order==1)k++;else k=0;
      for(;k<n_pattern && found==0;k++){
        if(regexec(re+k,a,(size_t)0,NULL,0)==0){found=1;break;}
      }
      buf_size+=strlen(a);
      if(buf_size>=mx_buf_size)buf=realloc(buf,(size_t)(mx_buf_size<<=1));
      strcat(buf,a);
      if(strncmp(a,delimiter,delimiter_length)==0){
        if(found!=inverse){fprintf(out,"%s",buf);fflush(out);}
        else if(complement!=NULL){fprintf(complement,"%s",buf);fflush(complement);}
        buf[0]='\0';buf_size=0;found=0;
      }
      goto y0;
    }
    fclose(in);
  }
  fclose(out);
  if(complement!=NULL)fclose(complement);
}

void usage()
{
  printf("exgrep is similiar to grep but looking for pattern in 'records'.  A record may contain\n");
  printf("multiple lines. User delimitates the record by giving a delimiter using -b or -e.\n");
  printf("Delimiter is considered as part of a record and always locates at the beginning of a line.\n");
  printf("Pattern is in extended regular expression format.\n");
  printf("Usage: exgrep [-h] [-{b|e} delimiter] [-i] [-v] [-o] {pattern|-f pattern_file} [-x complement_file] [file ...] \n");
  printf("  -h: help message. \n");
  printf("  -b delimiter: set delimiter as the begin of a record. default: not set. newline is the delimiter.\n");
  printf("  -e delimiter: set delimiter as the end of a record. default: not set. newline is the delimiter.\n");
  printf("  -i: case insensitive. default: case sensitive\n");
  printf("  -v: inverse output (print record when pattern is NOT found). default: off\n");
  printf("  -o: patterns are sorted in the same order as the input file. default: off\n");
  printf("      this argument won't change the result but accelerate the search.\n");
  printf("  -f pattern_file: file for patterns, one pattern per line. A record will be printed if ANY\n");
  printf("                   pattern is found in the record (or NONE of the pattern is found in the\n");
  printf("                   resord if -v is specificed. Patterns are searched in the order.\n\n");
  printf("  -x complement_file: default: NULL\n");
  printf("\nExample: exgrep -b 'LOCUS ' -i x12345 my_genbank_file\n");
  exit(0);
}
