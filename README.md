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

[![DOI](https://zenodo.org/badge/490592846.svg)](https://doi.org/10.5281/zenodo.11105016)
[![GitBook Docs](https://img.shields.io/badge/docs-GitBook-blue?logo=gitbook)](https://jyotirmoys-organization.gitbook.io/twistnext)
[![GitHub Invite Collaborators](https://img.shields.io/badge/Invite-Collaborators-blue?style=for-the-badge&logo=github)](https://github.com/JD2112/TwistNext/settings/access)

## Overview

This Nextflow pipeline is designed for the analysis of Twist NGS Methylation data, including quality control, alignment, methylation calling, differential methylation analysis, and post-processing. It integrates various tools and custom scripts to provide a comprehensive analysis workflow.

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
Find the details on the [manual](https://jyotirmoys-organization.gitbook.io/twistnext)

## Credits
- Main Author: 
    - Jyotirmoy Das ([@JD2112](https://github.com/JD2112))

- Collaborators: ()

## Citation

Das, J. (2024). TwistNext (v1.0.0). Zenodo. [https://doi.org/10.5281/zenodo.11105016](https://doi.org/10.5281/zenodo.11105016)

## HELP/FAQ/Troubleshooting

Please check the [manual](https://jyotirmoys-organization.gitbook.io/twistnext) for details.

Please create [issues](https://github.com/JD2112/TwistNext/issues) on github.

## License(s)

[GNU-3 public license](https://github.com/JD2112/TwistNext/blob/v1.0.3/LICENSE).

## Acknowledgement

We would like to acknowledge the **Core Facility, Faculty of Medicine and Health Sciences, Linköping University, Linköping, Sweden** and **Clinical Genomics Linköping, Science for Life Laboratory, Sweden** for their support.
