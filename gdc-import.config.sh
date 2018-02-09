# Define locale-specific (MGI vs. DC2) environment variables here

# the batch of cases under consideration for download, aka the project name
BATCH="CPTAC3.b2"

export IMPORTGDC_HOME="./importGDC"  # importGDC is a submodule

# Data download location
# NOTE: this has to be compatible with SomaticWrapper analysis, and should use IMPORT_DATAD_H from there
# However, might want to change name, since other analysis will use this data too
export IMPORT_DATAD_H="/gscmnt/gc2741/ding/CPTAC3-data"
#export DATA_DIR="/diskmnt/Projects/cptac"
export GDC_TOKEN="../token/gdc-user-token.2018-01-29T20_46_47.665Z.txt"

# This is where download-related metadata lives (config files, logs, etc)
export IMPORT_CONFIGD_H="$IMPORT_DATAD_H/GDC_import/import.config/$BATCH"
export IMPORT_CONFIGD_C="/data/GDC_import/import.config/$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# Moving SR file here is part of installation
export SR_H="$IMPORT_CONFIGD_H/${BATCH}.SR.dat"

# BAMMAP is created as the final step of import process.
# Like SR, it need not be visible from container, so need not be in $CONFIG_HOME_H
export BAMMAP="$CONFIG_HOME_H/${BATCH}.BamMap.dat"

if [ ! -e $SR_H ]; then
    >&2 echo Error: SR file $SR_H does not exist
    >&2 echo Please copy it from CPTAC3 discovery directory and try again
    exit 1
fi

# Define this =1 if in MGI environment
# Define this =0 otherwise
MGI=1
