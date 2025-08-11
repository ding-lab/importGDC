# making a basic BamMap in a custom format for running pipelines

BM8=dat/batch_8.BamMap.dat
BM12=dat/batch_12/batch.BamMap.dat
#     1	dataset_name
#     2	uuid
#     3	system
#     4	data_path

function nice_rm_dir {
    FN=$1

    if [ ! -d $FN ]; then
        >&2 echo NOTE: $FN does not exist
        return
    fi

    CMD="rm -r $FN"
    >&2 echo Running $CMD
    eval "$CMD"
}

function process_bammap {
    BM_DEL=$1
    while read L; do
        BAM=$(echo "$L" | cut -f 4)
        DATAD=$(dirname $BAM)
        nice_rm_dir $DATAD

    #done <$BM_DEL  # if no header
    done < <(tail -n +2 $BM_DEL) # if BamMap has header
}

process_bammap $BM8
process_bammap $BM12
