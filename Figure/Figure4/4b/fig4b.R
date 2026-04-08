# 准备工作环境
rm(list=ls())

# 加载R包
library(ggplot2)    # 画图
library(vegan)      # 用于计算距离和PCoA
library(dplyr)      # 数据操作
library(readxl)     # 读取Excel数据
library(tibble)     # 用于处理行名和列名
library(readr)

pcoa_points_filtered <- read_csv("D:/2025_1162_duck_args/文章/数据和代码/source_data_script/Figure/Figure4/4b/Feces_Breed_pcoa_points.csv")

# 定义形状映射(只有shishi)
shape_mapping <- c(
  "SXD-ShiShi" = 18,         
  "YXP-ShiShi" = 1,        
  "MWD-ShiShi" = 17,  #实心圆
  "TWD-ShiShi" = 2,       #空心圆
  "SPD-ShiShi" = 15,         #空心三角
  "PTB-ShiShi" = 12,      #实心三角
  "LSD-ShiShi" = 16,       #空心正方形
  "ZSP-ShiShi" = 0,       #实心正方形
  "JYP-ShiShi" = 25,       #实心正方形
  "JRD-ShiShi" = 11, 
  "LCW-ShiShi" = 13, 
  "CHP-ShiShi" = 10
)


size_mapping <- c(
  "SXD-ShiShi" = 3,         
  "YXP-ShiShi" = 3,        
  "MWD-ShiShi" = 3,  
  "TWD-ShiShi" = 3,      
  "SPD-ShiShi" = 3,      
  "PTB-ShiShi" = 3,     
  "LSD-ShiShi" = 3,    
  "ZSP-ShiShi" = 3,    
  "JYP-ShiShi" = 3,       
  "JRD-ShiShi" = 3, 
  "LCW-ShiShi" = 3, 
  "CHP-ShiShi" =3     
)


p1 <- ggplot(pcoa_points_filtered, aes(x = V1, y = V2, color = Application)) +
  geom_point(aes(shape = Breed_city, size = Breed_city), show.legend = TRUE) +
  scale_size_manual(values = size_mapping, guide = "none") +
  labs(x = xlab, y = ylab, 
       color = "Application",
       shape = "Breed-Collecting place") +
  theme_bw() +
  theme(
    plot.title = element_text(size = 12, hjust = 0.8),
    axis.title = element_text(family = "Arial", face = "bold", size = 14),
    axis.text = element_text(family = "Arial", face = "bold", size = 14),
    legend.title = element_text(family = "Arial", face = "bold", size = 10),
    legend.text = element_text(family = "Arial", face = "bold", size = 10)
  ) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c(
    "dual_type" = "#1f77b4",
    "egg_type" = "#ff7f0e"
    #"meat_type" = "#d62728"
  )) +
  scale_shape_manual(values = shape_mapping)

p1
