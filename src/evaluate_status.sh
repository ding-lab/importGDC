#!/bin/bash
#
# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu

read -r -d '' USAGE <<'EOF'
Usage: evaluate_status.sh [options] UUID [UUID2 ...]

Evaluate status of samples based on UUID

Required arguments:
-S CATALOG: path to Catalog data file. Required 
-O DATA_ROOT: path to base of download directory (will write to $DATA_ROOT/GDC_import/data). Required

Options:
-h: print help message
-1 : stop after one case processed.
-l LOGD: Log output base directory.  Default: ./logs
-M: Run in LSF environment (MGI or compute1)
-f status: output only lines matching status, e.g., -f import:complete
-u: include only UUID in output
-D: include data file path in output

If UUID is - then read UUID from STDIN
EOF

# We can launch in importGDC root dir or ./src.  Test based on existence of utils.sh, and cd to root dir if necessary
# utils.sh might live in . or ./src, depending on where this script runs 
if [ -e utils.sh ]; then
    cd ..
elif [ ! -e src/utils.sh ]; then 
    >&2 ERROR: cannot locate src/utils.sh
    exit 1
fi
source src/utils.sh

SCRIPT=$(basename $0)

LOG_DIR="./logs"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":S:O:h1l:Mf:uD" opt; do
  case $opt in
    S) 
      CATALOG=$OPTARG
      ;;
    O) 
      DATA_ROOT="$OPTARG"
      ;;
    h) 
      echo "$USAGE"
      exit 0
      ;;
    1)  
      JUSTONE=1
      ;;
    l) 
      LOG_DIR="$OPTARG"
      ;;
    M)  
      LSF=1
      ;;
    f) 
      FILTER=$OPTARG
      ;;
    u)  
      UUID_ONLY=1
      ;;
    D)  
      DATA_PATH=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 1 ]; then
    >&2 echo ERROR: Wrong number of arguments
    >&2 echo "$USAGE"
    exit 1
fi

if [ -z $CATALOG ]; then
    >&2 echo ERROR: CATALOG not defined
    >&2 echo "$USAGE"
    exit 1
fi
if [ -z $DATA_ROOT ]; then
    >&2 echo ERROR: DATA_ROOT not defined
    >&2 echo "$USAGE"
    exit 1
fi

confirm $CATALOG
DATAD="$DATA_ROOT/GDC_import/data"  
if [ ! -d $DATAD ]; then
    >&2 echo "ERROR: Data directory does not exist: $DATAD"
    exit 1
fi

# this allows us to get UUIDs in one of two ways:
# 1: start_step.sh ... UUID1 UUID2 UUID3
# 2: cat UUIDS.dat | start_step.sh ... -
if [ $1 == "-" ]; then
    UUIDS=$(cat - )
else
    UUIDS="$@"
fi


# Evaluate download status of gdc-client by examining LSF logs (LSF-specific) and existence of output file
# Returns one of "ready", "running", "complete", "incomplete", "error"
# Usage: test_import_success UUID FN DF
# where FN is the filename (relative to data directory) as written by gdc-client
# and DF is the data format.  Specifically, we test whether DF is BAM
function test_import_success {
    UUID=$1
    FN=$2
    DF=$3

    LOGERR="$LOG_DIR/$UUID.err"  
    LOGOUT="$LOG_DIR/$UUID.out"
    DAT="$DATAD/$UUID/$FN"
    DATP="$DATAD/$UUID/$FN.partial"

    # flow of gdc-client download and processing
    # 1. create output directory and $DAT.partial file as it is being downloaded
    # 2. index file (if it is a .bam) to create .bai file
    # 3. flagstat file (if it is a .bam) to create .flagstat file
    # 3. Create $DAT when it is finished.  Write "Successfully completed." to log.out file
    # 4. If dies for some reason, write "Exited with exit code" to log.out file

    # Other tests may be added as necessary

    # If neither DAT or DATP created, assume download did not start and status is ready
    if [ ! -e $DAT ] && [ ! -e $DATP ] ; then
        echo ready
        return
    fi

    # Handle the case where LOGOUT does not exist - this might happen during some error conditions.
    # We won't know if running or error, but might establish complete or incomplete
    # LSF and non-LSF stderr outputs are relatively similar in Y3, but for now testing stdout for LSF
    if [ $LSF ]; then 
        if [ ! -e $LOGOUT ]; then
            >&2 echo WARNING: Log file $LOGOUT does not exist.  Continuing.
        else
            ERROR="Exited with exit code"
            if fgrep -Fq "$ERROR" $LOGOUT; then
                echo error
                return
            fi

            SUCCESS="Successfully completed."
            if ! fgrep -Fxq "$SUCCESS" $LOGOUT; then
                echo running
                return
            fi
        fi
    else
        if [ ! -e $LOGERR ]; then
            >&2 echo WARNING: Log file $LOGERR does not exist.  Continuing.
        else
            ERROR="error"
            if fgrep -i -Fq "$ERROR" $LOGERR; then
                echo error
                return
            fi

            SUCCESS="Download succeeded"
            if ! fgrep -Fxq "$SUCCESS" $LOGERR; then
                echo running
                return
            fi
        fi
    fi

    # In case of BAM file, test if .bai and .flagstat files exists.  If both do, we are completed.  Otherwise, incomplete
    if [ "$DF" == 'BAM' ]; then
        BAI="$DAT.bai"
        FLAGSTAT="$DAT.flagstat"
        if [[ -s $BAI && -s $FLAGSTAT ]]; then
            echo complete
        else
            echo incomplete
        fi
    else
    # If not BAM file, just test if result file exists
        if [ -e $DAT ]; then
            echo complete
        else
            echo incomplete
        fi
    fi
}

