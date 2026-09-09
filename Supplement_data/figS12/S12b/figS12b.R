#不过滤
rm(list = ls())

# 加载所需包
library(tidyverse)
library(readxl)
library(ggpubr)
library(rstatix)
library(dplyr)


# 1. 数据准备
genus_KO_prevalence <- read_excel("Genus-DAP-KO-MAG存在率.xlsx")

fixed_genus_KO_prevalence <- genus_KO_prevalence[c(-1),]
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence %>%
  mutate(Symbol_KO = paste(Symbol, KO_id, sep = "-")) %>%
  select(Symbol_KO, everything())
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence[, c(-2, -3)]

# 提取显著KO
genes_to_extract <- c("murE-K01928", "mtgA-K03814", "dacB-K07259", 
                      "dgkA-K00887", "ftsI-K03587", "dacC, dacA, dacD-K07258",
                      "pbp5-K18149", "spoVD-K08384", "mrdA-K05515", 
                      "vanY-K07260", "pbpA-K05364")

significant_genus_KO_prevalence <- fixed_genus_KO_prevalence %>%
  filter(Symbol_KO %in% genes_to_extract)

# 定义分组
bacteroidaceae_genus <- c(
  "g__Phocaeicola", "g__Phocaeicola_A", "g__43-108", "g__Alloprevotella", 
  "g__Avibacteroides", "g__Bacteroides", "g__Mediterranea", 
  "g__Paraprevotella", "g__Prevotella", "g__UBA1794", "g__UBA4372", "g__UBA6398"
)

all_genus_cols <- colnames(genus_KO_prevalence)[grepl("^g__", colnames(genus_KO_prevalence))]

lys_type_genus <- c("g__Aliicoccus", "g__Jeotgalicoccus", "g__Staphylococcus", 
                    "g__Enterococcus", "g__Lactococcus", "g__Streptococcus")

# 整理数据为长格式
genus_KO_prevalence_long <- significant_genus_KO_prevalence %>%
  pivot_longer(
    cols = -c(Symbol_KO),
    names_to = "Genus",
    values_to = "Prevalence"
  ) %>%
  mutate(
    group = case_when(
      Genus %in% bacteroidaceae_genus ~ "DAP-type genus from Bacteroidaceae",
      Genus %in% lys_type_genus ~ "Lys-type genus",
      TRUE ~ "Other DAP-type genus"
    ),
    group = factor(group, 
                   levels = c("DAP-type genus from Bacteroidaceae", 
                              "Other DAP-type genus", 
                              "Lys-type genus"))
  )

genus_KO_prevalence_long$Prevalence <- as.numeric(genus_KO_prevalence_long$Prevalence)
genus_KO_prevalence_long$Symbol_KO <- factor(genus_KO_prevalence_long$Symbol_KO)

# 去掉3个标准差以外的数值
filtered_genus_KO_prevalence_long <- genus_KO_prevalence_long %>%
  group_by(Symbol_KO, group) %>%
  filter(Prevalence >= (mean(Prevalence, na.rm = TRUE) - 3 * sd(Prevalence, na.rm = TRUE)) &
           Prevalence <= (mean(Prevalence, na.rm = TRUE) + 3 * sd(Prevalence, na.rm = TRUE))) %>%
  ungroup()

# 计算显著性检验结果
pairwise_results <- filtered_genus_KO_prevalence_long %>%
  mutate(across(where(is.factor), as.character)) %>%
  group_by(Symbol_KO) %>%
  group_modify(~ {
    groups <- unique(.x$group)
    if (length(groups) < 2) {
      return(data.frame())
    }
    group_pairs <- combn(groups, 2, simplify = FALSE)
    map_dfr(group_pairs, function(pair) {
      group1 <- pair[1]
      group2 <- pair[2]
      test_data <- .x %>% dplyr::filter(group %in% c(group1, group2))
      if (nrow(test_data) == 0) {
        return(data.frame(group1 = group1, group2 = group2, p.value = NA_real_))
      }
      wilcox_test <- wilcox.test(Prevalence ~ group, data = test_data, exact = FALSE)
      data.frame(group1 = group1, group2 = group2, p.value = wilcox_test$p.value)
    })
  }) %>%
  ungroup() %>%
  group_by(Symbol_KO) %>%
  mutate(p.adj = p.adjust(p.value, method = "none"),
         significance = case_when(
           p.adj < 0.001 ~ "***",
           p.adj < 0.01 ~ "**",
           p.adj < 0.05 ~ "*",
           TRUE ~ "ns"
         )) %>%
  ungroup()

