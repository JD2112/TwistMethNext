include { MULTIQC } from '../modules/multiqc'

workflow QC_REPORTING {
    take:
    fastqc_reports
    trimming_reports
    align_reports
    dedup_reports
    methylation_reports
    summary_report
    qualimap_results

    main:
    MULTIQC(
        fastqc_reports.mix(
            trimming_reports,
            align_reports,
            dedup_reports,
            methylation_reports,
            summary_report,
            qualimap_results
        ).collect()
    )

    emit:
    multiqc_report = MULTIQC.out.report
}