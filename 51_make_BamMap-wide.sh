# Creating Bammap-wide file.  If run on compute1, need to be running inside docker
source gdc-import.config.sh

PYTHON=/usr/bin/python3

#CATALOGD="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
#CATALOG="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"

CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
CATALOG="$CATALOGD/Catalog3/CPTAC3.Catalog3.tsv"
#BM3="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/import/02.MILD_WXS_311/dat/batch.BamMap.dat.merged"
BM3="dat/batch.BamMap.dat.merged"
OUT="dat/${PROJECT}.BamMap-wide.tsv"

CMD="$PYTHON src/make_BamMap-wide.py $@ -o $OUT $BM3 $CATALOG"
>&2 echo Running: $CMD
eval $CMD


