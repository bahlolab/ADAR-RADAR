
process IMPORT_INTERSECT {
    cpus    1
    memory '4 GB'
    time   '1 h'
    label  'R'

    input:
    tuple path(gene_isec), path(pc_gene_isec), path(repeat_isec)


    output:
    path bounding_ensg         , emit: bounding_ensg
    path gen_features_intersect, emit: gen_features_intersect
    path rm_repeats_intersect  , emit: rm_repeats_intersect

    script:
    bounding_ensg           = "${params.name}.boundingENSG.rds"
    gen_features_intersect  = "${params.name}.genFeatures_intersect.rds"
    rm_repeats_intersect    = "${params.name}.RM_Repeats_intersect.rds"
    """
    01_import_intersect.R $params.name $gene_isec $pc_gene_isec $repeat_isec
    """
}