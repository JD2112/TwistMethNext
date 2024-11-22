process METHYLKIT_ANALYSIS {
    tag "MethylKit on ${design_file}"
    label 'process_medium'

    // conda "bioconda::r-methylkit=1.20.0 bioconda::bioconductor-org.hs.eg.db=3.14.0 bioconda::r-genomation=1.26.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/mulled-v2-9d3a7d03d8a3d72734447ab1fd6bc3dd3c0e815e:3a6d3e1f1a7a3e0b8f9d9b3b3e3f3d3c3b3a3d3e' :
    //     'quay.io/biocontainers/mulled-v2-9d3a7d03d8a3d72734447ab1fd6bc3dd3c0e815e:3a6d3e1f1a7a3e0b8f9d9b3b3e3f3d3c3b3a3d3e' }"

    input:
    path coverage_files
    path design_file
    val compare_str
    val threshold

    output:
    path "*.csv"        , emit: results
    path "versions.yml" , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def coverage_files_str = coverage_files.join(',')
    """
    Rscript ${projectDir}/bin/run_methylkit.R \\
        --coverage_files ${coverage_files_str} \\
        --design ${design_file} \\
        --compare ${compare_str} \\
        --output . \\
        --threshold ${threshold} \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-methylkit: \$(Rscript -e "library(methylKit); cat(as.character(packageVersion('methylKit')))")
        r-genomation: \$(Rscript -e "library(genomation); cat(as.character(packageVersion('genomation')))")
        r-org.hs.eg.db: \$(Rscript -e "library(org.Hs.eg.db); cat(as.character(packageVersion('org.Hs.eg.db')))")
    END_VERSIONS
    """
}