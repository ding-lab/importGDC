TODO: implement general purpose docker launcher with the following features:
* Aware of MGI, compute, docker environments
  - select queue, other defaults accordingly
* Can map arbitrary paths through command line arguments like, PATH_H:PATH_C
  - if form is PATH_H, implies PATH_C=PATH_H
* Select through command line arguments
  - memory
  - image
  - dryrun
  - run bash or given command line
  - arbitrary LSF arguments
* Idea is to use a common script for launching both cromwell runner and importGDC containers

Past work: TinDaisy start docker is a good one:
    /Users/mwyczalk/Projects/TinDaisy/TinDaisy-Core/src/start_docker.sh
    ./start_docker.LSF.sh
    ../src/launch_download.sh
      - does both LSF and docker
