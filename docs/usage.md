The pipeline needs to use NextFlow, Singularity/Docker/Conda (for container). Details are given in corresponding pages.

- It is tested locally on Ubuntu server 24.04.2 LTS.
- Tested on HPC (Dardel from PDC, KTH)

## Computational Requirements

### Software/s Requirements

* [Nextflow (>=21.10.3)](https://www.nextflow.io/docs/latest/install.html#install-nextflow)
* [Docker](https://docs.docker.com/engine/install/) or [Singularity](https://singularity-tutorial.github.io/01-installation/) (for containerized execution)
* Java (>=8)

### Hardware Requirements
- RAM: 12 GB - 200 GB
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
| `-r`                   | Run with `--tag` version from GitHub (e.g, `-r 1.0.5`)   | 


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

| sample_id | group | read1                                                  | read2                                                  |
|-----------|-------|--------------------------------------------------------|--------------------------------------------------------|
| 12A       | VD    | FASTQ/12A_S9_L001_R1_001.fastq.gz  | FASTQ/12A_S9_L001_R2_001.fastq.gz  |
| 13A       | CS    | FASTQ/13A_S11_L001_R1_001.fastq.gz | FASTQ/13A_S11_L001_R2_001.fastq.gz |
| 1A        | CS    | FASTQ/1A_S1_L001_R1_001.fastq.gz   | FASTQ/1A_S1_L001_R2_001.fastq.gz   |
| 20A       | VD    | FASTQ/20A_S13_L001_R1_001.fastq.gz | FASTQ/20A_S13_L001_R2_001.fastq.gz |
| 21A       | VD    | FASTQ/21A_S15_L001_R1_001.fastq.gz | FASTQ/21A_S15_L001_R2_001.fastq.gz |
| 22A       | VD    | FASTQ/22A_S17_L001_R1_001.fastq.gz | FASTQ/22A_S17_L001_R2_001.fastq.gz |
| 23A       | VD    | FASTQ/23A_S19_L001_R1_001.fastq.gz | FASTQ/23A_S19_L001_R2_001.fastq.gz |
| 25A       | CS    | FASTQ/25A_S21_L001_R1_001.fastq.gz | FASTQ/25A_S21_L001_R2_001.fastq.gz |
| 26A       | VD    | FASTQ/26A_S23_L001_R1_001.fastq.gz | FASTQ/26A_S23_L001_R2_001.fastq.gz |
| 2A        | CS    | FASTQ/2A_S3_L001_R1_001.fastq.gz   | FASTQ/2A_S3_L001_R2_001.fastq.gz   |
| 3A        | VD    | FASTQ/3A_S5_L001_R1_001.fastq.gz   | FASTQ/3A_S5_L001_R2_001.fastq.gz   |
| 5A        | CS    | FASTQ/5A_S7_L001_R1_001.fastq.gz   | FASTQ/5A_S7_L001_R2_001.fastq.gz   |

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

??? tip "SLURM script to run the sample data on HPC cluster"
    Here is an example SLURM script to run the pipeline on a HPC cluster with Singularity:

    ```bash
    #!/bin/bash    
    #SBATCH --job-name=TMF_test
    #SBATCH --partition=standard
    #SBATCH --nodes=2
    #SBATCH --mem=96G
    #SBATCH --time=3-00:00:00  # 3 days (D-HH:MM:SS)
    #SBATCH --cpus-per-task=16
    #SBATCH --output=tmf_test%j.out
    #SBATCH --error=tmf_test%j.err
    #SBATCH --mail-user=jyotirmoy.das@liu.se  
    #SBATCH --mail-type=BEGIN,END,FAIL 

    set -e

    # Load modules
    module load singularity-4.1.1
    module load nextflow-25.04.0

    # Set Nextflow and Singularity directories
    export NXF_HOME=<Your Nextflow home directory, e.g., /home/username/.nextflow >
    export NXF_WORK=<Your Nextflow home directory, e.g., /home/username/nextflow_work>
    export SINGULARITY_CACHEDIR=<Your Singularity cache directory, e.g., /home/username/singularity_cache>

    # Ensure directories exist
    mkdir -p $NXF_WORK $SINGULARITY_CACHEDIR


    # Run Nextflow
    nextflow run JD2112/TwistMethylFlow \
        -profile singularity \
        --sample_sheet samplesheet.csv \
        --genome_fasta <ABSOLUTE\ PATH\ TO\>/reference_genome/hg19.fa \
        --run_both_methods \
        --refseq_file hg19_RefSeq.bed.gz \
        --gtf_file Homo_sapiens.GRCh37.75.formatted.gtf \
        --outdir TMF_250519 \
        -with-dag
    ```