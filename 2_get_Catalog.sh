
source gdc-import.config.sh

# Usage: get_size_by_type TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_size_by_type {
        grep -v "^#" $DAT | awk -v t=$1 '{if ($4 == t) print}' | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}'
        #SIZE=$(grep -v "^#" $DAT | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}')
}

# Usage: get_count_by_type TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_count_by_type {
        grep -v "^#" $DAT | awk -v t=$1 '{if ($4 == t) print}' | wc -l 
        #SIZE=$(grep -v "^#" $DAT | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}')
}

function summarize {
DAT=$1
WGS_SIZE=$(get_size_by_type WGS)
WGS_COUNT=$(get_count_by_type WGS)

WXS_SIZE=$(get_size_by_type WXS)
WXS_COUNT=$(get_count_by_type WXS)

RNA_SIZE=$(get_size_by_type RNA-Seq)
RNA_COUNT=$(get_count_by_type RNA-Seq)

MIRNA_SIZE=$(get_size_by_type miRNA-Seq)
MIRNA_COUNT=$(get_count_by_type miRNA-Seq)

TOT_SIZE=$(echo "$WGS_SIZE + $WXS_SIZE + $RNA_SIZE + $MIRNA_SIZE" | bc)
TOT_COUNT=$(echo "$WGS_COUNT + $WXS_COUNT + $RNA_COUNT + $MIRNA_COUNT" | bc)

echo $DAT
echo "Total required disk space WGS: $WGS_SIZE Tb in $WGS_COUNT files"
echo "                          WXS: $WXS_SIZE Tb in $WXS_COUNT files"
echo "                      RNA-Seq: $RNA_SIZE Tb in $RNA_COUNT files"
echo "                    miRNA-Seq: $MIRNA_SIZE Tb in $MIRNA_COUNT files"
echo "                        TOTAL: $TOT_SIZE Tb in $TOT_COUNT files"
}

mkdir -p dat
UUID="dat/UUID-download.dat"

head -n1 $CATALOG_MASTER > $CATALOG_H
grep -f $UUID $CATALOG_MASTER >> $CATALOG_H

summarize $CATALOG_H
