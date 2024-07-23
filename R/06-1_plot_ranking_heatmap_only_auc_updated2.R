## Configuration
analysis_name <- "06-1_plot_ranking_heatmap_only_auc_updated2"
#config = file.path(getwd(), "/omics/groups/OE0219/internal/yuyu/10.Benchmarking/analysis/data_processing_manuscript/0_project_setting.R")
config = file.path("/omics/groups/OE0219/internal/yuyu/10.Benchmarking/analysis/data_processing_manuscript/0_project_setting.R")
source(config)

##### idx
wgbs_idx  =  1:10
swift_idx = 11:20
twgbs_idx = 21:30
pbat_idx  = 31:38
emseq_idx = 39:48 
# idx for metrics where some workflows failed in PBAT. 
idxs = list(wgbs_idx, swift_idx, twgbs_idx, pbat_idx, emseq_idx)
# idx for metrics 
idxs_all = list(wgbs_idx, swift_idx, twgbs_idx, c(31:40), c(41:50))

##### 1. whole genome deviation #####
df = read_("long_value", "02-5_calc_genome_wide_deivation")
m1  = df %>% group_by(protocol, workflow) %>% summarise(score=mean(abs(beta))) %>% ungroup() 
m1$protocol <- factor(m1$protocol, levels=protocols)
m1 = m1 %>% arrange(protocol)

#####
tb1= data.frame()
for(idx in idxs){

  m = m1[idx,] 
  
  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd, 
                    minmax=(score-minv)/d,
                    mtype="WG_DEV")
  
  s = sort(m$score, index=TRUE)$ix
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }  
  m = cbind(m, rank=s_, annot = s_)
  
  tb1 = rbind(tb1, m)
}

##

## 2. gold-standard
beta_cov_gs_ds_tb <- read_("beta_cov_gs_tb", "03-1_calc_beta_cov_gs")
beta_cov_gs_ds_tb$protocol <- replace_prot_name_(beta_cov_gs_ds_tb$protocol)
beta_cov_gs_ds_tb$protocol <- factor(beta_cov_gs_ds_tb$protocol, levels=protocols)
beta_cov_gs_ds_tb$workflow <- replace_wf_name_(beta_cov_gs_ds_tb$workflow)

beta_cov_gs_ds_tb <- beta_cov_gs_ds_tb %>%
  mutate(dev=apply(cbind(beta, lower, upper), 1, 
                   function(r){
                     m=r[1]
                     lower=r[2]
                     upper=r[3]
                     return(
                       ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                     )
                   })
  )

##
# Save as a xlsx
beta_cov_gs_ds_tb %>%
  writexl::write_xlsx(path = file.path(data_dir_, "gs_dev.xlsx"))
save_("gs_dev_tb", data=beta_cov_gs_ds_tb)
##

m2 = beta_cov_gs_ds_tb %>% dplyr::select("protocol", "workflow", "dev")
m2 = m2[!is.na(m2$dev),]
m2 = m2 %>% dplyr::group_by(protocol, workflow) 
m2 = m2 %>% dplyr::summarise(score = mean(abs(dev))) %>% dplyr::arrange(protocol)

tb2 = data.frame()
for(idx in idxs){

  m = m2[idx,] 
  
  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd, 
                    minmax=(score-minv)/d,
                    mtype="GS_DEV")

  s = sort(m$score, index=TRUE)$ix
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }  
  m = cbind(m, rank=s_, annot = s_)
  
  tb2 = rbind(tb2, m)
}

## 3. DMI Corr
df = read_("corr", "04-4_analyze_sequencing_by_DSS_feedback")
#df = read_("df_cor", "04-4_analyze_sequencing_by_DSS_debug3")

corr_tb = df %>% mutate(sample=gsub("hg38.(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).(.*)", "\\2", rownames(df))) %>%
  mutate(workflow=gsub("hg38.(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).(.*)", "\\3", rownames(df))) %>%
  mutate(protocol=gsub("hg38.(WGBS|TWGBS|PBAT|SWIFT|EMSEQ).(5N|5T|6T|6N).(.*)", "\\1", rownames(df))) %>% dplyr::rename(score=V1) %>%
  dplyr::select(sample, protocol, workflow, score)

corr_tb  = corr_tb %>% group_by(protocol, workflow) %>% summarise(score=mean(abs(score))) %>% ungroup() 

corr_tb$protocol <- replace_prot_name_(corr_tb$protocol)
corr_tb$workflow <- replace_wf_name_(corr_tb$workflow)
corr_tb$protocol <- factor(corr_tb$protocol, levels=protocols)
corr_tb = corr_tb %>% arrange(protocol)

