# Launch docker environment before running import, so that `parallel` is available
# This needs to be done on LSF systems

source gdc-import.config.sh

IMAGE="mwyczalkowski/cromwell-runner"

>&2 echo Launching $IMAGE on $SYSTEM
CMD="bash $DOCKER_BIN/start_docker.sh -I $IMAGE -M $DOCKER_SYSTEM $@ $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD

