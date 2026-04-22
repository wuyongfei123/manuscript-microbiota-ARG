# 清空工作环境
rm(list = ls())

# 加载必要的库
library(readxl)
library(UpSetR)
library(dplyr)
library(readr)

##upset图
# 设置文件路径
merged_df <- read_excel("ARG_gut_abundance.csv")


# 将ARGs丰度数据二值化
binary_matrix <- merged_df
binary_matrix[, -c(1, ncol(binary_matrix))] <- apply(
  merged_df[, -c(1, ncol(merged_df))], 2, function(x) ifelse(x > 0, 1, 0)
)

#Sample变列名
# 将第一列设置为行名
rownames(binary_matrix) <- binary_matrix[[1]]

# 删除第一列
binary_matrix <- binary_matrix[, -1]

#提取所有除最后一列（gut_locations）外的列
arg_columns <- colnames(binary_matrix)[1:(ncol(binary_matrix) - 1)]

#按肠段分组并计算每个ARG在该肠段中的出现次数
grouped_data <- binary_matrix %>%
  group_by(gut_locations) %>%
  summarise(across(all_of(arg_columns), sum))

#将每个ARG的出现次数大于等于3的定义为1，小于3的定义为0
updated_binary_result <- grouped_data %>%
  mutate(across(all_of(arg_columns), ~ ifelse(. >= 3, 1, 0)))

# 转置为 UpSet 格式
upset_data <- as.data.frame(t(updated_binary_result[, -1]))
colnames(upset_data) <- updated_binary_result$gut_locations

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

# 5. 绘制 UpSet 图 -----------------------------------------------------

# 定义集合颜色
set_colors <- c(
  "#5E5094",
  "#EFD19B",
  "#DC9FC8",
  "#7fabc4"
)

# 设置全局字体参数（在绘图前调用）
par(family = "Arial", font = 2)  # font=2 表示加粗字体

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
  
  # 关键修改：增大字体尺寸（此处数值已调大）
  text.scale = c(2.5, 2.5, 2.2, 2, 2.5, 2.5)  # 按顺序调整各部件字体大小
)

p

##双轴柱状图
# 清空工作环境
rm(list = ls())

# 加载必要的库
library(readxl)   # 读取Excel文件
library(dplyr)    # 数据处理
library(tidyr)    # 数据整理
library(ggplot2)  # 数据可视化
library(ggpubr)   # 多轴绘图

# 设置文件路径

# 5. 取前30个log10丰度最大的ARG
top_30_args_final_data <- read_csv("gut_shared_ARGs_abundance_count.csv")

# 创建一个修改后的主题，确保字体正确设置并添加灰色网格线
my_theme <- theme(
  text = element_text(family = "Arial", face = "bold", size = 14),  # 全局字体设置
  plot.title = element_text(size = 16, hjust = 0.5),  # 标题设置
  axis.title = element_text(size = 14),  # 坐标轴标题
  axis.text = element_text(size = 11, color = "black"),  # 坐标轴文本
  axis.title.y = element_text(color = "#000000"),
  axis.title.y.right = element_text(color = "#000000"),
  axis.text.x = element_text(angle = 45, hjust = 1, size = 11),
  panel.grid.major = element_line(color = "grey90", size = 0.2),  # 添加浅灰色主要网格线
  panel.grid.minor = element_blank(),  # 移除次要网格线
  legend.position = "none",
  panel.background = element_rect(fill = "white", colour = "white")  # 确保背景为纯白
)

# 创建图形
p_combined <- ggplot() +
  # 左侧柱子：Log10 Abundance
  geom_col(data = top_30_args_final_data, 
           aes(x = reorder(ARGs, -Log10_Abundance), y = Log10_Abundance), 
           fill = "#a6cfcd", width = 0.4, position = position_nudge(x = -0.2)) +
  # 右侧柱子：Occurrence Frequency（缩放）
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
  theme_minimal() +  # 使用简洁主题
  my_theme  # 应用自定义主题

# 打印图形
p_combined

