# Debug procedure and information for MGI downloads

Command to download/index/flagstat one UUID:
```
    bash start_import.c3b1.sh 59f284e7-cffa-4891-a76c-60dd8e46a01d
```

Testing with UUID `c336c120-966a-4ec0-9fc7-6d5c856bbc22` successful, with .bai and flagstat files created.  Data directory:
    /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/GDC_import/data/c336c120-966a-4ec0-9fc7-6d5c856bbc22
Log directory:
    /gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/GDC_import/import.config/CPTAC3.b2/logs

Note, three preliminary WGS runs need to be fixed:
    * confirm .bam file downloaded
    * confirm filenames names correct
    * index and flagstat
    - 27552a72-0d2c-4307-aefc-1cd193436953
    - 59f284e7-cffa-4891-a76c-60dd8e46a01d
    - e933d585-96d2-4ab6-89b1-2b542d07fa9e


Starting batch download of all WGS ready samples (this can be run in docker-interactive session):
```
export LSF_GROUP="/mwyczalk/gdc-download"
./evaluate_status.c3b1.sh -u -f import:ready WGS | ./start_import.c3b1.sh -
```

## Status

Confirm that one download is running at a time.
```
bjgroup -s /mwyczalk/gdc-download
```

Get details of given running job:
```
bjobs -w 5660277
```

Confirm download is going by looking at log:
```
/gscmnt/gc2521/dinglab/mwyczalk/somatic-wrapper-data/GDC_import/import.config/CPTAC3.b2/logs/14c0cb14-71e4-4f26-89f1-349ce26f0bf9.out
```
