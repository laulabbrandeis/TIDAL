#!/bin/sh

#Location of TIDAL code
#CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
CODEDIR=$2
#$1=libname.fastq

cat $1 > z0.$1


$CODEDIR/exgrep -v -b '>' 'X$' z0.$1 | \
grep -v '[AN][AN][AN][AN][AN][AN][AN][AN][AN][AN][AN][AN][AN]*' | \
grep -v '[CN][CN][CN][CN][CN][CN][CN][CN][CN][CN][CN][CN][CN]*' | \
grep -v '[GN][GN][GN][GN][GN][GN][GN][GN][GN][GN][GN][GN][GN]*' | \
grep -v '[TN][TN][TN][TN][TN][TN][TN][TN][TN][TN][TN][TN][TN]*' | \
$CODEDIR/remove_poly_n > $1.polyn
rm z0.$1


