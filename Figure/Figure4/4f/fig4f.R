rm(list = ls())

library(ggplot2)
library(dplyr)
library(readr)
library(multcompView)

Breed_ARG_data <- read_csv("Feces_breed_abundance.csv")


comparisons <- combn(unique(Breed_ARG_data$Breed), 2, simplify = FALSE)
p_values <- sapply(comparisons, function(x) {
  wilcox.test(total_abundance ~ Breed, data = Breed_ARG_data%>% filter(Breed %in% x))$p.value
})


p_values_adj = p_values

names(p_values_adj) <- sapply(comparisons, function(x) paste(x, collapse = "-"))


letters <- multcompLetters(p_values_adj)$Letters


letter_df <- data.frame(Breed = unique(Breed_ARG_data $Breed), letter = letters)


Breed_order <- c("LCW","LSD","CHP","ZSP","JRD","YXP","MWD","TWD","SPD","SXD","JYP","PTB")


Breed_ARG_data$Breed<- factor(Breed_ARG_data$Breed, levels = Breed_order)

custom_colors <- c(
  YXP = "#eab676",
  MWD = "#eab676",
  TWD = "#eab676",
  SPD = "#eab676",
  CVD = "#c9605f",
  JRD = "#646e9a",
  PTB = "#eab676",
  ZSP = "#646e9a",
  JYP = "#eab676",
  CHP = "#646e9a",
  LAD = "#646e9a",
  LSD = "#646e9a",
  LCW = "#646e9a",
  FCS = "#646e9a",
  SXD = "#eab676",
  DYD = "#646e9a"
)


p <- ggplot(Breed_ARG_data, aes(x = Breed, y = total_abundance)) +
  geom_violin(aes(fill = Breed), color = NA, alpha = 0.6, width = 0.5, trim = TRUE, scale = "width") + 
  geom_point(aes(color = Breed, fill = Breed), show.legend = FALSE, 
             position = position_jitter(seed = 123456, width = 0.2), shape = 21, size = 1) +
  geom_boxplot(aes(fill = Breed), width = 0.5, size = 0.6, fatten = 1, alpha = 0.6, outlier.shape = NA) + 
  scale_y_continuous(
    limits = c(0, max(Breed_ARG_data$total_abundance) * 1.5), 
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
      y = max(Breed_ARG_data$total_abundance) * 1.3, 
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
    axis.text.x = element_text(size = 14, family = "Arial"),  
    axis.text.y = element_text(size = 14, family = "Arial"),  
    axis.title.x = element_text(size = 14, family = "Arial", face = "bold"),
    axis.title.y = element_text(size = 14, family = "Arial", face = "bold"),
    plot.title = element_text(size = 14, family = "Arial", face = "bold", hjust = 0.5) 
  )


p