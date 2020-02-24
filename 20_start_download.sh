DATAD="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
TOKEN="/home/m.wyczalkowski/Projects/CPTAC3/import/token/gdc-user-token.2020-01-31T20_48_13.912Z.txt"
CATALOG="/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"
UUID="dat/UUID-download.dat"

#TESTARGS=-1ddd
TESTARGS=$@

src/start_downloads.sh -S $CATALOG -O $DATAD -t $TOKEN -g "-G compute-lding" -M -q general $TESTARGS - < $UUID