tb3 = data.frame()
for(idx in idxs){

  m = corr_tb[idx,] 

  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd, 
                    minmax=(score-minv)/d,
                    mtype="Array_Seq_corr")
 
  s = sort(m$score, index=TRUE, decreasing=TRUE)$ix
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }  
  
  m = cbind(m, rank=s_, annot = s_)  
  
  tb3 = rbind(tb3, m)
}

## 3. DMI AUC
ROCit_tb = read_("weighted_AUC", "04-7_plot_weighted_AUC")
df_auc = unique(ROCit_tb %>% dplyr::select("workflow", "protocol", "weighted"))
df_auc <- df_auc %>% dplyr::arrange(protocol) %>% dplyr::rename(score = weighted)
rownames(df_auc) <- NULL

df_auc$protocol <- replace_prot_name_(df_auc$protocol)
df_auc$workflow <- replace_wf_name_(df_auc$workflow)
df_auc$protocol <- factor(df_auc$protocol, levels=protocols)
df_auc <- df_auc %>% dplyr::arrange(protocol)

tb4 = data.frame()
for(idx in idxs){
  
  m = df_auc[idx,] 
  
  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd, minmax=(score-minv)/d)
  
  q <- quantile(m$score)
  zq <- quantile(m$zscore)
  mq <- quantile(m$minmax)
  m <- m %>% mutate(mtype="DMI AUC")  
  
  s = sort(m$score, index=TRUE, decreasing=TRUE)$ix
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }  
  
  m = cbind(m, rank=s_, annot = s_)
  
  tb4 = rbind(tb4, m)
}

tb4_ = data.frame()
for(p in protocols){
a = tb4 %>% filter(protocol == p) %>% left_join(tb3, by=c("workflow", "protocol")) %>% 
  mutate(ave_rank = (rank.x+rank.y)/2) %>%
  mutate(score = (score.x+score.y)/2) %>%
  mutate(zscore = (zscore.x+zscore.y)/2) %>%
  mutate(minmax = (minmax.x+minmax.y)/2) %>%
  mutate(mtype = "DIFF") %>% select("workflow", "protocol", "score", "zscore", "minmax", "mtype", "ave_rank") %>% arrange(ave_rank, zscore) %>% 
  mutate(rank=row_number(), annot=row_number()) %>% select(-ave_rank)
  tb4_ = rbind(tb4_, a)
}

tb4_ = tb4_ %>% mutate(zscore=-zscore) ## for combined

## additional 4 depth
depth_auc_tb = read_("depth_auc_tb", "01-4_plot_depth_vs_coverage") %>% mutate(mtype="Depth_%CpG_AUC") %>% dplyr::rename(score=auc) 
# Save as a xlsx
depth_auc_tb %>%
  writexl::write_xlsx(path = file.path(data_dir_, "depth_auc_tb.xlsx"))
save_("depth_auc_tb", data=depth_auc_tb)
##
tb5_auc = data.frame()
for(idx in idxs){
  m = depth_auc_tb[idx,]
  
  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd,
                    minmax=(score-minv)/d,
                    mtype="Depth_%CpG_AUC")
  
  s = rev(sort(m$score, index=TRUE)$ix)
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }  
  
  m = cbind(m, rank=s_, annot = s_) 
  
  tb5_auc = rbind(tb5_auc, m)  
}
tb5 = tb5_auc

tb5 = tb5 %>% mutate(zscore=-zscore) ## for combined
## 5. Hw_performance
###############
hw_tb = read_("hw_runt_mem_na_tb", "05-1_plot_runtime_and_maxmem")
hw_tb$protocol <- replace_prot_name_(hw_tb$protocol)
hw_tb$protocol <- factor(hw_tb$protocol, levels=protocols)
hw_tb$workflow <- replace_wf_name_(hw_tb$workflow)
hw_run_time_tb <- hw_tb %>% dplyr::mutate(score=run_time_h) %>% dplyr::arrange(protocol) %>% dplyr::select(protocol, workflow, score)
hw_max_mem_tb <- hw_tb %>% dplyr::mutate(score=max_mem_g) %>% dplyr::arrange(protocol) %>% dplyr::select(protocol, workflow, score)

# Save as a xlsx
hw_run_time_xlsx <- hw_tb %>% dplyr::mutate(score=run_time_h, mtype="run_time_h") %>% dplyr::arrange(protocol) %>% dplyr::select(protocol, workflow, score, mtype)
hw_max_mem_xlsx <- hw_tb %>% dplyr::mutate(score=max_mem_g, mtype="max_mem_g") %>% dplyr::arrange(protocol) %>% dplyr::select(protocol, workflow, score, mtype)
hw_xlsx = rbind(hw_run_time_xlsx, hw_max_mem_xlsx) 
hw_xlsx$mtype = ifelse(hw_xlsx$mtype=="run_time_h", "Run_Time", "Max_Mem")
hw_xlsx %>% writexl::write_xlsx(path = file.path(data_dir_, "runtime_maxmem.xlsx"))
save_("runtime_maxmem_tb", data=hw_xlsx)
##

