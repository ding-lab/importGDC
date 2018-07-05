# Here, we use the C325 SR file generated on denali here:
# We select a subset of cases from the file /Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/dat/CPTAC3.C325.cases.dat 
# 
CASES="../CommonFiles/CPTAC3.C325.cases.dat"
SR="../CommonFiles/CPTAC3.C325.SR.dat"

SEARCH_BATCH="b5"  # This has to match column in cases file
OUT_BATCH="CCRC.b5"  # This should match what's in gdc-import.config.sh
DIS="CCRC"

mkdir -p dat
TMP="dat/cases.tmp"
SR_NEW="dat/CPTAC3.${OUT_BATCH}.SR.dat"

awk -v batch=$SEARCH_BATCH -v dis=$DIS 'BEGIN{FS="\t"; OFS="\t"}{if (($3 == batch) && ($2 == dis)) print $1}' $CASES  > $TMP

grep -f $TMP $SR > $SR_NEW

echo Written to $SR_NEW
