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
	my @header_arr = ($tmp[0], $tmp[1], $tmp[2], $tmp[3], $tmp[4], $tmp[5], $tmp[6], $tmp[7], $tmp[8], $tmp[9], $tmp[10], $tmp[11], "Coverage_Ratio", $tmp[16], $tmp[17], "insert_code", "loci_code", "Sym_score", "libname");
	my $header_str = "";
	foreach my $el ( @header_arr  ) {
	    $header_str.="$el\t";    
	}
	$header_str=~s/\t$//;
	print "$header_str\n";
	next;
    }

    my @tmp = split(/\t/, $line);
    my $coverage_ratio = ($tmp[7]/($tmp[11]+1));
    $coverage_ratio = sprintf("%.1f", $coverage_ratio);

#calculate the rounder, needed for two other columns  
    my $rounder = (5000*int($tmp[2]/5000))+1;
    my $insert_code = $tmp[1]."_".$tmp[7]."_".$rounder;;
    my $loci_code = $tmp[1]."_".$rounder;
#calculate the SymScore
    my $symmetry_str = $tmp[9];
    my ($left, $right) = split(/-/, $symmetry_str);;
    my $sym_score = $left/($left+$right);
    $sym_score = sprintf("%.2f", $sym_score);
    $symmetry_str =  "'".$symmetry_str ;
    my @line_arr = ($tmp[0], $tmp[1], $tmp[2], $tmp[3], $tmp[4], $tmp[5], $tmp[6], $tmp[7], $tmp[8], $symmetry_str, $tmp[10], $tmp[11], $coverage_ratio, $tmp[16], $tmp[17], $insert_code, $loci_code, $sym_score, $libname);
    my $line_str = "";
    foreach my $el ( @line_arr  ) {
	$line_str.="$el\t";    
    }
    $line_str=~s/\t$//;
    print "$line_str\n";
     

    
}
close $INFILE;


exit;


