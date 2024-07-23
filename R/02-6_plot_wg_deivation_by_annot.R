## Configuration
analysis_name <- "02-7_plot_wg_deviation_by_annot"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)
library(annotatr)
library(dplyr)

annots_hg38 = builtin_annotations()[str_detect(builtin_annotations(), "hg38")]
annots_hg38 = annots_hg38[-17] # remove hg38_lncrna_gencode

legal_chrs = c("chr1","chr2","chr3","chr4", "chr5", "chr6", "chr7","chr8","chr9","chr10",
               "chr11","chr12","chr13","chr14", "chr15", "chr16", "chr17","chr18","chr19","chr20",
               "chr21","chr22","chrX","chrY")

annotated_df = read_("annotated_wg_dev_df", "02-6_calc_wg_deviation_by_annot")

df = annotated_df %>% group_by(workflow, protocol, annotation) %>% summarise(mean=mean(mean)) %>% ungroup()

df$workflow = factor(df$workflow, levels=rev(workflows))
df$protocol = replace_prot_name_(df$protocol)
df$protocol = factor(df$protocol, levels=protocols)

tmp = data.frame(workflow=c("BAT"), protocol="PBAT", mean=NA, annotation=unique(df$annotation))
df = rbind(df, tmp)
tmp = data.frame(workflow=c("gemBS"), protocol="PBAT", mean=NA, annotation=unique(df$annotation))
df = rbind(df, tmp)

annots_hg38 = gsub("hg38_", "", annots_hg38)
df$annotation = gsub("hg38_", "", df$annotation)


anno_order = df %>% filter(protocol=="WGBS") %>% group_by(annotation) %>% summarise(s=mean(mean)) %>% 
  arrange(s) %>% dplyr::select(annotation)
df$annotation = factor(df$annotation,levels=as.character(anno_order$annotation))

g = df %>% ggplot(aes(annotation, workflow, fill=mean)) + 
  geom_tile(colour="white",size=0.25) +
  theme(
    panel.border=element_blank(),
    panel.background = element_blank(),
    legend.text=element_text(face="bold"),
    axis.ticks=element_line(linewidth=0.4),
    axis.title.x = element_text(),
    strip.background =element_blank(),
    axis.text.x = element_text(angle = 60, hjust=1, size=7), 
    legend.position='bottom',
    strip.text = element_text(size = 11)
  ) + facet_wrap(~ protocol, ncol=5) + ylab("") + scale_fill_gradient(low = "yellow2",
                                                                      high = "darkgreen",
                                                                      guide = "colorbar")
g

save_("wg_deviation_annotation_plot", plot=g, use_pdf = TRUE, width=11, height=5)

df$workflow = factor(df$workflow, levels=rev(c("BSBolt", "methylCtools", "bwa-meth", "BAT", 
                                           "Bismark", "Biscuit", "FAME", "gemBS", "methylpy", "GSNAP")))

g = df %>% ggplot(aes(annotation, workflow, fill=mean)) + 
  geom_tile(colour="white",size=0.25) +
  theme(
    panel.border=element_blank(),
    panel.background = element_blank(),
    legend.text=element_text(face="bold"),
    axis.ticks=element_line(linewidth=0.4),
    axis.title.x = element_text(),
    strip.background =element_blank(),
    axis.text.x = element_text(angle = 60, hjust=1, size=7), 
    legend.position='bottom',
    strip.text = element_text(size = 11)
  ) + facet_wrap(~ protocol, ncol=5) + ylab("") + scale_fill_gradient(low = "yellow2",
                                                                      high = "darkgreen",
                                                                      guide = "colorbar")
g

save_("wg_deviation_annotation_order_by_rank_plot", plot=g, use_pdf = TRUE, width=11, height=5)
