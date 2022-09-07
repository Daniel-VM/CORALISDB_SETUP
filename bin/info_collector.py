#           info_collector.py
#
# So far, the info_collector collects  ncRNA-target interactions from curated databases (see mti_urls.json).
#
import pandas as pd
import json
import requests
import gzip
import re
import os
import sys

## CONFIG VARIABLES
base_dir = r'C:/Users/da.valle/ownCloud/work/Amanda/R_package/CORALIS'
bin_dir = os.path.join(base_dir, r"bin").replace( '\\','/')
outsource_dir = os.path.join(base_dir, r"data/basic_data/source").replace( '\\','/')

## Get URLs
print("...Accessiing to URLs...\n")
with open('mti_urls.json') as j_file:
    data = json.load(j_file)

## MIRTARBASE
mirtarbase = requests.get(data['miRTarbase'])
with open(os.path.join(outsource_dir, r'mirtarbase_all.xlsx').replace( '\\','/'), 'wb') as f_mirtarbase:
    f_mirtarbase.write(mirtarbase.content)
print("\nMIRTARBASE done \n")

#RAIDv3
# The RAIDatabase has stored the information regarding the ncRNA-interactions based on categories which are encoded numerically under the argument PID. 
# This pids indicates the detection method (strong / weak experimental evicence and computational prediction) by which ncRNA-interaction were found. 
# Aditionally, each pid argument has associated a sub argument called id  that points to the technique used.
# All source interaction files in RAID are stored according to the ID number.  
#     pid=31 <- strong experimental evicence
#     pid=32 <- weak experimental evicence
#
#     id=31*.zip <- strong experimental evicence
#     id=32*.zip <- weak experimental evicence

## RAIDv3: GET RAID info
raid_url = data['RAID'] 
raid_pids = requests.get("https://www.rna-society.org/rnainter3/js/browser/myztree.js", allow_redirects=False)

## RAIDv3: BROWSE experimentally validated interactions based on PIDs
pattern_strong = 'id:(.*?), pId:31'
pattern_weak = 'id:(.*?), pId:32'
pids_strong = re.findall(pattern_strong, raid_pids.text)
pids_weak = re.findall(pattern_weak, raid_pids.text)
pids_all = pids_strong + pids_weak

## RAIDv3:Download experimentally validadted interactions
cc = 1
for i in range(0, len(pids_all)):

    if pids_all[i] == "321":
        pids_all[i] = "ChIP-seq"

    file_name = pids_all[i] + ".zip"
    raid_file = raid_url + file_name
    raid = requests.get(raid_file, allow_redirects=False)
    bf = os.path.join(outsource_dir, r'tmp/').replace( '\\','/') + file_name

    with open(bf, 'wb') as f_raid:
        f_raid.write(raid.content)
        print(file_name)
    cc+=1
## DONE
print("RAIDv3 done \n>Downloaded zips: "+ str(cc)) #107 files