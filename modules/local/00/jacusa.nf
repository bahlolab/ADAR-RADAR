
process JACUSA {
    cpus    2
    memory '16 GB'
    time   '8 h'
    module 'java/1.8.0_211'


    input:
    tuple val(sample), path(bam), path(bai)
    path jacusa_jar

    output:
    tuple val(sample), path(output)

    script:
    output = "${sample}_jacusa_strnd1.out"
    """
    java -jar $jacusa_jar call-1 $bam \\
        -F 1024 \\
        -P RF-FIRSTSTRAND \\
        -a D,S,Y \\
        -p $task.cpus \\
        -r $output
    """
}