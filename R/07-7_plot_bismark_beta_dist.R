analysis_name <- "07-5_plot_bismark_beta_dist"
source("/omics/groups/OE0219/internal/yuyu/10.Benchmarking/analysis/data_processing_redo/00.project_setting.R")

## Load
##########################
mx_objs_name = c("methylCtools", "bwameth", "gemBS", "BAT", "Bismark", "FAME", "Biscuit", "BSBolt", "methylpy")
#mx_objs_name = c("methylCtools")

methrix_o <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir,"GSNAP"))
mx_objs = list(methrix_o) # Put first S4 Object

for(c in mx_objs_name){
  print(paste0(methrix_obj_dir,"//",c))
  objs = methrix::load_HDF5_methrix(file.path(methrix_obj_dir,c))
  mx_objs = append(mx_objs, objs) # append the rest S4 objects in
}

sample_size=SAMPLE_SIZE
set.seed(SEED_NUM)
idx = sample(1:HG38_CpG_NUM, SAMPLE_SIZE)
combs=c()
df=data.frame(matrix(0, ncol = 0, nrow = sample_size))
for(obj in mx_objs){
  combs = c(combs,paste(obj@colData@listData$sample, replace_prot_name_(obj@colData@listData$method),  obj@colData@listData$pipeline, sep = "_"))
  beta = obj@assays@data@listData[["beta"]][idx, ]
  df = cbind(df, as.data.frame(beta))
}

save_("beta_dist_sampling_tb", data=df)
save_("combination", data=combs)

df <- read_("beta_dist_sampling_tb", "06_general_beta_dist_plot")
combs <- read_("combination", "06_general_beta_dist_plot")

#####
df = beta_dist_sampling_tb
combs = combination
colnames(df) <- combs
# one plot for all protocols
df_tmp = df %>% 
  gather(key="MesureType", value="beta") %>%
  mutate(sample=gsub("(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EMseq)_(.*)", "\\1", MesureType)) %>%
  mutate(protocol=gsub("(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EMseq)_(.*)", "\\2", MesureType)) %>%
  mutate(workflow=gsub("(5N|5T|6T|6N)_(WGBS|TWGBS|T-WGBS|PBAT|Swift|EMSEQ|EMseq)_(.*)", "\\3", MesureType)) %>% 
  dplyr::select(-MesureType) %>%
  dplyr::filter(workflow=="Bismark")
  
df_tmp$workflow <- replace_wf_name_(df_tmp$workflow)
df_tmp$protocol =  factor(df_tmp$protocol, levels = protocols)
  
protocol_color_sheme <- c(
  "#CD534CFF",
  "#33cc00",
  "#0073C2FF",
  "#EFC000FF",
  "#ff9900"
)

p <- ggplot(df_tmp, aes(x=beta, color=protocol)) +
  geom_density() + unified_pg + scale_color_manual(values=protocol_color_sheme) # color_palette_color() + color_palette_fill()

p

save_(
  "beta_dist_density_bismark",
  use_pdf=TRUE,
  plot=p,
  width=7.5,
  height=5
)

for(s in c("5N", "5T", "6N", "6T")){
  p_sample <- df_tmp %>% dplyr::filter(sample==s) %>% ggplot(aes(x=beta, color=workflow)) +
    geom_density() + unified_pg +
    facet_wrap(~protocol, ncol=5, scales = "free_y") + color_palette_color() + color_palette_fill() + ylab(paste0(s, "_density")) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='right')    

  save_(
    paste0("beta_dist_density_", s),
    use_pdf=TRUE,
    plot=p_sample,
    width=7.5,
    height=2
  )
}

p2 <- ggplot(df_tmp, aes(x=beta, color=workflow)) +
  geom_density() + 
  #theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"), legend.key.size = unit(3, 'mm')) + 
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
         panel.border=element_rect(fill=NA),
         strip.background = element_blank(),
         legend.position='none') + 
  #guides(color = guide_legend(ncol = 2, byrow = FALSE)) +
  facet_wrap(~protocol, ncol=3, scales = "free_y") + color_palette_color() + color_palette_fill()

save_(
  "beta_dist_density_all_no_legend",
  use_pdf=TRUE,
  plot=p2,
  width=7.5,
  height=5
)
