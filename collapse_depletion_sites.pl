#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $LIMIT=300;
my $MAX_LIMIT = 600;
my $read_threshold = 10;
my $repeat_maskerfile;
my $table_lookup_file;

my %option;
#getopts( 'd:l:r:t:h', \%option );
getopts( 'l:r:m:t:h', \%option );
#if (( $option{l} ) &&  ( $option{r} ) &&  ( $option{d} ) &&  ( $option{t} )) {
if (( $option{l} ) &&  ( $option{r} ) &&  ( $option{m} ) && ( $option{t} ) ) {
    $LIMIT = $option{l};
    $read_threshold = $option{r};
    $repeat_maskerfile = $option{m};
    $table_lookup_file = $option{t};
}

#------------
#my $repeat_maskerfile = "/nlmusr/reazur/linux/NELSON/Genome_resequence/annotation/repmasker_track.txt";
#my $repeat_maskerfile = "/nlmusr/reazur/linux/NELSON/TIDAL/annotation/repmasker_dm6_track.txt";
my ($repbase_to_flybase) = &getRepbaseToFlybaseLookup($table_lookup_file);

open(my $REPFILE, "<", $repeat_maskerfile) 
    or die "unable to open repeat masker file $repeat_maskerfile";
my $rep_hash = {};

while ( my $line = <$REPFILE> ) {
    chomp $line;
    if ($line=~/^#bin/) {
#	$first_line = $line;
#	print STDERR "|$line|\n";
	next;
    }



    my @arr = split(/\t/, $line);
    my $chr = $arr[5];
    my $start = $arr[6];
    my $end = $arr[7];
    my $repname = $arr[10];

    foreach my $num ($start .. $end ) {
	my $key = $chr.",".$num;
	$rep_hash->{$key} = $repname ;
#	print STDERR "$num,";
    }
}

close $REPFILE;

#die;
#------------
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
#foreach my $line (@{$arr2d}) {
#    if (!defined($line->[12])) {
#	print STDERR "@$line\n";
#
#    }
#}


my @sortarr = sort { ($a->[11] cmp $b->[11]) || ($a->[12] <=> $b->[12]) || ($a->[14] cmp  $b->[14]) || ($a->[15] <=> $b->[15])} @{$arr2d};
#my @sortarr = sort { ($a->[11] cmp $b->[11]) || ($a->[12] <=> $b->[12]) || ($a->[9] <=>  $b->[9]) } @{$arr2d};

my $output_arr=[];

my ($chr, $chr_start, $chr_end, $chr_3p, $chr_start_3p, $chr_end_3p, $num_collapsed, $del_len) = ('', '', '', '', '', '', '', ''); 
my ($FIRST) = 1;
#my $LIMIT=300;
#my $MAX_LIMIT = 600;
my $insert_num= 1;

#9=del_len (diff betstart and end
#10= strand
#11= 5'chr
#12= 5' start
#13= strand
#14= 3' chr
#15= 3' start


foreach my $line ( @sortarr ) {

    if ($FIRST == 1) {
	$chr= $line->[11];
	$chr_start =$line->[12];
	$chr_end = $line->[12]; 
	$chr_3p = $line->[14]; 
	$chr_start_3p = $line->[15]; 
	$chr_end_3p = $line->[15]; 

	$num_collapsed = 1;
	$del_len = $line->[9];
	$FIRST=0;
    } else {
	#is this a new transposon
	if (($chr eq $line->[11]) &&  ($chr_3p eq $line->[14]) &&  (($chr_start+$LIMIT) > $line->[12] ) && ($chr_start <= $line->[12] ) && (($chr_start_3p+$LIMIT) > $line->[15]) && ($chr_start_3p <= $line->[15])) {
	    
	    $chr_end = $line->[12];
	    $chr_end_3p = $line->[15]; 
	    $num_collapsed++;
	    $del_len = 	$del_len + $line->[9];
#	    }
	} else {
#	    print "$insert_num\t$chr\t$chr_start\t$chr_end\t$te\t$te_start\t$te_end\t$num_collapsed\n";	    
	    push @{$output_arr}, [$insert_num,$chr,$chr_start,$chr_end,$chr_3p,$chr_start_3p,$chr_end_3p,$num_collapsed,$del_len];

	    $insert_num++;

	    $chr= $line->[11];
	    $chr_start =$line->[12];
	    $chr_end = $line->[12]; 
	    $chr_3p = $line->[14]; 
	    $chr_start_3p = $line->[15]; 
	    $chr_end_3p = $line->[15]; 
	    $num_collapsed = 1;
	    $del_len = $line->[9];	    
	}	
    }    
}

push @{$output_arr}, [$insert_num,$chr,$chr_start,$chr_end,$chr_3p,$chr_start_3p,$chr_end_3p,$num_collapsed,$del_len];
#print "$insert_num\t$chr\t$chr_start\t$chr_end\t$te\t$te_start\t$te_end\t$num_collapsed\n";	    
  
