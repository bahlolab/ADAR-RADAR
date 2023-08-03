
process INTERSECT_SITES {
    cpus    2
    memory '4 GB'
    time   '1 h'
    module 'bedtools/2.26.0'

    input:
    path sites
    path genes
    path pc_genes
    path ucsc_repeats


    output:
    tuple path(gene_isec), path(pc_gene_isec), path(repeat_isec)

    script:
    gene_isec    = "${params.name}.gene_isec.bed.gz"
    pc_gene_isec = "${params.name}.pc_gene_isec.bed.gz"
    repeat_isec  = "${params.name}.repeat_isec.bed.gz"
    """
    bedtools intersect -a $genes -b $sites \\
        | tr -d ";" \\
        | tr -d '"' \\
        | sort \\
        | uniq \\
        | gzip > $gene_isec

    bedtools intersect -a $pc_genes -b $sites \\
        | tr -d ";" \\
        | tr -d '"' \\
        | sort \\
        | uniq \\
        | gzip > $pc_gene_isec 

    bedtools intersect -a $ucsc_repeats -b $sites \\
        | sort \\
        | uniq \\
        | gzip > $repeat_isec 
    """
}