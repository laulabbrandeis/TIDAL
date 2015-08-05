#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $USAGE = "perl prepare_map_transposon_insertion_depletion.pl combined_fixed_bin_file.txt > output\n";

my $combined_fixed_bin_file = $ARGV[0];
# 0= "Chrom
# 1= interval
# 2= span
# 3= Insert_Reads
# 4= Insert_Count
# 5= Insert_Coverage_Ratio
# 6= FREEC_ratio
# 7= Depletion_Reads
# 8= Depletion_Count
# 9= Depletion_Coverage_Ratio
#\tInsert_code\tDepletion_code\tbin_code\tlibname\n";

open(my $INFILE, "<", $combined_fixed_bin_file) 
    or die "unable to open file $combined_fixed_bin_file";

while ( my $line = <$INFILE> ) {
    chomp $line;

    if ($line=~/^Chrom/) {
	print "Chrom\tinterval\tinsert_score\tinsert_reads\tdepletion_score\tdepletion_reads\n";
	next;
    }
    my @arr=split(/\t/, $line);
    my $chrom= $arr[0];
    my $interval= $arr[1];
    my $insert_coverage_ratio = $arr[5];
    my $insert_reads = $arr[3];
    my $insert_score = 0;
    if ($insert_coverage_ratio ne "") {
	if ($insert_coverage_ratio < 4) {
	    $insert_score=1;
	} else {
	    $insert_score=2;
	}
    }
    my $depletion_coverage_ratio = $arr[9];
    my $depletion_reads  = $arr[7];
    my $depletion_score = 0;
    if ($depletion_coverage_ratio ne "") {
	if ($depletion_coverage_ratio < 4) {
	    $depletion_score=-1;
	} else {
	    $depletion_score=-2;
	}
    }
    print "$chrom\t$interval\t$insert_score\t$insert_reads\t$depletion_score\t$depletion_reads\n";    
    #the insertion depletion score is determined based on coverage ratio
}


exit;


