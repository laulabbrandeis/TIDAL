#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;
my %option;
getopts( 'a:h', \%option );
my $refseq_annotation_file;
if ( $option{a} ) {
    $refseq_annotation_file=$option{a};
} else {die "refseq annotation file not provided in rough_annotation_insertion_sites.pl\n";}

#the refernce flat file is hardcoded
#my $input_filename = "/nlmusr/reazur/linux/NELSON/Genome_resequence/annotation/dm3_reflat.txt"; # $ARGV[0];

my ($global_arr, $global_hash) = &process_dm3reflat($refseq_annotation_file);

print "SV#\tsize\tChr_5p\tChr_coord_5p\tclassification_5p\tcomment_5p\tChr_mid\tChr_coord_mid\tclassification_mid\tcomment_mid\tChr_3p\tChr_coord_3p\tclassification_3p\tcomment_3p\n";

#open the file with insertion list
my $insert_filename = $ARGV[0];
open(my $INSERT, "<", $insert_filename) 
    or die "unable to open ct file $insert_filename";

my $insert_number = 1;
my $limit = 500;
my $first_line;
while ( my $line = <$INSERT> ) {
    chomp $line;
    
    if ($line=~/^SV/) {
	$first_line = $line;
	next;
    }
    
    my @arr = split(/\t/, $line);
    my $filechr = $arr[1];
    my $site = $arr[2];
    my $site_3prime = $arr[6];
    my $site_mid =  ($site + $site_3prime)/2; 
    $site_mid = sprintf( "%.0f", $site_mid);

    my $size = $site_3prime-$site;
#    print "$chr\t$site\t";
    #now implement the decision tree :)
    my ($genic) = &isSiteGenic($global_arr, $site, $filechr);
#    print  "$insert_number\t$filechr\t$site\t";
#    my $text = "$insert_number";    
#    print "$text";
    print "$insert_number\t$size";
#print for 5' site
    my ($feature, $comment) = &getFeatureAndComment($global_arr, $global_hash, $genic, $site, $filechr, $limit);
     $feature=~s/,$//;
    $comment=~s/,$//;
    print "\t$filechr\t$site\t$feature\t$comment";
#print for mid point sites
    ($genic) = &isSiteGenic($global_arr, $site_mid, $filechr);
    ($feature, $comment)=("", "");
    ($feature, $comment) = &getFeatureAndComment($global_arr, $global_hash, $genic, $site_mid, $filechr, $limit);
     $feature=~s/,$//;
    $comment=~s/,$//;
    print "\t$filechr\t$site_mid\t$feature\t$comment";
#print for 3' sites    
    ($genic) = &isSiteGenic($global_arr, $site_3prime, $filechr);
    ($feature, $comment)=("", "");
    ($feature, $comment) = &getFeatureAndComment($global_arr, $global_hash, $genic, $site_3prime, $filechr, $limit);
     $feature=~s/,$//;
    $comment=~s/,$//;
    print "\t$filechr\t$site_3prime\t$feature\t$comment";
    
    print "\n";
    $insert_number++;
}

close $INSERT;


exit;

