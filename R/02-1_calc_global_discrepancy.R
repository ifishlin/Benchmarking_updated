analysis_name <- "02-1_calc_global_discrepancy"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(methrix)

txt_dir <- file.path(data_dir_, "discrepancy_txt")
if (!file.exists(txt_dir)){
  dir.create(txt_dir)
}

## Load methrix
##########################
meth_list <- lapply(workflows_methrix, function(x){
  meth <- methrix::load_HDF5_methrix(file.path(methrix_obj_dir, x))
})

# Build empty matrix
pairs = unlist(lapply(meth_list, function(x){
  combs = unique(paste(x@colData$method, x@colData$pipeline, sep="&"))
}))

pairs = sort(pairs)
df = data.frame(matrix(0, length(pairs), length(pairs)))
rownames(df) = colnames(df) = pairs

df_5N = data.frame(matrix(0, length(pairs), length(pairs)))
df_5T = data.frame(matrix(0, length(pairs), length(pairs)))
df_6N = data.frame(matrix(0, length(pairs), length(pairs)))
df_6T = data.frame(matrix(0, length(pairs), length(pairs)))
rownames(df_5N) = colnames(df_5N) = pairs
rownames(df_5T) = colnames(df_5T) = pairs
rownames(df_6N) = colnames(df_6N) = pairs
rownames(df_6T) = colnames(df_6T) = pairs

## Calculate discrepancy for each combination
df_samples = data.frame()
for(i in pairs[1:length(pairs)]){
  for(j in pairs[1:length(pairs)]){    
    print(paste0(i," == ",j))
    pair1 <- strsplit(i, split="&")
    p1 = pair1[[1]][1]
    w1 = pair1[[1]][2]
    idx_1 = match(w1, workflows_methrix)
    df_idx_1 = match(i, pairs)
    
    pair2 <- strsplit(j, split="&")
    p2 = pair2[[1]][1]
    w2 = pair2[[1]][2]
    idx_2 = match(w2, workflows_methrix)
    df_idx_2 = match(j, pairs)
    
    if(df_idx_1 >= df_idx_2) next
    
    obj_1 = meth_list[[idx_1]]
    pair1_mat = methrix::get_matrix(m = obj_1[,which(obj_1@colData$method==p1)])
    obj_2 = meth_list[[idx_2]]   
    pair2_mat = methrix::get_matrix(m = obj_2[,which(obj_2@colData$method==p2)])
    difference <- pair1_mat-pair2_mat
    
    ## Save the difference as TXT file.
    new_colnames = paste0(i,"-",j, "_", c("5N", "5T", "6N", "6T"))
    colnames(difference) = new_colnames
    # outfile_name = paste0(data_dir_,"/discrepancy_txt/","discrepancy_score_abs_mean_", i, "-", j, ".txt")
    # if(!file.exists(outfile_name)){
    #   fwrite(as.data.table(difference), file = outfile_name, sep = "\t", row.names = FALSE)    
    # }
    
    if (class(difference)=="DelayedMatrix"){
      sum_diff <- DelayedMatrixStats::colMeans2(abs(difference), na.rm = T)
    }else{
      sum_diff <- matrixStats::colMeans2(abs(difference), na.rm = T)
    }    
    
    df_5N[df_idx_1, df_idx_2] = df_5N[df_idx_2, df_idx_1] = sum_diff[1]
    df_5T[df_idx_1, df_idx_2] = df_5T[df_idx_2, df_idx_1] = sum_diff[2]
    df_6N[df_idx_1, df_idx_2] = df_6N[df_idx_2, df_idx_1] = sum_diff[3]
    df_6T[df_idx_1, df_idx_2] = df_6T[df_idx_2, df_idx_1] = sum_diff[4]
    df[df_idx_1, df_idx_2] = df[df_idx_2, df_idx_1] = sum(sum_diff)/4
    
    print(paste0("++", i,"==",j," - ", sum(sum_diff)/4, "/", df_idx_1, "/", df_idx_2))
    
    df_samples = rbind(df_samples, c(i,j,sum_diff))
  }
}

colnames(df) = rownames(df) = replace_prot_name_(replace_wf_name_(colnames(df)))
colnames(df_5N) = rownames(df_5N) = replace_prot_name_(replace_wf_name_(colnames(df_5N)))
colnames(df_5T) = rownames(df_5T) = replace_prot_name_(replace_wf_name_(colnames(df_5T)))
colnames(df_6N) = rownames(df_6N) = replace_prot_name_(replace_wf_name_(colnames(df_6N)))
colnames(df_6T) = rownames(df_6T) = replace_prot_name_(replace_wf_name_(colnames(df_6T)))

colnames(df_samples) = c("c1", "c2", "D5N", "D5T", "D6N","D6T")
df_samples$D5N = as.numeric(df_samples$D5N)
df_samples$D5T = as.numeric(df_samples$D5T)
df_samples$D6N = as.numeric(df_samples$D6N)
df_samples$D6T = as.numeric(df_samples$D6T)

save_("discrepancy_tb", data=df)
save_("discrepancy_sample_tb", data=df_samples)
save_("discrepancy_5N_tb", data=df_5N)
save_("discrepancy_5T_tb", data=df_5T)
save_("discrepancy_6N_tb", data=df_6N)
save_("discrepancy_6T_tb", data=df_6T)

