# 清空环境
rm(list=ls())

# 加载必要的库
library(dplyr)    
library(ggplot2)  
library(readr)
library(ggpubr)



Duck_Human_ARG_data <- read_csv("Duck-Human-ARG-abundance.csv")

# 创建分组散点图（Duck点在Human点之上）
p <- ggplot(Duck_Human_ARG_data, aes(x = Total_high_risk_ARG_abundance, y = Total_ARG_abundance)) +
  
  #先绘制人类点（在底层）
  geom_point(
    data = subset(Duck_Human_ARG_data, source == "Human"),
    aes(color = source, fill = source), 
    size = 1, 
    alpha = 0.6,
    shape = 21,
    stroke = 0.4
  ) +
  
  #再绘制鸭子点（在顶层）
  geom_point(
    data = subset(Duck_Human_ARG_data, source == "Duck"),
    aes(color = source, fill = source), 
    size = 1.5, 
    alpha = 0.6,
    shape = 21,
    stroke = 0.4
  ) +
  
  # 回归线和置信区间（保持不变）
  geom_smooth(aes(color = source, fill = source), 
              method = "lm", 
              se = TRUE,
              level = 0.95,
              size = 0.8,
              alpha = 0.2) +
  
  # 相关系数标签
  stat_cor(aes(color = source, label = paste(..r.label.., ..p.label.., sep = "~")),
           method = "spearman",
           label.sep = "\n",
           label.y = c(20000, 19000), # 鸭的标签在上，人的标签在下
           show.legend = FALSE,
           size = 3.5) +
  
  # 坐标轴标签
  labs(x = "High Risk ARGs Abundance",
       y = "All ARGs Abundance") +
  
  # 坐标轴范围设置
  coord_cartesian(xlim = c(0, 4000), ylim = c(0, 21000)) +
  
  # 颜色方案
  scale_color_manual(values = c(Duck = "#FF9324", Human = "#03569A")) +
  scale_fill_manual(values = c(Duck = "#ffdaa5", Human = "#D0D8EB")) +
  
  # 主题设置
  theme_bw(base_size = 12) +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major = element_line(color = "gray90", linewidth = 0.3),
    legend.position = c(0.85, 0.15),
    legend.background = element_rect(fill = alpha("white", 0.6)),
    legend.title = element_text(family = "Arial",face = "bold"),
    axis.title = element_text(family = "Arial",face = "bold", size = 12),
    axis.text = element_text(color = "black")
  )

print(p)

