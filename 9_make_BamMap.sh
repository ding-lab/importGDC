#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu
    
# This is a wrapper around importGDC/summarize_import.sh with CPTAC3.b1-specific setup added for convenience
# All arguments passed to here will be passed to evaluate_status.sh

# Summarize details of given samples and check success of 
# Usage: summarize_import.sh [options] UUID [UUID2 ...]
# If UUID is - then read UUID from STDIN
#
# Output written to STDOUT

# options
# -r REF: reference name - assume same for all SR.  Default: hg19

source gdc-import.config.sh


UUIDFN="$CONFIG_HOME_H/*.batch.dat"

OUT="$CONFIG_HOME_H/${BATCH}.BamMap.dat"

# -w squelches warnings about data not being downloaded
cut -f 1 $UUIDFN | bash $IMPORTGDC_HOME/batch.import/make_bam_map.sh -O $DATAD -S $SR -H -w - | sort > $OUT

echo Written to $OUT

