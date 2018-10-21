#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu
    
# Check success of downloads and generate BamMap file.  Also writes merged BamMap, 
# and instructions for user

source gdc-import.config.sh

REF="-r $REFERENCE"

bash importGDC/make_bam_map.sh -H > $BAMMAP
bash importGDC/make_bam_map.sh -O $STAGE_ROOT -S $SR_H $REF - | sort >> $BAMMAP

rc=$?
if [[ $rc != 0 ]]; then
    >&2 echo Written to $BAMMAP
    >&2 echo Errors / warnings $rc: $!.  Exiting.
    exit $rc;
fi

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

head -n1 $BAMMAP > $BMM
cat $BAMMAP_MASTER $BAMMAP | grep -v "^#" | sort >> $BMM

>&2 echo Success.  Download BamMap written to $BAMMAP
>&2 echo This file was merged with master BamMap $BAMMAP_MASTER
>&2 echo and written to merged master $BMM
>&2 echo Please examine merged master file and replace original master as appropriate
