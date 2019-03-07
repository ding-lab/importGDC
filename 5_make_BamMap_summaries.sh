# Will make BamMap summaries for MGI, katmai, denali

CASES="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat"
AR="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.AR.dat"

function make_summary {
    BAMMAP=$1
    OUT=$2
    ARGS=$3
    CMD="bash importGDC/summarize_cases_available.sh $ARGS $CASES $AR $BAMMAP > $OUT"
    >&2 echo Running: $CMD
    eval $CMD
    rc=$?
    if [[ $rc != 0 ]]; then
        >&2 echo Fatal error $rc: $!.  Exiting.
        exit $rc;
    fi
    >&2 echo Written to $OUT
}


make_summary /home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/katmai.BamMap.dat dat/katmai.BamMap-summary.txt "$@"
make_summary /home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/MGI.BamMap.dat dat/MGI.BamMap-summary.txt "$@"
make_summary /home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/denali.BamMap.dat dat/denali.BamMap-summary.txt "$@"

