# Launch docker instance to import and index GDC data
# Usage: GDC_import.sh [options] UUID [UUID2 ...]
#
# -M: run in MGI environment
# -O IMPORT_DATAD_H: output directory on host.  Mandatory
# -t TOKEN_C: token file path in container.  Mandatory
# -l LOGD_H: log directory path in host.  Mandatory for MGI mode
# -n FN: filename associated with UUID (filename only, no path).  Mandatory
# -p: dataformat (BAM or FASTQ).  Mandatory
# -d: dry run - print out docker statement but do not execute (for debugging)
#     This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead, 
#     with each called function called in dry run mode if it gets one -d, and popping off one and passing rest otherwise
# -B: run bash instead of process_GDC_uuid.sh
# -D: Download only, do not index
# -I: Index only, do not Download.  DT must be "BAM"
# -g LSF_GROUP: LSF group to start in.  MGI mode only
# -f: force overwrite of existing data files
# -T TRICKLE_RATE: Run using trickle to shape data usage; rate is maximum cumulative download rate
# -E RATE: throttle download rate using MGI using LSF queue (Matt Callaway test).  Rate in mbps, try 600

# TODO: Add argument "process_GDC_uuid.sh -O IMPORTD_C". Currently default is /data/GDC_import/data
# Note that this is different from the -O passed go this script

# Also, passing TOKEN_C here is confusing - should not be seeing _C paths here.

# This is run from the host computer.  Essentially runs,
#    `docker process_GDC_uuid.sh`
# so that process_GDC_UUID.sh runs within docker container

DOCKER_IMAGE="mwyczalkowski/importgdc"
PROCESS="/usr/local/importGDC/process_GDC_uuid.sh"

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


# start process_GDC_uuid.sh in vanilla docker environment
function processUUID {
UUID=$1
IMPORT_DATAD_H=$2
TOKEN_C=$3
FN=$4
DF=$5

# This starts mwyczalkowski/importgdc and maps directories:
# Container: /data
# Host: $IMPORT_DATAD_H



# If DRYRUN is 'd' then we're in dry run mode (only print the called function),
# otherwise call the function as normal with one less -d argument than we got
if [ -z $DRYRUN ]; then   # DRYRUN not set
    DOCKER="docker"
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    DOCKER="echo docker"
    >&2 echo Dry run in $0
else    # DRYRUN has multiple d's: pop one d off the argument and pass it to function
    DOCKER="docker"
    DRYRUN=${DRYRUN%?}
    XARGS="$XARGS -$DRYRUN"
fi

# This is the command that will execute on docker
CMD="/bin/bash $PROCESS $XARGS $UUID $TOKEN_C $FN $DF"

if [ ! $RUNBASH ]; then
$DOCKER run -v $IMPORT_DATAD_H:/data $DOCKER_IMAGE $CMD >&2

else

$DOCKER run -it -v $IMPORT_DATAD_H:/data $DOCKER_IMAGE /bin/bash >&2

fi
test_exit_status

}

