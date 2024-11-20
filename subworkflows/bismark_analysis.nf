include { BISMARK_ALIGN; BISMARK_DEDUPLICATE; BISMARK_METHYLATION_EXTRACTOR; BISMARK_REPORT } from '../modules/bismark'
include { QUALIMAP } from '../modules/qualimap'

workflow BISMARK_ANALYSIS {
    take:
    trimmed_reads
    bismark_index

    main:
    BISMARK_ALIGN(trimmed_reads, bismark_index)
    
    // Add QUALIMAP after BISMARK_ALIGN
    QUALIMAP(BISMARK_ALIGN.out.bam)
    
    BISMARK_DEDUPLICATE(BISMARK_ALIGN.out.bam)
    BISMARK_METHYLATION_EXTRACTOR(BISMARK_DEDUPLICATE.out.deduplicated_bam)
    BISMARK_REPORT(BISMARK_ALIGN.out.report.mix(
        BISMARK_DEDUPLICATE.out.report,
        BISMARK_METHYLATION_EXTRACTOR.out.report
    ).collect())

    emit:
    coverage_files = BISMARK_METHYLATION_EXTRACTOR.out.coverage
    align_reports = BISMARK_ALIGN.out.report
    dedup_reports = BISMARK_DEDUPLICATE.out.report
    methylation_reports = BISMARK_METHYLATION_EXTRACTOR.out.report
    summary_report = BISMARK_REPORT.out.summary_report
    qualimap_results = QUALIMAP.out.results
}