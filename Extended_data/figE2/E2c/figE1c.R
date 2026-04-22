rm(list = ls())

# 加载所需的库
library(readr)  
library(readxl)  
library(dplyr)  
library(tidyr)
library(tidyverse)
library(networkD3)

ARG_MGE_bacteria_data <- read_csv("ARG_MGE_species.csv")

ARG_MGE_bacteria_data <- ARG_MGE_bacteria_data %>%
  filter(species != "unknown")


ARG_MGE_bacteria_data_filtered <- ARG_MGE_bacteria_data[, c(-4)]

#去重
ARG_MGE_bacteria_data_deduplicated <- ARG_MGE_bacteria_data_filtered %>% 
  distinct(ARG, MGE_subtype,species, .keep_all = TRUE)


ARG_MGE_bacteria_data_filtered2 <- ARG_MGE_bacteria_data_deduplicated %>%
  group_by(ARG,MGE_subtype) %>%
  summarise(Count = n()) %>%
  ungroup()

ARG_MGE_bacteria_data_filtered2 <- ARG_MGE_bacteria_data_filtered2 %>%
  filter(Count > 1)

#获取filtered2中的唯一ARG-MGE组合
filtered_keys <- ARG_MGE_bacteria_data_filtered2 %>%
  select(ARG, MGE_subtype) %>%
  distinct()

#筛选原始数据中匹配的组合
matched_data <- ARG_MGE_bacteria_data %>%
  semi_join(filtered_keys, by = c("ARG", "MGE_subtype"))

#肠道信息通过excel合并
ARG_MGE_bacteria_gut_data <- read_csv("ARG_MGE_genus_gut.csv")

#相同肠段相同ARG相同MGE相同物种计数
ARG_MGE_bacteria_gut_data <- ARG_MGE_bacteria_gut_data %>%
  group_by(ARG,MGE_subtype,species,gut_locations) %>%
  summarise(Count = n()) %>%
  ungroup()

ARG_MGE_bacteria_gut_data <- ARG_MGE_bacteria_gut_data  %>%
  filter(Count > 20)

merged_data <- ARG_MGE_bacteria_gut_data

#node建立
nodes <- data.frame(name = unique(c(as.character(merged_data$ARG),
                                    as.character(merged_data$species), 
                                    as.character(merged_data$MGE_subtype),
                                    as.character(merged_data$gut_locations))))
nodes$group <- ifelse(nodes$name %in% merged_data$ARG, "ARG", 
                      ifelse(nodes$name %in% merged_data$species, "species",
                                    ifelse(nodes$name %in% merged_data$MGE_subtype, "MGE_subtype", "gut_locations")))


#link建立
links <- merged_data %>%
  # 第一组：MGE_subtype 和 ARG
  group_by(MGE_subtype, ARG) %>%
  summarise(Count = sum(Count), .groups = 'drop') %>%
  mutate(MGE_subtype = as.numeric(factor(MGE_subtype, levels = nodes$name)) - 1,
         ARG = as.numeric(factor(ARG, levels = nodes$name)) - 1) %>%
  select(source = MGE_subtype, target = ARG, value = Count) %>%
  
  # 第二组：ARG 和 species （直接跳过 genus）
  bind_rows(
    merged_data %>%
      group_by(ARG, species) %>%
      summarise(Count = sum(Count), .groups = 'drop') %>%
      mutate(ARG = as.numeric(factor(ARG, levels = nodes$name)) - 1,
             species = as.numeric(factor(species, levels = nodes$name)) - 1) %>%
      select(source = ARG, target = species, value = Count)
  ) %>%
  
  # 第三组：species 和 gut_locations
  bind_rows(
    merged_data %>%
      group_by(species, gut_locations) %>%
      summarise(Count = sum(Count), .groups = 'drop') %>%
      mutate(species = as.numeric(factor(species, levels = nodes$name)) - 1,
             gut_locations = as.numeric(factor(gut_locations, levels = nodes$name)) - 1) %>%
      select(source = species, target = gut_locations, value = Count)
  )
# 生成颜色比例尺，并使用 JS() 函数将其转换为 JavaScript 对象
color_scale <- 'd3.scaleOrdinal()
                  .domain(["ARG", "MGE_subtype","species", "gut_locations"])
                  .range(["#ee9293", "#c2d3e0", "#d1d5ba","#f5c0d7"])'
# 确保链接数据是普通数据框
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
  width = 900, 
  height = 1300,
  fontSize = 14,
  nodePadding = 14
)

# 使用自定义的JavaScript代码来设置字体粗度
htmlwidgets::onRender(p, '
  function(el, x) {
    // 加粗节点文本
    d3.selectAll(".node text").attr("font-weight", "bold");
    // 如果需要加粗链接文本（如果有），取消下一行注释
    // d3.selectAll(".link text").attr("font-weight", "bold");
  }
')
# 显示 Sankey 图
p
