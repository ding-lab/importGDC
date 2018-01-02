#!/bin/bash

# Start import of given UUIDs.  This is run on host computer

# This is a wrapper around importGDC/start_step.sh with CPTAC3.b1-specific setup added for convenience
# All arguments passed to here will be passed to start_step.sh

# Using LSF_Group /mwyczalk/gdc-download (TODO: allow this to be defined in environment variable)

# Usage: start_import.c3b1.sh [options] UUID [UUID2 ...]
# Start import on host computer.  
# options:
# -d: dry run
#
# If UUID is - then read UUID from STDIN

source gdc-import.config.sh
# Data download location given by DATAD

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
mkdir -p $CONFIG_HOME_H/token
>&2 echo Copying $GDC_TOKEN to $CONFIG_HOME_H/token/gdc-user-token.txt
cp $GDC_TOKEN $CONFIG_HOME_H/token/gdc-user-token.txt
TOKEN_C="$CONFIG_HOME_C/token/gdc-user-token.txt"

# This is where bsub logs go
LOGD_H="$CONFIG_HOME_H/logs"

if [ $MGI == 1 ]; then
MGI_FLAG="-M"
fi

bash $IMPORTGDC_HOME/batch.import/start_step.sh $MGI_FLAG -O $DATAD -S $SR $LSF_GROUP_ARG -t $TOKEN_C -l $LOGD_H -s import "$@"
