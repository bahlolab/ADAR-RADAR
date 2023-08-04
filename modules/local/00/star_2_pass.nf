
process STAR_2_PASS {
    cpus    4
    memory '8 GB'
    time   '4 h'
    module 'STAR/2.6.1c'

    input:
    tuple val(sample), path(fastq1), path(fastq2)
    path star_genome_dir
    path star_gtf

    output:
    tuple val(sample), path(fastq1), path(fastq2)

    script:
    bam = "${sample}.Aligned.sortedByCoord.out.bam"
    """
    STAR \\
        --runThreadN $task.cpus \\
        --genomeDir $star_genome_dir \\
        --sjdbGTFfile $star_gtf \\
        --sjdbOverhang 149 \\
        --readFilesIn $fastq1 $fastq2  \\
        --readFilesCommand zcat \\
        --outFileNamePrefix ${sample}. \\
        --outSAMtype BAM SortedByCoordinate \\
        --twopassMode Basic
    """
}