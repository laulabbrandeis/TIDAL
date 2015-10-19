#!/bin/sh
#CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
CODEDIR=$4
masked_genomedb=$2
consensus_TEdb=$3
libname=$1
###################################
##  align to masked genome and remove those sequences
###################################

mismatch=1
database=$masked_genomedb

input=$libname
output=$input".gen.sam"
bowtie -f -v $mismatch -S -k 5 -m 5 -p 9 $database $input $output

perl $CODEDIR/separate_aligned_unaligned.pl -f $input -s $output 
mv $input.al $input.gen
mv $input.ual $input.nogen

$CODEDIR/writeqc.sh $input $input.gen match_dm6_mask_gen":$mismatch"



###################################
##  align to consensus TE
###################################


mismatch=2
database=$consensus_TEdb
input=$libname
output=$input".TE.sam"
bowtie -f -v $mismatch -S -k 5 -m 5 -p 9 $database $input $output


perl $CODEDIR/separate_aligned_unaligned.pl -f $input -s $output 
mv $input.al $input.TE
mv $input.ual $input.noTE

$CODEDIR/writeqc.sh $input $input.TE match_TE":$mismatch"

##########################################################

