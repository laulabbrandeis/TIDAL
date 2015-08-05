#!/usr/bin/perl
use strict;
use warnings;

use Getopt::Std;

#separate alinged and unaligned reads from 
#input fasta file with sequences, the alginemnt is in sam file

# -f front.gen.sam
# -e end.TE.sam

# -r front.Te.sam
# -n end.gen.sam


my $USAGE = "sepa\n";
my %option;
getopts( 'f:e:n:r:h', \%option );
my ($frontsam, $endsam, $endGENsam, $frontTEsam);
if ( $option{f} && $option{e} ) {
    $frontsam = $option{f};
    $endsam = $option{e};
    $endGENsam= $option{n};
    $frontTEsam= $option{r};

} else {
    die "proper parameters not passed\n$USAGE";
}

#my ($newhash, $len) =  &createSamHashTE($endsam);
#die;
#-------------------------------
#my $text = 'Dbuz\INE-1';
#if ($text=~/\\/) {
#    print "found match\n";
#} else {
#    print "no match found\n";
#} 
#--------------------------------


my $uhash = {};
#my ($fhash) = &createSamHash($frontsam, $uhash);
#my ($ehash) =  &createSamHash($endsam, $uhash);
my ($fhash) = &createSamHash($frontsam);
#my ($stop_hash) = &createSamHash($endGENsam);
my ($ehash, $lenhash) =  &createSamHashTE($endsam);

#print the header
print "Identifier\tstrand\tchr\tcoord\t5'/3' map gen\tstrand\tTE\tcoord\tnum_maps_concensus_TE\n";
foreach my $ident (keys %$ehash) {
    my $e_ref = $ehash->{$ident};
    if (exists $fhash->{$ident} ) {
	my $f_ref = $fhash->{$ident};
	
#	if ((@$e_ref > 1) || (@$f_ref > 1)) {
	if (@$f_ref > 1) {

	    # The multiple reads mapped unmasked genome	
	    
	} elsif ((@$e_ref >= 1) && (@$f_ref == 1)) {
	    # consider only the uniquely mapped reads
	    my $te_maps_num = @$e_ref;
	    my $arr1 = shift @{$f_ref};
	    my ($a1, $a2, $a3) = @$arr1; #strand, chr, coord 
	    my $strand;
	    if ($a1==0) {
		$strand="+";
	    } elsif ($a1==16) {
		$strand="-";
	    }
#	    my $linestr="";
	    my $linestr = "$ident\t$strand\t$a2\t$a3\t5'";
#	    print "$ident\t$strand\t$a2\t$a3\t5'";	    
                                    
	    my $arr2 = shift @{$e_ref};
	    my ($b1, $b2, $b3) = @$arr2; #strand, ident, coord 
	   
	    if ($b1==0) {
		$strand="+";
	    } elsif ($b1==16) {
		$strand="-";
	    }
	    my @el_arr = split('\|', $b2);
	    my $transposon = pop @el_arr;
	    $linestr .= "\t$strand\t$transposon\t$b3\t$te_maps_num\n";
	    my $trans_loc = $b3;

	    # print "\t$strand\t$transposon\t$b3\n";
	    # now test to see if the transposon hit is at the end of the beginning... 

#----- code for length restrictions -----------------------
#	    print "$linestr";
	    if (($trans_loc < 500) || (($lenhash->{$transposon} - $trans_loc) < 500) ) {
		print "$linestr";
	    } else {
		#This is a false positive hit
		
	    }
#--------------------------------------------------
	}
    } else {
	next;
    }
    
}


#die;
undef %$fhash;
undef %$ehash;
undef %$lenhash;

($fhash) = &createSamHash($endGENsam);

($ehash, $lenhash) =  &createSamHashTE($frontTEsam);


foreach my $ident (keys %$ehash) {
    my $e_ref = $ehash->{$ident};
    if (exists $fhash->{$ident} ) {
	my $f_ref = $fhash->{$ident};
	
	
#	if ((@$e_ref > 1) || (@$f_ref > 1)) {
	if (@$f_ref > 1) {
	    # The multiple reads mapped to unmasked genome	
	    
	} elsif ((@$e_ref >= 1) && (@$f_ref == 1)) {
	    # consider only the uniquely mapped reads
	    my $te_maps_num = @$e_ref;
	    my $arr1 = shift @{$f_ref};
	    my ($a1, $a2, $a3) = @$arr1; #strand, chr, coord 
	    my $strand;
	    if ($a1==0) {
		$strand="+";
	    } elsif ($a1==16) {
		$strand="-";
	    }
	    #	    my $linestr="";
	    my $linestr = "$ident\t$strand\t$a2\t$a3\t3'";
#	    print "$ident\t$strand\t$a2\t$a3\t3'";	    
	    
	    my $arr2 = shift @{$e_ref};
	    my ($b1, $b2, $b3) = @$arr2; #strand, ident, coord 
	    
	    if ($b1==0) {
		$strand="+";
	    } elsif ($b1==16) {
		$strand="-";
	    }
	    my @el_arr = split('\|', $b2);
	    my $transposon = pop @el_arr;
	    $linestr .= "\t$strand\t$transposon\t$b3\t$te_maps_num\n";
	    my $trans_loc = $b3;
	    
#	    print "\t$strand\t$transposon\t$b3\n";

#----- code for length restrictions -----------------------
#	    print "$linestr";
	    if (($trans_loc < 500) || (($lenhash->{$transposon} - $trans_loc) < 500) ) {
		print "$linestr";
		
	    } else {
		#This is a false positive hit
		
	    }
#---------------------------------------------------
	}
    } else {
	next;
    }
    
    
 }


#my @keys = keys %$uhash;
#my $size = @keys;
#print "size of uhash: $size\n";



#my @keys = keys %$fhash;
#my $size = @keys;
#print "size of fhash: $size\n";

#@keys = keys %$ehash;
#$size = @keys;
#print "size of ehash: $size\n";


exit;

sub createSamHash {
#    my ($frontsam, $uhash) = @_;
   my ($frontsam) = @_;
 
   my $fhash = {};
   my $lenhash = {};
    
    open(my $SAM, "<", $frontsam) 
	or die "unable to open sam file $frontsam";
    
   while ( my $line = <$SAM> ) {    
	next if ( $line =~ /^@/);
	
	my @arr = split("\t", $line);
	my $seq_header = $arr[0];
	my $match = $arr[2];
	#ignore matches to transposon hits that have \
	if ($match=~/\\/) {
	    next;
	}
	
	
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


sub createSamHashTE {
#    my ($frontsam, $uhash) = @_;
   my ($frontsam) = @_;
 
   my $fhash = {};
   my $lenhash = {};
   
   open(my $SAM, "<", $frontsam) 
       or die "unable to open sam file $frontsam";
   
   while ( my $line = <$SAM> ) {    
       if ( $line =~ /^@/) {
	   chomp $line;
	   my @arr = split("\t", $line);
	   my ($str, $len) = split(":", $arr[2]);  
	   
	   my @el_arr = split('\|', $arr[1]);
	   my $transposon = pop @el_arr;
	   # update the lenhash
	   $lenhash->{$transposon} = $len;
#	   print "$transposon\t$len\n";
	   next;
       }
       
       
       my @arr = split("\t", $line);
       my $seq_header = $arr[0];
       my $match = $arr[2];
       #ignore matches to transposon hits that have \
       if ($match=~/\\/) {
	   next;
       }
       
       
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
   
   return ($fhash, $lenhash);
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


