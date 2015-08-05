#!/bin/sh
GHOME="/nlmusr/gchirn/linux"
RHOME="/nlmusr/reazur/linux"
HOME=$GHOME

#pass the fastq filename as argument
prefix=${1%.fastq*}

workdir=$(pwd)
echo "workdir: $workdir"

source=$workdir"/insertion/"$prefix".noGEN"
target=$workdir"/depletion/"$prefix".noGEN"
ln -s $source $target

#create softlink of the sorted bam file

source=$workdir"/insertion/"$prefix".sort.bam"
target=$workdir"/depletion/"$prefix".sort.bam"
ln -s $source $target


#source=$workdir"/insertion/"$1".ployn"
#target=$workdir"/depletion/"$1".ployn"
#ln -s $source $target


#source=$workdir"/"$prefix".fastq.uq"
#target=$workdir"/insertion/"$prefix".fastq.uq"
#ln -s $source $target
