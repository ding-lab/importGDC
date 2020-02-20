#!/bin/bash

# author: Matthew Wyczalkowski m.wyczalkowski@wustl.edu

# Evaluate successful download of BAM/FASTQ files in SR_FILE and output BamMap data
# Usage: make_bam_map.sh [options] -S SR_FILE

# TODO: allow looping over either SR file or list of UUIDs
#
# options
# -S SR_FILE: path to SR data file.  Required
# -O DATA_DIR: path to base of download directory (downloads will be written to to $DATA_DIR/GDC_import/data). Default: ./data
# -w: don't print warnings about missing data
# -H: Print header
# -s: System (e.g., MGI).  Arbitrary string identifying system the path refers to.  Required
# -f: If unknown sample type, print warning but proceed

#
# Output written to STDOUT.  Format is TSV with the following columns:
#     1  sample_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  sample_type
#     6  data_path
#     7  filesize
#     8  data_format
#     9  reference
#    10  UUID
#    11  system

# where SampleName is a generated convenience name for this sample

# For every UUID in SR_FILE, confirm existence of output file and (if appropriate) index file.
# output a "bam map" file which can later be used as input for processing.  Note that
# all information used to generate BamMap comes from SR file and local configuration (paths, etc),
# We evaluate success of download by checking whether data file exists in the expected path and whether filesizes match.
# Only samples which check out OK are written to BamMap.
#
# Procedure:
# * extract information from SR file 
# * Make sure output file exists
# * Make sure output file has expected path
# * If this is a BAM, make sure .bai and .flagstat file exists.  Print warning if it does not
#
# Return values:
#   0: Success - all data downloaded correctly
#   1: Errors encountered - fatal error which prevents processing
#   2: Warnings encountered - some data not downloaded 

function summarize_import {
# SR columns:
#     1  # sample_name
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

# Catalog file format
#     1  # sample_name
#     2  case
#     3  disease
#     4  experimental_strategy
#     5  short_sample_type
#     6  aliquot
#     7  filename
#     8  filesize
#     9  data_format
#    10  result_type  ** new **
#    11  UUID
#    12  MD5
#    13  reference
#    14  sample_type  ** new **
    SR=$1

    ISOK=1

    SN=$(echo "$SR" | cut -f 1)
    CASE=$(echo "$SR" | cut -f 2)
    DIS=$(echo "$SR" | cut -f 3)
    ES=$(echo "$SR" | cut -f 4)
    STL=$(echo "$SR" | cut -f 5)
    FN=$(echo "$SR" | cut -f 7)
    DS=$(echo "$SR" | cut -f 8)
    DF=$(echo "$SR" | cut -f 9)  # data format
    UUID=$(echo "$SR" | cut -f 11)
    REF=$(echo "$SR" | cut -f 13)

# TODO: Confirm that this is valid
# This is being moved to merge_submitted_reads.sh (https://github.com/ding-lab/CPTAC3.case.discover/blob/master/merge_submitted_reads.sh)
    if [ "$STL" == "Blood Derived Normal" ]; then 
        ST="blood_normal"
    elif [ "$STL" == "Solid Tissue Normal" ]; then 
        ST="tissue_normal"
    elif [ "$STL" == "Primary Tumor" ]; then 
        ST="tumor"
    elif [ "$STL" == "Buccal Cell Normal" ]; then 
        ST="buccal_normal"
    elif [ "$STL" == "Primary Blood Derived Cancer - Bone Marrow" ]; then 
        ST="tumor_bone_marrow"
    elif [ "$STL" == "Primary Blood Derived Cancer - Peripheral Blood" ]; then 
        ST="tumor_peripheral_blood"
    elif [ "$STL" == "blood_normal" ] || [ "$STL" == "tissue_normal" ] || [ "$STL" == "tumor" ] || [ "$STL" == "buccal_normal" ] || [ "$STL" == "tumor_bone_marrow" ] || [ "$STL" == "tumor_peripheral_blood" ] ; then 
        ST="$STL"
    else
        if [ "$WEIRD_ST_OK" ]; then
            >&2 echo WARNING: Unknown sample type: $STL.  Continuing
            ST="$STL"
        else
            >&2 echo Error: Unknown sample type: $STL
            exit 1
        fi
    fi

    # Test existence of output file and index file
    FNF=$(echo "$DATD/$UUID/$FN" | tr -s '/')  # append full path to data file, normalize path separators
    if [ ! -e $FNF ] && [ -z $NOWARN ]; then
        >&2 echo WARNING: Data file does not exist: $FNF
        >&2 echo This file will not be added to BamMap
        ISOK=0
        RETVAL=1
        continue
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
        continue
    fi
    if [ $DF == "BAM" ]; then
        # If BAM file, test to make sure that .bai file generated
        BAI="$FNF.bai"
        if [ ! -e $BAI ] && [ -z $NOWARN ]; then
            >&2 echo WARNING: Index file does not exist: $BAI
            >&2 echo Continuing.
            ISOK=0
            RETVAL=1
            continue
        fi
        if [ ! -s $BAI ] && [ -z $NOWARN ]; then
            >&2 echo WARNING: Index file zero size: $BAI
            >&2 echo Continuing.
            ISOK=0
            RETVAL=1
            continue
        fi
        BAI="$FNF.flagstat"
        if [ ! -e $BAI ] && [ -z $NOWARN ]; then
            >&2 echo WARNING: Flagstat file does not exist: $BAI
            >&2 echo Continuing.
            ISOK=0
            RETVAL=1
            continue
        fi
    fi

    printf "$SN\t$CASE\t$DIS\t$ES\t$ST\t$FNF\t$DS\t$DF\t$REF\t$UUID\t$SYSTEM\n"
    
    if [ $ISOK == 1 ]; then
        >&2 echo OK: $FNF \($SN\)
    fi
}

