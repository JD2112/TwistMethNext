process METHYLKIT_ANALYSIS {
    tag "MethylKit on ${design_file}"
    label 'process_high'    

    input:
    path coverage_files
    path design_file
    val compare_str
    val threshold
    path refseq_file    

    output:
    tuple val('methylkit'), path("MethylKit_*.csv"), emit: results
    path "versions.yml", emit: versions
    path "methylkit_log.txt", emit: log

    script:
def args = task.ext.args ?: ''
def coverage_files_str = coverage_files.join(',')
def refseq_param = refseq_file ? "--refseq ${refseq_file}" : ""
"""
echo "Starting MethylKit analysis" > methylkit_log.txt
echo "Coverage files: ${coverage_files_str}" >> methylkit_log.txt
echo "Design file: ${design_file}" >> methylkit_log.txt
echo "Compare string: ${compare_str}" >> methylkit_log.txt
echo "Threshold: ${threshold}" >> methylkit_log.txt
echo "RefSeq file: ${refseq_file}" >> methylkit_log.txt

Rscript ${projectDir}/bin/methylkit_analysis.R \\
    --coverage_files ${coverage_files_str} \\
    --design ${design_file} \\
    --compare ${compare_str} \\
    --output . \\
    --threshold ${threshold} \\
    ${refseq_param} \\
    $args >> methylkit_log.txt 2>&1

cat <<-END_VERSIONS > versions.yml
"${task.process}":
    r-methylkit: \$(Rscript -e "library(methylKit); cat(as.character(packageVersion('methylKit')))")
    r-genomation: \$(Rscript -e "library(genomation); cat(as.character(packageVersion('genomation')))")
    r-org.hs.eg.db: \$(Rscript -e "library(org.Hs.eg.db); cat(as.character(packageVersion('org.Hs.eg.db')))")
END_VERSIONS
"""
}