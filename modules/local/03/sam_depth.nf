
process SAM_DEPTH {
    cpus    2
    memory '4 GB'
    time   '2 h'
    module 'samtools/1.17'
    tag "$sample"

    input:
    tuple val(sample), path(bam), path(bai)
    path bed

    output:
    tuple val(sample), path(output)

    script:
    output = "${sample}.${params.name}.depth.txt.gz"
    """
    samtools depth -@${task.cpus} -q 20 -Q 20 -b $bed $bam \\
        | gzip > $output
    """
}