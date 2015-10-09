#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $USAGE = "perl create_bedfile_with_correct_coordinates.pl level1cluster_file.xls > output.bed\n";

my $input_file=$ARGV[0];
open(my $INFILE, "<", $input_file) 
    or die "unable to open file $input_file\n";

while ( my $line = <$INFILE> ) {
    chomp $line;

    if ($line=~/^SV/) {
	# skip the header line
	next;
    }

    my @arr=split(/\t/, $line);
    my ($ident, $chr, $start, $end) = ($arr[0], $arr[1], $arr[2], $arr[3]);
    my $new_start = $start-22;
    print "$chr\t$new_start\t$end\t$ident\n";    
    #the insertion depletion score is determined based on coverage ratio

}


exit;


