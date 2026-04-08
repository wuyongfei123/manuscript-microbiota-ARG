rm(list=ls())

library(gggenes)
library(ggplot2)
library(scales)
library(readxl)
library(readr)
library(dplyr)

ARG_MGR_position <- read_csv("D:/2025_1162_duck_args/final_MGE/qac-sul1_annotation_plasmid_results.csv")


#筛选代表contig
select_ARG_MGR_position <- ARG_MGR_position %>%
  filter(contig_ID %in% c(
    "BKDN170794326-1A_k127_70098",
    "CCY47A_k127_179119",
    "BKDN170794158-1A_k127_95071",
    "SHCC103A_k127_203729",
    "SRR29409633_k127_145295",
    "SRR29354208_k127_3604",
    "SHCC201A_k127_1286"
  ))

#提取并合并数据
result <- bind_rows(
  # 提取MGE部分
  select_ARG_MGR_position %>%
    select(contig_ID = contig_ID, 
           gene = MGE_subtype, 
           start = MGE_Start, 
           end = MGE_End, 
           orientation = MGE_Strand) %>%
    mutate(type = "MGE"),  
  
  # 提取ARG部分
  select_ARG_MGR_position %>%
    select(contig_ID = contig_ID, 
           gene = ARG, 
           start = ARG_Start, 
           end = ARG_End, 
           orientation = ARG_Strand) %>%
    mutate(type = "ARG")   # 添加类型列（可选）
) %>%
  #重排列顺序（将type列放在第二列）
  select(contig_ID, 
         type,      # 可选列
         gene, 
         start, 
         end, 
         orientation)


result <- result %>%
  mutate(type = ifelse(gene == "qacEdelta1", "ARG-MGE", type))

result <- result %>%
  mutate(type = ifelse(gene == "qacEdelta", "ARG-MGE", type))
# 准备数据 - 保持contig顺序
plot_data <- result%>%
  mutate(
    forward = ifelse(orientation == 1, TRUE, FALSE),
    contig_ID = factor(contig_ID, levels = unique(contig_ID))
  ) %>%
  arrange(contig_ID, start)

# 定义指定的排序顺序
contig_order <- c(
  "BKDN170794326-1A_k127_70098",
  "CCY47A_k127_179119",
  "BKDN170794158-1A_k127_95071",
  "SHCC103A_k127_203729",
  "SRR29409633_k127_145295",
  "SRR29354208_k127_3604",
  "SHCC201A_k127_1286"
)

# 将contig_ID转换为因子并设置水平
plot_data$contig_ID <- factor(plot_data$contig_ID, levels = contig_order)

p <- ggplot(
  plot_data,
  aes(xmin = start, xmax = end, y = contig_ID, fill = type, label = gene, forward = forward)
) +
  geom_gene_arrow(arrowhead_height = unit(7, "mm"), 
                  arrowhead_width = unit(3, "mm"),
                  arrow_body_height = unit(5, "mm")) +
  geom_gene_label(align = "left") +
  geom_blank(data = plot_data) +
  facet_wrap(~ contig_ID, scales = "free", ncol = 1) +
  # 使用自定义颜色映射代替Set3
  scale_fill_manual(values = c(
    "ARG" = "#8DD3C7",
    "MGE" = "#FFFFB3",
    "ARG-MGE" = "#BEBADA"
  )) +
  theme_genes()

p


