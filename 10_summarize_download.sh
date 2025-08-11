
source gdc-import.config.sh

# CAT_TYPE="Catalog3"
# CAT_TYPE="GDAN"

# Catalog3 format
#     1  dataset_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  sample_type
#     6  specimen_name
#     7  filename
#     8  filesize
#     9  data_format
#    10  data_variety
#    11  alignment
#    12  project
#    13  uuid
#    14  md5
#    15  metadata


# modified to work with current GDC REST API catalog
# Usage: get_size_by_type TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_size_by_type {
   # for Catalog3 
   if [ $CAT_TYPE == "Catalog3" ]; then
       grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($4 == t) print}' | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}'
   else
       grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($5 == t) print}' | cut -f 9 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}'
    fi
}

# Usage: get_count_by_type TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_count_by_type {
   # for Catalog3 
    if [ $CAT_TYPE == "Catalog3" ]; then
        grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($4 == t) print}' | wc -l 
    else
        grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($5 == t) print}' | wc -l 
    fi
}

function summarize {
DAT=$1

>&2 echo Summarizing $DAT
WGS_SIZE=$(get_size_by_type WGS)
WGS_COUNT=$(get_count_by_type WGS)

WXS_SIZE=$(get_size_by_type WXS)
WXS_COUNT=$(get_count_by_type WXS)

RNA_SIZE=$(get_size_by_type RNA-Seq)
RNA_COUNT=$(get_count_by_type RNA-Seq)

MIRNA_SIZE=$(get_size_by_type miRNA-Seq)
MIRNA_COUNT=$(get_count_by_type miRNA-Seq)

METH_SIZE=$(get_size_by_type "Methylation_Array")
METH_COUNT=$(get_count_by_type "Methylation_Array")

TARG_SIZE=$(get_size_by_type "Targeted_Sequencing")
TARG_COUNT=$(get_count_by_type "Targeted_Sequencing")

SCRNA_SIZE=$(get_size_by_type "scRNA-Seq")
SCRNA_COUNT=$(get_count_by_type "scRNA-Seq")

TOT_SIZE=$(echo "$WGS_SIZE + $WXS_SIZE + $RNA_SIZE + $MIRNA_SIZE + $METH_SIZE + $TARG_SIZE + $SCRNA_SIZE" | bc)
TOT_COUNT=$(echo "$WGS_COUNT + $WXS_COUNT + $RNA_COUNT + $MIRNA_COUNT + $METH_COUNT + $TARG_COUNT + $SCRNA_COUNT" | bc)

echo "Total required disk space WGS: $WGS_SIZE Tb in $WGS_COUNT files"
echo "                          WXS: $WXS_SIZE Tb in $WXS_COUNT files"
echo "                      RNA-Seq: $RNA_SIZE Tb in $RNA_COUNT files"
echo "                    miRNA-Seq: $MIRNA_SIZE Tb in $MIRNA_COUNT files"
echo "            Methylation Array: $METH_SIZE Tb in $METH_COUNT files"
echo "          Targeted Sequencing: $TARG_SIZE Tb in $TARG_COUNT files"
echo "                    scRNA-Seq: $SCRNA_SIZE Tb in $SCRNA_COUNT files"
echo "                        TOTAL: $TOT_SIZE Tb in $TOT_COUNT files"
}

mkdir -p dat
>&2 echo Catalog: $CATALOG_MASTER
>&2 echo Evaluating UUIDs from $UUID

head -n1 $CATALOG_MASTER > $CATALOG_H
fgrep -f $UUID $CATALOG_MASTER >> $CATALOG_H

summarize $CATALOG_H
