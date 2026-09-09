m = read.delim('g_Lactobacillus.tsv',header = T)
m$Day = factor(m$Day,levels = c('0d','14d')) #'7d',,'21d'
m$Group = factor(m$Group, levels = c('Control','0.02%DAPr','0.03%DAPr'))
library(dplyr)
# 1. 定义过滤函数,过滤离散值,三倍标准差
remove_outliers_sd <- function(x, n_sd = 3) {
  mean_x <- mean(x, na.rm = TRUE)
  sd_x <- sd(x, na.rm = TRUE)
  return(x >= mean_x - n_sd * sd_x & x <= mean_x + n_sd * sd_x)
}
# 2. 过滤数据
m_clean <- m %>%
  group_by(Group, Day) %>%
  filter(remove_outliers_sd(RA, n_sd = 3)) %>%
  ungroup()

library(ggplot2)
library(ggpubr)
#compare_means(g__Phocaeicola~Group, data = m, group.by = 'Day')  #计算P值
my.group = list(c('Control','0.02%DAPr'),c('Control','0.03%DAPr'))
Group.col = c("#DE582B","#1868B2","#018A67") #,"#F3A332"
P = ggplot(m_clean, aes(x = Group, y = RA,color = Group,fill = Group)) +   # 
  #geom_violin(alpha = 0.7, trim = FALSE) +
  geom_boxplot(outlier.shape = NA, width=0.5,alpha = 0.6) +    # 绘制箱线图，不显示离群点
  geom_jitter(width = 0.2,height = 0,size = 1.5) +  # 添加散点aes(color = Group),width和height是点的抖动范围
  facet_wrap(~Day, scales = "free_x", strip.position = "top",nrow = 1) + 
  # 按 FID 分面，但共享纵坐标，并在顶部显示分面标题；
  #‘free’:每个分面可以有不同的y轴范围
  stat_compare_means(comparisons = my.group, method = 'wilcox.test',label = 'p.signif') +
  scale_fill_manual(values  = Group.col) + # 使用预设的颜色
  scale_color_manual(values = Group.col) +
  labs(title = "", y = "Relative Abundance (g__Lactobacillus)", x = "") +
  theme_bw() +
  theme(
    axis.text.x = element_text(size = 15,angle = 45,hjust = 1), # 倾斜 x 轴标签angle = 0, hjust = 1,
    axis.text.y = element_text(size = 15),      
    axis.title.y = element_text(size = 17),     #调整y轴主题字体大小
    strip.text = element_text(size = 17),              # 调整分面标题的大小
    panel.spacing = unit(1, "lines"),                 # 增加分面之间的间隔
    legend.position = 'none'
  )
ggsave(P,filename = 'g__Lactobacillus.3sd.pdf',width = 4,height = 5)
