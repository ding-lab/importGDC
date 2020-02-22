# Starts docker image and mounts given directory as /data
# Usage: start_docker.LSF.sh SYSTEM [data_path [token_path]] 
#
# start docker on given system using image in docker_image.sh.
# Optionally map data_path to /data in container, and token_path to /token
#
# System must be one of "MGI" or "compute1".  This will determine the queue 
# and other specifics

source docker_image.sh

SYSTEM=$1
DATD=$2
TOKEND=$3

if [ -z $SYSTEM ]; then 
    >&2 echo ERROR: pass SYSTEM argument: MGI or compute1
    exit 1
fi
if [ $SYSTEM == "MGI" ]; then
    QUEUE="research-hpc"
elif [ $SYSTEM == "compute1" ]; then
    QUEUE="general-interactive"
#You are a member of multiple LSF User Groups:
#compute-lding
#compute-dinglab
#You must specify an LSF User Group with -G {GROUPNAME} or by setting the LSB_SUB_USER_GROUP variable
    XARGS="-G compute-lding"
# Also, need to cd .. or else nothing besides docker directory visible
    cd ..
else
    >&2 echo ERROR: Unknown SYSTEM: $SYSTEM
    >&2 echo SYSTEM must be MGI or compute1
fi

if [ ! -z $DATD ]; then
    # Using python to get absolute path of DATD.  On Linux `readlink -f` works, but on Mac this is not always available
    # see https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
    ADATD=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $DATD)
    >&2 echo Mounting $ADATD to /data
    MNT="$ADATD:/data"
fi
if [ "$TOKEND" ]; then
    # Using python to get absolute path of DATD.  On Linux `readlink -f` works, but on Mac this is not always available
    # see https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
    ADATD=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $TOKEND)
    >&2 echo Mounting $ADATD to /token

    MNT="$MNT $ADATD:/token"
fi

export LSF_DOCKER_VOLUMES="$MNT"
CMD="bsub -Is -q $QUEUE $XARGS -a \"docker($IMAGE)\" /bin/bash"
>&2 echo Running $CMD
eval $CMD

