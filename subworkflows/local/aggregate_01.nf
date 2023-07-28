
include { IMPORT_JACUSA   } from '../../modules/local/import_jacusa.nf'
include { EXCLUDE_DBSNP   } from '../../modules/local/exclude_dbsnp.nf'
include { COMBINE_SITES   } from '../../modules/local/combine_sites.nf'
include { INTERSECT_SITES } from '../../modules/local/intersect_sites.nf'


dbsnp        = Channel.fromPath("$projectDir/resources/dbSNP_loci.tsv.gz", checkIfExists:true).first()
genes        = Channel.fromPath("$projectDir/resources/hg38_reorder_genes.bed.gz", checkIfExists:true).first()
pc_genes     = Channel.fromPath("$projectDir/resources/Homo_sapiens_ProteinCodingGenes.GRCh38.91.bed.gz", checkIfExists:true).first()
ucsc_repeats = Channel.fromPath("$projectDir/resources/UCSC_Repeats_reformat.bed.gz", checkIfExists:true).first()

workflow AGGREGATE_01 {
    take: 
    jacusa_results
    
    main:
    jacusa_results
        | IMPORT_JACUSA
        | combine(dbsnp)
        | EXCLUDE_DBSNP
        | map { it[2] }
        | collect
        | COMBINE_SITES

    INTERSECT_SITES(
        COMBINE_SITES.out.edsites_bed,
        genes,
        pc_genes,
        ucsc_repeats
    )
}