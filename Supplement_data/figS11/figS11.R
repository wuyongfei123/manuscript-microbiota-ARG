data.r = read.delim('r.value.tsv',header=T,row.names = 1,check.names = F)
data.p.adj = read.delim('p.adj.tsv',header=T,row.names = 1,check.names = F)
getSig = function(dc){
  sc = ''
  if (dc < 0.001) sc = '***'
  else if (dc < 0.01) sc = '**'
  else if (dc < 0.05) sc = '*'
  sc
}
data.p.adj = as.matrix(data.p.adj)
sig.mat = matrix(sapply(data.p.adj,getSig),nrow = nrow(data.p.adj))
library(pheatmap)
pheatmap(data.r,clustering_method = 'complete',cluster_rows = F,cluster_cols = F,
         display_numbers=sig.mat, angle_col = 45,
         show_rownames = T,show_colnames = T)