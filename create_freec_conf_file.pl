#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

my %option;
my $build="dm6";
my $stepsize=5000;
getopts( 'b:s:h', \%option );
if ( $option{h} ) {
    die "perl create_freec_conf_file.pl -b dm3|dm6 samfile -s 1000|5000\n";
}


if ( $option{b} &&  $option{s}) {
    $build = $option{b};
    $stepsize = $option{s};
}

my $input_samfile = $ARGV[0];


if ($build eq "dm3") {

print <<EOF;

[general]

#The parameters chrLenFile and ploidy are required.
chrLenFile = /nlmusr/reazur/linux/GENOMES/dm3/dm3.chr.len
ploidy = 2

#breakPointThreshold = .8
BedGraphOutput=TRUE

#Either coefficientOfVariation or window must be specified.

#coefficientOfVariation = 0.01
window = 5000
step=$stepsize
chrFiles = /nlmusr/reazur/linux/GENOMES/dm3



#if you are working with something non-human, we may need to modify these parameters:
minExpectedGC = 0.3
maxExpectedGC = 0.45


#numberOfProcesses = 1
#outputDir = test

minMappabilityPerWindow = 0.90
gemMappabilityFile = /nlmusr/reazur/linux/GENOMES/dm3/gem/gem_mappability_dm3_100mer
#uniqueMatch=TRUE

#breakPointType = 4
#forceGCcontentNormalization = 1
#sex=XX

[sample]

mateFile = $input_samfile
inputFormat = SAM
mateOrientation = 0

[control]


EOF

} elsif ($build eq "dm6") {

print <<EOF;

[general]

#The parameters chrLenFile and ploidy are required.
chrLenFile = /nlmusr/reazur/linux/GENOMES/dm6/dm6.chr.len
ploidy = 2

#breakPointThreshold = .8
BedGraphOutput=TRUE

#Either coefficientOfVariation or window must be specified.

#coefficientOfVariation = 0.01
window = 5000
step=$stepsize
chrFiles = /nlmusr/reazur/linux/GENOMES/dm6



#if you are working with something non-human, we may need to modify these parameters:
minExpectedGC = 0.3
maxExpectedGC = 0.45


#numberOfProcesses = 1
#outputDir = test

minMappabilityPerWindow = 0.90
gemMappabilityFile = /nlmusr/reazur/linux/GENOMES/dm6/gem/gem_mappability_dm6_100mer.mappability
#uniqueMatch=TRUE

#breakPointType = 4
#forceGCcontentNormalization = 1
#sex=XX

[sample]

mateFile = $input_samfile
inputFormat = SAM
mateOrientation = 0

[control]


EOF


}
