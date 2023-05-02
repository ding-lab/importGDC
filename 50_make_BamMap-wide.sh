# Creating Bammap-wide file.  If run on compute1, need to be running inside docker
source gdc-import.config.sh

PYTHON="./python3_docker"

#CATALOGD="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
#CATALOG="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"
#FileNotFoundError: [Errno 2] File b'/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog3.tsv' does not exist: b'/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog3.tsv'

#CATALOG="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.GDC_REST.20230409-AWG.tsv"
CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.GDC_REST.20230409-AWG.tsv"

#BM3="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/import/02.MILD_WXS_311/dat/batch.BamMap.dat.merged"
BM3="BamMapFix/DLBCL.BamMap3.merged-435.tsv"
OUT="dat/${PROJECT}.BamMap-wide.tsv"

CMD="$PYTHON src/make_BamMap-wide.py $@ -o $OUT $BM3 $CATALOG"
>&2 echo Running: $CMD
eval $CMD


