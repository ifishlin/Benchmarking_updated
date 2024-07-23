#BiocManager::install(c("viridis","ggplot2","tidyverse"))
analysis_name <- "04-4_plot_density"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(viridis)
library(ggplot2)
library(tidyverse)
setwd("/omics/groups/OE0219/internal/MJMC/yuyu")
df <- readRDS("/omics/groups/OE0219/internal/yuyu_share/meiju.rds")
df = data.frame(df)
my_breaks <- c(2, 10, 50, 250, 1250, 6000)
my_breaks_log2 <- round(log2(my_breaks),2)
g = ggplot(df, aes(x=delta_array_5, y=delta_methylCtools_5) ) +
  geom_hex(bins = 200) +
  scale_fill_viridis_c(breaks = my_breaks, labels = my_breaks_log2, 
                       trans = "log2")+
  labs(fill="log2(counts)")+
  theme_classic()+
  theme(legend.position = "right")
g
save_(
  paste0("test"),
  plot=g,
  use_pdf=TRUE,
  width=4,
  height=2.5
) 
ggsave("density_log2.pdf", width = 7, height = 4)