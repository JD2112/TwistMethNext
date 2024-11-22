process EDGER_ANALYSIS {
    label 'process_medium'

    // conda "bioconda::bioconductor-edger=3.34.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'quay.io/biocontainers/bioconductor-edger:3.34.0--r41h399db7b_0' :
    //     'quay.io/biocontainers/bioconductor-edger:3.34.0--r41h399db7b_0' }"

    input:
    path coverage_files
    path design_file
    val compare_str
    val coverage_threshold

    output:
    path "EdgeR_group_*.csv", emit: results
    path "versions.yml", emit: versions

    script:
    """
    Rscript $baseDir/bin/edgeR_analysis.R \
        --coverage_files '${coverage_files}' \
        --design "${design_file}" \
        --compare "${compare_str}" \
        --output . \
        --threshold ${coverage_threshold}
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$( R --version | grep "R version" | sed 's/R version //' | sed 's/ .*//' )
        bioconductor-edger: \$( R -e "library(edgeR); cat(as.character(packageVersion('edgeR')))" )
    END_VERSIONS
    """
}