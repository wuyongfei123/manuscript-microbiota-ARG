rm(list=ls())
# 加载必要的库
library(ggplot2)
library(reshape2)
library(dplyr)
library(readr)

# 读取数据
Duck_Human_ARG_data <- read_csv("Duck_Human_high_risk_ARG.csv")


# 提取数值矩阵
value_matrix <- Duck_Human_ARG_data[, -1]  
# Z-score标准化
value_scaled <- scale(value_matrix)
combined_scaled <- as.data.frame(value_scaled)
combined_scaled$ARG_type <- Duck_Human_ARG_data$ARG_type

arg_order <- unique(combined_scaled$ARG_type)
arg_order <- rev(arg_order)
combined_scaled$ARG_type <- factor(combined_scaled$ARG_type, levels = arg_order)

# 转换成长格式
combined_melt <- melt(combined_scaled, id.vars = "ARG_type")
colnames(combined_melt) <- c("ARG_type", "Indicator", "Zscore")

# 绘图
p1 <- ggplot(combined_melt, aes(x = Indicator, y = ARG_type)) +
  geom_point(aes(color = Zscore), size = 5, alpha = 0.85) +
  scale_color_gradientn(
    colors = c("#2166AC", "#92C5DE", "#F7F7F7", "#F4A582", "#B2182B"),
    values = c(0, 0.25, 0.5, 0.75, 1),
    name = "Z-score",
    limits = c(-2.5, 4.5),  
    oob = scales::squish 
  ) +
  labs(x = "Indicator", y = "ARG type") +
  theme_minimal(base_size = 11) +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
    axis.text.y = element_text(size = 8),
    axis.title = element_text(face = "plain"),
    panel.grid.major = element_line(color = "#E0E0E0", linewidth = 0.3),
    panel.grid.minor = element_blank(),
    legend.position = "right",
    legend.title = element_text(size = 9),
    legend.text = element_text(size = 8),
    plot.background = element_rect(fill = "white", color = NA),
    aspect.ratio = 1.5
  )

p1
