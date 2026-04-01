# Download batch name.  

PROJECT="CPTAC3"
CAT_TYPE="REST" # Catalog3 or REST

# Download token from GDC, good for 30 days.  Generating a new one causes old ones to break
GDC_TOKEN="../token/gdc-user-token.2026-03-03T20_01_37.928Z.txt"

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

# Catalog location differs for GDAN and CPTAC3 systems
if [ $PROJECT == "CPTAC3" ]; then
# for CPTAC3
    CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
#    BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${FILE_SYSTEM}.BamMap3.tsv"
else
# for GDAN
    CATALOGD="/rdcw/fs2/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
#    BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/${PROJECT}.BamMap3.tsv"
fi

# note that CPTAC3 used to have catalog3 or REST catalogs
# now, after CPTAC3 / GDAN merge only REST catalogs are supported
#if [ $CAT_TYPE == "REST" ]; then
CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog-REST.tsv"  
#else
#    CATALOG_MASTER="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"
#fi
if [ ! -e $CATALOG_MASTER ]; then
    >&2 echo ERROR: Catalog does not exist: $CATALOG_MASTER
    exit 1
fi

BAMMAPD="/rdcw/fs2/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
BAMMAP_MASTER="$CATALOGD/Catalog3/WUSTL-BamMap/storage1-GDC-BamMap4.tsv"
if [ ! -e $BAMMAP_MASTER ]; then
    >&2 echo ERROR: BamMap does not exist: $BAMMAP_MASTER
    exit 1
fi

# This file is generated in step 2 as a subset of CATALOG_MASTER
# It is no longer used to drive the workflow but remains for convenience
CATALOG_H="dat/batch.Catalog.dat"

# BAMMAP is created as the final step of import process.
BAMMAP="dat/batch.BamMap.dat"

START_DOCKERD="docker/WUDocker"
