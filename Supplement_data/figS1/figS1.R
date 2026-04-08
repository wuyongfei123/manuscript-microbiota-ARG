rm(list = ls())
library(ggplot2)
library(ggforce)
library(readr)
library(dplyr)

##MAG
phylum_data <- read_csv("MAG_phylum_ARG_count.csv")

# 计算百分比
phylum_data$percentage <- phylum_data$Total_MAGs / sum(phylum_data$Total_MAGs) * 100

# 按Total_MAGs降序排列，并处理Top 10
phylum_top5 <- phylum_data %>%
  arrange(desc(Total_MAGs)) %>%  
  mutate(rank = row_number()) %>%  
  mutate(Phylum_group = ifelse(rank <= 5, as.character(Phylum), "Other")) 

#按新的Phylum_group重新汇总
phylum_final <- phylum_top5 %>%
  group_by(Phylum_group) %>%
  summarise(
    Total_MAGs = sum(Total_MAGs),
    percentage = sum(percentage)
  ) %>%
  ungroup() %>%
  arrange(desc(Total_MAGs))  # 按数量重新排序

# 设置因子水平
phylum_final$Phylum_group <- factor(
  phylum_final$Phylum_group,
  levels = phylum_final$Phylum_group
)

colors <- c(
  "p__Bacillota" = "#3A6EA5", 
  "p__Bacteroidota" = "#E67F37",
  "p__Pseudomonadota" = "#FFCC00",
  "Other" = "#cccccc",
  "p__Actinomycetota" = "#99C870",
  "p__unclassified Bacteria phylum" = "#996633",
  "p__Cyanobacteriota" = "#89D1CE"
)


#绘制饼图
p1 <- ggplot(phylum_final, aes(x = 2, y = percentage, fill = Phylum_group)) +
  geom_bar(stat = "identity", color = "white") +
  coord_polar(theta = "y", start = 0) +
  scale_fill_manual(values = colors) + 
  theme_void() +
  xlim(0.5, 2.5) +
  labs(fill = "phylum") 

p1

rm(list = ls())
library(ggplot2)
library(ggforce)
library(readr)
library(dplyr)
##contig
phylum_data <- read_csv("contig_phylum_ARG_count.csv")

# 计算百分比
phylum_data$percentage <- phylum_data$Total_orfs / sum(phylum_data$Total_orfs) * 100

# 3. 按Total_MAGs降序排列，并处理Top 10
phylum_top5 <- phylum_data %>%
  arrange(desc(Total_orfs)) %>%  # 按Total_MAGs降序排列
  mutate(rank = row_number()) %>%  # 添加排名
  mutate(Phylum_group = ifelse(rank <= 5, as.character(phylum), "Other"))  # Top 10保留，其余为Other

# 4. 按新的Phylum_group重新汇总
phylum_final <- phylum_top5 %>%
  group_by(Phylum_group) %>%
  summarise(
    Total_contig_orfs = sum(Total_orfs),
    percentage = sum(percentage)
  ) %>%
  ungroup() %>%
  arrange(desc(Total_contig_orfs))  # 按数量重新排序

# 然后设置因子水平
phylum_final$Phylum_group <- factor(
  phylum_final$Phylum_group,
  levels = phylum_final$Phylum_group
)


colors <- c(
  "p__Bacillota" = "#3A6EA5", 
  "p__Bacteroidota" = "#E67F37",
  "p__Pseudomonadota" = "#FFCC00",
  "Other" = "#cccccc",
  "p__Actinomycetota" = "#99C870",
  "p__unclassified Bacteria phylum" = "#996633",
  "p__Cyanobacteriota" = "#89D1CE"
)

phylum_final <- phylum_final %>%
  arrange(desc(Phylum_group)) %>%
  mutate(cum_perc = cumsum(percentage) - percentage / 2)

# 5. 绘制饼图
p2 <- ggplot(phylum_final, aes(x = 2, y = percentage, fill = Phylum_group)) +
  geom_bar(stat = "identity", color = "white") +
  coord_polar(theta = "y", start = 0) +
  geom_text(aes(y = cum_perc, label = sprintf("%.1f%%", percentage)), color = "black") +
  scale_fill_manual(values = colors) +  # 保留你的自定义配色
  theme_void() +
  xlim(0.5, 2.5) +
  labs(fill = "phylum") 


p2
