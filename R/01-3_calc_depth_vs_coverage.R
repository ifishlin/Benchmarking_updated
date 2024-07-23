## Configuration
analysis_name <- "01-3_calc_depth_vs_coverage"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)

## Main
for(p in protocols_int){
  # STEP 1, Load methrix objects and extract the coverage matrix
  meth = methrix::load_HDF5_methrix(file.path(methrix_obj_dir, workflows_int[1]))
  meth = meth[,which(meth@colData$method==p)]

  for(c in workflows_int[2:length(workflows_int)]){
    meth_ = methrix::load_HDF5_methrix(file.path(methrix_obj_dir, c))
    meth_ = meth_[,which(meth_@colData$method==p)]
    meth = meth %>% combine_methrix(meth_, by="col")
  }

  cov_filt_tb <- meth %>%
    get_matrix(type="C", add_loci=T) %>%
    as_tibble

  rm(meth)
  rm(meth_)
  save_(paste0("cov_filt_tb_",p), data=cov_filt_tb)
  
  # STEP 2, Transfer wide format to long format
  cov_tb = lapply(4:length(cov_filt_tb), function(s){
    sub_m = cov_filt_tb[,c(1,2,3,s)]
    sub_m <- sub_m %>%
      dplyr::rename(seqnames=chr) %>%
      dplyr::select(-strand) %>%
      gather(
        "sample",
        "cov",
        -seqnames, -start,
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
      select(sample, workflow, cov, everything()) %>%
      dplyr::rename(chr=seqnames) %>%
      dplyr::rename(pos=start)
  }) %>% bind_rows()  
  
  rm(cov_filt_tb)
  cov_tb = cov_tb %>% dplyr::filter(chr != "chrM") %>% mutate(cov = ifelse(is.na(cov), 0, cov))
  save_(paste0("cov_tb_",p), data=cov_tb)
  
  ## STEP 3, Calculate accumulation under the coverage threshold.
  # cume_dist_min <- function(x)
  # {
  #   rank(x, ties.method = "max", na.last = "keep")/sum(!is.na(x))
  # }
  # 
  # cov_percent_rank_tb = cov_tb %>%
  #   dplyr::select(workflow, cov) %>%
  #   group_by(workflow) %>%
  #   dplyr::mutate(cume_dist_min=1-cume_dist_min(cov)) %>%
  #   ungroup
  # 
  # save_(paste0("cov_percent_rank_tb_", p) , data=cov_percent_rank_tb)
  # rm(cov_tb)
  # 
  # tb = data.frame()
  # for(w in workflows_int){
  #   cov_percent_rank_distinct_tb = cov_percent_rank_tb %>% filter(workflow==w) %>%
  #     dplyr::select(cov, cume_dist_min) %>%
  #     distinct(cov, .keep_all=TRUE) %>% mutate(workflow=w)
  #   tb =  rbind(tb, cov_percent_rank_distinct_tb)
  # }
  # 
  # save_(paste0("cov_percent_rank_distinct_tb_", p), data=tb)
  # rm(cov_percent_rank_tb)
  # rm(cov_percent_rank_distinct_tb)
}
