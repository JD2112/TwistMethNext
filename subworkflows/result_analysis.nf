include { ANNOTATE_RESULTS } from '../modules/annotate_results'
include { POST_PROCESSING } from '../modules/post_processing'
include { GO_ANALYSIS } from '../modules/go_analysis'

workflow RESULT_ANALYSIS {
    take:
    diff_meth_results
    compare_str
    logfc_cutoff
    pvalue_cutoff
    hyper_color
    hypo_color
    nonsig_color
    gtf_file

    main:

    ANNOTATE_RESULTS(
        diff_meth_results,
        gtf_file
        )

    POST_PROCESSING(
        ANNOTATE_RESULTS.out.annotated_results,
        compare_str,
        logfc_cutoff,
        pvalue_cutoff,
        hyper_color,
        hypo_color,
        nonsig_color
    )

    GO_ANALYSIS(
        ANNOTATE_RESULTS.out.annotated_results,
        logfc_cutoff,
        pvalue_cutoff
    )

    emit:
    annotated_results = ANNOTATE_RESULTS.out.annotated_results
    post_processing_summary = POST_PROCESSING.out.summary
    post_processing_plots = POST_PROCESSING.out.plots
    go_analysis_plot = GO_ANALYSIS.out.plot
    go_analysis_plot = GO_ANALYSIS.out.goplot
    go_analysis_results = GO_ANALYSIS.out.results
}