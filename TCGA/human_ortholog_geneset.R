## Function written by user Colin on bioconductor.org [here](https://support.bioconductor.org/p/129636/)

mouse_human_genes <- 
  read.csv("http://www.informatics.jax.org/downloads/reports/HOM_MouseHumanSequence.rpt", sep = "\t")

convert_mouse_to_human <- function(gene_list){
  
  output = c()
  
  for(gene in gene_list){
    class_key = (mouse_human_genes %>% filter(Symbol == gene & Common.Organism.Name=="mouse, laboratory"))[['DB.Class.Key']]
    if(!identical(class_key, integer(0)) ){
      human_genes = (mouse_human_genes %>% filter(DB.Class.Key == class_key & Common.Organism.Name=="human"))[, "Symbol"]
      for(human_gene in human_genes){
        output = append(output,human_gene)
      }
    }
  }
  
  return (output)
}
