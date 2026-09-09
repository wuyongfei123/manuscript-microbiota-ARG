rm(list = ls())

library(ggplot2)
library(dplyr)
library(readr)
library(ggh4x)

results <- read_csv("peptidoglycan_significant_ko_mean_abundance.csv")

#准备p值标签
pvalue_labels <- results %>%
  group_by(KEGG_info) %>%
  summarise(
    # 为每个比较创建标签
    comparison_labels = list({
      p_vals <- p_values_adj
      names(p_vals) <- comparison_names
      
      # 将p值转换为科学计数法格式
      p_formatted <- sapply(p_vals, function(p) {
        if (is.na(p)) {
          return("")
        } else {
          # 使用科学计数法，保留3位有效数字
          return(sprintf("p = %.2e", p))
        }
      })
      
      # 为每个比较创建标签数据框
      label_df <- data.frame(
        comparison = names(p_formatted),
        p_label = p_formatted,
        stringsAsFactors = FALSE
      )
      
      # 分离比较的组名
      label_df$group1 <- sapply(strsplit(label_df$comparison, "-"), function(x) x[1])
      label_df$group2 <- sapply(strsplit(label_df$comparison, "-"), function(x) x[2])
      
      label_df
    })
  ) %>%
  unnest(comparison_labels)

#为每个分面计算标签的y轴位置
y_max_df <- peptidoglycan_significant_KO_abundance %>%
  group_by(KEGG_info) %>%
  summarise(
    y_max = max(abundance) * 1.3,
    .groups = 'drop'
  )

# 为每个分面添加特定的y轴限制
y_max_custom <- data.frame(
  KEGG_info = c("K02563|murG", "K03814|mtgA", "K06153|bacA", "K07259|dacB"),
  y_limit = c(400, 90, 500, 180)
)

# 合并自定义y轴限制
y_max_df <- y_max_df %>%
  left_join(y_max_custom, by = "KEGG_info") %>%
  mutate(
    y_limit = ifelse(is.na(y_limit), y_max, y_limit)
  )

# 为每个比较分配y轴位置
pvalue_labels <- pvalue_labels %>%
  left_join(y_max_df, by = "KEGG_info") %>%
  group_by(KEGG_info) %>%
  mutate(
    n_comparisons = n(),
    y_position = y_limit * (0.9 - (row_number() - 1) * 0.05)
  ) %>%
  ungroup()

#定义组顺序和位置映射
group_order <- c("A/A", "G/A", "G/G")
# 创建组名到数值位置的映射
group_to_x <- setNames(seq_along(group_order), group_order)

# 为每个比较计算x位置
pvalue_labels <- pvalue_labels %>%
  mutate(
    x_pos = (group_to_x[group1] + group_to_x[group2]) / 2,
    x_start = group_to_x[group1],
    x_end = group_to_x[group2]
  )

#检查pvalue_labels
print(colnames(pvalue_labels))
print(pvalue_labels)

#定义颜色
custom_colors <- c(
  "G/G" = "#c9605f",  
  "G/A" = "#646e9a", 
  "A/A" = "#eab676"  
)

peptidoglycan_significant_KO_abundance$group <- factor(peptidoglycan_significant_KO_abundance$group, levels = group_order)

#绘图
p <- ggplot(peptidoglycan_significant_KO_abundance, aes(x = group, y = abundance)) +
  geom_violin(aes(fill = group), color = NA, alpha = 0.6, width = 0.5, trim = TRUE, scale = "width") + 
  geom_point(aes(color = group, fill = group), show.legend = FALSE, 
             position = position_jitter(seed = 123456, width = 0.2), 
             shape = 21, size = 1) +
  geom_boxplot(aes(fill = group), width = 0.7, size = 0.6, fatten = 1, 
               alpha = 0.6, outlier.shape = NA) +  
  facet_wrap(~ KEGG_info, scales = "free_y", ncol = 2) +
  
  geom_segment(
    data = pvalue_labels,
    aes(x = x_start, 
        xend = x_end, 
        y = y_position - y_limit * 0.03, 
        yend = y_position - y_limit * 0.03),
    linewidth = 0.3,
    color = "black",
    inherit.aes = FALSE
  ) +
  
  geom_text(
    data = pvalue_labels,
    aes(x = x_pos, y = y_position, label = p_label),
    size = 3.5, vjust = 0, hjust = 0.5,
    inherit.aes = FALSE
  ) +
  
  scale_fill_manual(values = custom_colors) +
  scale_color_manual(values = custom_colors) +

  facetted_pos_scales(
    y = list(
      KEGG_info == "K02563|murG" ~ scale_y_continuous(limits = c(0, 400), expand = expansion(mult = c(0.05, 0.15))),
      KEGG_info == "K03814|mtgA" ~ scale_y_continuous(limits = c(0, 90), expand = expansion(mult = c(0.05, 0.15))),
      KEGG_info == "K06153|bacA" ~ scale_y_continuous(limits = c(0, 500), expand = expansion(mult = c(0.05, 0.15))),
      KEGG_info == "K07259|dacB" ~ scale_y_continuous(limits = c(0, 180), expand = expansion(mult = c(0.05, 0.15)))
    )
  ) +
  
  labs(x = "genotype", y = "Abundance of KO") +
  
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line.x = element_line(color = "black", size = 1),
    axis.line.y = element_line(color = "black", size = 1),
    plot.background = element_blank(),
    legend.position = "none",
    axis.text.x = element_text(size = 14, family = "Arial"),
    axis.text.y = element_text(size = 14, family = "Arial"),
    axis.title.x = element_text(size = 14, family = "Arial"),
    axis.title.y = element_text(size = 14, family = "Arial"),
    strip.background = element_rect(fill = "lightblue", color = "black", size = 0.8),
    strip.text = element_text(size = 12, color = "black"),
    panel.spacing = unit(1.5, "lines")
  )

p