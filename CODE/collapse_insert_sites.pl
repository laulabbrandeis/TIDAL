#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $LIMIT=300; ##this is the cluster threshold
my $MAX_LIMIT = 600; # this is the max cluster limit
my $read_threshold = 10;
#span threshold, chr_ (82-22), or 60-22
#for 75 base, 53 in the theoretical max, but reads are sometimes trimmed
#for 125, 103 in the theoretical max
my $chr_distance_threshold = 150; 
my $BSR_threshold = 80;


my %option;
getopts( 'd:l:r:t:h', \%option );

if (( $option{l} ) &&  ( $option{r} ) &&  ( $option{d} ) &&  ( $option{t} )) {
    $LIMIT = $option{l};
    $read_threshold = $option{r};
    $chr_distance_threshold = $option{d};
    $BSR_threshold=$option{t};
}

#chr_distance_threshold should be (0.5 the length - 22 ) of read length
$chr_distance_threshold = int ($chr_distance_threshold/2) - 22;

#print "chr_threshold: $chr_distance_threshold\n";
#exit;

my $input_filename = $ARGV[0];
open(my $INFILE, "<", $input_filename) 
        or die "unable to open insert file $input_filename";


my $arr2d=[];
my $first_line;
while ( my $line = <$INFILE> ) {
    chomp $line;
    if ($line=~/^Identifier/) {
	$first_line = $line;
	next;
    }

    my @arr = split(/\t/, $line);
#    my $gene_name = $arr[0];
#    print "gene name: $gene_name\n";
    
    push @{$arr2d}, \@arr;

#    my $refsize = @{$ghash->{$gene_name}};  
#   print "num of element: $refsize\n";
    
}


close $INFILE;

#my @sortarr = sort { ($a->[2] cmp $b->[2]) || ($a->[3] <=> $b->[3]) } @{$arr2d};
my @sortarr = sort { ($a->[2] cmp $b->[2]) || ($a->[6] cmp $b->[6]) || ($a->[3] <=> $b->[3]) } @{$arr2d};

my $output_arr=[];

my ($chr, $chr_start, $chr_end, $te, $te_start, $te_end, $num_collapsed, $num_str, $blat_score) = ('', '', '', '', '', '', '', ''); 
my ($FIRST) = 1;
#my $LIMIT=300;
#my $MAX_LIMIT = 600;
my $insert_num= 1;
foreach my $line ( @sortarr ) {
# my $blat_score = $line->[9];
# next if ($blat_score > 90);
#

#    if ($chr, $chr_start, $chr_end, $te, $te_start, $te_end, $num_collapsed=='' ) {
    if ($FIRST == 1) {
	$chr= $line->[2];
	$chr_start =$line->[3];
	$chr_end = $line->[3]; 
	$te = $line->[6]; 
	$te_start = $line->[7]; 
	$te_end = $line->[7]; 
	$num_collapsed = 1;
	$num_str = $line->[3];
	$blat_score = $line->[9];
	$FIRST=0;
    } else {
	#is this a new transposon
	if (($chr eq $line->[2]) &&  ($te eq $line->[6]) &&  (($chr_end+$LIMIT) > $line->[3] )) {
	    if ( ($line->[3] - $chr_start) > $MAX_LIMIT) {  
		#create a new entry if the bin is becoming too large
		push @{$output_arr}, [$insert_num,$chr,$chr_start,$chr_end,$te,$te_start,$te_end,$num_collapsed, $num_str, $blat_score];
		$insert_num++;
		
		$chr= $line->[2];
		$chr_start =$line->[3];
		$chr_end = $line->[3]; 
		$te = $line->[6]; 
		$te_start = $line->[7]; 
		$te_end = $line->[7]; 
		$num_collapsed = 1;
		$num_str = $line->[3];
		$blat_score = $line->[9];
	    } else {
		
		$chr_end = $line->[3];
		$te_end = $line->[7]; 
		$num_collapsed++;
		$num_str = $num_str.','.$line->[3];
		$blat_score = $blat_score+$line->[9];
	    }
	} else {
#	    print "$insert_num\t$chr\t$chr_start\t$chr_end\t$te\t$te_start\t$te_end\t$num_collapsed\n";	    
	    push @{$output_arr}, [$insert_num,$chr,$chr_start,$chr_end,$te,$te_start,$te_end,$num_collapsed, $num_str, $blat_score];

	    $insert_num++;
	    $chr= $line->[2];
	    $chr_start =$line->[3];
	    $chr_end = $line->[3]; 
	    $te = $line->[6]; 
	    $te_start = $line->[7]; 
	    $te_end = $line->[7]; 
	    $num_collapsed = 1;
	    $num_str = $line->[3];
	    $blat_score = $line->[9];
	}


    }    
}
push @{$output_arr}, [$insert_num,$chr,$chr_start,$chr_end,$te,$te_start,$te_end,$num_collapsed, $num_str, $blat_score];
#print "$insert_num\t$chr\t$chr_start\t$chr_end\t$te\t$te_start\t$te_end\t$num_collapsed\n";	    
  
