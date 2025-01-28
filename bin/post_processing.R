#!/usr/bin/env Rscript

# Load required libraries
library(ggplot2)
library(dplyr)
library(tidyr)
library(optparse)

# Parse command line arguments
option_list <- list(
    make_option(c("--results"), type="character", default=NULL, 
                help="Path to the results file", metavar="FILE"),
    make_option(c("--compare"), type="character", default=NULL, 
                help="Comparison string", metavar="STRING"),
    make_option(c("--output"), type="character", default=".", 
                help="Output directory [default= %default]", metavar="DIR"),
    make_option(c("--logfc_cutoff"), type="double", default=0.5, 
                help="Log2 fold change cutoff [default= %default]", metavar="NUMBER"),
    make_option(c("--pvalue_cutoff"), type="double", default=0.05, 
                help="P-value cutoff [default= %default]", metavar="NUMBER"),
    make_option(c("--hyper_color"), type="character", default="red", 
                help="Color for hypermethylated CpGs [default= %default]", metavar="COLOR"),
    make_option(c("--hypo_color"), type="character", default="blue", 
                help="Color for hypomethylated CpGs [default= %default]", metavar="COLOR"),
    make_option(c("--nonsig_color"), type="character", default="grey", 
                help="Color for non-significant CpGs [default= %default]", metavar="COLOR"),
    make_option(c("--method"), type="character", default="edger",
                help="Analysis method (edger or methylkit) [default= %default]", metavar="STRING")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Read results
results <- read.csv(opt$results)

# Add a column for significance based on user-defined cutoffs
results$significance <- case_when(
    results$logFC >= opt$logfc_cutoff & results$PValue < opt$pvalue_cutoff ~ "Hypermethylated",
    results$logFC <= -opt$logfc_cutoff & results$PValue < opt$pvalue_cutoff ~ "Hypomethylated",
    TRUE ~ "Not Significant"
)

# Generate summary statistics
summary_stats <- results %>%
    summarize(
        total_dmrs = n(),
        hypermethylated = sum(significance == "Hypermethylated"),
        hypomethylated = sum(significance == "Hypomethylated"),
        significant_dmrs = sum(significance != "Not Significant")
    )

write.csv(summary_stats, file.path(opt$output, paste0(opt$method, "_summary_stats.csv")), row.names = FALSE)

# Color palette
color_palette <- c("Hypermethylated" = opt$hyper_color, 
                   "Hypomethylated" = opt$hypo_color, 
                   "Not Significant" = opt$nonsig_color)

# Create volcano plot
ggplot(results, aes(x = logFC, y = -log10(PValue), color = significance)) +
    geom_point(alpha = 0.6) +
    scale_color_manual(values = color_palette) +
    geom_vline(xintercept = c(-opt$logfc_cutoff, opt$logfc_cutoff), linetype = "dashed", color = "black") +
    geom_hline(yintercept = -log10(opt$pvalue_cutoff), linetype = "dashed", color = "black") +
    labs(title = paste("Volcano Plot -", opt$compare, "(", opt$method, ")"), 
         x = "Log2 Fold Change", y = "-Log10 P-value",
         color = "Methylation Status") +
    theme_minimal() +
    theme(legend.position = "right")
ggsave(file.path(opt$output, paste0(opt$method, "_volcano_plot.png")), width = 10, height = 8)

# Create MA plot
ggplot(results, aes(x = logCPM, y = logFC, color = significance)) +
    geom_point(alpha = 0.6) +
    scale_color_manual(values = color_palette) +
    geom_hline(yintercept = c(-opt$logfc_cutoff, opt$logfc_cutoff), linetype = "dashed", color = "black") +
    labs(title = paste("MA Plot -", opt$compare, "(", opt$method, ")"), 
         x = "Log2 CPM", y = "Log2 Fold Change",
         color = "Methylation Status") +
    theme_minimal() +
    theme(legend.position = "right")
ggsave(file.path(opt$output, paste0(opt$method, "_ma_plot.png")), width = 10, height = 8)

# Print the cutoffs and colors used
cat(sprintf("Analysis performed with:\nMethod: %s\nlogFC cutoff: %f\np-value cutoff: %f\n", 
            opt$method, opt$logfc_cutoff, opt$pvalue_cutoff))
cat(sprintf("Colors used:\nHypermethylated: %s\nHypomethylated: %s\nNot Significant: %s\n",
            opt$hyper_color, opt$hypo_color, opt$nonsig_color))