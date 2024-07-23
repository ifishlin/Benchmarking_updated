## Configuration
analysis_name <- "09_1.Create_CC_5N_N15"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library(foreach)
library(doParallel)
library(methrix)
library(dplyr)

find_cc <- function(vec_sorted, N=5, min_window_size=15){

  if(length(vec_sorted) == 0){
    return(c(0,0,NA))
  }
  
  vec_names = names(vec_sorted)
  vec_sorted = unname(vec_sorted)
  
  t = table(vec_names)
  if(length(t) != 3 || min(t) < N){
    return(c(0,0,NA))
  }

  for(w in min_window_size:length(vec_sorted)){ # window size
    diff_vector = c()
    last = (length(vec_sorted)-w+1)
    for(k in 1:last){
      diff_vector = append(diff_vector, vec_sorted[k+w-1] - vec_sorted[k])
    }
    names(diff_vector) = 1:last
    diff_vector = sort(diff_vector)
    diff_vector_names = names(diff_vector)
    
    for(k in as.numeric(diff_vector_names)){
      v = vec_sorted[k:(k+w-1)]
      n = vec_names[k:(k+w-1)]  
      tb = table(n)
      if(length(tb) == 3 && !(min(tb) < N)){
        return(c(v[1], v[length(v)], w))
      }
    }
  }
  return(c(NA,NA,NA)) #?
}

for(chr in paste0("chr", 1:22)){
  df_5N <- read_(paste0("df_cov10_5N_", chr), "create_CC_input_cov")
  colnames(df_5N) = gsub(".5N.", "_", gsub("hg38.", "", colnames(df_5N)))
  
  ### Test new algorithm
  batch_n = 10000
  batch = round(nrow(df_5N) / batch_n) - 1
  
  for(b in 0:batch){
    start_idx = ifelse(b==0, 1, b*10000+1)
    end_idx = ifelse(b==batch, nrow(df_5N), (b+1)*10000)
    print(paste0(b, " ", start_idx, " ", end_idx, " ", Sys.time()))
    df_batch = df_5N[start_idx:end_idx,]

    cl <- makeCluster(16)
    registerDoParallel(cl)

    results <- foreach(i = 1:nrow(df_batch), .combine = rbind, .packages = 'dplyr') %dopar% {
      x = df_batch[i,4:length(df_batch)]
      measures = sort(unlist(x))
      onames=names(measures)
      names(measures)[grep("WGBS", names(measures))] = "a"
      names(measures)[grep("EMSEQ", names(measures))] = "b"
      names(measures)[grep("SWIFT", names(measures))] = "c"
      cc = find_cc(measures)
      
      if(! is.na(cc[3])){
        idx = data.frame(measures) %>% mutate(in_or_out=ifelse(measures>=cc[1], ifelse(measures<=cc[2], TRUE, FALSE), FALSE))
        str_vec = onames[idx$in_or_out]
        cc[3]=length(str_vec)
      
        #first encoding
        result <- sapply(workflows_int, function(w){sapply(str_vec, function(x) grepl(w, x))})
        first_encoding=paste0(colSums(result), collapse="")
  
        # #Second encoding
        result <- sapply(c("WGBS", "SWIFT", "EMSEQ"), function(p){sapply(str_vec, function(x) grepl(p, x))})
        second_encoding=paste0(colSums(result), collapse="")
        
        re <- c(cc, first_encoding, second_encoding)
      }else{
        re <- c(cc, NA, NA)
      }
    }

    stopCluster(cl)

    results_df <- as.data.frame(results)

    colnames(results_df) = c("lower", "upper", "number", "workflow_encoding", "protocol_encoding")
    rownames(results_df) = NULL
    results_df$lower = as.numeric(results_df$lower)
    results_df$upper = as.numeric(results_df$upper)
    results_df$number = as.numeric(results_df$number)

    save_(paste0("df_wg_cc_", chr,"_5N_N15_batch", b), data=results_df)
  }
  
  #merge
  df = data.frame()
  for(b in 0:batch){
    df_t = read_(paste0("df_wg_cc_", chr,"_5N_N15_batch", b), "09_1.Create_CC_5N_N15")
    df = rbind(df, df_t)
  }
  
  save_(paste0("df_merged_5N_N15_", chr), data=df) 
}





