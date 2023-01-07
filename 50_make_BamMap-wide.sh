# Creating Bammap-wide file.  If run on compute1, need to be running inside docker

PYTHON=/usr/bin/python3

CATALOGD="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
CATALOG="$CATALOGD/Catalog3/MILD.Catalog3.tsv"
#BM3="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/import/02.MILD_WXS_311/dat/batch.BamMap.dat.merged"
BM3="dat/batch.BamMap.dat.merged"
OUT="dat/MILD.BamMap-wide.tsv"

CMD="$PYTHON src/make_BamMap-wide.py $@ -o $OUT $BM3 $CATALOG"
>&2 echo Running: $CMD
eval $CMD


