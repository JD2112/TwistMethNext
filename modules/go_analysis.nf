process GO_ANALYSIS {
    label 'process_medium'

    // conda "bioconda::r-goplot=1.0.2 bioconda::bioconductor-org.hs.eg.db=3.14.0 bioconda::bioconductor-clusterprofiler=4.2.2"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/mulled-v2-9aba8bf2acb0f2ca4c3d1e8f99cdb6be5b649de7:6c6c5d45a8a0d6c0e0c5a5a5a5a5a5a5a5a5a5a' :
    //     'quay.io/biocontainers/mulled-v2-9aba8bf2acb0f2ca4c3d1e8f99cdb6be5b649de7:6c6c5d45a8a0d6c0e0c5a5a5a5a5a5a5a5a5a5a' }"

    input:
    path results
    val logfc_cutoff
    val pvalue_cutoff

    output:
    path "gochord_plot.png", emit: plot
    path "gochord_plot.svg", emit: goplot
    path "go_enrichment_results.csv", emit: results
    path "versions.yml", emit: versions

    script:
    """
    Rscript ${workflow.projectDir}/bin/go_analysis.R \
        --results ${results} \
        --output . \
        --logfc_cutoff ${logfc_cutoff} \
        --pvalue_cutoff ${pvalue_cutoff}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | grep "R version" | sed 's/R version //' | sed 's/ .*//')
        goplot: \$(Rscript -e "library(GOplot); cat(as.character(packageVersion('GOplot')))")
        clusterprofiler: \$(Rscript -e "library(clusterProfiler); cat(as.character(packageVersion('clusterProfiler')))")
    END_VERSIONS
    """
}