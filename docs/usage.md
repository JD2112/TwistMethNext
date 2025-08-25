The pipeline needs to use NextFlow, Singularity/Docker/Conda (for container). Details are given in corresponding pages.

- It is tested locally on Ubuntu server 24.04.2 LTS.
- Tested on HPC (Dardel from PDC, KTH)

## Computational Requirements

### Software/s Requirements

* [Nextflow (>=21.10.3)](https://www.nextflow.io/docs/latest/install.html#install-nextflow)
* [Docker](https://docs.docker.com/engine/install/) or [Singularity](https://singularity-tutorial.github.io/01-installation/) (for containerized execution)
* Java (>=8)

### Hardware Requirements
- RAM: 6 GB - 200 GB
- CPU: min. 12 cores
- Storage: ~2TB for 24 paired-end samples


## Run NextFlow

```
nextflow run JD2112/TwistMethylFlow \
    -profile singularity \
    --sample_sheet Sample_sheet_twist.csv \
    --genome_fasta /data/reference_genome/hg38/hg38.fa \ 
    --run_both_methods \
    --gtf_file /data/Homo_sapiens.GRCh38.104.gtf \
    --refseq_file /data/hg38_RefSeq.bed.gz \
    --outdir Results/TwistMethylFlow_both 
```

??? info "additional options"
    **Run with pre-build reference genome index**
    `--bismark_index /data/reference_genome/hg38/`

    **Run only EdgeR**
    `--diff_meth_method edger`

    **Run only MethylKit**
    `--diff_meth_method methylkit`


??? warning "need annotation files"
    Remember to add annotation files for different differential methylation analysis
    
    `--gtf_file /data/Homo_sapiens.GRCh38.104.gtf` for **MethylKit** 

    `--refseq_file /data/hg38_RefSeq.bed.gz` for **EdgeR**


??? note "Help"
    ```
    nextflow run main.nf --help --outdir .
    ```

## Parameters configuration

User can change the `conf/params.config` or use the `--` flags directly on nextflow command line.

| options | Description |
|--------|-----------------------------------------------------------|
| `--sample_sheet`       | Path to the sample sheet CSV file (required) |                                           
| `--bismark_index`      | Path to the Bismark index directory (required unless `--genome` or `--aligned_bams` is provided) |
| `--genome`             | Path to the reference genome FASTA file (required if `--bismark_index` not provided)| 
| `--aligned_bams`       | Path to aligned BAM files (use this to start from aligned BAM files instead of FASTQ files) |
| `--refseq_file`        | Path to RefSeq file for annotation (reuired to run `both` or `methylkit`)  |
| `--gtf_file`           | Path to GTF file for annotation (reuired to run `both` or `edger`)  |
| `--outdir`             | Output directory (default: ./results) |
| `--diff_meth_method`   | Differential methylation method to use: 'edger' or 'methylkit' (default: edger) | 
| `--run_both_methods`   | Run both edgeR and methylkit for differential methylation analysis (default: false) | 
| `--skip_diff_meth`     | Skip differential methylation analysis (default: false)   | 
| `--coverage_threshold` | Minimum read coverage to consider a CpG site (default: 10) |
| `--logfc_cutoff`       | Differential methylation cut-off for Volcano or MA plot (default: 1.5)    |  
| `--pvalue_cutoff`      | Differential methylation P-value cut-off for Volcano or MA plot (default: 0.05)      | 
| `--hyper_color`        | Hypermethylation color for Volcano or MA plot (default: red) |
| `--hypo_cutoff`        | Hypomethylation color for Volcano or MA plot (default: blue) |
| `--nonsig_color`       | Non-significant color for Volcano or MA plot (default: black) |
| `--compare_str`        | Comparison string for differential analysis (e.g. "Group1-Group2")  |
| `--top_n_genes`        | Number of top differentially methylated genes to report for GOplot (default: 100) |
| `--help`               | Show this help message and exit   | 


??? info "MethylKit specific parameters"
    `--assembly` - user needs to provide the genome assembly version. Default: `hg38`

    `--mc_cores` - if required to run on multiple cores. Default: `1`

    `--diff` - Differential methylation cutoff value. Default: `0.5`

    `--qvalue` - qvalue respect to differential methylation value to identify significant CpGs. Default: `0.05`


??? note "Other parameters configuration"
    1. `conf/resource.config` - for resource settings.
    2. `conf/base.config` - for base settings.
    3. `nextflow.config` - for nextflow run with default setting.
    4. `dag.config` - for DAG configuration settings.

## Input File

Sample sheet (CSV format) with sample information

`Sample_sheet.csv`:

| sample\_id | group   | read1                                 | read2                                 |
| ---------- | ------- | ------------------------------------- | ------------------------------------- |
| SN09       | Healthy | FASTQ/SN09/SL1\_S9\_R1\_001.fastq.gz  | FASTQ/SN09/SL1\_S9\_R2\_001.fastq.gz  |
| SN10       | Disease | FASTQ/SN10/SL2\_S10\_R1\_001.fastq.gz | FASTQ/SN10/SL2\_S10\_R2\_001.fastq.gz |
| SN11       | Healthy | FASTQ/SN11/SL3\_S11\_R1\_001.fastq.gz | FASTQ/SN11/SL3\_S11\_R2\_001.fastq.gz |
| SN12       | Disease | FASTQ/SN12/SL4\_S12\_R1\_001.fastq.gz | FASTQ/SN12/SL4\_S12\_R2\_001.fastq.gz |
| SN13       | Healthy | FASTQ/SN13/SL5\_S13\_R1\_001.fastq.gz | FASTQ/SN13/SL5\_S13\_R2\_001.fastq.gz |
| SN14       | Disease | FASTQ/SN14/SL6\_S14\_R1\_001.fastq.gz | FASTQ/SN14/SL6\_S14\_R2\_001.fastq.gz |

## Results

Here is how the result folder looks like -

```

.
├── annotate_results
├── bismark_align
├── bismark_deduplicate
├── bismark_genome_preparation
├── bismark_methylation_extractor
├── bismark_report
├── edger_analysis
├── fastqc
├── go_analysis
├── multiqc
├── pipeline_info
├── post_processing
├── qualimap
├── samtools_index
├── samtools_sort
└── trim_galore
```

??? info "bismark alignment with bowtie2"
    | Option                 | Functionality                                                               |
    | ---------------------- | --------------------------------------------------------------------------- |
    | `-q`                   | Quiet mode: suppresses detailed output.                                     |
    | `--score-min L,0,-0.2` | Sets a linear minimum score for valid alignments (moderate stringency).     |
    | `--ignore-quals`       | Ignores base quality scores during alignment.                               |
    | `--no-mixed`           | Ensures both ends of paired reads align properly; no single-end alignments. |
    | `--no-discordant`      | Prevents discordant alignments; enforces proper orientation and distance.   |
    | `--dovetail`           | Allows overlapping or extended alignments in paired-end reads.              |
    | `--maxins 500`         | Sets the maximum allowed distance between paired-end reads to 500 bases.    |