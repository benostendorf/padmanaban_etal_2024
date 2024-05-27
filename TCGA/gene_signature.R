signature_score <- 
  function(se, signature, scaling = TRUE, keytype = "ALIAS"){
  
  require("org.Hs.eg.db")
  require("AnnotationDbi")
  require("SummarizedExperiment")
    
  signature_ensembl <- mapIds(org.Hs.eg.db, 
                              keys = signature, 
                              column = "ENSEMBL", 
                              keytype = keytype, 
                              multiVals="first")
  signature_ensembl_uniq <- unique(signature_ensembl)
  signature_ensembl_filt <- signature_ensembl_uniq[!is.na(signature_ensembl_uniq)]
  signature_ensembl_filt_names <- names(signature_ensembl_filt)
  signature_missing <- names(signature_ensembl_uniq[is.na(signature_ensembl)])
  
  # ## Filter for only genes present in SE
  # signature_ensembl_filt2 <- 
  #   signature_ensembl_filt[signature_ensembl_filt %in% rownames(se)]
  
  if (length(signature_missing) > 0) {
    warning("The following gene symbols from the signature could not be translated to Ensembl IDs: ", 
            paste0(signature_missing, collapse = ", "))
  }
  
  ## subset normalized counts for signature
  signature_idx <- rownames(se) %in% signature_ensembl_filt
  se_signature <- counts(se, normalized = TRUE)[signature_idx, ]
  
  ## transpose and z-transform option
  if (scaling) {
    se_signature_scaled <- apply(se_signature, MARGIN = 1, FUN = scale)
    se_signature_t <- t(se_signature_scaled)
  } else {
    se_signature_t <- t(se_signature)
  }
  
  rownames(se_signature_t) <- signature_ensembl_filt_names
  colnames(se_signature_t) <- colnames(se_signature)
  
  ## sum scores, calculate percentile rank of signature, and convert into df
  signature_score <- colSums(se_signature_t, na.rm = TRUE)
  signature_rank <- dplyr::percent_rank(signature_score)
  signature_score_df <- data.frame(signature_score,
                                   substring(names(signature_score), 1, 12), 
                                   signature_rank)
  colnames(signature_score_df) <- c(deparse(substitute(signature)), "UID", paste0(deparse(substitute(signature)), "_rank"))
  
  ## return and print head of signature score
  return(signature_score_df)
  message("Signature score created and returned. Printing head of generated df. ")
  print(signature_score_df[1:3, ])
}