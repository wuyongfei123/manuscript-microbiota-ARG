rm(list = ls())

# 加载所需的库
library(readr)   
library(dplyr)   
library(tidyr)

arg_breed_ARG_sum <- read_csv("CC_ARG_breed.csv")

# 获取每个品种内的Top5 ARG type丰度
arg_breed_top5 <- arg_breed_ARG_sum %>%
  group_by(Breed) %>% 
  mutate(Rank = rank(-Total_Abundance, ties.method = "first")) %>% # 按丰度降序排名
  filter(Rank <= 5) %>% 
  ungroup() %>%
  select(-Rank) 

# 获取ARG type并累加为 "Other"
arg_breed_other <- arg_breed_ARG_sum %>%
  anti_join(arg_breed_top5, by = c("Breed", "ARG_type")) %>% 
  group_by(Breed) %>%
  summarise(
    ARG_type = "Other", 
    Total_Abundance = sum(Total_Abundance) 
  )

# 合并 Top 5 和 "Other"
arg_breed_final <- bind_rows(arg_breed_top5, arg_breed_other)


# 加载所需的库
library(ggplot2)
library(dplyr)

# 定义 Breed 的顺序
breed_order <- c(
  "MAL", "CVD", "MSD", "PKD", "SRD", "LAD", "SXD"
)

# 定义 Species 的颜色映射
custom_colors <- c(
  "vanYG"  = "#b19ccb",
  "tet(O)" = "#c35171", 
  "vanYB" = "#e48fa7",  
  "lnuC" = "#efcdd6",  
  "APH(3')-IIIa" = "#dae8f8", 
  "tet(W)" = "#aad5f8",  
  "tet(Q)" = "#5184b3",
  "Other" = "#cfcfcf" 
)
arg_breed_final <- arg_breed_final %>%
  mutate(Breed = factor(Breed, levels = breed_order)) %>% 
  group_by(Breed) %>% 
  arrange(Total_Abundance) %>% 
  ungroup() 


desired_ARG_type_order <- c(
  "Other",
  "vanYG",
  "tet(O)", 
  "vanYB",  
  "lnuC",  
  "APH(3')-IIIa", 
  "tet(W)",  
  "tet(Q)"
)

arg_breed_final$ARG_type <- factor(
  arg_breed_final$ARG_type,
  levels = desired_ARG_type_order
)


p2 <- ggplot(data = arg_breed_final, aes(x = Breed, y = Total_Abundance, fill = ARG_type)) +
  geom_bar(stat = "identity", position = "stack") +
  scale_fill_manual(values = custom_colors) +
  theme_minimal() +
  labs(x = "Breed", y = "Total Abundance of ARGs", fill = "ARG type") +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    axis.text.x = element_text(angle = 45, hjust = 1, family = "Arial", face = "bold", size = 14),
    axis.title.x = element_text(family = "Arial", face = "bold", size = 14),
    axis.title.y = element_text(family = "Arial", face = "bold", size = 14),
    axis.text = element_text(family = "Arial", face = "bold", size = 14),
    legend.title = element_text(family = "Arial", face = "bold", size = 14),
    legend.text = element_text(family = "Arial", face = "bold", size = 12),
    plot.title = element_text(hjust = 0.5)
  ) +
  guides(fill = guide_legend(ncol = 1))

p2
