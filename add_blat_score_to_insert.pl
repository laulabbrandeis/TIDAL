#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my %option;
getopts( 'i:b:l:h', \%option );
my ($insert_filename, $bed_filename, $length); 

#if (( $option{i} ) && ( $option{b}) && ( $option{l} )) {
if (( $option{i} ) && ( $option{b}) ) {
    $insert_filename= $option{i};
    $bed_filename= $option{b};
#    $length=$option{l}
#the length is determined by reading the identifier
} else {
    die "proper parameters not passed\n";
}


my $score_hash = {};

open(my $BED, "<", $bed_filename) 
    or die "unable to open insert file $bed_filename";

while ( my $line = <$BED> ) {
    chomp $line;
    my @arr = split(/\t/, $line);
    my $ident = $arr[3];
    my $score = $arr[4];
    $score_hash->{$ident} = $score;
    
#    print "$ident\t$score\n";
    
}
close $BED;

#my $input_filename = $ARGV[0];
open(my $INSERT, "<", $insert_filename) 
    or die "unable to open insert file $insert_filename";

my $first_line;
while ( my $line = <$INSERT> ) {
    chomp $line;
    if ($line=~/^Identifier/) {
#	$first_line = $line;
	print "$line\tBlat_score\n";
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $ident = $arr[0];
    my ($seq, $count) = split(/:/, $ident);
    my $length = length($seq);
    my $score = $score_hash->{$ident};
    if (defined $score) {
	my $norm_score= ($score/$length)*100;
	$norm_score = sprintf("%.2f",$norm_score);
	print "$line\t$norm_score\n";
    } else {
	print "$line\t0\n";
    }
 #   print "\n$length\t$score\n";
 #   die;
}


close $INSERT;


