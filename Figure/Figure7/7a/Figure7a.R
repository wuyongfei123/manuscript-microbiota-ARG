library(ggpubr)
library(ggplot2)
data1 = read.delim('L.johnsonii.OD.value.tsv',header = T)
data1$Group = factor(data1$Group,levels = c('0ug/ml','250ug/ml','500ug/ml','1000ug/ml'))
data1$time = factor(data1$time, levels = c('0','2','4','6','8','10','15','21','27','30'))
P = ggline(data1,x = 'time',y='OD_value',add = 'mean_se',color = 'Group',palette = 'jco',
           shape = 'Group') +
  scale_shape_manual(values = c(15, 16, 17, 18)) +
  labs(
    title = '',
    x = "time (h)",
    y = "OD600(L.johnsonii)"
  )
ggsave(P,filename='L.johnsonii.pdf',width = 5,height=5)
