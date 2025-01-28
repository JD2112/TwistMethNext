#!/usr/bin/env Rscript

# Load required libraries
suppressPackageStartupMessages({
    library(optparse)
    library(dplyr)
    library(GOplot)
    library(org.Hs.eg.db)
    library(clusterProfiler)
})

# Parse command line arguments
option_list <- list(
    make_option(c("--results"), type="character", default=NULL, 
                help="Path to the results file", metavar="FILE"),
    make_option(c("--output"), type="character", default=".", 
                help="Output directory [default= %default]", metavar="DIR"),
    make_option(c("--top_n"), type="integer", default=100,
                help="Number of top differentially methylated genes to use [default= %default]", metavar="NUMBER"),
    make_option(c("--logfc_cutoff"), type="double", default=0.5, 
                help="Log2 fold change cutoff [default= %default]", metavar="NUMBER"),
    make_option(c("--pvalue_cutoff"), type="double", default=0.05, 
                help="P-value cutoff [default= %default]", metavar="NUMBER"),
    make_option(c("--method"), type="character", default="edger",
                help="Analysis method (edger or methylkit) [default= %default]", metavar="STRING")
)

opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Read results
results <- read.csv(opt$results)
cat(opt$method, "results dimensions:", dim(results), "\n")
cat(opt$method, "results columns:", paste(colnames(results), collapse=", "), "\n")

# Filter and sort results
filtered_results <- results %>%
    filter(abs(logFC) >= opt$logfc_cutoff, PValue < opt$pvalue_cutoff) %>%
    arrange(PValue) %>%
    head(opt$top_n)

cat("Filtered results dimensions:", dim(filtered_results), "\n")

# Extract gene symbols (assuming they are in a column named 'Symbol')
genes <- filtered_results$Symbol

if(length(genes) == 0) {
    stop("No genes passed the filtering criteria. Try adjusting the logfc_cutoff and pvalue_cutoff.")
}

cat("Number of genes for GO analysis:", length(genes), "\n")

# Perform GO enrichment analysis
go_enrichment <- enrichGO(gene = genes,
                          OrgDb = org.Hs.eg.db,
                          keyType = "SYMBOL",
                          ont = "BP",
                          pAdjustMethod = "BH",
                          pvalueCutoff = 0.05,
                          qvalueCutoff = 0.2)

if(nrow(go_enrichment@result) == 0) {
    stop("No enriched GO terms found. Try adjusting the filtering criteria or increasing the number of top genes.")
}

# Prepare data for GOChord plot
chord_data <- data.frame(
    Category = go_enrichment@result$Description[1:min(10, nrow(go_enrichment@result))],
    Genes = sapply(go_enrichment@result$geneID[1:min(10, nrow(go_enrichment@result))], function(x) paste(strsplit(x, "/")[[1]], collapse = ","))
)

# Add logFC to chord_data
chord_data$logFC <- sapply(strsplit(chord_data$Genes, ","), function(x) {
    mean(filtered_results$logFC[match(x, filtered_results$Symbol)], na.rm = TRUE)
})

cat("Chord data dimensions:", dim(chord_data), "\n")
print(chord_data)

# Prepare matrix for GOChord
genes_unique <- unique(unlist(strsplit(chord_data$Genes, ",")))
mat <- matrix(0, nrow = length(genes_unique), ncol = nrow(chord_data))
rownames(mat) <- genes_unique
colnames(mat) <- chord_data$Category

for(i in 1:nrow(chord_data)) {
    genes_in_category <- strsplit(chord_data$Genes[i], ",")[[1]]
    mat[genes_in_category, i] <- 1
}

# Add logFC as a column to mat
mat <- cbind(mat, logFC = filtered_results$logFC[match(rownames(mat), filtered_results$Symbol)])

cat("Matrix dimensions:", dim(mat), "\n")
print(head(mat))

# Function to generate GOChord plot
generate_gochord_plot <- function(file_path, width, height) {
    tryCatch({
        par(mar = c(5, 5, 5, 5))  # Increase margins (bottom, left, top, right)
        GOChord(mat, 
                space = 0.02, 
                gene.order = 'logFC', 
                gene.space = 0.25, 
                gene.size = 5,
                process.label = 10)  # Adjust as needed
    }, error = function(e) {
        cat("Error in GOChord:", conditionMessage(e), "\n")
        plot.new()
        text(0.5, 0.5, "Error generating GOChord plot", cex = 1.5)
    })
}

# Generate PNG file
png(file.path(opt$output, paste0(opt$method, "_gochord_plot.png")), width = 16.5, height = 14, units = "in", res = 300)
generate_gochord_plot()
dev.off()

# Generate SVG file
svg(file.path(opt$output, paste0(opt$method, "_gochord_plot.svg")), width = 36, height = 36)
generate_gochord_plot()
dev.off()

cat("GOChord plots saved as PNG and SVG in", opt$output, "\n")

# Save GO enrichment results
write.csv(go_enrichment@result, file.path(opt$output, paste0(opt$method, "_go_enrichment_results.csv")), row.names = FALSE)

cat("GO analysis complete. Results saved in", opt$output, "\n")