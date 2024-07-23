## Configuration
analysis_name <- "04-2_liftover_RnBeads_loci_hg19_to_hg38"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(liftOver)

## Set Path
rnbead_path="/omics/groups/OE0219/internal/yuyu/10.Benchmarking/GSE77965/results/report_benchmarking_04042023/differential_methylation_data/"
dml_rnbeads_hg19_tb <- read.table(file.path(rnbead_path, "diffMethTable_site_cmp1.csv"), sep=",", header = TRUE)
dml_rnbeads_hg19_gr <- dml_rnbeads_hg19_tb %>% dplyr::rename(seqnames=Chromosome, start=Start) %>% 
  dplyr::mutate(end=start+1) %>%
  makeGRangesFromDataFrame(keep.extra.columns = T)

## Liftover
path = system.file(package="liftOver", "extdata", "hg19ToHg38.over.chain")
ch = import.chain(path)
seqlevelsStyle(dml_rnbeads_hg19_gr) = "UCSC"  # necessary
cur38 = liftOver(dml_rnbeads_hg19_gr, ch)
cur38 <-subset(cur38, lengths(cur38)==1)
dml_rnbeads_hg38_gr = unlist(cur38)
dml_rnbeads_hg38_tb = data.frame(unique(dml_rnbeads_hg38_gr))
save_("dml_rnbeads_hg38_tb", data=dml_rnbeads_hg38_tb)
