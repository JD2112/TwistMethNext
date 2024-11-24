# Bismark Methylation Extractor

Extract methylation data from deduplicated BAM files.

```bash
bismark_methylation_extractor \
    --bedGraph --gzip \
    -o <output_directory> <deduplicated.bam>
```

* **Key options:**
  * `--bedGraph`: Generates bedGraph file
  * `--gzip`: Compresses the output files.
* **Output:**&#x20;
  * Generates `.bismark.cov.gz` files and methylation call data in CpG, CHG, and CHH contexts.
  * Generates `bedGraph.gz` file.
  * Also generates `splitting_report.txt` file.
