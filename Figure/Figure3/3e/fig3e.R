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

# 步骤1：加载数据
ARGs_abundance_table <- read_excel("ARGs_Abundance.xlsx")
gut_locations_table <- read_excel("sample-gut_locations.xlsx")
tax_table <- read_excel("ARGs_type.xlsx")

# 步骤2：重塑ARG丰度表为长格式
reshaped_data <- ARGs_abundance_table %>%
  pivot_longer(
    cols = -Sample,              
    names_to = "ARG_type",   
    values_to = "Abundance"     
  )


# 步骤2：合并ARG分类信息 (tax_table)
merged_data <- reshaped_data %>%
  inner_join(tax_table, by = "ARG_type")  


# 步骤3：合并肠道位置信息 (gut_locations_table)
final_data <- merged_data %>%
  inner_join(gut_locations_table, by = "Sample")  # 使用Sample列进行连接


# 步骤4：检查最终数据结构
str(final_data)


# 步骤5：重塑数据格式 - LEfSe分析需要宽格式数据（样本作为行，ARGs作为列）
lefse_data <- merged_data %>%
  select(Sample, ARG_type, Abundance) %>%  # 保留样本ID、ARG名称和丰度值
  pivot_wider(names_from = ARG_type, values_from = Abundance)  # ARG名称变为列名

# 步骤4：创建分类标签（肠道部位））
class_labels <- gut_locations_table %>%
  select(Sample, gut_locations) %>%
  distinct()


# 步骤5：匹配顺序
#检查样本顺序
print("lefse_data 的样本顺序：")
print(lefse_data$Sample)

print("class_labels 的样本顺序：")
print(class_labels$Sample)

# 重新排序 class_labels，使其顺序与 lefse_data 一致
class_labels <- class_labels %>%
  slice(match(lefse_data$Sample, Sample))  # 按 lefse_data$Sample 顺序重新排列


# 将 otu_table（lefse_data）转换为 data.frame
lefse_data <- as.data.frame(lefse_data)

# 将 sample_table（class_labels）转换为 data.frame
class_labels <- as.data.frame(class_labels)

# 将 tax_table 转换为 data.frame
tax_table <- as.data.frame(tax_table)

# 将 Sample 列设置为行名
rownames(lefse_data) <- lefse_data$Sample

# 移除 Sample 列
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

# 将 tax_table 的第一列设置为行名
rownames(tax_table) <- tax_table$ARGs

# 删除原始的 Best_Hit_ARO 列，因为行名已经设置
tax_table <- tax_table %>% select(-ARGs)

# 检查 tax_table 的结构
print("tax_table 的行名：")
print(rownames(tax_table))

# 手动删除丰度全为 0 的样本
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

# 确保 `gut_locations` 是因子类型，并按照特定顺序排序
dataset$gut_locations <- factor(
  dataset$gut_locations,
  levels = c("Stomach", "small_intestine", "large_intestine", "Feces")  # 自定义顺序
)


# 步骤7：执行LEfSe分析
lefse <- trans_diff$new(dataset = dataset,
                        method = "lefse",
                        group = "gut_locations",  # 组别是肠道部位
                        alpha = 0.05,  # 显著性水平
                        p_adjust_method = "none",  # 不进行p值校正
                        lefse_subgroup = NULL)

# 查看LEfSe分析结果
head(lefse$res_diff)

# 定义集合颜色
custom_colors <- c(
  "Stomach" = "#5E5094",
  "small_intestine" = "#EFD19B",
  "large_intestine" = "#DC9FC8",
  "Feces" = "#7fabc4"
)


# 执行 LEfSe 分析并绘制差异条形图，展示LDA>3的差异
lefse$plot_diff_bar(threshold = 3.5) +
  scale_fill_manual(values = custom_colors) +  # 使用自定义颜色
  geom_bar(stat = "identity", color = "white", size = 0.5) +  # 统一柱子边框为白色
  theme(
    axis.title.x = element_text(size = 12),  # 调整 x 轴坐标名称的字体大小
    axis.text.x = element_text(size = 8),  # 调整 x 轴标签的字体大小
    axis.text.y = element_text(size = 8)   # 调整 y 轴标签的字体大小
  )


p
