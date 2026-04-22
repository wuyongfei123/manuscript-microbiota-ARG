rm(list=ls())
# 加载必要的库
library(dplyr)
library(ggplot2)
library(readr)

# 读取数据
final_Duck_ARG_MGE_filtered <- read_csv("duck_ARG_MGE.csv")
final_Human_ARG_MGE_filtered <- read_csv("human_ARG_MGE.csv")

Duck_arg_order <- final_Duck_ARG_MGE_filtered %>%
  group_by(ARG_type) %>%
  summarise(Total_Duck = sum(Duck_Count_log10)) %>% 
  arrange(desc(Total_Duck)) %>%
  pull(ARG_type)

final_Human_ARG_MGE_filtered$ARG_type <- factor(final_Human_ARG_MGE_filtered$ARG_type, levels =Duck_arg_order)
final_Duck_ARG_MGE_filtered$ARG_type <- factor(final_Duck_ARG_MGE_filtered$ARG_type, levels = Duck_arg_order)


mge_levels <- c("transposase","IS91", "integrase", "IS26", "IS903")
mge_colors <- c(
  "transposase" = "#a30543",
  "IS91" = "#F6DEA4",
  "integrase" = "#f36f43",
  "IS26" = "#4965b0",
  "IS903" = "#80cba4"
)

final_Duck_ARG_MGE_filtered$Duck_MGE_Type <- factor(final_Duck_ARG_MGE_filtered$Duck_MGE_Type, levels = mge_levels)
final_Human_ARG_MGE_filtered$Human_MGE_Type <- factor(final_Human_ARG_MGE_filtered$Human_MGE_Type, levels = mge_levels)

Duck_n_groups <- length(levels(final_Duck_ARG_MGE_filtered$ARG_type))
Human_n_groups <- length(levels(final_Human_ARG_MGE_filtered$ARG_type))

bold_arial_theme <- function() {
  theme(
    text = element_text(family = "Arial", face = "bold", color = "black"),
    plot.title = element_text(family = "Arial", face = "bold", size = 12),
    axis.title = element_text(family = "Arial", face = "bold", size = 12),
    axis.title.x = element_text(margin = margin(t = 10)),
    axis.title.y = element_text(margin = margin(r = 10)),
    axis.text = element_text(family = "Arial", face = "bold", size = 12, color = "black"),
    legend.title = element_text(family = "Arial", face = "bold", size = 12),
    legend.text = element_text(family = "Arial", face = "bold", size = 12),
    panel.grid = element_blank(),
    panel.border = element_rect(color = "black", fill = NA),
    plot.margin = margin(10, 15, 10, 15)
  )
}

p1 <- ggplot(final_Duck_ARG_MGE_filtered) +
  annotate("rect", xmin = seq(0.5, Duck_n_groups - 0.5, by = 2), xmax = seq(1.5, Duck_n_groups + 0.5, by = 2), ymin = 0, ymax = 5, fill = "#f5f5f5", alpha = 0.3) +
  geom_hline(yintercept = seq(0, 5, 1), color = "#e6e6e6", linewidth = 0.3) +
  geom_col(aes(x = ARG, y = Duck_Count_log10, fill = Duck_MGE_Type), width = 0.7, position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = mge_colors) +
  scale_y_continuous(expand = c(0, 0), breaks = seq(0, 5, 1), limits = c(0, 5)) +
  labs(x = "", y = expression(paste(bold("Number of shared MGE Types in Duck"))), fill = "Shared MGE Type between duck and human") +
  theme_bw() +
  bold_arial_theme() +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), legend.position = "top") +
  guides(fill = guide_legend(nrow = 1, keywidth = 1.2, keyheight = 1.2, title.position = "top"))

p1

p2 <- ggplot(final_Human_ARG_MGE_filtered) +
  annotate("rect", xmin = seq(0.5, Human_n_groups - 0.5, by = 2), xmax = seq(1.5, Human_n_groups + 0.5, by = 2), ymin = 0, ymax = 5, fill = "#f5f5f5", alpha = 0.3) +
  geom_hline(yintercept = seq(0, 5,1), color = "#e6e6e6", linewidth = 0.3) +
  geom_col(aes(x = ARG, y = Human_Count_log10, fill = Human_MGE_Type), width = 0.7, position = position_stack(reverse = TRUE)) +
  scale_fill_manual(values = mge_colors) +
  scale_y_reverse(expand = c(0, 0), breaks = seq(0, 5,1), limits = c(5, 0)) +
  labs(x = "High Risk ARGs", y = expression(paste(bold("Number of shared MGE Types in Human")))) +
  theme_bw() +
  bold_arial_theme() +
  theme(legend.position = "none", axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1), axis.title.x = element_text(margin = margin(t = 15)))

p2

#宿主菌数据
bacteria_merged_genus_data <- read_csv("Duck_human_shared_genus.csv")

bacteria_merged_genus_data$ARG_type <- factor(bacteria_merged_genus_data$ARG_type, levels = Duck_arg_order)

# ggplot绘制热图条
p3 <- ggplot(bacteria_merged_genus_data, 
             aes(x = ARG_type, y = 1, fill = genus_count)) +
  geom_tile(color = "black") +
  geom_text(aes(label = genus_count), color = "black", size = 3.5) +
  scale_fill_gradientn(
    name = "Shared Genus Count",
    colors = c("white", "#69a9d2", "#c44c4b"), 
    limits = c(0, max(bacteria_merged_genus_data$genus_count))
  ) +
  guides(fill = guide_colorbar(title.position = "top")) + # 图例标题置顶
  theme_void() +
  theme(
    axis.text.x = element_blank(),
    plot.margin = margin(0, 15, 0, 15),
    legend.position = "right",  # 图例显示在右侧
    
    # 设置图例字体样式
    legend.title = element_text(
      family = "Arial",         # 使用Arial字体
      face = "bold",            # 加粗
      size = 10,                # 标题字体大小
      margin = margin(b = 5)    # 标题底部间距
    ),
    legend.text = element_text(
      family = "Arial",         # 使用Arial字体
      size = 8                  # 图例标签字体大小
    )
  )


p3