#process the dm3 flat file and return a global array and global hash
# 
sub process_dm3reflat {
    my ($input_filename) = @_;
    
    open(my $INFILE, "<", $input_filename) 
        or die "unable to open ct file $input_filename";
    
    my @global_arr = ();
    my $first_line='';
    my $last_line='';    
#------------------------------------
    my $arr2d=[];
    while ( my $line = <$INFILE> ) {
	chomp $line;
	if ($line=~/^#geneName/) {
	    $first_line = $line;
	    next;
	}
	
	my @arr = split(/\t/, $line);
	push @{$arr2d}, \@arr;
    }
    close $INFILE;
#---------------------------------------
    #sort by chromosome and start position
    my @sortarr = sort { ($a->[2] cmp $b->[2]) || ($a->[0] cmp $b->[0]) } @{$arr2d};
    
    
    foreach my $arr ( @sortarr ) {
	
	my ($gene, $chr, $tstart, $tend, $cdsstart, $cdsend, $exoncount, $exonstarts, $exonends) = ($arr->[0], $arr->[2], $arr->[4], $arr->[5], $arr->[6], $arr->[7], $arr->[8], $arr->[9], $arr->[10]);
	
	#----------------------------------
	if ($chr=~/Het$/i) {
	    next;
	} elsif ($chr=~/chrU/i) {
	    next;
	} elsif ($chr=~/extra$/i) {
	    next;
	}
	#-----------------------------------    
	my $curr_line = $arr;
	
	if ($last_line eq '') {
	    #the first occurrence of an entry
	    $last_line=$curr_line;
	    push @global_arr, $curr_line;
	    
	} else {
	    my ($last_gene, $last_chr, $last_tstart, $last_tend, $last_cdsstart, $last_cdsend, $last_exoncount, $last_exonstarts, $last_exonends) = ($last_line->[0], $last_line->[2], $last_line->[4], $last_line->[5], $last_line->[6], $last_line->[7], $last_line->[8], $last_line->[9], $last_line->[10]);
	    
#compare the last line with the current line
#to see if the current line is a new type or old type
	    if (($gene eq $last_gene) && ($chr eq $last_chr)) {
		#if they are the same 
		#Decide if I keep the current line or the last line 	    
		#-------------------------
		# select gene model based on transcription start site
		my $last_size = $last_tend - $last_tstart;
		my $current_size = $tend - $tstart;
		if ($last_size >= $current_size ) {
		    # keep last line
		    next;		
		} else {
		    my $remove = pop @global_arr; #remove the lastline
		    $last_line=$curr_line;
		    push @global_arr, $curr_line;
		}
		
	    } else {
		#the first occurrence of an entry
		$last_line=$curr_line;
		push @global_arr, $curr_line;    
	    }
	    
	}
    }
    close $INFILE;
    
    #sort by chr and tstart
    @global_arr = sort { ($a->[2] cmp $b->[2]) || ($a->[4] <=> $b->[4]) } @global_arr;
    
#---------- print the global array for debug ---
#foreach my $line (@global_arr) {
#    
#    foreach my $el (@$line) {
#	print "$el\t";
#    }
#    print "\n";
#}
#
#die;
#---------------
    
    
#------------- print the collapsed entries 
#create the golbal hash here
    my $global_hash = {};
    foreach my $ref (@global_arr) {
	my ($gene, $chr, $tstart, $tend, $cdsstart, $cdsend, $exoncount, $exonstarts, $exonends) = ($ref->[0], $ref->[2], $ref->[4], $ref->[5], $ref->[6], $ref->[7], $ref->[8], $ref->[9], $ref->[10]);
	
	#--------------------------------------------------------
	# prepare the exon hash, to detect the presence of exon
	my @startarr = split(/,/, $exonstarts);
	my @endarr = split(/,/, $exonends);
	my $exon_hash = {};
	
	while (@startarr) {
	    my $start = shift @startarr;
	    my $end = shift @endarr;
	    foreach my $num ($start..$end) {
		$exon_hash->{$num}++;
	    }
	}	   
	#-------------------------------------------------------
	my $key = $chr.'_'.$gene.'_'.$tstart;   
	$global_hash->{$key} = $exon_hash;
	
#    foreach my $el (@$line) {
#	print "$el\t";
#    }
#    print "\n";
    }
    
#------------------------
#die;
    
    return (\@global_arr, $global_hash);

}


#return 1 if the site is genic, otherwise return 0
sub isSiteGenic {
    my ($global_arr, $site, $filechr ) = @_;
    
    my $genic = 0;
    #is the site intergenic, within a transcription start and end site
    foreach my $ref ( @$global_arr ) {
	my ($gene, $chr, $tstart, $tend, $cdsstart, $cdsend, $exoncount, $exonstarts, $exonends) = ($ref->[0], $ref->[2], $ref->[4], $ref->[5], $ref->[6], $ref->[7], $ref->[8], $ref->[9], $ref->[10]);
	
	next if ($filechr ne $chr);
	if (($site >= $tstart) && ($site <= $tend) ) {
	    $genic=1;
#	    print "($site >= $tstart) && ($site <= $tend)  $filechr ne $chr\n";
#	    print "\t$gene, $chr, $tstart, $tend, $cdsstart, $cdsend, $exoncount, $exonstarts, $exonends\n";
	    
#builing a global hash here o
	}
    }
    return ($genic);
}


