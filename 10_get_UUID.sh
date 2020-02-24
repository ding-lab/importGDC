# We want all PDA genomic RNA-Seq samples available at GDC

CATALOG="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"
OUT="dat/UUID_download.dat"
mkdir -p dat

grep PDA $CATALOG | grep genomic | cut -f 11 | sort > $OUT
echo Written to $OUT
