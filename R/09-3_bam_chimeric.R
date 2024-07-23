analysis_name <- "0_supl_bam"
config = file.path(getwd(), "0_project_setting.R")
source(config)

BASE_DIR="/home/y306n/OE0219YUYU/benchmarking/BAMs_supplementary"

flagstat_list = read.table(file.path(BASE_DIR, "flagstat.list"), header = FALSE, sep = "", dec = ".")
filtered_files = as.character(flagstat_list$V1)

for(f in filtered_files){
  print(f)
  if(file.size(file.path(BASE_DIR, f)) == 0){
    print(f)
    #next
  }else{
    #print(f)
    next
  }
}


bam.workflow <- gsub(pattern="./(.*)/(.*)/(.*)/(.*).bam.flagstat", replacement="\\1", x=filtered_files)
bam.method <- gsub(pattern="./(.*)/(.*)/(.*)/(.*).bam.flagstat", replacement="\\2", x=filtered_files)
bam.type <- gsub(pattern="./(.*)/(.*)/(.*)/(.*).bam.flagstat", replacement="\\3", x=filtered_files) 
bam.sample <- gsub(pattern="./(.*)/(.*)/(.*)/(.*).bam.flagstat", replacement="\\4", x=filtered_files) 

tb = data.frame()
idx = 1
for(f in filtered_files){
  print(f)
  if(file.size(file.path(BASE_DIR, f)) == 0){
    next
  }
  txt <- read.delim(file=file.path(BASE_DIR, f), header=F, sep="+")
  
  mapped = as.numeric(txt[5,1]) #properly paired
  ratio = txt[5,2] #properly paired  
  
  pmapped = as.numeric(txt[9,1]) #properly paired
  pratio = txt[9,2] #properly paired
  
  #line 12
  mapped12 = as.numeric(txt[12,1]) #properly paired
  ratio12 = as.numeric(strsplit(trimws(txt[12,2]), " ")[[1]][1]) #properly paired
  
  #line 13
  mapped13 = as.numeric(txt[13,1]) #properly paired
  ratio13 = as.numeric(strsplit(trimws(txt[13,2]), " ")[[1]][1]) #properly paired  
  
  tb = rbind(tb, c(bam.workflow[idx], bam.method[idx], bam.type[idx], bam.sample[idx], mapped, ratio, pmapped, pratio, mapped12, ratio12, mapped13, ratio13))
  print(paste(bam.workflow[idx], bam.method[idx], bam.type[idx], bam.sample[idx], sep = " "))
  idx = idx + 1
}

colnames(tb) <- c("workflow", "method", "type", "sample", "mapped", "ratio", "pmapped", "pratio", "chimeric_mapped", "chimeric_ratio", "chimeric_mapped_mapQlt5", "chimeric_ratio_mapQlt5")

tb$mapped = as.numeric(tb$mapped)
tb$pmapped = as.numeric(tb$pmapped)
tb$chimeric_mapped = as.numeric(tb$chimeric_mapped)


tb2 = tb %>% filter(chimeric_mapped!=0) %>% 
  #filter(method %in% c("WGBS", "PBAT")) %>% 
  filter(type=="postprocessing") %>% 
  filter(workflow %in% c("methylCtools", "bwameth", "BSBolt", "Biscuit", "GSNAP"))

tb3 = tb2 %>% mutate(ratio1=chimeric_mapped/mapped, ratio2=chimeric_mapped/pmapped) %>% 
  select(workflow, method, sample, ratio1, ratio2, mapped, pmapped, chimeric_mapped) %>% arrange(workflow, method, sample)

names_emseq=c("AS-413230-LR-47024", "AS-413232-LR-47025", "AS-413234-LR-47026", "AS-413236-LR-47027")
names_pbat =c("AS-265830-LR-38589", "AS-265832-LR-38742", "AS-265834-LR-38743", "AS-265836-LR-38744")
names_swift=c("AS-461188-LR-49602", "AS-160032-LR-22992", "AS-160055-LR-22993", "AS-461189-LR-49603")
names_wgbs =c("AS-136075-LR-18956", "AS-136076-LR-18958", "AS-136077-LR-18960", "AS-136078-LR-18962",
              "AS-136075-LR-18957", "AS-136076-LR-18959", "AS-136077-LR-18961", "AS-136078-LR-18963",
              "AS-136075_rmdup", "AS-136076_rmdup", "AS-136077_rmdup", "AS-136078_rmdup",
              "AS-136075", "AS-136076", "AS-136077", "AS-136078")
