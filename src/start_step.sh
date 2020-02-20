#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu

read -r -d '' USAGE <<'EOF'
Usage: start_step.sh [options] UUID [UUID2 ...]
Start import. Run on host computer
Options:
-h: print help message
-d: dry run.  This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead, 
    with each called function called in dry run mode if it gets one -d, and popping off one and passing rest otherwise
-1 : stop after one case processed.
-g LSF_GROUP: LSF group to use starting job
-S SR_H: path to SR data file.  Default: config/SR.dat
-O IMPORT_DATAD_H: path to base of download directory (will write to $IMPORT_DATAD_H/GDC_import/data). Default: ./data
-t TOKEN_C: token filename, path relative to container.  Required
-l LOGD_H: Log output directory.  Required for MGI
-D: Download only, do not index
-I: Index only, do not Download.  DT must be "BAM"
-M: MGI environment
-B: Run BASH in Docker instead of gdc-client
-f: force overwrite of existing data files
-J PARALLEL_CASES: Specify number of UUID to run in parallel in non-MGI mode
   * Run this many cases at a time using `parallel`.  If not defined, run cases sequentially
   * If in MGI environment, exit with an error.  Parallel downloads are handled by bsub in MGI

If UUID is - then read UUID from STDIN

Path to importGDC directory is defined by environment variable IMPORTGDC_HOME.  Default
is /usr/local/importGDC; can be changed with,
```
   export IMPORTGDC_HOME="/path/to/importGDC"
```
EOF

# Parallel code based on https://github.com/mwyczalkowski/BICSEQ2/blob/master/src/process_cases.sh

# If environment variable not defined, set it for the duration of this script to the path below
if [ -z $IMPORTGDC_HOME ]; then
    IMPORTGDC_HOME="/usr/local/importGDC"
fi

function test_exit_status {
    # Evaluate return value for chain of pipes; see https://stackoverflow.com/questions/90418/exit-shell-script-based-on-process-exit-code
    rcs=${PIPESTATUS[*]};
    for rc in ${rcs}; do
        if [[ $rc != 0 ]]; then
            >&2 echo Fatal ERROR.  Exiting.
            exit $rc;
        fi;
    done
}

function launch_import {
    UUID=$1

    NMATCH=$(grep $UUID $SR_H | wc -l)
    if [ $NMATCH -ne "1" ]; then
        >&2 echo ERROR: UUID $UUID  matches $NMATCH lines in $SR_H \(expecting unique match\)
        exit 1;
    fi

    # Columns of SR.dat - Jan2018 update with sample_name
    #     1 sample_name
    #     2 case
    #     3 disease
    #     4 experimental_strategy
    #     5 sample_type
    #     6 samples
    #     7 filename
    #     8 filesize
    #     9 data_format
    #    10 UUID
    #    11 MD5
    FN=$(grep $UUID $SR_H | cut -f 7)
    DF=$(grep $UUID $SR_H | cut -f 9)


    if [ -z "$FN" ]; then
        >&2 echo Error: UUID $UUID not found in $SR_H
        exit 1
    fi

    # If DRYRUN is 'd' then we're in dry run mode (only print the called function),
    # otherwise call the function as normal with one less -d argument than we got
    if [ -z $DRYRUN ]; then   # DRYRUN not set
        :   # no-op
    elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
        >&2 echo "Dry run in $0" 
    else    # DRYRUN has multiple d's: strip one d off the argument and pass it to function
        DRYARG=${DRYRUN%?}
        XARGS="$XARGS -$DRYARG"
    fi

    CMD="$BASH $IMPORTGDC_HOME/GDC_import.sh $XARGS -t $TOKEN_C -O $IMPORT_DATAD_H -p $DF -n $FN  $UUID"

    if [ $PARALLEL_CASES ]; then
        JOBLOG="$LOGD_H/StartStep.${UUID}.log"
        RESD="$LOGD_H/$UUID"
        mkdir -p $RESD
        test_exit_status
        
        CMD=$(echo "$CMD" | sed 's/"/\\"/g' )   # This will escape the quotes in $CMD 
        CMD="parallel --semaphore -j$PARALLEL_CASES --id $MYID --joblog $JOBLOG --tmpdir $LOGD_H --results $RESD \"$CMD\" "
    fi

    if [ "$DRYRUN" == "d" ]; then
        >&2 echo Dryrun: $CMD
    else
        >&2 echo Running: $CMD
        eval $CMD
        test_exit_status
    fi
}

# Default values
SR_H="config/SR.dat"
IMPORT_DATAD_H="./data"

while getopts ":hdg:S:O:t:IDMBfl:J:1" opt; do
  case $opt in
    h) 
      echo "$USAGE"
      exit 0
      ;;
    d)  # -d is a stack of parameters, each script popping one off until get to -d
      DRYRUN="d$DRYRUN"
      ;;
   1)
      >&2 echo "Will stop after one case"
      JUSTONE=1
      ;;
    B) # define LSF_GROUP
      XARGS="$XARGS -B"
      ;;
    g) # define LSF_GROUP
      XARGS="$XARGS -g $OPTARG"
      ;;
    S) 
      SR_H=$OPTARG
      >&2 echo "SR File: $SR_H" 
      ;;
    t) 
      TOKEN_C=$OPTARG
      >&2 echo "Token File: $TOKEN_C" 
      ;;
    O) # set IMPORT_DATAD_H
      IMPORT_DATAD_H="$OPTARG"
      >&2 echo "Data Dir: $IMPORT_DATAD_H" 
      ;;
    I)  
      XARGS="$XARGS -I"
      ;;
    D)  
      XARGS="$XARGS -D"
      ;;
    M)  
      MGI=1
      XARGS="$XARGS -M"
      ;;
    f)  
      XARGS="$XARGS -f"
      ;;
    l)  
      LOGD_H="$OPTARG"
      XARGS="$XARGS -l $OPTARG"
      ;;
    J)
      PARALLEL_CASES=$OPTARG
      NOW=$(date)
      MYID=$(date +%Y%m%d%H%M%S)
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z $SR_H ]; then
    >&2 echo Error: SR file not defined \(-S\)
    exit 1
fi
if [ ! -e $SR_H ]; then
    >&2 echo "Error: $SR_H does not exist"
    exit 1
fi
if [ -z $TOKEN_C ]; then
    >&2 echo Error: Token file not defined \(-t\)
    exit 1
fi

if [ "$#" -lt 1 ]; then
    >&2 echo Error: Wrong number of arguments
    >&2 echo Usage: start_step.sh [options] UUID [UUID2 ...]
    >&2 echo "$USAGE"
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

VAR=( $UUIDS )
N_UUIDS=${#VAR[@]}
UUIDS_SEEN=0

# Loop over all remaining arguments
for UUID in $UUIDS
do
    UUIDS_SEEN=$(($UUIDS_SEEN + 1))
    >&2 echo Processing $UUIDS_SEEN / $N_UUIDS [ $(date) ]: $UUID
    launch_import $UUID
    if [ $JUSTONE ]; then
        break
    fi
done

# this will wait until all jobs completed
if [ $PARALLEL_CASES ] ; then
    CMD="parallel --semaphore --wait --id $MYID"
    eval "$CMD"
    test_exit_status
fi

