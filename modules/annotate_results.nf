process ANNOTATE_RESULTS {
    label 'process_medium'

    //container "bioconductor/bioconductor_docker:RELEASE_3_14"

    input:
    path results
    path gtf
    

    output:
    path "annotated_results.csv", emit: annotated_results
    path "versions.yml", emit: versions
    path "log.txt", emit: log

    script:
    def gtf_arg = gtf.name != 'NO_FILE' ? "--gtf ${gtf}" : ''

    """
    Rscript ${workflow.projectDir}/bin/annotate_results.R \
        --results ${results} \
        ${gtf_arg} \
        --output annotated_results.csv >> log.txt 2>&1

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(R --version | grep "R version" | sed 's/R version //' | sed 's/ .*//')
        genomicranges: \$(Rscript -e "library(GenomicRanges); cat(as.character(packageVersion('GenomicRanges')))")
    END_VERSIONS
    """
}