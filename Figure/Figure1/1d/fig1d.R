rm(list=ls())

# 加载必要的库
library(dplyr) 
library(ggplot2)  



# 读取数据
arg_MGE_data <- read.csv("ARG_MGE_count.csv", check.names = FALSE)

merged_data <- arg_MGE_data %>%
  mutate(
    ARG_count_log2 = log2(ARG_Count + 1),     
    MGE_count_log2 = log2(MGE_Count + 1)     
  )

#创建散点图
p <- ggscatter(merged_data, x = "ARG_count_log2", y = "MGE_count_log2",
               size = 5,
               add = "reg.line",
               color = "#246da5",
               fill = "#61a7db",
               shape = 21, 
               stroke = 2,
               alpha = 0.6,
               add.params = list(color = "#A52A2A", fill = "#ebc0c1", size = 3),
               conf.int = TRUE) +
  stat_cor(method = "spearman", label.sep = "\n") +
  xlab("Number of ARGs(log2)") +
  ylab("Number of MGEs within 5kb of ARGs(log2)") +
  theme(
    text = element_text(family = "Arial", face = "bold",size = 18),         
    axis.title.x = element_text(family = "Arial", face = "bold",size = 20), 
    axis.title.y = element_text(family = "Arial", face = "bold",size = 20)  
  )

p