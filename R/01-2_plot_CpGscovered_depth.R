## Configuration
analysis_name <- "01-2_plot_CpGscovered_depth"
config = file.path(getwd(), "0_project_setting.R")
source(config)

library(reshape2)
library(stringr)

## Load data
stats <- read_(
  "general_statistics",
  "01-1_calc_general_stats"
)

# Index of each metrics
mc_cidx = grep("Mean.Coverage", colnames(stats$WGBS)) # mean coverage
mm_cidx = grep("Mean.Methylation", colnames(stats$WGBS)) # mean methylation
ncpg_cidx = grep("CpG.Covered", colnames(stats$WGBS)) # CpG covered

mc = rbind(stats[["EM-seq"]][,mc_cidx], stats$PBAT[,mc_cidx], stats$Swift[,mc_cidx], stats[["T-WGBS"]][,mc_cidx], stats$WGBS[,mc_cidx])
mm = rbind(stats[["EM-seq"]][,mm_cidx], stats$PBAT[,mm_cidx], stats$Swift[,mm_cidx], stats[["T-WGBS"]][,mm_cidx], stats$WGBS[,mm_cidx])
ncpg = rbind(stats[["EM-seq"]][,ncpg_cidx], stats$PBAT[,ncpg_cidx], stats$Swift[,ncpg_cidx], stats[["T-WGBS"]][,ncpg_cidx], stats$WGBS[,ncpg_cidx])
rownames <- c(paste0(stats[["EM-seq"]][,1], "_EM-seq"), 
              paste0(stats$PBAT[,1],  "_PBAT"), 
              paste0(stats$Swift[,1], "_Swift"), 
              paste0(stats[["T-WGBS"]][,1], "_T-WGBS"), 
              paste0(stats$WGBS[,1],  "_WGBS"))
rownames(mc) = rownames
rownames(mm) = rownames
rownames(ncpg) = rownames

## Fraction of CpGs covered.
########################
df = data.frame()
p = str_split(rownames(ncpg) ,"_" ,simplify = TRUE)
df = rbind(df, data.frame(n_cpg = ncpg[,1], protocols=p[,2], sample="5N", workflows=p[,1]))
df = rbind(df, data.frame(n_cpg = ncpg[,2], protocols=p[,2], sample="5T", workflows=p[,1]))
df = rbind(df, data.frame(n_cpg = ncpg[,3], protocols=p[,2], sample="6N", workflows=p[,1]))
df = rbind(df, data.frame(n_cpg = ncpg[,4], protocols=p[,2], sample="6T", workflows=p[,1]))

df$protocols = factor(df$protocols, levels=protocols)
#df$workflows <- replace_wf_name_(df$workflows)

# Summarise with respect to samples.
df_data = df %>% mutate(metric=n_cpg, mtype="n_cpg") %>% dplyr::select(-n_cpg) 
df_data_condensed = df_data %>% dplyr::group_by(workflows, protocols, mtype) %>% 
  dplyr::summarise(s=mean(metric))

# Plot
g = ggplot() + geom_col(data=df_data_condensed, aes(x=workflows, y=s, fill=mtype, color=mtype), width=0.7) +
  facet_grid(col=vars(protocols), row=vars(mtype), scales = "free_y")  + 
  geom_point(data=df_data, aes(x = workflows, y = metric, color=sample), size=0.5, position=position_dodge(width=0.5)) + 
  scale_color_manual(values=c(sample_color_sheme, n_cpg="#2EB62C")) + 
  scale_fill_manual(values=c("#83D4757D")) +
  scale_y_continuous(expand = expansion(mult = c(0.02, .1))) +
  unified_pg +
  theme(axis.text = element_text(size=8),
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background.y = element_blank(),
        strip.text.y = element_blank(),
        legend.position = "none") + xlab("") + ylab("")

save_("fraction_CpGs_covered", width=7, height=3, plot=g, use_pdf=TRUE)

## Mean of coverage on CpGs 
########################
df2 = data.frame()
p = str_split(rownames(mc) ,"_" ,simplify = TRUE)
df2 = rbind(df2, data.frame(coverage = mc[,1], protocols=p[,2], sample="5N", workflows=p[,1]))
df2 = rbind(df2, data.frame(coverage = mc[,2], protocols=p[,2], sample="5T", workflows=p[,1]))
df2 = rbind(df2, data.frame(coverage = mc[,3], protocols=p[,2], sample="6N", workflows=p[,1]))
df2 = rbind(df2, data.frame(coverage = mc[,4], protocols=p[,2], sample="6T", workflows=p[,1]))

df2$protocols = factor(df2$protocols, levels=protocols)
#df2$workflows <- replace_wf_name_(df2$workflows)

# Summarise with respect to samples.
df2_data = df2 %>% mutate(metric=coverage, mtype="coverage") %>% dplyr::select(-coverage)
df2_data_condensed = df2_data %>% dplyr::group_by(workflows, protocols, mtype) %>% 
  dplyr::summarise(s=mean(metric))

# Plot
g2 = ggplot() + geom_col(data=df2_data_condensed, aes(x=workflows, y=s, fill=mtype, color=mtype), width=0.7) +
  facet_grid(col=vars(protocols), row=vars(mtype), scales = "free_y")  + 
  geom_point(data=df2_data, aes(x = workflows, y = metric, color=sample), size=0.5, position=position_dodge(width=0.5)) + 
  scale_color_manual(values=c(sample_color_sheme, coverage="#2EB62C")) + 
  scale_fill_manual(values=c("#83D4757D")) +
  scale_y_continuous(expand = expansion(mult = c(0.02, .1))) +
  unified_pg +
  theme(axis.text = element_text(size=8),
        axis.text.x = element_text(angle = 60, hjust=1),
        strip.background.y = element_blank(),
        strip.text.y = element_blank(),
        legend.position = "none") + xlab("") + ylab("")

save_("fraction_read_coverage", width=6.9, height=3, plot=g2, use_pdf=TRUE)

## Prepare data for final ranking
df_final_condensed = rbind(df_data_condensed, df2_data_condensed)
df_final_condensed$workflows = factor(df_final_condensed$workflows, levels=workflows)
save_("wg_cov_ncpg_condesed_tb", data=df_final_condensed)

df_final = rbind(df_data, df2_data)
df_final$workflows = factor(df_final$workflows, levels=workflows)
save_("wg_cov_ncpg_tb", data=df_final)


