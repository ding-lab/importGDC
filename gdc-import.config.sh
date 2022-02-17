# Download batch name.  

# System is one of MGI, compute1, or katmai
SYSTEM="compute1"

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2022-02-04T18_10_34.287Z.txt"

# Format: /USER/gdc-download
# Create with `bgadd -L 5 /USER/gdc-download`
LSF_GROUP="/mwyczalk/gdc-download"

# Variables below should not need to be modified in most cases
if [ $SYSTEM == "katmai" ]; then
    # katmai
# Master CATALOG file containing all samples.  We will download a subset of these
# Master BamMap file which hold most current list of BamMaps on system.  This file will not be modified by any scripts 
    CATALOGD="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog"

# Data download root directory.  Individual BAMS/FASTQs will be in,
#   $DATA_ROOT/GDC_import/data/<UUID>/<FILENAME>
# BAM files will have a <FILENAME>.bai and <FILENAME>.flagstat written as well

    DATA_ROOT="/diskmnt/Projects/cptac"

# Note about SYSTEM names
# * DOCKER_SYSTEM - one of MGI, compute1, docker
#     used by start_docker.sh to initialize appropriately
# * FILE_SYSTEM - one of MGI, storage1, katmai
#     used in creation of BamMaps to indicate where data stored
    FILE_SYSTEM="katmai"
    DOCKER_SYSTEM="docker"
    LSF=0

elif [ $SYSTEM == "MGI" ]; then 
    # MGI
    CATALOGD="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog"
    DATA_ROOT="/gscmnt/gc2741/ding/CPTAC3-data"
    FILE_SYSTEM="MGI"
    DOCKER_SYSTEM="MGI"
    LSF=1
    DL_ARGS="-M -q research-hpc" 
    LSF_ARGS="-g $LSF_GROUP"

elif [ $SYSTEM == "compute1" ]; then
    # compute1
    CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
    DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
    FILE_SYSTEM="storage1"
    DOCKER_SYSTEM="compute1"
    LSF=1
    DL_ARGS="-M -q dinglab" 
    LSF_ARGS="-g $LSF_GROUP -G compute-dinglab"

else

    >&2 echo ERROR: Unknown system $SYSTEM
    exit 1

fi

UUID="dat/download_UUID.dat"

# This is common to all systems
CATALOG_MASTER="$CATALOGD/CPTAC3.Catalog.dat"
BAMMAP_MASTER="$CATALOGD/BamMap/${FILE_SYSTEM}.BamMap.dat"
CASES_MASTER="$CATALOG/CPTAC3.cases.dat"

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/batch.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/batch.BamMap.dat"

START_DOCKERD="docker/WUDocker"
