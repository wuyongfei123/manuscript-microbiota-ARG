library(data.table)
add = fread('Add.Dom.ARG.Genome_level.Pvalue.combined.tsv',header=T)
topsnp = read.delim('Add.Dom.ARG.Genome_level.topSNP.tsv',header=T)
add.sig = read.delim('Add.Dom.ARG.Pvalue.sign.tsv',header=T,check.names =F,sep = '\t')
names(add.sig)[c(1,2,3,4)] = c('CHR','POS','ARG','Group')
add = as.data.frame(add)
data = add[add$P_value >= 2,]
names(data)[c(1,2)] = c('CHR','POS')
data = data[order(data$CHR,data$POS),]
data$SNP1 = seq(1,nrow(data),1)
data$CHR = factor(data$CHR,levels = unique(data$CHR))
data$ARG = factor(data$ARG,levels = unique(data$ARG))
data$Group = factor(data$Group,levels = unique(data$Group))
data.sig = merge(data, add.sig[,c('CHR','POS')], by = c('CHR','POS'))
data.topsnp = merge(data.sig,topsnp,by = c('CHR','POS'))
chr = aggregate(data$SNP1,by = list(data$CHR),FUN=median)
chr = chr[c(1:9,12,16,22,27,39),]
#获取ARG的唯一值用于颜色
#arg_levels = levels(data$ARG)
#n_arg = length(arg_levels)
#arg_colors = c("#DE582B","#1868B2","#018A67","#F3A332","#069DFF","#808080","#A4E048","#010101","#015493","#019092","#999999","#F4A99B",
#                "#BABABA","#0001A1","#037F77","#C5272D","#32037D","#7C1A97","#C94E65","#D9995B","#909090","#0095FF","#019092","#6FDCB5",
#                "#2F2D54","#9193B4","#BD9AAD","#E8D2B3","#D6D6D6","#9CB0C3","#7C9D97","#EAB080","#4FBD81","#ADE0B4","#5DBFE9","#E7E6D4"
#                )
#names(arg_colors) = arg_levels
#根据加性和显性效应注释颜色
AD_levels = levels(data$Group)
AD_colors = c("#6699CC","#CC6666")
names(AD_colors) = AD_levels
library(ggplot2)
library(ggnewscale)
p = ggplot(data,aes(SNP1,P_value)) +
    geom_hline(yintercept = c(-log10(1/1000000),-log10(0.05/1000000)),color = c('black','#23B2E0'),linewidth = 0.3,linetype = c("dashed","solid")) +
    geom_point(aes(color = CHR),show.legend = FALSE, alpha = 0.8,size = 2) +
    scale_color_manual(values = rep(c( "grey30","grey50"),39)) +
    scale_x_continuous(breaks = chr$x,labels = chr$Group.1, expand = c(0.01,0)) +
    new_scale_color() +  #使用 new_scale_color() 重置颜色映射
    geom_point(data = subset(data.sig, P_value > 6), aes(color = Group), size =2) +
    scale_color_manual(values = AD_colors,name = 'AD model') +
    geom_point(data = subset(data.topsnp, P_value > 7.3), color = 'red', size = 4) +
    theme_bw() +
    theme(panel.grid = element_blank(), 
        axis.text=element_text(size=15,color = 'black'), 
        axis.title.x=element_text(size=16),axis.title.y=element_text(size=16), 
        axis.line = element_line(color = 'black'), panel.background = element_rect(fill = 'transparent')) +
    labs(x = 'Chromosome', y = '-log10(P)')
ggsave(p, filename = 'Add.Dom.Genome_level.ARG.manhattan.plot.png',width = 14,height = 5,dpi = 300)
