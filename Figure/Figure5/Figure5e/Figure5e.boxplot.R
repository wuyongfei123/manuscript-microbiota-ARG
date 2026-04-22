data = read.delim('GT.Krukal.MAG.tsv',header = T)
data = data[,c(1,4,2)]
names(data)[1:3] = c('id','PeakSNP','traits')
data$PeakSNP = factor(data$PeakSNP,levels = c('g__Phocaeicola','other_genus_from_Bacteroidaceae','other_families'))
my.group = list(c("g__Phocaeicola","other_genus_from_Bacteroidaceae"),c("other_genus_from_Bacteroidaceae","other_families"),c("g__Phocaeicola","other_families"))
Group.col = c("#c74546","#93cc82","#4d97cd")
library(ggplot2)
library(ggpubr)
file_name = 'boxplot.pdf'
data$traits.log = -log10(data$traits)
p = ggboxplot(data, x="PeakSNP", y="traits.log", color = "PeakSNP",palette = Group.col, 
              width = 0.5, size = 0.6, fatten = 1, alpha = 0.6, outlier.shape = NA)+
  #geom_jitter(aes(color = Group), size = 2) +
  geom_violin(aes(fill = PeakSNP), color = NA, alpha = 0.6, width = 0.5, trim = TRUE, scale = "width") + 
  #geom_point(aes(color = PeakSNP, fill = PeakSNP), show.legend = FALSE, 
  #           position = position_jitter(seed = 123456, width = 0.2), shape = 21, size = 1) +
  stat_compare_means(comparisons=my.group,label = 'p.adj')+ # Add pairwise 
  #stat_compare_means(label.y = 4,label.x = 0.7) +# Add global p-value
  # annotate("text",x=c(1,2,3),y=-0.5,label=c("n = 75","n = 154","n = 67"),size=5) +
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