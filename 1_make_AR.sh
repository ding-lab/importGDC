source gdc-import.config.sh

mkdir -p dat

DAT="origdata/GDC_methyl_array_batch9added_6_6.tsv"
OUT=$AR_H

grep "Batch 9" $DAT | bash make_AR.sh > $OUT
echo Written to $OUT
