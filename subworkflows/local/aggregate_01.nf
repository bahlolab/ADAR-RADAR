
include { IMPORT_JACUSA } from '../../modules/local/import_jacusa.nf'
include { EXCLUDE_DBSNP } from '../../modules/local/exclude_dbsnp.nf'
include { COMBINE_SITES } from '../../modules/local/combine_sites.nf'


dbsnp = Channel.fromPath("$projectDir/resources/dbSNP_loci.tsv.gz", checkIfExists:true)

workflow AGGREGATE_01 {
    take: 
    jacusa_results
    
    main:
    jacusa_results \
        | IMPORT_JACUSA \
        | combine(dbsnp)
        | EXCLUDE_DBSNP \
        | map { it[2] } \
        | collect \
        | COMBINE_SITES

}