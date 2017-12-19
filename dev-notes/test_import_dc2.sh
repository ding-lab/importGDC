# Test download from DC2 directly

PROCESS="/home/mwyczalk_test/src/importGDC/image.init/process_GDC_uuid.sh"
OUTFN="/diskmnt/Projects/cptac/GDC_import"
UUID="15ae9b4c-fdc6-4698-b6cc-36a13a5b418f"
TOKEN="/diskmnt/Projects/Users/mwyczalk/data/import.CPTAC3b1/token/gdc-user-token.2017-11-13T19-13-55.857Z.txt"
FN="170802_UNC31-K00269_0072_AHK3GVBBXX_AGTCAA_S20_L006_R1_001.fastq.gz"
DT="FASTQ"

# Path of gdc-client
GDCBIN=""

bash $PROCESS -O $OUTFN $UUID $TOKEN $FN $DT
