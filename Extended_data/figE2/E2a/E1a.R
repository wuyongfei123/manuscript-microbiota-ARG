rm(list = ls())
library(ggplot2)
library(ggforce)
library(readr)
library(dplyr)

MGE_data <- read_csv("D:/2025_1162_duck_args/文章/数据和代码/source_data_script/Extended_data/figS1/MGE_ARG_count.csv")


##内圈
# 计算百分比
MGE_data$percentage <- MGE_data$count / sum(MGE_data$count) * 100

custom_order <- c("tnpA", "transposase_other", "Tn916", "qacEdelta", "rep7", 
                  "repUS12", "plasmid_other", "intI1", "integrase_other","IS91", "IS10", "insertion_element_other",
                  "tniB", "tniA", "istB")


# 颜色映射
colors <- c(
  "tnpA" = "#a0bed2",
  "rep7" = "#c3a9c3",
  "Tn916" = "#d7c3b8",
  "qacEdelta" = "#f1a9ca",
  "IS10" = "#bec6a0",
  "transposase_other" = "#B0ACAB",
  "intI1" = "#f5C67d",
  "plasmid_other" = "#B0ACAB",
  "repUS12" = "#ff7086",
  "IS91" = "#ccc06d",
  "tniB" = "#6A4D52",
  "tniA" = "#a77046",
  "integrase_other" = "#B0ACAB",
  "insertion_element_other" = "#B0ACAB",
  "istB" = "#1D7977"
)

# 确保MGE_symbol为因子并设置水平顺序
MGE_data$Renamed_MGE_subtype <- factor(MGE_data$Renamed_MGE_subtype, levels = custom_order)

# 按因子水平重新排序数据行（使绘图顺序匹配custom_order）
MGE_data <- MGE_data[order(MGE_data$Renamed_MGE_subtype), ]

# 生成环形图
p2 <- ggplot() + 
  geom_arc_bar(
    data = MGE_data,
    stat = "pie",
    aes(
      x0 = 0, 
      y0 = 0, 
      r0 = 0,
      r = 2,
      amount = percentage,
      fill = Renamed_MGE_subtype  
    ),
    color = "white",
    size = 0.5
  ) +
  scale_fill_manual(
    values = colors,
    breaks = custom_order,  
    drop = FALSE            
  ) +
  coord_equal() +
  theme_void() +
  theme(
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
  guides(fill = guide_legend(ncol = 1, title = "MGE subtype"))


p2


##外圈
MGE_class_data <- MGE_data[, c(1,3)]
MGE_class_data <- MGE_class_data %>%
  group_by(MGE_Type)%>%
  summarise(count = sum(count))
# 计算百分比
MGE_class_data$percentage <- MGE_class_data$count / sum(MGE_class_data$count) * 100

custom_order <- c(  "transposase",
                    "Tn916",
                    "qacEdelta",
                    "plasmid",
                    "integrase",
                    "insertion_element",
                    "tniB", "tniA", "istB"
)


# 颜色映射
colors <- c(
  "transposase" = "#4175b6",
  "Tn916"= "#db6c32",
  "qacEdelta" = "#d35b79",
  "plasmid"= "#643178",
  "integrase" = "#fac356",
  "insertion_element" = "#abca73",
  "tniB" = "#6A4D52",
  "tniA" = "#a77046",
  "istB" = "#1D7977"
)

# 确保MGE_symbol为因子并设置水平顺序
MGE_class_data$MGE_Type <- factor(MGE_class_data$MGE_Type, levels = custom_order)

# 按因子水平重新排序数据行（使绘图顺序匹配custom_order）
MGE_class_data <- MGE_class_data[order(MGE_class_data$MGE_Type), ]


# 生成环形图
p1 <- ggplot() + 
  geom_arc_bar(
    data = MGE_class_data,
    stat = "pie",
    aes(
      x0 = 0, 
      y0 = 0, 
      r0 = 1,
      r = 2,
      amount = percentage,
      fill = MGE_Type  # 因子水平已控制顺序
    ),
    color = "white",
    size = 0.5
  ) +
  scale_fill_manual(
    values = colors,
    breaks = custom_order,  # 强制图例按指定顺序显示
    drop = FALSE            # 确保图例显示所有类别（即使数据缺失）
  ) +
  coord_equal() +
  theme_void() +
  theme(
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
  guides(fill = guide_legend(ncol = 1, title = "MGE Type"))


p1
