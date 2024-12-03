---
cover: .gitbook/assets/logo.png
coverY: 0
layout:
  cover:
    visible: true
    size: hero
  title:
    visible: true
  description:
    visible: true
  tableOfContents:
    visible: true
  outline:
    visible: true
  pagination:
    visible: true
---

# Overview

This Nextflow pipeline is designed for the analysis of Twist NGS Methylation data, including quality control, alignment, methylation calling, differential methylation analysis, and post-processing. It integrates various tools and custom scripts to provide a comprehensive analysis workflow.



### Features

| Step                                       | Workflow                                                                                                                                                    |
| ------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Generate Reference Genome Index (optional) | [Bismark](http://felixkrueger.github.io/Bismark/bismark/genome_preparation/)                                                                                |
| Raw data QC                                | [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)                                                                                        |
| Adapter sequence trimming                  | [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/)                                                                              |
| Align Reads                                | [Bismark (bowtie2)](http://felixkrueger.github.io/Bismark/bismark/alignment/)                                                                               |
| Deduplicate Alignments                     | [Bismark](http://felixkrueger.github.io/Bismark/bismark/deduplication/)                                                                                     |
| Sort and indexing                          | [Samtools](http://www.htslib.org)                                                                                                                           |
| Extract Methylation Calls                  | [Bismark](http://felixkrueger.github.io/Bismark/bismark/methylation_extraction/)                                                                            |
| Sample Report                              | [Bismark](http://felixkrueger.github.io/Bismark/bismark/processing_report/)                                                                                 |
| Summary Report                             | [Bismark](http://felixkrueger.github.io/Bismark/bismark/summary_report/)                                                                                    |
| Alignment QC                               | [Qualimap](http://qualimap.conesalab.org)                                                                                                                   |
| QC Reporting                               | [MultiQC](https://seqera.io/multiqc/)                                                                                                                       |
| Differential Methylation Analysis          | [EdgeR](https://bioconductor.org/packages/release/bioc/html/edgeR.html)/[MethylKit](https://www.bioconductor.org/packages/release/bioc/html/methylKit.html) |
| Post processing                            | [ggplot2](https://ggplot2.tidyverse.org)                                                                                                                    |
| GO analysis                                | [Gene Ontology](https://geneontology.org)                                                                                                                   |
