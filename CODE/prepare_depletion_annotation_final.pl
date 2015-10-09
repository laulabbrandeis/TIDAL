#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $USAGE = "perl combine_fixed_bins_insertion_depletion.pl infile > output\n";
my %option;
getopts( 'p:h', \%option );
my $libname;
if ( $option{p} ) {
    $libname=$option{p};
}

my $input_filename = $ARGV[0];

open(my $INFILE, "<", $input_filename) 
    or die "unable to open file $input_filename";

#read: index 7 
#Reads: index 11

while ( my $line = <$INFILE> ) {
    chomp $line;
    if ($line=~/^SV/) {
	#header line
	my @tmp = split(/\t/, $line);
#$tmp[14]=SV#
	my @header_arr = ($tmp[0], $tmp[1], $tmp[2], $tmp[3], $tmp[4], $tmp[5], $tmp[6], $tmp[7], $tmp[8], $tmp[9], "RefGen_3prime", "Refgen_5prime", "RefGen_Avg", "Coverage_Ratio", $tmp[15], $tmp[16], $tmp[17], $tmp[18], $tmp[19], $tmp[20], $tmp[21], $tmp[22], $tmp[23], $tmp[24], $tmp[25], $tmp[26], $tmp[27], "depletion_code", "loci_code", "libname");
	my $header_str = "";
	foreach my $el ( @header_arr  ) {
	    $header_str.="$el\t";    
	}
	$header_str=~s/\t$//;
	print "$header_str\n";
	next;
    }

    my @tmp = split(/\t/, $line);
    my $ACR = ($tmp[12] + $tmp[13])/2;
    $ACR = sprintf("%.1f", $ACR); 

    my $ACR_pseudo = $tmp[8]/($ACR + 1);
    $ACR_pseudo = sprintf("%.1f", $ACR_pseudo); 

#calculate the rounder, needed for two other columns  
    my $avg_four = ( $tmp[2] + $tmp[3] + $tmp[5] + $tmp[6])/4;
    my $rounder = (5000*int($avg_four/5000))+1;

    my $depletion_code = $tmp[1]."_".$tmp[8]."_".$rounder;;
    my $loci_code = $tmp[1]."_".$rounder;
 #$tmp[14]=SV#   
    my @line_arr = ($tmp[0], $tmp[1], $tmp[2], $tmp[3], $tmp[4], $tmp[5], $tmp[6], $tmp[7], $tmp[8], $tmp[9], $tmp[12], $tmp[13], $ACR, $ACR_pseudo, $tmp[15], $tmp[16], $tmp[17], $tmp[18], $tmp[19], $tmp[20], $tmp[21], $tmp[22], $tmp[23], $tmp[24], $tmp[25], $tmp[26], $tmp[27], $depletion_code, $loci_code, $libname);

    my $line_str = "";
    foreach my $el ( @line_arr  ) {
	$line_str.="$el\t";    
    }
    $line_str=~s/\t$//;
    print "$line_str\n";
     
}
close $INFILE;


exit;


