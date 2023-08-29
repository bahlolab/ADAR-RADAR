
process STAR_2_PASS {
    cpus    8
    memory '40 GB'
    time   '4 h'
    module 'STAR/2.6.1c'
    tag "$sample"

    input:
    tuple val(sample), path(fastq1), path(fastq2)
    path star_genome_dir
    path star_gtf

    output:
    tuple val(sample), path(bam)

    script:
    bam = "${sample}.Aligned.sortedByCoord.out.bam"
    """
    STAR \\
        --runThreadN $task.cpus \\
        --genomeDir $star_genome_dir \\
        --sjdbGTFfile $star_gtf \\
        --readFilesIn $fastq1 $fastq2  \\
        --readFilesCommand zcat \\
        --outFileNamePrefix ${sample}. \\
        --outSAMtype BAM SortedByCoordinate \\
        --twopassMode Basic
    """
}