#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

my %option;
getopts( 's:h', \%option );
my $read_len;

if ( $option{s} ) {
    $read_len= $option{s};
} else {
    die "proper parameters not passed |$option{s}|\n";
}


my $USAGE = "perl create_bedfile_3prime_depletion_sites.pl -s read_len level1_depletion_file.xls > output.bed\n";

my $window = int ($read_len/5);
#print STDERR "window: |$window|\n";
#die;
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
    my ($ident, $chr, $start, $end) = ($arr[0], $arr[4], $arr[5], $arr[6]);
    my $new_start = $start-$window;
    my $new_end = $start + $window;
    print "$chr\t$new_start\t$new_end\t$ident\n";    
 
   #the insertion depletion score is determined based on coverage ratio

}


exit;


