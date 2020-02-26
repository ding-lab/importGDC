# Will make BamMap summaries for MGI, katmai, denali
source gdc-import.config.sh

#CASES="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat"
#CATALOG="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"

>&2 echo NOTE: this is not really being used anymore.  Deprecate?

function make_summary {
    BAMMAP=$1
    OUT=$2
    ARGS=$3
    CMD="bash importGDC/summarize_cases_available.sh $ARGS $CASES_MASTER $CATALOG_MASTER $BAMMAP > $OUT"
    >&2 echo Running: $CMD
    eval $CMD
    rc=$?
    if [[ $rc != 0 ]]; then
        >&2 echo Fatal error $rc: $!.  Exiting.
        exit $rc;
    fi
    >&2 echo Written to $OUT
}


make_summary $CATALOG/katmai.BamMap.dat dat/katmai.BamMap-summary.txt "$@"
make_summary $CATALOG/MGI.BamMap.dat dat/MGI.BamMap-summary.txt "$@"
#make_summary $CATALOG/denali.BamMap.dat dat/denali.BamMap-summary.txt "$@"

