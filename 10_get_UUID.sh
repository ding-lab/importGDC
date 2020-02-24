# We want all PDA genomic RNA-Seq samples available at GDC
source gdc-import.config.sh

OUT=$UUID
mkdir -p dat

grep PDA $CATALOG_MASTER | grep genomic | cut -f 11 | sort > $OUT
echo Written to $OUT
