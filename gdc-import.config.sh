

# the batch of cases under consideration for download, aka the project name
BATCH="CPTAC3.b3"

export IMPORTGDC_HOME="./importGDC"  # importGDC is a submodule

# Data download location
#export IMPORT_DATAD_H="/gscmnt/gc2741/ding/CPTAC3-data"
export IMPORT_DATAD_H="/diskmnt/Projects/cptac_downloads/data"
export GDC_TOKEN="../token/gdc-user-token.2018-03-13T15_50_31.158Z.txt"

# This is where download-related metadata lives (config files, logs, etc)
export IMPORT_CONFIGD_H="$IMPORT_DATAD_H/GDC_import/import.config/$BATCH"
export IMPORT_CONFIGD_C="/data/GDC_import/import.config/$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# Moving SR file here is part of installation
export SR_H="$IMPORT_CONFIGD_H/${BATCH}.SR.dat"

# BAMMAP is created as the final step of import process.
# Like SR, it need not be visible from container, so need not be in $IMPORT_CONFIGD_H
export BAMMAP="$IMPORT_CONFIGD_H/${BATCH}.BamMap.dat"

if [ ! -e $SR_H ]; then
    >&2 echo Error: SR file $SR_H does not exist
    >&2 echo Please copy it from CPTAC3 discovery directory and try again
    exit 1
fi

# Define this =1 if in MGI environment
# Define this =0 otherwise
MGI=0
