
include { STAR_2_PASS  } from '../../modules/local/00/star_2_pass.nf'
include { MARK_DUPS    } from '../../modules/local/00/mark_dups.nf'
include { JACUSA       } from '../../modules/local/00/jacusa.nf'

// TBD: replace with new
ref_genome      = Channel.fromPath("$projectDir/resources/Homo_sapiens_assembly38.fasta", checkIfExists:true).first()
star_genome_dir = Channel.fromPath("$projectDir/resources/star-index-hg38", checkIfExists:true).first()
star_gtf        = Channel.fromPath("$projectDir/resources/gencode.v43.annotation.gtf", checkIfExists:true).first()
jacus_jar       = Channel.fromPath("$projectDir/resources/JACUSA_v1.3.5.jar", checkIfExists:true).first()

workflow M00_PREPROCESS {
    take: 
    fastqs
    bams
    
    main:
    STAR_2_PASS(
        fastqs,
        star_genome_dir,
        star_gtf
    )

    MARK_DUPS (
        STAR_2_PASS.out,
        ref_genome
    )

    bams_mix = bams.mix(MARK_DUPS.out)

    JACUSA(
        bams_mix,
        jacus_jar
    )

    bamdir = file("${params.outdir}/bam").with{ it.mkdir(); it}.toRealPath()

    // create bam manifest
    MARK_DUPS.out
        .map { sm, bam, bai -> 
            "$sm,$bamdir/${bam.fileName}"
        }.collectFile(
            seed:     'sample,bam',
            name:     "${params.name}.bams.csv",
            storeDir: params.outdir,
            newLine:  true,
            sort:     true, 
            cache:    false
        )


    // create jacusa manifest
    jacusadir = file("${params.outdir}/jacusa").with{ it.mkdir(); it}.toRealPath()
    JACUSA.out
        .map { 
            sm, out -> "$sm,$jacusadir/${out.fileName}" 
        }.collectFile(
            seed:     'sample,jacusa',
            name:     "${params.name}.jacusa.csv",
            storeDir: params.outdir,
            newLine:  true,
            sort:     true, 
            cache:    false
        )

    emit:
    jacusa_results = JACUSA.out
    bams           = bams_mix
}