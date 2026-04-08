# 准备工作环境
rm(list = ls())

# 加载R包
library(ggplot2)   
library(dplyr)     
library(readr)
library(multcompView)


#CC
CC_data <- read_csv("CC_between_within_breed.csv")

comparisons <- combn(unique(CC_data$GroupType), 2, simplify = FALSE)
p_values <- sapply(comparisons, function(x) {
  wilcox.test(Distance ~ GroupType, data = CC_data%>% filter(GroupType %in% x))$p.value
})


p_values_adj = p_values

#p_values_adj <- p.adjust(p_values, method = "bonferroni")
names(p_values_adj) <- sapply(comparisons, function(x) paste(x, collapse = "-"))


letters <- multcompLetters(p_values_adj)$Letters


letter_df <- data.frame(GroupType = unique(CC_data $GroupType), letter = letters)


group_order <- c("within_breed","between_breed")


CC_data$GroupType<- factor(CC_data$GroupType, levels = group_order)

# ==========================================================


#组内箱线图
p1 <- ggplot(CC_data, aes(x = GroupType, y = Distance, fill = GroupType)) +
  geom_boxplot(width = 0.6, outlier.shape = 21) +
  scale_fill_manual(values = c( "#b7dbe3", "#f5e09b")) +
  labs(y = "Distance(Bray-Curtis)") +
  geom_text(data = letter_df, 
            aes(x = GroupType, 
                y = max(CC_data$Distance) * 1.3, 
                label = letter), 
            size = 6,
            family = "Arial",  
            fontface = "bold") +  
  
  theme_bw(base_size = 16) +  
  
  theme(
    text = element_text(family = "Arial", face = "bold"), 
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),  
    axis.title = element_text(face = "bold", size = 16), 
    axis.text = element_text(face = "bold", size = 14),  
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )
p1


##Feces
feces_data <- read_csv("feces_between_within_breed.csv")

comparisons <- combn(unique(feces_data$GroupType), 2, simplify = FALSE)
p_values <- sapply(comparisons, function(x) {
  wilcox.test(Distance ~ GroupType, data = feces_data%>% filter(GroupType %in% x))$p.value
})


p_values_adj = p_values

#p_values_adj <- p.adjust(p_values, method = "bonferroni")
names(p_values_adj) <- sapply(comparisons, function(x) paste(x, collapse = "-"))


letters <- multcompLetters(p_values_adj)$Letters


letter_df <- data.frame(GroupType = unique(feces_data$GroupType), letter = letters)


group_order <- c("within_breed","between_breed")


feces_data$GroupType<- factor(feces_data$GroupType, levels = group_order)

# ==========================================================


#组内箱线图
p2 <- ggplot(feces_data, aes(x = GroupType, y = Distance, fill = GroupType)) +
  geom_boxplot(width = 0.6, outlier.shape = 21) +
  scale_fill_manual(values = c( "#b7dbe3", "#f5e09b")) +
  labs(y = "Distance(Bray-Curtis)") +
  geom_text(data = letter_df, 
            aes(x = GroupType, 
                y = max(feces_data$Distance) * 1.3, 
                label = letter), 
            size = 6,
            family = "Arial",  
            fontface = "bold") + 
  
  theme_bw(base_size = 16) +  
  
  theme(
    text = element_text(family = "Arial", face = "bold"),  
    plot.title = element_text(hjust = 0.5, face = "bold", size = 18),  
    axis.title = element_text(face = "bold", size = 16),  
    axis.text = element_text(face = "bold", size = 14), 
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "none"
  )

p2
