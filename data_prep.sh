#RHOME="/nlmusr/reazur/linux"
CODEDIR="/nlmusr/reazur/linux/NELSON/TIDAL/CODE"
TRIMMOMATICDIR="/nlmusr/reazur/linux/SOFTWARE/Trimmomatic-0.30"
prefix=${1%.fastq*}

SElib=$1
finallib=$prefix".trim.fastq"

input=$SElib
output=$finallib
avgquality="20"
#provide directory location of trimmomatic
java -jar $TRIMMOMATICDIR/trimmomatic-0.30.jar SE -phred33 $input $output LEADING:20 TRAILING:20 AVGQUAL:$avgquality
#MINLEN:85

echo "Done with quality control"
mv $finallib $SElib


$CODEDIR/ngs_single_end_pre_mapping_qc.sh $SElib 

uqfile=$SElib".uq"

#-------------------------
#----------------------------------
# remove ployN characters ...
#---------------------------------------
$CODEDIR/remove_polyN_seq.sh $uqfile
polyn_output=$1".uq.polyn"
#$RHOME/CORE/writeqc.sh $input $polyn_output polyN_filter

#-------------------------------------------

workdir=$(pwd)
mkdir $workdir"/insertion"
mkdir $workdir"/depletion"


source=$workdir"/"$polyn_output
target=$workdir"/insertion/"$polyn_output
ln -s $source $target


source=$workdir"/"$polyn_output
target=$workdir"/depletion/"$polyn_output
ln -s $source $target


rm -r *.DIR
rm -r *.qc
rm -r *.stat
#gzip $1
rm $1
rm $uqfile
