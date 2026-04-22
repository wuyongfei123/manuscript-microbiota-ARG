#各表型在topSNP(1:131829512)不同基因型之间的聚类热图
phe.GT = read.delim('Figure.S10.left.tsv',header=T,check.names = F)
phe = phe.GT[order(phe.GT$GA),]
phe = phe[phe$GA!='./.',]
rownames(phe) = phe$id
phe = phe[,-c(1,2)]
phe = as.data.frame(t(phe))
#分组
group.col = read.delim('group.GT.txt',header=T)  #样本分组，基因型
rownames(group.col) = group.col$id
group.col.1 = subset(group.col,select = 'GA')
#代谢物分组
group.color = read.delim('group.meta.txt',header = T,row.names = 1,check.names = F)
group = group.color[,c(1,2)]
phe1 = phe[rownames(group.color),]

anno.color = list()
anno.color$class = unique(group.color$color) #c("#2C91E0","#3ABF99","#F0A73A")
anno.color$class1 = unique(group.color$color1) #c('#0C4E9B','#6B98C4',colorRampPalette(c('#B4DEA2','#6BBC46'))(6),colorRampPalette(c('#FBF8B4','#FBB463'))(20))
anno.color$GA = c("#6F6F6F","#F6631C","#C99BFF")
names(anno.color$class) = unique(group.color$class) #c('Growth traits','Quantitative lipidomics','TM Widely-targeted metabolomics')
names(anno.color$class1) = unique(group.color$class1)
names(anno.color$GA) = c('A/A','G/A','G/G')
library(pheatmap)
pheatmap(phe1,scale = 'row',clustering_method = 'complete',cluster_rows = F,cluster_cols = F,
         breaks = seq(-20,20,length.out = 100),legend = F,
         show_rownames = F,show_colnames = F, border_color = NA, angle_col = 0,
         annotation_row = group,
         annotation_col = group.col.1,
         annotation_colors = anno.color, annotation_legend = F,
         width = 10,height = 12,filename = 'Figure.S10.left.pdf')
