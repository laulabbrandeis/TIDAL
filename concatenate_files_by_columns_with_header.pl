#!/usr/bin/perl
use strict;
use warnings;
#use Getopt::Std;

# merge isoforms of the same gene.

my $USAGE = "combine_files_based_on_first_col.pl file1 file2\n";

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
    my $FIRST = 1;
    while ( my $line = <$INFILE> ) {
	chomp $line;
	if ($FIRST==1) {
	    push @header, $line;
	    $FIRST=0;
	    next;
	}
	my @arr = split(/\t/, $line);
	
	my $key = $arr[0];
	$hash->{$key} = \@arr;
	$uniq_hash->{$key}++;
    }
    close $INFILE;
    
}

#---------------------------
my $colsize =0;
foreach my $text ( @header ) {
    print "$text\t";    
    my @arr = split(/\t/, $text);
    $colsize = @arr;
}
print "\n";
#

foreach my $gene_key (sort { $a<=>$b } keys %$uniq_hash  ) {
#    print "$gene_key";
    foreach my $lib_name ( @name_arr ) {
#    foreach my $lib_name (sort keys %$name_tag ) {
	my $hash = $name_tag->{$lib_name};

	if ( exists $hash->{$gene_key} ) {
	    my @val = @{$hash->{$gene_key}};
	    foreach my $num (@val) {
		print "$num\t";
	    }	    
	} else {
	    foreach my $num (1..$colsize) {
		print "0\t";
	    }
#	    print "\t0\t0\t0\t0";
	}
    }
    print "\n";    
}

foreach my $lib_name ( @name_arr ) {
    print STDERR "$lib_name\n";   
}
exit;

