#!/bin/sh

RHOME="/nlmusr/reazur/linux"


CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"

#pass the fastq filename as argument
lib=$1
prefix=${1%.fastq*}
#read_len=151
read_len=$2

$CODEDIR/data_prep.sh $lib 
$CODEDIR/insert_pipeline.sh $lib".uq.polyn" $read_len  
$CODEDIR/setup.sh $lib
$CODEDIR/depletion_pipeline.sh $lib".uq.polyn" $read_len
$CODEDIR/last_part.sh $lib