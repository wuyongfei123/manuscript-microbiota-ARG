#环形柱状图
library(ggplot2)
data= read.table('clipboard',header=T)
Group.col = c("#F0A73A","#2C91E0")
p = ggplot(data, aes(x = as.factor(Type), y = number,fill = Category)) + 
  geom_bar(stat = 'identity', position = 'stack') +
  scale_fill_manual(values = alpha(Group.col,0.8)) +
  ylim(-5,8) +
  coord_polar(theta = 'x') +
  theme_bw() +
  theme(axis.text.y = element_blank(),#去除y轴坐标标签
        axis.text.x = element_text(size = 15),
        axis.ticks = element_blank(), #去除刻度线
        axis.title = element_blank(), #去除y轴主题
        panel.border = element_blank(), #去除外框
        #panel.grid = element_blank()  #去除网线
        legend.position = 'left'
  )
ggsave(p, filename = 'Figure6F.2.pdf', width = 7, height = 6)
