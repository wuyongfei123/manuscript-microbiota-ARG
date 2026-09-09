meta = read.delim('Fig6a.txt',header=T,row.names = 1,check.names = F)
meta.4 = as.data.frame(t(meta))
#绘图
par(mar = c(8, 6, 6, 4) + 0.1)  # 设置边距,底部, 左部, 上部, 右边，单位是文本行高度（lines）
library(pheatmap)
pheatmap(meta.4,scale = 'row',clustering_method = 'complete',cluster_rows = F,cluster_cols = F,
         show_rownames = T,show_colnames = F)