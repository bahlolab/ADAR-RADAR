
// run checks etc here

// import subworkflows
include { AGGREGATE_01 } from '../subworkflows/local/aggregate_01.nf'

// import modules

/* 
input manifest spec:
    - required columns "sample",  "seqtype", "filetype", "filename"
        - eg "sample1", "stranded", "fastq1", "/path/to/file.fastq_R1.gz"
    - optional columns "replicate", "group"
*/
input = WfAdarRadar
    .read_csv(file(params.input), required: ['sample', 'filename'])
    .collect { it + [file: file(it.filename, checkIfExists: true)] }
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

    jacusa_results = Channel.fromList(input).map { [it.sample, [:], it.file] }

    AGGREGATE_01(jacusa_results)
}

