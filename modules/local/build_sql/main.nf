process BUILD_SQL {
    tag 'Building Coralis database'
    label 'process_low'

    conda( params.enable_conda ? 'conda-forge::python=3.10.0' : null )

    input:
    file source

    output:
    path 'CORALIS_db.sqlite', emit: sqlite
    path 'versions.yml'     , emit: versions
    
    script:
    def args = task.ext.args ?: ''
    """
    #echo \$PWD > cwd.md
    touch CORALIS_db.sqlite

    DB_building.py ${source} \${PWD}/CORALIS_db.sqlite
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python3: \$( python3 --version | awk '{print \$2}' )
    END_VERSIONS
    """
}
    