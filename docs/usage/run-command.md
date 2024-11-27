# Run command

```
nextflow run main.nf \
    -profile singularity \
    --sample_sheet Sample_sheet_twist.csv \
    --genome_fasta data/reference_genome/hg38/hg38.fa \ 
    --diff_meth_method edger \
    --outdir /mnt/SD3/test_twistNext_dagTest_edgeR 
```

### Help

```
nextflow run main.nf --help --outdir .
```

