## Configuration
analysis_name <- "02-5_calc_genome_wide_deivation_debug"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)

for(workflow in workflows){
  print(workflow)
  print(format(Sys.time(), "%a %b %d %X %Y"))
  
  df <- data.frame(matrix(numeric(), ncol = 10))
  meth_base <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, workflow))
  
  for(sample in c("5N", "5T", "6N", "6T")){
    for(chr in paste0("chr", 1:22)){
      wg_cc <- read_(
        paste0("df_merged_",sample,"_N15_", chr),
        paste0("create_CC_parallel_", sample,"_N15")
      ) %>% mutate(number=as.numeric(number)) # %>% filter(number != 0)
      
      meth = meth_base[,meth_base$sample==sample]
      
      meth_filt = subset_methrix(meth, contigs=chr)
      meth_filt_tb <- meth_filt %>%
        get_matrix(add_loci=TRUE) %>%
        as_tibble 
      
      colnames(meth_filt_tb)[grep("EMSEQ", colnames(meth_filt_tb))] = "EMSEQ_beta"
      colnames(meth_filt_tb)[grep("SWIFT", colnames(meth_filt_tb))] = "SWIFT_beta"
      colnames(meth_filt_tb)[grep("\\.WGBS", colnames(meth_filt_tb))] = "WGBS_beta"
      colnames(meth_filt_tb)[grep("TWGBS", colnames(meth_filt_tb))] = "TWGBS_beta"
      colnames(meth_filt_tb)[grep("PBAT", colnames(meth_filt_tb))] = "PBAT_beta"
      
      #combined = cbind(meth_filt_tb[1000:1010,], wg_cc[1000:1010,4:6])
      combined = cbind(meth_filt_tb[], wg_cc[4:6]) %>% filter(number != 0) %>% dplyr::select(-number)
      
      combined$lower = as.numeric(combined$lower)
      combined$upper = as.numeric(combined$upper)
      combined = combined %>% mutate(dist=upper-lower) # %>% filter(dist<0.6)
      
      combined <- combined %>%
        mutate(EMSEQ_dev=apply(cbind(EMSEQ_beta, lower, upper), 1, 
                         function(r){
                           m=r[1]
                           lower=r[2]
                           upper=r[3]
                           return(
                             ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                           )
                         })        
        ) %>%
        mutate(SWIFT_dev=apply(cbind(SWIFT_beta, lower, upper), 1, 
                               function(r){
                                 m=r[1]
                                 lower=r[2]
                                 upper=r[3]
                                 return(
                                   ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                                 )
                               })        
        ) %>%
        mutate(WGBS_dev=apply(cbind(WGBS_beta, lower, upper), 1, 
                               function(r){
                                 m=r[1]
                                 lower=r[2]
                                 upper=r[3]
                                 return(
                                   ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                                 )
                               })        
        ) %>% 
        mutate(TWGBS_dev=apply(cbind(TWGBS_beta, lower, upper), 1, 
                               function(r){
                                 m=r[1]
                                 lower=r[2]
                                 upper=r[3]
                                 return(
                                   ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                                 )
                               })        
        )
      
      if(any(grepl("PBAT", colnames(combined)))){
        combined <- combined %>%
          mutate(PBAT_dev=apply(cbind(PBAT_beta, lower, upper), 1, 
                                function(r){
                                  m=r[1]
                                  lower=r[2]
                                  upper=r[3]
                                  return(
                                    ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                                  )
                                })        
          )  
      } 
      
      idx= grep("dev", colnames(combined))
      combined = combined[idx]
      colnames(combined) = paste0(sample, "_", workflow, "_", colnames(combined))
      a = colMeans(abs(combined), na.rm = TRUE)
      b = colSums(!is.na(combined))
      df = rbind(df, c(a,b))
      
    }
  } 
  
  if(ncol(df) == 10){
    colnames(df) <- c(paste0(rep(c("mean"),5), "_",rep(c("EMSEQ", "SWIFT", "WGBS", "TWGBS", "PBAT"), 1)),
                      paste0(rep(c("count"),5), "_",rep(c("EMSEQ", "SWIFT", "WGBS", "TWGBS", "PBAT"), 1)))
  }else{
    colnames(df) <- c(paste0(rep(c("mean"),4), "_",rep(c("EMSEQ", "SWIFT", "WGBS", "TWGBS"), 1)),
                      paste0(rep(c("count"),4), "_",rep(c("EMSEQ", "SWIFT", "WGBS", "TWGBS"), 1)))    
  }
  
  save_(paste0("value_", workflow), data=df)
}
