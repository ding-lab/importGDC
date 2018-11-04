# Get all UCEC hg38 cases which have not yet been downloaded
# Note that SR_MASTER here refers to HAR (i.e., hg38) data

# Plan:
# First, get all UCEC UUIDs in SR file - these are all available hg38 data at GDC
# Next, get all UCEC UUIDs in BamMap - these are the data we have downloaded
# Finally, get the UUIDs which exist in the SR which do NOT exist in BamMap - tehse are the ones we want to download

source gdc-import.config.sh

mkdir -p dat

UUID_ALL="dat/UUID-all-UCEC.dat"
UUID_KATMAI="dat/UUID-katmai.dat"
UUID_DOWNLOAD="dat/UUID-download.dat"

# Get all UCEC data in SR 
awk 'BEGIN{FS="\t";OFS="\t"}{if ($3 == "UCEC") print $10}' $SR_MASTER | sort > $UUID_ALL
# Get all UCEC data in BamMap
awk 'BEGIN{FS="\t";OFS="\t"}{if ($3 == "UCEC") print $10}' $BAMMAP_MASTER  | sort > $UUID_KATMAI

# now obtain all UUID which exist in UUID_KATMAI but not UUID_ALL
# recall: `comm -23 A B` returns lines unique in A
comm -23 $UUID_ALL $UUID_KATMAI > $UUID_DOWNLOAD

echo written to $UUID_DOWNLOAD
