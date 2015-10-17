#!/bin/bash
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
#This script download the sra file, converts it to fastq, and then runs the TIDAL pipeline
#ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/

while read libid srr_accession min_len
  do 
    # Skip the header
  [ "$libid" ==  "Library_ID" ] && continue
#    first="${srr_accession:1:3}" 
#    second="${srr_accession:1:6}"
#    accession="${srr_accession:1:9}"
  
  first="${srr_accession:0:3}" 
  second="${srr_accession:0:6}"
  accession="$srr_accession"
  
#    echo "|$libid|, |$min_len|, |$srr_accession|, |$first|, |$second|, |$accession|" >> run.txt
  
   #create the download link
  path=sra/sra-instant/reads/ByRun/sra/"$first"/"$second"/"$accession"/
  srafile="$accession"".sra"
  ftp -nv ftp-trace.ncbi.nlm.nih.gov 21 << ptf
user anonymous reazur@brandeis.edu
prom
ver
binary

cd $path

mget $srafile
bye
ptf
  
  #convert the sra to fastq-dump: min read and split spot
  fastq-dump --split-spot --minReadLen $min_len $srafile
  sra_fastq_file="$accession"".fastq"
  fastq_file=$libid".fastq"
  mkdir $libid
  mv $sra_fastq_file  $libid/$fastq_file
  #now move to that directory and run Tidal
  timestamp=$(date +%T)
  echo -ne "\nRunning TIDAL with $libid $min_len $accession...$timestamp\n" >> run.txt
  
  pushd $libid
  
  $CODEDIR/TIDAL_from_fastq.sh $fastq_file $min_len
  
  popd
  timestamp=$(date +%T)
  echo -ne "Done with $libid $min_len $accession...$timestamp\n" >> run.txt
  rm $srafile
done < $1
