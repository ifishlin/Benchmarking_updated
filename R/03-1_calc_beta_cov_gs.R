## Configuration
analysis_name <- "03-1_calc_beta_cov_gs"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(methrix)

## Annotation
#######################################################
region_annotation <- readRDS("gold_standard/data/region_annotation.rds") %>% as_tibble
region_annotation$start <- region_annotation$probe_pos
region_annotation$end <- region_annotation$probe_pos+1
regions <- region_annotation[,c("seqnames", "start", "end")]
colnames(regions) <-c("chr", "start", "end")
regions <- GenomicRanges::makeGRangesFromDataFrame(regions, keep.extra.columns = T, ignore.strand = T)


## GS
#######################################################
meth_gs <- readRDS("gold_standard/data/gold_standard_calls_means.rds")
meth_gs_tb <- meth_gs %>%
  names %>%
  lapply(function(s){
    meth_gs[[s]] %>%
      as_tibble %>%
      dplyr::mutate(sample=s)
  }) %>%
  do.call("bind_rows", .) %>%
  dplyr::select(sample, everything()) %>%
  dplyr::mutate(sample=gsub("_meth", "", sample)) %>%
  dplyr::mutate(sample=gsub("X", "", sample)) %>%
  dplyr::filter(!is.na(lower)) %>%
  dplyr::mutate(mid_interval=(upper+lower)/2) %>%
  dplyr::mutate(lid=gsub("recommended_","r",locus_identifier)) %>%
  dplyr::mutate(lid=gsub("mandatory_","m",lid))

## Subregions
meth = methrix::load_HDF5_methrix(file.path(methrix_obj_dir, workflows[1]))
meth_filt = subset_methrix(meth, regions= regions)

for(n in workflows[2:length(workflows)]){
  meth_ = methrix::load_HDF5_methrix(file.path(methrix_obj_dir, n))
  meth_filt_ = subset_methrix(meth_, regions= regions)
  meth_filt = meth_filt %>% combine_methrix(meth_filt_, by="col")
}

## Retrieve methylation status and coverage
meth_filt_tb <- meth_filt %>% 
  get_matrix(add_loci=T) %>% 
  as_tibble

cov_filt_tb <- meth_filt %>% 
  get_matrix(type="C", add_loci=T) %>% 
  as_tibble

save_("meth_filt_tb", data=meth_filt_tb)
save_("cov_filt_tb", data=cov_filt_tb)

## preprocessing
beta_cov_gs_tb <- meth_filt_tb %>%
  dplyr::rename(seqnames=chr) %>%
  select(-strand) %>%
  left_join(
    region_annotation %>%
      as.data.frame %>%
      as_tibble %>%
      select(seqnames, start, locus_identifier),
    by=c("seqnames", "start")
  ) %>%
  gather(
    "sample",
    "beta",
    -seqnames, -start, -locus_identifier,
  ) %>%
  mutate(sample=gsub("X", "", sample)) %>%
  mutate(
    protocol=sapply(sample, function(s){
      str_split(s, "\\.")[[1]][2]
    })
  ) %>%
  mutate(
    workflow=sapply(sample, function(s){
      str_split(s, "\\.")[[1]][4]
    })
  ) %>%
  mutate(
    sample=sapply(sample, function(s){
      str_split(s, "\\.")[[1]][3]
    })
  ) %>%
  left_join(
    cov_filt_tb %>%
      dplyr::rename(seqnames=chr) %>%
      select(-strand) %>%
      gather(
        "sample",
        "cov",
        -seqnames, -start,
      ) %>%
      mutate(sample=gsub("X", "", sample)) %>%
      mutate(
        protocol=sapply(sample, function(s){
          str_split(s, "\\.")[[1]][2]
        })
      ) %>%
      mutate(
        workflow=sapply(sample, function(s){
          str_split(s, "\\.")[[1]][4]
        })
      ) %>%
      mutate(
        sample=sapply(sample, function(s){
          str_split(s, "\\.")[[1]][3]
        })
      ),
    by=c("protocol", "workflow", "sample", "seqnames", "start")
  ) %>%
  left_join(
    meth_gs_tb %>%
      select(sample, locus_identifier, lower, upper, mid_interval, lid),
    by=c("sample", "locus_identifier")
  ) %>%
  select(lid, sample, protocol, workflow, beta, lower, upper, cov, everything()) %>%
  # region_annotation already considered the 5% flanking.
  # mutate(
  #   upper=pmin(upper+0.05, 1),
  #   lower=pmax(lower-0.05, 0),
  # ) %>%
  filter(!is.na(upper)) %>%
  mutate(
    ref=(upper+lower)/2
  )

beta_cov_gs_tb$protocol =  replace_prot_name_(beta_cov_gs_tb$protocol)
beta_cov_gs_tb$workflow =  replace_wf_name_(beta_cov_gs_tb$workflow)

save_("beta_cov_gs_tb", data=beta_cov_gs_tb)
