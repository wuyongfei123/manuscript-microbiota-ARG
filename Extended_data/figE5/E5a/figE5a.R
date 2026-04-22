# 准备工作环境
rm(list = ls())

# 加载R包
library(ggplot2)    
library(vegan)     
library(dplyr)   
library(readxl)   
library(tibble)   
library(readr)
library(vegan)
library(ggprism)
library(multcompView)

filtered_ARG_data <- read_csv("CC_ARG_abundance.csv")
breed_group_sub <- read_csv("CC_application.csv")
#第一列转为行名
filtered_ARG_data <- column_to_rownames(filtered_ARG_data, var = "Sample")

#计算距离
filtered_ARG_data_beta <- vegdist(filtered_ARG_data, method = 'bray') 

#将距离对象转化为矩阵
filtered_ARG_data_beta <- as.matrix(filtered_ARG_data_beta)

#将矩阵转化为数据框
filtered_ARG_data_beta <- as.data.frame(as.table(filtered_ARG_data_beta))

#重命名
colnames(filtered_ARG_data_beta) <- c("Sample1", "Sample2", "Distance")


#合并分组和距离数据
filtered_ARG_data_beta <- merge(filtered_ARG_data_beta, breed_group_sub, by.x = "Sample1", by.y = "Sample", all.x = TRUE)
filtered_ARG_data_beta <- merge(filtered_ARG_data_beta, breed_group_sub, by.x = "Sample2", by.y = "Sample", all.x = TRUE)

#重命名
colnames(filtered_ARG_data_beta)[4:5] <- c("Group1", "Group2")

#把两个样本来自于同一个分组的过滤掉
#df_group <- subset(filtered_ARG_data_beta, Group1 != Group2)

#把来自于同一个样本的过滤掉
df_group <- subset(filtered_ARG_data_beta, Sample1 != Sample2)

#提取组内各用途
MAL <- df_group %>% filter(Group1 == "MAL" & Group2 == "MAL")
meat_type <- df_group %>% filter(Group1 == "meat_type" & Group2 == "meat_type")
dual_type <- df_group %>% filter(Group1 == "dual_type" & Group2 == "dual_type")
egg_type <- df_group %>% filter(Group1 == "egg_type" & Group2 == "egg_type")

#提取组间各个用途
wild_meat_data <- df_group %>%
  filter(
    (Group1 == "MAL" & Group2 == "meat_type") |
      (Group1 == "meat_type" & Group2 == "MAL")
  )

wild_dual_data <- df_group %>%
  filter(
    (Group1 == "MAL" & Group2 == "dual_type") |
      (Group1 == "dual_type" & Group2 == "MAL")
  )

wild_egg_data <- df_group %>%
  filter(
    (Group1 == "MAL" & Group2 == "egg_type") |
      (Group1 == "egg_type" & Group2 == "MAL")
  )

meat_dual_data <- df_group %>%
  filter(
    (Group1 == "meat_type" & Group2 == "dual_type") |
      (Group1 == "dual_type" & Group2 == "meat_type")
  )

meat_egg_data <- df_group %>%
  filter(
    (Group1 == "meat_type" & Group2 == "egg_type") |
      (Group1 == "egg_type" & Group2 == "meat_type")
  )

dual_egg_data <- df_group %>%
  filter(
    (Group1 == "dual_type" & Group2 == "egg_type") |
      (Group1 == "egg_type" & Group2 == "dual_type")
  )

# 添加类型标识列
MAL <- MAL %>% mutate(Type = "MAL")
meat_type <- meat_type %>% mutate(Type = "meat_type")
dual_type <- dual_type %>% mutate(Type = "dual_type")
egg_type <- egg_type %>% mutate(Type = "egg_type")
wild_meat_data <- wild_meat_data %>% mutate(Type = "MAL vs. meat_type")
wild_dual_data <- wild_dual_data %>% mutate(Type = "MAL vs. dual_type")
wild_egg_data <- wild_egg_data %>% mutate(Type = "MAL vs. egg_type")
meat_dual_data <- wild_egg_data %>% mutate(Type = "meat_type vs. dual_type")
meat_egg_data <- meat_egg_data %>% mutate(Type = "meat_type vs. egg_type")
dual_egg_data <- dual_egg_data %>% mutate(Type = "dual_type vs. egg_type")
# 合并数据
combined_data <- bind_rows(
  MAL,
  meat_type,
  dual_type,
  egg_type,
  wild_meat_data,
  wild_dual_data,
  wild_egg_data,
  meat_dual_data,
  meat_egg_data,
  dual_egg_data
) %>% 
  # 转换为因子保证绘图顺序
  mutate(Type = factor(Type, levels = c("MAL","meat_type", "dual_type","egg_type","meat_type vs. egg_type","MAL vs. meat_type","meat_type vs. dual_type","MAL vs. egg_type","MAL vs. dual_type","dual_type vs. egg_type")))

#选择要进行检验的application对
comparisons1 <- list(
  c("MAL", "meat_type"),
  c("MAL", "dual_type"),
  c("MAL", "egg_type"),
  c("meat_type", "dual_type"),
  c("meat_type", "egg_type"),
  c("dual_type", "egg_type")
)

