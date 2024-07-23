## Configuration
analysis_name <- "07-1_meth_and_cov_distr"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)
library(BSgenome.Hsapiens.UCSC.hg38) 

# df = data.frame()
# sample_id = sample(1:HG38_CpG_NUM, SAMPLE_SIZE)
# for(w in workflows){
#   meth <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, w)) 
#   meth_filt_tb <- meth %>%
#     get_matrix(add_loci=TRUE, type="C") %>%
#     as_tibble
#   meth_sampled = meth_filt_tb
#   meth_sampled = meth_filt_tb[sample_id,]
#   a = gather(meth_sampled, key, cov,-chr, -start, -strand)
#   a = a %>% mutate(sample=gsub("hg38.(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).(.*)", "\\2", key)) %>%
#     mutate(protocol=gsub("hg38.(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).(.*)", "\\1", key)) %>%
#     mutate(workflow=gsub("hg38.(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).(.*)", "\\3", key)) %>% 
#     dplyr::select(-strand, -key)
#   df = rbind(df, a)
# }
# 
# colnames(df) = c("chr", "pos", "cov", "sample", "protocol", "workflow")
# df = df[!is.na(df$cov),]
# 
# save_("cov_tb",data=df)
df = read_("cov_tb", "07-1_meth_and_cov_distr")

## PLOT
get_distribution_overview <- function(beta_cov_tb, var="cov", add_category=NULL, condense=FALSE){
  if (condense){
    dist_overview_tb <- beta_cov_tb %>%
      group_by(protocol) 
  }
  else {
    dist_overview_tb <- beta_cov_tb %>%
      group_by(sample, protocol) 
  }
  dist_overview_tb <- dist_overview_tb %>%
    dplyr::summarize(
      mean=mean(UQ(sym(var)), na.rm=T),
      sd=sd(UQ(sym(var)), na.rm=T),
      med=median(UQ(sym(var)), na.rm=T),
      mad=mad(UQ(sym(var)), na.rm=T),
      upper=quantile(UQ(sym(var)), 0.75, na.rm=T),
      lower=quantile(UQ(sym(var)), 0.25, na.rm=T),
      n=n()
    ) %>%
    ungroup() %>%
    dplyr::mutate(se=sd/n)
  if (!is.null(add_category)){
    dist_overview_tb <- dist_overview_tb %>%
      mutate(category=add_category) %>%
      dplyr::select(category, everything())
  }
  return(dist_overview_tb)
}

plot_1_minus_ecdf_cov <- function(
    beta_cov_tb, add_category=NULL, condense=FALSE, facet=TRUE, x_limits=c(1, 100), log_scale=TRUE
){
  
  protocol_ypos <- seq(-0.25, -0.05, length.out=5)
  names(protocol_ypos) <- protocols
  med_cov_tb <-  get_distribution_overview(beta_cov_tb, "cov", add_category, condense=condense) %>%
    dplyr::mutate(ypos=protocol_ypos[protocol])
  
  save_(paste0("med_cov_tb_",condense),data=med_cov_tb)
  
  if(facet || condense){
    plot_ <- beta_cov_tb %>%
      ggplot() +
      geom_line(
        aes(x=cov, y=1 - ..y.., color=protocol), 
        stat="ecdf",
        alpha=0.7,
        size=1
      ) +
      geom_point(
        aes(med, ypos, color=protocol),
        size=3.5,
        alpha=1,
        shape=15,
        data=med_cov_tb
      ) +
      geom_segment(
        aes(
          x=lower, xend=upper, y=ypos, yend=ypos,
          color=protocol
        ),
        size=3.5,
        alpha=0.5,
        data=med_cov_tb
      ) +
      scale_y_continuous(
        breaks=c(-0.15, seq(0,1,0.25)), 
        labels=c("median\n & IQR", 0.00, 0.25, 0.5, 0.75, 1.00),
        limits=c(-0.25,1)
      )
  }else{
    plot_ <- beta_cov_tb %>%
      ggplot() +
      geom_line(
        aes(x=cov, y=1 - ..y.., color=protocol, alpha=sample, linetype=sample), 
        stat="ecdf",
        alpha=0.7,
        size=1
      ) +
      scale_alpha_manual(values=sample_alpha_sheme) +
      scale_linetype_manual(values=sample_linetype_sheme)
  }
  plot_ <- plot_ +
    ylab("1 - ecdf") +
    xlab("coverage") +
    scale_color_manual(values=protocol_color_sheme)
  
  if(log_scale){
    plot_ <- plot_ +
      scale_x_log10(breaks=c(1, 10, 15, 30, 50, 100), limits=x_limits)
  }
    
  if(facet){
    plot_ <- plot_ + 
      facet_grid(. ~ sample) +
      theme(
        panel.border=element_rect(fill=NA),
        strip.background =element_blank(),
        legend.position = "none"
      )
  }
  plot_ <- plot_ +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none')      
  
  return(
    list(
      data=med_cov_tb,
      plot=plot_
    )
  )
}

beta_cov_tb <- df

protocol_color_sheme <- c(
  "#CD534CFF",
  "#33cc00",
  "#0073C2FF",
  "#EFC000FF",
  "#ff9900"
)

protocols_show <- c(
  "WGBS",
  "Swift",
  "T-WGBS",
  "PBAT",
  "EM-seq"
)

names(protocol_color_sheme) <- protocols

beta_cov_tb$protocol <- replace_prot_name_(beta_cov_tb$protocol)
beta_cov_tb$protocol = factor(beta_cov_tb$protocol, levels = protocols)

one_minus_ecdf_cov_condensed_plot <- plot_1_minus_ecdf_cov(beta_cov_tb)$plot
#
# ## what I need
save_(
  "1_minus_ecdf_coverage",
  plot=one_minus_ecdf_cov_condensed_plot,
  width=7.5,
  height=2.6
)

one_minus_ecdf_cov_plot <- plot_1_minus_ecdf_cov(beta_cov_tb, condense=TRUE, facet=FALSE)$plot
# ## what I need
save_(
  "1_minus_ecdf_coverage_condense",
  plot=one_minus_ecdf_cov_plot,
  width=6,
  height=3
)

