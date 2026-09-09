m = read.delim('Shannon.tsv',header=T,sep = '\t')
m$Day = factor(m$Day,levels = c('0d','14d')) #'7d',,'21d'
m$Group = factor(m$Group, levels = c('Control','0.02%DAPr','0.03%DAPr'))
library(ggplot2)
library(ggpubr)
#compare_means(g__Phocaeicola~Group, data = m, group.by = 'Day')  #计算P值
my.group = list(c('Control','0.02%DAPr'),c('Control','0.03%DAPr'))
Group.col = c("#DE582B","#1868B2","#018A67") #,"#F3A332"
P = ggboxplot(m, x = 'Day', y = 'Shannon', color = 'Group', width=0.5,alpha = 0.6, add = "jitter") +    # 绘制箱线图，不显示离群点
  geom_violin(aes(fill = Group, color = Group), alpha = 0.5,width = 0.7,
              position = position_dodge(0.8),trim = TRUE) +
  scale_fill_manual(values  = Group.col) + # 使用预设的颜色
  scale_color_manual(values = Group.col) +
  labs(title = "", y = "Shannon Index", x = "") +
  theme_bw() +
  theme(panel.grid = element_blank(),
        panel.border = element_blank(),  #移除所有边框
        axis.line = element_line(color = "black"),  #显示所有轴线
        axis.text.x = element_text(size = 15), # 倾斜 x 轴标签angle = 0, hjust = 1,
        axis.text.y = element_text(size = 15),      
        axis.title.y = element_text(size = 17)     #调整y轴主题字体大小
        #strip.text = element_text(size = 17),             # 调整分面标题的大小
        #panel.spacing = unit(1, "lines"),                 # 增加分面之间的间隔
        #legend.position = 'none'
   )
ggsave(P,filename = 'Shannon.pdf',width = 6,height = 5)
