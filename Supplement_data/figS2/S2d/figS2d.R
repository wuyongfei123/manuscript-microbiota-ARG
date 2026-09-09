rm(list=ls())

# 加载必要的包
library(ggplot2)
library(readr)

tet_MGE <- read_csv("tet_ARG_MGE.csv")

# 手动调整因子顺序
mge_order <- c(
  "Tn6994",
  "Tn6073",
  "Tn6198",
  "Others",
  "Tn6303",
  "Tn6168",
  "Tn1721",
  "Tn10",
  "ColRNAI",
  "repC(Cassette)",
  "repC(pS0385p1)",
  "rep(SAP060B)",
  "Tn1116",
  "Tn6084",
  "repA(pSGG1)",
  "IS4351",
  "Tn4551",
  "Tn6000",
  "ISSag10",
  "CDS(p121BS)",
  "repA(pEF418)",
  "Tn6079",
  "rep(pSGG1)",
  "ICE"
)

# 定义 Species 的颜色映射
custom_colors <- c(
  "Tn6994" = "#a0bed2",
  "rep(pSGG1)" = "#90b9b3",
  "repA(pEF418)" = "#e36c90",
  "Tn6073" = "#C9A87C",        
  "Tn6198" = "#8A9B6E",      
  "Others" = "#B0ACAB",
  "Tn6079" = "#f1a9ca",
  "Tn6303" = "#B8956A",        
  "Tn6168" = "#78B8B5",       
  "Tn1721" = "#C97A6B",        
  "Tn10" = "#6DA8A0",         
  "ColRNAI" = "#C9B85C",       
  "repC(Cassette)" = "#B892B8",
  "repC(pS0385p1)" = "#7DAF7D", 
  "rep(SAP060B)" = "#C99A5C",   
  "Tn1116" = "#95484B",
  "Tn6084" = "#ccc06d",
  "repA(pSGG1)" = "#6A85B8",   
  "IS4351" = "#DAA520",
  "Tn4551" = "#6A4D52",
  "Tn6000" = "#C97A8A",        
  "ISSag10" = "#bec6a0",
  "CDS(p121BS)" = "#8A6B8A",
  "ICE" = "#bed487"


ARG_order <- c(
  "tet(Q)",
  "tet(M)",
  "tet(45)",
  "tet(O)",
  "tet(40)",
  "tet(O/W/32/O)",
  "tet(32)",
  "tet(S)",
  "tet(K)",
  "tet(44)",
  "tet(A)",
  "tet(C)",
  "tet(W)",
  "tet(B)",
  "tet(O/32/O)",
  "tet(36)",
  "tet(W/N/W)"
)


# 设置ARG_type和MGE_subtype的因子顺序
tet_MGE <- tet_MGE %>%
  mutate(ARG_type = factor(ARG_type, levels = ARG_type_order), # 设置ARG_type的因子顺序为按累加和降序
         MGE_subtype = factor(MGE_subtype, levels = mge_order)) # 设置MGE的因子顺序



# 绘制百分比堆叠柱状图
p <- ggplot(data = tet_MGE, aes(x = ARG_type, y = count, fill = MGE_subtype)) +
  geom_bar(stat = "identity", position = "fill") +
  scale_fill_manual(values = custom_colors) +     
  scale_y_continuous(labels = scales::percent_format()) + 
  theme_minimal() +                                
  labs(
    x = "ARG type", 
    y = "Proportion of MGE subtypes (%)", 
    fill = "MGE subtype"
  ) +
  theme(
    text = element_text(family = "Arial", face = "bold"), 
    axis.text.x = element_text(angle = 90, hjust = 1, size = 15),
    axis.text.y = element_text(size = 16),
    axis.title.x = element_text(size = 16),
    axis.title.y = element_text(size = 16),
    plot.title = element_text(hjust = 0.5),
    legend.position = "right",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13, face = "bold"),
    panel.grid.major = element_blank(), 
    panel.grid.minor = element_blank(),  
    panel.background = element_blank(),
    plot.background = element_blank()
  ) +
  guides(fill = guide_legend(ncol = 1))            

# 显示图形
p
