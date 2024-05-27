# Substance P and breast cancer metastasis

This repository contains the code to reproduce all figures from the manuscript

## Neuronal substance-P drives breast cancer growth and metastasis via an extracellular RNA-TLR7 axis, Nature, 2024

Veena Padmanaban, Isabel Keller, Ethan S. Seltzer, Benjamin N. Ostendorf, Zachary Kerner, Sohail F. Tavazoie

*doi*: []()

### Overview
| Analysis                                             | Main code file                                                    |
|-----------------------------------------------------|--------------------------------------------------------------|
| GSEA of shTlr7 versus shCtrl 4T1-derived spheroids    | [RNAseq_spheroids/GSEA_shTlr7_spheroids.R](RNAseq_spheroids/GSEA_shTlr7_spheroids.R)  |
| Association between a TLR7-dependent signature and survival in TCGA breast cancer patients    | [TCGA/01_TCGA.Rmd](TCGA/01_TCGA.Rmd)  |
| Association between a TLR7-dependent signature and survival in METABRIC breast cancer patients    | [METABRIC/01_METABRIC_Tlr7_signature.Rmd](METABRIC/01_METABRIC_Tlr7_signature.Rmd) |


### GEO upload for RNA-seq of 4T1 spheroids (GSE267958)
[https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE267958](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE267958)
