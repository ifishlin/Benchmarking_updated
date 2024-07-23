## Configuration
analysis_name <- "04-3_liftover_450K_loci_hg19_to_hg38"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(liftOver)

## Set Path
i450k_hg19 = read_csv(file="/home/y306n/OE0219YUYU/benchmarking/analysis/data_processing/450K_annotation/HumanMethylation450_15017482_v1-2.csv", skip=7)

i450k_hg19_gr = i450k_hg19 %>% dplyr::select(CHR, MAPINFO) %>% filter(!is.na(CHR)) %>% 
  dplyr::mutate(seqnames=paste0("chr", CHR), start=MAPINFO, end=MAPINFO+1) %>% 
  dplyr::select(-CHR, -MAPINFO) %>%
  makeGRangesFromDataFrame(keep.extra.columns = T)

## Liftover
path = system.file(package="liftOver", "extdata", "hg19ToHg38.over.chain")
ch = import.chain(path)
cur38 = liftOver(i450k_hg19_gr, ch)
i450k_hg38_gr = unlist(cur38)
i450k_hg38_tb = data.frame(unique(i450k_hg38_gr))

save_("i450k_hg38_gr", data=unique(i450k_hg38_gr))


