## Configuration
analysis_name <- "00.import"
config = file.path(getwd(), "0_project_setting.R")
source(config)

if(!requireNamespace("BSgenome.Hsapiens.UCSC.hg38")) {
  BiocManager::install("BSgenome.Hsapiens.UCSC.hg38")
}
library(BSgenome.Hsapiens.UCSC.hg38) 
library(methrix)

hg38 <- extract_CPGs("BSgenome.Hsapiens.UCSC.hg38")
BASE_DIR <- "/omics/groups/OE0219/internal/yuyu/benchmarking/analysis"
H5_TEMPDIR <- file.path(BASE_DIR, "tmp")

# BAT #OK
WDIR <- file.path(BASE_DIR, "methrix_input_redo/BAT")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bed")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "BAT"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_bat <-   read_bedgraphs(files = bg_files,   
                                   chr_idx = 1, 
                                   start_idx = 2,
                                   M_idx = 6,
                                   U_idx = 7, collapse_strands = T, stranded = T,
                                   ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                   vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/BAT"),
                                   h5temp = H5_TEMPDIR, coldata = sample_annotation)

HDF5Array::saveHDF5SummarizedExperiment(methrix_bat, file.path(BASE_DIR,"read_in_hdf5_manuscript/BAT"), replace = T)

# BSBolt #OK
WDIR <- file.path(BASE_DIR, "methrix_input_redo/BSBolt")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bg.gz")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bg.gz", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bg.gz", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "BSBolt"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_bsbolt <-   read_bedgraphs(files = bg_files,   
                                   chr_idx = 1, 
                                   start_idx = 2,
                                   M_idx = 5, 
                                   U_idx = 6, collapse_strands = T, stranded = T,
                                   ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                   vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/BSBolt"),
                                   h5temp = H5_TEMPDIR, coldata = sample_annotation)


HDF5Array::saveHDF5SummarizedExperiment(methrix_bsbolt, file.path(BASE_DIR,"read_in_hdf5_manuscript/BSBolt"), replace = T)

# Biscuit
WDIR <- file.path(BASE_DIR, "methrix_input_redo/Biscuit")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bed")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "Biscuit"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_biscuit <-   read_bedgraphs(files = bg_files,   
                                   chr_idx = 1, 
                                   start_idx = 2,
                                   beta_idx = 4,
                                   cov_idx = 5, collapse_strands = T, stranded = T,
                                   ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                   vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/Biscuit"),
                                   h5temp = H5_TEMPDIR, coldata = sample_annotation)


HDF5Array::saveHDF5SummarizedExperiment(methrix_biscuit, file.path(BASE_DIR,"read_in_hdf5_manuscript/Biscuit"), replace = T)

# Bismark
WDIR <- file.path(BASE_DIR, "methrix_input_redo/Bismark")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bismark.cov.gz")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(5N|5T|6T|6N).bismark.cov.gz", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(5N|5T|6T|6N).bismark.cov.gz", "\\2", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "Bismark"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

# methrix_bismark <-   read_bedgraphs(files = bg_files,   
#                                     chr_idx = 1, 
#                                     start_idx = 2,
#                                     M_idx = 5,
#                                     U_idx = 6, collapse_strands = T, stranded = T, zero_based = F,
#                                     ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
#                                     vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/Bismark"),
#                                     h5temp = H5_TEMPDIR, coldata = sample_annotation)

methrix_bismark <- methrix::read_bedgraphs(
  files = bg_files,
  pipeline="Bismark_cov",
  zero_based=FALSE,
  ref_cpgs = hg38,
  coldata = sample_annotation,
  vect = FALSE,
  h5 = TRUE,
  h5_dir = paste0(BASE_DIR,"read_in_hdf5_manuscript/Bismark"),
  h5temp = H5_TEMPDIR,
  collapse_strands = TRUE,
  stranded = T
)

HDF5Array::saveHDF5SummarizedExperiment(methrix_bismark, file.path(BASE_DIR,"read_in_hdf5_manuscript/Bismark"), replace = T)

# FAME
WDIR <- file.path(BASE_DIR, "methrix_input_redo/FAME")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bed")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "FAME"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_FAME <-   read_bedgraphs(files = bg_files,   chr_idx = 1,
                                 start_idx = 2,
                                 M_idx = 3,
                                 U_idx = 4, #stranded = TRUE, collapse_strands = TRUE,
                                 ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                 vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/FAME"),
                                 h5temp = H5_TEMPDIR, coldata = sample_annotation)

HDF5Array::saveHDF5SummarizedExperiment(methrix_FAME, file.path(BASE_DIR,"read_in_hdf5_manuscript/FAME"), replace = T)

