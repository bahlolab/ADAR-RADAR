
process REPORT {
    cpus    1
    memory '4 GB'
    time   '2 h'
    label  'R'
    publishDir "${params.outdir}", mode: 'copy'

    input:
    path(rmd)
    path(res_other)
    path(sites_tagged_context)

    output:
    path("${params.name}.report.html")

    script:
    """
    cp --remove-destination `readlink $rmd` $rmd
    04_report.R $params.name \\
        $rmd \\
        $res_other \\
        $sites_tagged_context
    """
}