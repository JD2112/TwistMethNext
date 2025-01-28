process GO_ANALYSIS {
    label 'process_medium'

    input:
    tuple val(method), path(results)
    val logfc_cutoff
    val pvalue_cutoff

    output:
    tuple val(method), path("${method}_gochord_plot.png"), emit: plot
    tuple val(method), path("${method}_gochord_plot.svg"), emit: goplot
    tuple val(method), path("${method}_go_enrichment_results.csv"), emit: results
    path "versions.yml", emit: versions

    script:
    """
    Rscript ${workflow.projectDir}/bin/go_analysis.R \
        --results ${results} \
        --output . \
        --method ${method} \
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