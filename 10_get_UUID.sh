# This is very project-specific
# Here, obtaining all PDA Genomic RNA-Seq data and writing UUIDs to download to $OUT

source gdc-import.config.sh

OUT=$UUID
mkdir -p dat

grep PDA $CATALOG_MASTER | grep genomic | cut -f 11 | sort > $OUT
echo Written to $OUT