# GSNAP
WDIR <- file.path(BASE_DIR, "methrix_input_redo/GSNAP")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bed")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "GSNAP"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_GSNAP <-   read_bedgraphs(files = bg_files, chr_idx = 1,
                                  start_idx = 2,
                                  strand_idx = 6,
                                  beta_idx = 4,
                                  cov_idx = 5,  stranded = T, collapse_strands = T,
                                  ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                  vect = F, h5 = T, h5_dir =  file.path(BASE_DIR,"read_in_hdf5_manuscript/GSNAP"),
                                  h5temp = H5_TEMPDIR, coldata = sample_annotation)

HDF5Array::saveHDF5SummarizedExperiment(methrix_GSNAP, file.path(BASE_DIR,"read_in_hdf5_manuscript/GSNAP"), replace = T) 

# bwameth
WDIR <- file.path(BASE_DIR, "methrix_input_redo/bwameth")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.bedgraph")
print(basename(bg_files))

sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bedgraph", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bedgraph", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "bwameth"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_bwameth <-   read_bedgraphs(files = bg_files,   
                                   chr_idx = 1, 
                                   start_idx = 2,
                                   M_idx = 5,
                                   U_idx = 6, collapse_strands = T, stranded = T,
                                   ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                   vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/bwameth"),
                                   h5temp = H5_TEMPDIR, coldata = sample_annotation)


HDF5Array::saveHDF5SummarizedExperiment(methrix_bwameth, file.path(BASE_DIR,"read_in_hdf5_manuscript/bwameth"), replace = T)

# gemBS
WDIR <- file.path(BASE_DIR, "methrix_input_redo/gemBS")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed.gz")
print(basename(bg_files))
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed.gz", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).bed.gz", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "gemBS"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_gemBS <-   read_bedgraphs(files = bg_files, chr_idx = 1,
                                  start_idx = 2,
                                  M_idx = 4,
                                  U_idx = 5,
                                  stranded = T, collapse_strands = T,
                                  ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                  vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/gemBS"),
                                  h5temp = H5_TEMPDIR, coldata = sample_annotation)

HDF5Array::saveHDF5SummarizedExperiment(methrix_gemBS, file.path(BASE_DIR,"read_in_hdf5_manuscript/gemBS"), replace = T)

# methylCtools
WDIR <- file.path(BASE_DIR, "methrix_input_redo/methylCtools")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.call.gz")
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).call.gz", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).call.gz", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "methylCtools"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_methylCtools <-   read_bedgraphs(files = bg_files,   
                                   chr_idx = 1, 
                                   start_idx = 2,
                                   M_idx = 5,
                                   U_idx = 6, collapse_strands = T, stranded = T,
                                   ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                   vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/methylCtools"),
                                   h5temp = H5_TEMPDIR, coldata = sample_annotation)


HDF5Array::saveHDF5SummarizedExperiment(methrix_methylCtools, file.path(BASE_DIR,"read_in_hdf5_manuscript/methylCtools"), replace = T)

# methylpy
WDIR <- file.path(BASE_DIR, "methrix_input_redo/methylpy")
bg_files <- dir(path = WDIR, full.names = T, recursive = T, pattern="*.CG.tsv.gz")
sample_annotation <- data.frame(matrix(data=NA, nrow = length(bg_files), ncol = 1))
colnames(sample_annotation) <- "sample"

samples <- gsub(paste0(WDIR, "/"), "", bg_files)

samples

sample_annotation$method <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).CG.tsv.gz", "\\1", samples)
sample_annotation$sample <- gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)/(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).CG.tsv.gz", "\\3", samples)
sample_annotation$assembly <- "hg38"
sample_annotation$pipeline <-  "methylpy"

rownames(sample_annotation) = paste0(sample_annotation$assembly, ".", sample_annotation$method, ".", sample_annotation$sample, ".", sample_annotation$pipeline)

sample_annotation

methrix_methylpy <-   read_bedgraphs(files = bg_files,   
                                     chr_idx = 1, 
                                     start_idx = 2,
                                     M_idx = 5,
                                     cov_idx = 6, stranded = T,  collapse_strands = T, zero_based = FALSE,
                                     ref_cpgs = hg38, ref_build = "hg38", contigs = NULL,
                                     vect = F, h5 = T, h5_dir = file.path(BASE_DIR,"read_in_hdf5_manuscript/methylpy"),
                                     h5temp = H5_TEMPDIR, coldata = sample_annotation)

HDF5Array::saveHDF5SummarizedExperiment(methrix_methylpy, file.path(BASE_DIR,"read_in_hdf5_manuscript/methylpy"), replace = T)
