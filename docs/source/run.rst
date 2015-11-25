Run
===
TIDAL can be run from both sra and fastq format, when library name and length is provided.


TIDAL from SRA
--------------
To run TIDAL on sra file, there are two you have to do two things:

1. Prepare a run file

Format of run file (tab delimited)
::

    Library_ID      SRR_Accession   Min_Library_Length
    S2R+    SRR497719       100
    OSS_C   SRR1185816      150

The first column header should be Library_ID, this used to skip the header line. The Library ID is used to name output files. The SRR Accession is used to download the file.

2. Run TIDAL_from_sra.sh
::

    nohup /location_from_root/TIDAL/CODE/TIDAL_from_sra.sh run_file.txt &


TIDAL from fastq
----------------
To run TIDAL on fastq file, we need the library in fastq format and read length.
::

    nohup /location_from_root/TIDAL/CODE/TIDAL_from_fastq.sh file.fastq min_len &

Congratulations!!! You have managed to run TIDAL, hope you get exciting results!

TIDAL for other scenarios
-------------------------
TIDAL_from_sra.sh script can be modified to run for other special cases. Here are two examples: 

1. TIDAL_from_sra_2files.sh: Combine two sra entry for one TIDAL run. This script can be modified to combine multiple sra entries.

2. TIDAL_from_sra_DGRP.sh: DGRP libraries often have multiple libraries with varying length concatenated into one sra entry. Since, library length is an important aspect of TIDAL, it needs to carefully specified to isolate the necessay reads from the mixed library.

Outputs
-------
Please check this `link <http://www.bio.brandeis.edu/laulab/Tidal_Fly/UserGuide_TIDAL_outputs.html>`_ for detailed description of output files from TIDAL. 