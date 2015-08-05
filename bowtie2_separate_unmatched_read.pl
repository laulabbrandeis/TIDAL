#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;

my $USAGE = "bowtie2_filter_unmatched_read.pl -f \n";
my %option;
getopts( 'f:h', \%option );
my ($fafilename);

if ( $option{f} ) {
    $fafilename = $option{f};
} else {
    die "proper parameters not passed\n$USAGE";
}

my $fa_hash = &process_fastafile($fafilename);


my $samfile=$ARGV[0];
my $prefix;
if ($samfile=~/(.*?)\./ ) {
   $prefix=$1; 
} else {
    die "Improper sam filename: $samfile";
}

my $micro_deletion_readfile = $prefix.".microdel";
my $snp_readfile = $prefix.".snp";
my $filtered_readfile = $prefix.".filter";

#put unaligned reads and mapped reads that pass the filter to the filtered file
open(my $FILTER, ">", $filtered_readfile) 
    or die "unable to open file $filtered_readfile";



my $hash = {};   
my $duplicate = 0;
my ($XM_hash, $XO_hash, $XG_hash, $NM_hash) = ({}, {}, {}, {});
my $count=1;
#print the uniquely mapped sam file
open(my $NEW_SAM, "<", $samfile) 
    or die "unable to open ct file $samfile";

while ( my $line = <$NEW_SAM> ) {    
    next if ( $line =~ /^@/);    
    my @arr = split("\t", $line);
    my $seq_header = $arr[0];
    my $match = $arr[2];
    if ($match eq '*') {
	#unmatched
	print $FILTER ">$seq_header\n$fa_hash->{$seq_header}";
	next;	
    }
    
}

close $NEW_SAM;

close $FILTER;

exit;


#process the fasta file
#return a hash  
sub process_fastafile {
    my ($fafilename) = @_;
    my ($fa_hash) = {};
    
    my $input_filename = $fafilename;
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open ct file $input_filename";
    
    
    my ($first_part, $second_part) = ("", "");
    while ( my $line = <$INFILE> ) {
	
	if ( $line =~ /^>/) {
	    
	    unless ( $first_part eq '') {
		$fa_hash->{$first_part} = $second_part;
		
		#$seq =~ s/[\n\s\t\r\W]//g; #should I remove other unwanted characters?
		
		($first_part, $second_part) = ("", "");
	    }

	    chomp $line;
	    # print "header: $line\n"; remove ">"
	    my $foo = reverse($line);
	    chop($foo);
	    $first_part = reverse($foo);
	    
	} else {
	    # print $line;
	    $second_part .= $line; 
	}
    }
    
    $fa_hash->{$first_part} = $second_part;    
    return ($fa_hash);    
}


