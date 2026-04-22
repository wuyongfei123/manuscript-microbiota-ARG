rm(list = ls())

# 加载所需的库
library(readr)    
library(dplyr)    
library(tidyr)
library(stringr)

filter_arg_genus_abun <- read_csv("SRD_high_risk_ARG_genus_abun.csv")

unknown_data <- subset(filter_arg_genus_abun, Genus == "unknown")
unknown_data <- rename(unknown_data,Genus_Group = Genus, Total_Abundance = Abundance)
filter_arg_genus_abun <-filter(filter_arg_genus_abun,Genus != "unknown")

MAG_bacteria <- read_csv("MAG_genus_family.csv")
family_genus <- MAG_bacteria[,c(2,3)]
filter_arg_family_genus_abun <- left_join(filter_arg_genus_abun,unique_family_genus,by = "Genus")

top3_genus_data <- filter_arg_family_genus_abun %>%
  group_by(Best_Hit_ARO) %>%
  arrange(desc(Abundance)) %>%
  mutate(
    rank = row_number(),
    non_zero_count = sum(Abundance > 0),  # 计算非零值的数量
    total_count = n(),                   # 计算总行数
    
    Genus_Group = case_when(
      # 对tet(Q)基因的特殊处理
      Best_Hit_ARO == "tet(Q)" & Family == "f__Bacteroidaceae" ~ Genus,
      Best_Hit_ARO == "tet(Q)" & Family != "f__Bacteroidaceae" ~ "Other",
      
      # 对其他基因的原有处理逻辑
      # 情况1：所有值都为0，只保留第一个
      all(Abundance == 0) & rank == 1 ~ Genus,
      
      # 情况2：只有1个非零值
      non_zero_count == 1 & rank == 1 ~ Genus,
      
      # 情况3：有2个非零值
      non_zero_count == 2 & rank <= 2 ~ Genus,
      
      # 情况4：有3个或以上非零值，取top3
      rank <= 3 & Abundance > 0 ~ Genus,
      
      # 默认情况：归为Other
      TRUE ~ "Other"
    )
  ) %>%
  select(-non_zero_count, -total_count) %>%  # 移除临时列
  ungroup()

#重新汇总数据（将 Other 合并）
final_data <- top3_genus_data %>%
  group_by(Best_Hit_ARO, Genus_Group) %>%
  summarise(Total_Abundance = sum(Abundance), .groups = 'drop')

combined_data <- rbind(final_data, unknown_data)
combined_data <- combined_data %>%
  mutate(Genus_Group = ifelse(Genus_Group == "unknown", "Other", Genus_Group))

final_combined_data <- combined_data %>%
  group_by(Best_Hit_ARO, Genus_Group) %>%
  summarise(Total_Abundance = sum(Total_Abundance), .groups = 'drop')


# 加载所需的库
library(ggplot2)
library(dplyr)

# 定义 Species 的颜色映射 
custom_colors <- c(
  "g__Merdivivens"= "#e48fa7",#f__UBA932
  "g__Spyradenecus" = "#A4B0FA",#f__UBA1067
  "g__Treponema_F"="#DCA7EB"  ,#f__Treponemataceae
  "g__Parabacteroides"= "#b36a6f",#f__Tannerellaceae
  "g__Anaerobiospirillum"= "#274753",#f__Succinivibrionaceae
  "g__Megamonas" = "#299d8f",#f__Selenomonadaceae
  "g__Fournierella"= "#a8817a",#f__Ruminococcaceae
  "g__Enterousia"= "#efcdd6",#f__Rs-D84
  "g__Tidjanibacter" = "#FA9191",#f__Rikenellaceae
  "g__Alistipes" = "#FCB8B8",
  "g__Mannheimia" = "#BED77C",#f__Pasteurellaceae
  "g__Gallibacterium"= "#DAEAAF",
  "g__Avoscillospira_A" = "#e4cce4",#f__Oscillospiraceae
  "g__Ligilactobacillus" = "#e76253",#f__Lactobacillaceae
  "g__Helicobacter_G" = "#D8CB92",#f__Helicobacteraceae
  "g__CAG-196" = "#bfdfd2",#f__Gastranaerophilaceae
  "g__Fusobacterium_A" = "#e9d95d",#f__Fusobacteriaceae
  "g__Enterococcus" = "#ebccb7",
  "g__Enterococcus_E" = "#e8b975",
  "g__Escherichia" = "#d8cac1",#f__Enterobacteriaceae
  "g__Mailhella"= "#917bbd",#f__Desulfovibrionaceae
  "g__Desulfovibrio" = "#b19ccb",
  "g__Butyricicoccus"= "#4a4f7e",#f__Butyricicoccaceae
  "g__Duodenibacillus"= "#FFFFDD",#f__Burkholderiaceae_A
  "g__UMGS263"="#c35171",#f__Acutalibacteraceae
  "g__Akkermansia" = "#8fdfd2",#f__Akkermansiaceae
  "g__Brachyspira" = "#586144",#f__Brachyspiraceae
  "g__Bacteroides"= "#e8eaf6",#f__Bacteroidaceae
  "g__Avibacteroides" = "#22a6ee",
  "g__Alloprevotella"="#a9caf2" ,
  "g__Prevotella"= "#dae8f8",
  "g__Mediterranea"= "#75b4f1",
  "g__Paraprevotella" = "#4398cf",
  "g__Phocaeicola" = "#438abc" ,
  "Other" = "#cfcfcf" 
)

