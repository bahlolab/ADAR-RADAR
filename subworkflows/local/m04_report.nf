
include { REPORT } from '../../modules/local/04/report.nf'


report_rmd = Channel.fromPath("$projectDir/bin/04_report.Rmd", checkIfExists:true).first()

workflow M04_REPORT {
    take: 
    // module 1
    res_other
    samp_site_counts
    sites_redi_join
    all_site_stats
    bounding_ensg
    gen_features_intersect
    rm_repeats_intersect
    // module 2
    sites_tagged_context
    sites_stats_filt
    sites_filt_bed
    // module 3
    sample_site_depth

    main:
    REPORT(
        report_rmd,
        res_other,
        sites_tagged_context
    )

    emit:
    REPORT.out
}