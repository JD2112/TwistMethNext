![](artworks/logo.png)

[![DOI](https://zenodo.org/badge/490592846.svg)](https://doi.org/10.5281/zenodo.11105016)

## Overview

This Nextflow pipeline is designed for the analysis of Twist NGS Methylation data, including quality control, alignment, methylation calling, differential methylation analysis, and post-processing. It integrates various tools and custom scripts to provide a comprehensive analysis workflow.

## Highlights
Here's a comprehensive overview of your methylation sequencing analysis pipeline:

1. READ_PROCESSING:
    - FASTQC: Performs quality control checks on raw sequence data.
    - TRIM_GALORE: Trims adapters and low-quality bases from the reads.

2. BISMARK_ANALYSIS:
    - BISMARK_ALIGN: Aligns bisulfite-treated reads to a reference genome.
    - BISMARK_DEDUPLICATE: Removes PCR duplicates from the aligned reads.
    - SAMTOOLS_SORT: Sorts the aligned and deduplicated BAM files.
    - SAMTOOLS_INDEX: Indexes the sorted BAM files for efficient access.
    - QUALIMAP: Generates quality control metrics for the aligned reads.
    - BISMARK_METHYLATION_EXTRACTOR: Extracts methylation calls from the aligned reads.
    - BISMARK_REPORT: Generates a summary report of the Bismark alignment and methylation extraction.

3. QC_REPORTING:
    - MULTIQC: Aggregates quality control reports from various steps into a single report.

4. DIFFERENTIAL_METHYLATION:
    - EDGER_ANALYSIS: Performs differential methylation analysis using the EdgeR package.
    - METHYLKIT_ANALYSIS: Performs differential methylation analysis using the methylKit package.

5. POST_PROCESSING:
    Generates summary statistics and visualizations of the differential methylation results.

## Detailed description of each main step:

1. **READ_PROCESSING:** Checks the quality of raw sequencing data and trims low-quality bases and adapters to improve downstream analysis.

2. **BISMARK_ANALYSIS:** Aligns bisulfite-converted reads to a reference genome, identifies and removes PCR duplicates, sorts and indexes the aligned reads, performs quality control on alignments, and extracts methylation information from the aligned reads.

3. **QC_REPORTING:** Compiles quality control metrics from various steps into a comprehensive report for easy interpretation.

4. **DIFFERENTIAL_METHYLATION:**
    - *EDGER_ANALYSIS:* 
        - Takes coverage files, a design file, and comparison information as input.
        - Performs differential methylation analysis using the EdgeR Bioconductor package.
        - Outputs CSV files with differential methylation results for each group comparison.
    *METHYLKIT_ANALYSIS:*
        - Takes coverage files, a design file, and comparison information as input.
        - Performs differential methylation analysis using the EdgeR Bioconductor package.
        - Outputs CSV files with differential methylation results for each group comparison.

5. **POST_PROCESSING:**
    - Reads the EdgeR results and generates:
    - Summary statistics (total DMRs, hyper/hypomethylated regions, significant DMRs)
    - Volcano plot (visualizing fold change vs. significance)
    - MA plot (visualizing intensity vs. fold change)
    - Outputs summary statistics CSV, visualization plots, and version information.

## Features

| Step                                       | Workflow          |
| ------------------------------------------ | ----------------- |
| Generate Reference Genome Index (optional) | Bismark           |
| Raw data QC                                | FastQC            |
| Adapter sequence trimming                  | Trim Galore       |
| Align Reads                                | Bismark (bowtie2) |
| Deduplicate Alignments                     | Bismark           |
| Sort and indexing                          | Samtools          |
| Extract Methylation Calls                  | Bismark           |
| Sample Report                              | Bismark           |
| Summary Report                             | Bismark           |
| Alignment QC                               | Qualimap          |
| QC Reporting                               | MultiQC           |
| Differential Methylation Analysis          | EdgeR/MethylKit   |
| Post processing                            | ggplot2           |

## Pipeline Schema
![](artworks/workflow_dag_color.png)

## Requirements

- [Nextflow (>=21.10.3)](https://www.nextflow.io/docs/latest/install.html#install-nextflow)
- [Docker](https://docs.docker.com/engine/install/) or [Singularity](https://singularity-tutorial.github.io/01-installation/) (for containerized execution)
- Java (>=8)

## Usage

```
nextflow run main.nf \
    -profile singularity \
    --sample_sheet Sample_sheet_twist.csv \
    --genome_fasta /mnt/SD2/Jyotirmoys/JD/Scripts/MyScripts/JDCo/DNAm/DNAm-NF2/data/reference_genome/hg38/hg38.fa \ 
    --diff_meth_method edger \
    --outdir /mnt/SD3/test_twistNext_dagTest_edgeR 

```

## HELP

```
nextflow run main.nf --help --outdir .
```

## Input
- Sample sheet (CSV format) with sample information

`Sample_sheet.csv`:

|sample_id  |group   |read1                                                            |read2                                                            |
|-----------|--------|-----------------------------------------------------------------|-----------------------------------------------------------------|
|SN09|Healthy |FASTQ/SN09/SL1_S9_R1_001.fastq.gz |FASTQ/SN09/SL1_S9_R2_001.fastq.gz |
|SN10|Disease|FASTQ/SN10/SL2_S10_R1_001.fastq.gz|FASTQ/SN10/SL2_S10_R2_001.fastq.gz|
|SN11|Healthy |FASTQ/SN11/SL3_S11_R1_001.fastq.gz|FASTQ/SN11/SL3_S11_R2_001.fastq.gz|
|SN12|Disease|FASTQ/SN12/SL4_S12_R1_001.fastq.gz|FASTQ/SN12/SL4_S12_R2_001.fastq.gz|
|SN13|Healthy |FASTQ/SN13/SL5_S13_R1_001.fastq.gz|FASTQ/SN13/SL5_S13_R2_001.fastq.gz|
|SN14|Disease|FASTQ/SN14/SL6_S14_R1_001.fastq.gz|FASTQ/SN14/SL6_S14_R2_001.fastq.gz|


## Parameters configuration
### Required parameters

- `--sample_sheet` (required) - provide the `sample_sheet.csv` same format as described above.
- `--genome_fasta` or `--bismark_index` (required) - provide the full path of the reference genome sequence (`.fa` or `.fasta`) or if the index files are already available, use the full path of the `bismark` index file instead of `genome_fasta`.


### Optional parameters
User can change it directly to `conf/params.config` or add to the `nextflow run` command.

- `--outdir` (optional) - full path of the output directory. Default is `${baseDir}/process_name`.
- `--diff_meth_method` (optional) - user can select between `EdgeR` analysis or `MethylKit` analysis for group-wise differential methylation calculation.
- `--compare_str` (optional) - provide the string such as `Healthy_vs_Disease` (for pair-wise comparisons) or `all` (for multiple pair-wise comparisons). By default, the pipeline will calculate `all` from the `Sample_sheet.csv`.
- `--coverage_threshold` (optional) - for `EdgeR` calculation, user can set their own `coverage_threshold`. Default is `10`.
- `--multiqc_config` (optional) - user can configure `MultiQC` run.
- `--multiqc_title` (optional) - user can provide `MultiQC` title.
- `--post_processing` (optional) - <boolean> Default is `true` to run the post-processing steps. Can be set `false` to avoid it.
- `--qualimap_args` (optional) - can use [qualimap arguments](from http://qualimap.conesalab.org/doc_html/command_line.html)

### Default Bismark Alignment with Bowtie2

| Option              | Functionality                                                                 |
|---------------------|-------------------------------------------------------------------------------|
| `-q`                | Quiet mode: suppresses detailed output.                                      |
| `--score-min L,0,-0.2` | Sets a linear minimum score for valid alignments (moderate stringency).       |
| `--ignore-quals`    | Ignores base quality scores during alignment.                                |
| `--no-mixed`        | Ensures both ends of paired reads align properly; no single-end alignments.  |
| `--no-discordant`   | Prevents discordant alignments; enforces proper orientation and distance.    |
| `--dovetail`        | Allows overlapping or extended alignments in paired-end reads.              |
| `--maxins 500`      | Sets the maximum allowed distance between paired-end reads to 500 bases.    |


**NOTE:**
1. `conf/resource.config` - for resource settings.
2. `conf/base.config` - for base settings.
3. `nextflow.config` - for nextflow run with default setting.

## Credits
- Main Author: 
    - Jyotirmoy Das ([@JD2112](https://github.com/JD2112))
- Maintainers:

- Contributions:

## Citation

Das, J. (2024). TwistNext (v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.14204261

## HELP/FAQ/Troubleshooting

Please check the manual for details.

Please create issues on github.

## License(s)

GNU-3 public license - click to read details.

## Acknowledgement

We would like to acknowledge the **Core Facility, Faculty of Medicine and Health Sciences, Linköping University, Linköping, Sweden** and **Clinical Genomics Linköping, Science for Life Laboratory, Sweden** for their support.
