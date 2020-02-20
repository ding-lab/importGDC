# Download batch name.  

BATCH="methylation.20191202"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $DATA_ROOT/GDC_import/data/<UUID>/<FILENAME>

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2019-12-02T23_49_17.255Z.txt"

# Master CATALOG file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

# katmai
CATALOG="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
DATA_ROOT="/diskmnt/Projects/cptac_downloads_7"
MGI=0
SYSTEM="katmai"

## denali
#CATALOG="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
#DATA_ROOT="/diskmnt/Projects/cptac_downloads/data"
#MGI=0
#SYSTEM="denali"

# MGI
#CATALOG="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog"
#DATA_ROOT="/gscmnt/gc2741/ding/CPTAC3-data"
## Define this =1 if in MGI environment, =0 otherwise
#MGI=1
#SYSTEM="MGI"

# this is used in importGDC scripts
export IMPORTGDC_HOME="./importGDC"  

# This is common to all systems
CATALOG_MASTER="$CATALOG/CPTAC3.Catalog.dat"
BAMMAP_MASTER="$CATALOG/BamMap/${SYSTEM}.BamMap.dat"
CASES_MASTER="$CATALOG/CPTAC3.cases.dat"

# This is the CATALOG file which will drive processing here: all samples in this file will be downloaded
# This file is generated in step 2 as a subset of CATALOG_MASTER
CATALOG_H="dat/$BATCH.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/$BATCH.BamMap.dat"

