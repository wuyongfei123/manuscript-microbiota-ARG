# 清空工作环境
rm(list = ls())

# 加载所需的库
library(readr) 
library(tibble)

final_High_Risk_ARG_SRD_genus_MAG_abun <- read_csv("SRD_MAG_genus_abundance.csv")
final_High_Risk_filtered_ARG_abun_sorted <- read_csv("SRD_high_risk_ARG_abundance.csv")
final_High_Risk_ARG_SRD_genus_MAG_abun <- final_High_Risk_ARG_SRD_genus_MAG_abun %>%
  column_to_rownames(var = "Sample") 
final_High_Risk_filtered_ARG_abun_sorted <- final_High_Risk_filtered_ARG_abun_sorted  %>%
  column_to_rownames(var = "Sample")


#相关性分析
library(psych)
library(corrplot)
# 使用corr.test计算ARG和MAG之间的相关性
corr_results <- corr.test(final_High_Risk_ARG_SRD_genus_MAG_abun,final_High_Risk_filtered_ARG_abun_sorted,
                          method = "spearman",
                          adjust= "BH")  

result.r <- corr_results$r
result.p <- corr_results$p
result.p.adj <- corr_results$p.adj

# 将矩阵转换为数据框
r_df <- as.data.frame.table(result.r, responseName = "r_value")
p_df <- as.data.frame.table(result.p, responseName = "p_value")
p_adj_df <- as.data.frame.table(result.p.adj, responseName = "p_adj_value")
final_df <- cbind(r_df, p_value = p_df$p_value, p_adj_value = p_adj_df$p_adj_value)

#genus画图顺序
custom_y_order <- c(  "g__Merdivivens",
                      "g__Spyradenecus",
                      "g__Treponema_F",
                      "g__Parabacteroides",
                      "g__Anaerobiospirillum",
                      "g__Megamonas",
                      "g__Fournierella",
                      "g__Enterousia",
                      "g__Tidjanibacter",
                      "g__Alistipes",
                      "g__Mannheimia",
                      "g__Gallibacterium",
                      "g__Avoscillospira_A",
                      "g__Ligilactobacillus",
                      "g__Helicobacter_G",
                      "g__CAG-196" ,
                      "g__Fusobacterium_A",
                      "g__Enterococcus",
                      "g__Enterococcus_E",
                      "g__Escherichia",
                      "g__Mailhella",
                      "g__Desulfovibrio" ,
                      "g__Butyricicoccus",
                      "g__Duodenibacillus",
                      "g__UMGS263",
                      "g__Akkermansia",
                      "g__Brachyspira",
                      "g__Bacteroides",
                      "g__Prevotella",
                      "g__Alloprevotella",
                      "g__Mediterranea",
                      "g__Avibacteroides",
                      "g__Paraprevotella",
                      "g__Phocaeicola")

library(pheatmap)

# 根据p值矩阵创建显著性标记矩阵
sig_matrix <- matrix("", nrow = nrow(result.p.adj), ncol = ncol(result.p.adj))
sig_matrix[result.p.adj  < 0.05] <- "*"
sig_matrix[result.p.adj  < 0.01] <- "**"
sig_matrix[result.p.adj < 0.001] <- "***"
dimnames(sig_matrix) <- dimnames(result.p.adj)
# 调整数据矩阵的列顺序
result.r.ordered <- result.r[custom_y_order,]
sig_matrix.ordered <- sig_matrix[custom_y_order,] 

p <- pheatmap(result.r.ordered,
              scale = "none", 
              cluster_rows = FALSE, 
              cluster_cols = TRUE, 
              color = colorRampPalette(c("#3f8094","#77a5b4","#d7e6ed","white","#fdcab4","#fa8350","#d9372a"))(100), 
              display_numbers = sig_matrix.ordered,  
              number_color = "black",       
              fontsize_number = 10,          
              show_rownames = TRUE,
              show_colnames = TRUE,
              fontsize_row = 13, 
              fontsize_col = 13) 

p