#进行Wilcoxon检验并计算p值
p_values1 <- sapply(comparisons1, function(x) {
  test_result <- wilcox.test(Distance ~ Type, 
                             data = combined_data %>% filter(Type %in% x))
  return(test_result$p.value)
})


p_values_adj1 = p_values1
#使用Bonferroni修正调整p值
#p_values_adj1 <- p.adjust(p_values1, method = "bonferroni")
names(p_values_adj1) <- sapply(comparisons1, function(x) paste(x, collapse = "-"))

#获取统计显著性的字母标签
letters1 <- multcompLetters(p_values_adj1)$Letters

#准备绘图的字母数据
types_in_comparisons1 <- unique(unlist(comparisons1))  

letter_df1 <- data.frame(Type = types_in_comparisons1, 
                         letter = NA)

for (i in 1:length(letters1)) {
  type_pair <- strsplit(names(letters1)[i], "-")[[1]]
  letter_df1$letter[letter_df1$Type %in% type_pair] <- letters1[i]
}

# 打印第一个字母数据框
print(letter_df1)

# ==========================================================

# 检验application对
comparisons2 <-  list(
  c("MAL vs. meat_type", "MAL vs. dual_type"),
  c("MAL vs. meat_type","MAL vs. egg_type"),
  c("MAL vs. meat_type","meat_type vs. dual_type"),
  c("MAL vs. meat_type","meat_type vs. egg_type"),
  c("MAL vs. meat_type","dual_type vs. egg_type"),
  c("MAL vs. dual_type","MAL vs. egg_type"),
  c("MAL vs. dual_type","meat_type vs. dual_type"),
  c("MAL vs. dual_type","meat_type vs. egg_type"),
  c("MAL vs. dual_type","dual_type vs. egg_type"),
  c("MAL vs. egg_type","meat_type vs. dual_type"),
  c("MAL vs. egg_type","meat_type vs. egg_type"),
  c("MAL vs. egg_type","dual_type vs. egg_type"),
  c("meat_type vs. dual_type","meat_type vs. egg_type"),
  c("meat_type vs. dual_type","dual_type vs. egg_type"),
  c("meat_type vs. egg_type","dual_type vs. egg_type")
)
# 进行Wilcoxon检验并计算p值
p_values2 <- sapply(comparisons2, function(x) {
  test_result <- wilcox.test(Distance ~ Type, 
                             data = combined_data %>% filter(Type %in% x))
  return(test_result$p.value)
})


p_values_adj2 = p_values2
# 使用Bonferroni修正调整p值
#p_values_adj2 <- p.adjust(p_values2, method = "bonferroni")
names(p_values_adj2) <- sapply(comparisons2, function(x) paste(x, collapse = "-"))

#获取统计显著性的字母标签
letters2 <- multcompLetters(p_values_adj2)$Letters

# 准备绘图的字母数据
Type_in_comparisons2 <- unique(unlist(comparisons2)) 

letter_df2 <- data.frame(Type = Type_in_comparisons2, 
                         letter = NA)

for (i in 1:length(letters2)) {
  Type_pair <- strsplit(names(letters2)[i], "-")[[1]]
  letter_df2$letter[letter_df2$Type %in% Type_pair] <- letters2[i]
}

# 打印第二个字母数据框
print(letter_df2)

# ==========================================================

#合并两个字母数据框
final_letter_df <- bind_rows(letter_df1, letter_df2)


# 组内箱线图
p <- ggplot(combined_data, aes(x = Type, y = Distance, fill = Type)) +
  geom_boxplot(width = 0.6, outlier.shape = 21) +
  scale_fill_manual(values = c("#d62728", "#2ca02c", "#1f77b4", "#ff7f0e", "#9467bd",
                               "#d781b0", "#9a6c5c", "#72c5d9", "#7e9a5c", "#BE9E33")) +
  labs(
    x = "Application",
    y = "Distance(Bray-Curtis)"
  ) +
  geom_text(
    data = final_letter_df, 
    aes(x = Type, y = max(combined_data$Distance) * 1.3, label = letter), 
    size = 6,
    family = "Arial",  
    fontface = "bold"  
  ) +
  theme_bw(base_size = 14) +
  theme(
    panel.grid.major = element_blank(),  # 移除主要网格线
    panel.grid.minor = element_blank(),  # 移除次要网格线
    text = element_text(family = "Arial", face = "bold"),  # 全局文本设置
    axis.text.x = element_text(angle = 45, hjust = 1, size = rel(1.0)),  # X轴标签
    axis.text.y = element_text(size = rel(1.0)),  # Y轴标签
    axis.title.x = element_text(size = rel(1.1)),  # X轴标题
    axis.title.y = element_text(size = rel(1.1)),  # Y轴标题
    panel.border = element_rect(size = 0.7),  # 加粗面板边框
    plot.title = element_text(hjust = 0.5),
    legend.position = "none"
  )


p
