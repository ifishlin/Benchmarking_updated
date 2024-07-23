## Configuration
analysis_name <- "02-5_plot_genome_wide_deivation"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)

df = data.frame()
for(w in workflows){
  a = read_(paste0("value_", w), "02-5_calc_genome_wide_deivation")
  protocol_num = length(a)/2
  frac = a[1:protocol_num]
  count = a[(protocol_num+1):length(a)]
  
  b = frac*count 
  b = b %>% mutate(sample=c(rep("5N",22), rep("5T",22), rep("6N",22), rep("6T",22))) %>% #chr1:22
    mutate(chr=rep(paste0("chr", 1:22), 4)) # sample 5N, 5T, 6N, 6T
  c = gather(b, key, value, -sample, -chr) %>%
    mutate(protocol=gsub("mean_(.*)", "\\1", key), workflow=w) %>%
    dplyr::select(-key)
  d = gather(count, key, count) %>% dplyr::select(-key)
  e = c %>% mutate(count=d$count) %>% dplyr::select(protocol, workflow, sample, chr, value, count)
  df = rbind(df, e)
}

df_summery = df %>% group_by(protocol, workflow, sample) %>% summarize(dev=sum(value), count=sum(count)) %>% 
  mutate(beta=dev/count) %>% ungroup() %>% dplyr::select(-dev, -count)

df = df_summery

df$protocol =  replace_prot_name_(df$protocol)
df$workflow =  replace_wf_name_(df$workflow)

save_("long_value", data=df)
df = read_("long_value", "02-5_plot_genome_wide_deivation")

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
    legend.position = "none"
  ) + facet_wrap( ~ protocol, ncol=5, scales="free_x") + geom_hline(yintercept=c(0, 0.1, 0.2,0.3), linetype="dashed", size=0.1) 

mean_plot

save_(
  paste0("whole_genome_mean_abs_shape_color_condensed"),
  plot=mean_plot,
  use_pdf=TRUE,
  width=7.5,
  height=3.5
)   

