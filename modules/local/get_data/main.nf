process GET_DATA {
    label 'process_low'

    conda( params.enable_conda ? 'conda-forge::python=3.10.0 conda-forge::requests=2.28.1' : null )

    input:
    file json

    output:
//    path "mirtarbase_all.xlsx", emit: mirtarbase
    path "*.txt"              , emit: rnainter
    path "versions.yml"       , emit: versions

    script:
    """
    info_collect.py $json \$PWD
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python3: \$( python3 --version | awk '{print \$2}' )
    END_VERSIONS
    """
}