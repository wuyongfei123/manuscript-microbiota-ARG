rm(list = ls())


library(tidyverse)
library(readxl)
library(rstatix)
library(dplyr)
library(ggpubr)
#输入数据
genus_KO_prevalence <- read_excel("Genus-DAP-KO-MAG-prevalence.xlsx")
fixed_genus_KO_prevalence <- genus_KO_prevalence [c(-1),]
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence %>%
  mutate(Symbol_KO = paste(Symbol, KO_id, sep = "-")) %>%
  select(Symbol_KO, everything())
fixed_genus_KO_prevalence <- fixed_genus_KO_prevalence[,c(-2,-3)]


#提取显著KO
genes_to_extract <- c("murE-K01928", "mtgA-K03814", "dacB-K07259", 
                      "dgkA-K00887", "ftsI-K03587", "dacC, dacA, dacD-K07258",
                      "pbp5-K18149", "spoVD-K08384", "mrdA-K05515", 
                      "vanY-K07260", "pbpA-K05364")

significant_genus_KO_prevalence <- fixed_genus_KO_prevalence %>%
  filter(Symbol_KO %in% genes_to_extract)

# 定义分组
bacteroidaceae_genus <- c(
  "g__Phocaeicola","g__Phocaeicola_A", "g__43-108", "g__Alloprevotella", 
  "g__Avibacteroides", "g__Bacteroides", "g__Mediterranea", 
  "g__Paraprevotella", "g__Prevotella","g__UBA1794","g__UBA4372","g__UBA6398"
)

# DAP-type列都以"g__"开头，但不包括特定的组
all_genus_cols <- colnames(genus_KO_prevalence)[grepl("^g__", colnames(genus_KO_prevalence))]

# 定义Lys-type genus包含的属
lys_type_genus <- c("g__Aliicoccus", "g__Jeotgalicoccus", "g__Staphylococcus", 
                    "g__Enterococcus", "g__Lactococcus", "g__Streptococcus")


# 定义各组包含的列
group_cols <- list(
  "DAP-type genus from Bacteroidaceae" = bacteroidaceae_genus,
  "other DAP-type genus" = setdiff(
    all_genus_cols[!all_genus_cols %in% c(lys_type_genus)], 
    bacteroidaceae_genus
  ),
  "Lys-type genus" = lys_type_genus 
)

# 整理数据为长格式
genus_KO_prevalence_long <- significant_genus_KO_prevalence %>%
  # 转换为长格式
  pivot_longer(
    cols = -c(Symbol_KO),  # 保留Symbol和KO_id列
    names_to = "Genus",
    values_to = "Prevalence"
  ) %>%
  # 添加分组信息
  mutate(
    group = case_when(
      Genus %in% bacteroidaceae_genus ~ "DAP-type genus from Bacteroidaceae",
      Genus %in% lys_type_genus ~ "Lys-type genus",  # 修改点：使用lys_type_genus向量
      TRUE ~ "Other DAP-type genus"
    ),
    # 因子化组别，控制顺序
    group = factor(group, 
                   levels = c("DAP-type genus from Bacteroidaceae", 
                              "Other DAP-type genus", 
                              "Lys-type genus"))
  )

genus_KO_prevalence_long$Prevalence <- as.numeric(genus_KO_prevalence_long$Prevalence)


# 多个Symbol_KO的版本
library(tidyverse)
library(ggpubr)
library(rstatix)

# 1. 确保数据格式正确
genus_KO_prevalence_long$Symbol_KO <- factor(genus_KO_prevalence_long$Symbol_KO)

#去掉3个标准差以外的数值
filtered_genus_KO_prevalence_long <- genus_KO_prevalence_long %>%
  group_by(Symbol_KO, group) %>%
  filter(Prevalence >= (mean(Prevalence, na.rm = TRUE) - 3 * sd(Prevalence, na.rm = TRUE)) &
           Prevalence <= (mean(Prevalence, na.rm = TRUE) + 3 * sd(Prevalence, na.rm = TRUE))) %>%
  ungroup()

pairwise_results <- filtered_genus_KO_prevalence_long  %>%
  #filter(Symbol_KO %in% significant_KO) %>%
  # 确保数据格式正确
  mutate(across(where(is.factor), as.character)) %>%
  # 按KO分组
  group_by(Symbol_KO) %>%
  group_modify(~ {
    # 获取当前KO下所有存在的组
    groups <- unique(.x$group)
    
    # 确保有足够的组进行比较
    if (length(groups) < 2) {
      return(data.frame())
    }
    
    # 生成所有两两组合
    group_pairs <- combn(groups, 2, simplify = FALSE)
    
    # 对每一对组合进行Wilcoxon检验
    map_dfr(group_pairs, function(pair) {
      group1 <- pair[1]
      group2 <- pair[2]
      
      # 过滤出当前要比较的两组数据
      test_data <- .x %>% 
        dplyr::filter(group %in% c(group1, group2))
      
      # 确保两组都有数据
      if (nrow(test_data) == 0) {
        return(data.frame(
          group1 = group1,
          group2 = group2,
          p.value = NA_real_
        ))
      }
      # 执行Wilcoxon秩和检验
      wilcox_test <- wilcox.test(Prevalence ~ group, data = test_data, exact = FALSE)
      
      # 返回结果
      data.frame(
        group1 = group1,
        group2 = group2,
        p.value = wilcox_test$p.value
      )
    })
  }) %>%
  ungroup() %>%
  # 对每个KO内的所有两两比较的p值进行多重检验校正
  group_by(Symbol_KO) %>%
  mutate(p.adj = p.adjust(p.value, method = "none"),
         significance = case_when(
           p.adj < 0.001 ~ "***",
           p.adj < 0.01 ~ "**",
           p.adj < 0.05 ~ "*",
           TRUE ~ "ns"
         )) %>%
  ungroup()

