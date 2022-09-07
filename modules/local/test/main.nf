process TEST {
    label 'process_low'

    input:
    file mirtarbase

    output:
    path('mirtarbase.txt'), emit: res

    script:
    """
    cat $mirtarbase | head -n 3 > mirtarbase.txt
    """
}