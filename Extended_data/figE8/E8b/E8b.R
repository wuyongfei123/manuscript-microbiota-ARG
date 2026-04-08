data.r = read.delim('Figure.S10.right.tsv',header = T,row.names = 1,check.names = F)
#代谢物分组
group.color = read.delim('group.meta.txt',header = T,row.names = 1,check.names = F)
group = group.color[,c(1,2)]
data.r.1 = data.r[rownames(group.color),]
#设置分组颜色
anno.color = list()
anno.color$class = unique(group.color$color) #c("#2C91E0","#3ABF99","#F0A73A")
anno.color$class1 = unique(group.color$color1) #c('#0C4E9B','#6B98C4',colorRampPalette(c('#B4DEA2','#6BBC46'))(6),colorRampPalette(c('#FBF8B4','#FBB463'))(20))
names(anno.color$class) = unique(group$class) #c('Growth traits','Quantitative lipidomics','TM Widely-targeted metabolomics')
names(anno.color$class1) = unique(group$class1)
library(pheatmap)

pheatmap(data.r.1,clustering_method = 'complete',cluster_rows = F,cluster_cols = F,
         breaks = seq(-0.3,0.3,length.out = 100),#legend = F,
         show_rownames = T,show_colnames = T, border_color = NA, angle_col = 0,
         annotation_row = group,annotation_colors = anno.color, #annotation_legend = F,
         width = 20,height = 15,filename = 'Figure.S10.right.pdf')
