#!/usr/bin/env Rscript

cat("Starting methylkit_analysis.R script\n")

suppressPackageStartupMessages({
  library(methylKit)
  library(readr)
  library(stringr)
  library(org.Hs.eg.db)
  library(genomation)
  library(optparse)
})

option_list <- list(
    make_option(c("-f", "--coverage_files"), type="character", default=NULL, 
                help="Comma-separated list of Bismark coverage files", metavar="FILES"),
    make_option(c("-d", "--design"), type="character", default=NULL, 
                help="Design file path (CSV format)", metavar="FILE"),
    make_option(c("-c", "--compare"), type="character", default="all", 
                help="Comparison string (e.g., 'GroupA_vs_GroupB') or 'all' for all pairwise comparisons [default= %default]", metavar="STRING"),
    make_option(c("-o", "--output"), type="character", default=".", 
                help="Output directory [default= %default]", metavar="DIR"),
    make_option(c("-t", "--threshold"), type="integer", default=5, 
                help="Coverage threshold for filtering [default= %default]", metavar="INTEGER"),
    make_option(c("--refseq"), type="character", default=NULL, 
                help="Path to RefSeq file", metavar="FILE")
)

opt <- parse_args(OptionParser(option_list=option_list))

cat("Script arguments:\n")
cat(paste("coverage_files:", opt$coverage_files, "\n"))
cat(paste("design:", opt$design, "\n"))
cat(paste("compare:", opt$compare, "\n"))
cat(paste("output:", opt$output, "\n"))
cat(paste("threshold:", opt$threshold, "\n"))
cat(paste("refseq:", opt$refseq, "\n"))

if (is.null(opt$coverage_files) || is.null(opt$design)) {
  stop("Both coverage_files and design file must be provided")
}

if (!file.exists(opt$design)) {
  stop(paste("Design file does not exist:", opt$design))
}

coverage_files <- unlist(strsplit(opt$coverage_files, ","))
for (file in coverage_files) {
  if (!file.exists(file)) {
    stop(paste("Coverage file does not exist:", file))
  }
}

# Read design file
cat("Reading design file...\n")
design <- tryCatch({
  read_csv(opt$design)
}, error = function(e) {
  cat(paste("Error reading design file:", e$message, "\n"))
  stop("Failed to read design file")
})
cat("Design file contents:\n")
print(design)

# Process coverage files
sample_names <- basename(unname(sapply(coverage_files, function(x) str_extract(x, ".+?(?=\\.)"))))

cat("Coverage files:\n")
print(coverage_files)
cat("Sample names:\n")
print(sample_names)

# Create methylKit object
cat("Creating methylKit object...\n")
tryCatch({
    myObj <- methRead(
        location = as.list(coverage_files),
        sample.id = as.list(sample_names),
        assembly = "hg38",
        treatment = as.numeric(factor(design$group)) - 1,
        context = "CpG",
        pipeline = "bismarkCoverage",
        mincov = opt$threshold
    )
    cat("MethylKit object created successfully\n")
    print(summary(myObj))
}, error = function(e) {
    cat(paste("Error in methRead:", e$message, "\n"))
    cat("Trying to read the first few lines of each coverage file:\n")
    for (file in coverage_files) {
        cat(paste("File:", file, "\n"))
        tryCatch({
            print(head(read.table(gzfile(file), header=FALSE, nrows=5)))
        }, error = function(e) {
            cat(paste("Error reading file:", e$message, "\n"))
        })
    }
    cat("Design file contents:\n")
    print(design)
    stop("Error in methRead. See above for details.")
})

# Filtering and normalization
cat("Starting filtering process...\n")
filtered.myObj <- filterByCoverage(myObj, 
                                   lo.count = opt$threshold, 
                                   lo.perc = NULL, 
                                   hi.count = NULL, 
                                   hi.perc = 99.9)

cat("Filtered object summary:\n")
print(summary(filtered.myObj))

cat("Starting normalization process...\n")
myobj.filt.norm <- normalizeCoverage(filtered.myObj, method = "median")

cat("Normalized object summary:\n")
print(summary(myobj.filt.norm))

# Merge data
cat("Starting data merging process...\n")
meth1 <- unite(myobj.filt.norm, destrand=FALSE)

cat("United object summary:\n")
print(summary(meth1))
print(head(meth1))

