#!/bin/bash

# Matthew Wyczalkowski <m.wyczalkowski@wustl.edu>
# https://dinglab.wustl.edu/

read -r -d '' USAGE <<'EOF'
Usage: download_GDC.sh [options] UUID TOKEN FN DF

Download data from GDC using gdc-client
If data type is BAM, also index and create a flagstat summary file

Mandatory arguments:
  UUID - UUID of object to download
  TOKEN - token filename visible from container
  FN - filename of object.  Used only for indexing
  DF - data format of object (BAM, FASTQ, IDAT, VCF)

Options:
  -h: print usage information
  -d: dry run, simply print commands which would be executed for principal steps
  -O IMPORTD_C: base of imported data dir, visible from container.  Default is /data/GDC_import/data.  Optional
  -D: Download only, do not index
  -I: Index only, do not Download.  DF must be "BAM"
  -f: force overwrite of existing data files
  -s server: The TCP server address server[:port].  Passed directly to gdc_client

for a BAM file FN.bam, creates FN.bam.bai and FN.bam.flagstat.
Note that for some BAM data, GDC provides FN.bai; in these cases, two .bai files will exist
EOF

# We can launch in importGDC root dir or ./src.  Test based on existence of utils.sh, and cd to root dir if necessary
# utils.sh might live in . or ./src, depending on where this script runs 
if [ -e utils.sh ]; then
    cd ..
elif [ ! -e src/utils.sh ]; then 
    >&2 echo ERROR: cannot locate src/utils.sh
    exit 1
fi
source src/utils.sh

SCRIPT=$(basename $0)

IMPORTD_C="/data/GDC_import/data"
GDC_CLIENT="/usr/local/bin/gdc-client" 
SAMTOOLS="/usr/bin/samtools"

# http://wiki.bash-hackers.org/howto/getopts_tutorial
while getopts ":hO:DIdfs:" opt; do
  case $opt in
    h)
      echo "$USAGE"
      exit 0
      ;;
    O)
      IMPORTD_C="$OPTARG"
      >&2 echo Output directory: $IMPORTD_C
      ;;
    D)  # Download only
      DLO=1
      ;;
    I)  # Index only
      IXO=1
      >&2 echo Output dir: $IMPORTD_C
      ;;
    f)  
      FORCE_OVERWRITE=1
      >&2 echo Force overwrite of existing files
      ;;
    d)  # dry run
      DRYRUN="d"
      ;;
    s)  
      XARGS="-s $OPTARG"
      ;;
    \?)
      >&2 echo "Invalid option: -$OPTARG" >&2
      >&2 echo "$USAGE"
      exit 1
      ;;
    :)
      >&2 echo "Option -$OPTARG requires an argument." >&2
      >&2 echo "$USAGE"
      exit 1
      ;;
  esac
done
shift $((OPTIND-1))

if [ "$#" -ne 4 ]
then
    >&2 echo "Error - invalid number of arguments"
    >&2 echo "$USAGE"
    exit 1
fi

UUID=$1
TOKEN=$2
FN=$3
DF=$4

mkdir -p $IMPORTD_C

# Where we expect output to go - this is generated by gdc-client
DAT="$IMPORTD_C/$UUID/$FN"
# .partial file is generated during download
DAT_PARTIAL="$IMPORTD_C/$UUID/${FN}.partial"

# If output file exists and FORCE_OVERWRITE not set, and not in Index Only mode, exit
if [ -f $DAT ] && [ -z $FORCE_OVERWRITE ] && [ -z $IXO ]; then
    >&2 echo Output file $DAT exists.  Stopping.  Use -f to force overwrite.
    exit 1
fi
# Treat presence of .partial file same way as if .bam existed.  We don't want to overwrite it by accident
if [ -f $DAT_PARTIAL ] && [ -z $FORCE_OVERWRITE ] && [ -z $IXO ]; then
    >&2 echo Temporary output file $DAT_PARTIAL exists.  Stopping.  Use -f to force overwrite.
    exit 1
fi

# Download if not "index only"
if [ -z $IXO ]; then
    >&2 echo Writing to $DAT

    # Confirm token file exists
    if [ ! -e $TOKEN ]; then
        >&2 echo ERROR: Token file does not exist: $TOKEN
        exit 1
    fi

    # Documentation of gdc-client: https://docs.gdc.cancer.gov/Data_Transfer_Tool/Users_Guide/Accessing_Built-in_Help/
    # GDC Client saves data to file $IMPORTD_C/$UUID/$FN.  We take advantage of this information to index BAM file after download
    CMD="$GDC_CLIENT download $XARGS -t $TOKEN -d $IMPORTD_C $UUID"
    run_cmd "$CMD" $DRYRUN
fi


## Now index if this is a BAM file, and not download-only
if [ $DF == "BAM" ] && [ -z $DLO ] ; then

    # Confirm $DAT exists
    if [ ! -f $DAT ] && [ ! $DRYRUN ]; then
        >&2 echo BAM file $DAT does not exist.  Not indexing.
        exit 1
    fi

    # It does not seem possible to perform indexing in a pipeline, so the index and flagstat operations need to take place in separate steps
    CMD="$SAMTOOLS index $DAT"
    run_cmd "$CMD" $DRYRUN

    CMD="$SAMTOOLS flagstat $DAT > ${DAT}.flagstat"
    run_cmd "$CMD" $DRYRUN
fi

>&2 echo Download succeeded
