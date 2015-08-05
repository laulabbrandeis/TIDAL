#!/bin/sh
GHOME="/nlmusr/gchirn/linux"
RHOME="/nlmusr/reazur/linux"
HOME=$GHOME

# Input for this pipeline is the .uq file
# $1 = OSS_C.fastq.uq
#input=$1
prefix=${1%.fastq*}
read_len=$2
input=$prefix.noGEN
#polyn_output=$1.polyn
polyn_output=$1
#----------------- Initializations -----------------
#both bowtie and bowtie2 db have the same name
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
genomedb="/nlmusr/reazur/linux/GENOMES/dm6/dm6"
masked_genomedb="/nlmusr/reazur/linux/GENOMES/dm6/dm6_mask"
consensus_TEdb="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/dm_TE"
GENOME="/nlmusr/reazur/linux/GENOMES/dm6/dm6.fa"
MASKED_GENOME="/nlmusr/reazur/linux/GENOMES/dm6/dm6.fa.masked"
repeat_masker_file="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/repmasker_dm6_track.txt"
refseq_annotationfile="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/refflat_dm6.txt"
table_lookup="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/Tidalbase_Dmel_TE_classifications_2015.txt"
#----------------- End initialization -------------------


pushd depletion

#----------------------------------------
#get the 5' and 3' end of surviving reads...
length=22
infile=$input
perl $CODEDIR/get_front_end_reads.pl -l $length $infile

frontfile=$infile.front
endfile=$infile.end

###################################
##  align 5' to masked genome and remove those sequences
###################################

mismatch=1
database=$masked_genomedb

input=$frontfile
output=$input".gendel.sam"
bowtie -f -v $mismatch -S -k 100000 -m 100000 --strata --best -p 12 $database $input $output

perl $CODEDIR/separate_aligned_unaligned.pl -f $input -s $output 
mv $input.al $input.gendel
mv $input.ual $input.nogendel

$CODEDIR/writeqc.sh $input $input.gendel match_dm6_mask_gen_del":$mismatch"

#-----------------------------------------------

###################################
##  align 5' to masked genome and remove those sequences
###################################


mismatch=1
database=$masked_genomedb

input=$endfile
output=$input".gendel.sam"
bowtie -f -v $mismatch -S -k 100000 -m 100000 --strata --best -p 12 $database $input $output

perl $CODEDIR/separate_aligned_unaligned.pl -f $input -s $output 
mv $input.al $input.gendel
mv $input.ual $input.nogendel

$CODEDIR/writeqc.sh $input $input.gendel match_dm6_mask_gen_del":$mismatch"

#-----------------------------------------------


# analysis of samfile files to identify candidate insertion sites
frontgensam=$frontfile".gendel.sam"
endgensam=$endfile".gendel.sam"
candidate_deletion=$prefix"_depletion.xls"

perl $CODEDIR/identify_depletion_sites.pl -f $frontgensam -e $endgensam > $candidate_deletion

#qc------------
echo "Candidate breakpoint sites in file: $candidate_deletion" >> summary
orig=$(grep -v "^Ident" $candidate_deletion | cut -f1 | cut -d':' -f2 | $CODEDIR/sum)
echo -ne "  reads:\t$orig\n" >> summary
uqr=$(grep -v "^Ident" $candidate_deletion | wc -l )
echo -ne "  uqreads:\t$uqr\n" >> summary
echo -ne "  Number of reads supporting candidate sites:\t$uqr\n\n" >> summary
 
#-------------------------------
level1file=$prefix"_depletion_level1.xls"
 
lim=300
read_threshold=4
#repeat masker file for dm6, -m
perl $CODEDIR/collapse_depletion_sites.pl -l $lim -r $read_threshold -m $repeat_masker_file -t $table_lookup $candidate_deletion > $level1file

#-------
echo "Level 1 collapse of depletion sites in file: $level1file" >> summary
uqr=$(grep -v "^Deletion"  $level1file | wc -l )
echo -ne "  Number of Level 1 collapsed sites:\t$uqr\n\n" >> summary

 
#-------------
level1file=$prefix"_depletion_level1.xls"
level1sitesannotation=$prefix"_level1siteannotation.xls"
perl $CODEDIR/rough_annotation_depletion_sites.pl -a $refseq_annotationfile $level1file > $level1sitesannotation

#----------------------------------
#calculate refgene coverage of depletion sites
bamfile=$prefix".sort.bam"

#create bed file with the correct coordinate for 5prime
level1_5prime_corrected_bed=$prefix"_5prime_sites.bed"
perl $CODEDIR/create_bedfile_5prime_depletion_sites.pl -s $read_len $level1file > $level1_5prime_corrected_bed


coverage_file_5prime=$prefix"_5prime_refgene_count.xls"
coverageBed -abam $bamfile -b $level1_5prime_corrected_bed > $coverage_file_5prime

#create bed file for correct coordinate with 3prime
level1_3prime_corrected_bed=$prefix"_3prime_sites.bed"
perl $CODEDIR/create_bedfile_3prime_depletion_sites.pl -s $read_len $level1file > $level1_3prime_corrected_bed

coverage_file_3prime=$prefix"_3prime_refgene_count.xls"
coverageBed -abam $bamfile -b $level1_3prime_corrected_bed > $coverage_file_3prime

# combined both 5 prime
strand_coverage_combined=$prefix"_depletion_coverage_combined.xls"  
perl $CODEDIR/combined_depletion_coverage.pl -s $read_len $coverage_file_5prime $coverage_file_3prime > $strand_coverage_combined


#--------------------------------------------------------
window=5000
chrlen_file="/nlmusr/reazur/linux/GENOMES/dm6/dm6.chr.len"
#---------------------------------------
#annotationFile=$prefix"_level1siteannotation.xls"
#depletiontFile=$prefix"_depletion_level1.xls"
coverageFile=$strand_coverage_combined
Depletion_Annotate_file=$prefix"_Depletion_Annotated.txt"


perl $CODEDIR/concatenate_files_by_columns_with_header.pl $level1file $coverageFile $level1sitesannotation > dump.txt


perl $CODEDIR/prepare_depletion_annotation_final.pl -p $prefix dump.txt > $Depletion_Annotate_file

rm dump.txt
#--------- separate the TE related entries ---------------
level1file_TEonly=$prefix"_Depletion_Annotated_TEonly.txt"
perl $CODEDIR/extract_depletion_TE_sites.pl $Depletion_Annotate_file > $level1file_TEonly

#coverage_ratio=[12]
outputfile=$prefix"_depletion_fixed_bin_"$window".txt"
perl $CODEDIR/fixed_bin_sites_depletion.pl -w $window -l $chrlen_file $level1file_TEonly > $outputfile

 
rm $prefix.noGEN.*
#gzip $prefix.filter

cp summary $prefix"_depletion_summary.txt"
#rm z*
#rm select*
#rm $polyn_output"."*

popd

exit

