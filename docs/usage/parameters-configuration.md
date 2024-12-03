# Parameters configuration

## Required

* `--sample_sheet` (required) - provide the `sample_sheet.csv` same format as described above.
* `--genome_fasta` or `--bismark_index` (required) - provide the full path of the reference genome sequence (`.fa` or `.fasta`) or if the index files are already available, use the full path of the `bismark` index file instead of `genome_fasta`.
* `--outdir` (required) - full path of the output directory. Default is `${baseDir}/process_name`

## Optional

User can change it directly to `conf/params.config` or add to the `nextflow run` command.

* `--diff_meth_method` (optional) - user can select between `EdgeR` analysis or `MethylKit` analysis for group-wise differential methylation calculation.
* `--compare_str` (optional) - provide the string such as `Healthy_vs_Disease` (for pair-wise comparisons) or `all` (for multiple pair-wise comparisons). By default, the pipeline will calculate `all` from the `Sample_sheet.csv`.
* `--coverage_threshold` (optional) - for `EdgeR` calculation, user can set their own `coverage_threshold`. Default is `10`.
* `--multiqc_config` (optional) - user can configure `MultiQC` run.
* `--multiqc_title` (optional) - user can provide `MultiQC` title.
* `--post_processing` (optional) - Default is `true` to run the post-processing steps. Can be set `false` to avoid it.
* `--qualimap_args` (optional) - can use [qualimap arguments](http://qualimap.conesalab.org/doc_html/command_line.html).

**Differential methylation analysis (figure specs, post-processing and GO analysis)**

* `--logfc_cutoff` (optional) - to generate the MA plot, Volcano plot and gene ontology analysis, the **mean median difference (mmd)** or here as **logfc.** Default is **1.5**.
* `--pvalue_cutoff` (optional) - for MA plot, volcano plot and calculating the significant differentially methylated CpGs from the analysis, the p-value cutoff is applied. The default is **0.05.** This cutoff is also applied to estimate the gene ontology analysis
* `--hyper_color` (optional) - for MA and volcano plot hypermethylation CpGs colors. Default is **red.**
* `--hypo_color` (optional) - for MA and Volcano plot hypomethylated CpGs colors. Default is **blue.**&#x20;
* `--nonsig_color` (optional) - for non-significant DMCs (based on the pvalue cutoff). Default is **black.**
* `--top_n`(optional) - for GO analysis. To peak top `n` (Default: 100) differentially methylated CpGs from the EdgeR/methylKit results.