pvalue_df <- pairwise_results %>%
  mutate(
    label = ifelse(
      p.adj < 0.001,
      paste0("p = ", formatC(p.adj, format = "e", digits = 2)),
      paste0("p = ", formatC(p.adj, format = "f", digits = 3))
    )
  ) %>%
  group_by(Symbol_KO) %>%
  mutate(
    y.position = max(
      filtered_genus_KO_prevalence_long$Prevalence[
        filtered_genus_KO_prevalence_long$Symbol_KO == unique(Symbol_KO)
      ],
      na.rm = TRUE
    ) + seq_len(n()) * 0.05
  ) %>%
  ungroup()

filtered_genus_KO_prevalence_long$group <- factor(
  filtered_genus_KO_prevalence_long$group,
  levels = c(
    "DAP-type genus from Bacteroidaceae",
    "Other DAP-type genus",
    "Lys-type genus"
  )
)



#带误差棒的柱状图
# 计算均值和标准误（或标准差）用于柱状图
summary_data <- filtered_genus_KO_prevalence_long %>%
  group_by(Symbol_KO, group) %>%
  summarise(
    mean_prevalence = mean(Prevalence),
    se_prevalence = sd(Prevalence) / sqrt(n()),  # 标准误
    sd_prevalence = sd(Prevalence),              # 标准差
    .groups = 'drop'
  )

summary_data$group <- factor(
  summary_data$group,
  levels = c(
    "DAP-type genus from Bacteroidaceae",
    "Other DAP-type genus",
    "Lys-type genus"
  )
)

ko_order <- c(
  "murE-K01928",
  "mtgA-K03814",
  "dacB-K07259",
  "ftsI-K03587",
  "mrdA-K05515",
  "dgkA-K00887",
  "dacC, dacA, dacD-K07258",
  "pbp5-K18149",
  "vanY-K07260",
  "spoVD-K08384",
  "pbpA-K05364"
)

summary_data$Symbol_KO <- factor(
  summary_data$Symbol_KO,
  levels = ko_order
)

pvalue_df$group1 <- factor(
  pvalue_df$group1,
  levels = levels(summary_data$group)
)
pvalue_df$group2 <- factor(
  pvalue_df$group2,
  levels = levels(summary_data$group)
)

pvalue_df$Symbol_KO <- factor(
  pvalue_df$Symbol_KO,
  levels = ko_order
)

library(ggplot2)
library(ggpubr)
library(ggh4x)

p <- ggplot(
  summary_data,
  aes(x = group, y = mean_prevalence, fill = group)
) +
  geom_col(
    width = 0.7,
    color = "black"
  ) +
  geom_errorbar(
    aes(
      ymin = mean_prevalence - se_prevalence,
      ymax = mean_prevalence + se_prevalence
    ),
    width = 0.2,
    linewidth = 0.6
  ) +
  facet_wrap(~ Symbol_KO, scales = "free_y", ncol = 4) +
  stat_pvalue_manual(
    pvalue_df,
    label = "label",
    xmin = "group1",
    xmax = "group2",
    y.position = "y.position",
    tip.length = 0.01,
    size = 4
  ) +
  # 为每个分面单独设置y轴范围
  facetted_pos_scales(
    y = list(
      Symbol_KO == "murE-K01928" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1.2)
      ),
      Symbol_KO =="mtgA-K03814" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 0.5)
      ),
      Symbol_KO =="dacB-K07259" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1)
      ),
      Symbol_KO =="ftsI-K03587" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1.2)
      ),
      Symbol_KO =="mrdA-K05515" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1.2)
      ),
      Symbol_KO == "dgkA-K00887" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1)
      ),
      Symbol_KO == "dacC, dacA, dacD-K07258" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1)
      ),
      Symbol_KO =="pbp5-K18149" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 0.5)
      ),
      Symbol_KO =="vanY-K07260" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 1)
      ),
      Symbol_KO == "spoVD-K08384" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 0.6)
      ),
      Symbol_KO =="pbpA-K05364" ~ scale_y_continuous(
        expand = expansion(mult = c(0, 0.2)),
        limits = c(0, 0.5)
      )
    )
  ) +
  scale_fill_manual(
    values = c(
      "DAP-type genus from Bacteroidaceae" = "#c9605f",
      "Other DAP-type genus"               = "#646e9a",
      "Lys-type genus"                     = "#eab676"
    )
  ) +
  labs(
    x = NULL,
    y = "Mean prevalence"
  ) +
  theme_minimal() +
  theme(
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid.major = element_line(color = "grey90", size = 0.2),
    panel.grid.minor = element_blank(),
    axis.line = element_line(color = "black", size = 0.5),
    plot.background = element_rect(fill = "white", color = NA),
    legend.position = "none",
    axis.text.x = element_text(
      size = 13, family = "Arial", face = "bold",
      color = "black", angle = 60, vjust = 1,hjust = 1
    ),
    axis.text.y = element_text(
      size = 13, family = "Arial", color = "black"
    ),
    axis.title.x = element_text(
      size = 13, family = "Arial", face = "bold",
      margin = margin(t = 10)
    ),
    axis.title.y = element_text(
      size = 13, family = "Arial", face = "bold",
      margin = margin(r = 10)
    ),
    strip.background = element_rect(
      fill = "#87CEEB", color = "black", size = 0.5
    ),
    strip.text = element_text(
      size = 12, face = "bold", color = "black",
      margin = margin(2, 0, 2, 0)
    ),
    panel.spacing = unit(1.2, "lines")
  )

p
