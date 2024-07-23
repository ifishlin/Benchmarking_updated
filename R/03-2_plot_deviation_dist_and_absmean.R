## Configuration
analysis_name <- "03-2_plot_deviation_dist_and_absmean"
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
################################################
beta_cov_gs_ds_tb <- read_("beta_cov_gs_tb", "03-1_calc_beta_cov_gs")
beta_cov_gs_ds_tb$protocol =  factor(beta_cov_gs_ds_tb$protocol, levels = protocols)

## plot overview of measurements:
################################################
sorting_gc_loci_tb <- meth_gs_tb %>%
  dplyr::group_by(lid) %>%
  dplyr::summarize(mean_mid_interval=mean(mid_interval)) %>%
  dplyr::arrange(-mean_mid_interval) %>%
  dplyr::mutate(sorting=1:length(mean_mid_interval)) 

##
selected_loci = c("r15", "m8", "m3", "m4", "m6", "m12")
beta_cov_gs_ds_tb %>% filter(lid %in% selected_loci)

## plot distance to consensus corridor by protocol:
################################################
beta_at_gs_plot <- function(plot_cov=FALSE, incl_recommended_loci=TRUE, use_selected_loci=FALSE, prot){
  
  plot_cov=FALSE
  incl_recommended_loci=TRUE
  use_selected_loci=TRUE

  beta_cov_gs_tb_ <- beta_cov_gs_ds_tb[beta_cov_gs_ds_tb$protocol==prot,]
  
  if(use_selected_loci){
    beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>% filter(lid %in% selected_loci)
  }else if(!incl_recommended_loci){
    beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
      filter(grepl("m", lid))    
  }

  if(plot_cov){
      beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
          mutate(cov_max20=ifelse(cov>20, 20, cov))
  }
  
  if(use_selected_loci){
    intervel_size=28
    dodge_dist=0.7    
  }else if(incl_recommended_loci){
    intervel_size=16
    dodge_dist=0.8
  }else{
    intervel_size=20
    dodge_dist=0.5
  }
  
  plot_ <- beta_cov_gs_tb_ %>%
    left_join(sorting_gc_loci_tb, by="lid") %>%
    mutate(dinterval=ifelse(beta>upper, upper, ifelse(beta<lower, lower, NA))) %>%
    ggplot() +
    geom_segment(
      aes(
        y=lower, yend=upper,
        x=reorder(lid, sorting), xend=reorder(lid, sorting)
      ),
      size=intervel_size,
      color="grey48",
      alpha=0.5
    ) +
    geom_linerange(
      aes(
        ymin=beta, ymax=dinterval,
        x=reorder(lid, sorting),
        color=workflow
      ),
      position=position_dodge(width=dodge_dist)
    )
  if (plot_cov){
    plot_ <- plot_ +
      geom_point(
        aes(
          reorder(lid, sorting), 
          beta, 
          color=workflow,
          size=cov_max20
        ),
        position=position_dodge(width=dodge_dist),
        alpha=0.75
      )
  }else {
    plot_ <- plot_ +
      geom_point(
        aes(
          reorder(lid, sorting), 
          beta, 
          color=workflow
        ),
        position=position_dodge(width=dodge_dist),
        size=1.5
        #size=0.3
      )
  }
  plot_ <- plot_ +
    #scale_color_brewer(palette="Spectral") +
    color_palette_color() +
    color_palette_fill() +
    facet_grid(rows=vars(sample)) +
    scale_y_continuous(breaks=c(0, 0.5, 1)) +
    xlab(paste0(prot, " gold-standard annotated loci")) +
    ylab("methylation") +
    theme(
      panel.border=element_rect(fill=NA),
      strip.background.y = element_blank(),
      panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
      legend.position = "none"
    )
  plot_
  return(plot_)
}

## Plot
for(prot in protocols){
  save_(
    paste0("beta_selected_gs_loci_", prot),
    plot=beta_at_gs_plot(
      plot_cov=FALSE,
      incl_recommended_loci=FALSE,
      use_selected_loci = TRUE,
      prot=prot
    ),
    use_pdf=TRUE,
    width=7.5,
    height=3.2
  )  
}
  
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

## Save
beta_cov_gs_ds_tb %>%
  writexl::write_xlsx(path = file.path(data_dir_, "beta_gs_dev.xlsx"))

