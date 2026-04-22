# 清空环境并设置工作目录
rm(list=ls())

# 加载必要的包
library(dplyr)  
library(tidyr) 
library(ggplot2) 
library(readxl)
library(tidyverse)
library(microeco)
library(magrittr)
library(readr)

# 加载数据
CC_ARG_data <- read_csv("CC_ARG_abundance.csv")
breed_data <- read_csv("CC_breed.csv")
tax_table <- read_csv("ARGs_type.csv")

#重塑数据格式
lefse_data <- CC_ARG_data %>%
  select(Sample, ARG, Abundance) %>%  
  pivot_wider(names_from = ARG, values_from = Abundance)  


order_index <- match(lefse_data$Sample, breed_data$Sample)
breed_data_sorted <- breed_data[order_index, ]

#创建分类标签）
class_labels <- breed_data_sorted  %>%
  select(Sample,Breed,Application) %>%
  distinct()

# 确保class_labels的顺序与lefse_data匹配
# 这里假设你已经确定了每个样本的分类标签


# 将lefse_data转换为 data.frame
lefse_data <- as.data.frame(lefse_data)

# 将class_labels转换为 data.frame
class_labels <- as.data.frame(class_labels)

# 将tax_table转换为 data.frame
tax_table <- as.data.frame(tax_table )

# 将Sample列设置为行名
rownames(lefse_data) <- lefse_data$Sample

# 移除Sample列
lefse_data <- lefse_data %>% 
  select(-Sample)

# 确保所有列都是数值型
lefse_data[] <- lapply(lefse_data, as.numeric)

# 再次检查数据结构，确保列是数值型
str(lefse_data)

# 将 class_labels 的 Sample 列设置为行名
rownames(class_labels) <- class_labels$Sample

# 移除 Sample 列，保留 gut_locations 作为唯一列
class_labels <- class_labels %>% select(-Sample)

# 转置 lefse_data，使样本名成为列名
lefse_data_t <- as.data.frame(t(lefse_data))

# 确保行名和列名格式一致
rownames(class_labels) <- trimws(rownames(class_labels))
colnames(lefse_data_t) <- trimws(colnames(lefse_data_t))

# 筛选共同样本
common_samples <- intersect(rownames(class_labels), colnames(lefse_data_t))

# 保留共同样本
class_labels <- class_labels[common_samples, , drop = FALSE]
lefse_data_t <- lefse_data_t[, common_samples, drop = FALSE]

# 检查最终一致性
print("样本名一致？")
print(all(rownames(class_labels) == colnames(lefse_data_t)))

# 将 tax_table 的第一列 Best_Hit_ARO 设置为行名
rownames(tax_table) <- tax_table$ARGs

# 删除原始的 Best_Hit_ARO 列，因为行名已经设置
tax_table <- tax_table %>% select(-ARGs)

# 检查 tax_table 的结构
print("tax_table 的行名：")
print(rownames(tax_table))

# 手动删除 otu_table 中丰度全为 0 的样本
lefse_data_t_filtered <- lefse_data_t[, colSums(lefse_data_t) > 0, drop = FALSE]

# 获取被保留的样本名
remaining_samples <- colnames(lefse_data_t_filtered)

#获取被保留ARGs
remaining_ARGs <- rownames(lefse_data_t_filtered)

# 在 sample_table (class_labels) 中保留相同的样本
class_labels_filtered <- class_labels[remaining_samples, , drop = FALSE]

tax_table_filtered <- tax_table[remaining_ARGs, , drop = FALSE]



# 创建 microtable 对象
dataset <- microtable$new(sample_table = class_labels_filtered,
                          otu_table = lefse_data_t_filtered,
                          tax_table = tax_table_filtered)



# 查看 microtable 对象
print(dataset)

# 确保 `Application` 是因子类型，并按照特定顺序排序
dataset$Application <- factor(
  dataset$Application,
  levels = c("MAL", "meat_type", "dual_type", "egg_type")  # 自定义顺序
)



# 步骤7：执行LEfSe分析
lefse <- trans_diff$new(dataset = dataset,
                        method = "lefse",
                        group = "Application",  # 组别是肠道部位
                        alpha = 0.05,  # 显著性水平
                        p_adjust_method = "none",  # 不进行p值校正
                        lefse_subgroup = NULL)

# 查看LEfSe分析结果
head(lefse$res_diff)


custom_colors <- c(
  "MAL" = "#58ae9a",
  "meat_type" = "#c9605f",  
  "dual_type" = "#646e9a", 
  "egg_type" = "#eab676" 
)

# 提取 LEfSe 分析结果
lefse_results <- lefse$res_diff

# 执行 LEfSe 分析并绘制差异条形图，展示LDA>3.5的差异
lefse$plot_diff_bar(threshold = 3.5) +
  scale_fill_manual(values = custom_colors) + 
  geom_bar(stat = "identity", color = "white", size = 0.5) + 
  theme(
    axis.title.x = element_text(size = 12),  
    axis.text.x = element_text(size = 8), 
    axis.text.y = element_text(size = 8)   
  )


