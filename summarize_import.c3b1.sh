# This is a wrapper around importGDC/summarize_import.sh with CPTAC3.b1-specific setup added for convenience
# All arguments passed to here will be passed to evaluate_status.sh

# Summarize details of given samples and check success of 
# Usage: summarize_import.sh [options] UUID [UUID2 ...]
# If UUID is - then read UUID from STDIN
#
# Output written to STDOUT

# options
# -r REF: reference name - assume same for all SR.  Default: hg19

DATA_DIR="/gscmnt/gc2521/dinglab/mwyczalk/CPTAC3-download/"
export IMPORTGDC_HOME="/gscuser/mwyczalk/src/importGDC"
SR="config/SR.CPTAC3.b1.dat"

bash $IMPORTGDC_HOME/batch.import/summarize_import.sh -O $DATA_DIR -S $SR "$@"
