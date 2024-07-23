## Configuration
analysis_name <- "03-3_plot_beeswarm_gs"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(methrix)
library(tidyverse)
library(ggplot2)
library(ggbeeswarm)
library(ggpubr)

## Annotation
#######################################################
region_annotation <- readRDS("gold_standard/data/region_annotation.rds") %>% as_tibble
region_annotation$start <- region_annotation$probe_pos
region_annotation$end <- region_annotation$probe_pos+1
regions <- region_annotation[,c("seqnames", "start", "end")]
colnames(regions) <-c("chr", "start", "end")
regions <- GenomicRanges::makeGRangesFromDataFrame(regions, keep.extra.columns = T, ignore.strand = T)

## Load data
###############################################$
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

## 1. grid by workflow and sample 2.condense samples only grid on workflow
##########################
plot_gs_comp_metric_condensed <- function(var, prot, title=NA){
  var = "dev"
  prot = "WGBS"
  title = "deviation from CI"
   if (is.na(title)){
    title <- var
  }
  beta_cov_gs_ds_tb_ <- beta_cov_gs_ds_tb %>% 
    dplyr::rename(var_=UQ(sym(var))) %>%
    dplyr::filter(!is.na(var_))
  
  beta_cov_gs_ds_tb_ = beta_cov_gs_ds_tb_ %>% dplyr::filter(protocol==prot)
  
  beta_cov_gs_ds_tb_$workflow <- replace_wf_name_(beta_cov_gs_ds_tb_$workflow)
  beta_cov_gs_ds_tb_$protocol <- replace_prot_name_(beta_cov_gs_ds_tb_$protocol)
  beta_cov_gs_ds_tb_$protocol =  factor(beta_cov_gs_ds_tb_$protocol, levels = protocols)
  
  a = beta_cov_gs_ds_tb_ %>% dplyr::filter(var_==0) %>% dplyr::group_by(workflow) %>% dplyr::summarise(n = n())
  b = beta_cov_gs_ds_tb_ %>% dplyr::filter(var_!=0) %>% dplyr::group_by(workflow) %>% dplyr::summarise(n = n()) 
  frac = round(b$n/(a$n+b$n),2)
  wn = a$workflow
  c = paste0(as.character(frac*100), "%") 
  
  beta_cov_gs_ds_tb_ = beta_cov_gs_ds_tb_ %>% mutate(level=ifelse(ref>0.8, "H", ifelse(ref>0.2, "M", "L")))
  beta_cov_gs_ds_tb_$level = factor(beta_cov_gs_ds_tb_$level, levels = c("H","M","L"))
  
  data = beta_cov_gs_ds_tb_ %>% dplyr::filter(var_!=0) %>% dplyr::mutate(cancer=ifelse(sample %in% c("5N", "6N"), "C", "T")) %>%
    dplyr::mutate(sep=paste0(workflow, "_",cancer))
  
  # dist_plot <- data %>% dplyr::filter(level=="M") %>%
  #   ggplot(aes(x = sep, y = var_, color=cancer)) + 
  #   geom_flat_violin() + geom_beeswarm(size=0.4)
  # 
  # dist_plot  
  # 
  # dist_plot2 <- data %>% dplyr::filter(level=="L") %>%
  #   ggplot(aes(x = sep, y = var_, color=cancer)) + 
  #   geom_flat_violin() + geom_beeswarm(size=0.4)
  # 
  # dist_plot2
  
  
  dist_plot <- data %>%
    ggplot(aes(x = sep, y = var_, color=level)) +
    geom_boxplot(outlier.size=1, notch=FALSE, outlier.shape=NA) +
    #geom_beeswarm(size=0.4) +
    #geom_violin(trim=FALSE) +
    # color_palette_color() +
    # color_palette_fill() +
    unified_pg +
    theme(#axis.text.x = element_text(angle = 45, hjust = 1),
      #axis.title.x = element_blank(),
      #axis.text.x = element_blank(),
      #axis.ticks.x = element_blank(),
      legend.position = 'none') +
    scale_x_discrete(labels= rep(c("N", "T"), length(unique(beta_cov_gs_ds_tb_$workflow)))) +
    ylab("deviation from CI")  + geom_hline(yintercept=0, linetype="dashed", size=0.5) + xlab("") +
    scale_shape_manual(values=c(22, 23)) + #scale_color_manual(values=c("red", "grey", "green")) + 
    geom_point(aes(fill = level), size = 0.1, shape = 21, alpha = 0.5, position = position_jitterdodge()) 
  
  dist_plot
  
  # fraction
  c_tb = t(as.data.frame(c))
  
  workflow_list = sort(unique(beta_cov_gs_ds_tb_$workflow))
  colnames(c_tb) <- workflow_list
  #colnames(c_tb) <- c("BAT", "Biscuit", "Bismark", "BSBolt", "bwa-meth", "FAME", "gemBS", "GSNAP", "methylCtools", "methylpy")
  rownames(c_tb) <- c("% Outside CI")
  
  stable = ggtexttable(c_tb, rows = NULL, 
                       theme = ttheme("mOrange"))
  
  stable

  frac_ = frac
  tb = as.data.frame(frac) %>% 
    dplyr::mutate(workflow=workflow_list) %>%
    dplyr::mutate(in_CI="N")
  frac_ = 1 - frac
  tb2 = as.data.frame(frac_) %>% dplyr::rename(frac=frac_) %>%
    dplyr::mutate(workflow=workflow_list) %>%
    dplyr::mutate(in_CI="Y")
  tb = rbind(tb, tb2)
  
  tb <- tb %>% 
    dplyr::arrange(desc(tb)) %>%
    dplyr::mutate(prop = frac / sum(tb$frac) *100) %>%
    dplyr::mutate(ypos = cumsum(prop)- 0.5*prop )  
  
  g = ggplot(tb, aes(x="", y=prop, fill=in_CI)) +
    geom_bar(stat="identity", width=1, color="white") +
    coord_polar("y", start=0) +
    theme_void() + scale_fill_manual(values=c("#d4d4d4","#9a9a9a")) +
    theme(legend.position="none")  + facet_wrap(~workflow, ncol=10) 
    #+ geom_text(aes(y = ypos, label = frac), color = "white", size=6) 

  g
  
  a = ggarrange(dist_plot, g,
                ncol = 1, nrow = 2,
                heights = c(1, 0.21))
  
  a  
  
  #WGBS width=7.5, height=3, else width=5, height=2
  save_(
    paste0(var, "_dist_sample_",prot, "_boxplot"),
    plot=dist_plot,
    use_pdf = TRUE,
    width=7.5,
    height=3
  )     
  
  save_(
    paste0(var, "_dist_sample_pie_",prot, ""),
    plot=g,
    use_pdf = TRUE,
    width=5,
    height=2
  )     

  save_(
    paste0(var, "_dist_sample_pie_",prot, "_frac"),
    plot=stable,
    use_pdf = TRUE,
    width=7.5,
    height=4
  ) 
 }

# what I need
for(prot in protocols){
  plot_gs_comp_metric_condensed(
    "dev", 
    prot,
    title="deviation from CI"
  )
}
