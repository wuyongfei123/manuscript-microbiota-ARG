rm(list = ls())

library(ggplot2)
library(dplyr)
library(readr)
library(ggh4x)

summary_data <- read_csv("peptidoglycan_significant_ko_mean_abundance.csv")

p <- ggplot(summary_data, aes(x = group, y = mean_abundance)) +
  # 柱状图
  geom_col(aes(fill = group), color = "black", alpha = 0.8, width = 0.5) +
  
  # 误差棒
  geom_errorbar(aes(ymin = mean_abundance - se_abundance, 
                    ymax = mean_abundance + se_abundance),
                width = 0.2, size = 0.8, color = "black") +
  
  # 显著性标记
  geom_text(aes(y = mean_abundance + se_abundance, label = letter),
            size = 6, fontface = "bold", color = "black",
            vjust = -0.8) + 
  
  facet_wrap(~ KEGG_info, scales = "free_y", ncol = 2) +
  
  # 为每个分面单独设置y轴范围
  facetted_pos_scales(
    y = list(
      KEGG_info == "K03814|mtgA" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),  # 增加上边空间
        limits = c(10, NA)
      ),
      KEGG_info == "K07259|dacB" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(10, NA)
      ),
      KEGG_info == "K02563|murG" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(50, NA)
      ),
      KEGG_info == "K06153|bacA" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(50, NA)
      )
    )
  ) +
  
  # 颜色设置
  scale_fill_manual(values = c("G/G" = "#c9605f", "G/A" = "#646e9a", "A/A" = "#eab676")) +
  
  labs(x = "Genotype", y = "Mean Abundance of KO") +
  
  # 主题设置
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey90", size = 0.2),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", size = 0.5),
    plot.background = element_rect(fill = "white", color = NA),
    legend.position = "none",
    
    axis.text.x = element_text(size = 14, family = "Arial", face = "bold", 
                               color = "black", angle = 0, hjust = 0.5),
    axis.text.y = element_text(size = 14, family = "Arial", color = "black"),
    axis.title.x = element_text(size = 16, family = "Arial", face = "bold", 
                                margin = margin(t = 10)),
    axis.title.y = element_text(size = 16, family = "Arial", face = "bold",
                                margin = margin(r = 10)),
    
    strip.background = element_rect(fill = "#87CEEB", color = "black", 
                                    size = 0.8),
    strip.text = element_text(size = 15, face = "bold", color = "black",
                              margin = margin(5, 0, 5, 0)),
    panel.spacing = unit(1.2, "lines")
  )

# 显示图形
p
