#!/bin/sh
prefix=${1%.fastq.uq*}
samfile=$1

samtools view -Sh -q 10 $samfile > test.sam
mv test.sam $samfile
samtools view -bSh $samfile > $prefix".bam"
samtools sort $prefix".bam" $prefix".sort"
samtools index $prefix".sort.bam"
#samtools view -h $prefix".sort.bam" >  $prefix".sort.sam"


rm $prefix".bam" 
rm $samfile