function get_job_status {
UUID=$1
SN=$2
FN=$3
DF=$3
# evaluates status of import by checking LSF logs
# Based on /gscuser/mwyczalk/projects/SomaticWrapper/SW_testing/BRCA77/2_get_runs_status.sh

# Its not clear how to test completion of a program in a general way, and to test if it exited with an error status
# For now, we'll grep for "Successfully completed." in the .out file of the submitted job
# This will probably not catch jobs which exit early for some reason (memory, etc), and is LSF specific


TEST1=$(test_import_success $UUID $FN $DF)  

# for multi-step processing would report back a test for each step
printf "$UUID\t$SN\t$DATAD/$UUID/$FN\timport:$TEST1\n"
}

function process_UUID {
    UUID=$1

# REST API Catalog file format
#     1  dataset_name    CTSP-ACY0.WGS.N
#     2  case    CTSP-ACY0
#     3  sample_type Blood Derived Normal
#     4  data_format BAM
#     5  experimental_strategy   WGS
#     6  preservation_method Frozen
#     7  aliquot CTSP-ACY0-NB1-A-1-0-D-A791-36
#     8  file_name   957099c7-0bc3-42dd-8df0-ffec8f99955a_wgs_gdc_realn.bam
#     9  file_size   78181632397
#    10  id  0e4322dc-bccf-481b-906a-e7ed5c3ce56a
#    11  md5sum  52112fbc3679a8478b9eac328bffb2d3


# Catalog3 header
#     1  dataset_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  sample_type
#     6  specimen_name
#     7  filename
#     8  filesize
#     9  data_format
#    10  data_variety
#    11  alignment
#    12  project
#    13  uuid
#    14  md5
#    15  metadata


# Catalog3
    SN=$(grep $UUID $CATALOG | cut -f 1)
    FN=$(grep $UUID $CATALOG | cut -f 7)
    DF=$(grep $UUID $CATALOG | cut -f 9)

# REST
#    SN=$(grep $UUID $CATALOG | cut -f 1)
#    FN=$(grep $UUID $CATALOG | cut -f 8)
#    DF=$(grep $UUID $CATALOG | cut -f 4)

    STATUS=$(get_job_status $UUID $SN $FN $DF)

    # which columns to output?
    if [ ! -z $UUID_ONLY ]; then
        COLS="1"
    elif [ ! -z $DATA_PATH ]; then        
        COLS="1-4" 
    else 
        COLS="1,2,4" 
    fi

    if [ ! -z $FILTER ]; then
        echo "$STATUS" | grep $FILTER | cut -f $COLS
    else 
        echo "$STATUS" | cut -f $COLS
    fi
}

# Loop over all remaining arguments
for UUID in $UUIDS
do
    process_UUID $UUID
    if [ $JUSTONE ]; then
        break
    fi
done
