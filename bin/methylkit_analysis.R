#!/usr/bin/env Rscript

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
                help="Coverage threshold for filtering [default= %default]", metavar="INTEGER")
)

opt <- parse_args(OptionParser(option_list=option_list))

# Read design file
design <- read_csv(opt$design)

# Process coverage files
coverage_files <- unlist(strsplit(opt$coverage_files, ","))
sample_names <- basename(unname(sapply(coverage_files, function(x) str_extract(x, ".+?(?=\\.)"))))

# Create methylKit object
myObj <- methRead(
    location = as.list(coverage_files),
    sample.id = as.list(sample_names),
    assembly = "hg38",
    treatment = design$Group,
    context = "CpG",
    mincov = opt$threshold
)

# Filtering and normalization
filtered.myObj <- filterByCoverage(myObj, 
                                   lo.count = opt$threshold, 
                                   lo.perc = NULL, 
                                   hi.count = NULL, 
                                   hi.perc = 99.9)

myobj.filt.norm <- normalizeCoverage(filtered.myObj, method = "median")

# Merge data
meth1 <- unite(myobj.filt.norm, destrand=FALSE)

# Calculate differential methylation
if (opt$compare == "all") {
    # Perform all pairwise comparisons
    groups <- unique(design$Group)
    comparisons <- combn(groups, 2, simplify = FALSE)
} else {
    # Perform specified comparison
    comparisons <- list(unlist(strsplit(opt$compare, "_vs_")))
}

for (comp in comparisons) {
    group1 <- comp[1]
    group2 <- comp[2]
    
    myDiff <- calculateDiffMeth(meth1,
                                overdispersion = "MN",
                                adjust = "BH",
                                mc.cores = 1,
                                treatment = design$Group %in% group1)

    # Get differentially methylated bases
    myDiff5p <- getMethylDiff(myDiff, difference=5, qvalue=0.01)

    # Annotation
    # download refseq file on the fly
    url <- "https://sourceforge.net/projects/rseqc/files/BED/Human_Homo_sapiens/hg38_RefSeq.bed.gz/download"
    tmpfile <- tempfile(tmpdir=getwd())
    file.create(tmpfile)
    download.file(url, tmpfile)
    file.rename(tmpfile, "hg38_RefSeq.bed.gz")
    gene.obj <- readTranscriptFeatures("hg38_RefSeq.bed.gz")

    myDiff5p.annot <- annotateWithGeneParts(as(myDiff5p, "GRanges"), gene.obj)

    # Get the annotation
    anno <- AnnotationDbi::select(org.Hs.eg.db, 
                                  keys=gsub("\\..*","", myDiff5p.annot$feature.name),
                                  columns=c("SYMBOL","GENENAME"),
                                  keytype="REFSEQ")

    # Combine all information
    DMC.final.annot <- cbind(as.data.frame(myDiff5p.annot), anno)

    # Write results
    output_name <- file.path(opt$output, paste0("Methylkit_", group1, "_vs_", group2, ".csv"))
    write.csv(DMC.final.annot, file = output_name, quote = FALSE)
}

# Write version information
cat(paste0("methylKit version: ", packageVersion("methylKit"), "\n"),
    file = file.path(opt$output, "versions.txt"))