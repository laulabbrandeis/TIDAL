#!/bin/bash
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"

#ftp://ftp-trace.ncbi.nlm.nih.gov/sra/sra-instant/reads/ByRun/sra/SRR/
#IFS=$'\n\t'
while read libid srr_accession1 srr_accession2 min_len
do 
    # Skip the header
    [ "$libid" ==  "Library_ID" ] && continue

    first="${srr_accession1:0:3}" 
    second="${srr_accession1:0:6}"
    accession1="$srr_accession1"

    echo "|$libid|, |$min_len|, |$first|, |$second|, |$accession1|" >> run.txt

    #create the download link
    path1=sra/sra-instant/reads/ByRun/sra/"$first"/"$second"/"$accession1"/
    srafile1="$accession1"".sra"
    #------------------------------

    first="${srr_accession2:0:3}" 
    second="${srr_accession2:0:6}"
    accession2="$srr_accession2"

    echo "|$libid|, |$min_len|, |$first|, |$second|, |$accession2|" >> run.txt

    #create the download link
    path2=/sra/sra-instant/reads/ByRun/sra/"$first"/"$second"/"$accession2"/
    srafile2="$accession2"".sra"
#------------------



    ftp -nv ftp-trace.ncbi.nlm.nih.gov 21 << ptf
user anonymous reazur@brandeis.edu
prom
ver
binary

cd $path1
mget $srafile1

cd $path2
mget $srafile2

bye
ptf

#convert the sra to fastq-dump: min read and split spot
    fastq-dump --split-spot -M $min_len $srafile1
    sra_fastq_file1="$accession1"".fastq"

    fastq-dump --split-spot -M $min_len $srafile2
    sra_fastq_file2="$accession2"".fastq"

    fastq_file=$libid".fastq"
    mkdir $libid
    cat $sra_fastq_file1 $sra_fastq_file2 > $libid/$fastq_file

    rm $sra_fastq_file1
    rm $sra_fastq_file2
    rm *.sra

    timestamp=$(date +%T)
    echo -ne "\nRunning TIDAL with $libid $min_len $accession...$timestamp\n" >> run.txt

    pushd $libid

    $CODEDIR/TIDAL_from_fastq.sh $fastq_file $min_len

    popd
    timestamp=$(date +%T)
    echo -ne "Done with $libid $min_len $accession...$timestamp\n" >> run.txt
#    rm sra file

done < $1
