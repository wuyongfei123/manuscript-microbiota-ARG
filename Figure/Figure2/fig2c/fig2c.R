# 清空环境
rm(list=ls())

library(dplyr)
library(networkD3)
library(readr)
library(htmlwidgets)

# 读取数据
Duck_ARG_risk_data <- read_csv("ARG_risk.csv")
merged_data <- Duck_ARG_risk_data[, c(2, 3)]

# 按Risk Level + Drug Class 统计数量
merged_data <- merged_data %>%
  group_by(Risk_Level, Drug_Class) %>%
  summarise(Count = n(), .groups = "drop") %>%
  filter(Count > 2)  # 只保留数量>2的

# 1. 创建节点
all_risks <- sort(unique(merged_data$Risk_Level))
all_drugs <- sort(unique(merged_data$Drug_Class))

nodes <- data.frame(
  name = c(all_risks, all_drugs),
  group = c(rep("Risk", length(all_risks)), rep("Drug", length(all_drugs)))
)

# 2. 创建连接
links <- merged_data %>%
  mutate(
    source = match(Risk_Level, nodes$name) - 1,
    target = match(Drug_Class, nodes$name) - 1, 
    link_group = paste0("from", gsub(" ", "", Risk_Level))
  )

# 颜色配置
color_scale <- JS('
  d3.scaleOrdinal()
    .domain([
      "Risk", "Drug",
      "fromRiskI", "fromRiskII",
      "fromRiskIII", "fromRiskIV", "fromRiskV"
    ])
    .range([
     "#385DA3", "#efa484",
      "#FF6B6B", "#9F8DB8",
      "#ABC8E5", "#96CEB4", "#FFEEAD"
    ])
')

# 绘制桑基图
p <- sankeyNetwork(
  Links = links,
  Nodes = nodes,
  Source = "source",
  Target = "target",
  Value = "Count",
  NodeID = "name",
  NodeGroup = "group",
  LinkGroup = "link_group",
  colourScale = color_scale,
  fontSize = 15,
  nodeWidth = 30,
  nodePadding = 20,
  margin = list(top=20, right=20, bottom=20, left=50),
  sinksRight = FALSE,
  iterations = 32,
  width = 900,
  height = 550
)

# 设置字体 Arial 加粗
p <- onRender(
  p,
  '
  function(el) {
    d3.select(el)
      .selectAll("text")
      .style("font-family", "Arial")
      .style("font-weight", "bold");
  }
  '
)


p