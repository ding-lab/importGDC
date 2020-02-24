This project consists of development of Y3 version and download of PDA RNA-Seq data.
See README.compute1-testing.md for details about development

PDA download is defined by UUID list in dat/UUID-download.dat, and consists of the following:

Total required disk space WGS: 0 Tb in 0 files
                          WXS: 0 Tb in 0 files
                      RNA-Seq: 1.69332 Tb in 205 files
                    miRNA-Seq: 0 Tb in 0 files
            Methylation Array: 0 Tb in 0 files
          Targeted Sequencing: 0 Tb in 0 files
                        TOTAL: 1.69332 Tb in 205 files

# Downloading

bash 20_start_download.sh -J5

## Downloading errors

```
Processing 25 / 205 [ Mon Feb 24 21:55:52 UTC 2020 ]: 1da42751-ac08-44d3-be4a-079c3cad256d
Running: parallel --semaphore -j5 --id 20200224210947 --joblog ./logs/parallel.1da42751-ac08-44d3-be4a-079c3cad256d.log --tmpdir ./logs "bash src/launch_download.sh -g \"-G compute-lding\" -M -q general -o /storage1/fs1/m.wyczalkowski/Active/Primary/CPTAC3.share/CPTAC3-GDC 1da42751-ac08-44d3-be4a-079c3cad256d /home/m.wyczalkowski/Projects/CPTAC3/import/token/gdc-user-token.2020-01-31T20_48_13.912Z.txt 2917532a-84e2-478f-8002-2cdc0933731a.rna_seq.genomic.gdc_realn.bam BAM"
Fatal ERROR. Exiting.
```

However, the jobs still seem to be running and the download is going OK.  Perhaps the fatal error has something to do with tmux and exiting?

