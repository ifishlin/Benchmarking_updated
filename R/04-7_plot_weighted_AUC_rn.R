## Configuration
analysis_name <- "04-7_plot_weighted_AUC_rn"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(ROCit)

## Load RnBeads DML data
dml_hg38_filtered_tb = read_("dml_rnbeads_hg38_tb", "04-2_liftover_RnBeads_loci_hg19_to_hg38") %>%
  arrange(diffmeth.p.adj.fdr) %>% mutate(gain_or_loss_array=ifelse(mean.diff > 0, "loss in tumor", "gain in tumor"))

##
## RnBeads diffmeth.p.adj.fdr < 0.1 => positive
df_gain = data.frame()
df_loss = data.frame()
for(p in protocols_int){
  #p = "WGBS"
  dml_test = read_(paste0("dml_i450_test_", p),"04-4_analyze_sequencing_by_DSS")
  p = replace_prot_name_(p)
  
  for(w in workflows){
     #w = "methylCtools"
     id = paste0(w, "_", p)
     
     if(is.null(dml_test[[id]])){
       next
     }
     
     dml_protocol = dml_test[[paste0(w, "_", p)]] %>%
       as_tibble() %>%
       dplyr::mutate(seqnames=chr, start=pos, end=pos+1, gain_or_loss=ifelse(diff>0, "loss in tumor", "gain in tumor")) %>%
       dplyr::mutate(fdr2=ifelse(abs(diff)>=0.1, fdr, 1))

     for(direction in directions){
       #direction = "loss in tumor"
       dml_protocol_ <- dml_protocol %>% dplyr::filter(gain_or_loss==direction)

       dml_hg38_filtered_tb_ <- dml_hg38_filtered_tb %>% dplyr::filter(gain_or_loss_array==direction) %>%
         dplyr::mutate(diffmeth.p.adj.fdr2=ifelse(abs(mean.diff)>=0.1, diffmeth.p.adj.fdr, 1))

       set.seed(123)
       shuffled_df <- dml_hg38_filtered_tb_[sample(nrow(dml_hg38_filtered_tb_), replace = FALSE), ]       
       
       o = left_join(shuffled_df, dml_protocol_, by=c("seqnames", "start", "end")) %>%
         dplyr::select("seqnames", "start", "end","diffmeth.p.adj.fdr", "diffmeth.p.adj.fdr2", "fdr", "fdr2")

       o[is.na(o)] = 1 ## no prediction, set fdr to 1
       a = o %>% mutate(diff_class = if_else(diffmeth.p.adj.fdr2 < DIFFMETH_P_ADJ_FDR, "+", "-"), 
                        score = 1-fdr2, score2 = -fdr2)
       
       a = a %>% select(fdr, diff_class) %>% mutate(fdr_r = -fdr) 
       a = a %>% arrange(fdr_r)
       a = a %>% mutate(rn1=row_number())

       # add small random number.
       ROCit_obj <- rocit(score=a$rn1, class=a$diff_class, negref = "-", step = TRUE)

       tpr = ROCit_obj["TPR"][["TPR"]] %>% as_tibble()
       fpr = ROCit_obj["FPR"][["FPR"]] %>% as_tibble()
       f = cbind(tpr, fpr)
       colnames(f) = c("tpr", "fpr")
       f = f %>% dplyr::mutate(protocol=p, workflow=w, auc=ROCit_obj$AUC)
       if(direction == "loss in tumor"){
         df_gain = rbind(df_gain, f)
       }else{
         df_loss = rbind(df_loss, f)
       }

     }
  }
}

save_("df_gain", data=df_gain)
save_("df_loss", data=df_loss)

df_gain = read_("df_gain", "04-7_plot_weighted_AUC_rn")
df_loss = read_("df_loss", "04-7_plot_weighted_AUC_rn")

df_gain$protocol = factor(df_gain$protocol, levels=protocols)
df_gain$workflow = factor(df_gain$workflow, levels=workflows)

#df_gain2 = df_gain[29610:29650,]

g = df_gain %>% filter(protocol=="WGBS") %>% ggplot() +
  geom_line(
    aes(fpr, tpr, color=workflow),
    size=0.3,
    alpha=2
  ) +
  xlab("1-Specificity (FPR)") +
  ylab("Sensitivity (TPR)") +
  #facet_wrap( ~ protocol, ncol=5, scales="free_x") +
  geom_abline(intercept=0, slope=1, size=1, linetype="dashed") +
  #scale_x_continuous(breaks=custom_breaks, labels=custom_labels) +
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        legend.position='none',
        strip.background =element_blank(),
        panel.border=element_rect(fill=NA)) +
  color_palette_fill() + color_palette_color() + scale_x_continuous(limits = c(0,1), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0,1), expand = c(0, 0)) 

