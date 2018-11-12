# Get all CCRC hg38 cases which have not yet been downloaded
# Note that SR_MASTER here refers to HAR (i.e., hg38) data

# Plan:
# First, get all CCRC UUIDs in SR file - these are all available hg38 data at GDC
# Next, get all CCRC UUIDs in BamMap - these are the data we have downloaded
# Finally, get the UUIDs which exist in the SR which do NOT exist in BamMap - tehse are the ones we want to download

source gdc-import.config.sh

mkdir -p dat

UUID_ALL="dat/UUID-all.dat"
UUID_LOCAL="dat/UUID-local.dat"
UUID_DOWNLOAD="dat/UUID-download.dat"

if [ !  -e $SR_MASTER ]; then
    >&2 echo Error: $SR_MASTER does not exist
    exit 1
fi
if [ !  -e $BAMMAP_MASTER ]; then
    >&2 echo Error: $BAMMAP_MASTER does not exist
    exit 1
fi

echo SR_MASTER: $SR_MASTER
echo BAMMAP_MASTER: $BAMMAP_MASTER

# Get all CCRC data in SR 
awk 'BEGIN{FS="\t";OFS="\t"}{if ($3 == "CCRC") print $10}' $SR_MASTER | sort > $UUID_ALL
# Get all CCRC data in BamMap
awk 'BEGIN{FS="\t";OFS="\t"}{if ($3 == "CCRC") print $10}' $BAMMAP_MASTER  | sort > $UUID_LOCAL

# now obtain all UUID which exist in UUID_LOCAL but not UUID_ALL
# recall: `comm -23 A B` returns lines unique in A
comm -23 $UUID_ALL $UUID_LOCAL > $UUID_DOWNLOAD

echo written to $UUID_DOWNLOAD
