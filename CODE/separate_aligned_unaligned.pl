#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;

#separate alinged and unaligned reads from 
#input fasta file with sequences, the alginemnt is in sam file

my $USAGE = "sepa\n";
my %option;
getopts( 'f:s:h', \%option );
my ($fafilename, $samfile);
if ( $option{f} && $option{s} ) {
    $fafilename = $option{f};
    $samfile = $option{s};
} else {
    die "proper parameters not passed\n$USAGE";
}

my $fa_hash = &process_fastafile($fafilename);

my $hash = {};
    
open(my $SAM, "<", $samfile) 
    or die "unable to open ct file $samfile";

my $out1 = $fafilename.".al";
my $out2 = $fafilename.".ual";

open(my $AL, ">", $out1) 
    or die "unable to open file $out1";

open(my $UAL, ">", $out2) 
    or die "unable to open file $out2";



while ( my $line = <$SAM> ) {    
    next if ( $line =~ /^@/);    
    my @arr = split("\t", $line);
    my $seq_header = $arr[0];
    my $match = $arr[2];
    if ($match eq '*') {
	#unmatched
	print $UAL ">$seq_header\n$fa_hash->{$seq_header}";
	
	
    } else {

	#matched
	#implement checks to prevent multiple print of the same sequence
	if (exists $hash->{$seq_header} ) {
	    next;
	} else {
	    $hash->{$seq_header}++;
	    print $AL ">$seq_header\n$fa_hash->{$seq_header}";
	}
    }    

    
}



close $SAM;
close $AL;
close $UAL;



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


