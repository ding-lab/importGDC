#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu
    
# Check success of downloads and generate BamMap file.  Also writes merged BamMap, 
# and instructions for user

source gdc-import.config.sh

CMD="cat $UUID | bash src/make_BamMap3.sh -C $CAT_TYPE -H -O $DATA_ROOT -S $CATALOG_MASTER -s $FILE_SYSTEM $@ - > $BAMMAP"
echo "Running: $CMD"
eval $CMD

# Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
rcs=${PIPESTATUS[*]};
for rc in ${rcs}; do
	if [[ $rc != 0 ]]; then
		>&2 echo Errors / warnings processing BamMap 
        exit $rc;
	fi;
done

>&2 echo Successfully written to $BAMMAP
