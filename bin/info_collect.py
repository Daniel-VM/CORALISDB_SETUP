#!/usr/bin/env python3

#           info_collector.py
#
# So far, the info_collector collects  ncRNA-target interactions from curated databases.
#
#import pandas as pd
import json
import requests
import tarfile
import os
import sys
import argparse


## Parse Arguments
def parse_args(args=None):
    Description='Access and download ncRNA target interaction data from miRTarbase and RNAInter database'
    Epilog='Usage: python3 info_collect.py FILE_IN DIR_OUT'

    parser = argparse.ArgumentParser(description=Description, epilog=Epilog)
    parser.add_argument("FILE_IN", help="Input file containing urls in JSON format")
    parser.add_argument("DIR_OUT", help="Directory to save output files")

    return parser.parse_args(args)

## Get source data through json file containing urls
def get_data(file_in, dir_out):
    """
    This function downloads RNA-RNA interaction data from miRTarbase and RNAINTER database. 
    """
    # SCANN INPUT FILE
    with open(file_in, 'r') as j_file:
        data = json.load(j_file)
    
    # MIRTARBASE
##    mirtarbase  = requests.get(data['miRTarbase'])
##    out_mirtarbase    = os.path.join(dir_out, r'mirtarbase_all.xlsx') 
##    with open( out_mirtarbase, 'wb') as f_mirtarbase:
##        f_mirtarbase.write( mirtarbase.content )
        
    # RNAINTER
    rniainter_tar  = requests.get(data['RNAINTER'], stream=True)
    
    with tarfile.open(fileobj=rniainter_tar.raw, mode="r|gz") as tf:
        # tf.extract(member=rnainter_fname, path = dir_out)
        tf.extractall(path = dir_out)
    
def main(args=None):
    args = parse_args(args)
    get_data(args.FILE_IN, args.DIR_OUT)
    
if __name__ == "__main__":
    sys.exit(main())