final_combined_data <- final_combined_data %>%
  # 计算每个Best_Hit_ARO中g__Phocaeicola的占比
  group_by(Best_Hit_ARO) %>%
  mutate(phocaeicola_ratio = ifelse(any(Genus_Group == "g__Phocaeicola"), 
                                    Total_Abundance[Genus_Group == "g__Phocaeicola"] / sum(Total_Abundance), 
                                    0)) %>%
  ungroup() %>%
  # 按照g__Phocaeicola的占比降序排列
  mutate(Best_Hit_ARO = factor(Best_Hit_ARO, 
                               levels = unique(Best_Hit_ARO[order(-phocaeicola_ratio)]))) %>%
  # 按排序后的Best_Hit_ARO和占比进行排序
  arrange(Best_Hit_ARO, desc(phocaeicola_ratio)) %>%
  ungroup()  # 解除分组


# 手动调整 Species 的因子顺序
desired_genus_order <- c(
  "Other",
  "g__Merdivivens",#f__UBA932
  "g__Spyradenecus",#f__UBA1067
  "g__Treponema_F",#f__Treponemataceae
  "g__Parabacteroides",#f__Tannerellaceae
  "g__Anaerobiospirillum",#f__Succinivibrionaceae
  "g__Megamonas",#f__Selenomonadaceae
  "g__Fournierella",#f__Ruminococcaceae
  "g__Enterousia",#f__Rs-D84
  "g__Tidjanibacter",#f__Rikenellaceae
  "g__Alistipes",
  "g__Mannheimia",#f__Pasteurellaceae
  "g__Gallibacterium",
  "g__Avoscillospira_A",#f__Oscillospiraceae
  "g__Ligilactobacillus",#f__Lactobacillaceae
  "g__Helicobacter_G",#f__Helicobacteraceae
  "g__CAG-196" ,#f__Gastranaerophilaceae
  "g__Fusobacterium_A",#f__Fusobacteriaceae
  "g__Enterococcus",#f__Enterobacteriaceae
  "g__Enterococcus_E",
  "g__Escherichia",
  "g__Mailhella",#f__Desulfovibrionaceae
  "g__Desulfovibrio" ,
  "g__Butyricicoccus",#f__Butyricicoccaceae
  "g__Duodenibacillus",#f__Burkholderiaceae_A
  "g__UMGS263",#f__Acutalibacteraceae
  "g__Akkermansia",#f__Akkermansiaceae
  "g__Brachyspira",#f__Brachyspiraceae
  "g__Bacteroides",#f__Bacteroidaceae
  "g__Prevotella",
  "g__Alloprevotella",
  "g__Mediterranea",
  "g__Avibacteroides",
  "g__Paraprevotella",
  "g__Phocaeicola"
)

final_combined_data$Genus_Group <- factor(
  final_combined_data$Genus_Group,
  levels = desired_genus_order
)



# 绘制百分比堆叠柱状图
p1 <- ggplot(data = final_combined_data, aes(x = Best_Hit_ARO, y = Total_Abundance, fill = Genus_Group)) +
  geom_bar(stat = "identity", position = position_fill()) +  # 使用position_fill()函数
  scale_y_continuous(labels = scales::percent) +
  scale_fill_manual(values = custom_colors) +
  theme_minimal() +
  labs(x = "High Risk ARGs", y = "Relatived Abundance", fill = "Genus") +
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

p1
