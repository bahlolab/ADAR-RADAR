
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

    JACUSA(
        MARK_DUPS.out,
        jacus_jar
    )

    emit:
    JACUSA.out
}