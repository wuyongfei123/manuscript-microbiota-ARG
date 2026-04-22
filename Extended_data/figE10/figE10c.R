library(ggpubr)
data.2 = read.delim('P.plebeius.txt',header=T,check.names = F)
ggline(data.2,x = 'time',y='values',add = 'mean_se',color = 'Group',palette = 'jco') +
  stat_compare_means(aes(group = Group),label = 'p.signif')
