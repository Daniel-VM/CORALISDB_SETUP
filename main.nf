#!/usr/bin/env nextflow
/*
=======================================
    CORALIS DATABASE SETUP
=======================================
*/

nextflow.enable.dsl = 2

/*
=======================================
    VALIDATE & PRINT PARAMS
=======================================
This pipeline runs initial checks to verify the user's input consistency (file format, mandatory params)
(See lib/)
*/
// <!-- IVI TODO: add nf-croe lib workflow -->


/*
=======================================
    CALL WORKFLOW
=======================================
*/
include { CORALISDB_SETUP } from './workflows/local/coralisdb_setup'

workflow NF_CORALISDB {
    CORALISDB_SETUP ()
} 

/*
=======================================
    CORALIS DB WORKFLOWS
=======================================
*/

workflow {
    NF_CORALISDB ()
}

/*
=======================================
    THE END
=======================================
*/