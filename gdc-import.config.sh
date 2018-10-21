# Download batch name.  
BATCH="UCEC.WGS.hg38.yb6"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $STAGE_ROOT/GDC_import/data/<UUID>/<FILENAME>
STAGE_ROOT="/diskmnt/Projects/cptac_downloads_3"

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2018-09-27T19_49_04.999Z.txt"


# This is where download-related metadata lives (config files, logs, etc)
IMPORT_CONFIGD_H="$STAGE_ROOT/GDC_import/import.config/CPTAC3.$BATCH"
>&2 echo IMPORT_CONFIGD $IMPORT_CONFIGD_H
IMPORT_CONFIGD_C="/data/GDC_import/import.config/CPTAC3.$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# Master SR file containing all samples.  We will download a subset of these
SR_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.hg38.b2.HAR.dat"

# This is the SR file which will drive processing here: all samples in this file will be downloaded
# This file is generated in step 2 as a subset of SR_MASTER
SR_H="dat/CPTAC3.$BATCH.SR.dat"

# Master BamMap file which hold most current list of BamMaps on system.  This file will not be 
# modified by any scripts 
BAMMAP_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/katmai.BamMap.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/CPTAC3.${BATCH}.BamMap.dat"

# Define this =1 if in MGI environment, =0 otherwise
MGI=0

# Code for reference, tupically hg19 or hg38
REFERENCE="hg19"
