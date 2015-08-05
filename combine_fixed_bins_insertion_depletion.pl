#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;


my $USAGE = "perl combine_fixed_bins_insertion_depletion.pl -i insertion file -d depletion file -p libname> output\n";

my ($insertion_file, $depletion_file, $libname);

my %option;
getopts( 'i:d:p:h', \%option );
if ( $option{i} && $option{d} && $option{p}) {
    $insertion_file=$option{i};
    $depletion_file=$option{d};
    $libname=$option{p};
}

my ($insert_hash) = &fileToHash($insertion_file);
my ($depletion_hash) = &fileToHash($depletion_file);


#my ($insert_hash) = &fileToHashInsertion($insertion_file);
#my ($depletion_hash) = &fileToHashDepletion($depletion_file);
#--------------------
my $arr2d=[];
#print header
print "Chrom\tinterval\tspan\tInsert_Reads\tInsert_Count\tInsert_Coverage_Ratio\tFREEC_ratio\tDepletion_Reads\tDepletion_Count\tDepletion_Coverage_Ratio\tInsert_code\tDepletion_code\tbin_code\tlibname\tMark_All\tMark_CR4\n";
foreach my $key (keys %$insert_hash) {
    my $insert_str = $insert_hash->{$key};
    my $depletion_str = $depletion_hash->{$key}; 
    my ($i1, $i2, $i3, $i4, $i5, $i6, $i7) = split(/\t/, $insert_str);
    my ($d1, $d2, $d3, $d4, $d5, $d6) = split(/\t/, $depletion_str);
 
    my $insert_code = $i1."_".$i4."_".$i2;
    my $depletion_code = $d1."_".$d4."_".$d2;
    my $bin_code = $i1."_".$i2;

#code for Mark_All and Mark_CR4 column 
    my ($mark_all, $mark_cr4)=(0,0);
    if ($i5 ne ""){ 
	if ($i5>0) {
	    $mark_all++;
	}
    }
    if ($d5 ne ""){ 
	if ($d5>0) {
	    $mark_all--;
	}
    }
    if ($i6 ne ""){ 
	if ($i6>=4) {
	    $mark_cr4++;
	}
    }
    if ($d6 ne ""){ 
	if ($d6>=4) {
	    $mark_cr4--;
	}
    }
#put everything in an array
#    print "$i1\t$i2\t$i3\t$i4\t$i5\t$d4\t$d5\t$insert_code\n";
    push @{$arr2d}, [$i1, $i2, $i3, $i4, $i5, $i6, $i7, $d4, $d5, $d6, $insert_code, $depletion_code, $bin_code, $libname, $mark_all, $mark_cr4]; 
    
}

#print a sorted array
foreach my $row_ref (sort { ($a->[0] cmp $b->[0]) || ($a->[1] <=> $b->[1]) } @{$arr2d} ) {
    my @arr = @$row_ref;
    my $str = "";
    foreach my $el (@arr) {
#	print "$el\t";
	$str.= "$el\t";
    }
    $str=~s/\t$//;
    print "$str\n";
}


exit;


#return hash 
sub fileToHash {
    my ($input_filename) = @_;
    my $hash = {};
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open file $input_filename";
    
    while ( my $line = <$INFILE> ) {
	chomp $line;
	my @arr = split(/\t/, $line);
	my $key = $arr[0]."\t".$arr[1];
	my $reads = $arr[3];
	my $identifier = $arr[4];
	my $ident_count = 0;
	if (defined($identifier)) {
	    if ($identifier eq "") {
		 $ident_count=0;
	    } else {
		my $num = $identifier =~tr/,//;
		$ident_count = $num + 1;
	    }
	} else {
	    $ident_count=0;
	}

	my $coverage_ratio="";
	if (defined $arr[5]) {
	    $coverage_ratio= $arr[5];
	}
	if (defined  $arr[6]) {
	    my $freec_ratio = $arr[6];
	    $hash->{$key}= $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$reads."\t".$ident_count."\t".$coverage_ratio."\t".$freec_ratio;
	} else {
	$hash->{$key}= $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$reads."\t".$ident_count."\t".$coverage_ratio;
	}  
    }
    close $INFILE;
    return ($hash);
}


#return hash 
sub fileToHashDepletion {
    my ($input_filename) = @_;
    my $hash = {};
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open file $input_filename";
    
    while ( my $line = <$INFILE> ) {
	chomp $line;
	my @arr = split(/\t/, $line);
	my $key = $arr[0]."\t".$arr[1];
	my $reads = $arr[3];
	my $identifier = $arr[4];
	my $ident_count = 0;
	if (defined($identifier)) {
	    my $num = $identifier =~tr/,//;
	    $ident_count = $num + 1;
	} else {
	    $ident_count=0;
	}

	my $coverage_ratio="";
	if (defined $arr[5]) {
	    $coverage_ratio= $arr[5];
	}
#	if (defined  $arr[6]) {
#	    my $freec_ratio = $arr[6];
#	    $hash->{$key}= $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$reads."\t".$ident_count."\t".$coverage_ratio."\t".$freec_ratio;
#	} else {
	$hash->{$key}= $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$reads."\t".$ident_count."\t".$coverage_ratio;
#	}  
    }
    close $INFILE;
    return ($hash);
}

#return hash 
sub fileToHashInsertion {
    my ($input_filename) = @_;
    my $hash = {};
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open file $input_filename";
    
    while ( my $line = <$INFILE> ) {
	chomp $line;
	my @arr = split(/\t/, $line);
	my $key = $arr[0]."\t".$arr[1];
	my $reads = $arr[3];
	my $identifier = $arr[4];
	my $ident_count = 0;
	if (defined($identifier) && ($identifier ne "")) {
	    my $num = $identifier =~tr/,//;
	    $ident_count = $num + 1;
	} else {
	    $ident_count=0;
	}
	my $coverage_ratio= $arr[5];
#	if (defined  $arr[6]) {
	my $freec_ratio = $arr[6];
	$hash->{$key}= $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$reads."\t".$ident_count."\t".$coverage_ratio."\t".$freec_ratio;
#	} else {
#	    $hash->{$key}= $arr[0]."\t".$arr[1]."\t".$arr[2]."\t".$reads."\t".$ident_count."\t".$coverage_ratio;
#	}  
    }
    close $INFILE;
    return ($hash);
}



