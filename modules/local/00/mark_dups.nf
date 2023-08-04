
process MARK_DUPS {
    cpus    2
    memory '8 GB'
    time   '4 h'
    module 'samtools/1.17'
    module 'picard-tools/2.26.11'

    input:
    tuple val(sample), path(in_bam)
    path ref_genome

    output:
    tuple val(sample), path(out_bam), path("${out_bam}.bai")

    script:
    out_bam = "${sample}.md.bam"
    """
    samtools index -@ $task.cpus $in_bam

    MarkDuplicates \\
        I=$in_bam \\
        O=tmp.bam \\
        M=${sample}_duplication_info
    
    samtools calmd -@ $task.cpus -b tmp.bam $ref_genome > $out_bam
    
    samtools index -@ $task.cpus $out_bam
    """
}