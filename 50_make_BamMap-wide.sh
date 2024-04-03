# Creating Bammap-wide file.  If run on compute1, need to be running inside docker
source gdc-import.config.sh

# TODO: Make this run in interactive / foreground mode.  Do not return until job done
# Also clean up cache / home issues - same directory but different paths shown

PYTHON="./python3_docker"

#CATALOGD="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
#CATALOG="$CATALOGD/Catalog3/${PROJECT}.Catalog3.tsv"
#FileNotFoundError: [Errno 2] File b'/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog3.tsv' does not exist: b'/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog3.tsv'


# top one does not work
#CATALOG="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/HCMI.Catalog-REST.tsv"
#CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/HCMI.Catalog-REST.tsv"
#CATALOGD="/rdcw/fs2/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
#CATALOG="$CATALOGD/HCMI.Catalog-REST.tsv"


#CATALOG="/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/DLBCL.GDC_REST.20230409-AWG.tsv"
#CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/MILD.Catalog-REST.tsv"
#CATALOG="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/CTSP_DLBCL.Catalog-REST.tsv"
#CATALOG="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog/Catalog3/CPTAC3.Catalog3.tsv"

# Error like this indicates that header in wrong line, needs to be fixed:
# KeyError: "['dataset_name'] not found in axis"

#BM3="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/import/02.MILD_WXS_311/dat/batch.BamMap.dat.merged"
BM3="dat/batch.BamMap.dat.merged"
OUT="dat/${PROJECT}.BamMap-wide.tsv"

echo catalog = $CATALOG_MASTER
CMD="$PYTHON src/make_BamMap-wide.py $@ -o $OUT $BM3 $CATALOG_MASTER"
>&2 echo Running: $CMD
>&2 echo Writing to $OUT
eval $CMD


