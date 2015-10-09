#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;

#produce two files that uses the input filename in uq format
#extract the front and end of the read based on the limit variable
# and adds the .front and .end extension. The 
my $LIMIT = 30;

my %option;
getopts( 'l:h', \%option );
if ( $option{l} ) {
    $LIMIT = $option{l};
}

my $input_filename = $ARGV[0];
open(my $INFILE, "<", $input_filename) 
    or die "unable to open ct file $input_filename";

my $out1 = $input_filename.".front";
my $out2 = $input_filename.".end";

open(my $FR, ">", $out1) 
    or die "unable to open file $out1";

open(my $ED, ">", $out2) 
    or die "unable to open file $out2";


my ($first_part, $second_part) = ("", "");
while ( my $line = <$INFILE> ) {
    chomp $line;
    
    if ( $line =~ /^>/) {
	unless ( $first_part eq '') {

	    #need a length check to determine if the input sequence is long enough

	    my $seq = $second_part;
	    $seq =~ s/[\n\s\t\r\W]//g; #should I remove other unwanted characters?
	    
	    #the first part is the identifier so need to make changes there
	    #get the first 25 bases, get the last 25 bases
	    my $fseq= substr($seq, 0, $LIMIT);
	    my $len = length($seq);
	    my $estart = $len - $LIMIT;
	    my $eseq= substr($seq, $estart, $LIMIT);
	    

	    print $FR "$first_part\n$fseq\n";
	    print $ED "$first_part\n$eseq\n";


	    ($first_part, $second_part) = ("", "");
	}
	
	
	# print "header: $line\n"; remove ">"
	#my $foo = reverse($line);
	#chop($foo);
	#$first_part = reverse($foo);
	$first_part =$line;
	
    } else {
	# print $line;
	$second_part .= $line; 
    }

}

#this is for the last sequence
my $seq = $second_part;
$seq =~ s/[\n\s\t\r\W]//g; #should I remove other unwanted characters?

#the first part is the identifier so need to make changes there
#get the first 25 bases, get the last 25 bases

#need a length check to determine if the input sequence is long enough

my $fseq= substr($seq, 0, $LIMIT);
my $len = length($seq);
my $estart = $len - $LIMIT;
my $eseq= substr($seq, $estart, $LIMIT);


print $FR "$first_part\n$fseq\n";
print $ED "$first_part\n$eseq\n";


($first_part, $second_part) = ("", "");


close $FR;
close $ED;


