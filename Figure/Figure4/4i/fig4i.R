rm(list=ls())

# 加载必要的包
library(ggplot2)
library(readr)
library(dplyr)
library(tidyr)
library(tidyverse)

wide_data <- read_csv("feces_high_risk_ARG_breed_abundance.csv")

# 设置行名为第一列
wide_data <- column_to_rownames(wide_data, var = "ARG_type")
# merged_data转为数值型矩阵
merged_data_matrix <- as.matrix(wide_data)

#画图
library(pheatmap)
# 自定义颜色
custom_colors <- colorRampPalette(c("white","#C9E1BD","#f0a5c0"))(100)

# 确保列名顺序
desired_order <- c("LCW","LSD","CHP","ZSP","JRD","YXP","MWD","TWD","SPD","SXD","JYP","PTB")
merged_data_matrix <- merged_data_matrix[, desired_order]

#创建分组注释数据框
annotation_df <- data.frame(
  row.names = colnames(merged_data_matrix),
  Application_Type = c(rep("dual type", 5), rep("egg type", 7))
)

# 定义分组对应的颜色
annotation_colors <- list(
  Application_Type = c(
    "meat type" = "#c9605f",  
    "dual type" = "#646e9a", 
    "egg type" = "#eab676"    
  )
)

# 绘制热图
p <- pheatmap(
  merged_data_matrix, 
  color = custom_colors,  
  cluster_rows = TRUE,    
  cluster_cols = FALSE,   
  annotation_col = annotation_df, 
  annotation_colors = annotation_colors, 
  #main = "Heatmap of different Breed and High Risk ARGs(Feces)",
  show_rownames = TRUE,
  show_colnames = TRUE,
  fontsize_row = 13,  
  fontsize_col = 13,   
  fontfamily = "Arial",
  scale = "row",     
  angle_col = 0,       
  annotation_names_col = FALSE 
)

p
