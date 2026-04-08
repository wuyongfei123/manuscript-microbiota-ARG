rm(list = ls())

library(readr)
library(readxl)
library(tidyr)
library(dbplyr)
library(tidyverse)

MGE_ARG_data <- read_csv("ARG_Drug_MGE_count.csv")

result2 <- MGE_ARG_data %>%
  # 将含有分号的药物类别重命名为"Double-Drug"
  mutate(Drug_Class = ifelse(grepl(";", Drug_Class), 
                             "Double-Drug", 
                             Drug_Class)) %>%
  # 按新的药物类别分组
  group_by(Drug_Class, Renamed_MGE_subtype_top10) %>%
  # 计算每组的MGE_symbol_count总和
  summarize(total_Count = sum(Count)) %>%
  # 按计数降序排列
  arrange(desc(total_Count))


# 加载所需的库
library(ggplot2)
library(dplyr)

# 颜色映射
colors <- c(
  "tnpA" = "#a0bed2",
  "rep7" = "#c3a9c3",
  "Tn916" = "#d7c3b8",
  "qacEdelta" = "#f1a9ca",
  "IS10" = "#bec6a0",
  "intI1" = "#f5C67d",
  "Others" = "#B0ACAB",
  "repUS12" = "#ff7086",
  "IS91" = "#ccc06d",
  "tniB" = "#6A4D52",
  "tnpA10" = "#F3A361"
)



# 手动调整因子顺序
desired_order <- c(
  "tnpA",
  "Tn916",
  "qacEdelta",
  "rep7",
  "IS10",
  "tnpA10",
  "intI1",
  "repUS12",
  "IS91",
  "tniB",
  "Others"
)

drug_class_totals <- result2 %>%
  group_by(Drug_Class) %>%
  summarise(total = sum(total_Count))

drug_class_top20 <- drug_class_totals %>%
  arrange(desc(total)) %>%
  head(20) %>%
  # 获取top20的药物类别名称
  pull(Drug_Class)

result2_top20 <- result2 %>%
  filter(Drug_Class %in% drug_class_top20)

result2_top20$Renamed_MGE_subtype_top10 <- factor(
  result2_top20$Renamed_MGE_subtype_top10,
  levels = desired_order
)
# 绘制百分比堆叠柱状图
p1 <- ggplot(data = result2_top20, aes(x = reorder(Drug_Class, -total_Count, FUN = sum), y = total_Count, fill = Renamed_MGE_subtype_top10)) +
  geom_bar(stat = "identity", position = "stack",width = 0.7) +
  scale_fill_manual(values = colors) +
  theme_minimal() +
  labs(x = "ARG Drug Class", y = "Number of MGEs within the 5 kb flanking regions of ARGs", fill = "MGE symbol") +
  theme(
    # 移除网格线
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    
    # 隐藏x轴标签但保留刻度线
    axis.text.x = element_blank(),  # 隐藏x轴标签
    axis.ticks.x = element_blank(),  # 保留x轴刻度线（可选）
    
    # y轴文本设置保持不变
    axis.text.y = element_text(family = "Arial", face = "bold", size = 14),
    
    # 坐标轴标题设置
    axis.title.x = element_text(family = "Arial", face = "bold", size = 14),
    axis.title.y = element_text(family = "Arial", face = "bold", size = 14),
    
    # 图例设置
    legend.title = element_text(family = "Arial", face = "bold", size = 14),
    legend.text = element_text(family = "Arial", face = "bold", size = 12),
    plot.title = element_text(hjust = 0.5)
  ) +
  guides(fill = guide_legend(ncol = 1))

p1
