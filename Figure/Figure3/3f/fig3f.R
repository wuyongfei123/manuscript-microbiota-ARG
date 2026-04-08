rm(list=ls())

# 加载必要的包
library(ggplot2)
library(tidyverse)
# 读取数据
wild_data <- read_csv("high_risk_ARG_gut_abundance.csv")

# 设置行名为第一列
wild_data <- column_to_rownames(wild_data, var = "ARG_type")
# merged_data转为数值型矩阵
merged_data_matrix <- as.matrix(wild_data)

#画图
library(pheatmap)
# 自定义颜色
custom_colors <- colorRampPalette(c("#335C8C", "white", "#C22E26"))(100)

# 确保列名顺序
desired_order <- c("Stomach", "small_intestine", "large_intestine", "Feces")
merged_data_matrix <- merged_data_matrix[, desired_order]

# 绘制热图
p <- pheatmap(
  merged_data_matrix, 
  color = custom_colors,  # 蓝-白-红颜色渐变
  cluster_rows = TRUE,    # 对行聚类
  cluster_cols = FALSE,   # 禁用列聚类以保留指定顺序
  #annotation_row = row_annotation,  # 行注释
  #annotation_colors = annotation_colors,  # 注释颜色
  #main = "Heatmap of different gut and High Risk ARGs",
  show_rownames = TRUE,
  show_colnames = TRUE,
  fontfamily = "Arial",
  fontsize_row = 10,  # Y轴标签字体大小
  fontsize_col = 15,   # X轴标签字体大小
  scale = "row",    # 数据按列标准化
  angle_col = 0        # 设置列标签为水平显示
)

p


