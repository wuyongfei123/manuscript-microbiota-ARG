# 清空环境
rm(list=ls())

# 加载必要的库
library(readxl)   
library(dplyr)    
library(ggplot2) 
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
  "GS" = 17, 
  "MS" = 17,  
  "DC" = 15,  
  "JC" = 15,  
  "IC" = 15,  
  "CC" = 16,  
  "CR" = 16,  
  "Feces" = 16 
)


# 读取数据
arg_abundance_richness_data <- read_excel("sample_ARG_abun_richness.csv")


# 设置 gut_locations 列为因子并指定顺序
final_data$gut_locations <- factor(
  final_data$gut_locations, 
  levels = c("GS", "MS", "DC", "JC", "IC", "CC", "CR", "Feces") 

# 绘制图表
p <- ggplot(final_data, aes(x = ARG_Count, y = Abundance_log10, color = gut_locations, shape = gut_locations)) +
  geom_point(alpha = 0.8, size = 2) + 
  scale_color_manual(values = custom_colors) +  
  scale_shape_manual(values = custom_shapes) +  
  theme_minimal() +  
  labs(
    x = "ARGs richness", 
    y = "ARGs abundance (log10)(TPM)",  
    color = "Gut Location",  
    shape = "Gut Location"  
  ) +
  scale_x_continuous(
    breaks = c(50, 100, 150, 200,250,300),  
    limits = c(0, NA)  
  ) +
  scale_y_continuous(
    breaks = c(1, 2, 3),  
    limits = c(0, NA)  
  ) +
  theme(
    legend.position = "right",  
    legend.text = element_text(size = 12,family = "Arial",face = "bold"),  
    legend.title = element_text(size = 12,family = "Arial", face = "bold"), 
    axis.text.x = element_text(size = 16, family = "Arial", face = "bold"),  
    axis.text.y = element_text(size = 16, family = "Arial", face = "bold"),  
    axis.title.x = element_text(size = 16, family = "Arial", face = "bold"),
    axis.title.y = element_text(size = 16, family = "Arial", face = "bold"),
    panel.grid = element_line(color = "grey90")  
  )
p


