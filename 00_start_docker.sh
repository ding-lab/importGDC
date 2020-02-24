#source Project.config.sh
# Launch docker environment before running import, so that `parallel` is available

if [ "$#" -ne 1 ]; then
    >&2 echo ERROR: pass SYSTEM argument
    >&2 echo Usage: 00_start_docker.sh SYSTEM
    exit 1  # exit code 1 indicates error
fi

SYSTEM=$1

if [ "$SYSTEM" == "MGI" ]; then

    >&2 echo Launching docker on MGI

    CMD="bash docker/start_docker.MGI.sh"
#    >&2 echo Running: $CMD
    eval $CMD

elif [ "$SYSTEM" == "compute1" ]; then

    >&2 echo Launching docker on compute1

    CMD="bash docker/start_docker.compute1.sh"
#    >&2 echo Running: $CMD
    eval $CMD

else 

    >&2 echo Unknown SYSTEM $SYSTEM

fi
