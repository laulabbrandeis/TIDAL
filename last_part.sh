#!/bin/sh

#pass the fastq filename as argument
prefix=${1%.fastq*}
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"

#the two necessary files in insertion directory
gzip insertion/$prefix".noGEN"
gzip $prefix".fastq.uq.polyn"

result=$prefix"_result"
mkdir $result
#------------
#copy CNV freec chart
cp insertion/$prefix"_freec_cnv.pdf" $result/
#copy the insertion and depletion final output
final_insert_file=$prefix"_Inserts_Annotated.txt"
final_depletion_file=$prefix"_Depletion_Annotated.txt"
final_depletion_TEonly_file=$prefix"_Depletion_Annotated_TEonly.txt"

cp insertion/$final_insert_file $result/$final_insert_file 
cp depletion/$final_depletion_file $result/$final_depletion_file
cp depletion/$final_depletion_TEonly_file $result/$final_depletion_TEonly_file
#--------------create bed file for insertion and depletion entries
#
cut -f2,3,4 $result/$final_insert_file | grep -v "coord" > $result/$prefix"_Inserts_Annotated.bed"
##4=5' end, 6=3' beginning
cut -f2,4,6 $result/$final_depletion_file | grep -v "coord" > $result/$prefix"_Depletion_Annotated.bed"
##4=5' end, 6=3' beginning
cut -f2,4,6 $result/$final_depletion_TEonly_file | grep -v "coord" > $result/$prefix"_Depletion_Annotated_TEonly.bed"

#combined fixbin file
window=5000
depletionFile=depletion/$prefix"_depletion_fixed_bin_"$window".txt"
insertFile=insertion/$prefix"_insert_fixed_bin_"$window".txt"

perl $CODEDIR/combine_fixed_bins_insertion_depletion.pl -i $insertFile -d $depletionFile -p $prefix> $result/$prefix"_fixed_bin.txt"

#copy the reads with initial scores
cp insertion/$prefix"_new_insert.txt" $result/$prefix"_ReadInsertion.txt"
cp depletion/$prefix"_depletion.xls" $result/$prefix"_ReadDepletion.txt"

#merge the summary file
echo "Insertion Pipeline" > $result/$prefix"_summary.txt"
cat insertion/$prefix"_insertion_summary.txt" >> $result/$prefix"_summary.txt"
echo -ne "\n\nBeginning of Depletion Pipeline\n" >> $result/$prefix"_summary.txt"
cat depletion/$prefix"_depletion_summary.txt" >> $result/$prefix"_summary.txt"


#TE indel plot
map_input=$result/$prefix"_map_insertion_depletion.txt"
perl $CODEDIR/prepare_map_transposon_insertion_depletion.pl $result/$prefix"_fixed_bin.txt" > $map_input

# run the R script for dm6
cat $CODEDIR/TEplot_dm6.R | R --slave --args $prefix $map_input
mv $map_input".pdf" $result/$prefix"_TE_Indel_genome_plot.pdf"