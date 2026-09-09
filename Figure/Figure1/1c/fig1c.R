# 清空工作环境
rm(list = ls())

# 加载必要的库  
library(ggplot2) 
library(ggExtra)
library(readr)

# 设置文件路径
merged_data <-read_excel("ARG-abundance-prevalence.csv")

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


