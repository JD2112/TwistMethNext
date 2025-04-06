include { EDGER_ANALYSIS } from '../modules/edger'
include { METHYLKIT_ANALYSIS } from '../modules/methylkit'

workflow DIFFERENTIAL_METHYLATION {
    take:
    coverage_files
    design_file
    compare_str
    coverage_threshold
    method
    refseq_file
    methylkit_assembly
    methylkit_mc_cores
    methylkit_diff
    methylkit_qvalue

    main:    
    ch_versions = Channel.empty()
    ch_edger_results = Channel.empty()
    ch_methylkit_results = Channel.empty()

    // Prepare the coverage files channel
    coverage_files_prepared = coverage_files
        .map { meta, file -> 
            return file 
        }
        .collect()
    
    //log.info "DIFFERENTIAL_METHYLATION: Prepared coverage files: ${coverage_files_prepared}"

    if (method == 'edger' || method == 'both') {
        //log.info "DIFFERENTIAL_METHYLATION: Running EdgeR analysis"        
        EDGER_ANALYSIS (
            coverage_files_prepared,
            design_file,
            compare_str,
            coverage_threshold
        )
        ch_edger_results = EDGER_ANALYSIS.out.results
        ch_versions = ch_versions.mix(EDGER_ANALYSIS.out.versions)
        //log.info "DIFFERENTIAL_METHYLATION: EdgeR analysis completed"        
    }

    if (method == 'methylkit' || method == 'both') {
        //log.info "DIFFERENTIAL_METHYLATION: Running MethylKit analysis"        
        try {
            METHYLKIT_ANALYSIS (
                coverage_files_prepared,
                design_file,
                compare_str,
                coverage_threshold,
                refseq_file,
                methylkit_assembly,
                methylkit_mc_cores,
                methylkit_diff,
                methylkit_qvalue
            )
            ch_methylkit_results = METHYLKIT_ANALYSIS.out.results
            ch_versions = ch_versions.mix(METHYLKIT_ANALYSIS.out.versions)
            //log.info "DIFFERENTIAL_METHYLATION: MethylKit analysis completed"            
        } catch (Exception e) {
            //log.error "DIFFERENTIAL_METHYLATION: Error in METHYLKIT_ANALYSIS: ${e.message}"
            e.printStackTrace()
        }
    }

    // Combine the results for RESULT_ANALYSIS
    // ch_combined_results = ch_edger_results
    //     .mix(ch_methylkit_results)
    //     .ifEmpty { error "No results generated from either EdgeR or MethylKit" }

    emit:
    edger_results = ch_edger_results
    methylkit_results = ch_methylkit_results
    //combined_results = ch_combined_results
    versions = ch_versions
}