# Calculate differential methylation
cat("Starting differential methylation calculation...\n")
if (opt$compare == "all") {
    # Perform all pairwise comparisons
    groups <- unique(design$group)
    comparisons <- combn(groups, 2, simplify = FALSE)
} else {
    # Perform specified comparison
    comparisons <- list(unlist(strsplit(opt$compare, "_vs_")))
}

for (comp in comparisons) {
    group1 <- comp[1]
    group2 <- comp[2]
    
    cat(paste("Calculating differential methylation for", group1, "vs", group2, "\n"))
    myDiff <- calculateDiffMeth(meth1,
                                overdispersion = "MN",
                                adjust = "BH",
                                mc.cores = 12,
                                treatment = design$group %in% group1)

    # Get differentially methylated bases
    myDiff5p <- getMethylDiff(myDiff, difference=5, qvalue=0.01)
    head(myDiff5p)

    # Annotation
cat("Starting annotation process...\n")
tryCatch({
    if (!is.null(opt$refseq)) {
        cat(paste("Using provided RefSeq file:", opt$refseq, "\n"))
        gene.obj <- readTranscriptFeatures(opt$refseq)
    } else {
        cat("Downloading default RefSeq file...\n")
        url <- "https://sourceforge.net/projects/rseqc/files/BED/Human_Homo_sapiens/hg38_RefSeq.bed.gz/download"
        destfile <- "hg38_RefSeq.bed.gz"
        download.file(url, destfile)
        gene.obj <- readTranscriptFeatures(destfile)
    }

    cat("Gene object summary:\n")
    print(summary(gene.obj))

    myDiff5p.annot <- suppressWarnings(annotateWithGeneParts(as(myDiff5p, "GRanges"), gene.obj))

    myDiff5p.annot <- suppressWarnings(annotateWithGeneParts(as(myDiff5p, "GRanges"), gene.obj))
    dist_to_tss <- myDiff5p.annot@dist.to.TSS

    dist_to_tss_df <- data.frame(
    dist_to_feature = dist_to_tss$dist.to.feature,
    feature_name = dist_to_tss$feature.name,
    feature_strand = dist_to_tss$feature.strand,
    target_row = dist_to_tss$target.row
    )

    myDiff5p_df <- as.data.frame(myDiff5p)

    myDiff5p_annotated <- myDiff5p_df

    myDiff5p_annotated$target_row <- 1:nrow(myDiff5p_annotated)
    myDiff5p_data <- getData(myDiff5p_annotated)
    myDiff5p_data_annotated <- merge(myDiff5p_data, dist_to_tss_df, by = "target_row", all.x = TRUE)

    # Get the annotation
    cat("Getting annotation from org.Hs.eg.db\n")

    key <- gsub("\\..*", "", myDiff5p_data_annotated$feature_name) 
    anno <- AnnotationDbi::select(org.Hs.eg.db, 
                                  keys=key,
                                  columns=c("SYMBOL","GENENAME"),
                                  keytype="REFSEQ")

    cat("Annotation result summary:\n")
    print(summary(anno))

    # Combine all information
    DMC.final.annot <- cbind(as.data.frame(myDiff5p_data_annotated), anno)

    cat("Final annotation summary:\n")
    print(summary(DMC.final.annot))

    # Write results
    output_name <- file.path(opt$output, paste0("MethylKit_", group1, "_vs_", group2, ".csv"))
    write.csv(DMC.final.annot, file = output_name, quote = FALSE)
    cat(paste("Results written to:", output_name, "\n"))
}, error = function(e) {
    cat(paste("Error in annotation process:", e$message, "\n"))
    cat("myDiff5p summary:\n")
    print(summary(myDiff5p))
    cat("myDiff5p.annot summary (if available):\n")
    if(exists("myDiff5p.annot")) print(summary(myDiff5p.annot))
    cat("Gene object summary (if available):\n")
    if(exists("gene.obj")) print(summary(gene.obj))
    stop("Annotation process failed. See above for details.")
})
}

# Write version information
version_file <- file.path(opt$output, "versions.txt")
cat(paste0("methylKit version: ", packageVersion("methylKit"), "\n"),
    file = version_file)
cat(paste("Version information written to:", version_file, "\n"))

cat("methylkit_analysis.R script completed successfully\n")