tb6 = data.frame()
for(idx in idxs){
  m = hw_run_time_tb[idx,]
  
  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd,
                    minmax=(score-minv)/d,
                    mtype="Run_Time")
  
  s = sort(m$score, index=TRUE)$ix
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }    

  m = cbind(m, rank=s_, annot = s_) 
  
  tb6 = rbind(tb6, m)  
}

tb7 = data.frame()
for(idx in idxs){
  m = hw_max_mem_tb[idx,]
  
  mean = mean(m$score)
  sd = sd(m$score)
  maxv = max(m$score)
  minv = min(m$score)
  d = maxv - minv
  
  m <- m %>% mutate(zscore=(score-mean)/sd,
                    minmax=(score-minv)/d,
                    mtype="Max_Mem")
  
  s = sort(m$score, index=TRUE)$ix
  s_ = s
  
  last_r = 1
  for(i in s){
    s_[i] = last_r
    last_r = last_r + 1
  }    
  
  m = cbind(m, rank=s_, annot = s_)
  
  tb7 = rbind(tb7, m) 
}
##
###############
tb_ranking = rbind(tb1, tb2, tb4_, tb5, tb6, tb7)
tb_ranking$mtype = factor(tb_ranking$mtype, levels=c("Depth_%CpG_AUC", 'WG_DEV', 'GS_DEV', 'DIFF', "Run_Time", "Max_Mem"))

save_("final_ranking_normalization_tb", data=tb_ranking)

# excel output
tb_exl = data.frame()
for(pro in protocols){
  a = tb_ranking %>% filter(protocol==pro) %>% dplyr::select(workflow, mtype, score)
  a = reshape(a, idvar="workflow", timevar="mtype", direction="wide") %>% mutate(protocol=pro)
  tb_exl = rbind(tb_exl, a)
}
tb_exl = tb_exl %>% dplyr::select(workflow, protocol, everything())

tb_exl %>%
  writexl::write_xlsx(path = file.path(data_dir_, "score_table.xlsx"))
save_("score_table_tb", data=tb_exl)
#

tb_ranking$protocol = factor(tb_ranking$protocol, levels=protocols)

## create blank rows for unavailable 
tb_lack = data.frame(score=NA, workflow=c('gemBS'), protocol=c('PBAT'), 
                     rank=(length(pbat_idx)+1)/2, zscore=NA, minmax=NA, annot=NA,
                     mtype=c("Depth_%CpG_AUC", 'WG_DEV', 'GS_DEV', 'DIFF', "Run_Time", "Max_Mem"))
tb_ranking = rbind(tb_ranking, tb_lack)
tb_lack = data.frame(score=NA, workflow=c('BAT'), protocol=c('PBAT'), 
                     rank=(length(pbat_idx)+1)/2, zscore=NA, minmax=NA, annot=NA,
                     mtype=c("Depth_%CpG_AUC", 'WG_DEV', 'GS_DEV', 'DIFF', "Run_Time", "Max_Mem"))
tb_ranking = rbind(tb_ranking, tb_lack)

save_("final_ranking_normalization_tb", data=tb_ranking)

# Save as a xlsx
tb_ranking %>%
  writexl::write_xlsx(path = file.path(data_dir_, "final_ranking.xlsx"))

## order by mean rank
global_ranking = tb_ranking %>% dplyr::group_by(workflow) %>% 
    dplyr::summarize(s_=mean(as.numeric(rank))) %>%
    dplyr::arrange(s_, workflow) 

## order workflow by global_ranking
tb_ranking$workflow = factor(tb_ranking$workflow, levels=rev(global_ranking$workflow))

## Label only top three
tb_ranking_ = tb_ranking %>% dplyr::mutate(sn_ = ifelse(annot>3, NA, annot)) %>% 
  dplyr::mutate(annot=as.character(annot))

tb_ranking_$annot = factor(tb_ranking_$annot, levels=1:11)

save_("final_ranking_normalization_data_tb", data=tb_ranking_)

mPalette <- c("#004616", "#005A1E", "#007328",
              "#007F2E", "#2A964D", "#59A76C",
              "#B2D3B9", "#CCE1D0", "#DFEBE2", "#ECF2ED", "darkgray")

