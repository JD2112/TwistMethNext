process MULTIQC {
    label 'process_medium'

    // conda "bioconda::multiqc=1.11"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'quay.io/biocontainers/multiqc:1.11--pyhdfd78af_0' :
    //     'quay.io/biocontainers/multiqc:1.11--pyhdfd78af_0' }"

    input:
    path '*'

    output:
    path "multiqc_report.html", emit: report
    path "versions.yml", emit: versions

    script:
    """
    multiqc .
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}