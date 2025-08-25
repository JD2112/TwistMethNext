# FAQs

# TwistMethylFlow FAQs

## Pipeline Steps

### Generate Reference Genome
??? question "What is the purpose of Generate Reference Genome?"
    This step creates reference genome index files for **Bismark**, which are required for bisulfite read alignment.

### Raw Data QC
??? question "How is raw sequencing data quality assessed?"
    Raw Data QC uses **FastQC** to evaluate per-base quality, GC content, adapter contamination, and other metrics.

### Adapter Trimming
??? question "How should adapters and low-quality bases be handled?"
    **Trim Galore** removes adapters and low-quality bases from reads, ensuring high-quality data for alignment.

### Align Reads
??? question "How are reads aligned to the reference genome?"
    **Bismark (Bowtie2)** aligns bisulfite-treated reads to the reference genome.  
    Accurate alignment is crucial for downstream methylation analysis.

### Deduplicate Removal
??? question "What is deduplicate removal?"
    **Bismark** removes PCR duplicates from aligned reads to prevent bias in methylation calling.

### Sort and Indexing
??? question "How are BAM files prepared after alignment?"
    **Samtools** sorts and indexes deduplicated BAM files for efficient access in downstream analyses.

### Extract Methylation Calls
??? question "How are methylation calls extracted?"
    **Bismark** extracts cytosine methylation calls from aligned reads, generating the input for differential methylation analysis.

### Summary Report
??? question "How is the summary report generated?"
    **Bismark** summarizes alignment statistics and methylation extraction results, including conversion efficiency.

### Alignment QC
??? question "How is alignment quality assessed?"
    **Qualimap** generates metrics such as coverage, mapping quality, and duplication rate for aligned reads.

### QC Reporting
??? question "How are QC reports aggregated?"
    **MultiQC** compiles QC reports from FastQC, Bismark, and Qualimap into a single comprehensive report.

### Differential Methylation
??? question "How is differential methylation analysis performed?"
    **EdgeR** and **MethylKit** identify differentially methylated positions or regions, considering replicates and experimental design.

### Post Processing
??? question "How are results visualized?"
    **ggplot2** creates summary plots like heatmaps, volcano plots, and coverage plots for differential methylation results.

### GO Analysis
??? question "How is Gene Ontology analysis performed?"
    Functional enrichment analysis identifies pathways associated with differentially methylated genes, providing biological interpretation.

---

## Nextflow Workflow Concepts

### General Nextflow
??? question "What is Nextflow?"
    Nextflow is a workflow management system for reproducible and scalable scientific pipelines.  
    It allows users to define tasks and data flow using **processes** and **channels**.

### Processes
??? question "What are processes in Nextflow?"
    Processes encapsulate a task with defined inputs, outputs, and commands.  
    They run independently and can scale across computing resources.

### Channels
??? question "What are channels in Nextflow?"
    Channels are asynchronous data streams that connect processes, passing input and output data between them.

### Outputs
??? question "How do I define outputs in Nextflow?"
    Outputs are declared using the `output` block in processes or workflows.  
    This defines what data is saved for downstream steps or exported from the workflow.

### Parallel Execution
??? question "How does Nextflow handle parallel execution?"
    Nextflow automatically runs independent processes in parallel based on available compute resources, enabling scalable execution.

### Reproducibility
??? question "How does Nextflow ensure reproducibility?"
    Nextflow supports containerization (Docker/Singularity) and environment specification, ensuring the same pipeline produces identical results across systems.

### Workflow Profiles
??? question "What are Nextflow profiles?"
    Profiles allow users to define environment-specific configurations, such as compute clusters, Docker images, and resource limits, for flexible pipeline execution.

### Learning Resources
??? question "Where can I learn more about Nextflow?"
    - [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html)  
    - [Nextflow Tutorials](https://nf-co.re/docs/usage/tutorials/nextflow)  
    - [Hello Nextflow Training](https://training.nextflow.io/2.0/hello_nextflow/)


