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
my $window = int ($read_len/5);

# merge isoforms of the same gene.

my $USAGE = "combine_files_based_on_first_col.pl file1 file2\n";

#the total read count is halved in this for normalization

my $name_tag={};
my @name_arr=();
my $uniq_hash={}; #needed when for entries present in one, but not the other

my @header = ();
foreach my $filename (@ARGV) {
#    print "file: $filename\n";
    my $tag; 
    if ($filename=~/(.*?)\./) {
	#the all the character before first dot is extracted as tag name
	$tag=$1;
#	print "tag: $tag\n";
	$name_tag->{$tag}={};
	push @name_arr, $tag;
    }
    my $hash=$name_tag->{$tag};  
    
#-------
    open(my $INFILE, "<", $filename) 
        or die "unable to open file: $filename";
    
    while ( my $line = <$INFILE> ) {
	chomp $line;

	next if ($line=~/^[\n\s]/);
	my @arr = split(/\t/, $line);
	my $width=$arr[6];
	my $norm_factor= $width/$window;
	my $key = $arr[3];
	my $val = $arr[4]/$norm_factor;
	$val = sprintf( "%.1f", $val);
	$hash->{$key} = $val;
	$uniq_hash->{$key}++;
    }
    close $INFILE;
    
}

print "Gene\tPseud_len\t5prime_coverage\t3prime_coverage\n";
foreach my $gene_key ( sort {$a<=>$b} keys %$uniq_hash ) {
    print "$gene_key\t0";
#    foreach my $lib_name (sort keys %$name_tag ) {
    foreach my $lib_name ( @name_arr ) {
	my $hash = $name_tag->{$lib_name};
	
	if ( exists $hash->{$gene_key} ) {
	    print "\t$hash->{$gene_key}";
	} else {
	    print "\t0";
	}
    }
    print "\n";    
}

#foreach my $lib_name (sort keys %$name_tag ) {
foreach my $lib_name ( @name_arr ) {
    print STDERR "$lib_name\n";   
}
exit;
