#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


#variable

my $LIMIT; #=100; #size of the read
#my $STOPlen=100; #discard reads below this size, the total size of reads before splitting
my %option;
getopts( 'l:h', \%option );
if ( $option{l} ) {
    $LIMIT = $option{l};
} else {
    die "Inappropriate parameters\n";
}
print STDERR "Length limit: $LIMIT, -10| +5\n";
#the the just uses the substr sequence

my $high_limit = $LIMIT + 5;
my $low_limit = $LIMIT-10 ;

my $input_file = $ARGV[0];

open(my $INFILE, "<", $input_file) 
    or die "unable to open fastq file $input_file";

while ( my $line = <$INFILE> ) {
    chomp $line;
    if ($line=~/^@/) {
#	if ($line=~/^/) {
	my $id_line = $line;
	my ($identifier) = split(/\s/, $id_line);
#	print "|$id_line|\nident: |$identifier|\n";
	
	my $seq = <$INFILE>;
	chomp $seq;
	my $seq_len = length($seq);
#	print "$seq_len\n";
	my $filler = <$INFILE>;
	chomp $filler;
	my $qual_score = <$INFILE>;
	chomp $qual_score;
	my $qual_score_len = length($qual_score);
#	print "$qual_score_len\n";
	
	if (( $seq_len <= $high_limit ) && ( $seq_len >= $low_limit )) {

	    print "$id_line\n$seq\n$filler\n$qual_score\n";
	    
	    
#	    my $count=1;
#	my $first_ident = $identifier.".".$count;
#	my $first_seq =  substr($seq, 0, $LIMIT);
#	my $first_qual_score_str =  substr($qual_score, 0, $LIMIT);
	    
#	print "$first_ident\n$first_seq\n+\n$first_qual_score_str\n";


#	print "qual: $first_qual_score_str\n";
#	$count++;

#	my $second_ident = $identifier.".".$count;
#	my $second_seq =  substr($seq, $LIMIT, $LIMIT);
#	my $second_qual_score_str =  substr($qual_score, $LIMIT, $LIMIT);
	#print "$second_ident\n$second_seq\n+\n$second_qual_score_str\n";
##	print "qual: $second_qual_score_str\n";
	
#	print "ident: |$identifier|\n";
	} else {
	    next;
	}
    } #end  if ($line=~/^@/) {
}

close $INFILE;

#    my $seq_segment = substr($chr_seq, $seq_start, $seq_length);



exit;

#sub process_fastafile {
#    my ($fafilename) = @_;
#    my ($fa_hash) = {};
#    
#    my $input_filename = $fafilename;
#    open(my $INFILE, "<", $input_filename) 
#        or die "unable to open ct file $input_filename";
#    
#    
#    my ($first_part, $second_part) = ("", "");
#    while ( my $line = <$INFILE> ) {
#        
#        if ( $line =~ /^>/) {
#            
#            unless ( $first_part eq '') {
#                $fa_hash->{$first_part} = $second_part;
#                
#                #$seq =~ s/[\n\s\t\r\W]//g; #should I remove other unwanted characters?
#                
#                ($first_part, $second_part) = ("", "");
#            }
#
#            chomp $line;
#            # print "header: $line\n"; remove ">"
#            my $foo = reverse($line);
#            chop($foo);
#            $first_part = reverse($foo);
#            
#        } else {
#            # print $line;
#	    chomp $line;
#            $second_part .= $line; 
#        }
#    }
#    
#    $fa_hash->{$first_part} = $second_part;    
#    return ($fa_hash);    
#}
