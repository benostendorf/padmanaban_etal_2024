signature_score <- 
  function(se, signature,  keytype = "ALIAS"){
  
  require("org.Hs.eg.db")
  require("AnnotationDbi")
  require("SummarizedExperiment")
    
  signature_ensembl <- mapIds(org.Hs.eg.db, 
                              keys = signature, 
                              column = "ENSEMBL", 
                              keytype = keytype, 
                              multiVals = "first")
  
  ## subset normalized counts for signature
  signature_idx <- rownames(se) %in% signature_ensembl
  se_signature <- se[signature_idx, ]
  
  ## sum scores, calculate percentile rank of signature, and convert into df
  signature_score <- colSums(se_signature, na.rm = TRUE)
  signature_rank <- dplyr::percent_rank(signature_score)
  signature_score_df <- data.frame(signature_score,
                                   names(signature_score), 
                                   signature_rank)
  colnames(signature_score_df) <- c(deparse(substitute(signature)), "PatientID", 
                                    paste0(deparse(substitute(signature)), "_rank"))
  
  ## return and print head of signature score
  return(signature_score_df)
  message("Signature score created and returned. Printing head of generated df. ")
  print(signature_score_df[1:3, ])
  }
