data = read.delim('Figure6b.txt',header=T)
file_name = 'Figure6b.pdf'
P=  ggplot(data,aes(r_value,-log10(p.fdr))) + #Application, shape = FID, shape = city
  geom_point(size = 2,alpha = 0.8) + #color = FID, shape = 1, stroke = 2, aes(color = Genus)
  geom_hline(yintercept = -log10(0.05),color = "gray",linetype='dashed') +
  geom_point(data = subset(data,p.fdr <= 0.05),color = '#F0A73A',size = 3) +
  geom_point(data = subset(data,p.fdr > 0.05),color = 'black',size = 2) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        # 调整边距 - 使用plot.margin(上，右，底，左)
        plot.margin = margin(t = 6, r = 6, b = 10, l = 10, unit = "mm"),
        plot.title = element_text(hjust = 0.5,size = 20),
        axis.text.x = element_text(size = 17),axis.text.y = element_text(size = 17),
        axis.title = element_text(size = 20),
        legend.text = element_text(face = "plain",colour = "black",size = 16),
        legend.title = element_text(face = "plain",colour = "black",size = 18)) +
  labs(x="The r value between DAPr and Genus",#
       y='-log10(Padj)')#,format(100*eig[2]/sum(eig),digits = 4),"%)",sep=""
ggsave(P,filename = file_name, width = 6,height =7)