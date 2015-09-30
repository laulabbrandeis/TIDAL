#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $USAGE = "perl fixed_bin_sites.pl inputfile.txt > test\n";
my $WINDOW_SIZE; # = 1000;
my $chrlen_file; #file with chromosome len info present (also used by FRREC)

my %option;
getopts( 'w:l:h', \%option );
if ( $option{w} && $option{l} ) {
    $WINDOW_SIZE = $option{w};
    $chrlen_file=$option{l};
}

##print "window size: $WINDOW_SIZE\n";
#die;
#my $WINDOW_SIZE = 1000;


#my @stoplist = qw/chrM chrU chrXHet chrYHet chr2LHet chr2RHet chr3LHet chr3RHet chrUextra/;

my $input_filename = $ARGV[0];
open(my $INFILE, "<", $input_filename) 
        or die "unable to open ct file $$input_filename";

my $SKIPLINE = 0;
my $arr2d=[];
my $first_line;
while ( my $line = <$INFILE> ) {
    chomp $line;
#    if ($line=~/^Identifier/) {
    if ($line=~/^SV/) {
	$first_line = $line;
	next;
    }
    
    my @arr = split(/\t/, $line);
    #skip unnecessary chr in stoplist 
#    foreach my $stop (@stoplist) {
#	if ($arr[1]=~/$stop/i) {
#	    $SKIPLINE=1;
#	    last;
#	}
#    } 
#    if ( $SKIPLINE) {
#	$SKIPLINE = 0;
#	next;
#    }
    
    push @{$arr2d}, \@arr;
    
#    my $refsize = @{$ghash->{$gene_name}};  
#   print "num of element: $refsize\n";
    
}


close $INFILE;

#my @sortarr = sort { ($a->[2] cmp $b->[2]) || ($a->[3] <=> $b->[3]) } @{$arr2d};
my @sortarr = sort { ($a->[1] cmp $b->[1]) || ($a->[2] <=> $b->[2]) } @{$arr2d};
my ($lenchr)=&getChrLen($chrlen_file);

#
#my $lenchr = { "chr2L" => 23011544,
#	       "chr2R" =>   21146708,
#	       "chr3L" =>   24543557,
#	       "chr3R" =>   27905053,
#	       "chr4" => 1351857,
#	       "chrX" => 22422827
#	       };
#

#global hash for storage of data
my $allchr = {}; # hash stores associated read number per insertion sites
my $allchr_str = {}; # use this to store strings, the identifiers for each entry
my $allchr_cr = {}; #for coverage ratio

#initialize the chr hash list
foreach my $chr (keys %$lenchr) {
    my $len = $lenchr->{$chr};
    my $chr_hash = {};
    my $chr_str_hash = {};
    my $chr_cr_hash = {};
    $allchr->{$chr}=$chr_hash;
    $allchr_str->{$chr} = $chr_str_hash;
    $allchr_cr->{$chr}= $chr_cr_hash;

    #The limit is assumed to be 1000, unless we hit the last bin    
    my $mod = ($len%$WINDOW_SIZE); 
    my $floor = int($len/$WINDOW_SIZE);  
    
    foreach my $num (1..($floor+1)) { 
	
	my $high = $num*$WINDOW_SIZE;
	my $low = (($num-1)*$WINDOW_SIZE) + 1;
	my $key = $low."-".$high;
#	print "$key\n";
	$chr_hash->{$low}=0;
	$chr_str_hash->{$low}="";
	$chr_cr_hash->{$low}="";
    }
    
#---print the hash
#    foreach my $key (sort {$a <=> $b} keys %$chr_hash ) {
#	
#	print "$key\n";
#    }
#--------------

#have to add the last one separately

#    die;
}


#my $mod = ($end%$WINDOW_SIZE) + 1;




foreach my $line (@sortarr) {
    my $identifier=$line->[0];
    my $chr = $line->[1];
    my $coverage_ratio = $line->[13];
    
#------------ additional code for deletion line
    my $site = $line->[2];
    my $site_3prime = $line->[6];
    if ($site_3prime < $site ) {
	$site = $line->[6];	
	$site_3prime = $line->[2];
    }
    
    my $site_mid =  ($site + $site_3prime)/2; 
    $site_mid = sprintf( "%.0f", $site_mid);
#---------------
#    my $coord  = $line->[2];
    my $coord  = $site_mid;
    my $chr_hash = $allchr->{$chr};
    my $chr_str_hash = $allchr_str->{$chr};
    my $chr_cr_hash = $allchr_cr->{$chr};
#    my $reads = $line->[7];
    my $reads = $line->[8];
#   my $mod = ($coord%$WINDOW_SIZE);
    my $floor = int($coord/$WINDOW_SIZE)*$WINDOW_SIZE;
    my $ceiling = $floor+$WINDOW_SIZE;
    $floor = $floor + 1;

    $chr_hash->{$floor} = $reads + $chr_hash->{$floor};
    $chr_str_hash->{$floor} = $identifier.','.$chr_str_hash->{$floor};
    # need floor, need ceiling... 
    $chr_cr_hash->{$floor} = $coverage_ratio.','.$chr_cr_hash->{$floor}
#    print "$chr\t$coord\tmod: $mod\tfloor: $floor\tceiling: $ceiling\n";    
    #   die;
#    
}

#header= 0: chr,1: coordinate, 2: range, 3: num reads, 4: Identifiers of TE, 5: avg cr ratio
foreach my $chr (keys %$allchr) {
    my $chrhash = $allchr->{$chr};
    my $chr_str_hash = $allchr_str->{$chr};
    my $chr_cr_hash = $allchr_cr->{$chr};
    
    foreach my $bin (sort  {$a <=> $b } keys %$chrhash) {
	my $val = $chrhash->{$bin} ;
	my $low = $bin;
	my $high = $low+$WINDOW_SIZE-1;
	my $key = "$low".'-'."$high";
	my $str = $chr_str_hash->{$bin};
	$str=~ s/,$//;
	
	my $cr_average =""; #the default output
	if ($chr_cr_hash->{$bin} ne "") {
	    my $coverage_ratio_str = $chr_cr_hash->{$bin};
	    $coverage_ratio_str=~ s/,$//;
	    my @arr = split(",", $coverage_ratio_str);	
	    my ($sum, $num);
	    foreach my $el (@arr) {
		$sum+=$el;
		$num++;
	    }
	    
	    $cr_average = $sum/$num;
	    $cr_average = sprintf("%.1f", $cr_average);
	} 

	print "$chr\t$low\t$key\t$val\t$str\t$cr_average\n";
	
    }

}

exit;

sub getChrLen {
    my ($input_filename) = @_;
    my $lenhash={};    
    
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open file $input_filename";
    
    while ( my $line = <$INFILE> ) {
	chomp $line;
	my ($chr, $len) = split(/\t/, $line);
	$lenhash->{$chr} = $len;
    }
    return ($lenhash);
}
