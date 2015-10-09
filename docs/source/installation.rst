Installation
============

Installation of TIDAL pipeline involves installing a set of softwares, downloading a set of annotation files, and updating the shells scripts to provide their locations.


Software Dependencies
---------------------
- fastq-dump (sra toolkit, tested with  v. 2.5.0 )
- Trimmomatics (v. 0.30)
- Bowtie (v. 1.0.0) and Bowtie2 (v. 2.1.0)
- BLAT (v. 35x1)
- FREEC (`Control-FREEC <http://bioinfo-out.curie.fr/projects/freec/>`_ v. 7.2, run freec with mapability tracks)
- bedtools suite (v. 2.17.0)
- awk and other basic unix tools are install
- Perl (64bit)

All sofatware version listed above show the version of the code used in the pipeline. The code has not been tested with other version of these tools, but we expect minimal version changes.

Source Code
-----------
Download the source code from github.
::
    cd directory_of_your_choice
    git clone https://github.com/laulabbrandeis/TIDAL

Annotation Files
----------------
Download *Drosophilia Melanogaster* reference genome and masked reference genome sequence (Release 6/dm6 build) from UCSC genome browser, and set up their Bowtie and Bowtie2 indices (Bowtie2 indices are needed only for reference genome sequence). In our analysis, we only considered the sequences for chr2R, chr2L, chr3R, chr3L, chrX, chrY, and chr4. The rest of the `annotation files <https://github.com/laulabbrandeis/TIDAL/blob/master/annotation.tar.gz>`_ are automatically downloaded when the source code is cloned. These files need to be uncompressed, and can be updated by the user as needed. Some of these files are manually curated, and others were retrieved from UCSC genome browser. Here is a brief description of these files are created/collected: 


- repmasker_dm6_track.txt : Repeat masker track from UCSC genome browser (table browser, track: Repeatmasker, table: rmsk, output format: all fields from table) 
- fly_virus_structure_repbase.fa: Manunally curated sequence from fly viruses, structural and repbase sequences (collected from UCSC genome ). Create its Bowtie index.
- Tidalbase_Dmel_TE_classifications_2015.txt : Custom table for repbase to flybase lookup
- gem_mappability_dm6_100mer.mappability : Gem mappability file needed by FREEC. Thanks to Hangnoh Lee for creating this file for us.
- Tidalbase_transposon_sequence.fa : List of concensus transposon sequences (manually curated). Create Bowtie indices for these consensus transposon seqeunces
- refflat_dm6.txt : RefSeq annotation from UCSC genome browser (table browser, track: Refseq Geens, table: refFlat, output format: all fields from table) 
- dm6.chr.len : tab delimited file with chromosome name and length

Create Bowtie indices for fly_virus_structure_repbase.fa and Tidalbase_transposon_sequence.fa.
::
    bowtie-build fly_virus_structure_repbase.fa fly_virus_structure_repbase
    bowtie-build Tidalbase_transposon_sequence.fa dm_TE


Compile C code
--------------------------------
Compile C code in TIDAL code directory
::
    cd /location_from_root/TIDAL/CODE
    make

Update Shell Scripts
--------------------
Update the following shell scripts with the location of the TIDAL code, annotation files and Bowtie indices. I recommend creating a TIDAL directory, with a subdirectory CODE for storing all the code, and another subdirectory annotation and 

data_prep.sh
::
    #location of TIDAL code from root
    CODEDIR="/location_from_root/TIDAL/CODE"
    #location of Trimmomatic
    TRIMMOMATICDIR="/location_from_root/Trimmomatic-0.30"  





