#!/bin/bash

# Start import of given UUIDs.  This is run on host computer

# This is a wrapper around importGDC/start_step.sh with CPTAC3.b1-specific setup added for convenience
# All arguments passed to here will be passed to start_step.sh

# Usage: start_import.c3b1.sh [options] UUID [UUID2 ...]
# Start import on host computer.  
#
# If UUID is - then read UUID from STDIN

source gdc-import.config.sh

if [ ! -e $GDC_TOKEN ]; then
    >&2 echo Error: Token file $GDC_TOKEN not found
    exit
fi

# This is MGI-specific
if [ ! -z $LSF_GROUP ]; then
    LSF_GROUP_ARG="-g $LSF_GROUP"
fi

# Copy token defined in host dir to container's /data directory
# Note there may be some security considerations associated with this
# TODO: this should be done by start_step, not here.
mkdir -p $IMPORT_CONFIGD_H/token
>&2 echo Copying $GDC_TOKEN to $IMPORT_CONFIGD_H/token/gdc-user-token.txt
cp $GDC_TOKEN $IMPORT_CONFIGD_H/token/gdc-user-token.txt
TOKEN_C="$IMPORT_CONFIGD_C/token/gdc-user-token.txt"

# This is where logs go
LOGD_H="$IMPORT_CONFIGD_H/logs"

if [ $MGI == 1 ]; then
    MGI_FLAG="-M"
fi

bash importGDC/start_step.sh $MGI_FLAG -O $DATA_ROOT -S $CATALOG_H $LSF_GROUP_ARG -t $TOKEN_C -l $LOGD_H "$@"
