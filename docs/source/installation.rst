Installation
============

Installation of TIDAL pipeline involves installing a set of softwares, downloading a set of annotation files, and updating the shells scripts to provide their locations.


Software Dependencies
---------------------
- fastq-dump (sra toolkit, tested with  v. 2.5.0 )
- Trimmomatics (v. 0.30)
- Bowtie (v. 1.0.0) and Bowtie2 (v. 2.1.0)
- BLAT (v. 35x1)
- `Control-FREEC <http://bioinfo-out.curie.fr/projects/freec/>`_ v. 7.2, run freec with mapability tracks)
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
The `annotation files <https://github.com/laulabbrandeis/TIDAL/blob/master/annotation.tar.gz>`_ are automatically downloaded when the source code is cloned. Uncompress the annotation files, which creates a directory with all the annotation files.
::

    cd /location_from_root/TIDAL
    tar -zxvf annotation.tar.gz

Some of these files are manually curated, and others were retrieved from UCSC genome browser. These files can be updated by the user as needed. Here is a brief description of these files are created/collected:
* repmasker_dm6_track.txt : Repeat masker track from UCSC genome browser (table browser, track: Repeatmasker, table: rmsk, output format: all fields from table) 
* fly_virus_structure_repbase.fa: Manunally curated sequence from fly viruses, structural and repbase sequences (collected from UCSC genome )
* Tidalbase_Dmel_TE_classifications_2015.txt : Custom table for repbase to flybase lookup
* gem_mappability_dm6_100mer.mappability : Gem mappability file needed by FREEC. Thanks to Hangnoh Lee for creating this file for us
* Tidalbase_transposon_sequence.fa : List of concensus transposon sequences (manually curated).
* refflat_dm6.txt : RefSeq annotation from UCSC genome browser (table browser, track: Refseq Genes, table: refFlat, output format: all fields from table) 
* dm6.chr.len : tab delimited file with chromosome name and length

Create Bowtie indices for fly_virus_structure_repbase.fa and Tidalbase_transposon_sequence.fa.
::

    bowtie-build fly_virus_structure_repbase.fa fly_virus_structure_repbase
    bowtie-build Tidalbase_transposon_sequence.fa dm_TE

Download *Drosophilia Melanogaster* reference genome and masked reference genome sequence (Release 6/dm6 build) from UCSC genome browser, and set up their Bowtie and Bowtie2 indices (Bowtie2 indices are needed only for reference genome sequence). In our analysis, we only considered the sequences for chr2R, chr2L, chr3R, chr3L, chrX, chrY, and chr4. One of the requirement of of running Control FREEC is to provide the location of individual chromosome fasta files.

You can use the script *download_ucsc_data.sh* to download dm6 reference genome, masked genome and individual chromosome fasta files. Update the CODEDIR variable in download_ucsc_data.sh.
::

    #location of TIDAL code
    CODEDIR="/location_from_root/TIDAL/CODE"

Now, run the script and set up the bowtie indices
::

    cd directory_of_choice 
    ./download_ucsc_data.sh
    #set up the required bowtie indices
    bowtie-build dm6.fa dm6
    bowtie2-build dm6.fa dm6
    bowtie-build dm6.fa dm6_mask

Compile C code
--------------------------------
Compile C code in TIDAL code directory
::

    cd /location_from_root/TIDAL/CODE
    make

Update Shell Scripts
--------------------
Update the following shell scripts with the location of the TIDAL code, annotation files and Bowtie indices.

**data_prep.sh**
::

    #location of TIDAL code from root
    CODEDIR="/location_from_root/TIDAL/CODE"
    #location of Trimmomatic
    TRIMMOMATICDIR="/location_from_root/Trimmomatic-0.30"  

**insert_pipeline.sh**
::

    #location of TIDAL code
    CODEDIR="/location_from_root/TIDAL/CODE"
    #bowtie and bowtie2 indices, both have the same name in this case
    genomedb="/location_from_root/dm6"
    #location of masked genome bowtie indices
    masked_genomedb="/location_from_root/dm6_mask"
    #location of consensus TE sequence bowtie indices 
    consensus_TEdb="/location_from_root/TIDAL/annotation/dm_TE"
    #location of FREEC 
    FREECDIR="/location_from_root/FREEC"
    #Genome sequence in fasta format (all chromosome concatenated in one file)
    GENOME="/location_from_root/dm6.fa"
    #Refseq annotation from UCSC genome browser
    refseq_annotationfile="/location_from_root/TIDAL/annotation/refflat_dm6.txt"
    #tab delimited file with chromosome name and length
    chrlen_file="/location_from_root/TIDAL/annotation/dm6.chr.len"
    #directory of individual chromosome files needed by FREEC
    chrDir="/location_from_root/dm6"
    #gem mappability file locationa
    gemMappabilityFile="/location_from_root/TIDAL/annotation/gem_mappability_dm6_100mer.mappability"
    #bowtie indices of fly virus, structure and repbase sequence
    fly_virus_structure_repbase_DB="/location_from_root/TIDAL/annotation/fly_virus_structure_repbase"

**depletion_pipeline.sh**
::

    #location of TIDAL code
    CODEDIR="/location_from_root/TIDAL/CODE"
    #bowtie and bowtie2 indices, both have the same name in this case
    genomedb="/location_from_root/dm6"
    #location of masked genome bowtie indices
    masked_genomedb="/location_from_root/dm6_mask"
    #location of consensus TE sequence bowtie indices 
    consensus_TEdb="/location_from_root/TIDAL/annotation/dm_TE"
    #Genome sequence in fasta format (all chromosome concatenated in one file)
    GENOME="/location_from_root/dm6.fa"
    #Masked Genome sequence in fasta format (all chromosome concatenated in one file)
    MASKED_GENOME="/location_from_root/dm6.fa.masked"
    #Repeat masker file from repbase, downloaded from UCSC genome browser
    repeat_masker_file="/location_from_root/TIDAL/annotation/repmasker_dm6_track.txt"
    #Refseq annotation from UCSC genome browser
    refseq_annotationfile="/location_from_root/TIDAL/annotation/refflat_dm6.txt"
    #location of custom table for classification and coversion from flybase to repbase name, this ensures that the naming is consistent with flybase
    table_lookup="/location_from_root/TIDAL/annotation/Tidalbase_Dmel_TE_classifications_2015.txt"
    #tab delimited file with chromosome name and length
    chrlen_file="/location_from_root/TIDAL/annotation/dm6.chr.len"

**TIDAL_from_fastq.sh**
::

    #location of TIDAL code
    CODEDIR="/location_from_root/TIDAL/CODE"

**TIDAL_from_sra.sh**
::

    #location of TIDAL code
    CODEDIR="/location_from_root/TIDAL/CODE"

**Congratulations!!! Now, you are ready to run TIDAL.**



