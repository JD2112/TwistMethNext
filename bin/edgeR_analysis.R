#!/usr/bin/env Rscript

# Load required libraries
suppressPackageStartupMessages({
    library(edgeR)
    library(readr)
    library(optparse)
    library(dplyr)
})

# Define command line arguments
option_list <- list(
    make_option(c("-f", "--coverage_files"), type="character", default=NULL, 
                help="Comma-separated list of Bismark coverage files", metavar="FILES"),
    make_option(c("-d", "--design"), type="character", default=NULL, 
                help="Design file path (CSV format)", metavar="FILE"),
    make_option(c("-c", "--compare"), type="character", default="all", 
                help="Comparison string (e.g., 'GroupA_vs_GroupB') or 'all' for all pairwise comparisons [default= %default]", metavar="STRING"),
    make_option(c("-o", "--output"), type="character", default=".", 
                help="Output directory [default= %default]", metavar="DIR"),
    make_option(c("-t", "--threshold"), type="integer", default=3, 
                help="Coverage threshold for filtering [default= %default]", metavar="INTEGER")
)

# Parse command line arguments
opt_parser <- OptionParser(option_list=option_list)
opt <- parse_args(opt_parser)

# Read design file
targets <- read_csv(opt$design)

# Read Bismark coverage files
coverage_files <- unlist(strsplit(opt$coverage_files, ","))
coverage_data <- lapply(coverage_files, function(file) {
    read_delim(file, delim="\t", col_names=c("chr", "start", "end", "methylation_percentage", "count_methylated", "count_unmethylated"))
})

# Combine coverage data
combined_coverage <- Reduce(function(x, y) full_join(x, y, by=c("chr", "start", "end")), coverage_data)

# Create DGEList object
counts <- combined_coverage %>% select(starts_with("count_"))
y <- DGEList(counts=counts, group=targets$Group)

# Filtering and normalization
keep <- rowSums(cpm(y) > opt$threshold) >= 2
y <- y[keep, , keep.lib.sizes=FALSE]

# Design matrix
design <- model.matrix(~0+group, data=y$samples)
colnames(design) <- levels(y$samples$group)

# Estimate dispersion
y <- estimateDisp(y, design)

# Fit model
fit <- glmQLFit(y, design)

# Perform comparisons
if(opt$compare == "all") {
    comparisons <- combn(levels(y$samples$group), 2, simplify = FALSE)
} else {
    group_ids <- strsplit(opt$compare, "_vs_")[[1]]
    comparisons <- list(group_ids)
}

for(comp in comparisons) {
    group1 <- comp[1]
    group2 <- comp[2]
    
    cat("Performing comparison:", group1, "vs", group2, "\n")
    
    contrast <- makeContrasts(contrasts=paste0(group2, "-", group1), levels=design)
    qlf <- glmQLFTest(fit, contrast=contrast)
    
    # Get results
    results <- topTags(qlf, n=Inf)
    
    # Prepare output
    output_name <- paste0("EdgeR_group_", trimws(group1), "_vs_", trimws(group2), "_coverage", opt$threshold)
    output_file <- file.path(opt$output, paste0(output_name, ".csv"))
    
    # Write results
    write.csv(results, file = output_file, quote = FALSE, row.names = TRUE)
    
    cat("Results written to:", output_file, "\n")
}

cat("All analyses complete.\n")
cat("Coverage threshold used:", opt$threshold, "\n")