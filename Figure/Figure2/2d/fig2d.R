# 清空环境
rm(list=ls())

library(dplyr)
library(readr)
library(tidyverse)
library(circlize)  

# 读取数据
ARG_risk_data <- read_csv("ARG_risk(human+duck).csv")
ARG_risk_data <- na.omit(ARG_risk_data)

# 创建风险等级转换矩阵
matrix_data <- ARG_risk_data %>%
  count(Duck_Risk_Level, Human_Risk_Level) %>%
  # 修改风险等级名称格式
  mutate(
    Duck_Risk_Level = factor(
      paste0("Duck ", Duck_Risk_Level),
      levels = paste0("Duck ", c("Risk I", "Risk II", "Risk III", "Risk IV", "Risk V"))
    ),
    Human_Risk_Level = factor(
      paste0("Human ", Human_Risk_Level),
      levels = paste0("Human ", c("Risk I", "Risk II", "Risk III", "Risk IV", "Risk V"))
    )
  ) %>%
  # 构建矩阵格式
  pivot_wider(
    names_from = Human_Risk_Level,
    values_from = n,
    values_fill = 0
  ) %>%
  column_to_rownames("Duck_Risk_Level") %>%
  as.matrix()

# 按照您的要求设置自定义颜色
duck_colors <- c(
  "Duck Risk I" = "#FF6B6B",     # 浅红色
  "Duck Risk II" = "#9F8DB8",    # 紫色
  "Duck Risk III" = "#ABC8E5",   # 浅蓝色
  "Duck Risk IV" = "#96CEB4",    # 薄荷绿
  "Duck Risk V" = "#FFEEAD"      # 浅黄色
)

human_colors <- c(
  "Human Risk I" = "#d32920",    # 橙黄色
  "Human Risk II" = "#7a57be",   # 深紫色
  "Human Risk III" = "#3c79b4",  # 蓝色
  "Human Risk IV" = "#6fc24c",   # 绿色
  "Human Risk V" = "#efc54d"     # 金黄色
)

# 合并所有颜色
all_colors <- c(duck_colors, human_colors)

# 创建绘图参数
par(mar = c(1, 1, 3, 1), cex.main = 1.5)  # 设置边距和标题大小

# 绘制简化弦图（无箭头）
chordDiagram(
  x = matrix_data,
  grid.col = all_colors,
  annotationTrack = c("name", "grid"),
  annotationTrackHeight = c(0.05, 0.08),
  big.gap = 10,  # 增加两组之间的间隙
  link.sort = TRUE,
  transparency = 0.2  # 增加连接线透明度使底层网格可见
)


# 添加自定义标签（加粗显示）
circos.track(track.index = 1, panel.fun = function(x, y) {
  sector.index = get.cell.meta.data("sector.index")
  xlim = get.cell.meta.data("xlim")
  ylim = get.cell.meta.data("ylim")
  
  # 直接绘制加粗文本
  circos.text(mean(xlim), mean(ylim), sector.index, 
              facing = "bending.inside", 
              cex = 1.0,
              adj = c(0.5, 0.5),
              col = "black",
              font = 1)
}, bg.border = NA)



