# the batch of cases under consideration for download, aka the project name
BATCH="CPTAC3.d3"

export IMPORTGDC_HOME="./importGDC"  # importGDC is a submodule

# Data download location
# NOTE: this has to be compatible with SomaticWrapper analysis, and should use IMPORT_DATAD_H from there
# However, might want to change name, since other analysis will use this data too
export IMPORT_DATAD_H="/gscmnt/gc2741/ding/CPTAC3-data"
#export IMPORT_DATAD_H="/diskmnt/Projects/cptac_downloads/data"
export GDC_TOKEN="../token/gdc-user-token.2018-06-30T19_43_41.286Z.txt"

# This is where download-related metadata lives (config files, logs, etc)
export IMPORT_CONFIGD_H="$IMPORT_DATAD_H/GDC_import/import.config/$BATCH"
export IMPORT_CONFIGD_C="/data/GDC_import/import.config/$BATCH"
mkdir -p $IMPORT_CONFIGD_H

# This is the SR file for LUAD.b1
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
MGI=1
