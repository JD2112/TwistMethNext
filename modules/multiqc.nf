process MULTIQC {
    label 'process_medium'
    publishDir "${params.outdir}/multiqc", mode: 'copy'

    input:
    path(input_files)

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data", emit: data
    path "versions.yml", emit: versions
    path "multiqc.log", emit: log

    script:
    def args = task.ext.args ?: ''
    """
    mkdir temp_multiqc_input
    for file in ${input_files}; do
        [ -e "\$file" ] && cp -L "\$file" temp_multiqc_input/ || echo "File \$file not found"
    done

    multiqc -f $args temp_multiqc_input > multiqc.log 2>&1

    rm -rf temp_multiqc_input

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}