rm(list=ls())

library(gggenes)
library(ggplot2)
library(scales)
library(readr)
library(dplyr)

ARG_MGR_position <- read_csv("tetB-tetR-cooccurrence-Escherichia_coli-plasmid.csv")

#每个ARG-MGE组合类型选取代表性contig绘图
select_ARG_MGR_position <- ARG_MGR_position %>%
  filter(contig_ID %in% c(
    "FH287B_k127_824081",
    "GCH221A_k127_381130",
    "FM2B_k127_98043",
    "SRR21163523_k127_187464",
    "SRR21163514_k127_255030"
  ))

# 提取并合并数据
result <- bind_rows(
  # 提取MGE部分
  select_ARG_MGR_position %>%
    select(contig_ID = contig_ID, 
           gene = MGE_subtype, 
           start = MGE_Start, 
           end = MGE_End, 
           orientation = MGE_Strand) %>%
    mutate(type = "MGE"),  # 添加类型列（可选）
  
  # 提取ARG部分
  select_ARG_MGR_position %>%
    select(contig_ID = contig_ID, 
           gene = ARG_type, 
           start = ARG_Start, 
           end = ARG_End, 
           orientation = ARG_Strand) %>%
    mutate(type = "ARG")   # 添加类型列（可选）
) %>%
  # 步骤5：重排列顺序（将type列放在第二列）
  select(contig_ID, 
         type,      # 可选列
         gene, 
         start, 
         end, 
         orientation)


# 准备数据 - 保持contig顺序
plot_data <- result%>%
  mutate(
    forward = ifelse(orientation == 1, TRUE, FALSE),
    contig_ID = factor(contig_ID, levels = unique(contig_ID))
  ) %>%
  arrange(contig_ID, start)

# 定义你指定的排序顺序
contig_order <- c(
  "FH287B_k127_824081",
  "GCH221A_k127_381130",
  "FM2B_k127_98043",
  "SRR21163523_k127_187464",
  "SRR21163514_k127_255030"
)

# 将contig_ID转换为因子并设置水平
plot_data$contig_ID <- factor(plot_data$contig_ID, levels = contig_order)

p <- ggplot(
  plot_data,
  aes(xmin = start, xmax = end, y = contig_ID, fill = type, label = gene,forward = forward)
) +
  geom_gene_arrow(arrowhead_height = unit(4, "mm"), arrowhead_width = unit(2, "mm")) +
  geom_gene_label(align = "left") +
  geom_blank(data = plot_data) +
  facet_wrap(~ contig_ID, scales = "free", ncol = 1) +
  scale_fill_brewer(palette = "Set3") +
  theme_genes()

p
