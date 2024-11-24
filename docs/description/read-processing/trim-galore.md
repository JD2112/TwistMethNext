# Trim galore

**Trim Galore** is a versatile tool for trimming sequencing reads and removing adapter sequences. It’s particularly useful for preparing raw sequencing data for downstream applications like alignment or differential expression/methylation analysis. Trim Galore combines the functionalities of **Cutadapt** and **FastQC** for quality control and trimming.

```
trim_galore --paired --cores $task.cpus $args $reads
```

#### **Common Options**

* `-q <quality>`: Trim low-quality bases from the ends of reads. Default is `20`.
* `--length <min_length>`: Discard reads shorter than the specified length after trimming.
* `--adapter <sequence>`: Specify a custom adapter sequence. By default, Trim Galore auto-detects adapters.
* `--gzip`: Compress the output files into `.gz` format.
* `--fastqc`: Run **FastQC** before and after trimming.
* `--cores <number>`: Use multiple cores for faster processing.

