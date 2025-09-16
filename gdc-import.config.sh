# Download batch name.  

PROJECT="TCGA"
CAT_TYPE="REST" # Catalog3 or REST

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2025-09-04T16_53_36.318Z.txt"

# Format: /USER/gdc-download
# Create with `bgadd -L 5 /USER/gdc-download`
LSF_GROUP="/mwyczalk/gdc-download"

# List of UUIDs to download - and delete if we're deleting the whole batch
UUID="dat/UUID_download.dat"
UUID_DELETE="dat/UUID_download.dat"

# Current policy is to keep all GDC data on a volume named GDAN-GDC.  The older CPTAC3-GDC
# DATA_ROOT is no longer used
# Try to stay on m.wyczalkowski when possible
DATA_ROOT="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/GDAN-GDC"   # All GDC data on m.wyczalkowski
#DATA_ROOT="/storage1/fs1/dinglab/Active/Primary/GDAN-GDC"                      # All GDC data on dinglab

FILE_SYSTEM="storage1"
DOCKER_SYSTEM="compute1"
LSF=1
DL_ARGS="-M -q dinglab" 
LSF_ARGS="-g $LSF_GROUP -G compute-dinglab"

# This differs for GDAN and CPTAC3 systems
if [ $PROJECT == "CPTAC3" ]; then
# for CPTAC3
    CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
    BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${FILE_SYSTEM}.BamMap3.tsv"
else
# for GDAN
    CATALOGD="/rdcw/fs2/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
    BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${PROJECT}.BamMap3.tsv"
    BAMMAP_WIDE="$CATALOGD/Catalog3/WUSTL-BamMap/${PROJECT}.BamMap-wide.tsv"
fi

# note that CPTAC3 can have catalog3 or REST catalogs
if [ $CAT_TYPE == "REST" ]; then
    CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog-REST.tsv"  
else
    CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"
fi

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/batch.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/batch.BamMap.dat"

START_DOCKERD="docker/WUDocker"
