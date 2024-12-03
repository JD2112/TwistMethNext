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
    def flattenChannel = { it ->
        it.flatMap { item ->
            if (item instanceof Map) {
                item.values().flatten()
            } else if (item instanceof Collection) {
                item.flatten()
            } else {
                [item]
            }
        }
    }
    
    def extractFile = { item ->
        if (item instanceof Map && item.containsKey('file')) {
            return item.file
        } else if (item instanceof Path || item instanceof File) {
            return item
        } else {
            return null
        }
    }
    
    ch_multiqc_files = Channel.empty()
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(fastqc_reports).map(extractFile))
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(trimming_reports).map(extractFile))
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(align_reports).map(extractFile))
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(dedup_reports).map(extractFile))
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(methylation_reports).map(extractFile))
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(summary_report).map(extractFile))
    ch_multiqc_files = ch_multiqc_files.mix(flattenChannel(qualimap_results).map(extractFile))

    ch_multiqc_files = ch_multiqc_files.filter { it != null }

    MULTIQC(ch_multiqc_files.collect())

    emit:
    multiqc_report = MULTIQC.out.report
    multiqc_log = MULTIQC.out.log
}