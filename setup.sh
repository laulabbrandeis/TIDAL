#!/bin/sh

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


