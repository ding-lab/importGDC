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




CASES="../CommonFiles/CPTAC3.C325.cases.dat"
SR="../CommonFiles/CPTAC3.C325.SR.dat"

BATCH="b4"  # This has to match column in cases file
DIS="LUAD"

mkdir -p dat
TMP="dat/cases.tmp"
SR_NEW="dat/CPTAC3.${DIS}.${BATCH}.SR.dat"

awk -v batch=$BATCH -v dis=$DIS 'BEGIN{FS="\t"; OFS="\t"}{if (($3 == batch) && ($2 == dis)) print $1}' $CASES  > $TMP

head -n1 $SR > $SR_NEW
grep -f $TMP $SR >> $SR_NEW

echo Written to $SR_NEW

summarize $SR_NEW
