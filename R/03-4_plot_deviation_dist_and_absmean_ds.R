## Configuration
analysis_name <- "03-2_plot_deviation_dist_and_absmean_ds"
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
beta_cov_gs_ds_tb <- read_("beta_cov_gs_tb", "03-1_calc_beta_cov_gs_ds")
beta_cov_gs_ds_tb$protocol =  factor(beta_cov_gs_ds_tb$protocol, levels = protocols)
beta_cov_gs_ds_tb$workflow =  factor(beta_cov_gs_ds_tb$workflow, levels = workflows)
## plot overview of measurements:
################################################
sorting_gc_loci_tb <- meth_gs_tb %>%
  dplyr::group_by(lid) %>%
  dplyr::summarize(mean_mid_interval=mean(mid_interval)) %>%
  dplyr::arrange(-mean_mid_interval) %>%
  dplyr::mutate(sorting=1:length(mean_mid_interval)) 

mPalette <- c("#4DBBD5FF","#00A087FF","#3C5488FF","#F39B7FFF","#DC0000FF","#7E6148FF")

## plot distance to consensus corridor by protocol:
################################################
## plot distance to consensus corridor by protocol:
################################################
beta_at_gs_plot <- function(plot_cov=FALSE, incl_recommended_loci=TRUE, use_selected_loci=FALSE, prot){
  
  # plot_cov=FALSE
  # incl_recommended_loci=TRUE
  # use_selected_loci=TRUE
  
  beta_cov_gs_tb_ <- beta_cov_gs_ds_tb[beta_cov_gs_ds_tb$protocol==prot,] %>% filter(lid %in% sorting_gc_loci_tb$lid[1:23])
  
  # if(use_selected_loci){
  #   beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>% filter(lid %in% selected_loci)
  # }else if(!incl_recommended_loci){
  #   beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
  #     filter(grepl("m", lid))    
  # }else{
  #   beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
  #     filter(grepl("r", lid))
  # }
  
  # if(plot_cov){
  #     beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
  #         mutate(cov_max20=ifelse(cov>20, 20, cov))
  # }
  
  # if(use_selected_loci){
  #   intervel_size=28
  #   dodge_dist=0.7    
  # }else if(incl_recommended_loci){
  #   intervel_size=16
  #   dodge_dist=0.8
  # }else{
  #   intervel_size=20
  #   dodge_dist=0.5
  # }
  
  intervel_size=12
  dodge_dist=0.8
  
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
        size=1.2
        #size=0.3
      )
  }
  plot_ <- plot_ +
    #scale_color_brewer(palette="Spectral") +
    scale_colour_manual(values=mPalette) + 
    scale_fill_manual(values=mPalette) +
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

## plot distance to consensus corridor by protocol:
################################################
beta_at_gs_plot_last_half <- function(plot_cov=FALSE, incl_recommended_loci=TRUE, use_selected_loci=FALSE, prot){
  
  # plot_cov=FALSE
  # incl_recommended_loci=TRUE
  # use_selected_loci=TRUE
  
  beta_cov_gs_tb_ <- beta_cov_gs_ds_tb[beta_cov_gs_ds_tb$protocol==prot,] %>% filter(lid %in% sorting_gc_loci_tb$lid[23:46])
  
  # if(use_selected_loci){
  #   beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>% filter(lid %in% selected_loci)
  # }else if(!incl_recommended_loci){
  #   beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
  #     filter(grepl("m", lid))    
  # }else{
  #   beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
  #     filter(grepl("r", lid))
  # }
  
  # if(plot_cov){
  #     beta_cov_gs_tb_ <- beta_cov_gs_tb_ %>%
  #         mutate(cov_max20=ifelse(cov>20, 20, cov))
  # }
  
  # if(use_selected_loci){
  #   intervel_size=28
  #   dodge_dist=0.7    
  # }else if(incl_recommended_loci){
  #   intervel_size=16
  #   dodge_dist=0.8
  # }else{
  #   intervel_size=20
  #   dodge_dist=0.5
  # }
  
  intervel_size=12
  dodge_dist=0.8
  
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
        size=1.2
        #size=0.3
      )
  }
  plot_ <- plot_ +
    #scale_color_brewer(palette="Spectral") +
    scale_colour_manual(values=mPalette) + 
    scale_fill_manual(values=mPalette) +
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
for(prot in c("WGBS")){
  save_(
    paste0("beta_selected_gs_loci_all_1st_", prot),
    plot=beta_at_gs_plot(
      plot_cov=FALSE,
      incl_recommended_loci=FALSE,
      use_selected_loci = TRUE,
      prot=prot
    ),
    use_pdf=TRUE,
    width=11,
    height=4
  )
  save_(
    paste0("beta_selected_gs_loci_all_2nd_", prot),
    plot=beta_at_gs_plot_last_half(
      plot_cov=FALSE,
      incl_recommended_loci=FALSE,
      use_selected_loci = TRUE,
      prot=prot
    ),
    use_pdf=TRUE,
    width=11,
    height=4
  )
}
 
