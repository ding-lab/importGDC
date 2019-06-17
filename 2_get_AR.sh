
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
METH_SIZE=$(get_size_by_type MethArray)
METH_COUNT=$(get_count_by_type MethArray)

echo $DAT
echo "Total required disk space MethArray: $METH_SIZE Tb in $METH_COUNT files"
}

mkdir -p dat

summarize $AR_H
