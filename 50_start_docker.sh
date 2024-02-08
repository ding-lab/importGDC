# Starting docker only needed for making BamMap-wide on compute1

# docker pull amancevice/pandas:latest
BIN="WUDocker/start_docker.sh"

#CATALOGD="/cache1/fs1/home1/Active/home/m.wyczalkowski/Projects/GDAN/GDAN.catalog"
CATALOGD="/storage1/fs1/dinglab/Active/Projects/CPTAC3/Common/CPTAC3.catalog"
DATAD="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"

# based on: https://www.freecodecamp.org/news/building-python-data-science-container-using-docker/
IMAGE="faizanbashir/python-datascience:3.6"
VOLS="$CATALOGD $DATAD"


bash $BIN -r -M compute1 -I $IMAGE $VOLS
