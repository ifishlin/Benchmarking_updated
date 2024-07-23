## Configuration
analysis_name <- "01-4_plot_depth_vs_coverage_debug"
config = file.path(getwd(), "0_project_setting.R")
source(config)

#read data
for(prot in c("WGBS", "SWIFT", "TWGBS", "EMSEQ")){
  ## ploting
  beta_cov_tb <- read_(
    paste0("cov_percent_rank_distinct_tb_", prot),
    "01-31_calc_depth_vs_coverage_improved_cmd"
  ) %>% filter(cov!=0)
  
  ## filling gaps in the front
  v = beta_cov_tb %>% filter(workflow=="Biscuit", cov==3)
  v = as.numeric(v$cume_dist_min)
  
  beta_cov_tb = beta_cov_tb %>% add_row(cov=1, cume_dist_min=v, workflow="Biscuit")
  beta_cov_tb = beta_cov_tb %>% add_row(cov=2, cume_dist_min=v, workflow="Biscuit")
  
  beta_cov_tb$workflow <- replace_wf_name_(beta_cov_tb$workflow)
  beta_cov_tb$workflow =  factor(beta_cov_tb$workflow, levels = workflows)
  
  g = beta_cov_tb %>% ggplot(aes(x=cov, y=cume_dist_min, color=workflow)) +
    geom_line() + #color_palette_color() + color_palette_fill() +
    scale_x_log10(breaks=c(1, 5, 10, 30, 50, 100, 200), limits=c(1, 200)) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='right') +
    geom_hline(yintercept=c(0,0.25,0.5,0.75,1), linetype="dashed", size=0.2) +
    geom_vline(xintercept=c(1, 5, 10, 30, 50, 100, 200), linetype="dashed", size=0.2) +
    color_palette_color() + color_palette_fill() + xlab("Cov") + ylab("%CpGs covered with coverage cut-off ")
  
  g
  
  save_(
    paste0("CpG_percetage_cov_thresold_log10_" ,prot),
    use_pdf=TRUE,
    plot=g,
    width=4.2,
    height=3.8
  )
  
  g = beta_cov_tb %>% ggplot(aes(x=cov, y=cume_dist_min, color=workflow)) +
    geom_line() + #color_palette_color() + color_palette_fill() +
    scale_x_continuous(breaks=c(1, 10, 30, 50, 80, 100, 200), limits=c(1, 200)) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none') +
    geom_hline(yintercept=c(0,0.25,0.5,0.75,1), linetype="dashed", size=0.1) +
    geom_vline(xintercept=c(1, 10, 30, 50, 80, 100, 200), linetype="twodash", size=0.1) +
    color_palette_color() + color_palette_fill() + xlab("Cov") + ylab("%CpGs covered with coverage cut-off ")
  
  save_(
    paste0("CpG_percetage_cov_thresold_" ,prot),
    use_pdf=TRUE,
    plot=g,
    width=3.5,
    height=3
  )
}

#read data
for(prot in c("PBAT")){
  ## ploting
  prot="PBAT"
  beta_cov_tb <- read_(
    paste0("cov_percent_rank_distinct_tb_", prot),
    "01-31_calc_depth_vs_coverage_improved_cmd"
  ) %>% filter(cov!=0)
  
  ## filling gaps in the front
  v = beta_cov_tb %>% filter(workflow=="Biscuit", cov==3)
  v = as.numeric(v$cume_dist_min)
  
  beta_cov_tb = beta_cov_tb %>% add_row(cov=1, cume_dist_min=v, workflow="Biscuit")
  beta_cov_tb = beta_cov_tb %>% add_row(cov=2, cume_dist_min=v, workflow="Biscuit")
  
  #color adjustion
  beta_cov_tb = beta_cov_tb %>% add_row(cov=1000, cume_dist_min=v, workflow="BAT")
  beta_cov_tb = beta_cov_tb %>% add_row(cov=1000, cume_dist_min=v, workflow="gemBS")
  
  beta_cov_tb$workflow <- replace_wf_name_(beta_cov_tb$workflow)
  beta_cov_tb$workflow =  factor(beta_cov_tb$workflow, levels = workflows)
  
  g = beta_cov_tb %>% ggplot(aes(x=cov, y=cume_dist_min, color=workflow)) +
    geom_line() + #color_palette_color() + color_palette_fill() +
    scale_x_log10(breaks=c(1, 5, 10, 30, 50, 100, 200), limits=c(1, 200)) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='right', legend.key = element_rect(fill = "white")) +
    geom_hline(yintercept=c(0,0.25,0.5,0.75,1), linetype="dashed", size=0.2) +
    geom_vline(xintercept=c(1, 5, 10, 30, 50, 100, 200), linetype="dashed", size=0.2) +
    color_palette_color() + color_palette_fill() + xlab("Cov") + ylab("%CpGs covered with coverage cut-off ") +
    guides(colour = guide_legend(override.aes = list(size=3, linetype=5, linewidth=2)))
  
  g
  
  save_(
    paste0("CpG_percetage_cov_thresold_log10_" ,prot, "_legend"),
    use_pdf=TRUE,
    plot=g,
    width=4.2,
    height=3.8
  )
  
  g = beta_cov_tb %>% ggplot(aes(x=cov, y=cume_dist_min, color=workflow)) +
    geom_line() + #color_palette_color() + color_palette_fill() +
    scale_x_continuous(breaks=c(1, 10, 30, 50, 80, 100, 200), limits=c(1, 200)) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none') +
    geom_hline(yintercept=c(0,0.25,0.5,0.75,1), linetype="dashed", size=0.1) +
    geom_vline(xintercept=c(1, 10, 30, 50, 80, 100, 200), linetype="twodash", size=0.1) +
    color_palette_color() + color_palette_fill() + xlab("Cov") + ylab("%CpGs covered with coverage cut-off ")
  
  save_(
    paste0("CpG_percetage_cov_thresold_" ,prot),
    use_pdf=TRUE,
    plot=g,
    width=3.5,
    height=3
  )
}

