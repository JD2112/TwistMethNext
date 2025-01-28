#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

// Import subworkflows
include { PREPARE_GENOME } from './subworkflows/prepare_genome'
include { READ_PROCESSING } from './subworkflows/read_processing'
include { BISMARK_ANALYSIS } from './subworkflows/bismark_analysis'
include { QC_REPORTING } from './subworkflows/qc_reporting'
include { DIFFERENTIAL_METHYLATION as EDGER_ANALYSIS } from './subworkflows/differential_methylation'
include { DIFFERENTIAL_METHYLATION as METHYLKIT_ANALYSIS } from './subworkflows/differential_methylation'
include { RESULT_ANALYSIS } from './subworkflows/result_analysis'

// Show help message
if (params.help) {
    def helpMessage = file("$projectDir/conf/USAGE.md").text
    log.info"""
    ===========================================================================
                  Twist DNA Methylation Data Analysis Pipeline
    ===========================================================================
    ${helpMessage}
    """.stripIndent()
    exit 0
}

// Print pipeline info
log.info """
Twist DNA Methylation Data Analysis Pipeline
===============================================
sample sheet : ${params.sample_sheet}
genome       : ${params.genome_fasta}
bismark index: ${params.bismark_index}
outdir       : ${params.outdir}
diff method  : ${params.diff_meth_method}
run both     : ${params.run_both_methods}
"""

def create_sample_channel(sample_sheet) {
    return Channel
        .fromPath(sample_sheet)
        .splitCsv(header:true)
        .map { row -> 
            def meta = [
                id: row.sample_id, 
                single_end: row.containsKey('read2') ? false : true
            ]
            def reads = meta.single_end ? [file(row.read1)] : [file(row.read1), file(row.read2)]
            return [meta, reads]
        }
}

// Main workflow
workflow {
    // Input channels
    log.info "Creating sample channel from: ${params.sample_sheet}"
    ch_samples = create_sample_channel(params.sample_sheet)
    
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
    BISMARK_ANALYSIS(READ_PROCESSING.out.trimmed_reads, ch_index.collect())

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

// Differential Methylation Analysis
    if (params.run_both_methods) {
        edger_results = EDGER_ANALYSIS(
            BISMARK_ANALYSIS.out.coverage_files,
            file(params.sample_sheet),
            params.compare_str,
            params.coverage_threshold,
            'edger'
        )
        
        methylkit_results = METHYLKIT_ANALYSIS(
            BISMARK_ANALYSIS.out.coverage_files,
            file(params.sample_sheet),
            params.compare_str,
            params.coverage_threshold,
            'methylkit'
        )
        
        diff_meth_results = edger_results.results.mix(methylkit_results.results)
    } else {
        diff_meth_results = DIFFERENTIAL_METHYLATION(
            BISMARK_ANALYSIS.out.coverage_files,
            file(params.sample_sheet),
            params.compare_str,
            params.coverage_threshold,
            params.diff_meth_method
        ).results
    }

    // if a GTF annotation file is included for differential analysis
    gtf_file = params.gtf ? file(params.gtf) : file('NO_FILE')

    // Result Analysis
    RESULT_ANALYSIS(
        diff_meth_results,
        params.compare_str,
        params.logfc_cutoff,
        params.pvalue_cutoff,
        params.hyper_color,
        params.hypo_color,
        params.nonsig_color,
        gtf_file,
        params.run_both_methods ? 'both' : params.diff_meth_method
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