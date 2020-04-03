source gdc-import.config.sh

CMD="cat $UUID | src/start_downloads.sh -S $CATALOG_MASTER -O $DATA_ROOT -t $GDC_TOKEN $DL_ARGS $@ -"

echo Running: $CMD
eval $CMD

