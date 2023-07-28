
process COMBINE_SITES {
    cpus    1
    memory '4 GB'
    time   '2 h'
    label  'R'

    input:
    path(jacusa_tables)

    output:
    path "${params.name}.stranded_edSites.bed", emit: edsites_bed
    path "${params.name}.res_other.rds", emit: res_other
    path "${params.name}.nSamp_site_counts.rds", emit: samp_site_counts

    script:
    """
    combine_sites.R $params.name $jacusa_tables
    """
}