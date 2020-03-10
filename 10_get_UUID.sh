# This is very project-specific
# Here, obtain all WGS data for the following diseases which does not exist on storage1
# * HNSCC
# * PDA

source gdc-import.config.sh

OUT1="dat/UUID-Catalog.dat"
OUT2="dat/UUID-storage1.dat"
mkdir -p dat

OUT=$UUID

#PRIORITY="HNSCC\|PDA\|LUAD\|CCRCC\|UCEC"
PRIORITY="HNSCC\|PDA"

grep "$PRIORITY" $CATALOG_MASTER | grep WGS | grep hg38 | cut -f 11 | sort > $OUT1
echo Written all UUID to $OUT1

# now get all WGS hg38 UUIDs which are available on storage1
echo $BAMMAP_MASTER
grep "$PRIORITY" $BAMMAP_MASTER | grep WGS | grep hg38 | cut -f 10 | sort > $OUT2
echo Written storage1 UUID to $OUT2

# Get all UUIDs which exist in catalog but not storage1
comm -23 $OUT1 $OUT2 > $OUT
echo Written download UUID to $OUT
