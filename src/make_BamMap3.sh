#!/bin/bash
# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu

read -r -d '' USAGE <<'EOF'
Usage: make_BamMap.sh [options] UUID [UUID2 ...]

Evaluate success of GDC data download and print data in BamMap3 format to STDOUT

Required options:
-S CATALOG: path to Catalog data file. Required 
-O DATA_ROOT: path to base of download directory (will write to $DATA_ROOT/GDC_import/data). Required
-s SYSTEM: Arbitrary string identifying system the data root path refers to, e.g., MGI.  Required

Options:
-h: print help message
-1 : stop after one case processed.
-w: don't print warnings about missing data
-f: If unknown sample type, print warning but proceed
-H: Print header

If UUID is - then read UUID from STDIN

BamMap3 format is TSV with the following columns:
    1  dataset_name
    2  UUID
    3  system
    4  data_path
See https://docs.google.com/document/d/1uSgle8jiIx9EnDFf_XHV3fWYKFElszNLkmGlht_CQGE/edit#

For every UUID, confirm existence of output and (if appropriate) index
files.  All information used to generate BamMap comes from catalog file and
local configuration (paths, etc), We evaluate success of download by checking
whether data file exists in the expected path and whether filesizes match.
Only samples which check out OK are written to BamMap.

Return values:
  0: Success - all data downloaded correctly
  1: Errors encountered - fatal error which prevents processing
  2: Warnings encountered - some data not downloaded 
EOF

SCRIPT=$(basename $0)

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":S:O:s:h1wfH" opt; do
  case $opt in
    S) 
      CATALOG=$OPTARG
      ;;
    O) # set DATA_ROOT
      DATA_ROOT="$OPTARG"
      ;;
    s) 
      SYSTEM=$OPTARG
      ;;
    h)
      echo "$USAGE"
      exit 0
      ;;
    1)
      JUSTONE=1
      ;;
    w) 
      NOWARN=1
      ;;
    f) 
      WEIRD_ST_OK=1
      ;;
    H) 
      HEADER=1
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

# Procedure for each UUID:
# * extract information from CATALOG file 
# * Make sure output file exists
# * Make sure output file has expected path
# * If this is a BAM, make sure .bai and .flagstat file exists.  Print warning if it does not

