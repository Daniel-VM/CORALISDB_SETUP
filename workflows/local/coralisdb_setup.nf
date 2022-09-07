/*
=====================================
    MANDATORY CONFIG-PARAMS
====================================
*/
if ( params.json_url ) { 
    json_url = Channel.fromPath( params.json_url ) 
} else { 
// <!-- IVI TODO: These two channels are a workaround that will point to the output of this module -->
    mirtarbase_data = Channel.fromPath( params.mirtarbase_data )
    raid_data       = Channel.fromPath( params.raid_data )
}

/*
=====================================
    LOCAL MODULES / SUBWORKFLOWS
====================================
*/
include { DATA_CLEANING } from '../../modules/local/data_cleaning/main'
include { BUILD_SQL     } from '../../modules/local/build_sql/main'
include { GET_DATA      } from '../../modules/local/get_data/main'

/*
=====================================
    NF-CORE MODULES / SUBWORKFLOWS
====================================
*/
include { CUSTOM_DUMPSOFTWAREVERSIONS } from '../../modules/nf-core/modules/custom/dumpsoftwareversions/main'

/*
=====================================
    RUN WORKFLOW
====================================
*/

workflow CORALISDB_SETUP {
    ch_versions = Channel.empty()

    //
    // MODULE: Get miRNA-target info
    //
// <!-- IVI TODO: wait till source database issues are fixed -->
    GET_DATA ( json_url )
    ch_versions = ch_versions.mix(GET_DATA.out.versions)
    
    //
    // MODULE: Data cleaning and format setup
    //
    DATA_CLEANING( 
        Channel.fromPath(params.mirtarbase_data), // Use this till mirtarbase is available through url
//        GET_DATA.out.mirtarbase,
        GET_DATA.out.rnainter
    )
    ch_versions = ch_versions.mix(DATA_CLEANING.out.versions)
    
    //
    // MODULE: Build CORALISDB
    //

    BUILD_SQL (
        DATA_CLEANING.out.csv
    )
    ch_versions = ch_versions.mix(BUILD_SQL.out.versions)

    //
    // MODULE: MERGE VERSIONS
    //
    CUSTOM_DUMPSOFTWAREVERSIONS (
        ch_versions.unique().collectFile(name: 'collated_versions.yml')
    )

}


/*
=====================================
    THE END
====================================
*/
