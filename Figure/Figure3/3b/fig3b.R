# 清空环境
rm(list=ls())

# 加载必要的库
library(readxl)   # 用于读取 Excel 文件
library(dplyr)    # 数据处理
library(ggplot2)  # 绘图
library(tidyr)

# 自定义颜色
custom_colors <- c(
  "GS" = "#EE7424", 
  "MS" = "#5E5094",
  "DC" = "#E86976",
  "JC" = "#EFD19B",
  "IC" = "#997942",
  "CC" = "#779A4F",
  "CR" = "#DC9FC8",
  "Feces" = "#7fabc4"
)

# 自定义形状
custom_shapes <- c(
  "GS" = 17,  # 三角形
  "MS" = 17,  # 三角形
  "DC" = 15,  # 正方形
  "JC" = 15,  # 正方形
  "IC" = 15,  # 正方形
  "CC" = 16,  # 圆形
  "CR" = 16,  # 圆形
  "Feces" = 16 # 圆形
)


# 读取数据
arg_abundance_richness_data <- read_excel("sample_ARG_abun_richness.csv")


# 设置 gut_locations 列为因子并指定顺序
final_data$gut_locations <- factor(
  final_data$gut_locations, 
  levels = c("GS", "MS", "DC", "JC", "IC", "CC", "CR", "Feces") # 指定所需的顺序
)

# 绘制图表
p <- ggplot(final_data, aes(x = ARG_Count, y = Abundance_log10, color = gut_locations, shape = gut_locations)) +
  geom_point(alpha = 0.8, size = 2) +  # 散点图
  scale_color_manual(values = custom_colors) +  # 自定义颜色
  scale_shape_manual(values = custom_shapes) +  # 自定义形状
  theme_minimal() +  # 简洁主题
  labs(
    x = "ARGs richness",  # X轴标签
    y = "ARGs abundance (log10)(TPM)",  # Y轴标签
    color = "Gut Location",  # 图例标题
    shape = "Gut Location"  # 图例标题（形状）
  ) +
  scale_x_continuous(
    breaks = c(50, 100, 150, 200,250,300),  # 自定义X轴刻度，不显示0
    limits = c(0, NA)  # 确保X轴从0开始，但不显示刻度
  ) +
  scale_y_continuous(
    breaks = c(1, 2, 3),  # 自定义Y轴刻度，不显示0
    limits = c(0, NA)  # 确保Y轴从0开始，但不显示刻度
  ) +
  theme(
    legend.position = "right",  # 图例放在右侧
    legend.text = element_text(size = 12,family = "Arial",face = "bold"),  # 图例文字大小
    legend.title = element_text(size = 12,family = "Arial", face = "bold"), # 图例标题大小
    axis.text.x = element_text(size = 16, family = "Arial", face = "bold"),  # 横坐标数字字体：宋体加粗
    axis.text.y = element_text(size = 16, family = "Arial", face = "bold"),  # 纵坐标数字字体：宋体加粗
    axis.title.x = element_text(size = 16, family = "Arial", face = "bold"), # 横坐标标签：宋体加粗
    axis.title.y = element_text(size = 16, family = "Arial", face = "bold"), # 纵坐标标签：宋体加粗
    panel.grid = element_line(color = "grey90")  # 网格线颜色
  )
p


