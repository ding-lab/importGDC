DATAD="/storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC"
TOKEN="/storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/CPTAC3/import/token/gdc-user-token.2020-01-31T20_48_13.912Z.txt"
CATALOG="/home/m.wyczalkowski/Projects/CPTAC3/CPTAC3.catalog/CPTAC3.Catalog.dat"
UUID="UUID.dat"

Starting docker for direct run:
```
bash start_docker.LSF.sh compute1 /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/ /storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/CPTAC3/import/token
```

## testing launch_download.sh

11LU013.MethArray.Green.T   11LU013 LUAD    Methylation Array   tumor   CPT0053040010   202176300111_R06C01_Grn.idat    13676226    IDAT    Green   2ddd5fb8-54c2-4423-8e3c-51aa0fab87fe    d9307aaeff5e7e26e023bfa8a79f94be    NA  Primary Tumor

  UUID - UUID of object to download
  TOKEN - token filename.  Host path, must exist
  FN - filename of object.  Used only for indexing
  DF - data format of object (BAM

launch_download.sh -o IMPORT_DATAD UUID TOKEN FN DF

XARGS="-M -q general -g \" -G compute-lding\" "
launch_download.sh -o /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC/ 2ddd5fb8-54c2-4423-8e3c-51aa0fab87fe /storage1/fs1/home1/Active/home/m.wyczalkowski/Projects/CPTAC3/import/token/gdc-user-token.2020-01-31T20_48_13.912Z.txt 202176300111_R06C01_Grn.idat IDAT

bsub -q general -K -G compute-lding -e ./logs/2ddd5fb8-54c2-4423-8e3c-51aa0fab87fe.err -o ./logs/2ddd5fb8-54c2-4423-8e3c-51aa0fab87fe.out -a "docker(mwyczalkowski/importgdc:Y3)" /bin/bash /usr/local/importGDC/src/download_GDC.sh 2ddd5fb8-54c2-4423-8e3c-51aa0fab87fe /token/gdc-user-token.2020-01-31T20_48_13.912Z.txt 202176300111_R06C01_Grn.idat IDAT


## Testing of start_downloads.sh

The file UUID.dat contains list of UUIDs to test

Usage: start_downloads.sh [options] UUID [UUID2 ...]

Start import of GDC data

Required arguments:
-S CATALOG: path to Catalog data file. Required
-O DATAD: path to base of download directory (will write to $IMPORT_DATAD/GDC_import/data). Required
-t TOKEN: token filename.  Required

Options:
-h: print help message
-d: dry run.  This may be repeated (e.g., -dd or -d -d) to pass the -d argument to called functions instead,
    with each called function called in dry run mode if it gets one -d, and popping off one and passing rest otherwise
-1 : stop after one case processed.
-J NJOBS: Specify number of UUID to download in parallel.  Default 0 runs downloads sequentially
-l LOGD: Log output base directory.  Default: ./logs

Arguments passed to launch_download.sh
-g LSF_ARGS: Additional args to pass to LSF.  LSF mode only
-M: Run in LSF environment (MGI or compute1)
-B: Start docker container, map paths, and run bash instead of starting download
-i IMAGE: docker image to use.  Default is obtained from docker/docker_image.sh

Arguments passed to download_GDC.sh
-D: Download only, do not index
-I: Index only, do not Download.  DF must be "BAM"
-f: force overwrite of existing data files

This can be tested with TESTARGS=-1ddd

src/start_downloads.sh -S $CATALOG -O $DATAD -t $TOKEN -g "-G compute-lding" -M -q general $TESTARGS - < $UUID

With parallel (-J 5) turned on,
    src/utils.sh: line 46: parallel: command not found
-> This script has to be run in a container which has parallel installed
-> using scripts from https://github.com/ding-lab/CromwellRunner to start cromwell runner
   - do this for now instead of tyring to merge principal container
