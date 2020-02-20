# Convenience function to run bash in mwyczalkowski/importgdc docker container
# with data directory mounted to /data
# essentially equivalent to GDC_import.sh -B


#DATA_DIR="/diskmnt/Projects/cptac"  # DC2 
DATA_DIR="$HOME/src/SomaticWrapper/data" # epazote
DOCKER_IMAGE="mwyczalkowski/importgdc"
CMD="/bin/bash"

docker run -v $DATA_DIR:/data -it $DOCKER_IMAGE $CMD
