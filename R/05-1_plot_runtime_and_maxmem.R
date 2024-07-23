## Configuration
analysis_name <- "05-1_plot_runtime_and_maxmem"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(scales)
library(lubridate)

## Time Conversion
to_hours <- function(sec){
  period = seconds_to_period(sec)
  return(round(period@day * 24 + period@hour + period@minute/60, 2))
}

to_days <- function(sec){
  period = seconds_to_period(sec)
  return(round(period@day + period@hour/24, 2))
}

to_gb<- function(mb){
  return(round(mb/1024, 2))
}

## Load data
df <- read.table(paste0(data_dir, "/hardware_performance_regression.txt"), sep = '\t',header = T, quote='', comment='')
df_trim <- read.table(paste0(data_dir, "/trim_run_time.txt"), sep = '\t',header = T, quote='', comment='') # Time of trimming
df$run_time = df$run_time + df_trim$run_time # Summarize the trimming time and the rests.

df <- df %>% dplyr::mutate(run_time_h=to_hours(run_time), run_time_d=to_days(run_time)) %>% 
  dplyr::mutate(run_time_h=to_hours(run_time), run_time_d=to_days(run_time)) %>% 
  dplyr::mutate(turnaround_time_h=to_hours(turnaround_time), turnaround_time_d=to_days(turnaround_time)) %>% 
  dplyr::mutate(max_mem_g=to_gb(max_mem), avg_mem_g=to_gb(avg_mem)) 

df$workflow = factor(replace_wf_name_(df$workflow), levels=workflows)
df$protocol = factor(df$protocol, levels=protocols)

save_("hw_runt_mem_tb", data=df)

rownum = df %>% mutate(rownum=row_number()) %>% filter(protocol=="PBAT", workflow %in% c("gemBS", "BAT")) %>% dplyr::select(rownum)
df_na = df %>% filter(!row_number() %in% unlist(rownum))

save_("hw_runt_mem_na_tb", data=df_na)

## df maximal memory
df_max_mem = df %>% dplyr::select(workflow, protocol, max_mem_g) %>%
  dplyr::filter(max_mem_g!=0) %>% dplyr::mutate(mtype='max_mem', score=max_mem_g) %>%
  dplyr::select(-max_mem_g)

g = df_max_mem %>% 
  ggplot(aes(x=workflow, y=score, fill=mtype, color=mtype)) + geom_col(width=0.7) + ylab("") + xlab("") +
  facet_grid(col=vars(protocol), row=vars(mtype), scales = "free_y") + unified_pg +
  theme(panel.spacing.y = unit(0, "mm"), 
        axis.text=element_text(size=8), 
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background =element_blank(),
        legend.position = 'none', 
        strip.background.y = element_blank(),
        strip.text.y = element_blank()) + 
        scale_fill_manual(values=c("#83D4757D")) + 
        scale_color_manual(values=c("#2EB62C")) +
        scale_y_continuous(expand = expansion(mult = c(0.02, .1)),
                           trans = log2_trans(),
                           breaks = trans_breaks("log2", function(x) 2^x))  +   
  ylab("Maximal Memory (GB)") + 
  geom_hline(yintercept=c(1, 2^2, 2^4, 2^6, 2^8), linetype="dashed", size=0.1) 

g

save_("max_mem", plot=g, use_pdf=TRUE, width=7.5, height=2.4)

## run Time
df_run_t = df %>% dplyr::select(workflow, protocol, run_time_h) %>%
  dplyr::filter(run_time_h!=0) %>% dplyr::mutate(mtype='run_t', score=run_time_h) %>%
  dplyr::select(-run_time_h)

g2 = df_run_t %>% 
  ggplot(aes(x=workflow, y=score, fill=mtype, color=mtype)) + geom_col(width=0.7) + ylab("") + xlab("") +
  facet_grid(col=vars(protocol), row=vars(mtype), scales = "free_y") + unified_pg +
  theme(panel.spacing.y = unit(0, "mm"), 
        axis.text=element_text(size=8), 
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background =element_blank(),
        legend.position = 'none', 
        strip.background.y = element_blank(),
        strip.text.y = element_blank())  + 
        scale_fill_manual(values=c("#83D4757D")) + 
        scale_color_manual(values=c("#2EB62C")) +
        scale_y_continuous(expand = expansion(mult = c(0.02, .1)),
        trans = 'log2',
        breaks = trans_breaks("log2", function(x) 2^x)) +   
  ylab("Run Time (hours)") + 
  geom_hline(yintercept=c(1, 2^2, 2^4, 2^6, 2^8), linetype="dashed",size=0.1) 

g2

save_("run_time", plot=g2, use_pdf=TRUE, width=7.5, height=2.4)

