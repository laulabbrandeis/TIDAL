#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my %option;
getopts( 'c:r:h', \%option );
my ($cluster_filename, $read_coverage_filename); 

if (( $option{c} ) && ( $option{r})) {
    $cluster_filename = $option{c} ;
    $read_coverage_filename = $option{r}; 
    
} else {
    die "proper parameters not passed\n";
}


my $read_hash = {};

open(my $READ, "<", $read_coverage_filename) 
    or die "unable to open insert file $read_coverage_filename";

while ( my $line = <$READ> ) {
    chomp $line;
    if ($line=~/^Gene/) {
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $ident = $arr[0];
    my $read = $arr[2];
    my $RPKM = $arr[4];
    $read_hash->{$ident} = "$read\t$RPKM";
    #    print "$ident\t$score\n";
}
close $READ;



open(my $CLUSTER, "<", $cluster_filename) 
    or die "unable to open insert file $cluster_filename";

my $first_line;
while ( my $line = <$CLUSTER> ) {
    chomp $line;
    if ($line=~/^SV/) {
	print "$line\tRefGen_Reads\tRPKM\n";
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $ident = $arr[0];
    
    my $read_str=$read_hash->{$ident};
 
    print "$line\t$read_str\n";
}


close $CLUSTER;


exit;
