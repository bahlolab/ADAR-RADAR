
process IMPORT_JACUSA {
    cpus    1
    memory '8 GB'
    time   '1 h'
    label  'R'
    tag "$id"

    input:
    tuple val(id), path(jacusa_output), path(dbsnp)

    output:
    tuple val(id), path(jacusa_table)

    script:
    jacusa_table = "${id}.jacusa_table.rds"
    """
    01_import_jacusa.R \\
        $id \\
        $jacusa_output \\
        $dbsnp \\
        $params.remove_chr
    """
        // $params.alt_count_thresh \\
        // $params.depth_thresh \\
}