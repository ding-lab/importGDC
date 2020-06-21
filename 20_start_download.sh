source gdc-import.config.sh

# Model for how to call this:
# cat $UUID | 20_start_download.sh -

CMD="src/start_downloads.sh -S $CATALOG_MASTER -g \"$LSF_ARGS\" -O $DATA_ROOT -t $GDC_TOKEN $DL_ARGS $@ "

echo Running: $CMD
eval $CMD

