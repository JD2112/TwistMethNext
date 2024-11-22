process POST_PROCESSING {
    label 'process_medium'

    // conda "bioconda::r-base=4.1.0 bioconda::r-ggplot2=3.3.5 bioconda::r-dplyr=1.0.7 bioconda::r-tidyr=1.1.3"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'quay.io/biocontainers/mulled-v2-8849acf39a43cdd6c839a369a74c0adc823e2f91:ab110436faf952a33575c64dd74615a84011450b-0' :
    //     'quay.io/biocontainers/mulled-v2-8849acf39a43cdd6c839a369a74c0adc823e2f91:ab110436faf952a33575c64dd74615a84011450b-0' }"

    input:
    path edger_results
    val compare_str

    output:
    path "summary_stats.csv", emit: summary
    path "*.png", emit: plots
    path "versions.yml", emit: versions

    script:
    """
    #!/usr/bin/env Rscript

    library(ggplot2)
    library(dplyr)
    library(tidyr)

    # Read EdgeR results
    results <- read.csv("${edger_results}")

    # Generate summary statistics
    summary_stats <- results %>%
        summarize(
            total_dmrs = n(),
            hypermethylated = sum(logFC > 0),
            hypomethylated = sum(logFC < 0),
            significant_dmrs = sum(FDR < 0.05)
        )

    write.csv(summary_stats, "summary_stats.csv", row.names = FALSE)

    # Create volcano plot
    ggplot(results, aes(x = logFC, y = -log10(PValue))) +
        geom_point(aes(color = FDR < 0.05)) +
        scale_color_manual(values = c("black", "red")) +
        labs(title = "Volcano Plot", x = "Log2 Fold Change", y = "-Log10 P-value") +
        theme_minimal()
    ggsave("volcano_plot.png")

    # Create MA plot
    ggplot(results, aes(x = logCPM, y = logFC)) +
        geom_point(aes(color = FDR < 0.05)) +
        scale_color_manual(values = c("black", "red")) +
        labs(title = "MA Plot", x = "Log2 CPM", y = "Log2 Fold Change") +
        theme_minimal()
    ggsave("ma_plot.png")

    # Create versions.yml
    writeLines(
        c(
            "\\"${task.process}\\":",
            "    r-base: \$(R --version | grep 'R version' | sed 's/R version //')",
            "    ggplot2: \$(Rscript -e 'cat(as.character(packageVersion(\"ggplot2\"))))'",
            "    dplyr: \$(Rscript -e 'cat(as.character(packageVersion(\"dplyr\"))))'",
            "    tidyr: \$(Rscript -e 'cat(as.character(packageVersion(\"tidyr\"))))'",
            ""
        ),
        "versions.yml"
    )
    """
}