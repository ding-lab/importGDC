#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu

# This is a wrapper around src/evaluate_status.sh with parsing of configuration for convenience
# All arguments passed to here will be passed to evaluate_status.sh

# TODO: src/evaluate_status.sh can accept specific UUIDs as arguments, wereas here we just
# go through all UUIDs.  Might want to improve this to allow UUID lists to be passed

source gdc-import.config.sh

if [ $LSF == 1 ]; then
    ARG="-M"
fi

CMD="bash src/evaluate_status.sh $ARG -C $CAT_TYPE -S $CATALOG_MASTER -O $DATA_ROOT $@ - < $UUID"
>&2 echo Running: $CMD
eval $CMD
