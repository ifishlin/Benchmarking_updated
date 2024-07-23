analysis_name <- "01.read_lose"
config = file.path(getwd(), "0_project_setting.R")
source(config)

#df <- read.table(paste0(data_dir, "/reads_loss_adv_update.txt"), sep = '\t',header = T, quote='', comment='')
df <- read.table(paste0(data_dir, "/read_lose.txt"), sep = '\t',header = T, quote='', comment='')

##
colMeans(df, na.rm = FALSE)
##

df2 = df %>% gather(key="type", value="ratio", -X) %>% dplyr::rename(workflow=X) %>% 
  mutate(protocol=gsub("(.*)_(.*)", "\\1", type)) %>% 
  mutate(stage=gsub("(.*)_(.*)", "\\2", type)) %>%
  dplyr::select(-type) 

df2 = df2 %>% mutate(stage=ifelse(stage=="final", "deduplication", stage))
df2 = df2 %>% mutate(ratio=as.numeric(ratio)) %>% filter(ratio!=0)
df2 = df2 %>% filter(!(protocol=="PBAT" & workflow=="gemBS"))

df2$label = as.character(round(df2$ratio, 3))

df2 = df2 %>% add_row(protocol="PBAT", workflow="BAT", ratio=NA, stage=c("trimming", "alignment", "deduplication"), label="NA")
df2 = df2 %>% add_row(protocol="PBAT", workflow="gemBS", ratio=NA, stage=c("trimming", "alignment", "deduplication"), label="NA")
df2 = df2 %>% add_row(protocol=c("WGBS", "EMSEQ", "SWIFT", "TWGBS"), workflow="BAT",ratio=NA, stage=c("deduplication"), label="NA")

df2 = df2 %>% add_row(protocol=c("WGBS", "EMSEQ", "SWIFT", "TWGBS", "PBAT"), workflow="FAME",ratio=NA, stage=c("deduplication"), label="UNK")
df2 = df2 %>% add_row(protocol=c("WGBS", "EMSEQ", "SWIFT", "TWGBS", "PBAT"), workflow="FAME",ratio=NA, stage=c("alignment"), label="UNK")
df2 = df2 %>% add_row(protocol=c("WGBS", "EMSEQ", "SWIFT", "TWGBS"), workflow="gemBS",ratio=NA, stage=c("alignment"), label="UNK")
df2 = df2 %>% add_row(protocol=c("WGBS", "EMSEQ", "SWIFT", "TWGBS", "PBAT"), workflow="methylpy",ratio=NA, stage=c("alignment"), label="UNK")

df2$stage = factor(df2$stage, levels=c("trimming", "alignment", "deduplication"))

df2$protocol = replace_prot_name_(df2$protocol)
df2$protocol = factor(df2$protocol, levels=protocols)
df2$workflow = replace_wf_name_(df2$workflow)
df2$workflow = factor(df2$workflow, levels=rev(workflows))

#df2$label = as.character(round(df2$ratio, 3))

# df2 %>% 
#   ggplot(aes(x=stage, y=ratio, group=workflow, colour=workflow)) +
#   geom_line() + geom_point() + unified_pg + coord_cartesian(ylim=c(0,1)) + 
#   facet_wrap( ~ protocol, ncol=5, scales="free_x") +
#   geom_hline(yintercept=c(0,0.25,0.5,0.75,1), linetype="dashed", size=0.1) +
#   theme(axis.text.x = element_text(angle = 65, hjust = 1, size = 8)) +
#   color_palette_fill() + color_palette_color()

plot = df2 %>% 
  ggplot(aes(x=stage, y=workflow, fill=ratio)) + geom_tile(color = "white", lwd = 0.5, linetype = 1) +
  facet_wrap( ~ protocol, ncol=5, scales="free_x") + 
  theme(axis.text.x = element_text(angle = 65, hjust = 1, size = 9), legend.position='bottom') +
  unified_pg + #geom_text(aes(label = round(ratio, 3)), color = "black", size = 2) + 
  geom_text(aes(label = label), color = "black", size = 2.7) + 
  guides(fill = guide_colourbar(title = "Reads Keeping ratio")) + 
  scale_fill_gradient(low = "white", high = "green") 

plot

save_(
  "read_reduce_update",
  use_pdf=TRUE,
  plot=plot,
  width=8,
  height=7
)
 