
include { SAM_DEPTH         } from '../../modules/local/03/sam_depth.nf'
include { COMBINE_SAM_DEPTH } from '../../modules/local/03/combine_sam_depth.nf'

workflow M03_SAMDEPTH {
    take: 
    bams_depth
    res_other
    sites_stats_filt
    sites_filt_bed
    
    main:

    SAM_DEPTH(
        bams_depth,
        sites_filt_bed
    )

    sam_depth_csv = SAM_DEPTH.out
        .map { sample, depth -> "$sample,${depth.fileName}" }
        .collectFile(
            seed:     'sample,depthfile',
            name:     "sam_depth.csv",\
            newLine:  true,
            sort:     true, 
            cache:    true
        ).first()

    sam_depth_files = SAM_DEPTH.out
        .map { it[1] }
        .collect()

    COMBINE_SAM_DEPTH(
        sites_stats_filt,
        sam_depth_csv,
        sam_depth_files,
        res_other
    )

    emit:
    sample_site_depth = COMBINE_SAM_DEPTH.out
}