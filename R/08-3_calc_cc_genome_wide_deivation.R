## Configuration
analysis_name <- "09-2_calc_genome_wide_deivation_rstudio"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)

value = c()

for(workflow in workflows){
  print(Sys.time())

  meth_base <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, workflow))
  
  for(sample in c("5N", "5T", "6N", "6T")){
    
    wg_cc <- read_(
      paste0("df_merged_",sample,"_N15_chr1"),
      paste0("create_CC_parallel_", sample,"_N15")
    )    
    
    meth = meth_base[,meth_base$sample==sample]
    
    meth_filt = subset_methrix(meth, contigs="chr1")
    meth_filt_tb <- meth_filt %>%
      get_matrix(add_loci=TRUE) %>%
      as_tibble 
    
    colnames(meth_filt_tb)[grep("EMSEQ", colnames(meth_filt_tb))] = "EMSEQ_beta"
    colnames(meth_filt_tb)[grep("SWIFT", colnames(meth_filt_tb))] = "SWIFT_beta"
    colnames(meth_filt_tb)[grep("\\.WGBS", colnames(meth_filt_tb))] = "WGBS_beta"
    colnames(meth_filt_tb)[grep("TWGBS", colnames(meth_filt_tb))] = "TWGBS_beta"
    colnames(meth_filt_tb)[grep("PBAT", colnames(meth_filt_tb))] = "PBAT_beta"
    
    #combined = cbind(meth_filt_tb[1000:1010,], wg_cc[1000:1010,4:6])
    combined = cbind(meth_filt_tb[], wg_cc[,4:5])
    
    combined$lower = as.numeric(combined$lower)
    combined$upper = as.numeric(combined$upper)
    combined = combined %>% mutate(dist=upper-lower) %>% filter(dist<0.6)
    
    combined <- combined %>%
      mutate(EMSEQ_dev=apply(cbind(EMSEQ_beta, lower, upper), 1, 
                       function(r){
                         m=r[1]
                         lower=r[2]
                         upper=r[3]
                         return(
                           ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                         )
                       })        
      ) %>%
      mutate(SWIFT_dev=apply(cbind(SWIFT_beta, lower, upper), 1, 
                             function(r){
                               m=r[1]
                               lower=r[2]
                               upper=r[3]
                               return(
                                 ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                               )
                             })        
      ) %>%
      mutate(WGBS_dev=apply(cbind(WGBS_beta, lower, upper), 1, 
                             function(r){
                               m=r[1]
                               lower=r[2]
                               upper=r[3]
                               return(
                                 ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                               )
                             })        
      ) %>% 
      mutate(TWGBS_dev=apply(cbind(TWGBS_beta, lower, upper), 1, 
                             function(r){
                               m=r[1]
                               lower=r[2]
                               upper=r[3]
                               return(
                                 ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                               )
                             })        
      )
    
    if(any(grepl("PBAT", colnames(combined)))){
      combined <- combined %>%
        mutate(PBAT_dev=apply(cbind(PBAT_beta, lower, upper), 1, 
                              function(r){
                                m=r[1]
                                lower=r[2]
                                upper=r[3]
                                return(
                                  ifelse(m>=lower, ifelse(m<=upper, 0, m-upper), m-lower) 
                                )
                              })        
        )  
    } 
    
    idx= grep("dev", colnames(combined))
    combined = combined[idx]
    colnames(combined) = paste0(sample, "_", workflow, "_", colnames(combined))
    a = colMeans(abs(combined), na.rm = TRUE)
    value = c(value, a)
  } 
}

df = data.frame(value)

save_("value", data=df)

df <- read_("value", "09.2_calc_genome_wide_deivation_rstudio")

#plot
df = df %>% mutate(sample=gsub("(5N|5T|6T|6N)_(.*)_(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)_dev", "\\1", rownames(df))) %>%
  mutate(workflow=gsub("(5N|5T|6T|6N)_(.*)_(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)_dev", "\\2", rownames(df))) %>%
  mutate(protocol=gsub("(5N|5T|6T|6N)_(.*)_(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)_dev", "\\3", rownames(df))) %>% dplyr::rename(beta=value) %>%
  select(sample, protocol, workflow, beta)
rownames(df) = NULL

df$protocol =  replace_prot_name_(df$protocol)
df$workflow =  replace_wf_name_(df$workflow)

mean_tb_sample2=df
mean_tb2=df %>% group_by(protocol, workflow) %>% summarise(mean_abs=mean(abs(beta))) %>% ungroup()

tb_ = data.frame()
tb_c_or_n_ = data.frame()
for(p in protocols){
  mean_tb_ = mean_tb2 %>% filter(protocol==p) 
  seq = seq(1, 10, 10/nrow(mean_tb_)) 
  mean_tb_ <- mean_tb_ %>% arrange(mean_abs) %>% mutate(x=seq)
  tb_ = rbind(tb_, mean_tb_)
  
  target <- mean_tb_$workflow # order
  
  mean_tb_c_or_n_ = mean_tb_sample2 %>% filter(sample=="5N", protocol==p) 
  tb_5N_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="N", s_id="5")
  
  mean_tb_c_or_n_ = mean_tb_sample2 %>% filter(sample=="5T", protocol==p)
  tb_5T_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="T", s_id="5") 
  
  mean_tb_c_or_n_ = mean_tb_sample2 %>% filter(sample=="6N", protocol==p) 
  tb_6N_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="N", s_id="6")
  
  mean_tb_c_or_n_ = mean_tb_sample2 %>% filter(sample=="6T", protocol==p)
  tb_6T_ = mean_tb_c_or_n_[match(target, mean_tb_c_or_n_$workflow),] %>% dplyr::mutate(x=seq, c_or_n="T", s_id="6")     
  
  tb_c_or_n_ = rbind(tb_c_or_n_, tb_5N_, tb_5T_, tb_6N_, tb_6T_) 
}

npg_color <- c(
  "#E64B35","#4DBBD5",
  "#00A087","#3C5488",
  "#F39B7F","#8491B4",
  "#91D1C2","#DC0000",
  "#7E6148","#B09C85",  
  "#EE766F","#2EB7BE"
)

tb_$protocol = factor(tb_$protocol, levels = protocols)
tb_c_or_n_$protocol = factor(tb_c_or_n_$protocol, levels = protocols)

title="Mean abs deviatopm from CC"
mean_plot <- ggplot() +
  geom_point(
    data=tb_,
    aes(
      x, mean_abs,
    ),
    position = position_dodge(width=1),
    size=3
  ) +
  geom_point(
    data=tb_,
    aes(
      x, mean_abs,
      color=workflow
    ),
    position = position_dodge(width=1),
    size=2.6
  ) +
  geom_point( #geom_boxplot
    data=tb_c_or_n_,
    aes(
      x, beta,
      shape=s_id,
      color=c_or_n
    ),
    size=1
  ) +
  ylab(paste0(" ", title)) +
  xlab("") + 
  scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) +
  #color_palette_color() + 
  #color_palette_fill() +    
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "right"
  ) + facet_wrap( ~ protocol, ncol=5, scales="free_x") + geom_hline(yintercept=c(0.1, 0.2), linetype="dashed", size=0.1) 

mean_plot

save_(
  paste0("whole_genome_mean_abs_shape_color_condensed"),
  plot=mean_plot,
  use_pdf=TRUE,
  width=7.5,
  height=5
)   
