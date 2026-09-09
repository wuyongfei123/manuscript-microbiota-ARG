# 清空环境并设置工作目录
rm(list=ls())

# 加载必要的包
library(ggplot2)
library(readr)


# 加载数据
plot_data <- read_csv("LEfSe_plot_data.csv")

custom_colors <- c(
  "MAL" = "#58ae9a",
  "meat_type" = "#c9605f",  
  "dual_type" = "#646e9a", 
  "egg_type" = "#eab676" 
)


p <- ggplot(plot_data, aes(x = LDA, y = Taxa, fill = Group)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = custom_colors) +
  theme_bw() +
  labs(x = "LDA Score", y = "ARG Types")


p
