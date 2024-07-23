## Configuration
analysis_name <- "04-4_analyze_sequencing_by_DSS"
config = file.path(getwd(), "0_project_setting.R")
source(config)
library("DSS")

## Main

## Load 450k annotation 
i450_gr = read_("i450k_hg38_gr","04-3_liftover_450K_loci_hg19_to_hg38")

dml_test <- list()
dml_list <- list()
dmr_list <- list()

for(p in protocols_int){
  for (w in workflows_methrix){
    meth = methrix::load_HDF5_methrix(file.path(methrix_obj_dir, w))

    id=paste0(replace_wf_name_(w),"_", replace_prot_name_(p))

    if(sum(meth$method==p) == 0){
      next
    }
    
    d = unique(i450_gr)
    meth = methrix::subset_methrix(meth, d)
    meth_p = meth[,meth$method==p]

    ## filter NA
    meth_filtered = methrix::coverage_filter(meth_p, cov_thr = 1, min_samples = 4)    ## 4
        
    bs_p <- methrix::methrix2bsseq(meth_filtered)
    
    dml_test[[id]] = DSS::DMLtest(bs_p, group1=c(1,3), group2=c(2,4), #5N,6N vs 5T,6T
                                smoothing = TRUE)
    
    dml_list[[id]] <- DSS::callDML(dml_test[[id]], delta = 0.1, p.threshold=1e-5)
    dmr_list[[id]] <- DSS::callDMR(dml_test[[id]], delta = 0.1, p.threshold=1e-5)
  }

  save_(
    paste0("dml_i450_test","_", p),
    data=dml_test
  )
  
  save_(
    paste0("dml_i450_list","_", p),
    data=dml_list
  )
  
  save_(
    paste0("dmr_i450_list","_", p),
    data=dmr_list
  )
  
  dml_test <- list()
  dml_list <- list()
  dmr_list <- list()
}

