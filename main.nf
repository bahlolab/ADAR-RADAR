#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.name = 'AR'
params.input = 'samples.csv'
params.outdir = 'output'

include { ADARRADAR } from './workflows/adarradar'

workflow {
    ADARRADAR()
}