# 清空环境并设置工作目录
rm(list=ls())

# 加载必要的包
library(ggplot2)
library(readr)


# 加载数据
combined_data <- read_csv("combined_data.csv")
final_letter_df <- read_csv("final_letter_df.csv")


# 箱线图
p <- ggplot(combined_data, aes(x = Type, y = Distance, fill = Type)) +
  geom_boxplot(width = 0.6, outlier.shape = 21) +
  scale_fill_manual(values = c("#d62728", "#2ca02c", "#1f77b4", "#ff7f0e", "#9467bd",
                               "#d781b0", "#9a6c5c", "#72c5d9", "#7e9a5c", "#BE9E33")) +
  labs(
    x = "Application",
    y = "Distance(Bray-Curtis)"
  ) +
  geom_text(
    data = final_letter_df, 
    aes(x = Type, y = max(combined_data$Distance) * 1.3, label = letter), 
    size = 6,
    family = "Arial",  
  ) +
  theme_bw(base_size = 14) +
  theme(
    # 移除网格线
    panel.grid.major = element_blank(),  
    panel.grid.minor = element_blank(),  
    
    # 文本设置为Arial
    text = element_text(family = "Arial"),  
    axis.text.x = element_text(angle = 45, hjust = 1, size = rel(1.0)),  
    axis.text.y = element_text(size = rel(1.0)),  
    axis.title.x = element_text(size = rel(1.1)),  
    axis.title.y = element_text(size = rel(1.1)),  
    
    # 其他设置
    panel.border = element_rect(size = 0.7), 
    plot.title = element_text(hjust = 0.5),
    legend.position = "none"
  )


p