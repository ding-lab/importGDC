# Download batch name.  

BATCH="Methylation.Batch9"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $STAGE_ROOT/GDC_import/data/<UUID>/<FILENAME>

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2019-06-06T04_48_59.198Z.txt"

# Master AR file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

# katmai
# CATALOG="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
# STAGE_ROOT="/diskmnt/Projects/cptac_downloads_7"
# MGI=0
# SYSTEM="katmai"

## denali
CATALOG="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
#STAGE_ROOT="/diskmnt/Projects/cptac_downloads/data"
STAGE_ROOT="/diskmnt/Projects/cptac_downloads/methylation"
MGI=0
SYSTEM="denali"

# MGI
#CATALOG="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog"
#STAGE_ROOT="/gscmnt/gc2741/ding/CPTAC3-data"
## Define this =1 if in MGI environment, =0 otherwise
#MGI=1
#SYSTEM="MGI"

# This is where download-related metadata lives (config files, logs, etc)
IMPORT_CONFIGD_H="$STAGE_ROOT/GDC_import/import.config/$BATCH"
>&2 echo IMPORT_CONFIGD $IMPORT_CONFIGD_H
IMPORT_CONFIGD_C="/data/GDC_import/import.config/$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# this is used in importGDC scripts
export IMPORTGDC_HOME="./importGDC"  

# This is common to all systems
AR_MASTER="$CATALOG/CPTAC3.AR.dat"
BAMMAP_MASTER="$CATALOG/${SYSTEM}.BamMap.dat"
CASES_MASTER="$CATALOG/CPTAC3.cases.dat"

# This is the AR file which will drive processing here: all samples in this file will be downloaded
# This file is generated in step 2 as a subset of AR_MASTER
AR_H="dat/$BATCH.AR.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/$BATCH.BamMap.dat"

