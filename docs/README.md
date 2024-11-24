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
