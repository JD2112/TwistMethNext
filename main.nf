#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { PREPARE_GENOME } from './subworkflows/prepare_genome'
include { READ_PROCESSING } from './subworkflows/read_processing'
include { BISMARK_ANALYSIS } from './subworkflows/bismark_analysis'
include { QC_REPORTING } from './subworkflows/qc_reporting'

// Import EdgeR module
include { EDGER_ANALYSIS } from './modules/edger'

// Import Post-processing module
include { POST_PROCESSING } from './modules/post_processing'

// Print pipeline info
log.info """
BISULFITE SEQUENCING ANALYSIS PIPELINE
=======================================
sample sheet : ${params.sample_sheet}
genome       : ${params.genome_fasta}
bismark index: ${params.bismark_index}
outdir       : ${params.outdir}
"""

// Function to create a channel from the sample sheet
def create_sample_channel(sample_sheet) {
    return Channel
        .fromPath(sample_sheet, checkIfExists: true)
        .splitCsv(header:true)
        .map { row -> 
            if (!(row.containsKey('sample_id') && row.containsKey('group') && row.containsKey('read1'))) {
                error "Sample sheet must contain 'sample_id', 'group', and 'read1' columns: ${row}"
            }
            def meta = [id: row.sample_id, group: row.group]
            def reads = row.containsKey('read2') ? [file(row.read1), file(row.read2)] : file(row.read1)
            return [meta, reads]
        }
}

// Main workflow
workflow {
    // Input channels
    log.info "Creating sample channel from: ${params.sample_sheet}"
    ch_samples = create_sample_channel(params.sample_sheet)
    
    // Debug: print out the contents of the sample channel
    //ch_samples.view { meta, reads -> "Sample: ${meta.id}, Group: ${meta.group}, Reads: ${reads}" }

    // Genome preparation
    if (!params.bismark_index) {
        ch_genome = Channel.fromPath(params.genome_fasta, checkIfExists: true)
        PREPARE_GENOME(ch_genome)
        ch_index = PREPARE_GENOME.out.index
    } else {
        ch_index = Channel.fromPath(params.bismark_index, checkIfExists: true)
    }

    // Read processing
    READ_PROCESSING(ch_samples)

    // Bismark analysis
    BISMARK_ANALYSIS(READ_PROCESSING.out.trimmed_reads, ch_index)

    // QC reporting
    QC_REPORTING(
        READ_PROCESSING.out.fastqc_reports,
        READ_PROCESSING.out.trimming_reports,
        BISMARK_ANALYSIS.out.align_reports,
        BISMARK_ANALYSIS.out.dedup_reports,
        BISMARK_ANALYSIS.out.methylation_reports,
        BISMARK_ANALYSIS.out.summary_report,
        BISMARK_ANALYSIS.out.qualimap_results
    )

    // Collect all coverage files for EdgeR analysis
    ch_coverage_files = BISMARK_ANALYSIS.out.coverage_files
        .map { meta, file -> file }
        .collect()

    // EdgeR Analysis
    EDGER_ANALYSIS(
        ch_coverage_files,
        params.sample_sheet,
        params.compare_str,
        params.coverage_threshold
    )

    // Post-processing
    POST_PROCESSING(
        EDGER_ANALYSIS.out.results,
        params.compare_str
    )
}

// Completion handler
workflow.onComplete {
    log.info "Pipeline completed at: $workflow.complete"
    log.info "Execution status: ${ workflow.success ? 'OK' : 'failed' }"
    log.info "Execution duration: $workflow.duration"
}

// Error handler
workflow.onError {
    log.error "Oops... Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}