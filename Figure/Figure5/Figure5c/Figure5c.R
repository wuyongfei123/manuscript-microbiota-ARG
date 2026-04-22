#LocusZoom plot

df = read.delim('Pvalue_g__Phocaeicola.Resion.R2.txt',header = T)
df$r2 = df$R2
df$r2[df$r2<0.2] = 'R2<0.2'
df$r2[df$r2>=0.2&df$r2<0.5] = '0.2<=R2<0.5'
df$r2[df$r2>=0.5&df$r2<0.8] = '0.5<=R2<0.8'
df$r2[df$r2>=0.8&df$r2<1] = '0.8<=R2<1'
df$r2[df$r2==1] = 'R2=1'

library(ggplot2)
library(dplyr)
library(ggrepel)

# 添加 -log10(P)
#df <- df %>% 
#  mutate(logP = -log10(P))

# 找到最显著的 SNP 用于标注
#top_snp <- df %>% filter(P_value == max(P_value))

#genes <- data.frame(
#  gene = c("GBGT1", "LCN1", "ABO", "SURF6", "MED22", "RPL7A"),
#  start = c(272800000, 272830000, 272880000, 272910000, 272950000, 272970000),
#  end = c(272820000, 272850000, 272900000, 272930000, 272960000, 272990000)
#)
genes = read.table('duck.genes.gff')
names(genes) = c('CHR','start','end','Gene')
topSNP.pos = 41556462    #根据topSNP进行调整
start.pos = topSNP.pos-100000
end.pos = topSNP.pos+100000
genes.1 = genes[genes$CHR == 1 & genes$start>start.pos & genes$end<end.pos,]
df = df.1[df.1$POS >=start.pos & df.1$POS <= end.pos,]

# 添加 gene 注释条
mycol = c('red','#D55E00','#F0E442','#009E73','#0072B2')
df$r2 = factor(df$r2,levels = c('R2=1','0.8<=R2<1','0.5<=R2<0.8','0.2<=R2<0.5','R2<0.2'))
P = ggplot(df, aes(x = POS / 1e6, y = -log10(p_wald), color = r2)) +
  geom_point(size = 4) +
  scale_colour_manual(values = mycol) +
  #geom_text_repel(data = top_snp, aes(label = SNP), nudge_y = 1.5) +
  geom_hline(yintercept = 0,color = "black", size = 1) +
  labs(
    x = "Position on Chr1 (Mb)",
    y = expression(-log[10](italic(P))),
    title = 'trait (1:131829512)'
  ) +
  
  geom_segment(data = genes.1, 
               aes(x = start/1e6, xend = end/1e6, y = -5, yend = -5),
               color = "black", linewidth = 4,  #linewidth设置矩形宽
               inherit.aes = FALSE) +  # 阻止继承主图层的aes
  geom_text_repel(data = genes.1,
                  aes(x = (start + end)/2/1e6, y = -6, label = Gene),
                  size = 3.5, angle = 45, hjust = 1,
                  box.padding = 0.3,
                  point.padding = 0.3,
                  min.segment.length = 0.2,
                  segment.color = "gray60",
                  segment.size = 0.5,
                  max.overlaps = 20,
                  inherit.aes = FALSE) +
  #geom_text(data = genes.1, 
  #aes(x = (start + end)/2/1e6, y = -6, label = Gene), 
  #size = 4, angle = 45, hjust = 1,
  #inherit.aes = FALSE) +  # 阻止继承主图层的aes
  coord_cartesian(ylim = c(-30, max(-log10(df$p_wald)) * 1.1)) +  #扩大y轴0以下的空间
  theme_classic(base_size = 14) +  # 白底 + 干净风格
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    axis.text = element_text(size = 15),
    axis.title = element_text(size = 18),
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    axis.line = element_line(color = "black", linewidth = 0.6),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8)
    #legend.position = "none"  # 可选：隐藏图例
  )
ggsave(P, filename="g_Phoca.Region.pdf",width = 10,height = 8) 
