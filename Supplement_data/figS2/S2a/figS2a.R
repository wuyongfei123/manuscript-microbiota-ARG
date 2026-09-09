rm(list = ls())

library(ggplot2)
library(ggforce)
library(readr)
library(dplyr)

plasflow_count <- read_csv("plasflow_result.csv")

# 设置因子水平
plasflow_count$location <- factor(
  plasflow_count$location,
  levels = plasflow_count$location
)

colors <- c(
  "unclassified" = "#cccccc", 
  "chromosome" = "#d49ab5",
  "plasmid" = "#a3bdd8"
)

plasflow_count <- plasflow_count %>%
  arrange(desc(location)) %>%
  mutate(cum_perc = cumsum(percentage) - percentage / 2)

# 绘制饼图
p <- ggplot(plasflow_count, aes(x = 2, y = percentage, fill = location)) +
  geom_bar(stat = "identity", color = "white") +
  coord_polar(theta = "y", start = 0) +
  geom_text(aes(y = cum_perc, label = sprintf("%.1f%%", percentage)), color = "black") +
  scale_fill_manual(values = colors) +  
  theme_void() +
  xlim(0.5, 2.5) +
  labs(fill = "location") 

p
