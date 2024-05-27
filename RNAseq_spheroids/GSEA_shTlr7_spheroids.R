## -----------------------------------------------------
## Title: "Knockdown of Tlr7 in 4T1 spheroids"
## Author: "Benjamin N. Ostendorf"
## -----------------------------------------------------

## Preamble
## -----------------------------------------------------
require(ashr)
library(DESeq2)
library(clusterProfiler)
library(AnnotationDbi)
library(org.Mm.eg.db)
library(tidyverse)

## Import data
## -----------------------------------------------------
## Count table and coldata
count_table <- read.table("counts.tsv", 
                          header = TRUE, 
                          check.names = FALSE)
coldata <- data.frame(sample = c(paste0("4T1_shCtrl_0", 1:4), 
                                 paste0("4T1_shTlr7_0", 1:4)), 
                      condition = c(rep("shCtrl", 4), 
                                    rep("shTlr7", 4)))

## Set up dds and perform DESeq2
dds <- DESeqDataSetFromMatrix(count_table, 
                              colData = coldata, 
                              design = ~condition)
dds <- dds[rowSums(counts(dds)) > 1, ]
dds <- DESeq(dds)
res <- 
  results(dds, contrast = c("condition", "shTlr7", "shCtrl"))
resLFC <- 
  lfcShrink(dds, res = res, type = "ashr") |>
  as_tibble(rownames = "symbol")


## GSEA
## -----------------------------------------------------
## Prepare ranked gene list for GSEA
res_ranked <- 
  resLFC |>
  arrange(-log2FoldChange) |>
  mutate(entrez_gene = mapIds(org.Mm.eg.db, 
                              keys = symbol, 
                              keytype = "SYMBOL", 
                              column = "ENTREZID")) |>
  filter(!is.na(entrez_gene))

geneList <- res_ranked$log2FoldChange
names(geneList) <- res_ranked$entrez_gene

## Run GSEA
gsea_res <- gseKEGG(geneList,
                    organism = "mmu", 
                    nPerm = 10000, 
                    pvalueCutoff = 0.1,
                    pAdjustMethod = "BH",
                    seed = TRUE)

## Plot GSEA results
summary(gsea_res) |> 
  as_tibble() |>
  filter(NES < 0) |>
  arrange(pvalue) |>
  slice(1:5) |>
  ggplot() + 
  geom_point(size = 0.25, aes(x = -log2(pvalue), 
                              y = reorder(Description, -pvalue)), 
             col = "black") +
  labs(x = "-log2(P value)",
       y = "", 
       title = "GSEA (downregulated pathways)") + 
  theme_classic() + 
  geom_segment(aes(y = Description, yend = Description, x = 0, xend = -log2(0.0001)), 
               linetype = "dotted", 
               size = 0.1) + 
  theme(axis.text.x = element_text(size = 5, color = "black"),
        axis.text.y = element_text(size = 5, color = "black"),
        axis.title = element_text(size = 6),
        plot.title = element_text(hjust = 0.5, size = 7),
        axis.ticks.length = unit(0.075, "cm")) 