names_twgbs=c("AS-134199-LR-18768", "AS-134209-LR-18770", "AS-134281-LR-18772", "AS-134290-LR-19158",
              "AS-134199-LR-18769", "AS-134209-LR-18771", "AS-134281-LR-18773", "AS-134290-LR-19159",
              "AS-134201-LR-18768", "AS-134211-LR-18770", "AS-134283-LR-18772", "AS-134292-LR-19158",
              "AS-134201-LR-18769", "AS-134211-LR-18771", "AS-134283-LR-18773", "AS-134292-LR-19159",
              "AS-134203-LR-18768", "AS-134213-LR-18770", "AS-134285-LR-18772", "AS-134294-LR-19158",
              "AS-134203-LR-18769", "AS-134213-LR-18771", "AS-134285-LR-18773", "AS-134294-LR-19159",
              "AS-134205-LR-18768", "AS-134215-LR-18770", "AS-134287-LR-18772", "AS-134296-LR-19158",
              "AS-134205-LR-18769", "AS-134215-LR-18771", "AS-134287-LR-18773", "AS-134296-LR-19159",
              "6584", "6585", "6587", "6588",
              "AS-134199", "AS-134209", "AS-134281", "AS-134290",
              "AS-134201", "AS-134211", "AS-134283", "AS-134292",
              "AS-134203", "AS-134213", "AS-134285", "AS-134294",
              "AS-134205", "AS-134215", "AS-134287", "AS-134296")

names <- c(names_emseq, names_pbat, names_swift, names_wgbs, names_twgbs)
replace <- rep(c("5N","5T","6N","6T"), 20)
library(stringi)
tb3$sample <- stri_replace_all_regex(tb3$sample,
                                    pattern=names,
                                    replacement=replace,
                                    vectorize=FALSE)


tb3$method =  replace_prot_name_(tb3$method)
tb3$method = factor(tb3$method, levels = protocols)

save_("tb3", data=tb3)
tb3 = read_("tb3", "0_supl_bam")
##mapped
tb4 = tb3 %>% group_by(workflow, method, sample) %>% summarise(sum_mapped=sum(mapped), sum_chimeric=sum(chimeric_mapped), ratio=sum_chimeric/sum_mapped)

g = tb3 %>% group_by(workflow, method, sample) %>% summarise(sum_mapped=sum(mapped), sum_chimeric=sum(chimeric_mapped), ratio=sum_chimeric/sum_mapped) %>% 
  ggplot(aes(x=method, y=ratio, group=sample, color=sample)) +
  geom_line() + 
  geom_point() + facet_wrap( ~ workflow, ncol=5, scales="free_x") + ylab("chimeric_mapped / mapped") +
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.position = "right",axis.text.x = element_text(angle = 60, hjust=1),
  )

g

save_("chimeric_mapped_per_workflow", plot=g, use_pdf=TRUE, width=7.5, height=3)

tb5 = tb3 %>% group_by(method, sample) %>% summarise(sum_mapped=sum(mapped), sum_chimeric=sum(chimeric_mapped), ratio=sum_chimeric/sum_mapped)

g = tb4 %>% ggplot(aes(x=method, y=ratio, group=sample, color=sample)) +
  geom_line() + 
  geom_point()  + ylab("chimeric_mapped / mapped") +
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.position = "right",axis.text.x = element_text(angle = 60, hjust=1),
  )

g

save_("chimeric_pmapped", plot=g, use_pdf=TRUE, width=7.5, height=3)

##unmapped
tb4 = tb3 %>% group_by(workflow, method, sample) %>% summarise(sum_mapped=sum(pmapped), sum_chimeric=sum(chimeric_mapped), ratio=sum_chimeric/sum_mapped)

g = tb3 %>% group_by(workflow, method, sample) %>% summarise(sum_mapped=sum(pmapped), sum_chimeric=sum(chimeric_mapped), ratio=sum_chimeric/sum_mapped) %>% 
  ggplot(aes(x=method, y=ratio, group=sample, color=sample)) +
  geom_line() + 
  geom_point() + facet_wrap( ~ workflow, ncol=5, scales="free_x") + ylab("chimeric_mapped / proper-pair-mapped") +
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.position = "right",axis.text.x = element_text(angle = 60, hjust=1),
  )

g

save_("chimeric_pmapped_per_workflow", plot=g, use_pdf=TRUE, width=7.5, height=3)

