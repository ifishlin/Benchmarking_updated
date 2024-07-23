analysis_name <- "9_conversion_rate"
source("/omics/groups/OE0219/internal/yuyu/DNA_meth_protocol_benchmarking/analysis/general_use.R")

## read in data:
#############################################
mbias_tb <- readRDS(file.path(data_dir, "8_plot_mbias", "mbias.rds")) %>% set_order()


## aggregate over positions:
###########################################
conversion_rate_tb <- mbias_tb %>%
    filter( context != "CpG" ) %>%
    filter( mbias_corr ) %>% 
    filter( read == 1) %>%
    filter( pos_in_read > 30) %>%
    filter( pos_in_read < 70) %>%
    group_by(protocol, sample) %>%
    dplyr::summarize(non_cpg_meth=sum(count_meth)/sum(cov)) %>%
    mutate(conversion_rate=1-non_cpg_meth) %>%
    ungroup() %>%
    set_order()


non_cpg_meth_plot <- conversion_rate_tb %>%
    ggplot() +
        geom_point(
            aes(
                protocol, non_cpg_meth, 
                color=protocol, 
                shape=sample
            ),
            position = position_dodge(width=0.7),
            size=3.5
        ) +
        ylim(0,NA) +
        ylab("mean non-CpG methylation") +
        scale_color_manual(values=protocol_color_sheme) +
        scale_shape_manual(values=sample_shape_sheme) +
        guides(color=FALSE) +
        theme(
            axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "right"
        )

save_(
    "non_cpg_meth",
    plot=non_cpg_meth_plot,
    data=conversion_rate_tb,
    width=6,
    height=5
)

conversion_rate_plot <- conversion_rate_tb %>%
    ggplot() +
        geom_point(
            aes(
                protocol, conversion_rate, 
                color=protocol, 
                shape=sample
            ),
            position = position_dodge(width=0.7),
            size=3.5
        ) +
        ylim(0,1) +
        ylab("conversion rate") +
        scale_color_manual(values=protocol_color_sheme) +
        scale_shape_manual(values=sample_shape_sheme) +
        guides(color=FALSE) +
        theme(
            axis.text.x = element_text(angle = 45, hjust = 1),
            legend.position = "right"
        )

save_(
    "conversion_rate",
    plot=conversion_rate_plot,
    data=conversion_rate_tb,
    width=6,
    height=5
)

save_(
    "conversion_rate_zoom",
    plot=conversion_rate_plot + ylim(NA,1),
    data=conversion_rate_tb,
    width=6,
    height=5
)


## per position:
conversion_rate_per_pos_tb <- mbias_tb %>%
    filter( context != "CpG" ) %>%
    filter( mbias_corr ) %>% 
    group_by(protocol, sample, pos_in_read, read) %>%
    dplyr::summarize(non_cpg_meth=sum(count_meth)/sum(cov)) %>%
    mutate(conversion_rate=1-non_cpg_meth) %>%
    ungroup() %>%
    set_order()

conversion_rate_per_pos_plot <- conversion_rate_per_pos_tb %>%
    ggplot() +
        geom_line(aes(pos_in_read, conversion_rate, color=protocol)) +
        facet_grid(read ~ sample) +
        scale_color_manual(values=protocol_color_sheme) +
        ylim(0,1) +
        ylab("conversion rate")

save_(
    "conversion_rate_per_pos",
    plot=conversion_rate_per_pos_plot,
    data=conversion_rate_per_pos_tb,
    width=20,
    height=10
)

save_(
    "conversion_rate_per_pos_zoom",
    plot=conversion_rate_per_pos_plot + ylim(NA,1),
    data=conversion_rate_per_pos_tb,
    width=20,
    height=10
)
