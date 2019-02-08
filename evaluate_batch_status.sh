#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu

# This is a wrapper around importGDC/evaluate_status.sh with CPTAC3.b1-specific setup added for convenience
# All arguments passed to here will be passed to evaluate_status.sh

# Usage from evaluate_status.sh

# Evaluate status of all samples in batch file 
# This is specific to MGI (dependent on LSF-specific output to evaluate status)
# Usage: evaluate_status.sh [options] batch.dat
#
# options
# -f status: output only lines matching status, e.g., -f import:completed
# -u: include only UUID in output
# -D: include data file path in output

# TODO: update documentation

source gdc-import.config.sh

# Example 
# evaluate_status.c3b1.sh -u -f import:ready dat/WXS.batch.dat 

#AR_TEST="dat/test.AR.dat"

bash importGDC/evaluate_status.sh -O $STAGE_ROOT -C $IMPORT_CONFIGD_H "$@" $AR_H
#bash importGDC/evaluate_status.sh -O $STAGE_ROOT -C $IMPORT_CONFIGD_H "$@" $AR_TEST
