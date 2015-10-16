#!/bin/sh

ftp -nv hgdownload.soe.ucsc.edu 21 << ptf
user anonymous reazur@brandeis.edu
prom
ver
binary

cd goldenPath/dm6/bigZips

mget dm6.fa.gz
#mget dm6.fa.masked.gz dm6.chrom.sizes

bye
ptf

#unzip files
#gunzip *.gz
#
#remove unnecessary fragment from the chromosome file
#mv dm6.fa dm6.fa.unpruned
#mv dm6.fa.masked dm6.fa.masked.unpruned
#/nlmusr/reazur/linux/CORE/process_wholegenome_dm6.pl dm6.fa.unpruned > dm6.fa
#/nlmusr/reazur/linux/CORE/process_wholegenome_dm6.pl dm6.fa.masked.unpruned > dm6.fa.masked

#split chromosomes in separate files if needed
#perl ~reazur/CORE/split_wholegenome.pl dm6.fa