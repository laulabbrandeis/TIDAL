#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my %option;
getopts( 'c:r:s:h', \%option );
my ($cluster_filename, $read_coverage_filename, $read_len); 

if (( $option{c} ) && ( $option{r}) && ( $option{s})) {
    $cluster_filename = $option{c} ;
    $read_coverage_filename = $option{r}; 
    $read_len= $option{s};
} else {
    die "proper parameters not passed |$option{c}|; |$option{r}|; |$option{s}|\n";
}


my $window=$read_len/5;

my $read_hash = {};

open(my $READ, "<", $read_coverage_filename) 
    or die "unable to open insert file $read_coverage_filename";

while ( my $line = <$READ> ) {
    chomp $line;
    if ($line=~/^Gene/) {
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $chr_start = $arr[1];
    my $chr_end = $arr[2];
    my $ident = $arr[3];
    my $read = $arr[4];
    my $cluster_window = $chr_end - $chr_start + 1;
    my $norm_constant = $cluster_window/$window;

    my $norm_read = $read/$norm_constant;
    $norm_read = sprintf( "%.1f", $norm_read);

    $read_hash->{$ident} = "$norm_read\t$read";

}
close $READ;



open(my $CLUSTER, "<", $cluster_filename) 
    or die "unable to open insert file $cluster_filename";

my $first_line;
while ( my $line = <$CLUSTER> ) {
    chomp $line;
    if ($line=~/^SV/) {
	print "$line\tNorm_RefGen_Reads\tRefGen_Reads\n";
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $ident = $arr[0];
    
    my $read_str=$read_hash->{$ident};
 
    print "$line\t$read_str\n";
}


close $CLUSTER;


exit;
