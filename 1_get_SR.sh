# Here, we use the C325 SR file generated on denali here:
# We select a subset of cases from the file /Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/dat/CPTAC3.C325.cases.dat 
# 

# Usage: get_size_by_type TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_size_by_type {
        grep -v "^#" $DAT | awk -v t=$1 '{if ($4 == t) print}' | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}'
        #SIZE=$(grep -v "^#" $DAT | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}')
}

function summarize {
DAT=$1
WGS_SIZE=$(get_size_by_type WGS)
WXS_SIZE=$(get_size_by_type WXS)
RNA_SIZE=$(get_size_by_type RNA-Seq)

echo $DAT
echo "Total required disk space WGS: $WGS_SIZE Tb"
echo "                          WXS: $WXS_SIZE Tb"
echo "                          RNA-Seq: $RNA_SIZE Tb"
}




SR="/gscuser/mwyczalk/projects/CPTAC3/CPTAC3.catalog/CPTAC3.hg38.b2.HAR.dat"
BATCH="LUAD.WGS.hg38"

mkdir -p dat
UUID="dat/UUID.dat"
SR_NEW="dat/CPTAC3.$BATCH.SR.dat"

echo "AWK start"
awk 'BEGIN{FS="\t"; OFS="\t"}{if ($3 == "LUAD" && $4 == "WGS") print $10}' $SR  > $UUID
echo "AWK end"

head -n1 $SR > $SR_NEW
grep -f $UUID $SR >> $SR_NEW

echo Written to $SR_NEW

summarize $SR_NEW
