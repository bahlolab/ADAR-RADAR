
include { INTERSECT  } from '../../modules/local/02/intersect.nf'


// dbsnp        = Channel.fromPath("$projectDir/resources/dbSNP_loci.tsv.gz", checkIfExists:true).first()

workflow M02_INTERSECT {
    take: 
    res_other
    samp_site_counts
    sites_redi_join
    all_site_stats
    bounding_ensg
    gen_features_intersect
    rm_repeats_intersect
    
    main:

    INTERSECT(
        sites_redi_join,
        bounding_ensg,
        rm_repeats_intersect,
        gen_features_intersect,
        all_site_stats
    )

    emit:
    null
    
}