#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;

my $USAGE = "process_wholegenome_dm6.pl fasta_file > output_fasta\n";

my $fafilename = $ARGV[0];
my ($fa_hash) = &process_fastafile($fafilename);

#my @chr_list = qw/chr2R chr2L chr3R chr3L chrX chrY chr4/;

#foreach my $chr (@chr_list) {
#    if (defined($chr) && defined($fa_hash->{$chr})) {
#	print ">$chr\n$fa_hash->{$chr}";
#    } else {
#	print STDERR "chr:|$chr|$fa_hash->{$chr}";
#    }
#    
#}



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
		
		open(my $FILE, ">", $first_part.".fa") 
		    or die "unable to open file $first_part";
		print $FILE ">$first_part\n$second_part";
		close $FILE;
		

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
#	    chomp $line;
            $second_part .= $line; 
        }
    }
    
    $fa_hash->{$first_part} = $second_part;
    open(my $FILE, ">", $first_part.".fa") 
	or die "unable to open file $first_part";
    print $FILE ">$first_part\n$second_part";
    close $FILE;
    
    return ($fa_hash);    
}

