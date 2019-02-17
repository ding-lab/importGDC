# Download batch name.  

BATCH="LUAD.RNA-Seq.hg38"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $STAGE_ROOT/GDC_import/data/<UUID>/<FILENAME>

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2019-01-28T23_27_07.488Z.txt"

# Master AR file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

## katmai
#AR_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.AR.dat"
#BAMMAP_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/katmai.BamMap.dat"
#STAGE_ROOT="/diskmnt/Projects/cptac_downloads_5"
#MGI=0
#SYSTEM="katmai"

## denali
#AR_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.AR.dat"
#BAMMAP_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/denali.BamMap.dat"
#STAGE_ROOT="/diskmnt/Projects/cptac_downloads/data"
#MGI=0
#SYSTEM="denali"

# MGI
AR_MASTER="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.AR.dat"
BAMMAP_MASTER="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat"
STAGE_ROOT="/gscmnt/gc2619/dinglab_cptac3"
# Define this =1 if in MGI environment, =0 otherwise
MGI=1
SYSTEM="MGI"

# This is where download-related metadata lives (config files, logs, etc)
IMPORT_CONFIGD_H="$STAGE_ROOT/GDC_import/import.config/$BATCH"
>&2 echo IMPORT_CONFIGD $IMPORT_CONFIGD_H
IMPORT_CONFIGD_C="/data/GDC_import/import.config/$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# this is used in importGDC scripts
export IMPORTGDC_HOME="./importGDC"  


# This is the AR file which will drive processing here: all samples in this file will be downloaded
# This file is generated in step 2 as a subset of AR_MASTER
AR_H="dat/$BATCH.AR.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/$BATCH.BamMap.dat"

