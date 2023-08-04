
process JACUSA {
    cpus    2
    memory '8 GB'
    time   '4 h'
    module 'java/1.8.0_211'


    input:
    tuple val(sample), path(bam)
    path jacusa_jar

    output:
    tuple val(sample), path(output)

    script:
    output = "${sample}_jacusa_strnd1.out"
    """
    java -jar $jacusa_jar call-1 ${tmpDir}/MYFILE_md.bam \\
        -F 1024 \\
        -P RF-FIRSTSTRAND \\
        -a D,S,Y \\
        -r $output
    """
}