data.r = read.delim('r_value.txt',header=T,row.names =1,check.names = F)
data.p.adj = read.delim('pvalue.txt',header=T,row.names =1,check.names = F)

library(pheatmap)
#设置显著性标记
getSig = function(dc){
  sc = ''
  if (dc < 0.001) sc = '***'
  else if (dc < 0.01) sc = '**'
  else if (dc < 0.05) sc = '*'
  sc
}
data.p.adj = as.matrix(data.p.adj)
sig.mat = matrix(sapply(data.p.adj,getSig),nrow = nrow(data.p.adj))

pheatmap(data.r, clustering_method = 'complete',cluster_cols = F, 
         display_numbers=sig.mat, cluster_rows = F,
         width = 10,height = 7,
         filename ='fig.s6.pdf')
