# Quality Mapping

The main module for assessing alignment quality is `qualimap bamqc`.

```bash
qualimap bamqc \
    -bam <input.bam> \
    -outdir <output_directory> \
    -outformat <html> \
    --java-mem-size
```

* **Options:**
  * `-bam <input.bam>`: Path to the aligned BAM file (e.g., deduplicated BAM file).
  * `-outdir <output_directory>`: Directory for output reports.
  * `-outformat <pdf|html>`: Choose the output format for the report.
*   **Output of Qualimap BAMQC**

    The output includes:

    1. **General Alignment Statistics**:
       * Total number of reads.
       * Percentage of mapped reads.
       * Percentage of properly paired reads (for paired-end data).
    2. **Coverage Statistics**:
       * Mean coverage depth.
       * Percentage of the genome covered at varying depths (e.g., 1x, 5x, 10x).
    3. **Insert Size Distribution** (for paired-end reads):
       * Provides insights into library preparation and sequencing quality.
    4. **GC Content Distribution**:
       * Checks for bias in GC content distribution compared to expected values.
    5. **Read Quality Metrics**:
       * Distribution of mapping quality scores.
