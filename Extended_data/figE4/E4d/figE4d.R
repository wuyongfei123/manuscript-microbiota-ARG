rm(list=ls())

# 加载必要的包
library(readr)

merged_data <- read_csv("tetracycline_gut_abundance.csv")

# 设置行名为第一列
merged_data <- column_to_rownames(merged_data, var = "ARG")
# merged_data转为数值型矩阵
merged_data_matrix <- as.matrix(merged_data)

#画图
library(pheatmap)
# 自定义颜色
custom_colors <- colorRampPalette(c("#3D82BF", "white", "#F37C2E"))(100)

# 确保列名顺序
desired_order <- c("Stomach", "small_intestine", "large_intestine", "Feces")
merged_data_matrix <- merged_data_matrix[, desired_order]

# 绘制热图
p <- pheatmap(
  merged_data_matrix, 
  color = custom_colors,  
  cluster_rows = TRUE,  
  cluster_cols = FALSE,   
  show_rownames = TRUE,
  show_colnames = TRUE,
  fontfamily = "Arial",
  fontsize_row = 10,  
  fontsize_col = 15,  
  scale = "row",   
  angle_col = 0       
)
