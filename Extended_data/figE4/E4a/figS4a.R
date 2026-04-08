rm(list = ls())

library(readxl)
library(fmsb)
library(scales)

results <- read_excel("不同因素对耐药组的影响.xlsx")

# 使用 Adjusted R²
radar_data <- results %>%
  dplyr::select(Variable, R2adjust_rda, P_PERMANOVA) %>%
  arrange(desc(R2adjust_rda))

# 把变量名设为行名
radar_data <- as.data.frame(radar_data)
rownames(radar_data) <- radar_data$Variable
radar_data$Variable <- NULL


max_val <- max(radar_data$R2adjust_rda, na.rm = TRUE)

radar_plot_data <- rbind(
  max = rep(max_val, nrow(radar_data)),
  min = rep(0, nrow(radar_data)),
  values = radar_data$R2adjust_rda
)

colnames(radar_plot_data) <- rownames(radar_data)
radar_plot_data <- as.data.frame(radar_plot_data)

# 所有变量 P = 0.001 → 全部 "***"
radar_data$Sig <- "***"

# 把星号加到变量名
new_names <- paste0(rownames(radar_data), " ", radar_data$Sig)

# 更新列名
colnames(radar_plot_data) <- new_names


radarchart(
  radar_plot_data,
  axistype = 1,
  pcol = "#2C7BB6",
  pfcol = scales::alpha("#2C7BB6", 0.4),
  plwd = 2,
  cglcol = "grey80",
  cglty = 1,
  axislabcol = "grey30",
  caxislabels = seq(0, ceiling(max_val*100)/100, length.out = 5),
  vlcex = 1.1
)


