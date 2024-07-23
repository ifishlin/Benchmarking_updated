analysis_name <- "01-4_plot_depth_vs_coverage"
config = file.path(getwd(), "0_project_setting.R")
source(config)

#read data
df = data.frame()
for(prot in protocols_int){
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
  
  for(w in workflows){
    cov = beta_cov_tb %>% filter(workflow==w, cov <= 200) %>% arrange(cov) 
    if(nrow(cov)==0) next
    cov1 = data.frame(cov=0, cume_dist_min=1, workflow=w)
    cov2 = data.frame(cov=201, cume_dist_min=0, workflow=w)
    cov = rbind(cov1,cov)
    cov = rbind(cov, cov2)
  
    cov_n = cov %>% select(cume_dist_min)
    cov_n = cov_n[-1,]
  
    cov_auc = cov[-202,] %>% mutate(cov_n=cov_n) %>% mutate(dist=cume_dist_min-cov_n) %>% mutate(width=1/200)
    cov_auc = cov_auc %>% mutate(area1=cov_n*width) %>% mutate(area2=dist*width/2) %>% filter(cov<200)
    
    auc = sum(cov_auc$area2) + sum(cov_auc$area1)
    print(paste0(w, " ",round(auc,3)))
    df = rbind(df, c(replace_prot_name_(prot), w, as.numeric(round(auc,3))))
  }
}
colnames(df) = c("protocol", "workflow", "auc")

df$protocol = factor(df$protocol, level=protocols)
df = df %>% mutate(auc=as.numeric(auc))

df %>% ggplot(aes(protocol, auc)) + geom_point(aes(colour = factor(workflow)))

df %>% mutate(type="auc") %>% ggplot(aes(workflow, auc, fill=type, color=type)) + geom_col(width=0.7) + facet_grid(col=vars(protocol)) +
  theme(panel.spacing.y = unit(0, "mm"), 
        axis.text=element_text(size=8), 
        axis.text.x = element_text(angle = 60, hjust=1, size=6), legend.position = 'none'
        ) + scale_y_continuous(expand = expansion(mult = c(0.02, .1))) + unified_pg +         
  scale_fill_manual(values=c("#83D4757D")) + 
  scale_color_manual(values=c("#2EB62C")) 

save_("depth_auc_tb", data=df)
