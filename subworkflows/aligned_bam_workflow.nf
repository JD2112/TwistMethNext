// File: subworkflows/aligned_bam_workflow.nf

include { BISMARK_DEDUPLICATE } from '../modules/bismark'
include { BISMARK_METHYLATION_EXTRACTOR } from '../modules/bismark'
include { BISMARK_REPORT } from '../modules/bismark'
include { QUALIMAP } from '../modules/qualimap'

workflow ALIGNED_BAM_WORKFLOW {
    take:
    aligned_bams

    main:
    // Deduplicate alignments
    BISMARK_DEDUPLICATE(aligned_bams)

    // Extract methylation calls
    BISMARK_METHYLATION_EXTRACTOR(BISMARK_DEDUPLICATE.out.deduplicated_bam)

    // Generate sample report
    BISMARK_REPORT(
        BISMARK_DEDUPLICATE.out.deduplicated_bam.join(BISMARK_DEDUPLICATE.out.report).join(BISMARK_METHYLATION_EXTRACTOR.out.report)
    )

    // Alignment QC
    // We need to create a channel with BAM and BAI files for QUALIMAP
    ch_bam_bai = BISMARK_DEDUPLICATE.out.deduplicated_bam.map { meta, bam ->
        def bai = file("${bam}.bai")
        if (!bai.exists()) {
            error "BAI index file not found for ${bam}"
        }
        [meta, bam, bai]
    }
    QUALIMAP(ch_bam_bai)

    emit:
    coverage_files = BISMARK_METHYLATION_EXTRACTOR.out.coverage
    bedgraph_files = BISMARK_METHYLATION_EXTRACTOR.out.bedgraph
    methylation_reports = BISMARK_METHYLATION_EXTRACTOR.out.report
    dedup_reports = BISMARK_DEDUPLICATE.out.report
    bismark_reports = BISMARK_REPORT.out.summary_report
    qualimap_results = QUALIMAP.out.results
    versions = BISMARK_METHYLATION_EXTRACTOR.out.versions.mix(
        BISMARK_DEDUPLICATE.out.versions,
        BISMARK_REPORT.out.versions,
        QUALIMAP.out.versions
    )
}