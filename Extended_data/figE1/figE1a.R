#清理环境
rm(list=ls())

#加载R包
library(glue)
library(dplyr)
library(tidyr)
library(ggplot2)
library(tibble)
library(visbuilder)
library(ggtree)
library(ggtreeExtra)
library(ggnewscale)
library(readr)
library(readxl)
library(Cairo)
library(ape)


#数据输入
ARG_bacteria_data <- read_csv("ARG-host.csv")
ARG_bacteria_data <- ARG_bacteria_data %>%
  filter(kingdom == "k__Bacteria")
ARG_genus_data <- ARG_bacteria_data[,c(1,4,10,12)]
all_ARG_genus_data <- ARG_genus_data %>%
  group_by(ARG_type, phylum,genus_without_unknown) %>%
  summarise(orf_count = sum(orf_count), .groups = "drop")  # .groups = "drop" 解除分组结构


#树文件
# 合并Phylum和genus列
ARG_genus_data <- all_ARG_genus_data %>%
  # 使用unite()合并两列
  unite(
    col = "Phylum_genus", # 新列名称
    phylum, genus_without_unknown,        # 要合并的列
    sep = ";",              # 分隔符（可根据需要修改为_、-等）
    remove = FALSE          # 保留原始列
  )

filter_ARG_genus_data <- ARG_genus_data %>%
  filter(genus_without_unknown != "Other")


top_genus <- ARG_genus_data %>%
  group_by(genus_without_unknown) %>%
  summarise(total_count = sum(orf_count)) %>%
  arrange(desc(total_count)) %>%
  slice_head(n = 101) %>%  
  pull(genus_without_unknown)         


final_data <- ARG_genus_data %>%
  filter(genus_without_unknown %in% top_genus)

# 4. 按新分类聚合数据
filter_final_data <- final_data %>%
  group_by(ARG_type, genus_without_unknown) %>%
  summarise(Total_Count = sum(orf_count), .groups = "drop") #Other的合并在一起，方便过滤

filter_final_data <- filter_final_data %>%
  filter(genus_without_unknown != "Other")

filter_orf_count <- filter_final_data %>%
  group_by(genus_without_unknown) %>%
  summarise(count = sum(Total_Count))


ARG_genus_data <- pivot_wider(filter_final_data,
                                names_from = ARG_type,
                                values_from = Total_Count,
                                values_fill =  0)
ARG_genus_data <- column_to_rownames(ARG_genus_data, var = "genus_without_unknown")
ARG_genus_data.scaled<-scale(ARG_genus_data)##标准化数据

#genus对应phylum文件
genus_phylum <- filter_ARG_genus_data  %>% 
  filter(genus_without_unknown %in% top_genus)

genus_phylum <- genus_phylum[,c(3,4)]
genus_phylum <- genus_phylum %>%
  distinct()


#genus对应ARGs文件
phylum_ARG <- filter_ARG_genus_data %>%
  filter(genus_without_unknown %in%  genus_phylum$genus_without_unknown)



phylum_ARG_count <- phylum_ARG %>%
  group_by(genus_without_unknown) %>%
  summarise(count = n()) %>%
  ungroup()

# 计算每个物种的总ARGs数量
genus_total_ARG_count <- phylum_ARG_count %>%
  group_by(genus_without_unknown) %>%
  summarise(Total_ARGs = sum(count)) %>%
  ungroup() %>%
  # 添加label列
  mutate(label = genus_without_unknown)

#ARG对应的药物类型
ARG_Drug_class <- read_csv("D:/2025_1162_duck_args/final_risk/ARG-Drug.csv")
ARG_ARG_Drug_Class <- left_join(phylum_ARG,ARG_Drug_class,by = c("ARG_type" = "ARGs_name"))
ARG_ARG_Drug_Class <- ARG_ARG_Drug_Class %>%
  group_by(genus_without_unknown,Drug_Class) %>%
  summarise(count = sum(orf_count)) %>%
  ungroup()


filter_ARG_Drug_class <- ARG_ARG_Drug_Class %>%
  mutate(Drug_Class = case_when(
    Drug_Class %in% c("multidrug", "glycopeptide", "aminoglycoside", 
                     "tetracycline", "nitroimidazole", "M-L-S", "FT") ~ Drug_Class,
    TRUE ~ "Other"  # 其余药物类型归为Other
  )) %>%
  group_by(genus_without_unknown, Drug_Class) %>%
  summarise(count = sum(count), .groups = "drop")  # 按新分组聚合Count值

filter_ARG_Drug_class_phylum <- left_join(filter_ARG_Drug_class,genus_phylum,by = "genus_without_unknown")

