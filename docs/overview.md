# Overview

TwistMethNext integrates various tools and custom scripts to provide a comprehensive analysis workflow for Twist NGS Methylation data.

## Features

| Step                       | Tool/Software                                                                 |
|----------------------------|------------------------------------------------------------------------------|
| Generate Reference Genome  | [Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)       |
| Raw Data QC                | [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)         |
| Adapter Trimming           | [Trim Galore](https://www.bioinformatics.babraham.ac.uk/projects/trim_galore/) |
| Align Reads                | [Bismark (bowtie2)](https://www.bioinformatics.babraham.ac.uk/projects/bismark/) |
| Deduplicate Alignments     | [Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)       |
| Sort and Indexing          | [Samtools](http://www.htslib.org/)                                           |
| Extract Methylation Calls  | [Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)       |
| Sample Report              | [Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)       |
| Summary Report             | [Bismark](https://www.bioinformatics.babraham.ac.uk/projects/bismark/)       |
| Alignment QC               | [Qualimap](http://qualimap.conesalab.org/)                                   |
| QC Reporting               | [MultiQC](https://multiqc.info/)                                             |
| Differential Methylation   | [EdgeR](https://bioconductor.org/packages/release/bioc/html/edgeR.html), [MethylKit](https://bioconductor.org/packages/release/bioc/html/methylKit.html) |
| Post Processing            | [ggplot2](https://ggplot2.tidyverse.org/)                                    |
| GO Analysis                | [Gene Ontology](http://geneontology.org/)                                    |

For more details on each step, refer to the [Description](./description/read-processing/README.md) section.
