analysis_name <- "k08_plot_mbias"
source("/omics/groups/OE0219/internal/yuyu/10.Benchmarking/analysis/data_processing_redo/00.project_setting.R")

mbias_corr_dir="/home/y306n/OE0219YUYU/benchmarking/analysis/bismark_pilot/mbias_corr"
mbias_dir="/home/y306n/OE0219YUYU/benchmarking/analysis/bismark_pilot/mbias"

protocols = c("WGBS", "SWIFT", "TWGBS", "PBAT", "EMseq")
  
## read in data from bismark's mbias txt:
#############################################
read_bismark_mbias_txt <- function(mbias_txt){
    mbias_tb_ <- tibble(
        context=factor(levels=c("CpG", "CHG", "CHH")),
        read=factor(levels=c(1, 2)),
        pos_in_read=numeric(),
        count_meth=numeric(),
        count_unmeth=numeric(),
        meth=numeric(),
        cov=numeric()
    )

    lines <- readLines(mbias_txt) %>%
        strsplit("\t")

    for (line in lines){
        if (length(line) != 0){
            if (length(line) == 1){
                if (grepl("context", line[1])){
                    context_ <- substring(line[1], 1, 3)
                    read_ <- substring(line[1], 15, 15)
                    if(read_ == ""){
                        read_ <- 1
                    }
                }
            } else if(line[1] != "position"){
                mbias_tb_ <- mbias_tb_ %>%
                    add_row(
                        context=context_,
                        read=read_,
                        pos_in_read=as.numeric(line[1]),
                        count_meth=as.numeric(line[2]),
                        count_unmeth=as.numeric(line[3]),
                        meth=as.numeric(line[4]),
                        cov=as.numeric(line[5])
                    )
            }
        }
    }
    
    return(mbias_tb_)
}


mbias_tb <- tibble(
    protocol=factor(levels=protocols),
    sample=factor(level=samples),
    context=factor(levels=c("CpG", "CHG", "CHH")),
    read=factor(levels=c(1, 2)),
    pos_in_read=numeric(),
    count_meth=numeric(),
    count_unmeth=numeric(),
    meth=numeric(),
    cov=numeric(),
    mbias_corr=logical()
)
for (mb_corr in c(TRUE, FALSE)){
    mbias_dir_ <- ifelse(mb_corr, mbias_corr_dir, mbias_dir)
    for (p in protocols){
        for (s in samples){
            #if (!(p=="EMseq" && s=="6T")){
                print(paste0(s,"_",p))
                mbias_txt_ <- file.path(
                    mbias_dir_,
                    paste0(s,"_",p,".M-bias.txt")
                )
                
                if(file.exists(mbias_txt_)){
                    mbias_tb <- mbias_tb %>%
                        bind_rows(
                            read_bismark_mbias_txt(mbias_txt_) %>%
                                mutate(
                                    sample=s,
                                    protocol=p,
                                    mbias_corr=mb_corr
                                )
                        )
                } else {
                    print(paste0(mbias_txt_, " does not exist."))
                }

            #}
        }
    }
}


mbias_tb <- mbias_tb %>%
    mutate(
        meth=count_meth/cov
    ) %>%
    set_order()

save_(
    "mbias",
    data=mbias_tb
)

## plot mbias:
####################################################
for (mb_corr in c(TRUE, FALSE)){
    for (context_ in c("CpG", "CHG", "CHH")){
        print(context_)
        #mb_corr = TRUE
        #context_ = "CpG"
        plot_mbias <- mbias_tb %>%
            filter(context==context_) %>%
            filter(mbias_corr==mb_corr) %>%
            ggplot() +
                geom_line(aes(pos_in_read, meth, color=protocol)) +
                facet_grid(read ~ sample) +
                scale_color_manual(values=protocol_color_sheme) +
                ylim(0,NA)

        plot_mbias
        
        save_(
            paste0("mbias_", context_, ifelse(mb_corr, "_corr", "")),
            plot=plot_mbias,
            data=mbias_tb,
            width=20,
            height=10
        )
    }
}

