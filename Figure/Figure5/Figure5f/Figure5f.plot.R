#point plot
data = read.delim('GT.Krukal.MAG.tsv',header=T)
data$P.log = -log10(data$p.adj)
data$Group = factor(data$Group,levels = c('MAGs from Phocaeicola','MAGs from other genus in Bacteroidaceae','MAGs from other families'))
library(ggplot2)
file_name = 'fig5f.right.pdf'

library(ggpubr)
ggscatterhist(data, x = 'live_rate',y = 'P.log',color = 'Group', size = 3, alpha = 0.8,
              palette = c("#c74546","#B88640","#4d97cd"),
              margin.plot = 'density',
              margin.params = list(fill = 'Group',color = 'black', size = 0.3),
              xlab = 'The presence rate in SRD CC sample',
              ylab = '-log10(Padj)',
              legend = 'right'
)
ggsave(filename = file_name, width = 9,height = 7)

#boxplot
data.1 = read.delim('GT.Krukal.MAG.tsv',header=T)
data = data[,c(1,4,2)]
names(data)[1:3] = c('id','Group','traits')
data$Group = factor(data$Group,levels = c('MAGs from Phocaeicola','MAGs from other genus in Bacteroidaceae','MAGs from other families'))
my.group = list(c("MAGs from Phocaeicola","MAGs from other genus in Bacteroidaceae"),
                c("MAGs from other genus in Bacteroidaceae","MAGs from other families"),
                c("MAGs from Phocaeicola","MAGs from other families"))
Group.col = c("#c74546","#B88640","#4d97cd")
library(ggplot2)
library(ggpubr)
file_name = 'boxplot.pdf'
data$traits.log = -log10(data$traits)
p = ggboxplot(data, x="Group", y="traits.log", color = "Group",palette = Group.col, 
              width = 0.5, size = 0.6, fatten = 1, alpha = 0.6, outlier.shape = NA)+
  geom_violin(aes(fill = Group), color = NA, alpha = 0.6, width = 0.5, trim = TRUE, scale = "width") + 
  stat_compare_means(comparisons=my.group,label = 'p.adj')+ # Add pairwise 
  theme_bw() +
  theme(panel.grid = element_blank(),
        plot.title = element_text(size = 14,face = 'bold',hjust = 0.5),
        axis.text.x = element_blank(),axis.text.y = element_text(size = 17),
        axis.title = element_text(size = 18),
        legend.position = 'none'
  ) +
  labs(
    title = '',
    x = "",
    y = "-log10(Padj)"
  )
ggsave(p,filename = file_name, width = 4,height = 5)
