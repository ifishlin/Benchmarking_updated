analysis_name <- "k36.extract_gc_content_distribution"
source("/omics/groups/OE0219/internal/yuyu/10.Benchmarking/analysis/data_processing_redo/00.project_setting.R")
library(GenomicRanges)
library(rtracklayer)
library(Biostrings)

## read in bed and extract gc content:
########################################
bs_genome <- BSgenome.Hsapiens.UCSC.hg38::BSgenome.Hsapiens.UCSC.hg38

# gc_content_tb <- lapply(protocols, function(p){
#     lapply(samples, function(s){
#         # if (p=="EMseq" & s=="6T"){
#         #     return(tibble())
#         # }
#         # 
#         bed_path <- file.path(
#             data_dir_,
#             paste0(s, "_", p, ".bam.bed")
#         )
#         alignments_gr <- import.bed(bed_path)
#         genome_seq_levels <- seqlevels(bs_genome)
#         seqnames_included <- sapply(seqnames(alignments_gr), function(s) s %in% genome_seq_levels)
#         alignments_gr <- alignments_gr[seqnames_included]
#         seqlevels(alignments_gr) <- genome_seq_levels
#         seqinfo(alignments_gr) <- seqinfo(bs_genome)
#         alignments_gr <- GenomicRanges::trim(alignments_gr)
#         seqs <- alignments_gr %>% BSgenome::getSeq(bs_genome, .)
#         letterFrequency(seqs, c("C","G"), as.prob=TRUE) %>%
#             rowSums() %>%
#             tibble(
#                 gc_content=.
#             ) %>%
#             mutate(
#                 protocol=p,
#                 sample=s
#             ) %>%
#             return()
#     }) %>%
#         do.call(bind_rows, .)
# }) %>%
#     do.call(bind_rows, .) %>%
#     select(sample, protocol, gc_content) %>%
#     set_order()

gc_content_tb = read_("gc_content_tb", "k36.extract_gc_content_distribution")

## plot gc content:
###########################################
gc_content_plot <- gc_content_tb %>%
    ggplot() +
        geom_density(
            aes(gc_content, color=protocol),
            alpha=0.75,
            size=1.5
        ) +
        ylab("density") +
        xlab("GC content") +
        scale_color_manual(values=protocol_color_sheme) +
        facet_wrap(~ sample, ncol = 4) +
        #facet_grid(. ~ sample) +
        theme(
            panel.background = element_blank(),          
            strip.background = element_blank(),
            panel.border=element_rect(fill=NA),
            legend.position="none"
        ) + scale_x_continuous(breaks=c(0,0.25,0.5,0.75,1), labels=c("0","0.25","0.5","0.75","1")) 

gc_content_plot

save_(
    "gc_content",
    plot=gc_content_plot,
    data=gc_content_tb,
    width=7.3,
    height=2.2
)

gc_content_condensed_plot <- gc_content_tb %>%
    ggplot() +
        geom_density(
            aes(gc_content, color=protocol),
            alpha=0.75,
            size=1.5
        ) +
        ylab("density") +
        xlab("GC content") +
        scale_color_manual(values=protocol_color_sheme) +
        theme(
            panel.background = element_blank(),          
            strip.background = element_blank(),          
            panel.border=element_rect(fill=NA),
            legend.position="none"
        )

gc_content_condensed_plot

save_(
    "gc_content_condensed",
    plot=gc_content_condensed_plot,
    data=gc_content_tb,
    width=4,
    height=3.1
)