function summarize_import {
# REST API catalog
#     1  dataset_name
#     2  case
#     3  sample_type
#     4  data_format
#     5  experimental_strategy
#     6  preservation_method
#     7  aliquot
#     8  file_name
#     9  file_size
#    10  id
#    11  md5sum

# For one, back to Catalog3
#     1  dataset_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  sample_type
#     6  specimen_name
#     7  filename
#     8  filesize
#     9  data_format
#    10  data_variety
#    11  alignment
#    12  project
#    13  uuid
#    14  md5
#    15  metadata


    UUID=$1

    SR=$(grep $UUID $CATALOG)
    if [ -z "$SR" ]; then
        >&2 echo ERROR: Unable to find $UUID in $CATALOG
        exit 1
    fi

    ISOK=1

# REST API
    SN=$(echo "$SR" | cut -f 1)
    FN=$(echo "$SR" | cut -f 8)
    DS=$(echo "$SR" | cut -f 9) # file size
    DF=$(echo "$SR" | cut -f 4)  # data format
    UUID=$(echo "$SR" | cut -f 10)

# Catalog3
#    SN=$(echo "$SR" | cut -f 1)
#    FN=$(echo "$SR" | cut -f 7)
#    DS=$(echo "$SR" | cut -f 8) # file size
#    DF=$(echo "$SR" | cut -f 9)  # data format
#    UUID=$(echo "$SR" | cut -f 13)

    # Test existence of output file and index file
    FNF=$(echo "$DATD/$UUID/$FN" | tr -s '/')  # append full path to data file, normalize path separators
    if [ ! -e $FNF ] && [ -z $NOWARN ]; then
        >&2 echo WARNING: Data file does not exist: $FNF
        >&2 echo This file will not be added to BamMap
        ISOK=0
        RETVAL=1
        return
    fi

    # Test actual filesize on disk vs. size expected from SR file
    # stat has different usage on Mac and Linux.  Try both, ignore errors
    # stat -f%z - works on Mac
    # stat -c%s - works on linux
    BMSIZE=$(stat -f%z $FNF 2>/dev/null || stat -c%s $FNF 2>/dev/null)
    if [ "$BMSIZE" != "$DS" ]; then
        >&2 echo WARNING: $FNF size \($BAMSIZE\) differs from expected \($DS\)
        >&2 echo Continuing.
        ISOK=0
        RETVAL=1
    fi

    if [[ $DF == "BAM" ]]; then # this will fail for chimeric and transcriptome RNA-Seq data, which is not indexed.  But we no longer have RT = result type
    #if [[ $DF == "BAM" && $RT != "chimeric" && $RT != "transcriptome" ]]; then
        # If BAM file, test to make sure that .bai file generated
        BAI="$FNF.bai"
        if [ ! -e $BAI ] && [ -z $NOWARN ]; then
            >&2 echo WARNING: Index file does not exist: $BAI
            >&2 echo Continuing.
            ISOK=0
            RETVAL=1
        fi
        if [ ! -s $BAI ] && [ -z $NOWARN ]; then
            >&2 echo WARNING: Index file zero size: $BAI
            >&2 echo Continuing.
            ISOK=0
            RETVAL=1
        fi
        BAI="$FNF.flagstat"
        if [ ! -e $BAI ] && [ -z $NOWARN ]; then
            >&2 echo WARNING: Flagstat file does not exist: $BAI
            >&2 echo Continuing.
            ISOK=0
            RETVAL=1
        fi
    fi

    #printf "$SN\t$CASE\t$DIS\t$ES\t$ST\t$FNF\t$DS\t$DF\t$REF\t$UUID\t$SYSTEM\n"
#$CASE\t$DIS\t$ES\t$ST\t$FNF\t$DS\t$DF\t$REF\t$UUID\t$SYSTEM\n"
    printf "$SN\t$UUID\t$SYSTEM\t$FNF\n"
    
    if [ $ISOK == 1 ]; then
        >&2 echo OK: $FNF \($SN\)
    fi
}


if [ -z $CATALOG ]; then
    >&2 echo ERROR: CATALOG file not defined \(-S\)
    exit 1
fi
if [ ! -e $CATALOG ]; then
    >&2 echo "ERROR: $CATALOG does not exist"
    exit 1
fi

if [ -z $DATA_ROOT ]; then
    >&2 echo ERROR: DATA_ROOT file not defined \(-O\)
    exit 1
fi
if [ ! -d $DATA_ROOT ]; then
    >&2 echo ERROR: $DATA_ROOT does not exist
    exit 1
fi
DATD="$DATA_ROOT/GDC_import/data"
if [ ! -d $DATD ]; then
    >&2 echo "ERROR: Data directory does not exist: $DATD"
    exit 1
fi

if [ -z $SYSTEM ]; then
    >&2 echo ERROR: system not defined \(-s\)
    exit 1
fi

if [ $HEADER ]; then
    #printf "# sample_name\tcase\tdisease\texperimental_strategy\tsample_type\tdata_path\tfilesize\tdata_format\treference\tUUID\tsystem\n" 
    printf "dataset_name\tuuid\tsystem\tdata_path\n"
fi

# this allows us to get UUIDs in one of two ways:
# 1: start_step.sh ... UUID1 UUID2 UUID3
# 2: cat UUIDS.dat | start_step.sh ... -
if [ $1 == "-" ]; then
    UUIDS=$(cat - )
else
    UUIDS="$@"
fi

# Return value, 0 if no errors / warnings, 1 if error, 2 if any warning
RETVAL=0
# Loop over all remaining arguments
for UUID in $UUIDS; do
    summarize_import $UUID
    if [ $JUSTONE ]; then
        break
    fi
done

if [ $RETVAL == 0 ]; then
    >&2 echo "Download successful"
elif [ $RETVAL == 1 ]; then
    >&2 echo "Errors encountered"   # typically not seen since errors exit
else
    >&2 echo "Warnings encountered"
fi

exit $RETVAL
