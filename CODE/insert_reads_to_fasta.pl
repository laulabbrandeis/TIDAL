#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $input_filename = $ARGV[0];
open(my $INFILE, "<", $input_filename) 
        or die "unable to open insert file $input_filename";


my $first_line;
while ( my $line = <$INFILE> ) {
    chomp $line;
    if ($line=~/^Identifier/) {
	$first_line = $line;
	next;
    }

    my @arr = split(/\t/, $line);

    my $identifier = $arr[0];
    my ($read, $count) = split(/:/, $identifier);
#    print "gene name: $gene_name\n";
    print ">$identifier\n$read\n";
    
#    push @{$arr2d}, \@arr;

#    my $refsize = @{$ghash->{$gene_name}};  
#   print "num of element: $refsize\n";
    
}


close $INFILE;


exit;