sub getFeatureAndComment {
    my ($global_arr, $global_hash, $genic, $site, $filechr, $limit) = @_;

    my $feature = "";
    my $comment = "";
    
    if ($genic) {
#	print "$filechr\t$site\t";
	#identify 5`
#	my $feature = "";
#	my $comment = "";
	foreach my $ref ( @$global_arr ) {
	    my ($gene, $chr, $tstart, $tend, $cdsstart, $cdsend, $exoncount, $exonstarts, $exonends, $strand) = ($ref->[0], $ref->[2], $ref->[4], $ref->[5], $ref->[6], $ref->[7], $ref->[8], $ref->[9], $ref->[10], $ref->[3]);

	    next if ($filechr ne $chr);
	    if ( ($site >= $tstart) && ($site <= $tend) ) { 
		$comment .= "$gene $strand,";
		
		my $key = $chr.'_'.$gene.'_'.$tstart;
		my $exon_hash  = $global_hash->{$key};		
		if (($site >= $tstart) && ($site <= $cdsstart)) {
		    #identify 5`
		    if (exists $exon_hash->{$site}) {
			if ($strand eq '-') {
			    $feature .= "3` UTR,";
			} else {
			    $feature .= "5` UTR,";
			}			
		    } else {
			$feature .= "intron,";
		    }
		} elsif (($site >= $cdsend) && ($site <= $tend)) {
		    #identify 3`
		    if (exists $exon_hash->{$site}) {
			if ($strand eq '-') {
			    $feature .= "5` UTR,";
			} else {
			    $feature .= "3` UTR,";
			}
		    } else {
			$feature .= "intron,";
		    }
		} else {
		    #identify if it exon or intron	
		    #does the site fall on the exon hash
		    if (exists $exon_hash->{$site}) {
			$feature .= "exon,";
		    } else {
			$feature .= "intron,";
		    }	    
		} #end else
	    } #end,  if ( ($site >= $tstart) && ($site <= $tend)
	} #end, foreach loop 
#	print "$feature\t$comment\n";
    } else {
#	my $intergenic = 0;
#	my $limit=5000;
	
#	print "intergenic\t";
	my @com_arr=();	
	
	foreach my $ref ( @$global_arr ) {
	    my ($gene, $chr, $tstart, $tend, $cdsstart, $cdsend, $exoncount, $exonstarts, $exonends, $strand) = ($ref->[0], $ref->[2], $ref->[4], $ref->[5], $ref->[6], $ref->[7], $ref->[8], $ref->[9], $ref->[10], $ref->[3]);
	    
	    next if ($filechr ne $chr);
	    
	    if (($site < $tstart) &&  ($site >= ($tstart-$limit))) {
#		$intergenic=1;
		my $len =  $tstart - $site +1;
		push @com_arr, [$gene, $strand, $len];
		#$comment .= "$gene $strand\t";
	    } elsif (($site > $tend) && ($site <= $tend+$limit)) {
		my $len = $site - $tend +1;
		push @com_arr, [$gene, $strand, $len];
		#$comment .= "$gene $strand\t";
		
	    } else {
		# not near genes 
		#$comment = "not near genes";
	    }
	}
	#---------------------------------
#	my $comment="";
	$feature = "intergenic";
	if (@com_arr) {
	    @com_arr =  sort { ($a->[2] <=> $b->[2]) } @com_arr;
	    foreach my $ref (@com_arr) {
		my $gene= $ref->[0];
		my $strand= $ref->[1];
		$comment .= "$gene $strand,";
	    }
	} else {
	    $comment = "not near genes";
	} 
#	print "$feature\t$comment\n";
    } 

    return ($feature, $comment);
}