g

save_(
  "ROC",
  plot=g,
  use_pdf = TRUE,
  width=3,
  height=2.5
)

for(p in protocols){
  g = df_gain %>% filter(protocol == p) %>% ggplot() +
    geom_line(
      aes(fpr, tpr, color=workflow),
      size=0.3,
      alpha=2
    ) +
    xlab("1-Specificity (FPR)") +
    ylab("Sensitivity (TPR)") +
    geom_abline(intercept=0, slope=1, size=1, linetype="dashed") +
    #scale_x_continuous(breaks=custom_breaks, labels=custom_labels) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          legend.position='none',
          strip.background =element_blank(),
          panel.border=element_rect(fill=NA)) +
    color_palette_fill() + color_palette_color()
  
  g
  
  save_(
    paste0("ROC_gain_", p),
    plot=g,
    use_pdf = TRUE,
    width=3,
    height=2.5
  )
  
  
  g = df_loss %>% filter(protocol == p) %>% ggplot() +
    geom_line(
      aes(fpr, tpr, color=workflow),
      size=0.3,
      alpha=2
    ) +
    xlab("1-Specificity (FPR)") +
    ylab("Sensitivity (TPR)") +
    geom_abline(intercept=0, slope=1, size=1, linetype="dashed") +
    #scale_x_continuous(breaks=custom_breaks, labels=custom_labels) +
    theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          legend.position='none',
          strip.background =element_blank(),
          panel.border=element_rect(fill=NA)) +
    color_palette_fill() + color_palette_color()
  
  g
  
  save_(
    paste0("ROC_loss_", p),
    plot=g,
    use_pdf = TRUE,
    width=3,
    height=2.5
  )  
}

## Calculate AUC
df_auc = unique(df_gain %>% dplyr::select("workflow", "protocol", "auc") %>% dplyr::rename(auc_gain=auc)) 
df_auc = cbind(df_auc, unique(df_loss %>% dplyr::select("workflow", "protocol", "auc")) %>% 
                 dplyr::select("auc") %>% 
                 dplyr::rename(auc_loss=auc)) 

## Calculate weighted AUC
dml_hg38_count_tb = dml_hg38_filtered_tb %>% dplyr::count(gain_or_loss_array) %>% arrange(gain_or_loss_array)
df_auc = cbind(df_auc, as.matrix(df_auc[,c(3,4)]) %*% dml_hg38_count_tb[,2] / nrow(dml_hg38_filtered_tb))
colnames(df_auc)[5] = "weighted"
save_("weighted_AUC", data=df_auc)

## Plot
g = df_auc %>% mutate(mtype="auc") %>% ggplot(aes(x=workflow, y=weighted, fill= mtype, color=mtype)) +  
  geom_col(width = 0.4) + 
  facet_grid(~protocol) + 
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        axis.text.x = element_text(angle = 65, hjust = 1, size = 8),
        legend.position='none',
        strip.background =element_blank(),
        panel.border=element_rect(fill=NA)) +
  xlab("") + ylab("Weighted AUC") + 
  scale_y_continuous(expand = expansion(mult = c(0.02, .1))) + 
  scale_fill_manual(values=c("#83D4757D")) + 
  scale_color_manual(values=c("#2EB62C")) + 
  geom_hline(yintercept=c(0,0.2,0.4,0.6,0.8), linetype="dashed", size=0.1) 

g

save_(
  "DML_I450K_weighted_AUC_green",
  plot=g,
  use_pdf = TRUE,
  width=7.5,
  height=3
)  

df_loss2 = df_loss %>% filter(protocol=="WGBS", workflow=="methylCtools")
p = df_loss2 %>% ggplot() +
  geom_line(
    aes(fpr, tpr, color=workflow),
    size=1,
    alpha=2
  ) +
  xlab("1-Specificity (FPR)") +
  ylab("Sensitivity (TPR)") +
  geom_abline(intercept=0, slope=1, size=1, linetype="dashed") +
  #scale_x_continuous(breaks=custom_breaks, labels=custom_labels) +
  theme(panel.background = element_rect(fill = "white", colour = "black", linetype="solid")) +
  color_palette_fill() + color_palette_color()
#scale_color_brewer(palette="Spectral")

p


