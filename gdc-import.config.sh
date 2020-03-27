# Download batch name.  

# Note about SYSTEM names
# * DOCKER_SYSTEM - one of MGI, compute1, docker
#     used by start_docker.sh to initialize appropriately
# * FILE_SYSTEM - one of MGI, storage1, katmai
#     used in creation of BamMaps to indicate where data stored

BATCH="WXS_WGS.20200310"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $DATA_ROOT/GDC_import/data/<UUID>/<FILENAME>
# BAM files will have a <FILENAME>.bai and <FILENAME>.flagstat written as well

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2020-03-27T16_23_03.768Z.txt"

# Master CATALOG file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 

# katmai
# CATALOGD="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"
# DATA_ROOT="/diskmnt/Projects/cptac"
# START_DOCKERD="/home/mwyczalk_test/Projects/WUDocker"
# FILE_SYSTEM="katmai"
# DOCKER_SYSTEM="docker"
# LSF=0

# MGI
# CATALOGD="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog"
# DATA_ROOT="/gscmnt/gc2741/ding/CPTAC3-data"
# START_DOCKERD="" # git clone https://github.com/ding-lab/WUDocker.git
# FILE_SYSTEM="MGI"
# DOCKER_SYSTEM="MGI"
# LSF=1
# DL_ARGS="-M -q research-hpc" 

# compute1
CATALOGD="/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog"
DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
START_DOCKERD="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/WUDocker" # git clone https://github.com/ding-lab/WUDocker.git
FILE_SYSTEM="storage1"
DOCKER_SYSTEM="compute1"
LSF=1
DL_ARGS="-M -q general" 
## Map home directory (containing token) and storage directory
VOLUME_MAPPING="/home/m.wyczalkowski /storage1/fs1/m.wyczalkowski /storage1/fs1/dinglab/Active"

#
# The following typically do not need to be modified
#

UUID="dat/UUID-download.dat"

# This is common to all systems
CATALOG_MASTER="$CATALOGD/CPTAC3.Catalog.dat"
BAMMAP_MASTER="$CATALOGD/BamMap/${FILE_SYSTEM}.BamMap.dat"
CASES_MASTER="$CATALOG/CPTAC3.cases.dat"

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/${BATCH}.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/${BATCH}.BamMap.dat"

