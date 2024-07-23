## Configuration
analysis_name <- "04-1_analyze_microarray_by_RnBeads"
#config = file.path(getwd(), "0_project_setting.R")
#source(config)

################################################################################
# DNA methylation analysis with RnBeads
# Epigenomics 2016 Workshop
# ------------------------------------------------------------------------------
#  Vanilla analysis of the Ziller2011 450K dataset
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# created: 2016-01-22
# author:  Fabian Mueller <rnbeads@mpi-inf.mpg.de>
# http://rnbeads.mpi-inf.mpg.de/
################################################################################

################################################################################
# (0) Preliminaries
################################################################################
# load the package
library(RnBeads)
library(grid)

setwd("/omics/groups/OE0219/internal/yuyu/10.Benchmarking/GSE77965")
# define the directory structure
# setwd(".")
dataDir <- file.path(getwd(), "data")
resultDir <- file.path(getwd(), "results")

# dataset and file locations
datasetDir <- file.path(dataDir, "colon")
idatDir <- file.path(datasetDir, "dataset", "idat")
sampleSheet <- file.path(datasetDir, "dataset", "benchmarking_annotationn.csv")
reportDir <- file.path(resultDir, "report_benchmarking_04042023")
################################################################################
# (1) Set analysis options
################################################################################
rnb.options(
  filtering.sex.chromosomes.removal = TRUE,
  identifiers.column                = "Sample_ID"
)
# optionally disable some parts of the analysis to reduce runtime
rnb.options(
  exploratory.correlation.qc        = FALSE,
  exploratory.intersample           = FALSE,
  # exploratory.region.profiles       = c("genes"),
  exploratory.region.profiles       = character(0),
  exploratory.clustering            = "top",
  exploratory.clustering.top.sites  = 100,
  # region.types                      = c("promoters", "genes", "tiling"),
  region.types                      = c("promoters", "cpgislands", "genes", "tiling"),
  differential.report.sites         = TRUE,
  differential.comparison.columns   = c("diseaseState"),
  columns.pairing                   = c("diseaseState"="Pair_ID")
)

################################################################################
# (2) Run the analysis
################################################################################
rnb.run.analysis(
  dir.reports=reportDir,
  sample.sheet=sampleSheet,
  data.dir=idatDir,
  data.type="infinium.idat.dir"
)

################################################################################
# Link to finished analysis
################################################################################
# see the results at:
# http://rnbeads.mpi-inf.mpg.de/reports/tutorial/epigenomics2016/results/report_Ziller2011_vanilla/index.html
