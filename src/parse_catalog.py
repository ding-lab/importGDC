import pandas as pd
import argparse
import sys

# https://stackoverflow.com/questions/5574702/how-do-i-print-to-stderr-in-python
# Usage: eprint("Test")
def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

# Catatalog and projects are merged on case column
def parse_catalog(catalog_fn, projects_fn, paths_fn):

    projects = pd.read_csv(projects_fn, sep="\t")

# want to merge on field "case"
# left is catalog, right is projects
    catalog = catalog.merge(projects, on="case", how="left")

# want to join RD and CD with path info in file GD=GDC_list_D.dat, Common key is UUID

    paths = pd.read_csv(paths_fn, sep="\t")
    print(paths)

    catalog = catalog.merge(paths, on="uuid", how="left")

    print(catalog)

    return catalog

# return dataframe of UUID, paths from both batch and master
def get_paths(batch_bm, master_bm):
    batch = pd.read_csv(batch_bm, sep="\t", usecols=['uuid', 'data_path'])

    if master_bm:
        master = pd.read_csv(master_bm, sep="\t", usecols=['uuid', 'data_path'])
        batch = pd.concat([batch, master], axis=0, ignore_index=True)
    return batch


# Takes in 
# * 4 column BamMap file of newly downloaded data
# * master BamMap file
# * Catalog file 
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Merge catalog file with project and path info")
    parser.add_argument("-c", "--catalog", dest="catalog_fn", help="Input catalog filename")
    parser.add_argument("-n", "--batch_bammap", dest="batch_bm", help="4-column BamMap of newly downloaded data")
    parser.add_argument("-m", "--master_bammap", dest="master_bm", help="System BamMap")
    parser.add_argument("-o", "--output", dest="output_fn", help="Output filename of new master BamMap")

    args = parser.parse_args()

    paths = get_paths(args.batch_bm, args.master_bm)

    catalog = pd.read_csv(args.catalog_fn, sep="\t")

    print(catalog)
    print(paths)

    print("Merging")
    catalog = catalog.merge(paths, on="uuid", how="right")
    print(catalog)
    catalog = catalog.sort_values(by='dataset_name')
    catalog['file_size'] = catalog['file_size'].astype(int)


    catalog.to_csv(args.output_fn, sep="\t", index=False)
    print(f"written to {args.output_fn}")

    
