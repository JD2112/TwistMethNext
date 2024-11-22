process BISMARK_GENOME_PREPARATION {
    tag "$genome"
    label 'process_high'

    conda "bioconda::bismark=0.23.0"
    container "quay.io/biocontainers/bismark:0.23.0--hdfd78af_1"

    input:
    path genome

    output:
    path "bismark_index", emit: index
    path "versions.yml", emit: versions

    script:
    """
    mkdir -p genome_dir
    mv $genome genome_dir/
    bismark_genome_preparation --verbose genome_dir
    mkdir -p bismark_index
    mv genome_dir/* bismark_index/
    
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: \$( bismark --version | sed -e "s/Bismark Version: v//g" )
    END_VERSIONS
    """
}

// process BISMARK_ALIGN {
//     tag "$meta.id"
//     label 'process_high'

//     conda "bioconda::bismark=0.23.0"
//     container "quay.io/biocontainers/bismark:0.23.0--hdfd78af_1"

//     input:
//     tuple val(meta), path(reads)
//     path index

//     output:
//     tuple val(meta), path("*.bam"), emit: bam
//     tuple val(meta), path("*_report.txt"), emit: report
//     path "versions.yml", emit: versions

//     script:
//     def args = task.ext.args ?: ''
//     def prefix = task.ext.prefix ?: "${meta.id}"
//     """
//     echo "Copying index directory..."
//     mkdir -p copied_index
//     cp -rL $index/* ./copied_index/

//     echo "Contents of copied index directory:"
//     ls -lR ./copied_index

//     echo "Searching for genome file:"
//     genome_file=\$(find ./copied_index -name "*.fa" -o -name "*.fasta" | head -n 1)
    
//     if [ -z "\$genome_file" ]; then
//         echo "No genome file found in index directory"
//         exit 1
//     else
//         echo "Found genome file: \$genome_file"
//         echo "First few lines of genome file:"
//         head -n 5 "\$genome_file"
//     fi

//     bismark --genome ./copied_index \\
//         $args \\
//         -1 ${reads[0]} \\
//         -2 ${reads[1]} \\
//         --basename $prefix

//     mv ${prefix}_pe.bam ${prefix}.bam

//     cat <<-END_VERSIONS > versions.yml
//     "${task.process}":
//         bismark: \$( bismark --version | sed -e "s/Bismark Version: v//g" )
//     END_VERSIONS
//     """
// }

// In modules/bismark.nf
process BISMARK_ALIGN {
    tag "$meta.id"
    label 'process_bismark_align'

    // conda "bioconda::bismark=0.23.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/bismark:0.23.0--hdfd78af_1' :
    //     'quay.io/biocontainers/bismark:0.23.0--hdfd78af_1' }"

    input:
    tuple val(meta), path(reads)
    path index

    output:
    tuple val(meta), path("*.bam"), emit: bam
    tuple val(meta), path("*report.txt"), emit: report
    tuple val(meta), path("*unmapped_reads.fq.gz"), optional:true, emit: unmapped
    path "versions.yml", emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def single_end = meta.single_end ? true : false
    def reads_command = single_end ? "-s $reads" : "-1 ${reads[0]} -2 ${reads[1]}"
    
    """
    echo "Debug: Starting BISMARK_ALIGN for ${meta.id}"
    echo "Debug: Single-end: ${single_end}"
    echo "Debug: Reads: ${reads}"
    echo "Debug: Index: ${index}"
    echo "Debug: Prefix: ${prefix}"
    echo "Debug: CPUs: ${task.cpus}"
    echo "Debug: Memory: ${task.memory}"

    bismark \\
        $args \\
        --genome $index \\
        -o . \\
        --basename $prefix \\
        -p ${task.cpus} \\
        $reads_command

    echo "Debug: BISMARK_ALIGN completed for ${meta.id}"


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: \$(bismark --version | sed -e "s/Bismark Version: v//g")
    END_VERSIONS
    """
}

process BISMARK_DEDUPLICATE {
    tag "$meta.id"
    label 'process_medium'

    // conda "bioconda::bismark=0.23.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/bismark:0.23.0--hdfd78af_1' :
    //     'quay.io/biocontainers/bismark:0.23.0--hdfd78af_1' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.deduplicated.bam"), emit: bam
    tuple val(meta), path("*_deduplication_report.txt"), emit: report
    path "versions.yml"           , emit: versions

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def paired_end = meta.single_end ? '' : '-p'
    
    """
    deduplicate_bismark ${paired_end} $args --bam $bam

    # Rename the deduplication report to match the expected pattern
    mv ${prefix}.deduplication_report.txt ${prefix}_deduplication_report.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: \$( bismark --version | sed -e "s/Bismark Version: v//g" )
    END_VERSIONS
    """
}

process BISMARK_METHYLATION_EXTRACTOR {
    tag "$meta.id"
    label 'process_high'

    // conda "bioconda::bismark=0.23.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'quay.io/biocontainers/bismark:0.23.0--hdfd78af_1' :
    //     'quay.io/biocontainers/bismark:0.23.0--hdfd78af_1' }"

    input:
    tuple val(meta), path(bam)

    output:
    tuple val(meta), path("*.bedGraph.gz"), emit: bedgraph
    tuple val(meta), path("*.bismark.cov.gz"), emit: coverage
    tuple val(meta), path("*_splitting_report.txt"), emit: report
    path "versions.yml", emit: versions

    script:
    """
    bismark_methylation_extractor --bedGraph --gzip $bam
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: \$( bismark --version | sed -e "s/Bismark Version: v//g" )
    END_VERSIONS
    """
}

process BISMARK_REPORT {
    label 'process_low'

    // conda "bioconda::bismark=0.23.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'quay.io/biocontainers/bismark:0.23.0--hdfd78af_1' :
    //     'quay.io/biocontainers/bismark:0.23.0--hdfd78af_1' }"

    input:
    path "*_report.txt"

    output:
    path "bismark_summary_report.html", emit: summary_report
    path "versions.yml", emit: versions

    script:
    """
    bismark2report
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bismark: \$( bismark --version | sed -e "s/Bismark Version: v//g" )
    END_VERSIONS
    """
}