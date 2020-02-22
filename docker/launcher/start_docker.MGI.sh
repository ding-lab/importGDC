# Previous MGI launch command:
# /gscmnt/gc2560/core/env/v1/bin/gsub -m 32
# where -m Memory to reserve (in Gb). Default 2

# from /gscmnt/gc2560/core/env/v1/bin/gsub 
# selectString="select[mem>$(( mem * 1000 ))] rusage[mem=$(( mem * 1000 ))]";
# bsub -Is -J $jobname -M $(( $mem * 1000000 )) -n $nthreads -R "$selectString" -q $queue -a "$image" /bin/bash -l

# New command
# bsub -Is -q research-hpc -M 16000000 -R ‘rusage[mem=16000] select[mem>=16000]’ -a ‘docker(registry.gsc.wustl.edu/genome/lucid-default:latest)’ bash -l

mem=32

SELECT="select[mem>$(( mem * 1000 ))] rusage[mem=$(( mem * 1000 ))]";
QUEUE="research-hpc"
IMAGE="mwyczalkowski/cromwell-runner"

CMD="bsub -Is -M $(( $mem * 1000000 )) -R \"$SELECT\" -q $QUEUE -a \"docker($IMAGE)\" /bin/bash -l"
>&2 echo Running: $CMD
eval $CMD
