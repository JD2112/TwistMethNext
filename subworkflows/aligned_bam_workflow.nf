// File: subworkflows/aligned_bam_workflow.nf

include { DEDUPLICATE } from '../modules/bismark/deduplicate'
include { EXTRACT_METHYLATION } from '../modules/bismark/extract_methylation'
include { SAMPLE_REPORT } from '../modules/bismark/sample_report'
include { SUMMARY_REPORT } from '../modules/bismark/summary_report'
include { QUALIMAP } from '../modules/qualimap/qualimap'

workflow ALIGNED_BAM_WORKFLOW {
    take:
    aligned_bams

    main:
    // Deduplicate alignments
    DEDUPLICATE(aligned_bams)

    // Extract methylation calls
    EXTRACT_METHYLATION(DEDUPLICATE.out)

    // Generate sample report
    SAMPLE_REPORT(EXTRACT_METHYLATION.out)

    // Generate summary report
    SUMMARY_REPORT(SAMPLE_REPORT.out.collect())

    // Alignment QC
    QUALIMAP(DEDUPLICATE.out)

    emit:
    coverage_files = EXTRACT_METHYLATION.out.coverage_files
    qc_reports = QUALIMAP.out.collect()
}