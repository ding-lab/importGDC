# d3 batch consists of three UCEC batches
# Special request by Dan Cui to add them to existing set of UCEC analyses
# Note that these do not have WXS data.  Cases are:
# C3L-01925, C3N-01346, C3N-01349
#
# Here, we use the C325 SR file generated on denali here:
# We select a subset (batch = d3) of cases from the file /Users/mwyczalk/Projects/CPTAC3/CPTAC3.Cases/dat/CPTAC3.C325.cases.dat 
# 
CASES="../CommonData/CPTAC3.C325.cases.dat"
SR="../CommonData/CPTAC3.C325.SR.dat"

BATCH="d3"

mkdir -p dat
TMP="dat/cases.tmp"
SR_NEW="dat/CPTAC3.$BATCH.SR.dat"

awk -v batch=$BATCH 'BEGIN{FS="\t"; OFS="\t"}{if ($3 == batch) print $1}' $CASES  > $TMP

grep -f $TMP $SR > $SR_NEW

echo Written to $SR_NEW
echo Please copy this to /gscmnt/gc2741/ding/CPTAC3-data/GDC_import/import.config/CPTAC3.d3/CPTAC3.d3.SR.dat
