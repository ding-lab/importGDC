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
        >&2 echo Partly written to $BAMMAP
        >&2 echo Stopping.  Will not merge with Master BamMap.
		exit $rc;
	fi;
done

# If no errors, write merged BamMap, which is BAMMAP and BAMMAP_MASTER concatenated and sorted
# The output filename will be $BAMMAP.merged
# If master BAMMAP not defined, exit with no error; if defined but not exist, exit with error
if [ -z $BAMMAP_MASTER ]; then
    >&2 echo Master BamMap not defined.  Stopping.
    >&2 echo Download BamMap written to $BAMMAP
    exit 0
fi
if [ ! -e $BAMMAP_MASTER ]; then
    >&2 echo Error: Master BamMap defined but does not exist.  Exiting 
    >&2 echo Master BamMap: $BAMMAP_MASTER
    exit 1
fi

BMM="${BAMMAP}.merged"

head -n 1 $BAMMAP > $BMM
cat <(tail -n +2 $BAMMAP_MASTER) <(tail -n +2 $BAMMAP) | grep -v "^#" | sort -u >> $BMM

>&2 echo Success.  Download BamMap written to $BAMMAP
>&2 echo Merged with BamMap $BAMMAP_MASTER
>&2 echo Written to $BMM
>&2 echo Please examine merged master file and replace original master as appropriate
