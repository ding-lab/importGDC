import numpy as np
import pandas as pd
import argparse, sys, os, binascii
import csv, re, json

# Append BamMap path and system info to catalog by merging to catalog on column uuid, retain
# only entries in BamMap

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def read_bammap(fn):
    # force aliquot_annotation to be type str - doesn't seem to work?
    #type_arg = {'aliquot_annotation': 'str'}
    #aliquots = pd.read_csv(fn, sep="\t", dtype=type_arg, comment='#')

    # might be useful...
    # # make sure "alignment" has the string value "NA", not NaN
    # rf.loc[rf['alignment'].isna(), "alignment"] = "NA"
    bammap = pd.read_csv(fn, sep="\t", comment='#')
    return(bammap)

def read_catalog(fn):
    catalog = pd.read_csv(fn, sep="\t", comment='#')
    return(catalog)

def get_bammap_wide(catalog, bammap):
    bammap.drop('dataset_name', axis=1, inplace=True)
#    print(bammap.columns.tolist())  # debug
#    print(catalog.columns.tolist()) # debug
    cols_catalog = catalog.columns.tolist()

    merged = bammap.merge(catalog, on="uuid", how="left")# [['sample_code', 'sample_type_short']]

    # Now move the first two columns to end
#    cols = merged.columns.tolist()
#    print(cols) # debug
#    cols = cols[3:] + cols[1:3]
    cols = cols_catalog + ["system", "data_path"]
    merged = merged[cols]

    return merged

def write_bmw(outfn, bmw):
    print("Writing bammap-wide to " + outfn)
    bmw.to_csv(outfn, sep="\t", quoting=csv.QUOTE_NONE, index=False)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Creates Bammap wide format as a join between BamMap3 and Catalog3 files")
    parser.add_argument("bammap", help="BamMap3-format (4 column) file")
    parser.add_argument("catalog", help="Catalog3-format file")
    parser.add_argument("-o", "--output", dest="outfn", required=True, help="Output file name")
    parser.add_argument("-d", "--debug", action="store_true", help="Print debugging information to stderr")
    parser.add_argument("-n", "--no-header", action="store_true", help="Do not print header")

    args = parser.parse_args()

    bammap = read_bammap(args.bammap)
    catalog = read_catalog(args.catalog)

    bmw = get_bammap_wide(catalog, bammap) 
    write_bmw(args.outfn, bmw)
