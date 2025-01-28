#!/usr/bin/env Rscript

suppressPackageStartupMessages({
    library(optparse)
    library(edgeR)
    library(dplyr)
})

# Parse command line arguments
option_list <- list(
    make_option(c("--results"), type="character", default=NULL, 
                help="Path to the results file", metavar="FILE"),
    make_option(c("--output"), type="character", default="annotated_results.csv", 
                help="Output file name [default= %default]", metavar="FILE"),
    make_option(c("--method"), type="character", default="edger",
                help="Analysis method (edger or methylkit) [default= %default]", metavar="STRING")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Check if required arguments are provided
if (is.null(opt$results)) {
    stop("Error: --results argument is required. Use --help for more information.")
}

# Read results
cat("Reading", opt$method, "results file:", opt$results, "\n")
results <- read.csv(opt$results)
cat(opt$method, "results dimensions:", dim(results), "\n")
cat(opt$method, "results columns:", paste(colnames(results), collapse=", "), "\n")

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
output_file <- paste0(opt$method, "_", opt$output)
cat("Writing annotated results...\n")
write.csv(results, file = output_file, row.names = FALSE)

cat("Annotation complete. Results saved to", output_file, "\n")

# Print summary
cat("\nSummary:\n")
cat("Total results:", nrow(results), "\n")
cat("Results with gene annotations:", sum(!is.na(results$EntrezID)), "\n")
cat("Unique genes identified:", length(unique(results$EntrezID[!is.na(results$EntrezID)])), "\n")