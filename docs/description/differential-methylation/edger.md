# EdgeR

**edgeR** is a Bioconductor package primarily used for RNA-seq differential expression analysis but can also handle differential methylation analysis when paired with bisulfite sequencing data. This requires pre-processed methylation data, such as counts of methylated (`M`) and unmethylated (`U`) reads at each cytosine position or region of interest.

```
Rscript $baseDir/bin/edgeR_analysis.R \
        --coverage_files '${coverage_files}' \
        --design "${design_file}" \
        --compare "${compare_str}" \
        --output . \
        --threshold ${coverage_threshold}
```

**options**

* `--coverage_files:` selected from the `bismark_methylation_extractor` files.
* `--design`: selected from the `Sample_sheet.csv`&#x20;
* `--compare`: selected from the `Sample_sheet.csv` .

**Output file**

* Generates `EdgeR_group_<compare_str>.csv` .&#x20;