# Default values
DATA_DIR="./data"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":S:O:Hws:f" opt; do
  case $opt in
    S) 
      SR_FILE=$OPTARG
      ;;
    s) 
      SYSTEM=$OPTARG
      ;;
    O) # set DATA_DIR
      DATA_DIR="$OPTARG"
      ;;
    H) 
      HEADER=1
      ;;
    w) 
      NOWARN=1
      ;;
    f) 
      WEIRD_ST_OK=1
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

if [ $HEADER ]; then
    printf "# sample_name\tcase\tdisease\texperimental_strategy\tsample_type\tdata_path\tfilesize\tdata_format\treference\tUUID\tsystem\n" 
    if [ "$#" -eq 0 ]; then
        exit 0
    fi
    >&2 echo printed header, but not exiting
fi

#if [ "$#" -lt 1 ]; then
#    >&2 echo Error: No UUIDs passed
#    exit 1
#fi

if [ -z $SR_FILE ]; then
    >&2 echo Error: SR file not defined \(-S\)
    exit 1
fi
if [ ! -e $SR_FILE ]; then
    >&2 echo "Error: $SR_FILE does not exist"
    exit 1
fi
if [ -z $SYSTEM ]; then
    >&2 echo Error: system not defined \(-s\)
    exit 1
fi

DATD="$DATA_DIR/GDC_import/data"
if [ ! -e $DATD ]; then
    >&2 echo "Error: Data directory does not exist: $DATD"
    exit 1
fi

# Return value, 0 if no errors / warnings, 1 if error, 2 if any warning
RETVAL=0
# Now loop over all lines of SR file and process them
while read L; do
    # Skip comments and header
    [[ $L = \#* ]] && continue

    summarize_import "$L" 
done <$SR_FILE

if [ $RETVAL == 0 ]; then
    >&2 echo "Download successful"
elif [ $RETVAL == 1 ]; then
    >&2 echo "Errors encountered"   # typically not seen since errors exit
else
    >&2 echo "Warnings encountered"
fi

exit $RETVAL
