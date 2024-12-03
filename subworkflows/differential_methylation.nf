include { EDGER_ANALYSIS } from '../modules/edger'
include { METHYLKIT_ANALYSIS } from '../modules/methylkit'

workflow DIFFERENTIAL_METHYLATION {
    take:
    coverage_files    // Channel: [ val(meta), path(coverage) ]
    design_file       // Path: design file
    compare_str       // String: comparison string
    coverage_threshold // Integer: coverage threshold

    main:
    ch_versions = Channel.empty()

    // Prepare the coverage files channel
    coverage_files_prepared = coverage_files
        .map { meta, file -> file }
        .collect()

    if (params.diff_meth_method == 'edger') {
        EDGER_ANALYSIS (
            //coverage_files.map { meta, file -> file }.collect(), //coverage_files,
            coverage_files_prepared,
            design_file,
            compare_str,
            coverage_threshold
        )
        ch_results = EDGER_ANALYSIS.out.results
        ch_versions = ch_versions.mix(EDGER_ANALYSIS.out.versions)
    } else if (params.diff_meth_method == 'methylkit') {
        METHYLKIT_ANALYSIS (
            //coverage_files.map { meta, file -> file }.collect(),
            coverage_files_prepared,
            design_file,
            compare_str,
            coverage_threshold
        )
        ch_results = METHYLKIT_ANALYSIS.out.results
        ch_versions = ch_versions.mix(METHYLKIT_ANALYSIS.out.versions)
    } else {
        error "Invalid differential methylation method: ${params.diff_meth_method}. Choose either 'edger' or 'methylkit'."
    }

    emit:
    results  = ch_results    // Channel: [ path(results) ]
    versions = ch_versions   // Channel: [ path(versions.yml) ]
}