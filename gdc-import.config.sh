# Download batch name.  

BATCH="Y3.dev.PDA"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $DATA_ROOT/GDC_import/data/<UUID>/<FILENAME>

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2020-01-31T20_48_13.912Z.txt"

# Master CATALOG file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

# katmai
# CATALOG="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
# DATA_ROOT="/diskmnt/Projects/cptac_downloads_7"
# SYSTEM="docker"
# LSF=0

# MGI
#CATALOG="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog"
#DATA_ROOT="/gscmnt/gc2741/ding/CPTAC3-data"
#SYSTEM="MGI"
# LSF=1

# compute1
CATALOGD="/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog"
DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
SYSTEM="compute1"
LSF=1

UUID="dat/UUID-download.dat"

# This is common to all systems
CATALOG_MASTER="$CATALOGD/CPTAC3.Catalog.dat"
BAMMAP_MASTER="$CATALOGD/BamMap/${SYSTEM}.BamMap.dat"
CASES_MASTER="$CATALOG/CPTAC3.cases.dat"

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/${BATCH}.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/${BATCH}.BamMap.dat"

