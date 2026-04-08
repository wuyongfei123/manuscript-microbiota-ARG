rm(list=ls())

# 加载必要的包
library(ggplot2)
library(readxl)
library(ggsignif)
library(dplyr)
library(tidyr)
library(openxlsx) 
library(readr)

tet_MGE <- read_csv("tet_ARG_MGE.csv")

# 手动调整因子顺序
mge_order <- c(
  "tnpA1133",
  "qacEdelta",
  "rep22",
  "rep7",
  "tniB",
  "IS91",
  "repUS12",
  "IS10",
  "tnpA10",
  "tnpA",
  "Tn916-family"
)

# 定义 Species 的颜色映射
custom_colors <- c(
  "tnpA" = "#a0bed2",
  "rep7" = "#c3a9c3",
  "Tn916-family" = "#d7c3b8",
  "qacEdelta" = "#f1a9ca",
  "IS10" = "#bec6a0",
  "repUS12" = "#ff7086",
  "IS91" = "#ccc06d",
  "tniB" = "#6A4D52",
  "tnpA10" = "#F3A361",
  "rep22" = "#e5dfeb",
  "tnpA1133" = "#FAD5DC"
)

ARG_type_order <- c("tet(M)", "tet(A)", "tet(45)", "tet(Q)", 
               "tet(B)", "tet(R)","tet(K)", "tet(O)", "tet(44)", "tet(S)", "tet(C)",
               "tet(Z)", "tet(W)", "tet(33)", "tet(59)", "tet(40)", "tet(D)",
               "tet(W/N/W)", "emrY", "emrK", "tet(O/32/O)")

# 设置ARG_type和MGE_subtype的因子顺序
tet_MGE <- tet_MGE %>%
  mutate(ARG_type = factor(ARG_type, levels = ARG_type_order), # 设置ARG_type的因子顺序为按累加和降序
         MGE_subtype = factor(MGE_subtype, levels = mge_order)) # 设置MGE的因子顺序



# 绘制百分比堆叠柱状图
p <- ggplot(data = tet_MGE, aes(x = ARG_type, y = count, fill = MGE_subtype)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = custom_colors) +     
  scale_y_continuous(labels = scales::percent_format()) + 
  theme_minimal() +                                
  labs(
    x = "ARG type", 
    y = "Proportion of MGE subtypes (%)", 
    fill = "MGE subtype"
  ) +
  theme(
    text = element_text(family = "Arial", face = "bold"), 
    axis.text.x = element_text(angle = 90, hjust = 1, size = 15),
    axis.text.y = element_text(size = 16),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    plot.title = element_text(hjust = 0.5),
    legend.position = "right",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13, face = "bold"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),  
    panel.background = element_blank(),
    plot.background = element_blank()
  ) +
  guides(fill = guide_legend(ncol = 1))            

# 显示图形
p
