
process EXCLUDE_DBSNP {
    cpus    1
    memory '4 GB'
    time   '1 h'
    label  'R'
    tag "$id"

    input:
    tuple val(id), val(meta), path(jacusa_table), path(dbsnp)

    output:
    tuple val(id), val(meta), path(jacusa_table_flt)

    script:
    jacusa_table_flt = "${id}.jacusa_table.dbSNP_filt.rds"
    """
    exclude_dbsnp.R $id $jacusa_table $dbsnp
    """
}