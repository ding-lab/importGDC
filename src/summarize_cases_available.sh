#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Evaluate presence of data on system and on GDC

Usage:
  summarize_cases_available.sh [options] CASES.dat AR.dat BAMMAP.dat

Options:
    -h: Print this help message
    -1: Stop after one case

EOF

# This script is based on https://github.com/ding-lab/CPTAC3.case.discover/blob/master/summarize_cases.sh
# Writes to STDOUT simple ASCII summary of data present at GDC and on this system
#
# We are interested in obtaining counts of various "data species".  These consist of the following:
# * WGS.hg19 
# * WXS.hg19 
# * RNA.fq 
# * miRNA.fq 
# * WGS.hg38 
# * WXS.hg38 
# * RNA.hg38 
# For each, consider tumor (T), blood normal (N), and tissue adjacant normal (A)
# Data available on system (in BamMap) indicated with upper case, those on GDC but not here are in lower case

# 
# Algorithm:
#   Loop over all cases
#       Consier each "data species": 
#           Obtain UUIDs for each species
#           loop over each UUID
#               Count how many entries associated with UUID.
#                   0: GDC-count++
#                   1: local-count++
#                   >1: Warning, duplicate data, local-count++
#           Print local, GDC count of available UUIDs with uppercase, lowercase symbols (TTt indicates two locally available tumor datasets of a given species, one not downloaded from GDC)

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":h1" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    1)  # example of binary argument
      STOP_AFTER_ONE=1
      ;;
#    f) # example of value argument
#      FILTER=$OPTARG
#      >&2 echo "Setting memory $MEMGB Gb" 
#      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" 
      echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." 
      echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 3 ]; then
    >&2 echo Error: Wrong number of arguments
    >&2 echo "$USAGE"
    exit 1
fi

CASES=$1
AR=$2
BAMMAP=$3

# Usage: repN X N
# will return a string consisting of character X repeated N times
# if N is 0 empty string is returned
# https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
function repN {
    X=$1
    N=$2

    if [ $N == 0 ]; then
        return
    fi

    printf "$1"'%.s' $(eval "echo {1.."$(($2))"}");
}

function get_GDC_UUID {
    CASE=$1
    ES=$2
    ST=$3
    REF=$4
    # Columns of AR.dat
    #     1  sample_name
    #     2  case
    #     3  disease
    #     4  experimental_strategy
    #     5  sample_type
    #     6  samples
    #     7  filename
    #     8  filesize
    #     9  data_format
    #    10  UUID
    #    11  MD5
    #    12  reference

    awk -v c=$CASE -v es=$ES -v st=$ST -v ref=$REF 'BEGIN{FS="\t";OFS="\t"}{if ( ($2 == c) && ($4 == es) && ($5 == st) && ($12 == ref)) print $10}' $AR 
}

#function count_entries_BAM {
#    CASE=$1
#    ES=$2
#    ST=$3
#    REF=$4
#    # Columns of BamMap
#    #     1  sample_name
#    #     2  case
#    #     3  disease
#    #     4  experimental_strategy
#    #     5  sample_type
#    #     6  data_path
#    #     7  filesize
#    #     8  data_format
#    #     9  reference
#    #    10  UUID
#    #    11  system
#
#    awk -v c=$CASE -v es=$ES -v st=$ST -v ref=$REF 'BEGIN{FS="\t";OFS="\t"}{if ( ($2 == c) && ($4 == es) && ($5 == st) && ($9 == ref)) print}' $BAMMAP | wc -l
#}

# Return for a given case a species availability string (e.g., 'TTt') which indicates availability of given data species locally and on GDC
# Species is defined by (experimental strategy, sample type, reference)
# Availability string like 'TTt' indicates that two Tumor samples are present locally (in BamMap), and an additional one is available on GDC 
function get_species_availability {
    CASE=$1
    ES=$2
    ST=$3
    REF=$4
    LOC=$5    # letter indicating available locally, e.g., "T"
    GDC=$6    # letter indicating available GDC (not locally), e.g., "t"

    UUIDS=$(get_GDC_UUID $CASE $ES $ST $REF)
    GDC_COUNT=0
    LOCAL_COUNT=0

    # Evaluate existence of each UUID in BamMap.  Multiple UUIDs imply duplicate data and are reported
    for UUID in $UUIDS; do
        L=$(fgrep $UUID $BAMMAP | wc -l)
        if [ "$L" == 0 ]; then
            GDC_COUNT=$GDC_COUNT+1
        elif [ "$L" == 1 ]; then
            LOCAL_COUNT=$(($LOCAL_COUNT + 1))
        else
            LOCAL_COUNT=$(($LOCAL_COUNT + 1))
            >&2 echo NOTE: multiple copies \( $L \) of UUID $UUID in $BAMMAP   Continuing
        fi
    done

    # Get string representations, given character repeated as many times as datasets 
    LOCAL_STR=$(repN $LOC $LOCAL_COUNT)
    GDC_STR=$(repN $GDC $GDC_COUNT)
    echo ${LOCAL_STR}${GDC_STR}
}

