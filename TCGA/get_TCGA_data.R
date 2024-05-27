if (!file.exists("data/BRCA_se.rds")) {
  
  clinical_out <- "data/clinical_all_projects.csv"
  project <- c("BRCA")
  project_name <- "TCGA-BRCA"
  
  ## ---------------------------------------------------
  ## Download clinical data
  ## ---------------------------------------------------
  if (!file.exists("data/TCGA-CDR-SupplementalTableS1.xlsx")) {
    download.file(url = "https://api.gdc.cancer.gov/data/1b5f413e-a8d1-4d10-92eb-7c4ae739ed81", 
                  destfile = "data/TCGA-CDR-SupplementalTableS1.xlsx")
  }
  clinical <- 
    readxl::read_excel("data/TCGA-CDR-SupplementalTableS1.xlsx", sheet = 1) |>
    filter(type == "BRCA") |>
    rename(patient = bcr_patient_barcode)
  
  ## ---------------------------------------------------
  ## Download expression data
  ## ---------------------------------------------------
  if (file.exists("data/BRCA_GE.rda")) {
    load("data/BRCA_GE.rda")
  } else {
    
    query <- GDCquery(project = project_name,
                      data.category = "Transcriptome Profiling",
                      data.type = "Gene Expression Quantification",
                      workflow.type="STAR - Counts", 
                      sample.type = "Primary Tumor")
    
    ## Download queried items
    GDCdownload(query, directory = "data")
    
    data <- GDCprepare(query,
                       save = TRUE,
                       directory = "data",
                       save.filename = "BRCA_GE.rda",
                       remove.files.prepared = TRUE)
  }
  
  ## ---------------------------------------------------
  ## Append harmonized clinical data to SE object
  ## ---------------------------------------------------
  coldata_dds <- 
    colData(data) |>
    as_tibble(rownames = "rownames_coldata") |>
    select(patient, starts_with("paper"), rownames_coldata)
  clinical_joint <- 
    coldata_dds |>
    left_join(clinical)
  new_coldata <- as.data.frame(clinical_joint)
  rownames(new_coldata) <- new_coldata$rownames_coldata
  
  BRCA_se <- SummarizedExperiment(assay(data), colData = new_coldata)
  rownames(BRCA_se) <- gsub("(ENSG\\d*)\\.\\d*", "\\1", rownames(BRCA_se))
  saveRDS(BRCA_se, "data/BRCA_se.rds")
}
BRCA_se <- readRDS("data/BRCA_se.rds")
