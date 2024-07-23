analysis_name <- "06-2_plot_ranking_alluvial"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(methrix)
library(tidyverse)
library(ggplot2)
library("ggalluvial")

indv_ranking_tb_ <- read_("indv_ranking_tb", "06-1_plot_ranking_heatmap")
indv_ranking_tb = indv_ranking_tb_ %>% dplyr::select(workflow) %>% 
  mutate(WGBS=factor(workflow, levels=indv_ranking_tb_$WGBS_rank_n)) %>% 
  mutate(Swift=workflow) %>% 
  mutate(TWGBS=factor(paste0(workflow, "  "), levels = paste0(indv_ranking_tb_$`T-WGBS_rank_n`, "  "))) %>% 
  mutate(PBAT=workflow) %>%
  mutate(EMseq=factor(paste0(workflow, "    "), levels = paste0(indv_ranking_tb_$`EM-seq_rank_n`, "    ")))
b = indv_ranking_tb
b = cbind(b, c(1,1,1,1,1,1,1,1,1,1))
colnames(b)[7] = "Freq"

b = b %>% mutate(WGBS = factor(paste0(c("BSBolt", "methylCtools", "bwa-meth", "BAT", "Bismark",
                                        "FAME", "gemBS", "Biscuit", "methylpy", "GSNAP")," "),
                               levels = paste0(c("BSBolt", "methylCtools", "Biscuit",  "BAT", "bwa-meth", "Bismark",
                                                 "FAME", "gemBS", "methylpy", "GSNAP")," ")))

b = b %>% mutate(Swift = factor(paste0(c("BSBolt", "methylCtools", "bwa-meth", "BAT", "Bismark", 
                                         "FAME", "gemBS", "Biscuit", "methylpy", "GSNAP"),"  "), 
                                levels = paste0(c("BSBolt","bwa-meth", "methylCtools",  "gemBS", "methylpy",
                                                  "BAT", "Bismark", "FAME", "Biscuit", "GSNAP"),"  ")))

b = b %>% mutate(TWGBS = factor(paste0(c("BSBolt", "methylCtools", "bwa-meth", "BAT", "Bismark", 
                                         "FAME", "gemBS", "Biscuit", "methylpy", "GSNAP"),"   "), 
                                levels = paste0(c("BSBolt", "bwa-meth", "Bismark", "gemBS", "BAT", "methylpy", "FAME",
                                                  "methylCtools", "Biscuit", "GSNAP"),"   ")))

b = b %>% mutate(PBAT = factor(paste0(c("BSBolt", "methylCtools", "bwa-meth", "NA", "Bismark", 
                                        "FAME", "NA", "Biscuit", "methylpy", "GSNAP"),"    "), 
                               levels = paste0(c("BSBolt", "methylCtools", "Biscuit", "FAME", "Bismark",
                                                 "methylpy", "bwa-meth", "GSNAP", "NA"),"    ")))

b = b %>% mutate(EMseq = factor(paste0(c("BSBolt", "methylCtools", "bwa-meth", "BAT", "Bismark", 
                                         "FAME", "gemBS", "Biscuit", "methylpy", "GSNAP"),"     "), 
                                levels = paste0(c("BSBolt", "methylCtools", "BAT", "Bismark", "bwa-meth", "Biscuit", "FAME",
                                                  "gemBS", "methylpy", "GSNAP"),"     ")))



b$workflow = factor(b$workflow, levels = workflows)

###

g = b %>% ggplot(aes(y = Freq, axis1 = WGBS,  axis2=Swift, axis3=TWGBS, axis4=PBAT, axis5=EMseq)) +
  geom_alluvium(aes(fill = workflow), width = 1/30) + 
  geom_stratum(width = 1/12, fill = "black",  color = "black") +
  geom_label(stat = "stratum", aes(label = str_trim(after_stat(stratum))), size = 2.8) +
  scale_x_discrete(limits = c("WGBS", "Swift", "T-WGBS", "PBAT", "EM-seq"), expand = c(.05, .05)) + 
  unified_pg + ylab("") + theme(axis.ticks.y = element_blank(),
                                axis.text.y = element_blank(),
                                legend.position='none') + color_palette_fill() + color_palette_color()

g

save_(paste0("alluvial_7x4"), plot=g, use_pdf = TRUE, width=7.3, height=3)
