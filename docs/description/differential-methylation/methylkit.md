# MethylKit

**MethylKit** is an R package designed for analyzing bisulfite sequencing data, particularly for differential methylation analysis. It supports genome-wide methylation data and is ideal for CpG, CHH, and CHG methylation studies.

```
Rscript $baseDir/bin/run_methylkit.R \
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

* Generates `Methylkit_group_<compare_str>.csv` .&#x20;
