## Configuration
analysis_name <- "01-5_plot_beta_dist_debug"
config = file.path(getwd(), "0_project_setting.R")
source(config)

## Load
##########################
meth_list = lapply(workflows, function(x){
  methrix_o <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, x))
})

## Sampling
set.seed(SEED_NUM)
idx = sample(1:HG38_CpG_NUM, SAMPLE_SIZE) # The number of CpGs is 29,401,795
combs=c()
df=data.frame(matrix(0, ncol = 0, nrow = SAMPLE_SIZE))
for(obj in meth_list){
  combs = c(combs,paste(obj@colData@listData$sample,
                        replace_prot_name_(obj@colData@listData$method),
                        replace_wf_name_(obj@colData@listData$pipeline), sep = "_"))
  beta = obj@assays@data@listData[["beta"]][idx, ]
  df = cbind(df, as.data.frame(beta))
}
colnames(df) = combs
save_("beta_dist_sampling_tb", data=df)
df = read_("beta_dist_sampling_tb", "01-5_plot_beta_dist")

## Reformat
df_tmp = df %>% 
  gather(key="MesureType", value="beta") %>%
  mutate(sample=gsub("(5N|5T|6T|6N)_(WGBS|T-WGBS|PBAT|Swift|EM-seq)_(.*)", "\\1", MesureType)) %>%
  mutate(protocol=gsub("(5N|5T|6T|6N)_(WGBS|T-WGBS|PBAT|Swift|EM-seq)_(.*)", "\\2", MesureType)) %>%
  mutate(workflow=gsub("(5N|5T|6T|6N)_(WGBS|T-WGBS|PBAT|Swift|EM-seq)_(.*)", "\\3", MesureType)) %>% 
  dplyr::select(-MesureType)
  
#df_tmp$workflow <- replace_wf_name_(df_tmp$workflow)
df_tmp$protocol =  factor(df_tmp$protocol, levels = protocols)

save_("beta_dist_sampling_long_tb", data=df_tmp)
df_tmp = read_("beta_dist_sampling_long_tb", "01-5_plot_beta_dist")

## summarize as bin
df_line = df_tmp
bin_size <- 0.05
df_line$Bins <- cut(df_line$beta, breaks = seq(0, 1, by = bin_size))
df_line$Bins<- ifelse(is.na(df_line$Bins), "0", df_line$Bins)

result <- data.frame(table(df_line$workflow, df_line$protocol, df_line$Bins))
colnames(result) = c("workflow", "protocol" ,"region", "count")
result$region = factor(result$region, levels=c(0:20))
result = result %>% arrange(region)
result$x = (as.numeric(result$region) - 2) * 0.05 + 0.05

filtered_result = result
filtered_result$norm = filtered_result$count/(SAMPLE_SIZE*4)

filtered_result = filtered_result[!(filtered_result$workflow=="gemBS" & filtered_result$protocol=="PBAT"),]
filtered_result = filtered_result[!(filtered_result$workflow=="BAT" & filtered_result$protocol=="PBAT"),]

p <- ggplot(filtered_result, aes(x=x, y=norm, group=workflow)) + 
  geom_line(aes(color=workflow), size=0.3) + 
  geom_point(aes(color=workflow), size=0.3) + 
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='none') + 
  facet_wrap(~protocol, ncol=5, scales = "free_y") +
  color_palette_color() + color_palette_fill()
p

save_(
  "beta_dist_line",
  use_pdf=TRUE,
  plot=p,
  width=10,
  height=2.8
)

## Density Plot
p <- ggplot(df_tmp, aes(x=beta, color=workflow)) +
  geom_density() +   
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        panel.border=element_rect(fill=NA),
        strip.background = element_blank(),
        legend.position='none') + 
  facet_wrap(~protocol, ncol=5, scales = "free_y") + color_palette_color() + color_palette_fill()

p

save_(
  "beta_dist_density",
  use_pdf=TRUE,
  plot=p,
  width=10,
  height=2.8
)

for(s in c("5N", "5T", "6N", "6T")){
  df_line = df_tmp %>% filter(sample==s)
  bin_size <- 0.05
  df_line$Bins <- cut(df_line$beta, breaks = seq(0, 1, by = bin_size))
  df_line$Bins<- ifelse(is.na(df_line$Bins), "0", df_line$Bins)
 
  result <- data.frame(table(df_line$workflow, df_line$protocol, df_line$Bins))
  colnames(result) = c("workflow", "protocol" ,"region", "count")
  result$region = factor(result$region, levels=c(0:20))
  result = result %>% arrange(region)
  result$x = (as.numeric(result$region) - 2) * 0.05 + 0.05  
   
  filtered_result = result
  filtered_result$norm = filtered_result$count/SAMPLE_SIZE
  
  filtered_result = filtered_result[!(filtered_result$workflow=="gemBS" & filtered_result$protocol=="PBAT"),]
  filtered_result = filtered_result[!(filtered_result$workflow=="BAT" & filtered_result$protocol=="PBAT"),]  
  
  p <- filtered_result %>%ggplot(aes(x=x, y=norm, group=workflow)) + 
    geom_line(aes(color=workflow), size=0.3) + 
    geom_point(aes(color=workflow), size=0.3) + 
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          panel.border=element_rect(fill=NA),
          strip.background = element_blank(),
          legend.position='none') + 
    facet_wrap(~protocol, ncol=5, scales = "free_y") +
    color_palette_color() + color_palette_fill()
  p
  
  save_(
    paste0("beta_dist_line_", s),
    use_pdf=TRUE,
    plot=p,
    width=10,
    height=2.4
  )  
  
  # p <- df_tmp %>% filter(sample == s) %>% ggplot(aes(x=beta, color=workflow)) +
  #   geom_density() +   
  #   theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
  #         panel.border=element_rect(fill=NA),
  #         strip.background = element_blank(),
  #         legend.position='none') + 
  #   facet_wrap(~protocol, ncol=5, scales = "free_y") + color_palette_color() + color_palette_fill()
  # 
  # p
  # 
  # save_(
  #   paste0("beta_dist_density_", s),
  #   use_pdf=TRUE,
  #   plot=p,
  #   width=7.5,
  #   height=2.8
  # )  
}


