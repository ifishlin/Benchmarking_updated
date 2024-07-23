analysis_name <- "07-5_plot_bismark_beta_dist"
config = file.path(getwd(), "0_project_setting.R")
source(config)

## Load
##########################
meth_list = lapply(workflows, function(x){
  methrix_o <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, x))
})

sample_size=SAMPLE_SIZE
set.seed(SEED_NUM)
idx = sample(1:HG38_CpG_NUM, sample_size)
combs=c()
df=data.frame(matrix(0, ncol = 0, nrow = length(sample_size)))
df_cov=data.frame(matrix(0, ncol = 0, nrow = length(sample_size)))
for(obj in meth_list){
  combs = c(combs,paste(obj@colData@listData$sample,
                        replace_prot_name_(obj@colData@listData$method),
                        obj@colData@listData$pipeline, sep = "_"))
  beta = obj@assays@data@listData[["beta"]][idx, ]
  cov = obj@assays@data@listData[["cov"]][idx, ]
  df_cov = cbind(df_cov, as.data.frame(cov))
  df = cbind(df, as.data.frame(beta))
}

colnames(df) = combs
colnames(df_cov) = combs
save_("df", data=df)
save_("df_cov", data=df_cov)
save_("combination", data=combs)

df[df_cov < COV_THRESHOLD] = NA
df_cov[df_cov < COV_THRESHOLD] = NA

df2_cov = df_cov[grep("5N_WGBS", combs)]
df2_cov$idx_5N_WGBS = apply(df_cov[grep("5N_WGBS", combs)], 1, mean, na.rm=T)
df2_cov$idx_5T_WGBS = apply(df_cov[grep("5T_WGBS", combs)], 1, mean, na.rm=T)
df2_cov$idx_6N_WGBS = apply(df_cov[grep("6N_WGBS", combs)], 1, mean, na.rm=T)
df2_cov$idx_6T_WGBS = apply(df_cov[grep("6T_WGBS", combs)], 1, mean, na.rm=T)

df2_cov$`idx_5N_T-WGBS` = apply(df_cov[grep("5N_T-WGBS", combs)], 1, mean, na.rm=T)
df2_cov$`idx_5T_T-WGBS` = apply(df_cov[grep("5T_T-WGBS", combs)], 1, mean, na.rm=T)
df2_cov$`idx_6N_T-WGBS` = apply(df_cov[grep("6N_T-WGBS", combs)], 1, mean, na.rm=T)
df2_cov$`idx_6T_T-WGBS` = apply(df_cov[grep("6T_T-WGBS", combs)], 1, mean, na.rm=T)

df2_cov$idx_5N_PBAT = apply(df_cov[grep("5N_PBAT", combs)], 1, mean, na.rm=T)
df2_cov$idx_5T_PBAT = apply(df_cov[grep("5T_PBAT", combs)], 1, mean, na.rm=T)
df2_cov$idx_6N_PBAT = apply(df_cov[grep("6N_PBAT", combs)], 1, mean, na.rm=T)
df2_cov$idx_6T_PBAT = apply(df_cov[grep("6T_PBAT", combs)], 1, mean, na.rm=T)

df2_cov$`idx_5N_EM-seq` = apply(df_cov[grep("5N_EM-seq", combs)], 1, mean, na.rm=T)
df2_cov$`idx_5T_EM-seq` = apply(df_cov[grep("5T_EM-seq", combs)], 1, mean, na.rm=T)
df2_cov$`idx_6N_EM-seq` = apply(df_cov[grep("6N_EM-seq", combs)], 1, mean, na.rm=T)
df2_cov$`idx_6T_EM-seq` = apply(df_cov[grep("6T_EM-seq", combs)], 1, mean, na.rm=T)

df2_cov$idx_5N_Swift = apply(df_cov[grep("5N_Swift", combs)], 1, median, na.rm=T)
df2_cov$idx_5T_Swift = apply(df_cov[grep("5T_Swift", combs)], 1, median, na.rm=T)
df2_cov$idx_6N_Swift = apply(df_cov[grep("6N_Swift", combs)], 1, median, na.rm=T)
df2_cov$idx_6T_Swift = apply(df_cov[grep("6T_Swift", combs)], 1, median, na.rm=T)

d2 = df[grep("5N_WGBS", combs)]
d2$idx_5N_WGBS = apply(df[grep("5N_WGBS", combs)], 1, median, na.rm=T)
d2$idx_5T_WGBS = apply(df[grep("5T_WGBS", combs)], 1, median, na.rm=T)
d2$idx_6N_WGBS = apply(df[grep("6N_WGBS", combs)], 1, median, na.rm=T)
d2$idx_6T_WGBS = apply(df[grep("6T_WGBS", combs)], 1, median, na.rm=T)

