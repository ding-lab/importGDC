source gdc-import.config.sh

# Model for how to call this:
# cat $UUID | 20_start_download.sh -

export LSF_GROUP="/mwyczalk/gdc-download"

# differs for GDAN / CPTAC3
#ARG="-s https://api.awg.gdc.cancer.gov"
CMD="src/start_downloads.sh -C $CAT_TYPE -S $CATALOG_MASTER -g \"$LSF_ARGS\" -O $DATA_ROOT -t $GDC_TOKEN $ARG $DL_ARGS $@ "

echo Running: $CMD
eval $CMD

