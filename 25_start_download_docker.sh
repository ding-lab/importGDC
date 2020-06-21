source gdc-import.config.sh

# Here we start download process in a non-interactive job.  This is to avoid 
# problem of interactive sessions dying after 24 hours 
# Side effect of this is that need to have explicit list of UUIDs to download

# The need for this approach may need to be reconsidered with LSF jobs moving to 
# job control via LSF job groups.
# This is not being run for MGI downloads currently

>&2 echo NOTE: this is not currently supported or suggested

# to run in container, 
UUID="dat/UUID-run3b.dat"

CMD="src/start_downloads.sh -S $CATALOG_MASTER -O $DATA_ROOT -t $GDC_TOKEN $DL_ARGS $@ $UUID"

IMAGE="mwyczalkowski/cromwell-runner"

# Also need: /storage1/fs1/dinglab/Active/CPTAC3/Common/CPTAC3.catalog
>&2 echo Launching $IMAGE on $DOCKER_SYSTEM
DOCKER_CMD="bash $START_DOCKERD/start_docker.sh -I $IMAGE -M $DOCKER_SYSTEM -c \"$CMD\" $VOLUME_MAPPING"
echo Running: $DOCKER_CMD
eval $DOCKER_CMD

