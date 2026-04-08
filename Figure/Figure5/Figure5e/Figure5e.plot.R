MAG = read.delim('GT.Krukal.MAG.tsv',header=T)
data = MAG[,c(1,3,16,17)]
Group.col = c("#c74546","#93cc82","#4d97cd")
#Group.col = c('#1C9E78','#D75E01','#4d97cd')
data$P.log = -log10(data$p.adj)
#data$Group = factor(data$Group,levels = unique(data$Group))
data$Group = factor(data$Group,levels = c('g__Phocaeicola','other_genus_from_Bacteroidaceae','other_families'))
library(ggplot2)
file_name = 'Figure.6E.point.plot.pdf'
P=  ggplot(data,aes(live_rate,P.log)) + #Application, shape = FID, shape = city
  geom_point(aes(color = Group),size = 3,alpha = 0.8) + #color = FID, shape = 1, stroke = 2
  #stat_ellipse(level = 0.95,aes(colour = Application),linetype = 2) + #添加置信圈
  #scale_shape_manual(values = c(16,17,18,16,17,16,16,17,18,16,17,16,17,18,16,16,17,18)) +#15,16,17,18
  scale_colour_manual(values = Group.col) +   #mycol
  #geom_vline(xintercept = 0,color = "gray") +
  #geom_hline(yintercept = 0,color = "gray") +
  #scale_y_continuous(limits = c(-0.25,0.1)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        axis.text.x = element_text(size = 17),axis.text.y = element_text(size = 17),
        axis.title = element_text(size = 18),
        legend.text = element_text(face = "plain",colour = "black",size = 16),
        legend.title = element_text(face = "plain",colour = "black",size = 18)) +
  labs(x="The presence rate in SRD CC sample",#
       y='-log10(Padj)')#,format(100*eig[2]/sum(eig),digits = 4),"%)",sep=""
ggsave(P,filename = file_name, width = 9,height = 7)
