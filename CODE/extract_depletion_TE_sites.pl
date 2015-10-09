#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $input_filename = $ARGV[0];
open(my $INFILE, "<", $input_filename) 
        or die "unable to open ct file $$input_filename";

my $SKIPLINE = 0;
my $arr2d=[];
my $first_line;
while ( my $line = <$INFILE> ) {
    chomp $line;
#    if ($line=~/^Identifier/) {
    if ($line=~/^SV/) {
	$first_line = $line;
	print "$line\n";
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $repname = $arr[7];
    if ($repname ne "" ) {
	print "$line\n";
    }
}

exit;
