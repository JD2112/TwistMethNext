# Bismark Alignment



This step aligns bisulfite-treated sequencing reads to a reference genome.

```
bismark --genome <path_to_reference_genome> -1 <reads_R1.fq> -2 <reads_R2.fq> -o <output_directory>
```

* **Key options:**
  * `--genome`: Path to the reference genome directory preprocessed with `bismark_genome_preparation`.
  * `-1` and `-2`: Specify paired-end reads. Use `-U` for single-end reads.
  * `-o`: Output directory for alignment files.
* **Output:**&#x20;
  * Produces `.bam`  alignment files.
  * Produces `.report.txt`  and
  * `unmapped_reads.fq.gz` file.
