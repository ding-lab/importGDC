
H="/rdcw/fs2/home1/Active"
CATALOG_FN="$H/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/GDC.Catalog-REST.tsv"
NEWBM="dat/batch.BamMap.dat"
MASTER_BM="$H/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog/Catalog3/WUSTL-BamMap/storage1-GDC-BamMap4.tsv"

OUTPUT_FN="dat/new-storage1.BamMap.tsv"

CMD="python3 src/parse_catalog.py -c $CATALOG_FN -n $NEWBM -m $MASTER_BM -o $OUTPUT_FN"
echo $CMD
eval $CMD
