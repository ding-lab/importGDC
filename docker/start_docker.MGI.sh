# Starts docker image and mounts given directory as /data
# Usage: start_docker.sh [data_path] 
#
# start docker using image in docker_image.sh, and optionally map data_path to /data in container
#
# Note that the queue will need to change for compute1

source docker_image.sh

DATD=$1

if [ -z $DATD ]; then
    # Using python to get absolute path of DATD.  On Linux `readlink -f` works, but on Mac this is not always available
    # see https://stackoverflow.com/questions/1055671/how-can-i-get-the-behavior-of-gnus-readlink-f-on-a-mac
    ADATD=$(python -c 'import os,sys;print(os.path.realpath(sys.argv[1]))' $DATD)
    >&2 echo Mounting $ADATD to /data

    MNT="-v $ADATD:/data"

    #docker run $MNT -it $IMAGE /bin/bash
fi

bsub -Is -q research-hpc -a "docker($IMAGE)" /bin/bash