function summarize_case {
    CASE=$1
    DIS=$2

    # Get counts for (tumor, normal, tissue) x (WGS.hg19, WXS.hg19, WGS.hg38, WXS.hg38, RNA-Seq, miRNA-Seq)
    #
    # values of sample_type we are evaluating:
    # blood_normal = N
    # tissue_normal = A
    # tumor = T

    # Note that Submitted Aligned Reads were previously (y1) all hg19.  That will not necessarily always
    # be the case, but we don't know what they are. For now, for simplicity, we will list the reference of all submitted
    # aligned reads as "hg19"

    # Get number of matches for each data category
    WGS19_TS=$(get_species_availability $CASE WGS tumor hg19 T t)
    WGS19_NS=$(get_species_availability $CASE WGS blood_normal hg19 N n)
    WGS19_AS=$(get_species_availability $CASE WGS tissue_normal hg19 A a)

    WXS19_TS=$(get_species_availability $CASE WXS tumor hg19 T t)
    WXS19_NS=$(get_species_availability $CASE WXS blood_normal hg19 N n)
    WXS19_AS=$(get_species_availability $CASE WXS tissue_normal hg19 A a)

    WGS38_TS=$(get_species_availability $CASE WGS tumor hg38 T t)
    WGS38_NS=$(get_species_availability $CASE WGS blood_normal hg38 N n)
    WGS38_AS=$(get_species_availability $CASE WGS tissue_normal hg38 A a)

    WXS38_TS=$(get_species_availability $CASE WXS tumor hg38 T t)
    WXS38_NS=$(get_species_availability $CASE WXS blood_normal hg38 N n)
    WXS38_AS=$(get_species_availability $CASE WXS tissue_normal hg38 A a)

    RNA_TS=$(get_species_availability $CASE RNA-Seq tumor NA T t)
    RNA_NS=$(get_species_availability $CASE RNA-Seq blood_normal NA N n)
    RNA_AS=$(get_species_availability $CASE RNA-Seq tissue_normal NA A a)

    RNA38_TS=$(get_species_availability $CASE RNA-Seq tumor hg38 T t)
    RNA38_NS=$(get_species_availability $CASE RNA-Seq blood_normal hg38 N n)
    RNA38_AS=$(get_species_availability $CASE RNA-Seq tissue_normal hg38 A a)

    MIRNA_TS=$(get_species_availability $CASE miRNA-Seq tumor NA T t)
    MIRNA_NS=$(get_species_availability $CASE miRNA-Seq blood_normal NA N n)
    MIRNA_AS=$(get_species_availability $CASE miRNA-Seq tissue_normal NA A a)

    MIRNA38_TS=$(get_species_availability $CASE miRNA-Seq tumor hg38 T t)
    MIRNA38_NS=$(get_species_availability $CASE miRNA-Seq blood_normal hg38 N n)
    MIRNA38_AS=$(get_species_availability $CASE miRNA-Seq tissue_normal hg38 A a)

    printf "$CASE\t$DIS\t\
    WGS.hg19 $WGS19_TS $WGS19_NS $WGS19_AS\t\
    WXS.hg19 $WXS19_TS $WXS19_NS $WXS19_AS\t\
    RNA.fq $RNA_TS $RNA_NS $RNA_AS\t\
    miRNA.fq $MIRNA_TS $MIRNA_NS $MIRNA_AS\t\
    WGS.hg38 $WGS38_TS $WGS38_NS $WGS38_AS\t\
    WXS.hg38 $WXS38_TS $WXS38_NS $WXS38_AS\t\
    RNA.hg38 $RNA38_TS $RNA38_NS $RNA38_AS\n"
}

while read L; do

    [[ $L = \#* ]] && continue  # Skip commented out entries

    CASE=$(echo "$L" | cut -f 1 )
    DIS=$(echo "$L" | cut -f 2 )

    >&2 echo Processing $CASE

    summarize_case $CASE $DIS 

    if [ "$STOP_AFTER_ONE" ]; then
        >&2 echo Stopping after one
        exit 0
    fi

done < $CASES



