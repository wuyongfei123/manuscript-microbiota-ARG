rm(list = ls())

library(readr)
library(readxl)
library(ggplot2)
library(dplyr)
library(scales)  # 用于百分比格式
library(ggforce)

Drug_class_abundance <- read_excel("Drug_ARGs_abundance.xlsx")
Drug_class_count <- read_excel("Drug_ARGs_number.xlsx")

#丰度
# 计算百分比
Drug_class_abundance$percentage <- Drug_class_abundance$total_abundance / sum(Drug_class_abundance$total_abundance) * 100

# 设置 Drug_ARGs 为因子并排序
Drug_class_abundance$Drug_Class <- factor(Drug_class_abundance$Drug_Class, levels = unique(Drug_class_abundance$Drug_Class))

# 定义固定颜色
colors <- c(
  "glycopeptide" = "#DC9FC8",
  "nitroimidazole" = "#C1E7BD",
  "tetracycline" = "#9EC9EB",
  "Others" = "#B0ACAB",
  "disinfecting agents and antiseptics" = "#FCE693",
  "aminoglycoside" ="#ACD68E",
  "macrolide" =  "#8DA0CB",
  "phenicol" =  "#dc9fa9",
  "M-L-S" = "#D8C4E9", 
  "lincosamide" = "#89D1CE" 
)

p1 <- ggplot() + 
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    legend.position = "right",  
    legend.title = element_text(
      family = "Arial", 
      face = "bold", 
      size = 12
    ),
    legend.text = element_text(
      family = "Arial", 
      size = 10
    )
  ) +
  labs(fill = "ARG Drug Class") +
  xlab("") + ylab('') +
  scale_fill_manual(values = colors) +
  geom_arc_bar(
    data = Drug_class_abundance,
    stat = "pie",
    aes(
      x0 = 0, y0 = 0, 
      r0 = 1, r = 2, 
      amount = percentage,
      fill = Drug_Class
    )
  ) +
  guides(fill = guide_legend(ncol = 1, byrow = TRUE))  # 分两行显示

p1




#数目
# 计算百分比
Drug_class_count$percentage <- Drug_class_count$Count / sum(Drug_class_count$Count) * 100

# 设置 Drug_ARGs 为因子并排序
Drug_class_count$Drug_Class <- factor(Drug_class_count$Renamed_Drug_Class, levels = unique(Drug_class_count$Renamed_Drug_Class))

# 定义固定颜色
colors <- c(
  "glycopeptide" = "#DC9FC8",
  "nitroimidazole" = "#C1E7BD",
  "tetracycline" = "#9EC9EB",
  "Others" = "#B0ACAB",
  "disinfecting agents and antiseptics" = "#FCE693",
  "aminoglycoside" ="#ACD68E",
  "macrolide" =  "#8DA0CB",
  "phenicol" =  "#dc9fa9",
  "M-L-S" = "#D8C4E9", 
  "lincosamide" = "#89D1CE" ,
  "F-T" = "#F9B562",
  "T-O-P" = "#C8B291",
  "phosphonic acid" = "#f07874"
)

p2 <- ggplot() + 
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.ticks = element_blank(),
    axis.text = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    legend.position = "right",  
    legend.title = element_text(
      family = "Arial", 
      face = "bold", 
      size = 12
    ),
    legend.text = element_text(
      family = "Arial", 
      size = 10
    )
  ) +
  labs(fill = "ARG Drug Class") +
  xlab("") + ylab('') +
  scale_fill_manual(values = colors) +
  geom_arc_bar(
    data = Drug_class_count,
    stat = "pie",
    aes(
      x0 = 0, y0 = 0, 
      r0 = 1, r = 2, 
      amount = percentage,
      fill = Renamed_Drug_Class
    )
  ) +
  guides(fill = guide_legend(ncol = 1, byrow = TRUE))  

p2