#保留每个门下的所有属，包括那些没有aminoglycoside的属（计数为0）
filter_ARG_Drug_class_phylum_sorted <- filter_ARG_Drug_class_phylum %>%
  # 按phylum和genus分组
  group_by(phylum, genus_without_unknown) %>%
  # 计算每个属的aminoglycoside的总Count（可能没有记录）
  summarise(
    Total_amin = sum(count[Drug_Class == "aminoglycoside"]), 
    .groups = "drop") %>%
  # 如果Total_amin为NA，则替换为0（但sum求和如果不存在则为0，所以无需替换？因为sum(数值向量为空)返回0？）
  # 然后按门分组排序
  group_by(phylum) %>%
  arrange(desc(Total_amin), .by_group = TRUE)


# 修正物种门分类数据框（添加label列）
genus_phylum <- filter_ARG_Drug_class_phylum_sorted %>% 
  mutate(label = genus_without_unknown) %>% 
  select(label, phylum,Total_amin)

  
# 创建自定义排序因子（先按门排序，然后按物种名称排序）
genus_phylum_sorted <- genus_phylum %>%
  arrange(phylum, desc(Total_amin)) %>%      # 先按门分组，再按计数降序
  group_by(phylum) %>%                   # 按门分组
  mutate(rank = rank(-Total_amin, ties.method = "first")) %>%  # 添加排名列
  ungroup() %>%                         # 取消分组
  arrange(phylum, rank) %>%             # 按门和排名排序
  pull(label)                           # 提取Genus列作为向量

# 转换为因子确保正确顺序
genus_total_ARG_count$label <- factor(genus_total_ARG_count$label, levels = genus_phylum_sorted)
filter_ARG_Drug_class$genus_without_unknown <- factor(filter_ARG_Drug_class$genus_without_unknown, levels = genus_phylum_sorted)
genus_phylum$label <- factor(genus_phylum$label, levels = genus_phylum_sorted)

# 创建星形树（所有物种直接从中心延伸）
star_tree <- stree(n = length(genus_phylum_sorted), tip.label = genus_phylum_sorted, type = "star")


# 创建基础树图（使用圆形布局）
p <- ggtree(star_tree, layout = "fan", open.angle = 5, size = 0) + 
  theme(legend.position = "right",
        text = element_text(family = "Arial"), # 全局Arial字体
        legend.text = element_text(family = "Arial"), # 图例标签
        legend.title = element_text(family = "Arial", face = "bold")) # 图例标题加粗
#print(p)


# 添加门分类点和Genus名称
p1 <- p %<+% genus_phylum +
  geom_tippoint(
    aes(color = phylum),
    size = 5,
    alpha = 0.8
  ) +
  # 添加Genus名称标签
  geom_tiplab(
    aes(label = label),   
    size = 4,          
    offset = -0.02,     
    hjust = -0.2,         
    family = "Arial",    
    face = "bold",
    color = "black",     
    align = TRUE          
  ) +
  scale_color_manual(
    name = "Phylum",
    values = c(
      "p__Actinomycetota" = "#b3c38a",
      "p__Bacillota" = "#82A6C1",
      "p__Bacteroidota" = "#ed8687",
      "p__Campylobacterota" = "#b7a8cf",
      "p__Deferribacterota" = "#E8E49F",
      "p__Fusobacteriota" = "#85b8bb",
      "p__Pseudomonadota" = "#efa484",
      "p__Spirochaetota" = "#b6766c",
      "p__Thermodesulfobacteriota" = "#74352c"
    ),
    na.value = "gray",
    guide = guide_legend(
      ncol = 1,
      keywidth = 0.8,
      keyheight = 0.8,
      title.position = "top",
      title.hjust = 0,
      title.theme = element_text(
        family = "Arial",
        face = "bold",
        size = 10
      ),
      label.theme = element_text(
        family = "Arial",
        size = 8
      ),
      order = 4
    )
  ) +
  new_scale_fill()
p1

# 添加总ARGs数量热图（中间圈）
p2 <- p1 +
  geom_fruit(
    data = filter_orf_count,
    geom = geom_tile,
    mapping = aes(y = genus_without_unknown, fill = count),
    width = 0.08,
    offset = -0.07,
    color = "white",
    size = 0.2
  ) +
  scale_fill_gradientn(
    name = "ARGs Count", 
    colours = c(
      "#ffffc1",  
      "#fde18d",  
      "#a8d969",  
      "#19974e",  
      "#f26d43",   
      "#d53127"
    ),
    #breaks = c(500, 1000, 5000, 10000, 12000),
    #labels = c("500", "1000", "5000", "10000", "12000"),
    na.value = "gray",
    guide = guide_colorbar(
      title.position = "top",
      title.hjust = 0,
      barwidth = unit(5, "mm"),
      barheight = unit(20, "mm"),
      direction = "vertical",
      label.theme = element_text(
        family = "Arial",
        size = 8,
        vjust = 0.5
      ),
      title.theme = element_text(
        family = "Arial", 
        face = "bold",
        size = 10
      )
    )
  ) +
  new_scale_fill()
