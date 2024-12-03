include { BISMARK_ALIGN; BISMARK_DEDUPLICATE; BISMARK_METHYLATION_EXTRACTOR; BISMARK_REPORT } from '../modules/bismark'
include { SAMTOOLS_SORT; SAMTOOLS_INDEX } from '../modules/samtools'
include { QUALIMAP } from '../modules/qualimap'

workflow BISMARK_ANALYSIS {
    take:
    trimmed_reads
    bismark_index

    main:
    ch_versions = Channel.empty()

    // Align reads to reference genome with Bismark
    BISMARK_ALIGN ( trimmed_reads, bismark_index )
    ch_versions = ch_versions.mix(BISMARK_ALIGN.out.versions.first())
    
    BISMARK_DEDUPLICATE(BISMARK_ALIGN.out.bam)

    SAMTOOLS_SORT(BISMARK_DEDUPLICATE.out.deduplicated_bam)
    SAMTOOLS_INDEX(SAMTOOLS_SORT.out.bam)
    
    // Combine sorted BAM and its index
    ch_sorted_indexed_bam = SAMTOOLS_SORT.out.bam.join(SAMTOOLS_INDEX.out.bai)
    
    QUALIMAP(ch_sorted_indexed_bam)

    BISMARK_METHYLATION_EXTRACTOR(BISMARK_DEDUPLICATE.out.deduplicated_bam)
    
    // BISMARK_REPORT(
    //     BISMARK_ALIGN.out.report.join(BISMARK_DEDUPLICATE.out.report).join(BISMARK_METHYLATION_EXTRACTOR.out.report).join(BISMARK_ALIGN.out.report)
    // )
    reports_ch = BISMARK_ALIGN.out.report
        .mix(BISMARK_DEDUPLICATE.out.report)
        .mix(BISMARK_METHYLATION_EXTRACTOR.out.report)
        .groupTuple()

    BISMARK_REPORT(reports_ch)

    emit:
    coverage_files = BISMARK_METHYLATION_EXTRACTOR.out.coverage
    align_reports = BISMARK_ALIGN.out.report
    dedup_reports = BISMARK_DEDUPLICATE.out.report
    methylation_reports = BISMARK_METHYLATION_EXTRACTOR.out.report
    summary_report = BISMARK_REPORT.out.summary_report
    deduplicated_bam     = BISMARK_DEDUPLICATE.out.deduplicated_bam
    sorted_bam           = SAMTOOLS_SORT.out.bam
    bam_index            = SAMTOOLS_INDEX.out.bai
    qualimap_results     = QUALIMAP.out.results
    bam      = BISMARK_ALIGN.out.bam        // channel: [ val(meta), [ bam ] ]
    report   = BISMARK_ALIGN.out.report     // channel: [ val(meta), [ txt ] ]
    unmapped = BISMARK_ALIGN.out.unmapped   // channel: [ val(meta), [ fq.gz ] ]
    versions = ch_versions                  // channel: [ versions.yml ]
}