## Mean deviation of five protocols
plot_gs_abs_metric_condensed <- function(var, title=NA, mean_lab="mean abs", median_lab="median abs"){

  var = "dev"
  title="deviation from CI"
  mean_lab="mean abs"
  
  if (is.na(title)){
    title <- var
  }
  
  beta_cov_gs_ds_tb_ <- beta_cov_gs_ds_tb %>%
    dplyr::rename(var_=UQ(sym(var))) %>%
    dplyr::mutate(c_or_n=ifelse(sample %in% c("5N", "6N"), "N", "T")) %>%
    filter(!is.na(var_))

  mean_tb <- beta_cov_gs_ds_tb_ %>%
    dplyr::select(sample, protocol, workflow, lid, var_) %>%
    group_by(protocol, workflow) %>%
    summarize(
      mean_abs=mean(abs(var_)),
      median_abs=median(abs(var_))
    ) %>% ungroup()
      
  mean_tb_sample <- beta_cov_gs_ds_tb_ %>%
    dplyr::select(sample, protocol, sample, workflow, lid, var_) %>%
    group_by(protocol, workflow, sample) %>%
    summarize(
      mean_abs=mean(abs(var_)),
      median_abs=median(abs(var_))
    ) %>% ungroup()
  
  tb_ = data.frame()
  tb_c_or_n_ = data.frame()
  
  for(p in protocols){
    mean_tb_ = mean_tb %>% filter(protocol==p) 
    seq = seq(1, 10, 10/nrow(mean_tb_)) 
    mean_tb_ <- mean_tb_ %>% arrange(mean_abs) %>% mutate(x=seq)
    tb_ = rbind(tb_, mean_tb_)
    
    target <- mean_tb_$workflow # order
    
    mean_tb_c_or_n_ = mean_tb_sample %>% filter(sample=="5N", protocol==p) 
    tb_5N_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="N", s_id="5")
    
    mean_tb_c_or_n_ = mean_tb_sample %>% filter(sample=="5T", protocol==p)
    tb_5T_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="T", s_id="5") 
    
    mean_tb_c_or_n_ = mean_tb_sample %>% filter(sample=="6N", protocol==p) 
    tb_6N_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="N", s_id="6")
    
    mean_tb_c_or_n_ = mean_tb_sample %>% filter(sample=="6T", protocol==p)
    tb_6T_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="T", s_id="6")     
    
    tb_c_or_n_ = rbind(tb_c_or_n_, tb_5N_, tb_5T_, tb_6N_, tb_6T_) 
  }
  
  npg_color <- c(
    "#E64B35","#4DBBD5",
    "#00A087","#3C5488",
    "#F39B7F","#8491B4",
    "#91D1C2","#DC0000",
    "#7E6148","#B09C85",  
    "#EE766F","#2EB7BE"
  )
  
  mean_plot <- ggplot() +
    geom_point(
      data=tb_,
      aes(
        x, mean_abs,
      ),
      position = position_dodge(width=1),
      size=3
    ) +
    geom_point(
      data=tb_,
      aes(
        x, mean_abs,
        color=workflow
      ),
      position = position_dodge(width=1),
      size=2.6
    ) +
    geom_point( #geom_boxplot
      data=tb_c_or_n_,
      aes(
        x, mean_abs,
        shape=s_id,
        color=c_or_n
      ),
      size=1
    ) +
    # geom_boxplot( #geom_boxplot
    #   data=tb_c_or_n_,
    #   aes(
    #     x, mean_abs,
    #     color=workflow
    #   ),
    #   size=1
    # ) +    
    ylab(paste0(mean_lab, " ", title)) +
    xlab("") + 
    scale_color_manual(values=npg_color) +
    scale_fill_manual(values=npg_color) +
    #color_palette_color() + 
    #color_palette_fill() +    
    theme(
      panel.border=element_rect(fill=NA),
      panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
      strip.background.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      legend.position = "right"
    ) + facet_wrap( ~ protocol, ncol=5, scales="free_x") 
  
  mean_plot = mean_plot + ylim(c(0, 0.12)) + 
    geom_hline(yintercept=c(0, 0.025, 0.05, 0.075, 0.1), linetype="dashed", size=0.1) 
  mean_plot
  
  save_(
    paste0(var, "_mean_abs_shape_color_condensed"),
    plot=mean_plot,
    use_pdf=TRUE,
    width=7.5,
    height=3.5
  )    
}

## Plot
plot_gs_abs_metric_condensed(
  "dev", 
  title="deviation from CI"
)
