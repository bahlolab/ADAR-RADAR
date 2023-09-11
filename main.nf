#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.name = 'AR'
params.input = 'samples.csv'
params.outdir = 'output'
params.sample_thresh = 5
params.alt_count_thresh = 3
params.depth_thresh = 10
params.remove_chr = true

// TODO:
params.strand = 'RF-FIRSTSTRAND' // 'RF-FIRSTSTRAND', 'FR-SECONDSTRAND' or 'UNSTRANDED'

 // check params.strand
if (!['RF-FIRSTSTRAND', 'FR-SECONDSTRAND', 'UNSTRANDED'].contains(params.strand)) {
    error("params.strand must be one of 'RF-FIRSTSTRAND', 'FR-SECONDSTRAND' or  'UNSTRANDED'")
}

include { ADARRADAR } from './workflows/adarradar'

workflow {
    ADARRADAR()
}