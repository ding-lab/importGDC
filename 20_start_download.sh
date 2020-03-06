source gdc-import.config.sh

UUID="dat/UUID-download.dat"

#TESTARGS=-1ddd
TESTARGS=$@

src/start_downloads.sh -S $CATALOG_MASTER -O $DATA_ROOT -t $GDC_TOKEN $DL_ARGS $TESTARGS - < $UUID
