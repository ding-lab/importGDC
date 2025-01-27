# Download batch name.  

# System is one of MGI, compute1, or katmai
SYSTEM="compute1"
PROJECT="CPTAC3"
CAT_TYPE="REST" # Catalog3 or REST

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2025-01-02T21_21_22.946Z.txt"

# Format: /USER/gdc-download
# Create with `bgadd -L 5 /USER/gdc-download`
LSF_GROUP="/mwyczalk/gdc-download"

# List of UUIDs to download
UUID="dat/UUID_download.dat"

# compute1
#    CATALOGD="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"

# for GDAN
#CATALOGD="/rdcw/fs2/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"

# for CPTAC3
CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"

#    DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
#DATA_ROOT="/storage1/fs1/dinglab/Active/Primary/CPTAC3.share/CPTAC3-GDC"
DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/GDAN-GDC"   # new GDAN data
FILE_SYSTEM="storage1"
DOCKER_SYSTEM="compute1"
LSF=1
DL_ARGS="-M -q dinglab" 
LSF_ARGS="-g $LSF_GROUP -G compute-dinglab"

# This differs for GDAN/REST and Catalog3/CPTAC3 systems
if [ $CAT_TYPE == "Catalog3" ]; then
    CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"
    BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${FILE_SYSTEM}.BamMap3.tsv"
else
    CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog-REST.tsv"  
    BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${PROJECT}.BamMap3.tsv"
fi

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/batch.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/batch.BamMap.dat"

START_DOCKERD="docker/WUDocker"
