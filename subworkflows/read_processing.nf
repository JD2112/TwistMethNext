include { FASTQC } from '../modules/fastqc'
include { TRIM_GALORE } from '../modules/trim_galore'

workflow READ_PROCESSING {
    take:
    reads

    main:
    FASTQC(reads)
    TRIM_GALORE(reads)

    emit:
    trimmed_reads = TRIM_GALORE.out.trimmed_reads
    fastqc_reports = FASTQC.out.reports
    trimming_reports = TRIM_GALORE.out.reports
}