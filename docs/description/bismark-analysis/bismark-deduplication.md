# Bismark Deduplication

This step removes duplicate reads to avoid overestimating methylation levels.

```
deduplicate_bismark ${paired_end} $args --bam $bam
```

* **Key options:**
  * `args` options use all arguments from bismark deduplicate command.
  * `--paired`: Use this for paired-end data. Remove for single-end reads.
  * `--bam`: Specifies the input BAM file, generated from `bismark alignment`
* **Output:**&#x20;
  * Generates a deduplicated `.bam` file.
  * Produces `deduplicated_report.txt` file.
