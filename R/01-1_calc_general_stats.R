## Configuration
analysis_name <- "01-1_calc_general_stats"
config = file.path(getwd(), "0_project_setting.R")
source(config)

#install.packages("readr")

## Create statistic sheet
df = lapply(workflows, function(x){
  # Load methrix object
  meth <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, x))
  
  # Reformat the sample name
  df_ = meth@metadata$descriptive_stats$genome_stat
  df_$Sample_Name = replace_wf_name_(df_$Sample_Name)
  df_$Sample_Name = replace_prot_name_(df_$Sample_Name)
  
  # Count the number of total CpGs except chrM
  CpG_table = meth@metadata[["ref_CpG"]]
  chrM_CpG = as.numeric(CpG_table %>% filter(chr=="chrM") %>% dplyr::select("N"))
  total_CpG=sum(CpG_table[["N"]]) - chrM_CpG 
  
  # Calculate the % CpGs covered
  n_cpgs_covered = meth@metadata$descriptive_stats$n_cpgs_covered %>% 
    filter(chr!="chrM") %>% 
    dplyr::select(-chr)
  
  n_cpgs_covered[is.na(n_cpgs_covered)] <- 0
  n_cpgs_covered = colSums(n_cpgs_covered)/total_CpG  
  
  df_ = cbind(n_cpgs_covered, df_)
  
}) %>% bind_rows(.)
  
## Reformat the sheet
groups = data.frame(do.call("rbind", strsplit(df$Sample_Name, "\\.")))
sheets = protocols

list_of_dfs = list()
for (i in 1:length(sheets)){
  sheet = sheets[i]
  d = df[groups[,2]==sheet,]
  group = groups[groups[,2]==sheet,]
  g = unique(sort(group[,4]))
  header = c()
  mtx = c()
  for (j in 1:length(g)){
    t = g[j]
    idx = group[,4]==t
    s = group[idx,3]
    d2 = data.frame(d[idx,])
    d2 = d2[,c(1:5)]
    d2 = d2[order(s),] # make sure the sample ordered by ASCII
    s = s[order(s)]
    header = c(paste(colnames(d2)[4], s),
               paste(colnames(d2)[3], s),
               paste(colnames(d2)[2], s),
               paste(colnames(d2)[1], s),
               paste(colnames(d2)[5], s)) 
    mtx = rbind(mtx, c(d2[,4],d2[,3],d2[,2],d2[,1],d2[,5]))
  }
  
  header = gsub("n_cpgs_covered", "CpG Covered", header) 
  header = gsub("median_meth", "Median Methylation", header)  
  header = gsub("mean_cov", "Mean Coverage", header) 
  header = gsub("median_cov", "Median Coverage", header)  
  header = gsub("mean_meth", "Mean Methylation", header)
  colnames(mtx)=header
  mtx = data.frame(Tool=g,mtx)
  list_of_dfs[[sheet]] = data.frame(mtx)
}

# Save data
save_(
  "general_statistics",
  data=list_of_dfs
)

# Save as a xlsx
list_of_dfs %>%
  writexl::write_xlsx(path = file.path(data_dir_, "general_statistics.xlsx"))
