analysis_name <- "02-6_calc_wg_deviation_by_annot"
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

annotated_df = data.frame()
for(workflow in workflows){
  meth_base <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, workflow))
  for(sample in c("5N", "5T", "6N", "6T")){
    ## load all Concensus Corridor
    wg_cc = lapply(paste0("chr", 1:22), function(x){
      wg_cc <- read_(
        paste0("df_merged_",sample ,"_N15_", x),
        paste0("create_CC_parallel_",sample ,"_N15")
      )  
    }) %>% bind_rows(.)   
    
    ## Create GR 
    wg_cc_gr =wg_cc %>% mutate(start=as.numeric(start), 
                               lower=as.numeric(lower), 
                               upper=as.numeric(upper), 
                               number=as.numeric(number)) %>% 
      mutate(end=start+1) %>% filter(number!=0) %>% dplyr::select(-strand) %>% 
      makeGRangesFromDataFrame(keep.extra.columns = T, ignore.strand=TRUE)   
    
    ## Load methylation profile
    for(annot_name in annots_hg38){
      annotations = build_annotations(genome = 'hg38', annotations = annot_name)
    
      annot = data.frame(annotations) %>% 
        filter(seqnames %in% legal_chrs) %>% 
        makeGRangesFromDataFrame(keep.extra.columns = T)
    
      hits_cc = findOverlaps(wg_cc_gr, annot)
      hits = wg_cc_gr[sort(unique(hits_cc@from)),]
     
      meth = meth_base[,meth_base$sample==sample]
      meth_filt = subset_methrix(meth, regions=hits)
      meth_filt_tb <- meth_filt %>%
        get_matrix(add_loci=TRUE) %>%
        as_tibble      
     
      colnames(meth_filt_tb)[grep("EMSEQ", colnames(meth_filt_tb))] = "EMSEQ_beta"
      colnames(meth_filt_tb)[grep("SWIFT", colnames(meth_filt_tb))] = "SWIFT_beta"
      colnames(meth_filt_tb)[grep("\\.WGBS", colnames(meth_filt_tb))] = "WGBS_beta"
      colnames(meth_filt_tb)[grep("TWGBS", colnames(meth_filt_tb))] = "TWGBS_beta"
      colnames(meth_filt_tb)[grep("PBAT", colnames(meth_filt_tb))] = "PBAT_beta" 
      
      df = data.frame(hits)
      df$seqnames = as.character(df$seqnames)
      df <- df[order(df$seqnames), ]

      if(sum(meth_filt_tb[2] != df[2]) != 0){
        stop("The order of calling and corridor are not matched")
      }
      
      #combined = cbind(meth_filt_tb[1000:1010,], df[1000:1010,c(6,7)])
      combined = cbind(meth_filt_tb, df[,c(6,7)])
  
      # calculate deviation
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
    
      ## END OF CALCULATE
      idx= grep("dev", colnames(combined))
      combined = combined[idx]   
      #colnames(combined) = paste0(sample, "_", workflow, "_", colnames(combined))
      a = data.frame(colMeans(abs(combined), na.rm = TRUE))
      colnames(a) = c("mean")
      a = a %>% mutate(protocol=gsub("(WGBS|TWGBS|PBAT|SWIFT|EMSEQ)_dev", "\\1", rownames(a))) %>%
        mutate(workflow=workflow, sample=sample, annotation=annot_name)
      rownames(a) = NULL
      annotated_df = rbind(annotated_df, a)
    }
  }
}

save_("annotated_wg_dev_df", data=annotated_df)
#annotated_df = annotated_wg_dev_df

df = annotated_df %>% group_by(workflow, protocol, annotation) %>% summarise(mean=mean(mean)) %>% ungroup()

df$workflow = factor(df$workflow, levels=rev(workflows))
df$protocol = replace_prot_name_(df$protocol)
df$protocol = factor(df$protocol, levels=protocols)

tmp = data.frame(workflow=c("BAT"), protocol="PBAT", mean=NA, annotation=unique(df$annotation))
df = rbind(df, tmp)
tmp = data.frame(workflow=c("gemBS"), protocol="PBAT", mean=NA, annotation=unique(df$annotation))
df = rbind(df, tmp)

df$annotation = factor(df$annotation,levels=annots_hg38)

g = df %>% ggplot(aes(annotation, workflow, fill=mean)) + 
  geom_tile(colour="white",size=0.25) +
  theme(
    panel.border=element_blank(),
    panel.background = element_blank(),
    legend.text=element_text(face="bold"),
    axis.ticks=element_line(size=0.4),
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
