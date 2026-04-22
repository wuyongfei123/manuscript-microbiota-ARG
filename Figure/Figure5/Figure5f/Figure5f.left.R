library(ggplot2)
Group.col = c("#ED7A6A","#77DCDD","#66C999","#DEAEBF","#638DEE") #分组
P=  ggplot(phoca,aes(live.rate,-log10(p.adj))) + #Application, shape = FID, shape = city
  geom_point(aes(color = Resistance.Mechanism),size = 3, ) + #color = FID
  #stat_ellipse(level = 0.95,aes(colour = Application),linetype = 2) + #添加置信圈
  #scale_shape_manual(values = c(16,17,18,16,17,16,16,17,18,16,17,16,17,18,16,16,17,18)) +#15,16,17,18
  scale_colour_manual(values = Group.col) +   #values = Group.col
  #geom_vline(xintercept = 0,color = "gray") +
  geom_point(data = subset(phoca, -log10(p.adj) < -log10(0.05)),color = "#999999",size = 4) +
  geom_hline(yintercept = -log10(0.05),color = "black") +
  #scale_y_continuous(limits = c(-0.25,0.1)) +
  theme_bw() +
  theme(panel.grid = element_blank(),
        plot.title = element_text(hjust = 0.5,size = 20),
        axis.text.x = element_text(size = 17),axis.text.y = element_text(size = 17),
        axis.title = element_text(size = 18),
        legend.text = element_text(face = "plain",colour = "black",size = 16),
        legend.title = element_text(face = "plain",colour = "black",size = 18)) +
  labs(x="The presence rate in SRD CC sample",#
       y='-log10(adj.p_value)')
ggsave(P,filename = "Figure6F.1.pdf",width = 8,height = 7)