g = tb_ranking_ %>% 
  ggplot(aes(mtype, workflow, fill= annot)) + 
  geom_tile(colour="white",size=0.25) + geom_text(aes(label = sn_), color="white") +
  facet_wrap(~ protocol, ncol=5) +
  theme(
    panel.border=element_blank(),
    panel.background = element_blank(),
    legend.text=element_text(face="bold"),
    axis.ticks=element_line(size=0.4),
    axis.title.x = element_text(),
    strip.background =element_blank(),
    axis.text.x = element_text(angle = 60, hjust=1), legend.position='none'
  ) + guides(fill=guide_legend(title="Rank",ncol = 11, byrow = TRUE)) + xlab("") +  ylab("") + coord_fixed() +
  scale_x_discrete(breaks= c("Depth_%CpG_AUC", 'WG_DEV', 'GS_DEV', 'DIFF', "Run_Time", "Max_Mem"), 
                   label = c("Coverage", 'WG Deviation', 'GS Deviation', 'DM Calling', "Run Time", "Max Mem")) + 
  scale_colour_manual(values=mPalette) + 
  scale_fill_manual(values=mPalette)

g

save_(paste0("heatmap_grid_ten_gsmean_rank"), plot=g, use_pdf = TRUE, width=8, height=5)

g = tb_ranking_ %>% 
  ggplot(aes(mtype, workflow, fill= annot)) + 
  geom_tile(colour="white",size=0.25) + geom_text(aes(label = annot), color="white") +
  facet_wrap(~ protocol, ncol=5) +
  theme(
    panel.border=element_blank(),
    panel.background = element_blank(),
    legend.text=element_text(face="bold"),
    axis.ticks=element_line(size=0.4),
    axis.title.x = element_text(),
    strip.background =element_blank(),
    axis.text.x = element_text(angle = 60, hjust=1), legend.position='none'
  ) + guides(fill=guide_legend(title="Rank",ncol = 11, byrow = TRUE)) + xlab("") +  ylab("") + coord_fixed() +
  scale_x_discrete(breaks= c("Depth_%CpG_AUC", 'WG_DEV', 'GS_DEV', 'DIFF', "Run_Time", "Max_Mem"), 
                   label = c("Coverage", 'WG Deviation', 'GS Deviation', 'DM Calling', "Run Time", "Max Mem")) + 
  scale_colour_manual(values=mPalette) + 
  scale_fill_manual(values=mPalette)

g

save_(paste0("heatmap_grid_ten_gsmean_rank_10"), plot=g, use_pdf = TRUE, width=8, height=5)


indv_ranking = tb_ranking %>%  group_by(workflow) %>%
  dplyr::summarize(s_=mean(as.numeric(rank))) %>%
  dplyr::arrange(s_) %>% ungroup %>% 
  mutate(r1=as.numeric(as.factor(rank(s_)))) 

## alluvial plot
indv_ranking_tb = data.frame(1:10)

p = "EM-seq"
t = lapply(protocols, function(x)
tb_ranking %>% dplyr::filter(protocol==x) %>% group_by(workflow) %>%
  dplyr::summarize(s_=mean(as.numeric(rank))) %>%
  dplyr::arrange(s_) %>% ungroup %>% 
  mutate(r1=as.numeric(as.factor(rank(s_)))) %>% dplyr::select(workflow)
) %>% bind_cols(.)

colnames(t) = protocols

p="EM-seq"
indv_ranking = tb_ranking %>% dplyr::filter(protocol==p) %>% group_by(workflow) %>%
  dplyr::summarize(s_=mean(as.numeric(rank)), z_=mean(zscore)) %>%
  dplyr::arrange(s_, z_) %>% ungroup %>% 
  mutate(r1=row_number()) 

indv_ranking

indv_rank = as.character(indv_ranking$workflow)

indv_ranking = indv_ranking %>% 
               arrange(desc(workflow)) %>% 
               mutate(r1_n = indv_rank)
  
indv_ranking_tb = cbind(indv_ranking_tb, indv_ranking)

for(p in c("Swift", "T-WGBS", "PBAT", "EM-seq")){
  indv_ranking = tb_ranking %>% dplyr::filter(protocol==p) %>% group_by(workflow) %>%
    dplyr::summarize(s_=mean(as.numeric(rank))) %>%
    dplyr::arrange(s_) %>% ungroup %>% 
    mutate(r1=as.numeric(as.factor(rank(s_)))) 
  
  indv_rank = as.character(indv_ranking$workflow)
  
  indv_ranking = indv_ranking %>% 
    arrange(desc(workflow)) %>% mutate(r1_n = indv_rank) %>%
    dplyr::select(s_, r1, r1_n)

  indv_ranking_tb = cbind(indv_ranking_tb, indv_ranking)
}
indv_ranking_tb = indv_ranking_tb[-1]
colnames(indv_ranking_tb) = c("workflow", "WGBS_score", "WGBS_rank", "WGBS_rank_n", 
                              "Swift_score", "Swift_rank", "Swift_rank_n", 
                              "T-WGBS_score", "T-WGBS_rank", "T-WGBS_rank_n",  
                              "PBAT_score", "PBAT_rank", "PBAT_rank_n",  
                              "EM-seq_score", "EM-seq_rank", "EM-seq_rank_n") 

save_("indv_ranking_tb", data=indv_ranking_tb)

