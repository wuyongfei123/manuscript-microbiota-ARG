data = read.delim('PCoA.tsv',header=T)
data$Group = factor(data$Group,levels = c('Control','0.02%DAPr','0.03%DAPr'))
#步骤1：计算中心点和标准误
library(dplyr)
group_cent = data %>%
  group_by(Day, Group) %>%
  summarise(
    x_mean = mean(PCoA1),
    y_mean = mean(PCoA2),
    x_se = sd(PCoA1) / sqrt(n()),
    y_se = sd(PCoA2) / sqrt(n()),
    .groups = "drop"
  )
mycol = Group.col = c("#DE582B","#1868B2","#018A67")
library(ggplot2)
P = ggplot(group_cent,aes(x=x_mean, y = y_mean, shape = Day, color = Group)) +
  geom_point(aes(color = Group),size = 10, alpha = 0.8) +
  #垂直误差棒
  geom_errorbar(aes(x = x_mean, y=y_mean, 
                    ymin = y_mean - y_se, ymax = y_mean + y_se), width = 0.02, linewidth = 0.5) +
  #水平误差棒
  geom_errorbarh(aes(x = x_mean, y=y_mean, 
                     xmin = x_mean - x_se, xmax = x_mean + x_se),
                 height = 0.02,linewidth = 0.5) +
  scale_color_manual(values = mycol) +  #设置点的颜色
  scale_shape_manual(values = c(16,17)) +  #设置点的形状
  geom_vline(xintercept = 0, color = 'gray') +
  geom_hline(yintercept = 0, color = 'gray') +
  theme_bw() +
  theme(panel.grid = element_blank(), #q去除theme_bw（）的网格
        plot.title=element_text(hjust=0.5, size=20), #主题字体大小
        axis.text.x=element_text(size = 17),axis.text.y=element_text(size = 17), #x和y轴的字体大小
        axis.title = element_text(size = 18),
        legend.text=element_text(face="plain", colour="black", size=16), #图例字体        
        legend.title=element_text(face="plain", colour="black", size=18)) +  
  labs(x=paste("PCoA1(",39.28,"%)",sep=""),  #计算各个主成分的解释率
      y=paste("PCoA2(",16.89,"%)",sep=""),
      title = '')
ggsave(P,filename = 'PCoA.pdf',width = 7,height = 6)
