# CORALIS DB SETUP

This is a nIextflow workflow that creates (and automatically configures) the [CORALIS](https://github.com/Daniel-VM/CORALS) database containing experimentally validated interactions between ncRNAs and their target genes. So far, interactions are retrieved from [miRTarbase]() and [RNAInterv4 database](http://rnainter.org/).

## Steps
1. Get data from miRTarbase and RNAINTERv4 databases
2. Data Cleaning and filtering
3. SQLite database generation

## Download
```console
git clone https://github.com/Daniel-VM/CORALISDB_SETUP
```

## Usage
In order to use this workflow you must install [conda](https://www.anaconda.com/products/distribution) in your system.

```console
nextflow run main -profile conda --json_url 'pathTo/url_file.json' --out 'pathTo/outputDir'
```
- `profile`: package manager that will be used by the workflow. so far, this workflow works with conda only.
- `json_url`: path to list of urls to get the raw data in json format. These urls should ponint directly to the file in which ncRNA-target data is allocated. 
- `output`: Directory to save the results.


## Details

### Source data
Raw data containing ncRNA-target interaction data is obtained from [miRTarbase]() and [RNAInterv4 database](http://rnainter.org/).

### Raw data preprocess
Firstly, intra-specie interactions will be filtered out from miRTarbase. 

Second, we select ncRNA-mRNA interactions that meet the following criteria:
1. ncRNAs-mRNA target interactions (circRNA, lncRNA, miRNA, ncRNA, rRNA, piRNA, snoRNA and snRNA)
2. Interactions with strong or weak evidence
3. Intrspecie interactions
4. Keep species with >=30 ncRNA-mRNA interactions.