d2$`idx_5N_T-WGBS` = apply(df[grep("5N_T-WGBS", combs)], 1, median, na.rm=T)
d2$`idx_5T_T-WGBS` = apply(df[grep("5T_T-WGBS", combs)], 1, median, na.rm=T)
d2$`idx_6N_T-WGBS` = apply(df[grep("6N_T-WGBS", combs)], 1, median, na.rm=T)
d2$`idx_6T_T-WGBS` = apply(df[grep("6T_T-WGBS", combs)], 1, median, na.rm=T)

d2$idx_5N_PBAT = apply(df[grep("5N_PBAT", combs)], 1, median, na.rm=T)
d2$idx_5T_PBAT = apply(df[grep("5T_PBAT", combs)], 1, median, na.rm=T)
d2$idx_6N_PBAT = apply(df[grep("6N_PBAT", combs)], 1, median, na.rm=T)
d2$idx_6T_PBAT = apply(df[grep("6T_PBAT", combs)], 1, median, na.rm=T)

d2$`idx_5N_EM-seq` = apply(df[grep("5N_EM-seq", combs)], 1, median, na.rm=T)
d2$`idx_5T_EM-seq` = apply(df[grep("5T_EM-seq", combs)], 1, median, na.rm=T)
d2$`idx_6N_EM-seq` = apply(df[grep("6N_EM-seq", combs)], 1, median, na.rm=T)
d2$`idx_6T_EM-seq` = apply(df[grep("6T_EM-seq", combs)], 1, median, na.rm=T)

d2$idx_5N_Swift = apply(df[grep("5N_Swift", combs)], 1, median, na.rm=T)
d2$idx_5T_Swift = apply(df[grep("5T_Swift", combs)], 1, median, na.rm=T)
d2$idx_6N_Swift = apply(df[grep("6N_Swift", combs)], 1, median, na.rm=T)
d2$idx_6T_Swift = apply(df[grep("6T_Swift", combs)], 1, median, na.rm=T)

d3 = d2[,-c(1:10)]
d4 = df2_cov[,-c(1:10)]

save_("d3", data=d3)
save_("d4", data=d4)

d3 = read_("d3", "07-5_plot_bismark_beta_dist")
d4 = read_("d4", "07-5_plot_bismark_beta_dist")
combs = read_("combination", "07-5_plot_bismark_beta_dist")
#####

colnames(df) <- combs
# one plot for all protocols
df3_tmp = d3 %>% 
  gather(key="MesureType", value="beta") %>%
  mutate(sample=gsub("idx_(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EM-seq)", "\\1", MesureType)) %>%
  mutate(protocol=gsub("idx_(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EM-seq)", "\\2", MesureType)) %>%
  mutate(workflow="median") %>% 
  dplyr::select(-MesureType) 

df4_tmp = d4 %>% 
  gather(key="MesureType", value="cov") %>%
  mutate(sample=gsub("idx_(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EM-seq)", "\\1", MesureType)) %>%
  mutate(protocol=gsub("idx_(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EM-seq)", "\\2", MesureType)) %>%
  mutate(workflow="median") %>% 
  dplyr::select(-MesureType) 


df_tmp = cbind(df3_tmp, df4_tmp$cov)
colnames(df_tmp) = c("beta", "sample", "protocol", "workflow", "cov")

df_tmp2 = df_tmp
df_tmp = na.omit(df_tmp)
df_tmp %>% group_by(protocol) %>% summarize(count=n(), mean_cov=mean(cov))

df_tmp %>% filter(beta==1) %>% group_by(protocol) %>% summarize(count=n(), mean_cov=mean(cov))
df_tmp %>% filter(beta==0) %>% group_by(protocol) %>% summarize(count=n(), mean_cov=mean(cov))

df_tmp$protocol =  factor(df_tmp$protocol, levels = protocols)

protocol_color_sheme <- c(
  "#CD534CFF",
  "#33cc00",
  "#0073C2FF",
  "#EFC000FF",
  "#ff9900"
)

df_tmp %>% filter(protocol=="WGBS")
total = nrow(df_tmp)/5

