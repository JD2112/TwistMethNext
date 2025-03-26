include { ANNOTATE_RESULTS } from '../modules/annotate_results'
include { POST_PROCESSING as POST_PROCESSING_EDGER } from '../modules/post_processing'
include { POST_PROCESSING as POST_PROCESSING_METHYLKIT } from '../modules/post_processing'
include { GO_ANALYSIS as GO_ANALYSIS_EDGER } from '../modules/go_analysis'
include { GO_ANALYSIS as GO_ANALYSIS_METHYLKIT } from '../modules/go_analysis'

workflow RESULT_ANALYSIS {
    take:
    diff_meth_results // Channel: [ val(method), path(results) ]
    compare_str
    logfc_cutoff
    pvalue_cutoff
    hyper_color
    hypo_color
    nonsig_color
    gtf_file
    method // String: 'edger', 'methylkit', or 'both'
    top_n_genes

    main:
    //log.info "Starting RESULT_ANALYSIS for method: $method"
    //log.info "Received diff_meth_results: $diff_meth_results"
    
    ch_edger_results = Channel.empty()
    ch_methylkit_results = Channel.empty()
    ch_post_processing_edger = Channel.empty()
    ch_post_processing_methylkit = Channel.empty()
    ch_go_analysis_edger_plot = Channel.empty()
    ch_go_analysis_edger_goplot = Channel.empty()
    ch_go_analysis_edger_results = Channel.empty()
    ch_go_analysis_methylkit_plot = Channel.empty()
    ch_go_analysis_methylkit_goplot = Channel.empty()
    ch_go_analysis_methylkit_results = Channel.empty()
    ch_versions = Channel.empty()

    if (method == 'edger' || method == 'both') {
        //log.info "RESULT_ANALYSIS: Processing EdgeR results"
        ch_edger_results = diff_meth_results.filter { it[0] == 'edger' }
        ch_edger_results.view { "Filtered EdgeR results: $it" }
        
        ANNOTATE_RESULTS(ch_edger_results, gtf_file)
        
        ANNOTATE_RESULTS.out.annotated_results.view { "Annotated EdgeR results: $it" }
        
        POST_PROCESSING_EDGER(
            ANNOTATE_RESULTS.out.annotated_results,
            compare_str,
            logfc_cutoff,
            pvalue_cutoff,
            hyper_color,
            hypo_color,
            nonsig_color
        )

        GO_ANALYSIS_EDGER(
            ANNOTATE_RESULTS.out.annotated_results,
            logfc_cutoff,
            pvalue_cutoff,
            top_n_genes
        )

        ch_post_processing_edger = POST_PROCESSING_EDGER.out.summary
        ch_go_analysis_edger_plot = GO_ANALYSIS_EDGER.out.plot
        ch_go_analysis_edger_goplot = GO_ANALYSIS_EDGER.out.goplot
        ch_go_analysis_edger_results = GO_ANALYSIS_EDGER.out.results
        ch_versions = ch_versions.mix(ANNOTATE_RESULTS.out.versions).mix(POST_PROCESSING_EDGER.out.versions).mix(GO_ANALYSIS_EDGER.out.versions)
    }

    if (method == 'methylkit' || method == 'both') {
        ch_methylkit_results = diff_meth_results
            .filter { it[0] == 'methylkit' }
            .map { method, results -> 
                def results_file = results instanceof Path ? results : results[1]
                [method, results_file]
            }
        
        //log.info "Processing MethylKit results"
        ch_methylkit_results.view { "Debug - MethylKit results before POST_PROCESSING: $it" }
        
        POST_PROCESSING_METHYLKIT(
            ch_methylkit_results,
            compare_str,
            logfc_cutoff,
            pvalue_cutoff,
            hyper_color,
            hypo_color,
            nonsig_color
        )

        GO_ANALYSIS_METHYLKIT(
            ch_methylkit_results,
            logfc_cutoff,
            pvalue_cutoff,
            top_n_genes
        )

        ch_post_processing_methylkit = POST_PROCESSING_METHYLKIT.out.summary
        ch_go_analysis_methylkit_plot = GO_ANALYSIS_METHYLKIT.out.plot
        ch_go_analysis_methylkit_goplot = GO_ANALYSIS_METHYLKIT.out.goplot
        ch_go_analysis_methylkit_results = GO_ANALYSIS_METHYLKIT.out.results
        ch_versions = ch_versions.mix(POST_PROCESSING_METHYLKIT.out.versions).mix(GO_ANALYSIS_METHYLKIT.out.versions)
    }

    //log.info "Completed RESULT_ANALYSIS for method: $method"

    emit:
    edger_results = ch_edger_results
    methylkit_results = ch_methylkit_results
    post_processing_edger = ch_post_processing_edger
    post_processing_methylkit = ch_post_processing_methylkit
    go_analysis_edger_plot = ch_go_analysis_edger_plot
    go_analysis_edger_goplot = ch_go_analysis_edger_goplot
    go_analysis_edger_results = ch_go_analysis_edger_results
    go_analysis_methylkit_plot = ch_go_analysis_methylkit_plot
    go_analysis_methylkit_goplot = ch_go_analysis_methylkit_goplot
    go_analysis_methylkit_results = ch_go_analysis_methylkit_results
    versions = ch_versions
}