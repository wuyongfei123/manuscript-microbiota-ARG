meta = read.delim('1.131829512.GT.meta.median.n246.tsv',header=T,row.names = 1,check.names = F)
meta.4 = aggregate(.~topSNP.g.P,data = meta.3,median)  #提取分组中位数
rownames(meta.4) = meta.4$topSNP.g.P
meta.4 = meta.4[,-1]
meta.4 = as.data.frame(t(meta.4))
#绘图
par(mar = c(8, 6, 6, 4) + 0.1)  # 设置边距,底部, 左部, 上部, 右边，单位是文本行高度（lines）
library(pheatmap)
pheatmap(meta.4,scale = 'row',clustering_method = 'complete',cluster_rows = F,cluster_cols = F,
         show_rownames = T,show_colnames = F)