for (mb_corr in c(TRUE, FALSE)){
    plot_mbias_cpg_mcorr_adapted <- mbias_tb %>%
        filter(context=="CpG") %>%
        filter(mbias_corr==mb_corr) %>%
        mutate(read=ifelse(read==1, "read1", "read2")) %>%
        ggplot() +
            geom_line(aes(pos_in_read, meth, color=protocol)) +
            facet_grid(read ~ sample) +
            scale_color_manual(values=protocol_color_sheme) +
            theme(
                panel.background = element_blank(), 
                strip.background =element_blank(), 
                panel.border=element_rect(fill=NA),
                legend.position="none"
            ) +
            ylab("methylation") +
            xlab("position in read")

    label <- "mbias_cpg_adapted"
    if(mb_corr){
        label <- paste0(label, "_mcorr")
        plot_mbias_cpg_mcorr_adapted <- plot_mbias_cpg_mcorr_adapted +
        ylim(0.4, 0.8)
    }
    save_(
        label,
        plot=plot_mbias_cpg_mcorr_adapted,
        data=mbias_tb,
        width=7.7,
        height=3
    )
}

## qunatify into single score:
############################################
# total_methylation_level_tb <- mbias_tb %>%
#     filter(context=="CpG") %>%
#     group_by(protocol, sample) %>%
#     summarize(
#         count_meth=sum(count_meth),
#         count_unmeth=sum(count_unmeth),
#     ) %>%
#     mutate(
#         total_meth=count_meth/(count_meth+count_unmeth)
#     )
# 
# mbias_score_tb_ <- mbias_tb %>%
#     filter(context=="CpG") %>%
#     select(protocol, sample, read, pos_in_read, meth, mbias_corr) %>%
#     left_join(
#         total_methylation_level_tb,
#             by=c("sample", "protocol")
#     ) %>%
#     mutate(
#         abs_diff_to_global_mean=abs(meth-total_meth)
#     ) 
# 
# mbias_score_tb <- mbias_score_tb_ %>%
#     group_by(sample, protocol, mbias_corr) %>%
#     summarize(mbias_score=mean(abs_diff_to_global_mean)) %>%
#     ungroup()
# 
# mbias_score_read_wise_tb <- mbias_score_tb_ %>%
#     group_by(sample, protocol, mbias_corr, read) %>%
#     summarize(mbias_score=mean(abs_diff_to_global_mean)) %>%
#     ungroup()
# 
# mbias_score_tb <- bind_rows(
#     mbias_score_tb %>% mutate(read_wise=FALSE),
#     mbias_score_read_wise_tb %>% mutate(read_wise=TRUE),
# ) %>%
#     set_order()
# 
# 
# for (mb_corr in c(TRUE, FALSE)){
#     for (r_wise in c(TRUE, FALSE)){
#         mbias_score_plot <- mbias_score_tb %>%
#             filter(mbias_corr==mb_corr) %>%
#             filter(read_wise==r_wise) %>%
#             ggplot() +
#                 geom_point(
#                     aes(
#                         protocol, mbias_score, 
#                         color=protocol, 
#                         shape=sample
#                     ),
#                     position = position_dodge(width=0.7),
#                     size=3.5
#                 ) +
#                 ylim(0, NA) +
#                 ylab("mbias score") +
#                 scale_color_manual(values=protocol_color_sheme) +
#                 scale_shape_manual(values=sample_shape_sheme) +
#                 guides(color=FALSE) +
#                 theme(
#                     axis.text.x = element_text(angle = 45, hjust = 1),
#                     legend.position = "right"
#                 )
#         if(r_wise){
#             mbias_score_plot <- mbias_score_plot +
#                 facet_grid(. ~ read)
#         }
# 
#         label <- "mbias_score"
#         if(mb_corr){
#             label <- paste0(label, "_mcorr")
#         }
#         if(r_wise){
#             label <- paste0(label, "_rwise")
#         }
#         save_(
#             label,
#             plot=mbias_score_plot,
#             data=mbias_score_tb,
#             width=ifelse(r_wise, 10, 6),
#             height=5
#         )
#     }
# }

