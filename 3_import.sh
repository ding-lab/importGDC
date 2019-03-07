
read -r -d '' USAGE <<'EOF'
Data import is done manually and varies between katmai and MGI.  See README.md

tl;dr:  On katmai the following command will start four downloads in parallel:

    ./evaluate_batch_status.sh -f import:ready -u | ./start_batch_import.sh -J4 - 
  
EOF

>&2 echo "$USAGE"

