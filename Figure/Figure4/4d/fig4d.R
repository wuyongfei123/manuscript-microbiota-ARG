rm(list = ls())

library(ggplot2)
library(dplyr)
library(readr)
library(multcompView)

merge_data <- read_csv("CC_breed_abundance.csv")


comparisons <- combn(unique(merge_data$Breed), 2, simplify = FALSE)
p_values <- sapply(comparisons, function(x) {
  wilcox.test(Total_Abundance ~ Breed, data = merge_data %>% filter(Breed %in% x))$p.value
})
p_values_adj=p_values

names(p_values_adj) <- sapply(comparisons, function(x) paste(x, collapse = "-"))

letters <- multcompLetters(p_values_adj)$Letters


letter_df <- data.frame(Breed = unique(merge_data$Breed), letter = letters)

custom_colors <- c(
  "MAL" = "#58ae9a",  
  "CVD" = "#c9605f", 
  "MSD" = "#c9605f",  
  "PKD" = "#c9605f",
  "LAD" = "#646e9a",  
  "SRD" = "#646e9a",  
  "SXD" = "#eab676"   
)


breed_order <- c("MAL","CVD","MSD","PKD","LAD","SRD", "SXD")


merge_data$Breed <- factor(merge_data$Breed, levels = breed_order)


p <- ggplot(merge_data, aes(x = Breed, y = Total_Abundance)) +
  geom_violin(aes(fill = Breed), color = NA, alpha = 0.6, width = 0.5, trim = TRUE, scale = "width") + 
  geom_point(aes(color = Breed, fill = Breed), show.legend = F, position = position_jitter(seed = 123456, width = 0.2), shape = 21, size = 1) +
  geom_boxplot(aes(fill = Breed), width = 0.7, size = 0.6, fatten = 1, alpha = 0.6, outlier.shape = NA) +  
  scale_y_continuous(
    limits = c(0, max(merge_data$Total_Abundance) * 1.5), 
    expand = c(0, 0)
  ) +
  scale_fill_manual(values = custom_colors) +
  scale_color_manual(values = custom_colors) +
  labs(
    x = "Breed",
    y = "Total Abundance of ARGs"
  ) +
  geom_text(
    data = letter_df, 
    aes(
      x = Breed, 
      y = max(merge_data$Total_Abundance) * 1.3, 
      label = letter
    ), 
    size = 6
  ) +
  theme(
    panel.background = element_blank(),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.line.x = element_line(color = "black", size = 1),
    axis.line.y = element_line(color = "black", size = 1),
    plot.background = element_blank(),
    legend.position = "none",
    
    # 修改X轴和Y轴的刻度和标题字体为Arial Bold 14
    axis.text.x = element_text(size = 14, family = "Arial", face = "bold"),  # X轴刻度标签
    axis.text.y = element_text(size = 14, family = "Arial", face = "bold"),  # Y轴刻度标签
    axis.title.x = element_text(size = 14, family = "Arial", face = "bold"),  # X轴标题
    axis.title.y = element_text(size = 14, family = "Arial", face = "bold")  # Y轴标题
  )

p
