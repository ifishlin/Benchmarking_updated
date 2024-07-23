## Configuration
analysis_name <- "03-4_Testing_ANOVA"
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


## Load data
################################################
beta_cov_gs_ds_tb <- read_("beta_cov_gs_tb", "03-1_calc_beta_cov_gs")
beta_cov_gs_ds_tb$protocol =  factor(beta_cov_gs_ds_tb$protocol, levels = protocols)


## plot deviation from consensus corridor:
####################################################
beta_cov_gs_ds_tb <- beta_cov_gs_ds_tb %>%
  mutate(dev=apply(cbind(beta, lower, upper), 1, 
                   function(r){
                     m=r[1]
                     lower=r[2]
                     upper=r[3]
                     return(
                       ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                     )
                   })
  )

beta_cov_gs_ds_tb = beta_cov_gs_ds_tb %>% select(protocol, workflow, sample, lid, beta, cov, ref, dev)
na_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(workflow!="methylpy")

normalize <- function(x, na.rm = TRUE) {
  return((x- min(x)) /(max(x)-min(x)))
}

na_removed$dev_normalized = normalize(na_removed$dev)
na_removed$cov_normalized = normalize(na_removed$cov)
na_removed$beta_normalized = normalize(na_removed$beta)

p = na_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
p
#lm(dev_normalized~cov_normalized+beta_normalized, data=na_removed)
one.way = aov(dev_normalized~workflow+sample+protocol, data=na_removed)
summary(one.way)

one.way = aov(dev_normalized~workflow+sample, data=na_removed)
summary(one.way)

kruskal.test(dev_normalized~workflow, data=na_removed)
kruskal.test(dev_normalized~sample, data=na_removed)
kruskal.test(dev_normalized~protocol, data=na_removed)

# cor(na_removed$cov, na_removed$dev, method = c("pearson"))
# cor(na_removed$cov, na_removed$dev, method = c("spearman"))
# cor(na_removed$beta, na_removed$dev, method = c("pearson"))
# cor(na_removed$beta, na_removed$dev, method = c("spearman"))

### WGBS only
na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol=="WGBS", workflow!="methylpy")
na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
# p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
# p2
one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
summary(one.way)

for(p in protocols){
  print(p)
  na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol==p, workflow!="methylpy")
  na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
  na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
  na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
  # p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
  # p2
  one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
  summary(one.way)  
  print(one.way)
}

### WGBS only
na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol=="WGBS", workflow!="methylpy")
na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
# p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
# p2
one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
summary(one.way)

### SWIFT only
na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol=="Swift", workflow!="methylpy")
na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
# p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
# p2
one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
summary(one.way)

### T-WGBS only
na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol=="T-WGBS", workflow!="methylpy")
na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
# p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
# p2
one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
summary(one.way)

### PBAT only
na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol=="PBAT", workflow!="methylpy")
na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
# p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
# p2
one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
summary(one.way)

### EM-seq only
na_wgbs_removed = beta_cov_gs_ds_tb[!is.na(beta_cov_gs_ds_tb$dev),] %>% filter(protocol=="EM-seq", workflow!="methylpy")
na_wgbs_removed$dev_normalized = normalize(na_wgbs_removed$dev)
na_wgbs_removed$cov_normalized = normalize(na_wgbs_removed$cov)
na_wgbs_removed$beta_normalized = normalize(na_wgbs_removed$beta)
# p2 = na_wgbs_removed %>% ggplot(aes(x=workflow, y=dev_normalized)) + geom_boxplot() 
# p2
one.way = aov(dev_normalized~sample+workflow, data=na_wgbs_removed)
summary(one.way)