print "SV#\tChr_5p\tChr_coord_5p_start\tChr_coord_5p_end\tChr_3p\tChr_coord_3p_start\tChr_coord_3p_end\trepName\tReads_collapsed\tavg_del_len\n";
my $count=1;
foreach my $line ( sort { ($a->[1] cmp $b->[1]) || ($a->[2] <=> $b->[2]) }  @{$output_arr}) {
    my $first_el = shift @$line; #remove the first element, which is insert num

    # read in each line, and decide if it meets the filter criteria
#    my ($chr, $chr_start, $chr_end, $te, $te_start, $te_end, $read_collapsed, $num_str, $sum_blat_score) = @$line;
    my ($chr, $chr_start, $chr_end,$chr_3p,$chr_start_3p,$chr_end_3p,$read_collapsed,$sum_del_len) = @$line;

 
    my $avg_del_score = $sum_del_len/$read_collapsed;
    $avg_del_score = sprintf("%.0f", $avg_del_score);

    #filter for read count
    next if ($read_collapsed < $read_threshold);
    #filter for chr_dist (end - start)
#    next if ($chr_dist < $chr_distance_threshold);
    
    if ($chr_end_3p < $chr_start) {
	my ($a1, $a2, $a3, $a4) = ($chr_start, $chr_end, $chr_start_3p, $chr_end_3p);
	$chr_start =$a3;
	$chr_end = $a4; 
	$chr_start_3p = $a1;
	$chr_end_3p = $a2;
    } 

#-----------------
    my $site_mid =  ($chr_start + $chr_end_3p)/2; 
    $site_mid = sprintf( "%.0f", $site_mid);
    my $key = $chr.",".$site_mid;
    my $repname = "";
    if (exists $rep_hash->{$key}) {
	$repname = $rep_hash->{$key};
    }
#some processing to remove "(CAG)n", "AT_rich" from repreat masker annotation. 
    if ($repname=~/\(.*\)n$/) {
	$repname="";
    } elsif ($repname=~/[-_]rich$/) {
	$repname="";
    }
    my $flybase_name = "";
    if (exists $repbase_to_flybase->{$repname}) {
	$flybase_name = $repbase_to_flybase->{$repname};
    } 
#---------------begin filter for specific regions ----------------
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
    
#------------- end of region specific filter ---------------
#    my $store_str = "$count\t$chr\t$chr_start\t$chr_end\t$chr_3p\t$chr_start_3p\t$chr_end_3p\t$read_collapsed\t$avg_del_score\n";
#    my $store_str = "$count\t$chr\t$chr_start\t$chr_end\t$chr_3p\t$chr_start_3p\t$chr_end_3p\t$repname\t$read_collapsed\t$avg_del_score\n";
    my $store_str = "$count\t$chr\t$chr_start\t$chr_end\t$chr_3p\t$chr_start_3p\t$chr_end_3p\t$flybase_name\t$read_collapsed\t$avg_del_score\n";
    print "$store_str";
    
    $count++;
    
}


exit;

#get the lookup table to convert from repbase to flybase
#reutrns a hash with repbase name is key and flybase name is value 
sub getRepbaseToFlybaseLookup {
    my ($classification_file) = @_; #"Tidalbase_Dmel_TE_classifications_2015.txt";
    
    my $repbase_to_flybase = {};
    my $length_hash = {};
    my $input_filename = $classification_file;
    my $classification_str = "";
    open(my $INFILE, "<", $input_filename) 
	or die "unable to open file $input_filename";
    while ( my $line = <$INFILE> ) {
	
	chomp $line;    
	if ($line=~/^TidalBase/) {
	    next;
	}
	
	my @arr = split(/\t/, $line);
	my $flybase_name = $arr[2];
	my $repbase_name = $arr[7];
	my $length = $arr[4];
	if (defined ($repbase_name) && ($repbase_name ne "")) {
	    if (exists $repbase_to_flybase->{$repbase_name}) {
#		print STDERR "Exists |$repbase_name| => $flybase_name\n";
		if ($length_hash->{$repbase_name} <= $length) {
		    $repbase_to_flybase->{$repbase_name} = $flybase_name;
		    $length_hash->{$repbase_name}=$length;
		} else {
		    next;
		}
		
	    } else {
		$repbase_to_flybase->{$repbase_name} = $flybase_name;
		$length_hash->{$repbase_name}=$length;
	    }
	    #    $classification_str.= $line;
	} else {
#	    print STDERR "skipped $flybase_name\n";
	}
    }
    close $INFILE;
    
    return ($repbase_to_flybase);   
#foreach my $key (keys %$repbase_to_flybase) {
#    print "Key: |$key|; value: $repbase_to_flybase->{$key}\n";
#}
    
}
