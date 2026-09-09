Genus = read.delim('Figure7d.txt',header=T)
Group = read.delim('Group.txt',header=T)
Genus.1 = merge(Group,Genus,by = 'Sample_id')
library(tidyr)
Genus.2 = gather(Genus.1, key = 'Genus',value = 'value',4:ncol(Genus.1))
Genus.3 = unite(Genus.2, col = 'Group.D',Day,Group,sep = '_')
library(ggplot2)
library(ggalluvial)
library(RColorBrewer)
Genus.3$Genus = factor(Genus.3$Genus,levels = c('Others','g__Jeotgalicoccus','g__Anaerococcus','g__Gleimia',
                                                'g__Microaceticoccus','g__Enterococcus_E','g__Phocaeicola',
                                                'g__Aerococcus','g__Corynebacterium','g__Staphylococcus','g__Streptococcus'))
Genus.3$Group.D = factor(Genus.3$Group.D,levels = c('0d_Control','0d_0.02%DAPr','0d_0.03%DAPr',
                                                    '14d_Control','14d_0.02%DAPr','14d_0.03%DAPr'))
mycol = c("#D9D9D9","#FCCDE5","#B3DE69","#C99BFF","#B88640","#FFD92F",
          "#2C91E0","#E78AC3","#8DA0CB","#66C2A5","#FC8D62")
plot1 = ggplot(Genus.3,aes(x=Sample_id,fill = Genus,y = value*100,stratum = Genus,alluvium = Genus)) +
  geom_col(position = 'stack') +
  geom_alluvium() +  #条形与条形之间连接的颜色块
  scale_fill_manual(values = mycol) +  #填充颜色
  #geom_stratum(width = 0.5,size = 0.3) +  #设置条状图的大小
  #scale_y_continuous(expand = c(0,0)) +  #控制x轴上刻度线与y轴的距离
  labs(y = 'Relative abundance(%)') +
  facet_wrap(~Group.D,scales = 'free_x',ncol = 6) +  #按Group分组,顶部的标签
  theme(axis.text.x = element_blank(),axis.text.y = element_text(size = 12),
        axis.title.x = element_blank(),axis.title.y = element_text(size = 15),
        legend.position = "right", #将图例设置在右边
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 15),
  )
ggsave(plot1,filename='Figure7d.pdf',width = 9,height = 4)