print "SV#\tChr\tChr_coord_5p\tChr_coord_3p\tTE\tTE_coord_start\tTE_coord_end\tReads_collapsed\tChr_Coord_Dist\tSymmetry\tavg_blat_score\n";
my $count=1;
foreach my $line ( sort { ($a->[1] cmp $b->[1]) || ($a->[2] <=> $b->[2]) }  @{$output_arr}) {
    my $first_el = shift @$line; #remove the first element, which is insert num
#    my $sum_blat_score = pop @$line;
#    my $avg_blat_score = ;
#    my $num_str = pop @$line;

    # read in each line, and decide if it meets the filter criteria
    my ($chr, $chr_start, $chr_end, $te, $te_start, $te_end, $read_collapsed, $num_str, $sum_blat_score) = @$line;


    # my $ident= $line->[0].":".$line->[1];
    my $chr_dist = $chr_end - $chr_start; 
 
    my $avg_blat_score = $sum_blat_score/$read_collapsed;
    $avg_blat_score = sprintf("%.2f", $avg_blat_score);

    #avg blat score filter 
    next if ($avg_blat_score > $BSR_threshold );
  
    #filter for read count
    next if ($read_collapsed < $read_threshold);
    #filter for chr_dist (end - start)
    next if ($chr_dist < $chr_distance_threshold);
    
    #-------- calculate the symmetry ---------------
    my @num_arr = split(/,/, $num_str);
    my $mid_point = $chr_start + ($chr_dist/2);
    
    my ($part1, $part2) = (0, 0);
    
    foreach my $num (@num_arr) {
	if ($num <= $mid_point) {
	    $part1++; 
	} else {
	    #num is greater than midpoint	    
	    $part2++;  
	}
    }
    #-------------- end of symmetry calculation -------------
    #apply region filter
    #chr 3R region filter chr3R:19,440,438-19,451,950
    #updated to chr3R:19,441,000-19,451,000
    my ($filter_chr, $filter_chr_start, $filter_chr_end);
    $filter_chr= "chr3R";
    $filter_chr_start = 19441000;
    $filter_chr_end= 19451000;
    
    if ($chr eq $filter_chr) {
	if ((( $chr_start > $filter_chr_start ) && ( $chr_start < $filter_chr_end )) || (( $chr_end > $filter_chr_start ) && ( $chr_end < $filter_chr_end ))) {
	    
	    next;
	}
    }
    
#chrX:23,109,831-23,541,907
    $filter_chr= "chrX";
    $filter_chr_start = 23109831;
    $filter_chr_end= 23541907;
    if ($chr eq $filter_chr) {
	if ((( $chr_start > $filter_chr_start ) && ( $chr_start < $filter_chr_end )) || (( $chr_end > $filter_chr_start ) && ( $chr_end < $filter_chr_end ))) {
	    next;
	}
    }
    
#chrX:22,380,257-22,389,592
    $filter_chr= "chrX";
    $filter_chr_start = 22380257;
    $filter_chr_end= 22389592;
    if ($chr eq $filter_chr) {
	if ((( $chr_start > $filter_chr_start ) && ( $chr_start < $filter_chr_end )) || (( $chr_end > $filter_chr_start ) && ( $chr_end < $filter_chr_end ))) {
	    next;
	}
    }
    
#chr2L:23,315,576-23,449,819
    $filter_chr= "chr2L";
    $filter_chr_start = 23315576;
    $filter_chr_end= 23449819;
    if ($chr eq $filter_chr) {
	if ((( $chr_start > $filter_chr_start ) && ( $chr_start < $filter_chr_end )) || (( $chr_end > $filter_chr_start ) && ( $chr_end < $filter_chr_end ))) {
	    next;
	}
    }



    #----- end of region specific filter ---------------
    my $store_str = "$count\t$chr\t$chr_start\t$chr_end\t$te\t$te_start\t$te_end\t$read_collapsed\t$chr_dist\t$part1-$part2\t$avg_blat_score\n";
    print "$store_str";
    
    $count++;
    
}


exit;

