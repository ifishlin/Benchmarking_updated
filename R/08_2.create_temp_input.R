## Configuration
analysis_name <- "09_1.create_CC_input_cov"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(foreach)
library(doParallel)
library(methrix)

for(c in c(paste0("chr", 1:22))){
  
  df = lapply(workflows, function(x){
    meth <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, x))
    meth_p = meth[,meth$method %in% c("WGBS", "SWIFT", "EMSEQ")]
    meth_filt = subset_methrix(meth_p, contigs=c)
    ## Retrieve methylation status and coverage
    meth_filt_tb <- meth_filt %>%
      get_matrix(add_loci=TRUE) %>%
      as_tibble 
    
    loci_annot = meth_filt_tb %>% dplyr::select(chr, start, strand)
    meth_filt_tb = meth_filt_tb %>% dplyr::select(-chr, -start, -strand)
    
    cov_filt_tb <- meth_filt %>%
      get_matrix(type = "C") %>%
      as_tibble 
    
    meth_filt_tb[cov_filt_tb < COV_THRESHOLD] = NA
    meth_filt_tb = cbind(loci_annot, meth_filt_tb)
  }) %>% bind_cols(.)
  
  patient_5N_idx = grep("5N", colnames(df))
  df_5N = df[c(1,2,3, patient_5N_idx)]
  colnames(df_5N) = c("chr", "start", "strand", colnames(df_5N)[4:length(df_5N)])
  patient_5T_idx = grep("5T", colnames(df))
  df_5T = df[c(1,2,3, patient_5T_idx)]
  colnames(df_5T) = c("chr", "start", "strand", colnames(df_5T)[4:length(df_5T)])
  patient_6N_idx = grep("6N", colnames(df))
  df_6N = df[c(1,2,3, patient_6N_idx)]
  colnames(df_6N) = c("chr", "start", "strand", colnames(df_6N)[4:length(df_6N)])
  patient_6T_idx = grep("6T", colnames(df))
  df_6T = df[c(1,2,3, patient_6T_idx)]
  colnames(df_6T) = c("chr", "start", "strand", colnames(df_6T)[4:length(df_6T)])
  
  save_(paste0("df_cov10_5N_", c), data=df_5N)
  save_(paste0("df_cov10_5T_", c), data=df_5T)
  save_(paste0("df_cov10_6N_", c), data=df_6N)
  save_(paste0("df_cov10_6T_", c), data=df_6T)
  
}








