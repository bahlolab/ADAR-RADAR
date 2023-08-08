
// run checks etc here

// import subworkflows
include { M00_PREPROCESS } from '../subworkflows/local/m00_preprocess.nf'
include { M01_AGGREGATE  } from '../subworkflows/local/m01_aggregate.nf'
include { M02_INTERSECT  } from '../subworkflows/local/m02_intersect.nf'

// import modules

/* 
input manifest spec:
    - required columns "sample",  "seqtype", "filetype", "filename"
        - eg "sample1", "stranded", "fastq1", "/path/to/file.fastq_R1.gz"
    - optional columns "replicate", "group"
*/
// input = WfAdarRadar
//     .read_csv(file(params.input), required: ['sample', 'filename'])
//     .collect { it + [file: file(it.filename, checkIfExists: true)] }

input = WfAdarRadar
    .read_csv(file(params.input), required: ['sample', 'fastq1', 'fastq2'])
/*
worflow steps:
    - STAR align (FE_star2pass.sh)
    - markdups calmd etc (jacusa_template.sh)
    - jacusa (jacusa_template.sh)
    - import jacusa (01_aggregate.R)
        - dbSNP sites excluded
        - create bedtools sites
    - intersect with features (stranded_bedtools_scripts.sh)
        - hg38_reorder_genes.bed?? (gencode?)
        - Protein Coding Genes (is this not redundant?)
        - UCSC repeats
    - ...
*/

workflow ADARRADAR {

    // jacusa_results = Channel.fromList(input).map { [it.sample, [:], it.file] }
    fastqs = Channel
        .fromList(input)
        .map { [it.sample, file(it.fastq1, checkIfExists: true), file(it.fastq2, checkIfExists: true)] }

    M00_PREPROCESS(
        fastqs
    )

    M01_AGGREGATE(
        M00_PREPROCESS.out.jacusa_results
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
}

