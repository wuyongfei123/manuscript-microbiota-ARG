rm(list=ls())

# 加载必要的包
library(ggplot2)
library(readr)

gut_ARG_data <- read_csv("high_risk_ARG_gut_abundance.csv")

gut_ARG_data <- gut_ARG_data %>%
  group_by(gut_locations) %>% 
  mutate(
    mean_val = mean(high_risk_ARG_abundance, na.rm = TRUE),
    sd_val = sd(high_risk_ARG_abundance, na.rm = TRUE),
    # 判断是否在均值 ± 3σ 范围内
    is_outlier = abs(high_risk_ARG_abundance - mean_val) > 3 * sd_val
  ) %>%
  filter(!is_outlier)  # 过滤掉离群值

# 进行Wilcoxon检验并计算p值
comparisons <- combn(unique(gut_ARG_data$gut_locations), 2, simplify = FALSE)
p_values <- sapply(comparisons, function(x) {
  wilcox.test(high_risk_ARG_abundance ~ gut_locations, data = gut_ARG_data%>% filter(gut_locations %in% x))$p.value
})


p_values_adj = p_values
names(p_values_adj) <- sapply(comparisons, function(x) paste(x, collapse = "-"))

# 获取统计显著性的字母标签
letters <- multcompLetters(p_values_adj)$Letters

# 准备绘图的字母数据
letter_df <- data.frame(gut_locations = unique(gut_ARG_data $gut_locations), letter = letters)

# 自定义x轴标签顺序
gut_order <- c("Stomach","small_intestine",  "large_intestine", "Feces")

# 将Breed列转换为因子并设定顺序
gut_ARG_data$gut_locations<- factor(gut_ARG_data$gut_locations, levels = gut_order)

#绘图
p <- ggplot(gut_ARG_data, aes(x = gut_locations, y = high_risk_ARG_abundance)) +
  geom_violin(aes(fill = gut_locations), color = NA, alpha = 0.6, width = 0.5, trim = TRUE, scale = "width") + 
  geom_point(aes(color = gut_locations, fill = gut_locations), show.legend = FALSE, 
             position = position_jitter(seed = 123456, width = 0.2), shape = 21, size = 2) +
  geom_boxplot(aes(fill = gut_locations), width = 0.6, size = 1, fatten = 1, alpha = 0.6, outlier.shape = NA) + 
  scale_y_continuous(
    limits = c(0, max(gut_ARG_data$high_risk_ARG_abundance) * 1.5), 
    expand = c(0, 0)
  ) +
  scale_fill_manual(values = c("#5E5094",
                               "#EFD19B",
                               "#DC9FC8",
                               "#7fabc4")) +
  scale_color_manual(values = c("#5E5094",
                                "#EFD19B",
                                "#DC9FC8",
                                "#7fabc4")) +
  labs(
    #title = "High Risk ARGs Abundance of different gut", 
    x = "Gut Location",
    y = "ARGs Abundance (TPM)"
  ) +
  geom_text(
    data = letter_df, 
    aes(
      x = gut_locations, 
      y = max(gut_ARG_data$high_risk_ARG_abundance) * 1.3, 
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
    axis.text.x = element_text(size = 16, family = "Arial", face = "bold"),  
    axis.text.y = element_text(size = 16, family = "Arial", face = "bold"),  
    axis.title.x = element_text(size = 16, family = "Arial", face = "bold"), 
    axis.title.y = element_text(size = 16, family = "Arial", face = "bold"), 
    plot.title = element_text(size = 16, family = "Arial", face = "bold", hjust = 0.5) 
  )

# 输出图形
p
