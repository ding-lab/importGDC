# Launch docker environment before running import, so that `parallel` is available

# Map home directory (containing token) and storage directory
#VOLUME_MAPPING="/storage1/fs1/home1/Active/home/m.wyczalkowski /storage1/fs1/m.wyczalkowski"
VOLUME_MAPPING="/home/m.wyczalkowski /storage1/fs1/m.wyczalkowski"

LSF_ARGS="-G compute-lding"
IMAGE="mwyczalkowski/cromwell-runner"

>&2 echo Launching $IMAGE on compute1
CMD="bash src/start_docker.sh -I $IMAGE -M compute1 -g \"$LSF_ARGS\" $@ $VOLUME_MAPPING"
echo Running: $CMD
eval $CMD


