process QUALIMAP {
    tag "$meta.id"
    label 'process_medium'

    conda "bioconda::qualimap=2.2.2d"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/qualimap:2.2.2d--1' :
        'quay.io/biocontainers/qualimap:2.2.2d--1' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("${meta.id}_qualimap"), emit: results
    path "versions.yml"                         , emit: versions

    script:
    """
    qualimap bamqc \
        -bam $bam \
        -outdir ${meta.id}_qualimap \
        -outformat HTML \
        --java-mem-size=${task.memory.toGiga()}G \
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        qualimap: \$(qualimap 2>&1 | grep 'QualiMap v.' | sed 's/QualiMap v.//g')
    END_VERSIONS
    """
}