# 准备显著性标注数据框
y_max_df <- filtered_genus_KO_prevalence_long %>%
  group_by(Symbol_KO) %>%
  summarise(y_max = max(Prevalence, na.rm = TRUE) * 1.5, .groups = 'drop')  # 从1.3改为1.5

# 准备显著性标注数据
sig_df <- pairwise_results %>%
  filter(significance != "ns") %>%
  left_join(y_max_df, by = "Symbol_KO") %>%
  group_by(Symbol_KO) %>%
  mutate(
    y_position = y_max * 0.85 + seq_len(n()) * (y_max * 0.05)  # 从0.92改为0.85，步长从0.08改为0.05
  ) %>%
  ungroup()

print("显著性标注数据：")
print(sig_df %>% select(Symbol_KO, group1, group2, significance, y_max, y_position))

# 绘图
# 定义颜色
custom_colors <- c(
  "DAP-type genus from Bacteroidaceae" = "#c9605f",
  "Other DAP-type genus" = "#646e9a",
  "Lys-type genus" = "#eab676"
)

# 定义分组顺序
group_order <- c("DAP-type genus from Bacteroidaceae", 
                 "Other DAP-type genus", 
                 "Lys-type genus")

filtered_genus_KO_prevalence_long$group <- factor(
  filtered_genus_KO_prevalence_long$group, 
  levels = group_order
)

p <- ggplot(filtered_genus_KO_prevalence_long, aes(x = group, y = Prevalence)) +
  
  # 小提琴图
  geom_violin(aes(fill = group), 
              color = NA, alpha = 0.6, width = 0.5, 
              trim = TRUE, scale = "width") + 
  
  # 抖动点
  geom_point(aes(color = group, fill = group), 
             show.legend = FALSE, 
             position = position_jitter(seed = 123456, width = 0.2), 
             shape = 21, size = 1.5) +
  
  # 箱线图
  geom_boxplot(aes(fill = group), 
               width = 0.7, size = 0.6, fatten = 1, 
               alpha = 0.6, outlier.shape = NA) +  
  
  facet_wrap(~ Symbol_KO, scales = "free_y", ncol = 4) +
  
  geom_text(
    data = sig_df,
    aes(x = group1, y = y_position, label = significance),
    size = 6, vjust = 0, hjust = 0.5,
    inherit.aes = FALSE
  ) +
  
  geom_segment(
    data = sig_df,
    aes(x = as.numeric(group1), xend = as.numeric(group2),
        y = y_position - 0.02 * y_max, yend = y_position - 0.02 * y_max,
        group = Symbol_KO),
    inherit.aes = FALSE,
    color = "black",
    size = 0.4
  ) +
  geom_segment(
    data = sig_df,
    aes(x = as.numeric(group1), xend = as.numeric(group1),
        y = y_position - 0.02 * y_max, yend = y_position - 0.04 * y_max,
        group = Symbol_KO),
    inherit.aes = FALSE,
    color = "black",
    size = 0.4
  ) +
  geom_segment(
    data = sig_df,
    aes(x = as.numeric(group2), xend = as.numeric(group2),
        y = y_position - 0.02 * y_max, yend = y_position - 0.04 * y_max,
        group = Symbol_KO),
    inherit.aes = FALSE,
    color = "black",
    size = 0.4
  ) +
  
  scale_fill_manual(values = custom_colors) +
  scale_color_manual(values = custom_colors) +
  
  labs(x = "Genotype", y = "Prevalence of KO") +
  
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line.x = element_line(color = "black", size = 1),
    axis.line.y = element_line(color = "black", size = 1),
    axis.text.x = element_text(size = 10, family = "Arial", angle = 30, hjust = 1),
    axis.text.y = element_text(size = 12, family = "Arial"),
    axis.title.x = element_text(size = 14, family = "Arial", face = "bold"),
    axis.title.y = element_text(size = 14, family = "Arial", face = "bold"),
    strip.background = element_rect(fill = "lightblue", color = "black", size = 0.8),
    strip.text = element_text(size = 11, color = "black", face = "bold"),
    legend.position = "bottom",
    legend.title = element_text(size = 12, family = "Arial", face = "bold"),
    legend.text = element_text(size = 10, family = "Arial"),
    panel.spacing = unit(1.2, "lines"),
    plot.margin = unit(c(0.5, 0.5, 0.5, 0.5), "cm")
  ) +
  expand_limits(y = max(filtered_genus_KO_prevalence_long$Prevalence, na.rm = TRUE) * 1.4)

# 显示图形
print(p)


