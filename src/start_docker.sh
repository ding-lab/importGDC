#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

# TODO: implement general purpose docker launcher with the following features:
# * Aware of MGI, compute, docker environments
#   - select queue, other defaults accordingly
# * Can map arbitrary paths through command line arguments like, PATH_H:PATH_C
#   - if form is PATH_H, implies PATH_C=PATH_H
##  * Select through command line arguments
#   - memory
#   - image
#   - dryrun
#   - run bash or given command line
#   - arbitrary LSF arguments
# * Idea is to use a common script for launching both cromwell runner and importGDC containers
# 
# Past work: TinDaisy start docker is a good one:
#     /Users/mwyczalk/Projects/TinDaisy/TinDaisy-Core/src/start_docker.sh
#     ./start_docker.LSF.sh
#     ../src/launch_download.sh
#       - does both LSF and docker

read -r -d '' USAGE <<'EOF'
Start docker container in standard docker or LSF environments with optional mounted volumes
Usage: start_docker.sh [options] [ data_path_1 [ data_path_2 ...] ]

Required options:
-I DOCKER_IMAGE: Specify docker image.  Required.

Options:
-h: show help
-d: dry run.  print out docker statement but do not execute
-M SYSTEM: Available systems: MGI, compute1, docker.  Default: docker
-m MEM_GB: request given memory resources on launch
-c DOCKER_CMD: run given command in non-interactive mode.  Default is to run /bin/bash in interactive mode
-L LOGD: Log directory on host.  Logs are written to $LOGD_H/log/*.[err|out] for non-interactive mode only
-g LSF_ARGS: optional arguments to pass verbatim to bsub.  LSF mode only
-q LSFQ: queue to use when launching LSF command.  Defaults are research-hpc for SYSTEM = MGI,
   general-interactive for SYSTEM = compute1

One or more data_path arguments will map volumes on docker start.  If data_path is PATH_H:PATH_C,
then PATH_C will map to PATH_H.  If only a single path is given, it is equivalent to PATH_C=PATH_H
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
LSF_ARGS=""
DOCKER_CMD="/bin/bash"
INTERACTIVE=1
WRITE_LOGS=0
SYSTEM="docker"

BSUB="bsub"
DOCKER="docker"

while getopts ":I:hdM:m:L:c:g:q:" opt; do
  case $opt in
    I)
      DOCKER_IMAGE="$OPTARG"
      ;;    
    h)
      echo "$USAGE"
      exit 0
      ;;
    d) 
      DRYRUN="d"  
      ;;
    M)  
      SYSTEM="$OPTARG"
      ;;
    m)  
      MEM_GB="$OPTARG"
      ;;
    L)  
      LOGD=$OPTARG
      ;;
    c)
      DOCKER_CMD="$OPTARG"
      INTERACTIVE=0
      WRITE_LOGS=1
      ;;    
    g)
      LSF_ARGS="$LSF_ARGS $OPTARG"
      ;;
    q)  
      LSFQ="$OPTARG"
      ;;
    \?)
      >&2 echo "$SCRIPT: ERROR. Invalid option: -$OPTARG" >&2
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "$SCRIPT: ERROR. Option -$OPTARG requires an argument." >&2
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ -z $DOCKER_IMAGE ]; then
    >&2 echo Error: Docker image \(-I\) not specified
    >&2 echo "$USAGE"
    exit 1
fi

if [ $SYSTEM == "docker" ]; then
    LSFQ_DEFAULT=""
    IS_LSF=0
elif [ $SYSTEM == "MGI" ]; then
    LSFQ_DEFAULT="-q research-hpc"  
    IS_LSF=1
elif [ $SYSTEM == "compute1" ]; then
    LSFQ_DEFAULT="-q general-interactive"  
    IS_LSF=1
else
    >&2 echo ERROR: Unknown SYSTEM: $SYSTEM
    >&2 echo "$USAGE"
    exit 1
fi
if [ $IS_LSF == 1 ] && [ -z $LSFQ ]; then
    LSFQ=$LSFQ_DEFAULT
fi

PATH_MAP=""
# Loop over all arguments, host directories which will be mapped to container directories
for DP in "$@"
do
    # Each data path DP consists of one or two paths separated by :
    # If 2 paths, they are PATH_H:PATH_C
    # If 1 path, define PATH_C = PATH_H
    PATH_H=$(echo "$DP" | cut -f 1 -d :)
    PATH_C=$(echo "$DP" | cut -f 2 -d :)

    if [ ! -d $PATH_H ]; then
        >&2 echo ERROR: $PATH_H is not an existing directory
        exit 1
    fi

    # Using python to get absolute path of DATDH.  On Linux `readlink -f` works, but on Mac this is not always available
    # see https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
    ABS_PATH_H=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $PATH_H)

    if [ -z $PATH_C ]; then
        PATH_C=$ABS_PATH_H
    fi

    >&2 echo Mapping $PATH_C to $ABS_PATH_H
    if [ $IS_LSF == 1 ]; then
        PATH_MAP="$PATH_MAP $ABS_PATH_H:$PATH_C"
    else
        PATH_MAP="$PATH_MAP -v $ABS_PATH_H:$PATH_C"
    fi 
done

if [ $WRITE_LOGS == 1 ]; then
    mkdir -p $LOGD
    test_exit_status
    ERRLOG="$LOGD/${UUID}.err"
    OUTLOG="$LOGD/${UUID}.out"
    >&2 echo Output logs written to: $OUTLOG and $ERRLOG
    rm -f $ERRLOG $OUTLOG

    if [ $IS_LSF == 1 ]; then
        LSF_LOGS="-e $ERRLOG -o $OUTLOG"
    else
        LOG_REDIRECT="> $OUTLOG 2> $ERRLOG"
    fi
fi

# This is the command that will execute on docker
if [ $INTERACTIVE == 1 ]; then
    if [ $IS_LSF == 1 ]; then
        LSF_ARGS="$LSF_ARGS -Is"
    else
        DOCKER_ARGS="$DOCKER_ARGS -it"
    fi
fi

if [ $IS_LSF == 1 ]; then
    ECMD="export LSF_DOCKER_NETWORK=host && export LSF_DOCKER_VOLUMES=\"$PATH_MAP\" "
    run_cmd "$ECMD" $DRYRUN
    DCMD="$BSUB $LSFQ $LSF_ARGS $LSF_LOGS -a \"docker($DOCKER_IMAGE)\" $DOCKER_CMD "
else
    DCMD="$DOCKER run $DOCKER_ARGS $PATH_MAP $DOCKER_IMAGE $DOCKER_CMD $LOG_REDIRECT"
fi

run_cmd "$DCMD" $DRYRUN
