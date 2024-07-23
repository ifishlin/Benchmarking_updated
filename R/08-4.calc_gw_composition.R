## Configuration
analysis_name <- "09_3.stat_composition"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(foreach)
library(doParallel)
library(methrix)

stat_df = data.frame()
for(sample in c("5N", "5T", "6N", "6T")){
  for(chr in paste0("chr", 1:22)){
    df = read_(paste0("df_merged_", sample ,"_N15_", chr), paste0("09_1.Create_CC_",sample,"_N15"))
    df_na = df[!is.na(df$number),]
    df_na = df_na %>% mutate(BAT=as.numeric(substr(workflow_encoding,1,1))) %>% 
      mutate(Biscuit=as.numeric(substr(workflow_encoding,2,2))) %>% 
      mutate(Bismark=as.numeric(substr(workflow_encoding,3,3))) %>% 
      mutate(BSBolt=as.numeric(substr(workflow_encoding,4,4))) %>% 
      mutate(bwameth=as.numeric(substr(workflow_encoding,5,5))) %>% 
      mutate(FAME=as.numeric(substr(workflow_encoding,6,6))) %>% 
      mutate(gemBS=as.numeric(substr(workflow_encoding,7,7))) %>% 
      mutate(GSNAP=as.numeric(substr(workflow_encoding,8,8))) %>% 
      mutate(methylCtools=as.numeric(substr(workflow_encoding,9,9))) %>% 
      mutate(methylpy=as.numeric(substr(workflow_encoding,10,10)))
    
    x = colSums(df_na[,6:15])/nrow(df_na)  
    my_dataframe <- as.data.frame(t(c(sample=sample, chr=chr, "number"=nrow(df_na) ,x)))
    
    stat_df = rbind(stat_df, my_dataframe)
  }
}

stat_df[, (ncol(stat_df)-10):ncol(stat_df)] = apply(stat_df[, (ncol(stat_df)-10):ncol(stat_df)], 2, as.numeric)

stat_df_mean_by_chr = stat_df %>% group_by(chr) %>% summarise(mean_BAT = mean(BAT), mean_Biscuit = mean(Biscuit), mean_Bismark = mean(Bismark),
                                        mean_BSBolt = mean(BSBolt), mean_bwameth = mean(bwameth), mean_FAME = mean(FAME),
                                        mean_gemBS = mean(gemBS), mean_GSNAP = mean(GSNAP), mean_methylCtools= mean(methylCtools), 
                                        mean_methylpy = mean(methylpy)) %>% ungroup()

save_("stat_df", data=stat_df)
save_("stat_df_mean_by_chr", data=stat_df_mean_by_chr)

stat_df_mean_by_chr = stat_df_mean_by_chr %>% gather(workflow, value, -chr)
stat_df_mean_by_chr = stat_df_mean_by_chr %>% mutate(workflow=gsub("mean_(.*)", "\\1", workflow))

stat_df_chr1 = stat_df_mean_by_chr %>% filter(chr=="chr1")

p<-ggplot(data=stat_df_chr1, aes(x=workflow, y=value, fill=workflow)) +
  geom_col(width=0.7)  + unified_pg + #facet_grid(col=vars(chr), scales = "free_y")
  theme(panel.spacing.y = unit(0, "mm"), 
        axis.text=element_text(size=8), 
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background =element_blank(),
        legend.position = 'right', 
        strip.background.y = element_blank(),
        strip.text.y = element_blank()) + color_palette_color() + color_palette_fill()+
  geom_hline(yintercept=c(0.5, 1, 1.5, 2), linetype="dashed", size=0.1) 
p

save_("chr1", plot=p, use_pdf=TRUE, width=7.5, height=4)

stat_df_mean_by_chr = stat_df_mean_by_chr %>% mutate(members_included=value/22) 

stat = stat_df_mean_by_chr %>% group_by(workflow) %>% summarise(n=sum(value)/22) %>% ungroup() %>% mutate(name_col=workflow)
stat$name_col = factor(stat$name_col = levels=stat$name_col) 
stat = stat %>% arrange(-n)
stat$workflow = factor(stat$workflow, levels=stat$workflow)

p<-ggplot(data=stat, aes(x=workflow, y=n, fill=name_col)) +
  geom_col(width=0.7)  + unified_pg + 
  theme(panel.spacing.y = unit(0, "mm"), 
        axis.text=element_text(size=8), 
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background =element_blank(),
        legend.position = 'none', 
        strip.background.y = element_blank(),
        strip.text.y = element_blank()) + color_palette_color() + color_palette_fill() +
        geom_hline(yintercept=c(0, 0.6, 1.2, 1.8, 2.4), linetype="dashed", size=0.1) + 
        scale_y_continuous(breaks=c(0, 0.6, 1.2, 1.8, 2.4), labels=c("0","0.2","0.4","0.6", "0.8"), expand = c(0,0.03)) 

p

save_("ave", plot=p, use_pdf=TRUE, width=4, height=2.5)

p<-ggplot(data=stat_df_mean_by_chr, aes(x=workflow, y=members_included, fill=workflow)) +
  geom_col(width=0.7) + unified_pg + facet_grid(col=vars(chr), scales = "free_y") +
  theme(panel.spacing.y = unit(0, "mm"), 
        axis.text=element_text(size=8), 
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background =element_blank(),
        legend.position = 'none', 
        strip.background.y = element_blank(),
        strip.text.y = element_blank()) + color_palette_color() + color_palette_fill()
p

save_("all", plot=p, use_pdf=TRUE, width=20, height=4)

