## Configuration
analysis_name <- "0_wg_alignment_deviation_correlation_alignment_ratio_update"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)

df = read_("long_value", "02-5_calc_genome_wide_deivation") %>% filter(protocol=="PBAT") %>%
  filter(!workflow %in% c("methylpy", "FAME")) %>% dplyr::select(-protocol) %>% arrange(workflow, sample)
df2 <- read.table(paste0(data_dir, "/aligment_rate_update.csv"), sep = ',',header = T, quote='', comment='')  %>% 
  #filter(!workflow %in% c("Bismark")) %>%
  arrange(workflow, sample)
df3 = cbind(df,df2)
colnames(df3) = c("sample", "workflow", "beta", "workflow1", "sample1", "aligment_rate")

cor(df3$beta, df3$aligment_rate, method = "spearman")
cor.test(df3$beta, df3$aligment_rate, method = "spearman")

cor(df3$beta, df3$aligment_rate, method = "pearson")
cor.test(df3$beta, df3$aligment_rate, method = "pearson")

npg_color <- c(
  "#4DBBD5",
  "#00A087","#3C5488",
  "#F39B7F","#DC0000",
  "#7E6148" 
)


df3$workflow = factor(df3$workflow, levels=workflows)
p = df3 %>% ggplot() + 
  geom_point(aes(x=aligment_rate, y=beta, color=workflow, shape=sample1)) +
  geom_smooth(aes(x=aligment_rate, y=beta), data = df3, method=lm,  linetype="dashed", color="black") + 
              theme(
                panel.border=element_rect(fill=NA),
                panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
                strip.background.x = element_blank(),
                legend.text=element_text(face="bold")
              ) +   scale_color_manual(values=npg_color) +
        scale_fill_manual(values=npg_color) + xlab("Alignment rate") + ylab("Abs mean deviation")
p
save_(
  paste0("PBAT_corr_deviation_alignment_rate_all_sample_include_bismark"),
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=4
)  

npg_color <- c(
  "#4DBBD5",
  "#3C5488",
  "#F39B7F","#DC0000",
  "#7E6148" 
)

df4 = df3 %>% filter(!workflow %in% c("Bismark"))
cor(df4$beta, df4$aligment_rate, method = "spearman")
cor.test(df4$beta, df4$aligment_rate, method = "spearman")

cor(df4$beta, df4$aligment_rate, method = "pearson")
cor.test(df4$beta, df4$aligment_rate, method = "pearson")

p = df4 %>% ggplot(aes(x=aligment_rate, y=beta, color=workflow)) + 
  geom_point() +
  geom_smooth(method=lm,  linetype="dashed", color="black") + 
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.text=element_text(face="bold")
  ) +   scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("Alignment rate") + ylab("Abs mean deviation")
p
save_(
  paste0("PBAT_corr_deviation_alignment_rate_all_sample_exclude_bismark"),
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=4
)  

# cor(df3$beta, df3$aligment_rate, method = "pearson")
# cor.test(df3$beta, df3$aligment_rate, method = "pearson")
# plot(df3$beta, df3$aligment_rate)
npg_color <- c(
  "#4DBBD5",
  "#00A087","#3C5488",
  "#F39B7F","#DC0000",
  "#7E6148" 
)
##

df4 =  df3 %>% filter(sample=="5N")
p = ggplot(df4, aes(x=aligment_rate, y=beta, color=workflow)) + 
  geom_point() +
  geom_smooth(method=lm,  linetype="dashed", color="black") + 
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.text=element_text(face="bold")
  ) +   scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("Alignment rate") + ylab("Abs mean deviation")

p

save_(
  paste0("PBAT_spear_corr_deviation_alignment_rate_5N"),
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=4
)

cor(df4$beta, df4$aligment_rate, method = "spearman")
cor.test(df4$beta, df4$aligment_rate, method = "spearman")  

df5 =  df3 %>% filter(sample=="5T")
p = ggplot(df5, aes(x=aligment_rate, y=beta, color=workflow)) + 
  geom_point() +
  geom_smooth(method=lm,  linetype="dashed", color="black") + 
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.text=element_text(face="bold")
  ) +   scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("Alignment rate") + ylab("Abs mean deviation")
save_(
  paste0("PBAT_spear_corr_deviation_alignment_rate_5T"),
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=4
)
cor(df5$beta, df5$aligment_rate, method = "spearman")
cor.test(df5$beta, df5$aligment_rate, method = "spearman")  

df6 =  df3 %>% filter(sample=="6N")
p = ggplot(df6, aes(x=aligment_rate, y=beta, color=workflow)) + 
  geom_point() +
  geom_smooth(method=lm,  linetype="dashed", color="black") + 
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.text=element_text(face="bold")
  ) +   scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("Alignment rate") + ylab("Abs mean deviation")
save_(
  paste0("PBAT_spear_corr_deviation_alignment_rate_6N"),
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=4
)
cor(df6$beta, df6$aligment_rate, method = "spearman")
cor.test(df6$beta, df6$aligment_rate, method = "spearman")  

df7 =  df3 %>% filter(sample=="6T")
p = ggplot(df7, aes(x=aligment_rate, y=beta, color=workflow)) + 
  geom_point() +
  geom_smooth(method=lm,  linetype="dashed", color="black") + 
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.text=element_text(face="bold")
  ) +   scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("Alignment rate") + ylab("Abs mean deviation")
save_(
  paste0("PBAT_spear_corr_deviation_alignment_rate_6T"),
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=4
)
cor(df7$beta, df7$aligment_rate, method = "spearman")
cor.test(df7$beta, df7$aligment_rate, method = "spearman")  

plot(df4$beta, df4$aligment_rate)
plot(df5$beta, df5$aligment_rate)
plot(df6$beta, df6$aligment_rate)
plot(df7$beta, df7$aligment_rate)

# df4 =  df3 %>% filter(sample=="5N")
# cor(df4$beta, df4$aligment_rate, method = "pearson")
# cor.test(df4$beta, df4$aligment_rate, method = "pearson")  
# 
# df5 =  df3 %>% filter(sample=="5T")
# cor(df5$beta, df5$aligment_rate, method = "pearson")
# cor.test(df5$beta, df5$aligment_rate, method = "pearson")  
# 
# df6 =  df3 %>% filter(sample=="6N")
# cor(df6$beta, df6$aligment_rate, method = "pearson")
# cor.test(df6$beta, df6$aligment_rate, method = "pearson")  
# 
# df7 =  df3 %>% filter(sample=="6T")
# cor(df7$beta, df7$aligment_rate, method = "pearson")
# cor.test(df7$beta, df7$aligment_rate, method = "pearson")
# 
# (0.08691+0.06748+0.08102+0.044)/4