# start docker in MGI environment
function processUUID_MGI {
UUID=$1
IMPORT_DATAD_H=$2
TOKEN_C=$3
FN=$4
DF=$5
LOGD_H=$6

# logs will be written to $LOGD_H/bsub_run-step_$STEP.err, .out
mkdir -p $LOGD_H
ERRLOG="$LOGD_H/$UUID.err"
OUTLOG="$LOGD_H/$UUID.out"
LOGS="-e $ERRLOG -o $OUTLOG"
rm -f $ERRLOG $OUTLOG
echo Writing bsub logs to $OUTLOG and $ERRLOG

BSUB="$BSUB_PREFIX bsub"

if [ -z $DRYRUN ]; then   # DRYRUN not set
    : # do nothing
elif [ $DRYRUN == "d" ]; then  # DRYRUN is -d: echo the command rather than executing it
    BSUB="echo $BSUB"
    >&2 echo Dry run $0
else    # DRYRUN has multiple d's: pop one d off the argument and pass it to function
    DRYRUN=${DRYRUN%?}
    XARGS="$XARGS -$DRYRUN"
fi

# Where container's /data is mounted on host
echo Mapping /data to $IMPORT_DATAD_H
export LSF_DOCKER_VOLUMES="$IMPORT_DATAD_H:/data"

# for testing, so that it goes faster, do this on blade18-2-11.gsc.wustl.edu
#DOCKERHOST="-m blade18-2-11.gsc.wustl.edu"
# TODO: add the flag below, as in SomaticWrapper.CPTAC3.b1/SomaticWrapper.workflow/src/submit-MGI.sh
# -h DOCKERHOST - define a host to execute the image

if [ -z $RUNBASH ]; then

    PROCESS="$IMPORTGDC_HOME/process_GDC_uuid.sh"

    CMD="/bin/bash $PROCESS $XARGS $UUID $TOKEN_C $FN $DF"
    $BSUB $LSFQ $DOCKERHOST $LSF_ARGS $LOGS -a "docker($DOCKER_IMAGE)" "$CMD"
else
    $BSUB $LSFQ $DOCKERHOST $LSF_ARGS -Is -a "docker($DOCKER_IMAGE)" "/bin/bash"
fi
test_exit_status
}

XARGS=""
LSF_ARGS=""
LSFQ="-q research-hpc"  # MGI LSF queue.  Modfied if using data transfer queue for data throttling
BSUB_PREFIX=""
while getopts ":Mt:O:p:n:dBIDg:fl:T:E:" opt; do
  case $opt in
    M)  # example of binary argument
      MGI=1
      >&2 echo MGI Mode
      ;;
    t)
      TOKEN_C=$OPTARG
      >&2 echo Token file: $TOKEN_C
      ;;
    O)  
      IMPORT_DATAD_H=$OPTARG
      >&2 echo Host data dir: $IMPORT_DATAD_H
      ;;
    p)
      DF=$OPTARG
      >&2 echo Data Format: $DF
      ;;
    n)
      FN=$OPTARG
      >&2 echo Filename: $FN
      ;;
    l)
      LOGD_H=$OPTARG
      >&2 echo Log Directory: $LOGD_H
      ;;
    d) 
      DRYRUN="d$DRYRUN" # -d is a stack of parameters, each script popping one off until get to -d
      ;;
    B)  
      RUNBASH=1
      >&2 echo Run bash
      ;;
    I)  
      XARGS="$XARGS -I"
      ;;
    D)  
      XARGS="$XARGS -D"
      ;;
    f)  
      XARGS="$XARGS -f"
      ;;
    g)  
      LSF_ARGS="$LSF_ARGS -g $OPTARG"
      >&2 echo LSF Group: $OPTARG
      ;;
    T)  
      XARGS="$XARGS -T $OPTARG"
      ;;
    E)  # Perform MGI-specific throttling 
      BSUB_PREFIX="LSF_DOCKER_NETWORK=host LSF_DOCKER_CGROUP=netcap"  
      LSF_ARGS="$LSF_ARGS -R \"rusage[internet_download_mbps=$OPTARG]\""
      LSFQ="-q lims-i1-datatransfer"
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

if [ -z $TOKEN_C ]; then
    >&2 echo Error: token not defined \[-t\]
    exit 1
fi
if [ -z $IMPORT_DATAD_H ]; then
    >&2 echo Error: output directory not defined \[-o\]
    exit 1
fi

for UUID in "$@"
do

if [ $MGI ]; then
    if [ -z $LOGD_H ]; then
        >&2 echo Error: Log directory not defined \[-l\]
        exit 1
    fi
    processUUID_MGI $UUID $IMPORT_DATAD_H $TOKEN_C $FN $DF $LOGD_H
else
    processUUID $UUID $IMPORT_DATAD_H $TOKEN_C $FN $DF
fi

done
