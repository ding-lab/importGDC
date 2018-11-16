# Download batch name.  

BATCH="UCEC.WGS.hb2"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $STAGE_ROOT/GDC_import/data/<UUID>/<FILENAME>

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2018-10-27T22_53_11.029Z.txt"

# Master SR file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

## KATMAI
SR_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.SR.dat"
BAMMAP_MASTER="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/katmai.BamMap.dat"
STAGE_ROOT="/diskmnt/Projects/cptac_downloads_5"
MGI=0
SYSTEM="katmai"

# MGI
#SR_MASTER="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.SR.dat"
#BAMMAP_MASTER="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat"
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


# This is the SR file which will drive processing here: all samples in this file will be downloaded
# This file is generated in step 2 as a subset of SR_MASTER
SR_H="dat/$BATCH.SR.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/$BATCH.BamMap.dat"

