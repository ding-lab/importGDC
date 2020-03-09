# Download batch name.  

# Note about SYSTEM names
# * DOCKER_SYSTEM - one of MGI, compute1, docker
#     used by start_docker.sh to initialize appropriately
# * FILE_SYSTEM - one of MGI, storage1, katmai
#     used in creation of BamMaps to indicate where data stored

BATCH="Y3.dev.PDA"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $DATA_ROOT/GDC_import/data/<UUID>/<FILENAME>

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="/diskmnt/Projects/cptac_scratch/CPTAC3.workflow/import.Y3/token/gdc-user-token.2020-02-28T20_37_36.653Z.txt"

# Master CATALOG file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

# katmai
CATALOGD="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
DATA_ROOT="/diskmnt/Projects/cptac_downloads_6"
DOCKER_BIN="/home/mwyczalk_test/Projects/WUDocker"
FILE_SYSTEM="katmai"
DOCKER_SYSTEM="docker"
LSF=0

# MGI
# CATALOGD="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog"
# DATA_ROOT="/gscmnt/gc2741/ding/CPTAC3-data"
# DOCKER_BIN="" # git clone https://github.com/ding-lab/WUDocker.git
# FILE_SYSTEM="MGI"
# DOCKER_SYSTEM="MGI"
# LSF=1
# DL_ARGS="-M -q research-hpc" 

# compute1
# CATALOGD="/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog"
# DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
# DOCKER_BIN="" # git clone https://github.com/ding-lab/WUDocker.git
# FILE_SYSTEM="storage1"
# DOCKER_SYSTEM="compute1"
# LSF=1
# DL_ARGS="-M -q general" 
## Map home directory (containing token) and storage directory
# VOLUME_MAPPING="/home/m.wyczalkowski /storage1/fs1/m.wyczalkowski"

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

