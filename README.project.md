Download methylation data from GDC.

UUIDs from email from Mathangi 6/7/19, identifying all methylation data associated with Batch 9, in file GDC_methyl_array_batch9added_6_6.xlsx
This original file and its TSV version in ./origdata

Columns of GDC_methyl_array_batch9added_6_6.tsv:
     1  aliquots.id
     2  aliquots.submitter_id
     3  Type
     4  CaseID
     5  Tumor Type
     6  Batch 9
     7  type
     8  id
     9  project_id
    10  submitter_id
    11  channel
    12  data_category
    13  data_format
    14  data_type
    15  experimental_strategy
    16  file_name
    17  file_size
    18  md5sum
    19  platform
    20  chip_id
    21  chip_position
    22  plate_name
    23  plate_well

Downloading of methylation data is based on ad-hoc download if miRNA data in
    denali:/home/mwyczalk_test/Projects/CPTAC3/import.CPTAC3/import.CPTAC3.miRNA/1_make_SR.sh
First an AR file is created, then that is used to guide download

We make extensive use of scripts which are also used to download GDC sequence data, but for
now we are keeping the methylation datasets separate.  In particular, download root directory
is denali:/diskmnt/Projects/cptac_downloads/methylation

