
CASES="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat"
AR="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.AR.dat"
BAMMAP="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/katmai.BamMap.dat"

#OUT_SR="dat/${PROJECT}.katmai-BamMap-summary.txt"

bash importGDC/summarize_cases_available.sh $@ $CASES $AR $BAMMAP
#echo Written to $OUT_SR

