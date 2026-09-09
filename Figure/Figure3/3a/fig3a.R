# 准备工作环境
rm(list=ls())

# 加载R包
library(ggplot2)  
library(readr)      

# 读取数据
pcoa_points_filtered <- read_csv("pcoa_points.csv") 

p <- ggplot(pcoa_points_filtered, aes(x = V1 * (-1), y = V2 * (-1), color = group)) +
  geom_point(size = 3, alpha = 0.7) +  
  labs(x = xlab, y = ylab, color = "Gut Location") +  
  theme_bw() +
  theme(
    text = element_text(family = "Arial", face = "bold", size = 16),
    plot.title = element_text(hjust = 0.5, size = 12),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(face = "bold"),
    legend.text = element_text(face = "bold"),
    legend.title = element_text(face = "bold")
  ) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(
    values = alpha(  
      c("GS" = "#EE7424", 
        "MS" = "#5E5094",
        "DC" = "#E86976",
        "JC" = "#EFD19B",
        "IC" = "#997942",
        "CC" = "#779A4F",
        "CR" = "#DC9FC8",
        "Feces" = "#7fabc4"),
      alpha = 0.9  
    ),
    limits = c("GS", "MS", "DC", "JC", "IC", "CC", "CR", "Feces")
  )

p


