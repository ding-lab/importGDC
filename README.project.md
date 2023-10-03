Downloading 72 files required to complete DLBCL WGS SNV analysis
Runs and files are identified in work performed here:
    /home/m.wyczalkowski/Projects/GDAN/Work/20230914.DLBCL_WGS_Confirm

Specifically, the file dat2/analysis_summary_BAM.dat provides a list of all runs which have been performed and uploaded.
Note that to simplify UUID issues we are using BAM filenames and not UUIDs

The file on paprika: /Users/m.wyczalkowski/Projects/GDAN/Work/20230914.DLBCL_WGS_Confirm/dlbcl_deep_cov_dna_wgs_pairs_with_metadata.numbers
is based on a download from synapse as suggested by Jennifer Shelton, which annotates which samples are FFPE and which are FF.
The logic is that we need to perform runs for all cases which have 1) FF tumor and normal, and 2) if no FF tumor is available to run
FFPE.  This comes to 196 tumor / normal pairs to run.

List of these pairs are in /home/m.wyczalkowski/Projects/GDAN/Work/20230914.DLBCL_WGS_Confirm/dat2/dlbcl_deep_196.dat

Runs weve performed and submitted (unique runs only) can be found in the file dat2/analysis_summary_BAM.dat
Runs unique to the request list can be found as,
    comm -13 analysis_summary_BAM.dat dlbcl_deep_196.dat > missing_runs.dat

These form the basis of the download as well as future runs.

# UUIDs to download

Based on dat/missing_runs.dat and 
    CATR="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog-REST.tsv"
obtain the UUIDs of files to download:
```
$ grep -f <(tr '\t' '\n' < missing_runs.dat) $CATR | cut -f 10 | sort > uuid_download.dat
```
    
Total required disk space WGS: 17.1705 Tb in 72 files
                          WXS: 0 Tb in 0 files
                      RNA-Seq: 0 Tb in 0 files
                    miRNA-Seq: 0 Tb in 0 files
            Methylation Array: 0 Tb in 0 files
          Targeted Sequencing: 0 Tb in 0 files
                    scRNA-Seq: 0 Tb in 0 files
                        TOTAL: 17.1705 Tb in 72 files
