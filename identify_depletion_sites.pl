#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;

#Identify deletion site given two sam files where the front and end of the read is mapped to the masked genome.
# The goal is to identify reads that do not map to the masked genome, but the 5' and 3' end does map to the genome  

# -f front.gen.sam
# -e end.gen.sam


my %option;
getopts( 'f:e:h', \%option );
my ($gen_front_sam, $gen_end_sam );
if ( $option{f} && $option{e} ) {
    $gen_front_sam = $option{f};
    $gen_end_sam = $option{e};

} else {
    die "proper parameters not passed\n";
}


my $uhash = {};
#my ($fhash) = &createSamHash($frontsam, $uhash);
#my ($ehash) =  &createSamHash($endsam, $uhash);
my ($fhash) = &createSamHash($gen_front_sam);
my ($ehash) =  &createSamHash($gen_end_sam);

#print the header
#print "Identifier\tstrand\tchr\tcoord\tstrand\tchr\tcoord\tDel len\n";
print "Identifier\t'5' seq\t'3' seq\t'5' strand\t'5' chr\t'5' coord\t'3' strand\t'3' chr\t'3' coord\tDel len\t'5' SPC\t'5' corr chr\t'5' corr coord\t'3' SPC\t'3' corr chr\t'3' corr coord\n";
foreach my $ident (keys %$ehash) {
    my $e_ref = $ehash->{$ident};
#split read with mapping in both 5' and 3' end
    if (exists $fhash->{$ident} ) {
	my $f_ref = $fhash->{$ident};
	
	if ((@$e_ref > 1) || (@$f_ref > 1)) {
	    # The multiple mapping on either the front on end 22mers
	    
	} elsif ((@$e_ref == 1) || (@$f_ref == 1)) {
	    # consider only the uniquely mapped reads
#-------------
	    my ($seq, $count)=split(":", $ident);
	    my $seq_len = length($seq);
	    my $prime5_seq = substr($seq,0,22) ;
	    my $index_3prime = length($seq) - 22;
	    my $prime3_seq = substr($seq,$index_3prime,22);
#---------------
	    my $arr1 = shift @{$f_ref};
	    my ($a1, $a2, $a3) = @$arr1; #strand, chr, coord 
	    my $strand;
	    if ($a1==0) {
		$strand="+";
	    } elsif ($a1==16) {
		$strand="-";
	    }
#	    print "$ident\t$strand\t$a2\t$a3\t5'";	    

	    my $arr2 = shift @{$e_ref};
	    my ($b1, $b2, $b3) = @$arr2; #strand, ident, coord 
	    
	    my $nstrand;
	    if ($b1==0) {
		$nstrand="+";
	    } elsif ($b1==16) {
		$nstrand="-";
	    }
#	    my @el_arr = split('\|', $b2);
#	    my $transposon = pop @el_arr;

	    my $diff;
	    if ($a3> $b3) {
		$diff = $a3-$b3;
	    } elsif ($b3 > $a3) {
		$diff = $b3-$a3;
	    } else {
		$diff = $b3-$a3;
	    }

#	    if (($a1==$b1 ) && ($a2 eq $b2) && (!($diff))) {
#		print STDERR "$ident\n$strand\n$a2\n|$a3|";
#		print STDERR "\n$nstrand\n$b2\n|$b3|\n$diff\n";	
#		die;
#	    }
		
	    
	    #have to be in the same chr and same strand
	    #a1=strand, a2=chr, a3=coord 
#	    if (($a1==$b1 ) && ($a2 eq $b2) && ($diff > 101)) {
	    if (($a1==$b1 ) && ($a2 eq $b2) && ($diff > $seq_len))  {
		print "$ident\t$prime5_seq\t$prime3_seq\t$strand\t$a2\t$a3";
		print "\t$nstrand\t$b2\t$b3\t$diff";
		if ($strand eq "-") {
		    print "\t+\t$b2\t$b3\t+\t$a2\t$a3";
		} else {
		    #strand pos
		    print "\t$strand\t$a2\t$a3\t$nstrand\t$b2\t$b3";
		}
		print "\n";
#		die;
#		if (!($diff)) {
#		    print STDERR "$ident\t$strand\t$a2\t$a3";
#		    print STDERR "\t$nstrand\t$b2\t$b3\t$diff\n";
#		}
		
	    } else {
		
	    }

	}
    } else {
	next;
    }
    
    
}

#undef %$fhash;
#undef %$ehash;




#my @keys = keys %$uhash;
#my $size = @keys;
#print "size of uhash: $size\n";



my @keys = keys %$fhash;
my $size = @keys;
#print "size of |fhash|: $size\n";

@keys = keys %$ehash;
$size = @keys;
#print "size of |ehash|: $size\n";


exit;


sub createSamHash {
#    my ($frontsam, $uhash) = @_;
   my ($frontsam) = @_;
 
   my $fhash = {};
    
    open(my $SAM, "<", $frontsam) 
	or die "unable to open sam file $frontsam";
    
    while ( my $line = <$SAM> ) {    
	next if ( $line =~ /^@/);    
	my @arr = split("\t", $line);
	my $seq_header = $arr[0];
	my $match = $arr[2];
#	#ignore matches to transposon hits that have \
#	if ($match=~/\\/) {
#	    next;
#	}
	
	
	#ignore hits to chr*Het
	if ($match=~/^chr/i) {
	    if ($match=~/Het$/i) {
		next;
	    } elsif ($match=~/chrU/i) {
		next;
	    } 
	}
	
	


	#   my $str_arr = [$arr[1], $arr[2], $arr[3], $arr[9]];
	my $str_arr = [$arr[1], $arr[2], $arr[3]];

	if ($match eq '*') {
	    #unmatched reads
#	print $UAL ">$seq_header\n$fa_hash->{$seq_header}";
	    
	    
	} else {
	    #matched
#	    $uhash->{$seq_header}++;
	    #implement checks to prevent multiple print of the same sequence
	    push @{$fhash->{$seq_header}}, $str_arr;
	} 
	
    }
    
    close $SAM;
    
    return ($fhash);
}






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
	    $second_part .= $line; 
	}
    }
    
    $fa_hash->{$first_part} = $second_part;    
    return ($fa_hash);    
}


