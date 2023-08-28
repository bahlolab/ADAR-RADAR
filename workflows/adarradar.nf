
// run checks etc here

// import subworkflows
include { M00_PREPROCESS } from '../subworkflows/local/m00_preprocess.nf'
include { M01_AGGREGATE  } from '../subworkflows/local/m01_aggregate.nf'
include { M02_INTERSECT  } from '../subworkflows/local/m02_intersect.nf'

// TODO: check 1 row per sample
// TODO: check has bam if has jacusa
input = WfAdarRadar
    .read_csv(file(params.input), required: ['sample'])

// create channels from input
fastqs = Channel
    .fromList(input)
    .filter { it.fastq1 != null & it.fastq2 != null }
    .filter { it.bam == null & it.jacusa == null }
    .map { [it.sample, file(it.fastq1, checkIfExists: true), file(it.fastq2, checkIfExists: true)] }

bams_no_jacusa = Channel
    .fromList(input)
    .filter { it.bam != null & it.jacusa == null }
    .map { [it.sample, file(it.bam, checkIfExists: true), file("${it.bam}.bai", checkIfExists: true)] }

bams_with_jacusa = Channel
    .fromList(input)
    .filter { it.bam != null & it.jacusa != null }
    .map { [it.sample, file(it.bam, checkIfExists: true), file("${it.bam}.bai", checkIfExists: true)] }

jacusa_results = Channel
    .fromList(input)
    .filter { it.jacusa != null & it.bam != null }
    .map { [it.sample, file(it.jacusa, checkIfExists: true)] }

workflow ADARRADAR {

    // jacusa_results = Channel.fromList(input).map { [it.sample, [:], it.file] }
    // fastqs = Channel
    //     .fromList(input)
    //     .map { [it.sample, file(it.fastq1, checkIfExists: true), file(it.fastq2, checkIfExists: true)] }

    M00_PREPROCESS(
        fastqs,
        bams_no_jacusa
    )

    M01_AGGREGATE(
        jacusa_results.mix(
            M00_PREPROCESS.out.jacusa_results
        )
    )

    M02_INTERSECT(
        M01_AGGREGATE.out.res_other,
        M01_AGGREGATE.out.samp_site_counts,
        M01_AGGREGATE.out.sites_redi_join,
        M01_AGGREGATE.out.all_site_stats,
        M01_AGGREGATE.out.bounding_ensg,
        M01_AGGREGATE.out.gen_features_intersect,
        M01_AGGREGATE.out.rm_repeats_intersect
    )

    //TBD
    bams_depth = bams_with_jacusa.mix(M00_PREPROCESS.out.bams)

}