tb6 = tb3 %>% group_by(method, sample) %>% summarise(sum_mapped=sum(pmapped), sum_chimeric=sum(chimeric_mapped), ratio=sum_chimeric/sum_mapped)

g = tb4 %>% ggplot(aes(x=method, y=ratio, group=sample, color=sample)) +
  geom_line() + 
  geom_point()  + ylab("chimeric_mapped / proper-pair-mapped") +
  theme(
    panel.border=element_rect(fill=NA),
    panel.background = element_rect(fill = "white", colour = "black", linetype="solid"),
    strip.background.x = element_blank(),
    legend.position = "right",axis.text.x = element_text(angle = 60, hjust=1),
  )

g

save_("chimeric_pmapped", plot=g, use_pdf=TRUE, width=7.5, height=3)

## how many times
tb5 %>% group_by(method) %>% summarize(sum_p=sum(sum_mapped), sum_c=sum(sum_chimeric), sum_r=sum_c/sum_p)
tb6 %>% group_by(method) %>% summarize(sum_p=sum(sum_mapped), sum_c=sum(sum_chimeric), sum_r=sum_c/sum_p)
##

tb = tb %>% mutate(name=sample)

tb$sample = gsub(".sorted", "", tb$sample)
tb$sample = gsub(".rmdup", "", tb$sample)

#tb = tb %>% filter(workflow %in% c("Biscuit"))
#tb = tb %>% filter(method=="SWIFT")
#tb = tb %>% filter(method=="WGBS", workflow %in% c("bwameth", "methylCtools"))

names_emseq=c("AS-413230-LR-47024", "AS-413232-LR-47025", "AS-413234-LR-47026", "AS-413236-LR-47027")
names_pbat =c("AS-265830-LR-38589", "AS-265832-LR-38742", "AS-265834-LR-38743", "AS-265836-LR-38744")
names_swift=c("AS-461188-LR-49602", "AS-160032-LR-22992", "AS-160055-LR-22993", "AS-461189-LR-49603")
names_wgbs =c("AS-136075-LR-18956", "AS-136076-LR-18958", "AS-136077-LR-18960", "AS-136078-LR-18962",
              "AS-136075-LR-18957", "AS-136076-LR-18959", "AS-136077-LR-18961", "AS-136078-LR-18963",
              "AS-136075", "AS-136076", "AS-136077", "AS-136078")
names_twgbs=c("AS-134199-LR-18768", "AS-134209-LR-18770", "AS-134281-LR-18772", "AS-134290-LR-19158",
              "AS-134199-LR-18769", "AS-134209-LR-18771", "AS-134281-LR-18773", "AS-134290-LR-19159",
              "AS-134201-LR-18768", "AS-134211-LR-18770", "AS-134283-LR-18772", "AS-134292-LR-19158",
              "AS-134201-LR-18769", "AS-134211-LR-18771", "AS-134283-LR-18773", "AS-134292-LR-19159",
              "AS-134203-LR-18768", "AS-134213-LR-18770", "AS-134285-LR-18772", "AS-134294-LR-19158",
              "AS-134203-LR-18769", "AS-134213-LR-18771", "AS-134285-LR-18773", "AS-134294-LR-19159",
              "AS-134205-LR-18768", "AS-134215-LR-18770", "AS-134287-LR-18772", "AS-134296-LR-19158",
              "AS-134205-LR-18769", "AS-134215-LR-18771", "AS-134287-LR-18773", "AS-134296-LR-19159",
              "6584", "6585", "6587", "6588")

names <- c(names_emseq, names_pbat, names_swift, names_wgbs, names_twgbs)
replace <- rep(c("5N","5T","6N","6T"), 15)

library(stringi)
tb$sample <- stri_replace_all_regex(tb$sample,
                                  pattern=names,
                                  replacement=replace,
                                  vectorize=FALSE)

tb$method = factor(tb$method, levels=c("WGBS", "EMSEQ", "SWIFT","TWGBS", "PBAT"))

#
#Manually copy
a = tb %>% filter(workflow=="FAME") %>% filter(type=="alignment") %>% arrange(method, name)
b = tb %>% filter(workflow=="bwameth") %>% filter(type=="postprocessing") %>% arrange(method, name)
#view updated data frame
tb = tb %>% arrange(workflow, method, type, sample,name)

# Save as a xlsx
tb %>%
  writexl::write_xlsx(path = file.path(data_dir_, "alignment.xlsx"))

