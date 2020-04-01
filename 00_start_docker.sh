# Launch docker environment before running import, so that `parallel` is available
# This needs to be done on LSF systems

echo "Deprecated"
exit 1

source gdc-import.config.sh

IMAGE="mwyczalkowski/cromwell-runner"


# Also need: /storage1/fs1/dinglab/Active/CPTAC3/Common/CPTAC3.catalog
>&2 echo Launching $IMAGE on $SYSTEM
CMD="bash $START_DOCKERD/start_docker.sh -I $IMAGE -M $DOCKER_SYSTEM $@ $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD

