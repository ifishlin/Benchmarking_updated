## Configuration
analysis_name <- "04-4_analyze_sequencing_by_DSS_debug3"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(liftOver)
library(methrix)
 
i450_methylation_bed_dir="/omics/groups/OE0219/internal/yuyu/10.Benchmarking/GSE77965/results/report_benchmarking_04042023/tracks_and_tables_data/sites/bed"
i450_samples_files = c("rnbeads_sample9.bed", "rnbeads_sample10.bed", "rnbeads_sample11.bed", "rnbeads_sample12.bed") #5T 5N 6T 6N

data1 = read.table(file.path(i450_methylation_bed_dir, "rnbeads_sample10.bed"), sep="\t", skip=1) 
data2 = read.table(file.path(i450_methylation_bed_dir, "rnbeads_sample9.bed"), sep="\t", skip=1) 
data3 = read.table(file.path(i450_methylation_bed_dir, "rnbeads_sample12.bed"), sep="\t", skip=1) 
data4 = read.table(file.path(i450_methylation_bed_dir, "rnbeads_sample11.bed"), sep="\t", skip=1) 

colnames(data1) = c("chr", "start", "end", "name", "score", "strand") 
colnames(data2) = c("chr", "start", "end", "name", "score", "strand")
colnames(data3) = c("chr", "start", "end", "name", "score", "strand") 
colnames(data4) = c("chr", "start", "end", "name", "score", "strand") 

data1 = data1 %>% mutate(start=start+1)
data2 = data2 %>% mutate(start=start+1)
data3 = data3 %>% mutate(start=start+1)
data4 = data4 %>% mutate(start=start+1)

data1 = GenomicRanges::makeGRangesFromDataFrame(data1, keep.extra.columns = T)
data2 = GenomicRanges::makeGRangesFromDataFrame(data2, keep.extra.columns = T)
data3 = GenomicRanges::makeGRangesFromDataFrame(data3, keep.extra.columns = T)
data4 = GenomicRanges::makeGRangesFromDataFrame(data4, keep.extra.columns = T)

gr_list <- list(data1, data2, data3, data4)
intersect_gr_origin <- purrr::reduce(gr_list, GenomicRanges::intersect)
intersect_gr = GenomicRanges::makeGRangesFromDataFrame(data.frame(intersect_gr_origin) %>% filter(width==2))

data1_tb = subsetByOverlaps(data1, intersect_gr) %>% as_tibble %>% mutate(beta_chip_5N=score/1000)
data2_tb = subsetByOverlaps(data2, intersect_gr) %>% as_tibble %>% mutate(beta_chip_5T=score/1000)
data3_tb = subsetByOverlaps(data3, intersect_gr) %>% as_tibble %>% mutate(beta_chip_6N=score/1000)
data4_tb = subsetByOverlaps(data4, intersect_gr) %>% as_tibble %>% mutate(beta_chip_6T=score/1000)

data_samples = data1_tb %>% mutate(beta_chip_5T = data2_tb$beta_chip_5T, beta_chip_6N = data3_tb$beta_chip_6N, beta_chip_6T = data4_tb$beta_chip_6T)
data_samples = data_samples %>% mutate(delta_chip_5 = beta_chip_5T - beta_chip_5N, delta_chip_6 = beta_chip_6T - beta_chip_6N)
data_samples = data_samples %>% mutate(strand="*")
data_samples_hg19 = makeGRangesFromDataFrame(data_samples, keep.extra.columns = T)

path = system.file(package="liftOver", "extdata", "hg19ToHg38.over.chain")
ch = import.chain(path)
seqlevelsStyle(data_samples_hg19) = "UCSC"  # necessary
data_gr_hg38 = liftOver(data_samples_hg19, ch)
data_gr_hg38 <-subset(data_gr_hg38, lengths(data_gr_hg38)==1)
data_tb_hg38 = data.frame(unique(unlist(data_gr_hg38))) %>% dplyr::select(-c(width,strand,name,score))
regions_array = GenomicRanges::makeGRangesFromDataFrame(data_tb_hg38, keep.extra.columns = T)
#regions_array = GenomicRanges::makeGRangesFromDataFrame(data_tb_hg38) #453664

###
df_delta = data.frame(matrix(ncol=0, nrow=453628))
df_beta = data.frame(matrix(ncol=0, nrow=453628))
df_cor = data.frame()
for(w in workflows_int){
  w = "methylCtools"
  meth = methrix::load_HDF5_methrix(file.path(methrix_obj_dir, w))
  meth_filt = subset_methrix(meth, regions= regions_array)
  print(length(meth_filt))
    
  meth_filt_tb <- meth_filt %>% 
    get_matrix(add_loci=T) %>% 
    as_tibble
    
  meth_filt_tb <- meth_filt_tb %>% mutate(end=start+1)
  meth_filt_tb = meth_filt_tb %>% relocate(end, .before = strand)
  regions_seq = GenomicRanges::makeGRangesFromDataFrame(meth_filt_tb, keep.extra.columns = T)
  overlap <- subsetByOverlaps(regions_array, regions_seq) #453628
  beta_chip = data.frame(overlap) %>% arrange(seqnames, start, end) # %>% mutate(name=paste0(seqnames,":",start,"-",end))
  beta_seq = data.frame(regions_seq) %>% arrange(seqnames, start, end) # %>% mutate(name=paste0(seqnames,":",start,"-",end))
  
  idx1 = grep("5N", colnames(beta_seq))
  idx2 = grep("5T", colnames(beta_seq))
  idx3 = grep("6N", colnames(beta_seq))
  idx4 = grep("6T", colnames(beta_seq))
  
  delta_seq_5 = beta_seq[idx2] - beta_seq[idx1]
  delta_seq_6 = beta_seq[idx4] - beta_seq[idx3]

  cor_delta_5 = t(cor(beta_chip$delta_chip_5,delta_seq_5, use="complete.obs"))
  cor_delta_6 = t(cor(beta_chip$delta_chip_6,delta_seq_6, use="complete.obs")) 
  df_cor = rbind(df_cor, cor_delta_5, cor_delta_6) 
  
  df_delta = cbind(df_delta, delta_seq_5, delta_seq_6)
  df_beta = cbind(df_beta, beta_seq[6:length(beta_seq)])
  
  for(i in colnames(delta_seq_5)){
    i = "hg38.EMSEQ.5T.methylCtools"
    data = cbind(beta_chip$delta_chip_5, delta_seq_5[i])
    
    pt = strsplit(colnames(data)[2], ".", fixed = TRUE)[[1]][2]
    wf = strsplit(colnames(data)[2], ".", fixed = TRUE)[[1]][4]
    
    colnames(data) = c("delta_array_5", paste0("delta_", wf, "_5"))
    corr = cor(data,  use="complete.obs")
  
    
    g = ggplot(data, aes_string(x="delta_array_5", y=paste0("delta_", wf, "_5"))) + geom_point(size=0.2) +
        geom_abline(intercept = 0, slope = 1, colour="red") + 
        xlab(paste0("delta_array_5", " (corr=", round(corr[2],2),")")) +
        theme(
          panel.border=element_rect(fill=NA),
          panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
          strip.background.x = element_blank(),
          #axis.text.x = element_blank(),
          #axis.ticks.x = element_blank(),
          legend.position = "none"
        )

    g
    
    g = ggplot(data, aes_string(x="delta_array_5", y=paste0("delta_", wf, "_5"))) + geom_bin2d(bins = 70) +
      scale_fill_continuous(type = "viridis")

    save_("meiju", data=data)
    
    g

    array_threshold = 0.025
    deq_threshold = 0.025
    data = data[!is.na(data$delta_methylCtools_5),]
    idx = (data$delta_array_5 < array_threshold & data$delta_array_5 > -array_threshold) & (data$delta_methylCtools_5 > -deq_threshold & data$delta_methylCtools_5 < 0)
    keep = data[!idx,]
    ds = data[idx,]
    sample_id = sample(1:nrow(ds), nrow(ds)/50)
    ds_ = ds[sample_id,]

    data_ds = rbind(ds_,keep)
    g = ggplot(data_ds, aes_string(x="delta_array_5", y=paste0("delta_", wf, "_5"))) + geom_bin2d(bins = 70) +
      scale_fill_continuous(type = "viridis")

    g
    
    save_(
      paste0("corr_delta_5_chip_", i),
      plot=g,
      use_pdf=FALSE,
      width=7.5,
      height=3.8
    )
    
    save_(
      paste0("corr_delta_5_chip_", i),
      plot=g,
      use_pdf=TRUE,
      width=7.5,
      height=3.8
    )
    
  }
  
  for(i in colnames(delta_seq_6)){
    data = cbind(beta_chip$delta_chip_6, delta_seq_6[i])
    
    pt = strsplit(colnames(data)[2], ".", fixed = TRUE)[[1]][2]
    wf = strsplit(colnames(data)[2], ".", fixed = TRUE)[[1]][4]    
    
    colnames(data) = c("delta_array_6", paste0("delta_", wf, "_6"))
    corr = cor(data,  use="complete.obs")
    g = ggplot(data, aes_string(x="delta_array_6", y=colnames(data)[2])) + geom_point(size=0.2) +
      geom_abline(intercept = 0, slope = 1, colour="red") + 
      xlab(paste0("delta_array_6", " (corr=", round(corr[2],2),")")) +
      theme(
        panel.border=element_rect(fill=NA),
        panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
        strip.background.x = element_blank(),
        #axis.text.x = element_blank(),
        #axis.ticks.x = element_blank(),
        legend.position = "none"
      )
    
    save_(
      paste0("corr_delta_6_chip_", i),
      plot=g,
      use_pdf=FALSE,
      width=7.5,
      height=3.8
    )
    
    save_(
      paste0("corr_delta_6_chip_", i),
      plot=g,
      use_pdf=TRUE,
      width=7.5,
      height=3.8
    )    
  } 
  
}

save_(
  paste0("df_delta"),
  data=df_delta
)

save_(
  paste0("df_beta"),
  data=df_beta
)

save_(
  paste0("df_chip"),
  data=beta_chip
)

df_delta = read_("df_delta", "04-4_analyze_sequencing_by_DSS_debug3")
df_beta = read_("df_beta", "04-4_analyze_sequencing_by_DSS_debug3")
beta_chip = read_("df_chip", "04-4_analyze_sequencing_by_DSS_debug3")

df_cor <- df_cor %>% mutate(
  protocol=sapply(rownames(df_cor), function(s){
    str_split(s, "\\.")[[1]][2]
  })) %>% mutate(
  sample=sapply(rownames(df_cor), function(s){
    str_split(s, "\\.")[[1]][3]
  }))%>% mutate(
  workflow=sapply(rownames(df_cor), function(s){
    str_split(s, "\\.")[[1]][4]
  }))
rownames(df_cor) = NULL
colnames(df_cor) = c("cor", "protocol", "sample", "workflow")

save_(
  paste0("df_cor"),
  data=df_cor
)

df_cor = read_("df_cor", "04-4_analyze_sequencing_by_DSS_debug3")


df_cor$protocol = replace_prot_name_(df_cor$protocol)
df_cor$protocol = factor(df_cor$protocol, levels=protocols)

df_cor_mean_tb = df_cor %>% group_by(protocol, workflow) %>%
  summarize(
    mean_abs=mean(abs(cor))
  ) %>% ungroup()

weighted_AUC = read_("weighted_AUC", "04-7_plot_weighted_AUC")
df_cor_mean_tb$auc = weighted_AUC$weighted

tb_ = data.frame()
tb_sample = data.frame()
for(p in protocols){
  mean_tb_ = df_cor_mean_tb %>% dplyr::filter(protocol==p) 
  seq = seq(1, 10, 10/nrow(mean_tb_)) 
  mean_tb_ <- mean_tb_ %>% arrange(mean_abs) %>% mutate(x=seq)
  tb_ = rbind(tb_, mean_tb_)
  
  target <- mean_tb_$workflow # order
  mean_5T_tb = df_cor %>% filter(sample=="5T", protocol==p) 
  tb_5T_ = mean_5T_tb[match(target, mean_5T_tb$workflow),] %>% dplyr::mutate(x=seq, s_id="5")
  
  target <- mean_tb_$workflow # order
  mean_6T_tb = df_cor %>% filter(sample=="6T", protocol==p) 
  tb_6T_ = mean_6T_tb[match(target, mean_6T_tb$workflow),] %>% dplyr::mutate(x=seq, s_id="6")  
  
  tb_sample = rbind(tb_sample, tb_5T_, tb_6T_) 
}

npg_color <- c(
  "#E64B35","#4DBBD5",
  "#00A087","#3C5488",
  "#F39B7F","#8491B4",
  "#91D1C2","#DC0000",
  "#7E6148","#B09C85",  
  "#EE766F","#2EB7BE"
)

#tb_ = tb_ %>% filter(workflow %in% c("methylCtools", "bwameth", "gemBS"))

mean_plot <- ggplot() +
  # geom_point(
  #   data=tb_,
  #   aes(
  #     x, auc, 
  #   ),
  #   position = position_dodge(width=1),
  #   size=1.5,
  #   shape=23
  # ) + 
  # geom_point(
  #   data=tb_,
  #   aes(
  #     x, auc, 
  #     color=workflow
  #   ),
  #   position = position_dodge(width=1),
  #   size=1.2
  # ) +    
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
    data=tb_sample,
    aes(
      x, cor,
      shape=s_id,
      color=s_id
    ),
    size=1
  ) + #scale_y_continuous(sec.axis = sec_axis(~., name = "weighted AUC")) + 
  #geom_point(data=tb_, aes(x, auc, color=workflow), size = 3, position = position_dodge(width=1)) +
  #geom_point(data=tb_, aes(x, auc), size = 2.6, position = position_dodge(width=1)) +
  scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("") +
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "right"
  ) + facet_wrap( ~ protocol, ncol=5, scales="free_x") + ylab("Correlation of Array & Sequencing")

mean_plot = mean_plot + 
  geom_hline(yintercept=c(0.3, 0.4, 0.5, 0.6, 0.7), linetype="dashed", size=0.1) 

mean_plot

save_(
  paste0("corr_mean_delta"),
  plot=mean_plot,
  use_pdf=TRUE,
  width=7.5,
  height=3.5
)   

mean_plot <- ggplot() +
  geom_point(
    data=tb_,
    aes(
      x, auc, color=workflow, fill=workflow
    ),
    position = position_dodge(width=1),
    size=1.5,
    shape=23
  ) + 
  #geom_point(data=tb_, aes(x, auc, color=workflow), size = 3, position = position_dodge(width=1)) +
  #geom_point(data=tb_, aes(x, auc), size = 2.6, position = position_dodge(width=1)) +
  scale_color_manual(values=npg_color) +
  scale_fill_manual(values=npg_color) + xlab("") +
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    legend.position = "right"
  ) + facet_wrap( ~ protocol, ncol=5, scales="free_x") + ylab("Weighted AUC")

mean_plot = mean_plot + ylim(0.68,0.8) +
   geom_hline(yintercept=c(0.68, 0.72, 0.8), linetype="dashed", size=0.1) 

mean_plot

save_(
  paste0("auc"),
  plot=mean_plot,
  use_pdf=TRUE,
  width=7.5,
  height=1.5
)   
