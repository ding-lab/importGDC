# Given cases list, get UUIDs of associated WGS 

source gdc-import.config.sh

UUID="dat/UUID.dat"
CASES="dat/cases.yb6.dat"

grep -f $CASES $SR_MASTER | awk 'BEGIN{FS="\t";OFS="\t"}{if ($4 == "WGS") print $10}' > $UUID
echo written to $UUID
