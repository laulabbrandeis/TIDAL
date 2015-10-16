#!/bin/sh

#location of TIDAL code
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"

ftp -nv hgdownload.soe.ucsc.edu 21 << ptf
user anonymous reazur@brandeis.edu
prom
ver
binary

cd goldenPath/dm6/bigZips

mget dm6.fa.gz
mget dm6.fa.masked.gz

bye
ptf

#exit

#unzip files
gunzip *.gz
#
#remove unnecessary fragment from the chromosome file
mv dm6.fa dm6.fa.unpruned
mv dm6.fa.masked dm6.fa.masked.unpruned
perl $CODEDIR/process_wholegenome_dm6.pl dm6.fa.unpruned > dm6.fa
perl $CODEDIR/process_wholegenome_dm6.pl dm6.fa.masked.unpruned > dm6.fa.masked

#split chromosomes in separate files as needed for FREEC
perl $CODEDIR/split_wholegenome.pl dm6.fa

rm dm6.fa.unpruned
rm dm6.fa.masked.unpruned
