# Run command

### Option 1: Without cloning the repo

```
nextflow run https://github.com/JD2112/TwistNext.git \
    -profile singularity \
    --sample_sheet Sample_sheet_twist.csv \
    --genome_fasta /data/reference_genome/hg38/hg38.fa \ 
    --diff_meth_method edger \
    --outdir Results/TwistNext_edgeR 
```

### Option 2: Clone the git repo

```
git clone https://github.com/JD2112/TwistNext.git
cd TwistNext
```

### With the reference genome, --genome\_fasta

```
nextflow run main.nf \
    -profile singularity \
    --sample_sheet Sample_sheet_twist.csv \
    --genome_fasta data/reference_genome/hg38/hg38.fa \ 
    --diff_meth_method edger \
    --outdir /mnt/SD3/test_twistNext_dagTest_edgeR 
```

### With the bisulfite index, --bismark\_index

```
nextflow run main.nf \
    -profile singularity \
    --sample_sheet Sample_sheet_twist.csv \
    --bismark_index /data/reference_genome/hg38/ \ 
    --diff_meth_method edger \
    --outdir /mnt/Results/test_twistNext_dagTest_edgeR 
```

**Use `--diff_meth_method`** **`methylkit` to run MethylKit analysis.**

### Help

```
nextflow run main.nf --help --outdir .
```

