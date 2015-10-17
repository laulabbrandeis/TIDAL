
#!/bin/sh
# This script runs the insertion part of the TIDAL pipeline
# Input for this pipeline is the .uq file
# for usage: pass filename and read length
# ./insert_pipeline.sh libname.fastq.uq 151

prefix=${1%.fastq.uq*}
read_len=$2
#----------------- Initializations -----------------
#change the variables in this section as needed
#location of TIDAL code
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
#bowtie and bowtie2 indices, both have the same name in this case
genomedb="/nlmusr/reazur/linux/GENOMES/dm6/dm6"
#location of masked genome bowtie indices
masked_genomedb="/nlmusr/reazur/linux/GENOMES/dm6/dm6_mask"
#location of consensus TE sequence bowtie indices 
consensus_TEdb="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/dm_TE"
#location of FREEC 
FREECDIR="/nlmusr/reazur/linux/SOFTWARE/FREEC"
#Genome sequence in fasta format (all chromosome concatenated in one file)
GENOME="/nlmusr/reazur/linux/GENOMES/dm6/dm6.fa"
#Refseq annotation from UCSC genome browser
refseq_annotationfile="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/refflat_dm6.txt"
#tab delimited file with chromosome name and length
chrlen_file="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/dm6.chr.len"
#directory of individual chromosome files needed by FREEC
chrDir="/nlmusr/reazur/linux/GENOMES/dm6"
#gem mappability file locationa
gemMappabilityFile="/nlmusr/reazur/linux/GENOMES/dm6/gem/gem_mappability_dm6_100mer.mappability"
#bowtie indices of fly virus, structure and repbase sequence
fly_virus_structure_repbase_DB="/nlmusr/reazur/linux/NELSON/TIDAL/annotation/fly_virus_structure_repbase"
#----------------- End initialization -------------------
pushd insertion


##############################
# map reads to genome with bowtie2

#-polyn_output----------------------------
polyn_output=$1
input=$polyn_output
output=$input".sam"
 
bowtie2 -f --sensitive -p 9 --end-to-end -x $genomedb -S $output -U $input
#-x localtion of bowtie2 database

perl $CODEDIR/bowtie2_separate_unmatched_read.pl -f $input $output

#outputs prefix.filter 
#write qc
$CODEDIR/writeqc.sh $input $prefix.filter Bowtie2_wholegenome

#----------------
#run FREEC with the output SAM FILE
#-------------------------
samfile=$output
conf_file="conf_"$prefix".txt"

#create the conf file for dm6, -b build, -s stepsize
perl $CODEDIR/create_freec_conf_file.pl -b dm6 -s 5000 -c $chrDir -g $gemMappabilityFile -l $chrlen_file $samfile > $conf_file
ratio_file=$samfile"_ratio.txt"

$FREECDIR/freec -conf $conf_file
# run the R script for dm6 provided by FREEC for visualization
cat $FREECDIR/scripts/makeGraph_dm6.R | R --slave --args $prefix $ratio_file
mv $ratio_file".pdf" $prefix"_freec_cnv.pdf"
mv $ratio_file $prefix"_freec_ratio.txt"
#rm $samfile
rm *BedGraph
rm *CNVs
rm *.cpn
rm *.cnp
echo "Done with Freec"

#convert the sam file into a sorted bam file
$CODEDIR/convert_sam_sorted_bam.sh $samfile
##############################
# remove virus. structural rna, repbase sequences 
#-----------------------------

mismatch=3
database=$fly_virus_structure_repbase_DB
input=$prefix".filter"
output=$input".sam"
bowtie -f -v $mismatch -S -k 2 -m 100000 -p 9 $database $input $output

perl $CODEDIR/separate_aligned_unaligned.pl -f $input -s $output 
mv $input.al $prefix.strna
mv $input.ual $prefix.nostrna

$CODEDIR/writeqc.sh $input $prefix.nostrna virus_structural_rna_repbase_filter
rm $input
rm $output
rm $prefix.strna


###################################
##  align to consensus TE
###################################


mismatch=3
database=$consensus_TEdb
input=$prefix".nostrna"
output=$input".sam"
bowtie -f -v $mismatch -S -k 2 -m 100000 -p 9 $database $input $output

perl $CODEDIR/separate_aligned_unaligned.pl -f $input -s $output 
mv $input.al $prefix.TE
mv $input.ual $prefix.noTE

$CODEDIR/writeqc.sh $input $prefix.noTE TE_filter
rm $input
rm $output
rm $prefix.TE

mv $prefix.noTE $prefix.noGEN

#-------------------------------------------------------
#get the 5' and 3' end of surviving reads...
length=22
perl $CODEDIR/get_front_end_reads.pl -l $length $prefix.noGEN


frontfile=$prefix.noGEN.front
endfile=$prefix.noGEN.end

#now i have to align consensus_TEdb
$CODEDIR/part_match.sh $frontfile $masked_genomedb $consensus_TEdb $CODEDIR

