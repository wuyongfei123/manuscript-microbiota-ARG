rm(list = ls())

# 加载所需的库
library(readr)  
library(readxl)  
library(dplyr)  
library(tidyr)
library(tidyverse)
library(networkD3)

merged_data <- read_csv("ARG_MGE_family_gut.csv")

#node建立
nodes <- data.frame(name = unique(c(as.character(merged_data$ARG_type),
                                    as.character(merged_data$Family), 
                                    as.character(merged_data$MGE_subtype),
                                    as.character(merged_data$gut_locations))))
nodes$group <- ifelse(nodes$name %in% merged_data$ARG_type, "ARG", 
                      ifelse(nodes$name %in% merged_data$Family, "Family",
                             ifelse(nodes$name %in% merged_data$MGE_subtype, "MGE_subtype", "gut_locations")))


#link建立
links <- merged_data %>%
  group_by(ARG_type, MGE_subtype) %>%
  summarise(Count = sum(Count), .groups = 'drop') %>%
  mutate(ARG_type = as.numeric(factor(ARG_type, levels = nodes$name)) - 1,
         MGE_subtype = as.numeric(factor(MGE_subtype, levels = nodes$name)) - 1) %>%
  select(source = ARG_type, target = MGE_subtype, value = Count) %>%

  bind_rows(
    merged_data %>%
      group_by(MGE_subtype, Family) %>%
      summarise(Count = sum(Count), .groups = 'drop') %>%
      mutate(MGE_subtype = as.numeric(factor(MGE_subtype, levels = nodes$name)) - 1,
             Family = as.numeric(factor(Family, levels = nodes$name)) - 1) %>%
      select(source = MGE_subtype, target = Family, value = Count)
  ) %>%
  
  bind_rows(
    merged_data %>%
      group_by(Family, gut_locations) %>%
      summarise(Count = sum(Count), .groups = 'drop') %>%
      mutate(Family = as.numeric(factor(Family, levels = nodes$name)) - 1,
             gut_locations = as.numeric(factor(gut_locations, levels = nodes$name)) - 1) %>%
      select(source = Family, target = gut_locations, value = Count)
  )
# 生成颜色比例尺，并使用 JS() 函数将其转换为 JavaScript 对象
color_scale <- 'd3.scaleOrdinal()
                  .domain(["ARG", "MGE_subtype","Family", "gut_locations"])
                  .range(["#ee9293", "#c2d3e0", "#d1d5ba","#b7a6c7"])'
links <- as.data.frame(links)
# 创建 Sankey 图
p <- sankeyNetwork(
  Links = links, 
  Nodes = nodes, 
  Source = "source", 
  Target = "target", 
  Value = "value", 
  NodeID = "name", 
  NodeGroup = "group",   
  colourScale = color_scale,  
  width = 1000, 
  height = 800,
  fontSize = 14,
  nodePadding = 14
)

# 使用自定义的JavaScript代码来设置字体粗度
htmlwidgets::onRender(p, '
  function(el, x) {
    // 设置节点文本为常规粗细
    d3.selectAll(".node text").attr("font-weight", "normal");
    // 如果需要设置链接文本（如果有），取消下一行注释
    // d3.selectAll(".link text").attr("font-weight", "normal");
  }
')
# 显示 Sankey 图
p
