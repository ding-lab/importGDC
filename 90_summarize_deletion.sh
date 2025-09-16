source gdc-import.config.sh

# Catalog-REST
#     1  dataset_name    MILD-B588.RNA-Seq.genomic.T
#     2  case    MILD-B588
#     3  sample_type Primary Tumor
#     4  data_format BAM
#     5  experimental_strategy   RNA-Seq
#     6  preservation_method Frozen
#     7  aliquot MILD-B588-TTP1-A-1-1-R-A863-41
#     8  file_name   0d20c5f2-5bda-4c26-9150-0c56ff448530.rna_seq.genomic.gdc_realn.bam
#     9  file_size   18237224238
#    10  uuid    7699428a-b000-4483-b87a-e5539c579aee
#    11  md5sum  075669879ca08a94bd8107b3d6b2e331

# modified to work with current GDC REST API catalog
# Usage: get_size_by_es TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_size_by_es {
   # for Catalog-REST
   grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($5 == t) print}' | cut -f 9 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}'

    # For Catalog3
#   grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($4 == t) print}' | cut -f 8 | awk '{s+=$1} END {print s / 1024 / 1024 / 1024 / 1024}'
}

# Usage: get_count_by_es TYPE
# where TYPE is WGS, WXS, RNA-Seq
function get_count_by_es {
   # for Catalog-MILD
    grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($5 == t) print}' | wc -l 
   # for Catalog3 
#    grep -v "^#" $DAT | awk -v t="$1" 'BEGIN{FS="\t"}{if ($4 == t) print}' | wc -l 
}

function summarize {
DAT=$1

>&2 echo Summarizing $DAT
WGS_SIZE=$(get_size_by_es WGS)
WGS_COUNT=$(get_count_by_es WGS)

WXS_SIZE=$(get_size_by_es WXS)
WXS_COUNT=$(get_count_by_es WXS)

RNA_SIZE=$(get_size_by_es RNA-Seq)
RNA_COUNT=$(get_count_by_es RNA-Seq)

MIRNA_SIZE=$(get_size_by_es miRNA-Seq)
MIRNA_COUNT=$(get_count_by_es miRNA-Seq)

METH_SIZE=$(get_size_by_es "Methylation_Array")
METH_COUNT=$(get_count_by_es "Methylation_Array")

TARG_SIZE=$(get_size_by_es "Targeted_Sequencing")
TARG_COUNT=$(get_count_by_es "Targeted_Sequencing")

SCRNA_SIZE=$(get_size_by_es "scRNA-Seq")
SCRNA_COUNT=$(get_count_by_es "scRNA-Seq")

TOT_SIZE=$(echo "$WGS_SIZE + $WXS_SIZE + $RNA_SIZE + $MIRNA_SIZE + $METH_SIZE + $TARG_SIZE + $SCRNA_SIZE" | bc)
TOT_COUNT=$(echo "$WGS_COUNT + $WXS_COUNT + $RNA_COUNT + $MIRNA_COUNT + $METH_COUNT + $TARG_COUNT + $SCRNA_COUNT" | bc)

echo "   Total freed disk space WGS: $WGS_SIZE Tb in $WGS_COUNT files"
echo "                          WXS: $WXS_SIZE Tb in $WXS_COUNT files"
echo "                      RNA-Seq: $RNA_SIZE Tb in $RNA_COUNT files"
echo "                    miRNA-Seq: $MIRNA_SIZE Tb in $MIRNA_COUNT files"
echo "            Methylation Array: $METH_SIZE Tb in $METH_COUNT files"
echo "          Targeted Sequencing: $TARG_SIZE Tb in $TARG_COUNT files"
echo "                    scRNA-Seq: $SCRNA_SIZE Tb in $SCRNA_COUNT files"
echo "                        TOTAL: $TOT_SIZE Tb in $TOT_COUNT files"
}

source config.sh

>&2 echo BAMMAP_MASTER: $BAMMAP_MASTER

CATALOG_TMP="dat/catalog.tmp"
mkdir -p dat
>&2 echo Catalog: $CATALOG_MASTER
>&2 echo Evaluating UUIDs from $UUID_DELETE, writing to $CATALOG_TMP

fgrep -f $UUID_DELETE $CATALOG_MASTER > $CATALOG_TMP

summarize $CATALOG_TMP
