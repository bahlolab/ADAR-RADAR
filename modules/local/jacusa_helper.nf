
process JACUSA_HELPER {
    cpus    1
    memory '4 GB'
    time   '1 h'
    label  'R'
    tag "$id"

    input:
    tuple val(id), val(meta), path(jacusa_output)

    output:
    tuple val(id), val(meta), path(jacusa_table)

    script:
    jacusa_table = "${id}.jacusa_table.tsv.gz"
    """
    jacusa_helper.R $id $jacusa_output
    """
}