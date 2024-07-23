## Configuration
analysis_name <- "03-5_Testing_beta_underestimate"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(methrix)
library(tidyverse)
library(ggplot2)
library(ggbeeswarm)

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


## Load data
###############################################$
beta_cov_gs_ds_tb <- read_("beta_cov_gs_tb", "03-1_calc_beta_cov_gs")
beta_cov_gs_ds_tb$protocol =  factor(beta_cov_gs_ds_tb$protocol, levels = protocols)

## plot overview of measurements:
################################################
sorting_gc_loci_tb <- meth_gs_tb %>%
  dplyr::group_by(lid) %>%
  dplyr::summarize(mean_mid_interval=mean(mid_interval)) %>%
  dplyr::arrange(-mean_mid_interval) %>%
  dplyr::mutate(sorting=1:length(mean_mid_interval)) 
  
## plot deviation from consensus corridor:
####################################################
beta_cov_gs_ds_tb <- beta_cov_gs_ds_tb %>%
  dplyr::mutate(dev=apply(cbind(beta, lower, upper), 1, 
                   function(r){
                     m=r[1]
                     lower=r[2]
                     upper=r[3]
                     return(
                       ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                     )
                   })
  )

tb = data.frame()

for(sp in c("5N", "5T", "6N", "6T")){
  for(prot in protocols){
    region = beta_cov_gs_ds_tb %>% filter(ref > 0.9, protocol == prot, sample == sp)
    
    overestimate = region %>% filter(dev > 0)
    underestimate = region %>% filter(dev < 0)
    correct = region %>% filter(dev == 0)
    incorrect = region %>% filter(dev != 0)
    tb = rbind(tb,c(prot, sp, "hyper", nrow(correct)
                    , nrow(incorrect)
                    , nrow(overestimate)
                    , nrow(underestimate)))
    
    region = beta_cov_gs_ds_tb %>% filter(ref < 0.1, protocol == prot, sample==sp)
    overestimate = region %>% filter(dev > 0)
    underestimate = region %>% filter(dev < 0)
    correct = region %>% filter(dev == 0)
    incorrect = region %>% filter(dev != 0)
    tb = rbind(tb,c(prot, sp, "hypo", nrow(correct), nrow(incorrect), nrow(overestimate), nrow(underestimate)))
    
    region = beta_cov_gs_ds_tb %>% filter(ref >= 0.1, ref <= 0.9, protocol == prot, sample==sp)
    overestimate = region %>% filter(dev > 0)
    underestimate = region %>% filter(dev < 0)
    correct = region %>% filter(dev == 0)
    incorrect = region %>% filter(dev != 0)
    tb = rbind(tb,c(prot, sp, "middle", nrow(correct), nrow(incorrect), nrow(overestimate), nrow(underestimate)))
  }
}

colnames(tb) <- c("protocol", "sample", "type", "corr", "incorr", "overestimate",  "underestimate")
tb = tb %>% dplyr::mutate(corr = as.integer(tb$corr), incorr = as.integer(tb$incorr),
                     overestimate = as.integer(tb$overestimate), underestimate = as.integer(tb$underestimate))

tb2 = tb %>% dplyr::filter(type=="hyper") %>% dplyr::group_by(protocol) %>% dplyr::summarise(over = sum(overestimate), under = sum(underestimate))
tb3 = tb %>% dplyr::group_by(protocol, type) %>% dplyr::summarise(corr = sum(corr), incorr = sum(incorr),
                                                                  over = sum(overestimate), under = sum(underestimate))

tb3 = tb3 %>% dplyr::mutate('correct%' = corr/(incorr+corr), 'under%' = under/incorr) %>% 
  dplyr::select(protocol, type, corr, incorr, 'correct%', over, under, 'under%')

library("writexl")
tb3 %>%write_xlsx(path = file.path(data_dir_, "deviation.xlsx"))


beta_cov_gs_ds_tb = beta_cov_gs_ds_tb %>% mutate(level=ifelse(ref>0.8, "H", ifelse(ref>0.2, "M", "L")))
beta_cov_gs_ds_tb$level = factor(beta_cov_gs_ds_tb$level, levels = c("H","M","L"))
e = beta_cov_gs_ds_tb %>% select("lid", "sample", "protocol", "workflow", "locus_identifier", "ref", "dev", "level", "cov")

# Protocol(WGBS), level=A, type=part =>  statistic in paper
y = lapply(protocols, function(x){
  lapply(c("L", "M", "H", "A"), function(l){
    df = data.frame()

    #methylation level
    if(l=="A"){
       c = e %>% filter(protocol==x) 
    }else{
       c = e %>% filter(protocol==x, level==l)
    }
    
    #outside or all
    print(c$dev)
    r = t.test(c$dev, alternative = "less")
    df = rbind(df, c(x, l, "all", r$statistic, r$parameter, r$stderr, r$conf.int, r$p.value, r$estimate, r$alternative))
    colnames(df) = c("protocol", "level", "type","statistic", "parameter", "stderr", "conf.int_1", "conf.int_2", "pvalue", "estimate", "alternative")
    
    c = c %>% filter(protocol==x, dev != 0)
    r = t.test(c$dev, alternative = "less")
    df = rbind(df, c(x, l, "part", r$statistic, r$parameter, r$stderr, r$conf.int, r$p.value, r$estimate, r$alternative))
    colnames(df) = c("protocol", "level", "type","statistic", "parameter", "stderr", "conf.int_1", "conf.int_2", "pvalue", "estimate", "alternative")
    df
    
  }) %>% bind_rows() 
}) %>% bind_rows()    

save_("underestimate_td", data=y)

y %>%
  writexl::write_xlsx(path = file.path(data_dir_, "underestimate.xls"))