$CODEDIR/part_match_end.sh $endfile $masked_genomedb $consensus_TEdb $CODEDIR

#---------------
# analysis of samfile files to identify candidate insertion sites
frontgensam=$frontfile".gen.sam"
frontTEsam=$frontfile".TE.sam"
endgensam=$endfile".gen.sam"
endTEsam=$endfile".TE.sam"
candidate_insert=$prefix"_insert.txt"
perl $CODEDIR/unify_front_end_reads.pl -f $frontgensam -e $endTEsam -n $endgensam -r $frontTEsam > $candidate_insert
    
#qc
echo "Candidate insertion sites in file: $candidate_insert" >> summary
orig=$(grep -v "^Ident" $candidate_insert | cut -f1 | cut -d':' -f2 | $CODEDIR/sum)
echo -ne "  reads:\t$orig\n" >> summary
uqr=$(grep -v "^Ident" $candidate_insert | wc -l )
echo -ne "  uqreads:\t$uqr\n" >> summary
echo -ne "  Number of Candidate sites:\t$uqr\n\n" >> summary

#remove everything but the noGEN file
rm $prefix.noGEN.*

#----------------------------------- alignment with blat
old_candidate_insert=$prefix"_insert.txt"
blat_query=$prefix"_insert.fa"

#create the blat query from insert.txt file
perl $CODEDIR/insert_reads_to_fasta.pl $old_candidate_insert > $blat_query

blat_out=$prefix"_insert.psl"
blat $GENOME $blat_query -stepSize=3 -repMatch=2253 -minScore=0 -minIdentity=0 -maxIntron=10 $blat_out

#convert result to bed file
blat_bed=$prefix"_insert.bed"
perl $CODEDIR/psl_to_bed_best_score.pl $blat_out $blat_bed

#read length parameter becomes a issue if read length is some what variable
candidate_insert=$prefix"_new_insert.txt"
perl $CODEDIR/add_blat_score_to_insert.pl -i $old_candidate_insert -b $blat_bed > $candidate_insert

rm $blat_out
rm $old_candidate_insert 
rm $blat_bed


length=22
#--------------------------
#this is the cluster threshold
lim=300
read_threshold=4
#span threshold, chr_ (82-22), or 60-22
#for 75 base, 53-22 in the theoretical max, but reads are sometimes trimmed
#for 125, 103-22 in the theoretical max
#chr_distance_threshold should be (0.5 the length - 22 ) of read length (calculated in perl script)
chr_distance_threshold=$read_len
BSR_threshold=83

#level 1 collapse, collapsing the same transposons in the same reason
level1file=$prefix"_insert_base"$length"_W"$lim"_level1.xls"
perl $CODEDIR/collapse_insert_sites.pl -l $lim -r $read_threshold -d $chr_distance_threshold -t $BSR_threshold $candidate_insert > $level1file
 
echo "Level 1 collapse of insertion sites in file: $level1file" >> summary
uqr=$(grep -v "^Insertion"  $level1file | wc -l )
echo -ne "  Number of Level 1 collapsed sites:\t$uqr\n\n" >> summary
#--------------------------------------
# assigning annotation to insertion sites 
level1sitesannotation=$prefix"_level1siteannotation.xls"
perl $CODEDIR/rough_annotation_insertion_sites.pl -a $refseq_annotationfile $level1file > $level1sitesannotation
echo "Level 1 annotation file: $level1sitesannotation" >> summary


#---------------------------------------
#this part is used for the Coverage ratio at the site of insertion
#---------------------------

level1_corrected_bed=$prefix"_correct_bed.bed"
perl $CODEDIR/create_bedfile_with_correct_coordinates.pl $level1file > $level1_corrected_bed

bamfile=$prefix".sort.bam"
coverage_file=$prefix"_insert_refgene_count.xls"
coverageBed -abam $bamfile -b $level1_corrected_bed > $coverage_file


combinedlevel1file=$prefix"_combined_level1.xls"
perl $CODEDIR/merge_cluster_with_ref_coverage.pl -c $level1file -r $coverage_file -s $read_len > $combinedlevel1file




#-----------------------combining outputs

annotationFile=$prefix"_level1siteannotation.xls"
Insert_Annotated=$prefix"_Inserts_Annotated.txt"

perl $CODEDIR/concatenate_files_by_columns_with_header.pl $combinedlevel1file $level1sitesannotation > dump.txt

perl $CODEDIR/prepare_insertion_annotation_final.pl -p $prefix dump.txt > $Insert_Annotated

rm dump.txt

window=5000
freec_ratio=$prefix"_freec_ratio.txt"
outputfile=$prefix"_insert_fixed_bin_"$window".txt"
perl $CODEDIR/fixed_bin_sites_insertion.pl -w $window -l $chrlen_file -r $freec_ratio $Insert_Annotated > $outputfile

echo "Insertion sites in fixed bin:" >> summary
echo "$outputfile" >> summary




echo "End of pipeline" >> summary


cp summary $prefix"_insertion_summary.txt"

popd
#end of insertion part