p2



# 添加总ARGs类型数量热图（中间圈）
p3 <- p2 +
  geom_fruit(
    data = genus_total_ARG_count,
    geom = geom_tile,
    mapping = aes(y = label, fill = Total_ARGs),
    width = 0.08,
    offset = -0.07,
    color = "white",
    size = 0.2
  ) +
  scale_fill_gradientn(
    name = "ARGs Type Count", 
    colours = c(
      "#eaeff6",  # <25
      "#98cadd",  # 25
      "#61aacf",  # 50
      "#e3b3bb",  # 75
      "#c47b91",  # 100
      "#8f476d"   # >125
    ),
    values = scales::rescale(c(
      0, 25, 50, 75, 100, 125
    )),
    breaks = c(25, 50, 75, 100, 125),
    limits = c(
      min(genus_total_ARG_count$Total_ARGs),
      max(genus_total_ARG_count$Total_ARGs)
    ),
    na.value = "gray",
    guide = guide_colorbar(
      title.position = "top",
      title.hjust = 0,
      barwidth = unit(5, "mm"),
      barheight = unit(20, "mm"),
      direction = "vertical",
      
      # 添加以下两个参数修改字体
      label.theme = element_text(family = "Arial",size = 8),
      title.theme = element_text(family = "Arial", face = "bold",size = 10)
    )
  ) +
  new_scale_fill()
p3

#最外圈画图
# 定义药物类别排序
drug_class_order <- c(
  "Other",
  "M-L-S", 
  "FT",
  "nitroimidazole",
  "multidrug",
  "aminoglycoside",
  "tetracycline",
  "glycopeptide"

)

# 定义精确匹配图片的药物类别颜色
drug_class_colors <- c(
  "multidrug" = "#C8B291",
  "nitroimidazole" = "#C1E7BD",
  "disinfecting agents and antiseptics" = "#FCE693",
  "macrolide" =  "#8DA0CB",
  "phenicol" =  "#dc9fa9",
  "M-L-S" = "#D8C4E9", 
  "lincosamide" = "#89D1CE" ,
  "FT" = "#F9B562",
  "phosphonic acid" = "#f07874",
  "glycopeptide" = "#DC9FC8",
  "aminoglycoside" ="#ACD68E",
  "tetracycline" = "#9EC9EB",
  "Other" = "gray"
)

# 应用排序和颜色映射
filter_ARG_Drug_class$Drug_Class <- factor(
  filter_ARG_Drug_class$Drug_Class,
  levels = drug_class_order
)

# 创建最外圈点图
p4 <- p3 +
  geom_fruit(
    data = filter_ARG_Drug_class,
    geom = geom_point,
    mapping = aes(
      y = genus_without_unknown,
      x = Drug_Class,
      size = count,
      fill = Drug_Class
    ),
    shape = 21,
    color = "black",
    stroke = 0.2,
    pwidth = 0.21,  
    offset = -0.14,
    axis.params = list(
      axis = "x",
      text.angle = 90,
      text.size = 0
    )
  ) +
  scale_fill_manual(
    name = "Drug Class",
    values = drug_class_colors,
    breaks = drug_class_order,
    guide = guide_legend(
      ncol = 2,
      keywidth = unit(0.4, "cm"),
      keyheight = unit(0.4, "cm"),
      override.aes = list(size = 3),
      order = 1,
      
      # 添加Arial字体设置
      label.theme = element_text(
        family = "Arial",
        size = 8  # 图例标签字号8
      ),
      title.theme = element_text(
        family = "Arial", 
        face = "bold",  # Arial Bold
        size = 10  # 标题字号10
      )
    )
  ) +
  scale_size_continuous(
    name = "Drug Class Count",
    range = c(1, 8),
    breaks = c(1,100,500, 1000,5000,10000,15000),
    guide = guide_legend(
      override.aes = list(fill = "gray70", color = "black"),
      order = 2,
      
      # 添加Arial字体设置
      label.theme = element_text(
        family = "Arial",
        size = 8  # 图例标签字号8
      ),
      title.theme = element_text(
        family = "Arial", 
        face = "bold",  # Arial Bold
        size = 10  # 标题字号10
      )
    )
  ) +
  theme(
    legend.position = "right",
    legend.box = "vertical",
    legend.spacing.y = unit(0.1, "cm"),
    
    # 全局图例字体设置
    legend.title = element_text(
      family = "Arial", 
      face = "bold", 
      size = 10  # 标题字号10
    ),
    legend.text = element_text(
      family = "Arial", 
      size = 8  # 标签字号8
    ),
    
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank(),
    axis.title.x = element_blank()
  )
p4
# 输出图形
Cairo::CairoPDF(file="D:\\2025_1162_duck_args\\结果图\\part1过程中间图\\contig宿主菌3.0.pdf",width=15,height=10)
p4
dev.off()

