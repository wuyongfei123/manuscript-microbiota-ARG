# 清空环境
rm(list=ls())

library(readr)    
library(ggpubr)   

merged_data <- read_csv("high_risk-all_ARG_count.csv")

#创建散点图
p<-ggscatter(merged_data,x="high_risk_ARG_number",y="total_ARG_number",
             size = 3,
             add = "reg.line",
             color = "#246da5",
             fill = "#61a7db",
             shape = 21, 
             stroke = 2,
             alpha = 0.6,
             add.params = list(color = "#A52A2A", fill = "#ebc0c1", size = 2),
             conf.int = TRUE) +
  stat_cor(method="spearman",label.sep="\n",size = 8)+
  xlab("High Risk ARGs number")+
  ylab("All ARGs number")+
  theme(
    text = element_text(family = "Arial", face = "bold",size = 18),         
    axis.title.x = element_text(family = "Arial", face = "bold",size = 22), 
    axis.title.y = element_text(family = "Arial", face = "bold",size = 22)  
  )

p
