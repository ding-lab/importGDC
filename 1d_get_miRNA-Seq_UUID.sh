# Download all samples for a given disease, reference, and experimental strategy

# Plan:
# First, get all UUIDs of interest from CATALOG file - these are the data we want
# Next, get all relevant UUIDs in BamMap - these are the data we have downloaded
# Finally, get the UUIDs which exist in the CATALOG which do NOT exist in BamMap - tehse are the ones we want to download
DIS="HNSCC"
ES="miRNA-Seq"
REF="NA"

source gdc-import.config.sh

mkdir -p dat

UUID_ALL="dat/UUID-all.dat"
UUID_LOCAL="dat/UUID-local.dat"
UUID_DOWNLOAD="dat/UUID-download-miRNA-Seq.dat"

if [ !  -e $CATALOG_MASTER ]; then
    >&2 echo Error: $CATALOG_MASTER does not exist
    exit 1
fi
if [ !  -e $BAMMAP_MASTER ]; then
    >&2 echo Error: $BAMMAP_MASTER does not exist
    exit 1
fi

echo CATALOG_MASTER: $CATALOG_MASTER
echo BAMMAP_MASTER: $BAMMAP_MASTER

# Get all data in CATALOG 
awk -v dis=$DIS -v es=$ES -v ref=$REF 'BEGIN{FS="\t";OFS="\t"}{if ($3 == dis && $4 == es && $12 == ref ) print $10}' $CATALOG_MASTER | sort > $UUID_ALL
#awk -v dis=$DIS -v es=$ES -v ref=$REF 'BEGIN{FS="\t";OFS="\t"}{if ($3 == dis && $4 == es && $12 == ref && $7 ~ "genomic") print $10}' $CATALOG_MASTER | sort > $UUID_ALL

# Get all data in BamMap
awk -v dis=$DIS -v es=$ES -v ref=$REF 'BEGIN{FS="\t";OFS="\t"}{if ($3 == dis && $4 == es && $9 == ref ) print $10}' $BAMMAP_MASTER  | sort > $UUID_LOCAL
#awk -v dis=$DIS -v es=$ES -v ref=$REF 'BEGIN{FS="\t";OFS="\t"}{if ($3 == dis && $4 == es && $9 == ref && $6 ~ "genomic") print $10}' $BAMMAP_MASTER  | sort > $UUID_LOCAL

# now obtain all UUID which exist in UUID_LOCAL but not UUID_ALL
# recall: `comm -23 A B` returns lines unique in A
comm -23 $UUID_ALL $UUID_LOCAL > $UUID_DOWNLOAD

echo written to $UUID_DOWNLOAD
