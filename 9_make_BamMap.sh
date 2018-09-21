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

UUIDFN="$IMPORT_CONFIGD_H/*.batch.dat"

REF="-r hg38"

# -w squelches warnings about data not being downloaded
bash $IMPORTGDC_HOME/make_bam_map.sh -H > $BAMMAP
cut -f 1 $UUIDFN | bash $IMPORTGDC_HOME/make_bam_map.sh -O $IMPORT_DATAD_H -S $SR_H $REF - | sort >> $BAMMAP

echo Written to $BAMMAP

echo TODO: check all md5sums
