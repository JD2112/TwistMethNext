This Nextflow pipeline performs comprehensive analysis of Twist NGS DNA Methylation sequencing data, including quality control, alignment, methylation calling, and differential methylation analysis.

Usage:
------
nextflow run main.nf [options]

Options:
--------
--sample_sheet         Path to the sample sheet CSV file (required)
--bismark_index        Path to the Bismark index directory (required)
--outdir               Output directory (default: ./results)
--diff_meth_method     Differential methylation method to use: 'edger' or 'methylkit' (default: edger)
--coverage_threshold   Minimum read coverage to consider a CpG site (default: 10)
--genome               Path to the reference genome FASTA file (required if --bismark_index not provided)
--logfc_cutoff         Differential methylation cut-off for Volcano or MA plot (default: 1.5)
--pvalue_cutoff        Differential methylation P-value cut-off for Volcano or MA plot (default: 0.05)
--hyper_color          Hypermethylation color for Volcano or MA plot (default: red)
--hypo_cutoff         Hypomethylation color for Volcano or MA plot (default: blue)
--nonsig_color        Non-significant color for Volcano or MA plot (default: black)  
--help                 Show this help message and exit

Input:
------
The sample sheet should be a CSV file with the following columns:
sample_id,read1,read2,group
Where:
- sample_id: Unique identifier for the sample
- read1: Path to R1 FASTQ file
- read2: Path to R2 FASTQ file (leave empty for single-end data)
- group: Group identifier for differential methylation analysis

Output:
-------
The pipeline will create several subdirectories in the specified output directory:
- fastqc: FastQC reports for raw reads
- trimmed: Trimmed reads and trimming reports
- bismark_align: Bismark alignment results
- bismark_deduplicate: Deduplicated BAM files
- bismark_methylation_extraction: Methylation call files
- qualimap: Qualimap reports for aligned reads
- multiqc: MultiQC report summarizing QC metrics
- differential_methylation: Differential methylation analysis results
- post_processing: Summary statistics and plots of differential methylation results

Profiles:
---------
The pipeline comes with several pre-configured profiles:
- standard: Local execution with default parameters
- singularity: Executes pipeline using Singularity containers
- conda: Executes pipeline using Conda environments

Example commands:
-----------------
1. Run with singularity profile:
   nextflow run main.nf -profile singularity --sample_sheet samples.csv --bismark_index /path/to/bismark_index --outdir /path/to/results

2. Run with conda profile and methylkit for differential analysis:
   nextflow run main.nf -profile conda --sample_sheet samples.csv --bismark_index /path/to/bismark_index --diff_meth_method methylkit

3. Run with genome FASTA instead of pre-built Bismark index:
   nextflow run main.nf -profile singularity --sample_sheet samples.csv --genome /path/to/genome.fa --outdir /path/to/results

For more information and detailed documentation, please refer to the README.md file.