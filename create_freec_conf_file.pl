#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Std;

my %option;
my $build="dm6";
my $stepsize=5000;
my $chr_Files = "";
my $gem_Mappability_Files = "";
my $chr_len = "";
getopts( 'b:s:c:g:l:h', \%option );
if ( $option{h} ) {
    die "perl create_freec_conf_file.pl -b dm3|dm6 samfile -s 1000|5000 -c location of chromosome files (each chromosome in a separate file) -g gem mappability files -l chr length file\n";
}


if ( $option{b} &&  $option{s}) {
    $build = $option{b};
    $stepsize = $option{s};
    $chr_Files = $option{c};
    $gem_Mappability_Files = $option{g};
    $chr_len = $option{l};
}

my $input_samfile = $ARGV[0];


if ($build eq "dm3") {

print <<EOF;

[general]

#The parameters chrLenFile and ploidy are required.
chrLenFile = $chr_len
ploidy = 2

#breakPointThreshold = .8
BedGraphOutput=TRUE

#Either coefficientOfVariation or window must be specified.

#coefficientOfVariation = 0.01
window = 5000
step=$stepsize
chrFiles = $chr_Files



#if you are working with something non-human, we may need to modify these parameters:
minExpectedGC = 0.3
maxExpectedGC = 0.45


#numberOfProcesses = 1
#outputDir = test

minMappabilityPerWindow = 0.90
gemMappabilityFile = $gem_Mappability_Files
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
chrLenFile = $chr_len
ploidy = 2

#breakPointThreshold = .8
BedGraphOutput=TRUE

#Either coefficientOfVariation or window must be specified.

#coefficientOfVariation = 0.01
window = 5000
step=$stepsize
chrFiles = $chr_Files



#if you are working with something non-human, we may need to modify these parameters:
minExpectedGC = 0.3
maxExpectedGC = 0.45


#numberOfProcesses = 1
#outputDir = test

minMappabilityPerWindow = 0.90
gemMappabilityFile = $gem_Mappability_Files
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
