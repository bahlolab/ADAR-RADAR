
process MARK_DUPS {
    cpus    2
    memory '8 GB'
    time   '4 h'
    module 'samtools/1.17'
    module 'picard-tools/2.26.11'
    publishDir "${params.outdir}/bam", mode: 'copy'
    tag "$sample"

    input:
    tuple val(sample), path(in_bam)
    path ref_fasta
    path ref_fasta_files

    output:
    tuple val(sample), path(out_bam), path("${out_bam}.bai")

    script:
    out_bam = "${sample}.md.bam"
    """
    mkdir tmp

    MarkDuplicates \\
        TMP_DIR=tmp \\
        I=$in_bam \\
        O=tmp.bam \\
        M=${sample}_duplication_info
    
    samtools calmd -@ $task.cpus -b tmp.bam $ref_fasta > $out_bam

    rm tmp.bam tmp -r
    
    samtools index -@ $task.cpus $out_bam
    """
}