
include { IMPORT_JACUSA    } from '../../modules/local/01/import_jacusa.nf'
include { EXCLUDE_DBSNP    } from '../../modules/local/01/exclude_dbsnp.nf'
include { COMBINE_SITES    } from '../../modules/local/01/combine_sites.nf'
include { INTERSECT_SITES  } from '../../modules/local/01/intersect_sites.nf'
include { IMPORT_INTERSECT } from '../../modules/local/01/import_intersect.nf'


dbsnp        = Channel.fromPath("$projectDir/resources/dbSNP_loci.tsv.gz", checkIfExists:true).first()
genes        = Channel.fromPath("$projectDir/resources/hg38_reorder_genes.bed.gz", checkIfExists:true).first()
pc_genes     = Channel.fromPath("$projectDir/resources/Homo_sapiens_ProteinCodingGenes.GRCh38.91.bed.gz", checkIfExists:true).first()
ucsc_repeats = Channel.fromPath("$projectDir/resources/UCSC_Repeats_reformat.bed.gz", checkIfExists:true).first()
redi_counts  = Channel.fromPath("$projectDir/resources/REDI_gtex_counts.rds", checkIfExists:true).first()

workflow AGGREGATE_01 {
    take: 
    jacusa_results
    
    main:
    jacusa_tables = jacusa_results
        | IMPORT_JACUSA
        | combine(dbsnp)
        | EXCLUDE_DBSNP
        | map { it[2] }
        | collect

    COMBINE_SITES(
        jacusa_tables,
        redi_counts
    )

    INTERSECT_SITES(
        COMBINE_SITES.out.edsites_bed,
        genes,
        pc_genes,
        ucsc_repeats)
        | IMPORT_INTERSECT

    emit:
        // edsites_bed            = COMBINE_SITES.out.edsites_bed
        res_other              = COMBINE_SITES.out.res_other
        samp_site_counts       = COMBINE_SITES.out.samp_site_counts
        sites_redi_join        = COMBINE_SITES.out.sites_redi_join
        bounding_ensg          = IMPORT_INTERSECT.out.bounding_ensg
        gen_features_intersect = IMPORT_INTERSECT.out.gen_features_intersect
        rm_repeats_intersect   = IMPORT_INTERSECT.out.rm_repeats_intersect
    
}