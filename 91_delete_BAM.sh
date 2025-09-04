source gdc-import.config.sh

BMOUT="dat/BamMap3-updated.tsv"

# Recommend running with -d first time
CMD="cat $UUID | bash src/rm_UUID.sh $@ -B $BAMMAP_MASTER - > $BMOUT"

>&2 echo Running: $CMD
eval $CMD

>&2 echo Successfully completed.
>&2 echo Written to $BMOUT
>&2 echo Original BamMap: $BAMMAP_MASTER
