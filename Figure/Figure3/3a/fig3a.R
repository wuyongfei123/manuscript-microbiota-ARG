# 准备工作环境
rm(list=ls())

# 加载R包
library(ggplot2)
library(vegan)     
library(dplyr)    
library(readxl)   
library(tibble)    

# 读取丰度数据
data <- read_excel("ARGs_Abundance.xlsx") %>%
  column_to_rownames(var = "Sample")  

# 读取分组信息
group <- read_excel("sample_gut_locations.xlsx") %>%
  column_to_rownames(var = "Sample")  

# 检查样本名是否一致
if (!all(rownames(data) %in% rownames(group))) {
  stop("Error: 样本名在丰度数据和分组信息中不一致，请检查！")
}

data <- as.data.frame(data)  # 确保数据是一个标准数据框

# 移除全零行
data <- data[rowSums(data) > 0, ]


# 计算样本间的距离，使用Bray-Curtis距离
dist <- vegdist(data, method = "bray", diag = TRUE, upper = TRUE)

# 将距离矩阵转换为matrix
dist <- as.matrix(dist)

# 执行PCoA分析
pcoa <- cmdscale(dist, eig = TRUE)

# 提取各维度的占比与解释率
eig <- summary(eigenvals(pcoa))

# 设置各维度的名字，从PCoA1开始
axis <- paste0("PCoA", 1:ncol(pcoa$points))

# 计算各轴解释率
explained_variance <- pcoa$eig / sum(pcoa$eig)
pco1 <- round(explained_variance[1] * 100, 2)
pco2 <- round(explained_variance[2] * 100, 2)

# 设置x轴和y轴的标题
xlab <- paste0("PCoA1 (", pco1, "%)")
ylab <- paste0("PCoA2 (", pco2, "%)")

# 获取各样本在前两个维度的坐标
pcoa_points <- as.data.frame(pcoa$points)
colnames(pcoa_points) <- c("V1", "V2")
pcoa_points$Sample <- rownames(pcoa_points)

# 合并样本坐标和分组信息
pcoa_points <- pcoa_points %>% 
  mutate(group = group[rownames(pcoa_points), 1])  # 提取分组信息


# 筛选胃肠段数据
pcoa_points_filtered <- pcoa_points %>% filter(group %in% c("GS", "MS", "DC", "JC", "IC", "CC", "CR", "Feces"))

p <- ggplot(pcoa_points_filtered, aes(x = V1 * (-1), y = V2 * (-1), color = group)) +
  geom_point(size = 3, alpha = 0.7) +  
  labs(x = xlab, y = ylab, color = "Gut Location") +  # 这里修改图例标题
  theme_bw() +
  theme(
    # 全局字体设置
    text = element_text(family = "Arial", face = "bold", size = 16),
    plot.title = element_text(hjust = 0.5, size = 12),
    # 坐标轴标签加粗
    axis.title = element_text(face = "bold"),
    # 坐标轴刻度加粗
    axis.text = element_text(face = "bold"),
    # 图例标签加粗
    legend.text = element_text(face = "bold"),
    legend.title = element_text(face = "bold")
  ) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(
    values = alpha(  # 使用alpha函数添加透明度
      c("GS" = "#EE7424", 
        "MS" = "#5E5094",
        "DC" = "#E86976",
        "JC" = "#EFD19B",
        "IC" = "#997942",
        "CC" = "#779A4F",
        "CR" = "#DC9FC8",
        "Feces" = "#7fabc4"),
      alpha = 0.9  # 透明度值 (0-1)
    ),
    limits = c("GS", "MS", "DC", "JC", "IC", "CC", "CR", "Feces")
  )

p







