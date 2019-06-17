# Create AR file which will have enough information to allow
# downloads from GDC as if were regular RNA-Seq data
#
# Usage:
#   cat methylation.dat | make_AR.sh > AR.dat

# Downloading of methylation data is based on ad-hoc download if miRNA data in
#    denali:/home/mwyczalk_test/Projects/CPTAC3/import.CPTAC3/import.CPTAC3.miRNA/1_make_SR.sh

# Sample row of GDC_methyl_array_batch9added_6_6.tsv
#      1  aliquots.id 4c454769-e24a-4f43-b9a3-61b66a026a24
#      2  aliquots.submitter_id   CPT0163800006
#      3  Type    Normal DNA
#      4  CaseID  C3N-02279
#      5  Tumor Type  HNSCC
#      6  Batch 9 Batch 9
#      7  type    raw_methylation_array
#      8  id  21cbc5f4-44fb-465e-8f2e-5e0e311547f0
#      9  project_id  CPTAC-3
#     10  submitter_id    CPT0163800006.203281980258_R01C01_Red.idat
#     11  channel Red
#     12  data_category   DNA Methylation
#     13  data_format IDAT
#     14  data_type   Raw Intensities
#     15  experimental_strategy   Methylation Array
#     16  file_name   203281980258_R01C01_Red.idat
#     17  file_size   13676206
#     18  md5sum  b72bfb4a63c208a8d9e37aff3c988bd2
#     19  platform    Illumina Methylation Epic
#     20  chip_id 203281980258
#     21  chip_position   R01C01
#     22  plate_name  MultiPDO_0402_EPIC01
#     23  plate_well  A05

# This is used to look up disease based on case name.  This should be read from gdc-import.config.sh
CASES="/home/mwyczalk_test/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.cases.dat"

# Given line from methylation file, print one AR line
# Usage: pass one methylation line 
function print_AR_line {
    LINE=$1

    # Sample name is a convenience string which looks like,
    # C3N-00858.MethArray.Red.N
    # C3N-00858.MethArray.Green.N
    # based on https://github.com/ding-lab/CPTAC3.case.discover/blob/master/merge_submitted_reads.sh
    # where suffix is N for Type (column 3) = "Normal DNA" and "Germline DNA", T for Type = "Tumor DNA"
    # and Red/Grn correspond to Red, Green channels, resp.
    STL=`echo "$LINE" | cut -f 3`
    CASE=`echo "$LINE" | cut -f 4`

    # From Mathangi,  "Tumor DNA” : DNA from tumor;  "Normal DNA” : DNA from Normal Adjacent Tissue (NAT);  "Germline DNA” : DNA from germline blood
    if [ "$STL" == "Normal DNA" ] ; then 
        ST="A"
        SAMP_TYPE="tissue_normal"
    elif [ "$STL" == "Germline DNA" ]; then
        ST="N"
        SAMP_TYPE="blood_normal"
    elif [ "$STL" == "Tumor DNA" ]; then
        ST="T"
        SAMP_TYPE="tumor"  # assumed
    else
        >&2 echo Error: Unknown sample type: $STL
        exit 1
    fi
    CHANNEL=`echo "$LINE" | cut -f 11`
    SN="${CASE}.MethArray.${CHANNEL}.${ST}"

    # Get disease for Cases list
    DISEASE=`grep $CASE $CASES | cut -f 2`
    if [ -z "$DISEASE" ]; then
        >&2 echo ERROR: case $CASE not found in $CASES
        exit 1
    fi

    ES="MethArray"

    # Use the aliquot name for Samples
    SAMPS=`echo "$LINE" | cut -f 2`

    FN=`echo "$LINE" | cut -f 16`   # file name
    FS=`echo "$LINE" | cut -f 17`   # file size
    DF="IDAT"                       # data format
    ID=`echo "$LINE" | cut -f 8`    # Using column 8, since column 1 is repeated (consistent with aliquot id)
    MD=`echo "$LINE" | cut -f 18`   
        
    printf "$SN\t$CASE\t$DISEASE\t$ES\t$SAMP_TYPE\t$SAMPS\t$FN\t$FS\t$DF\t$ID\t$MD\n"
}

printf "# sample_name\tcase\tdisease\texperimental_strategy\tsample_type\tsamples\tfilename\tfilesize\tdata_format\tUUID\tMD5\n"  

#while read L; do
#
#[[ $L = \#* ]] && continue  # Skip commented out entries
#
#    CASE=$(echo "$L" | cut -f 2 )
#
#    >&2 echo Processing $CASE
#
#    print_AR_line "$L" >> $OUT
#
#done < $MTDAT

# https://stackoverflow.com/questions/6980090/how-to-read-from-a-file-or-stdin-in-bash
while IFS= read -r L; do
    #printf '%s\n' "$L"
    [[ $L = \#* ]] && continue
    [[ $L = aliquots* ]] && continue

    print_AR_line "$L" 
done

