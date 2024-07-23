## Configuration
analysis_name <- "07-2_cov_enrichment_merged_histo_IQR"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)
library(BSgenome.Hsapiens.UCSC.hg38) 
library(DescTools)

## read data:
################################################
beta_cov_tb <- read_(
  "cov_tb",
  "07-1_meth_and_cov_distr"
)

## calc percent_rank:
########################

cov_rank_tb <- beta_cov_tb %>%
    dplyr::select(protocol, sample, chr, pos, cov) %>%
    group_by(sample, protocol) %>%
    dplyr::mutate(top_percent_rank=1-percent_rank(cov)) %>%
    ungroup
    
cov_rank_condensed_tb <- beta_cov_tb %>%
    dplyr::select(protocol, chr, pos, cov) %>%
    group_by(protocol) %>%
    dplyr::mutate(top_percent_rank=1-percent_rank(cov)) %>%
    ungroup

save_("cov_rank_condensed_tb", data=cov_rank_condensed_tb)
read_("cov_rank_condensed_tb", "07-2_cov_enrichment_merged_histo_IQR")

protocol_color_sheme <- c(
  "#CD534CFF",
  "#33cc00",
  "#0073C2FF",
  "#EFC000FF",
  "#ff9900"
)


cov_rank_tb$protocol <- replace_prot_name_(cov_rank_tb$protocol)
cov_rank_tb$protocol = factor(cov_rank_tb$protocol, levels = protocols)

save_("cov_rank_tb", data=cov_rank_tb)
cov_rank_tb = read_("cov_rank_tb", "07-2_cov_enrichment_merged_histo_IQR")

total = nrow(cov_rank_tb) / 5

cov_rank_tb = cov_rank_tb %>% group_by(protocol)
var = "cov"
protocol_ypos <- seq(-0.002, -0.015, length.out=5) * total
names(protocol_ypos) <- protocols
med_cov_tb <- cov_rank_tb %>%
  dplyr::summarize(
    mean=mean(cov, na.rm=T),
    sd=sd(cov, na.rm=T),
    med=median(cov, na.rm=T),
    mad=mad(cov, na.rm=T),
    upper=quantile(cov, 0.75, na.rm=T),
    lower=quantile(cov, 0.25, na.rm=T),
    n=n()
  ) %>%
  ungroup() %>% dplyr::mutate(se=sd/n) %>% dplyr::mutate(ypos=protocol_ypos[protocol])

save_("med_cov_tb", data=med_cov_tb)

p = cov_rank_tb %>% ggplot(aes(x=cov)) + 
  geom_point(
    aes(med, ypos, color=protocol),
    size=2,
    alpha=1,
    shape=15,
    data=med_cov_tb
  ) +
  geom_segment(
    aes(
      x=lower, xend=upper, y=ypos, yend=ypos,
      color=protocol
    ),
    size=2,
    alpha=0.5,
    data=med_cov_tb
  ) +
  unified_pg + color_palette_color() + color_palette_fill() +
  geom_histogram(data=subset(cov_rank_tb, protocol == 'WGBS'), binwidth = 1, fill = "#CD534CFF", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'Swift'), binwidth = 1, fill = "#33cc00", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'T-WGBS'), binwidth = 1, fill = "#0073C2FF", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'PBAT'), binwidth = 1, fill = "#EFC000FF", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'EM-seq'), binwidth = 1, fill = "#ff9900", alpha = 0.5) + 
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='right', legend.key = element_rect(fill = "white")) + xlim(0,150) +  ylab("") +
  scale_y_continuous(breaks=c(-total*0.01, 0, total*0.02, total*0.04, total*0.06), labels=c("IQR","0","0.02","0.04","0.06")) +
  scale_colour_manual(values=protocol_color_sheme) + 
  scale_fill_manual(values=protocol_color_sheme) + guides(colour = guide_legend(override.aes = list(size=3, linetype=5, linewidth=2)))

p

save_(
  "coverage_bin_histogram_merged_plot_legend",
  plot=p,
  width=5,
  height=3.1
)

####
total = nrow(cov_rank_tb) / 20 #5x4

cov_rank_tb = read_("cov_rank_tb", "07-2_cov_enrichment_merged_histo_IQR")
cov_rank_tb = cov_rank_tb %>% group_by(sample, protocol)
var = "cov"
protocol_ypos <- seq(-0.003, -0.016, length.out=5) * total
names(protocol_ypos) <- protocols
med_cov_tb <- cov_rank_tb %>%
  dplyr::summarize(
    mean=mean(cov, na.rm=T),
    sd=sd(cov, na.rm=T),
    med=median(cov, na.rm=T),
    mad=mad(cov, na.rm=T),
    upper=quantile(cov, 0.75, na.rm=T),
    lower=quantile(cov, 0.25, na.rm=T),
    n=n()
  ) %>%
  ungroup() %>% dplyr::mutate(se=sd/n) %>% dplyr::mutate(ypos=protocol_ypos[protocol])

save_("med_cov_sample_tb", data=med_cov_tb)

p = cov_rank_tb %>% ggplot(aes(x=cov)) + 
  geom_point(
    aes(med, ypos, color=protocol),
    size=1.8,
    alpha=1,
    shape=15,
    data=med_cov_tb
  ) +
  geom_segment(
    aes(
      x=lower, xend=upper, y=ypos, yend=ypos,
      color=protocol
    ),
    size=1.5,
    alpha=0.5,
    data=med_cov_tb
  ) +  
  unified_pg + color_palette_color() + color_palette_fill() +
  geom_histogram(data=subset(cov_rank_tb, protocol == 'WGBS'), binwidth = 1, fill = "#CD534CFF", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'Swift'), binwidth = 1, fill = "#33cc00", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'T-WGBS'), binwidth = 1, fill = "#0073C2FF", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'PBAT'), binwidth = 1, fill = "#EFC000FF", alpha = 0.5) + 
  geom_histogram(data=subset(cov_rank_tb, protocol == 'EM-seq'), binwidth = 1, fill = "#ff9900", alpha = 0.5) + 
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='none') + xlim(0,150) +  
  scale_y_continuous(breaks=c(0, total*0.02, total*0.04, total*0.06), labels=c("0","0.02","0.04","0.06")) + 
  facet_wrap(~ sample, ncol=2) +
  scale_colour_manual(values=protocol_color_sheme) + 
  scale_fill_manual(values=protocol_color_sheme)
  

p

save_(
  "coverage_bin_histogram_merged_plot_sample",
  plot=p,
  width=7.5,
  height=4
)
