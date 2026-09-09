rm(list = ls())

library(dplyr)
library(readxl)
library(tidyverse)   
library(pheatmap)    
library(grid)       
library(viridis)

genus_KO_prevalence <- read_excel("Genus-DAP-KO-MAG-prevalence.xlsx")
fixed_genus_KO_prevalence <- genus_KO_prevalence [c(-1),]
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence %>%
  mutate(Symbol_KO = paste(Symbol, KO_id, sep = "-")) %>%
  select(Symbol_KO, everything())
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence[,c(-2,-3)]


#转为数值型
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence %>%
  mutate(across(-1, ~ as.numeric(as.character(.))))

# 定义各组菌属
bacteroidaceae_genus <- c("g__Phocaeicola","g__Phocaeicola_A", "g__43-108", "g__Alloprevotella", 
                          "g__Avibacteroides", "g__Bacteroides", "g__Mediterranea", 
                          "g__Paraprevotella", "g__Prevotella", "g__UBA1794", 
                          "g__UBA4372", "g__UBA6398")  

Lys_type_genus <- c("g__Aliicoccus", "g__Jeotgalicoccus", "g__Staphylococcus", 
                    "g__Enterococcus", "g__Lactococcus", "g__Streptococcus")  

# 从数据中提取除了以上三组之外的其他DAP-type菌属
genus_cols <- names(fixed_genus_KO_prevalence)[grepl("^g__", names(fixed_genus_KO_prevalence))] 
group_assignment <- ifelse(
  genus_cols %in% bacteroidaceae_genus, 
  "DAP-type genus from Bacteroidaceae",
  ifelse(
    genus_cols %in% Lys_type_genus, 
    "Lys-type genus", 
    "other DAP-type genus"
  )
)


# 先按分组顺序，再在组内按字母顺序
group_order <- c("DAP-type genus from Bacteroidaceae", 
                 "other DAP-type genus", "Lys-type genus")

# 按分组对菌属进行排序
genus_by_group <- list()
for(group in group_order) {
  group_genus <- genus_cols[group_assignment == group]
  genus_by_group[[group]] <- sort(group_genus)
}

# 获取按分组排序后的菌属列表
ordered_genus <- unlist(genus_by_group)

# 重新排列数据框列
data_for_plot <- fixed_genus_KO_prevalence %>%
  select(Symbol_KO, all_of(ordered_genus))

#创建绘图矩阵
plot_matrix <- as.matrix(data_for_plot[, -1])
rownames(plot_matrix) <- data_for_plot$Symbol_KO
colnames(plot_matrix) <- ordered_genus

# 创建列分组信息
col_annotation <- data.frame(
  Group = rep(names(genus_by_group), sapply(genus_by_group, length))
)
rownames(col_annotation) <- ordered_genus

# 设置分组颜色
group_colors <- list(
  Group = c(
    "DAP-type genus from Bacteroidaceae" = "#7da6c6", 
    "other DAP-type genus" = "#84c3b7",     
    "Lys-type genus" = "#b7b3d0"         
  )
)

# 自定义颜色渐变
custom_colors <- colorRampPalette(
  c("#3f8094", "#77a5b4", "#d7e6ed", "white", "#fdcab4", "#fa8350", "#d9372a")
)(100)

# 加载必要的包
library(grid)
library(gridExtra)
library(pheatmap)

# 1. 定义自定义行名顺序
custom_row_order <- c(
  "Ddl-K01921", "murE-K01928", "murEF-K15792","murF-K01929", "uppS-K00806","bacA-K06153", 
  "bcrC-K19302","dgkA-K00887", "mraY-K01000", "murG-K02563", "mtgA-K03814","ftsW-K03588",
  "rodA-K05837","pbpC-K05367","mrcA-K05366","mrcB-K05365","pbp2A-K12555","pbpD-K18770","pbpG-K21464",
  "mrdA-K05515","ftsI-K03587","pbp5-K18149","pbpB-K08724","spoVD-K08384","pbpA-K05364","pbpA-K21465",
  "dacC, dacA, dacD-K07258","dacB-K07259","pbp4b","vanY-K07260","vanXY-K18866")


# 只保留实际存在的行名
valid_row_order <- intersect(custom_row_order, rownames(plot_matrix))

# 重新排序矩阵行
ordered_matrix <- plot_matrix[match(valid_row_order, rownames(plot_matrix)), ]


group_data <- list()
for (group_name in group_order) {
  group_genus <- genus_by_group[[group_name]]
  if (length(group_genus) > 0) {
    group_data[[group_name]] <- ordered_matrix[, group_genus, drop = FALSE]
  } else {
    group_data[[group_name]] <- matrix(nrow = nrow(ordered_matrix), ncol = 0)
    rownames(group_data[[group_name]]) <- rownames(ordered_matrix)
  }
}


row_labels <- rownames(ordered_matrix)

# 绘制第一个分组的热图并显示行名
first_group_data <- group_data[[group_order[1]]]
first_group_annotation <- data.frame(Group = rep(group_order[1], ncol(first_group_data)))
rownames(first_group_annotation) <- colnames(first_group_data)

#计算行高
n_rows <- nrow(first_group_data)
cell_height_value <- 30

p_first <- pheatmap(first_group_data,
                    annotation_col = first_group_annotation,
                    annotation_colors = group_colors,
                    annotation_legend = FALSE,
                    show_colnames = FALSE,
                    show_rownames = TRUE,
                    labels_row = row_labels,
                    cluster_rows = FALSE,      
                    cluster_cols = FALSE,
                    color = custom_colors,
                    cellheight = cell_height_value, 
                    border_color = NA,
                    silent = TRUE)

#绘制其他分组（不显示行名）
other_grobs <- list()
for (group_name in group_order[-1]) {
  current_data <- group_data[[group_name]]
  current_annotation <- data.frame(Group = rep(group_name, ncol(current_data)))
  rownames(current_annotation) <- colnames(current_data)
  
  p_other <- pheatmap(current_data,
                      annotation_col = current_annotation,
                      annotation_colors = group_colors,
                      annotation_legend = FALSE,
                      show_colnames = FALSE,
                      show_rownames = FALSE, 
                      cluster_rows = FALSE,   
                      cluster_cols = FALSE,
                      color = custom_colors,
                      cellheight = cell_height_value,  
                      border_color = NA,
                      silent = TRUE)
  
  other_grobs[[group_name]] <- p_other$gtable
}

#设置宽度比例
width_ratios <- c(
  "DAP-type genus from Bacteroidaceae" = 0.7, 
  "other DAP-type genus" = 0.6,
  "Lys-type genus" = 0.3
)

# 9. 手动拼接
all_grobs <- c(list(p_first$gtable), other_grobs)
width_ratios_combined <- c(width_ratios[1], width_ratios[-1])

# 10. 最终绘图
grid.arrange(
  grobs = all_grobs,
  nrow = 1,
  widths = width_ratios_combined
)


