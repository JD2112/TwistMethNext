#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(optparse)
    library(edgeR)
    library(dplyr)
})

# Parse command line arguments
option_list <- list(
    make_option(c("--results"), type="character", default=NULL, 
                help="Path to the EdgeR results file", metavar="FILE"),
    make_option(c("--output"), type="character", default="annotated_results.csv", 
                help="Output file name [default= %default]", metavar="FILE")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Check if required arguments are provided
if (is.null(opt$results)) {
    stop("Error: --results argument is required. Use --help for more information.")
}

# Read EdgeR results
cat("Reading EdgeR results file:", opt$results, "\n")
results <- read.csv(opt$results)
cat("EdgeR results dimensions:", dim(results), "\n")
cat("EdgeR results columns:", paste(colnames(results), collapse=", "), "\n")

# Ensure Chr column has 'chr' prefix
results$Chr <- ifelse(grepl("^chr", results$Chr), results$Chr, paste0("chr", results$Chr))

# Find nearest TSS
cat("Finding nearest TSS...\n")
TSS <- nearestTSS(results$Chr, results$Locus, species="Hs")

# Add gene information to results
results$EntrezID <- TSS$gene_id
results$Symbol <- TSS$symbol
results$Strand <- TSS$strand
results$Distance <- TSS$distance
results$Width <- TSS$width

cat("Number of results with gene annotations:", sum(!is.na(results$EntrezID)), "\n")

# Write the results with gene annotations
cat("Writing annotated results...\n")
write.csv(results, file = opt$output, row.names = FALSE)

cat("Annotation complete. Results saved to", opt$output, "\n")

# Print summary
cat("\nSummary:\n")
cat("Total results:", nrow(results), "\n")
cat("Results with gene annotations:", sum(!is.na(results$EntrezID)), "\n")
cat("Unique genes identified:", length(unique(results$EntrezID[!is.na(results$EntrezID)])), "\n")