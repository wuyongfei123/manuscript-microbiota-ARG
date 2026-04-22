# 清空工作环境
rm(list = ls())

# 加载必要的库
library(readxl)   # 用于读取 Excel 文件
library(dplyr)    # 数据处理
library(ggplot2)  # 绘图
library(tidyr)
library(ggExtra)
library(readr)

# 设置文件路径
ARG_abundance <-read_excel("ARGs_Abundance.xlsx")

# 提取ARGs丰度列
args_data <- ARG_abundance[, -1]

# 二值化处理
args_binary <- as.data.frame(ifelse(args_data > 0, 1, 0))

# 按列累加
present_counts <- colSums(args_binary)

# 总样本数
total_samples <- nrow(args_binary)

# 计算每列的流行率
prevalence <- present_counts / total_samples

# 结果输出为数据框
prevalence_df <- data.frame(ARG = colnames(args_binary), Prevalence = prevalence,row.names = NULL)

# 转换 Prevalence 为百分比
prevalence_df$Prevalence_percent <- prevalence_df$Prevalence * 100

total_abundance <- colMeans(args_data)
abundance_df <- data.frame(ARG = colnames(args_data), Abundance = total_abundance, row.names = NULL)
abundance_df$Log2_Abundance <- log2(abundance_df$Abundance + 1e-6)
merged_data <- left_join(abundance_df,prevalence_df,by = "ARG")


# 绘图
p <- ggplot(merged_data, aes(x = Prevalence_percent, y = Log2_Abundance)) +
  geom_point(size = 2.5,alpha = 1, color = "black") +
  #scale_color_manual(values = colors, name = "ARG Drug Class") +
  geom_vline(xintercept = 10, color = "red", linetype = "solid", size = 1.5) +
  geom_vline(xintercept = 80, color = "red", linetype = "solid", size = 1.5) +
  labs(x = "Prevalence of ARGs",
       y = "Average Abundance of ARGs (Log2)") +
  theme_bw(base_size = 14) +
  theme(
    text = element_text(family = "Arial", face = "bold"),
    axis.title = element_text(family = "Arial", face = "bold"),
    axis.text = element_text(family = "Arial", face = "bold"),
    plot.title = element_text(family = "Arial", face = "bold", hjust = 0.5),
    panel.grid = element_blank()
  )

p
# 添加边缘密度分布图
p_margin <- ggMarginal(
  p,
  type = "density",
  margins = "both",
  size = 5,
  colour = "red",
  fill = "red",
  alpha = 0.3
)

p_margin