p<-ggplot(df_tmp, aes(x=beta, color=protocol)) + 
  geom_histogram(binwidth = 0.01) +  unified_pg + facet_wrap(~protocol, ncol=5) + 
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='none') + scale_color_manual(values=protocol_color_sheme) + 
  scale_y_continuous(breaks=c(0, total*0.05, total*0.10, total*0.15), labels=c("0","0.05","0.10","0.15")) + 
  scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))

p

save_(
  "beta_dist_histo_ave",
  use_pdf=TRUE,
  plot=p,
  width=9,
  height=3
)

for(s in c("5N", "5T", "6N", "6T")){
  total = nrow(df_tmp)/5/4
  p_sample <- df_tmp %>% dplyr::filter(sample==s) %>% ggplot(aes(x=beta, color=protocol)) +
    geom_histogram(binwidth = 0.01)+ unified_pg +
    facet_wrap(~protocol, ncol=5) + scale_color_manual(values=protocol_color_sheme) + ylab(paste0(s)) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none') + 
    scale_y_continuous(breaks=c(0, total*0.05, total*0.10, total*0.15), labels=c("0","0.05","0.10","0.15")) + 
    scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))
    #scale_y_continuous(breaks=c(0, 15000, 30000, 45000), labels=c("0","0.2","0.4","0.6")) + 
    #scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))
  
  p_sample

  save_(
    paste0("beta_dist_histogram_", s),
    use_pdf=TRUE,
    plot=p_sample,
    width=9,
    height=3
  )
}

for(s in c("5N", "5T", "6N", "6T")){
  total = nrow(df_tmp)/5/4
  p_sample <- df_tmp %>% ggplot(aes(x=beta, color=protocol)) +
    geom_histogram(binwidth = 0.01)+ unified_pg +
    facet_wrap(~sample+protocol, ncol=5) + scale_color_manual(values=protocol_color_sheme) + ylab(paste0(s)) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none') + ylab("") + 
    scale_y_continuous(breaks=c(0, total*0.05, total*0.10, total*0.15), labels=c("0","0.05","0.10","0.15")) + 
    scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))
  
  p_sample
  
  save_(
    paste0("beta_dist_sample_compare"),
    use_pdf=TRUE,
    plot=p_sample,
    width=9,
    height=6
  )  
  
}
total = nrow(df_tmp)/5/2
p_type <- df_tmp %>% dplyr::filter(sample %in% c("5N", "6N")) %>% ggplot(aes(x=beta, color=protocol)) +
    geom_histogram(binwidth = 0.01)+ unified_pg +
    facet_wrap(~protocol, ncol=5) + scale_color_manual(values=protocol_color_sheme)  + ylab(paste0("5N and 6N")) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none') +   
  scale_y_continuous(breaks=c(0, total*0.05, total*0.10, total*0.15), labels=c("0","0.05","0.10","0.15")) + 
  scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))
  
p_type
  
save_(
    paste0("beta_dist_histogram_normal"),
    use_pdf=TRUE,
    plot=p_type,
    width=9,
    height=3
)
total = nrow(df_tmp)/5/2
p_type <- df_tmp %>% dplyr::filter(sample %in% c("5T", "6T")) %>% ggplot(aes(x=beta, color=protocol)) +
  geom_histogram(binwidth = 0.01)+ unified_pg +
  facet_wrap(~protocol, ncol=5) + scale_color_manual(values=protocol_color_sheme) + ylab(paste0("5T and 6T")) +
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='none') + 
  scale_y_continuous(breaks=c(0, total*0.05, total*0.10, total*0.15), labels=c("0","0.05","0.10","0.15")) + 
  scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))

p_type

save_(
  paste0("beta_dist_histogram_cancer"),
  use_pdf=TRUE,
  plot=p_type,
  width=9,
  height=3
)

df_tmp = df_tmp %>% mutate(type=ifelse(sample %in% c("5N", "6N"), "N", "C"))
total = nrow(df_tmp)/2
p_sample <- df_tmp %>% ggplot(aes(x=beta, color=type)) +
  geom_histogram(binwidth = 0.01)+ unified_pg +
  facet_wrap(~type, ncol=5) + color_palette_color() + color_palette_fill() + ylab(paste0(s)) +
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='none') + ylab("") + 
  scale_y_continuous(breaks=c(0, total*0.05, total*0.10, total*0.15), labels=c("0","0.05","0.10","0.15")) + 
  scale_x_continuous(breaks=c(0, 0.25, 0.5, 0.75, 1), labels=c("0","0.25","0.5","0.75","1"))
p_sample

save_(
  paste0("beta_dist_type_compare"),
  use_pdf=TRUE,
  plot=p_sample,
  width=9,
  height=4
)  
