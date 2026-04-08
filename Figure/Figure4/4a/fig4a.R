# 准备工作环境
rm(list = ls())

# 加载R包
library(ggplot2)   
library(vegan)      
library(readr)


pcoa_points_filtered <- read_csv("CC_Breed_pcoa_points.csv")


shape_mapping <- c(
  "CVD-XinYang" = 25, 
  "SXD-ZhuJi" = 18,         
  "LAD-NanChang" = 10,         
  "SRD-JiAn" = 13,        
  
  "PKD-HeiLongJiang" = 16,  
  "PKD-ShanDong" = 1,       
  
  "MAL-HaiYan" = 2,         
  "MAL-HangZhou" = 17,  
  
  "MSD-ShangHai" = 0, 
  "MSD-ZheJiang" = 15  
)


size_mapping <- c(
  "CVD-XinYang" = 2.5,        
  "SXD-ZhuJi" = 3.5,      
  "LAD-NanChang" = 2.5,        
  "SRD-JiAn" = 2.5,           
  
  "PKD-HeiLongJiang" = 2.5,   
  "PKD-ShanDong" = 2.5,       
  
  "MAL-HaiYan" = 2.5,         
  "MAL-HangZhou" = 2.5,       
  
  "MSD-ShangHai" = 2.5,       
  "MSD-ZheJiang" = 2.5        
)


p1 <- ggplot(pcoa_points_filtered, aes(x = V1, y = V3, color = application)) +
  geom_point(aes(shape = shape_id, size = shape_id), show.legend = TRUE) +
  scale_size_manual(values = size_mapping, guide = "none") +
  stat_ellipse(geom = "path", 
               aes(group = application, color = application), 
               linetype = "dashed", 
               level = 0.95, 
               size = 1) + 
  labs(x = xlab, y = ylab, 
       color = "Application",
       shape = "Breed-Collecting place") +
  theme_bw() +
  theme(
    plot.title = element_text(size = 12, hjust = 0.8),
    axis.title = element_text(family = "Arial", face = "bold", size = 14),
    axis.text = element_text(family = "Arial", face = "bold", size = 14),
    legend.title = element_text(family = "Arial", face = "bold", size = 10),
    legend.text = element_text(family = "Arial", face = "bold", size = 10)
  ) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_color_manual(values = c(
    "dual_type" = "#1f77b4",
    "egg_type" = "#ff7f0e",
    "meat_type" = "#d62728",
    "MAL" = "#1b7c3d"
  )) +
  scale_shape_manual(values = shape_mapping)

p1



