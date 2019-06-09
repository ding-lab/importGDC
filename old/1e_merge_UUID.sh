WGS="dat/UUID-download-WGS.dat"
WXS="dat/UUID-download-WXS.dat"
RNA="dat/UUID-download-RNA-Seq.dat"
miRNA="dat/UUID-download-miRNA-Seq.dat"

OUT="dat/UUID-download.dat"

cat $WGS $WXS $RNA $miRNA | sort > $OUT
echo Written to $OUT
