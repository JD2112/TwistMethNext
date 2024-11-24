# Description

1. **READ\_PROCESSING:** Checks the quality of raw sequencing data and trims low-quality bases and adapters to improve downstream analysis.
2. **BISMARK\_ANALYSIS:** Aligns bisulfite-converted reads to a reference genome, identifies and removes PCR duplicates, sorts and indexes the aligned reads, performs quality control on alignments, and extracts methylation information from the aligned reads.
3. **QC\_REPORTING:** Compiles quality control metrics from various steps into a comprehensive report for easy interpretation.
4. **DIFFERENTIAL\_METHYLATION:**
   * _EDGER\_ANALYSIS:_
     * Takes coverage files, a design file, and comparison information as input.
     * Performs differential methylation analysis using the EdgeR Bioconductor package.
     * Outputs CSV files with differential methylation results for each group comparison. _METHYLKIT\_ANALYSIS:_
     * Takes coverage files, a design file, and comparison information as input.
     * Performs differential methylation analysis using the EdgeR Bioconductor package.
     * Outputs CSV files with differential methylation results for each group comparison.
5. **POST\_PROCESSING:**
   * Reads the EdgeR results and generates:
   * Summary statistics (total DMRs, hyper/hypomethylated regions, significant DMRs)
   * Volcano plot (visualizing fold change vs. significance)
   * MA plot (visualizing intensity vs. fold change)
   * Outputs summary statistics CSV, visualization plots, and version information.
