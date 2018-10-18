# the batch of cases under consideration for download, aka the project name
BATCH="LUAD.WGS.hg38"

export IMPORTGDC_HOME="./importGDC"  # importGDC is a submodule

# Data download location
# NOTE: this has to be compatible with SomaticWrapper analysis, and should use IMPORT_DATAD_H from there
# However, might want to change name, since other analysis will use this data too
export IMPORT_DATAD_H="/gscmnt/gc2619/dinglab_cptac3"
#export IMPORT_DATAD_H="/diskmnt/Projects/cptac"
export GDC_TOKEN="../token/gdc-user-token.2018-09-27T19_49_04.999Z.txt"

# This is where download-related metadata lives (config files, logs, etc)
export IMPORT_CONFIGD_H="$IMPORT_DATAD_H/GDC_import/import.config/CPTAC3.$BATCH"
>&2 echo IMPORT_CONFIGD $IMPORT_CONFIGD_H
export IMPORT_CONFIGD_C="/data/GDC_import/import.config/CPTAC3.$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# This is the SR file 
export SR_H="dat/CPTAC3.$BATCH.SR.dat"

# BAMMAP is created as the final step of import process.
# Like SR, it need not be visible from container, so need not be in $IMPORT_CONFIGD_H
export BAMMAP="$IMPORT_CONFIGD_H/CPTAC3.${BATCH}.BamMap.dat"

# Define this =1 if in MGI environment
# Define this =0 otherwise
MGI=1
