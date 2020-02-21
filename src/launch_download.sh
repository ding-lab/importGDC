#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Launch docker instance to import and index GDC data
Usage: launch_download.sh [options] UUID TOKEN FN DT

Mandatory arguments:
  UUID - UUID of object to download
  TOKEN - token filename.  Host path, must exist
  FN - filename of object.  Used only for indexing
  DF - data format of object (BAM, FASTQ, IDAT, VCF)

Required options:
-o IMPORT_DATAD: output directory on host

Options:
-h: print help message
-d: dry run.  This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead, 
    with each called function called in dry run mode if it gets one -d, and popping off one and passing rest otherwise
-l LOGD: log directory path in host.  Default: ./logs
-M: run in LSF environment
-g LSF_ARGS: Additional args to pass to LSF.  LSF mode only
-q LSFQ: LSF queue name.  Default: research-hpc
-i DOCKER_IMAGE: docker image to use.  Default: mwyczalkowski/importgdc
-B: Start docker container, map paths, but run bash instead of starting download

Arguments passed to download_GDC.sh
-D: Download only, do not index
-I: Index and create filestat only, do not Download.  Relevant only for DT="BAM"
-f: force overwrite of existing data files

All paths are relative to host.  Essentially, this script starts docker, maps
data and token directories, and runs download_GDC.sh within docker container
EOF

# utils.sh might live in . or ./src, depending on where this script runs 
if [ -e utils.sh ]; then
    source utils.sh
elif [ -e src/utils.sh ]; then 
    source src/utils.sh
else
    >&2 ERROR: cannot locate utils.sh
    exit 1
fi

SCRIPT=$(basename $0)
DOCKER="docker"
BSUB="bsub"


DOCKER_IMAGE="mwyczalkowski/importgdc"
XARGS=""
LSF_ARGS=""
LSFQ="-q research-hpc"  # LSF queue
LOGD="./logs"

while getopts ":o:hdl:M:g:q:i:BDIF" opt; do
  case $opt in
    o)
      IMPORT_DATAD=$OPTARG
      ;;
    h) 
      echo "$USAGE"
      exit 0
      ;;
    d) 
      DRYRUN="d$DRYRUN" # -d is a stack of parameters, each script popping one off until get to -d
      ;;
    l)
      LOGD=$OPTARG
      ;;
    M)  # example of binary argument
      LSF=1
      ;;
    g)  
      LSF_ARGS="$LSF_ARGS $OPTARG"
      ;;
    q)
      LSFQ="-q $OPTARG"
      ;;
    i)
      DOCKER_IMAGE="$OPTARG"
      ;;
    B)  
      RUNBASH=1
      ;;
    D)  
      XARGS="$XARGS -D"
      ;;
    I)  
      XARGS="$XARGS -I"
      ;;
    f)  
      XARGS="$XARGS -f"
      ;;
    \?)
      echo "ERROR: Invalid option: -$OPTARG" >&2
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      echo "ERROR: Option -$OPTARG requires an argument." >&2
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 4 ]
then
    >&2 echo "ERROR: invalid number of arguments"
    >&2 echo "$USAGE"
    exit 1
fi

UUID=$1
TOKEN=$2; confirm $TOKEN
FN=$3
DT=$4

if [ -z $IMPORT_DATAD ]; then
    >&2 echo ERROR: output directory not defined \[-o\]
    >&2 echo "$USAGE"
    exit 1
fi
mkdir -p $IMPORT_DATAD
test_exit_status

mkdir -p $LOGD
test_exit_status
ERRLOG="$LOGD/${UUID}.err"
OUTLOG="$LOGD/${UUID}.out"
>&2 echo Logs: $OUTLOG and $ERRLOG
rm -f $ERRLOG $OUTLOG

# If DRYRUN is 'd' then we're in dry run mode (only print the called function),
# otherwise call the function as normal with one less -d argument than we got (passing DRYARG)
if [ -z $DRYRUN ]; then   # DRYRUN not set
    DRYARG=""
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    DRYARG=""
else    # DRYRUN has multiple d's: pop one d off the argument and pass it to function
    DRYARG="-${DRYRUN%?}"
fi
XARGS="$XARGS $DRYARG"

# Map the following volumes:
# IMPORT_DATAD mapped to /data
# Directory of TOKEN mapped to /token
TOKEND=$( dirname $TOKEN )
TOKENFN=$( basename $TOKEN )
TOKEN_C="/token/$TOKENFN"

>&2 echo Mapping /data to $IMPORT_DATAD
>&2 echo Mapping /token to $TOKEND

# This is the command that will execute on docker
if [ ! $RUNBASH ]; then
    CMD="/bin/bash src/download_GDC.sh $XARGS $UUID $TOKEN_C $FN $DF"
else
    # Not clear how logs interact with bash.  May need to get rid of STDERR and STDOUT?
    CMD="/bin/bash"
    if [ $LSF ]; then
        LSF_ARGS="$LSF_ARGS -Is"
    else
        DOCKER_ARGS="$DOCKER_ARGS -it"
    fi
fi

if [ $LSF ]; then
    LOGS="-e $ERRLOG -o $OUTLOG"
    export LSF_DOCKER_VOLUMES="$IMPORT_DATAD:/data $TOKEND:/token"
    DCMD="$BSUB $LSFQ $DOCKERHOST $LSF_ARGS $LOGS -a \"docker($DOCKER_IMAGE)\" $CMD "
else
    VOL_ARGS="-v $IMPORT_DATAD:/data -v $TOKEND:/token"
    DCMD="$DOCKER run $DOCKER_ARGS $VOL_ARGS $DOCKER_IMAGE $CMD > $OUTLOG 2> $ERRLOG "
fi

run_cmd "$DCMD" $DRYRUN

