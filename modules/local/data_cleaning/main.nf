process DATA_CLEANING {
    tag 'Processing source data'
    label 'process_low'

    conda (params.enable_conda ? "conda-forge::r=4.1 conda-forge::r-dplyr=1.0.9 conda-forge::r-openxlsx=4.2.5 conda-forge::r-stringr=1.4.1" : null)

    input:
    file mirtarbase
    file rnainter

    output:
    path 'mirtarbase_raid.csv'  , emit: csv
    path 'versions.yml'         , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    """
    db_preprocess.R $mirtarbase $rnainter

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        R-base: \$( R --version | awk 'NR==1{print \$3}' )
    END_VERSIONS
    """
}