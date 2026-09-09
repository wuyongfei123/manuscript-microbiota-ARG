# 清空工作环境
rm(list = ls())

# 加载必要的库
library(readxl)
library(UpSetR)
library(dplyr)
library(readr)

##upset图
upset_data <- read_csv("upset_data.csv")

upset_data <- as.data.frame(upset_data)
rownames(upset_data) <- upset_data[, 1]  
upset_data <- upset_data[, -1]           

# 确保列顺序
desired_order <- c("Stomach", "small_intestine", "large_intestine", "Feces")
if (all(desired_order %in% colnames(upset_data))) {
  upset_data <- upset_data[, desired_order]
} else {
  stop("Error: Not all desired columns are present in the data.")
}

# 转换为列表格式
data_list <- apply(upset_data, 2, function(x) rownames(upset_data)[x == 1])

# 检查数据
print(data_list)

# 5. 绘制 UpSet 图 

# 定义集合颜色
set_colors <- c(
  "#5E5094",
  "#EFD19B",
  "#DC9FC8",
  "#7fabc4"
)

# 设置全局字体参数
par(family = "Arial", font = 2)  

# 创建UpSet图
p <- upset(
  fromList(data_list),
  nintersects = NA,
  sets = desired_order,
  keep.order = TRUE,
  mainbar.y.label = "Shared ARGs Count",
  sets.x.label = "ARGs Count",
  order.by = "freq",
  sets.bar.color = set_colors,
  main.bar.color = "#7e594d",
  matrix.color = "#c7ab7c",
  point.size = 3,
  line.size = 1,
  text.scale = c(2.5, 2.5, 2.2, 2, 2.5, 2.5)  
)

p

##双轴柱状图
# 清空工作环境
rm(list = ls())

# 加载必要的库
library(readxl)   
library(dplyr)    
library(tidyr)    
library(ggplot2)  
library(ggpubr)   

#取前30个log10丰度最大的ARG
top_30_args_final_data <- read_csv("gut_shared_ARGs_abundance_count.csv")

my_theme <- theme(
  text = element_text(family = "Arial", face = "bold", size = 14),  
  plot.title = element_text(size = 16, hjust = 0.5),  
  axis.title = element_text(size = 14),  
  axis.text = element_text(size = 11, color = "black"), 
  axis.title.y = element_text(color = "#000000"),
  axis.title.y.right = element_text(color = "#000000"),
  axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
  panel.grid.major = element_line(color = "grey90", size = 0.2),  
  panel.grid.minor = element_blank(),  
  legend.position = "none",
  panel.background = element_rect(fill = "white", colour = "white")  
)

# 创建图形
p_combined <- ggplot() +
  # 左侧柱子：Log10 Abundance
  geom_col(data = top_30_args_final_data, 
           aes(x = reorder(ARGs, -Log10_Abundance), y = Log10_Abundance), 
           fill = "#a6cfcd", width = 0.4, position = position_nudge(x = -0.2)) +
  # 右侧柱子：Occurrence Frequency
  geom_col(data = top_30_args_final_data, 
           aes(x = reorder(ARGs, -Log10_Abundance), y = Occurrence_Frequency / 300), 
           fill = "#efe59a", width = 0.4, position = position_nudge(x = 0.2)) +
  # 设置双Y轴
  scale_y_continuous(
    name = "Shared ARGs Abundance(Log10)(TPM)",
    sec.axis = sec_axis(~ . * 300, name = "Shared ARGs Count")
  ) +
  labs(
    #title = "Top 30 Shared ARGs in 4 Gut Locations",
    x = "ARGs Type"
  ) +
  theme_minimal() +  #
  my_theme  

p_combined

