# Download batch name.  

# System is one of MGI, compute1, or katmai
SYSTEM="compute1"
PROJECT="MILD"

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2023-05-01T19_43_50.254Z-AWG.txt"

# Format: /USER/gdc-download
# Create with `bgadd -L 5 /USER/gdc-download`
LSF_GROUP="/mwyczalk/gdc-download"

# List of UUIDs to download
UUID="dat/UUID_download.dat"
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

elif [ $SYSTEM == "compute1" ]; then
    # compute1
    CATALOGD="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
    #CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
    # DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
    DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/GDAN-GDC"   # new GDAN data
    FILE_SYSTEM="storage1"
    DOCKER_SYSTEM="compute1"
    LSF=1
    DL_ARGS="-M -q dinglab" 
    LSF_ARGS="-g $LSF_GROUP -G compute-dinglab"

else

    >&2 echo ERROR: Unknown system $SYSTEM
    exit 1

fi


# This differs for GDAN and Catalog3 systems
#CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"
CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog-REST.tsv"
#/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/HCMI.Catalog-REST.tsv
BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${PROJECT}.BamMap3.tsv"

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/batch.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/batch.BamMap.dat"

START_DOCKERD="docker/WUDocker"
