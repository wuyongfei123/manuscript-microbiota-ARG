rm(list=ls())

# 加载必要的包
library(dplyr)
library(readr)
library(ggraph)
library(igraph)
library(tidyverse)
# 读取数据
ARG_MGE_node <- read_csv("ARG-MGE-node-top20.csv")

# 在节点数据中创建新的着色列
ARG_MGE_node$color_category <- ifelse(
  ARG_MGE_node$leaf,
  as.character(ARG_MGE_node$MGE_subtype),
  "Parent"
)

# 创建完整的颜色映射（包含父节点颜色）
full_colors <- c(
  "Tn6994" = "#a0bed2",
  "Tn5253" = "#c3a9c3",
  "ISCpe8" = "#d7c3b8",
  "Tn6079" = "#f1a9ca",
  "ISSag10" = "#bec6a0",
  "Tn6248" = "#0d243e",
  "Tn6261" = "#ed8687",
  "Tn4351" = "#eb573c",
  "Tn1116" = "#95484B",
  "Tn4451" = "#81a5d7",
  "repA(pEF418)" = "#e36c90",
  "Tn558" = "#EEE7C2",
  "Tn2" = "#cc8264",
  "TnAs3" = "#FAD5DC",
  "Tn6218" = "#F3A361",
  "Tn2424" = "#f5C67d",
  "Tn6003" = "#B5A9CE",
  "repB(pLFE1)" = "#e5dfeb",
  "rep(pSGG1)" = "#90b9b3",
  "ISCco2" = "#c995ea",
  "Tn6084" = "#ccc06d",
  "Tn5086" = "#8FBC8F",
  "Tn3" = "#a77046",
  "Tn4453a" = "#137ea0",
  "Tn917" = "#7BCDDF",
  "Tn1332" = "#51999f",
  "Tn6031" = "#4a4f7e",
  "Tn6301" = "#81989b",
  "Tn5045" = "#b5af8b",
  "Tn6072" = "#2E8B57",
  "Tn5393" = "#4682B4",
  "rep(pKH13)" = "#976793",
  "IS942" = "#d1d1ca",
  "IS4351" = "#DAA520",
  "Tn4551" = "#6A4D52",
  "repE(pTEF1)" = "#879e48",
  "Tn2009" = "#FDE5D9",
  "ICE" = "#2A2A2A",
  "Others" = "#B0ACAB",
  "Other" = "#ffffff"
  #"Parent" = "#EAE5E3"  # 为父节点添加特定颜色
  #"Parent" = "#e9f4f4"
)

# 构建igraph对象（需明确指定节点属性）
mygraph <- graph_from_data_frame(edges, vertices = ARG_MGE_node)

# 创建隐藏节点的颜色类别标记
ARG_MGE_node$plot_color <- ifelse(
  ARG_MGE_node$size >= 5 | !ARG_MGE_node$leaf,  # 显示条件：size>=5 或 是父节点
  as.character(ARG_MGE_node$color_category),    # 真实颜色类型
  "__HIDDEN__"                                   # 隐藏标记
)

# 创建只包含可见类型的颜色映射
visible_colors <- ARG_MGE_node %>% 
  filter(plot_color != "__HIDDEN__") %>%
  distinct(color_category) %>%
  pull(color_category)

# 提取这些可见类型的颜色
filtered_colors <- full_colors[names(full_colors) %in% visible_colors]

# 构建igraph对象
mygraph <- graph_from_data_frame(edges, vertices = ARG_MGE_node)

# 绘图
p <- ggraph(mygraph, layout = 'circlepack', weight = size) + 
  coord_fixed(ratio = 1) +  # 固定纵横比
  
  # 1. 为所有节点绘制边框
  geom_node_circle(aes(filter = !leaf), colour = '#b7cbcc', alpha = 0.3, size = 0.2, aspect.ratio = 1) + 
  
  # 2. 为父节点绘制统一背景
  geom_node_circle(
    aes(filter = !leaf), 
    fill = "#ffeae5",  
    colour = NA,      
    alpha = 0.3,
    aspect.ratio = 1
  ) + 
  
  # 3. 只为非隐藏的叶节点绘制颜色
  geom_node_circle(
    aes(filter = plot_color != "__HIDDEN__", fill = plot_color),
    colour = NA,      
    alpha = 0.7,
    aspect.ratio = 1
  ) + 
  
  # 4. 标签
  geom_node_label(
    aes(label = ARG_type, filter = !leaf, size = size),  
    fontface = "bold",
    family = "Arial",
    label.padding = unit(0.2, "lines"),
    label.r = unit(0.05, "lines"),
    color = "#111111",
    label.size = 0,
    fill = NA
  ) +
  
  # 5. 颜色映射和主题 - 只包含可见的颜色类型
  theme_void() +
  scale_fill_manual(
    name = "MGE Type",
    values = c(filtered_colors, "__HIDDEN__" = NA),  # 隐藏节点无色
    breaks = setdiff(names(filtered_colors), "Parent"),
    na.value = NA,  # 确保隐藏节点不绘制
    drop = TRUE     # 自动隐藏未使用的图例
  ) +
  guides(fill = guide_legend(
    override.aes = list(size = 4, alpha = 0.85),
    nrow = 3
  )) +
  theme(
    legend.position = "bottom",
    legend.margin = margin(10, 0, 5, 0),
    text = element_text(family = "Arial", face = "bold"),
    legend.text = element_text(family = "Arial", face = "bold", size = 11),
    legend.title = element_text(family = "Arial", face = "bold", size = 12)
  )
p


