
process COMBINE_SAM_DEPTH {
    cpus    1
    memory '4 GB'
    time   '2 h'
    label  'R'

    input:
    path(sites_stats_filt)
    path(sam_depth_csv)
    path(sam_depth_files)
    path(res_other)

    output:
    path("${params.name}.sample_site_depth.rds")

    script:
    """
    03_combine_sam_depth.R $params.name \\
        $sites_stats_filt \\
        $sam_depth_csv \\
        $res_other
    """
}