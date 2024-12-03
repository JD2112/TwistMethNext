# Genome preparation

Bismark needs to prepare the bisulfite index for the genome.

* In the current pipeline, user can provide the `genome.fasta` and the pipeline can index it.
* Optinally, user can provide the index files directly, and the pipeline will use it without indexing the genome again.

#### **Key Options**

* `--verbose`: Prints detailed output during the indexing process.
* `--parallel <threads>`: Uses multiple threads to speed up genome preparation.
* `--bowtie2`: Specifies that **Bowtie2** will be used for alignment (default option in most versions).
* `--path_to_bowtie <path>`: Specifies the path to the Bowtie installation if not in your `PATH`.

**Example with Options:**

```bash
bismark_genome_preparation --bowtie2 --parallel 4 <genome.fasta>
```

***

#### **4. Output**

After successful completion, Bismark generates a bisulfite-converted genome in two orientations (C->T and G->A) along with the Bowtie/Bowtie2 indices.

Output directory structure:

```plaintext
your_path_to_reference/
    Bisulfite_Genome/
        CT_conversion/
        GA_conversion/
        genome.1.bt2
        genome.2.bt2
        ...
```
