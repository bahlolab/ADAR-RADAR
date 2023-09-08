
process INTERSECT {
    cpus    1
    memory '4 GB'
    time   '2 h'
    label  'R'
    publishDir "${params.outdir}/rds", pattern: '*.rds', mode: 'copy'

    input:
    path sites_redi_join 
    path bounding_ensg
    path rm_repeats_intersect
    path gen_features_intersect
    path all_site_stats

    output:
    path "${params.name}.sites_tagged_context.rds", emit: sites_tagged_context
    path "${params.name}.siteStats_filt.rds",       emit: sites_stats_filt
    path "${params.name}.sites_filt.bed.gz",        emit: sites_filt_bed

    script:
    """
    02_intersect.R $params.name \\
        $sites_redi_join \\
        $bounding_ensg \\
        $rm_repeats_intersect \\
        $gen_features_intersect \\
        $all_site_stats
    """
}