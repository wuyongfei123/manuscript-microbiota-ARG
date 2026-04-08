rm(list=ls())

# 加载必要的库
library(dplyr)    
library(ggplot2) 
library(readr)
library(scales)


# 自定义颜色
custom_colors <- c(
  "Risk I" = "#FF6B6B", 
  "Risk II" = "#9F8DB8",
  "Risk III" ="#ABC8E5",
  "Risk IV" = "#96CEB4", 
  "Risk V" =  "#FFEEAD" 
)



# 读取数据
ARG_RI <- read_csv("ARG_risk.csv")
ARG_RI$RI <- as.numeric(ARG_RI$RI)

# 设置 Risk_leve 列为因子并指定顺序
ARG_RI$Risk_Level <- factor(
  ARG_RI$Risk_Level, 
  levels = c("Risk I", "Risk II", "Risk III", "Risk IV", "Risk V") # 指定所需的顺序
)

levels(ARG_RI$Risk_Level)[1] <- "Risk I"
levels(ARG_RI$Risk_Level)[2] <- "Risk II"
levels(ARG_RI$Risk_Level)[3] <- "Risk III"
levels(ARG_RI$Risk_Level)[4] <- "Risk IV"
levels(ARG_RI$Risk_Level)[5] <- "Risk V"

# 自定义非线性变换函数：新比例
custom_trans <- trans_new(
  name = "new_nonlinear",
  transform = function(x) {
    ifelse(x <= 0.01, 
           x * (0.15/0.01),           # 0-0.01 -> 0-0.15 (15%)
           ifelse(x <= 0.3,
                  0.15 + (x - 0.01) * (0.15/(0.3-0.01)),  # 0.01-0.3 -> 0.15-0.30 (15%)
                  ifelse(x <= 3.5,
                         0.30 + (x - 0.3) * (0.15/(3.5-0.3)),  # 0.3-3.5 -> 0.30-0.45 (15%)
                         0.45 + (x - 3.5) * (0.55/(3000-3.5))   # 3.5-3000 -> 0.45-1.00 (55%)
                  )
           )
    )
  },
  inverse = function(y) {
    ifelse(y <= 0.15, 
           y * (0.01/0.15),           # 逆变换0-0.15部分
           ifelse(y <= 0.30,
                  0.01 + (y - 0.15) * ((0.3-0.01)/0.15),  # 逆变换0.15-0.30部分
                  ifelse(y <= 0.45,
                         0.3 + (y - 0.30) * ((3.5-0.3)/0.15),  # 逆变换0.30-0.45部分
                         3.5 + (y - 0.45) * ((3000-3.5)/0.55)  # 逆变换0.45-1.00部分
                  )
           )
    )
  }
)

# 创建图形
p <- ggplot(ARG_RI, aes(x = sorted, y = RI, color = Risk_Level)) +
  geom_point(alpha = 0.7, size = 1.2) +
  scale_color_manual(values = custom_colors) +
  theme_minimal() +
  labs(
    x = "sorted number", 
    y = "RI", 
    color = "Risk level",
    #title = "ARGs Risk Level"
  ) +
  scale_x_continuous(
    breaks = seq(50, 400, by = 50),
    limits = c(0, NA)
  ) +
  scale_y_continuous(
    trans = custom_trans,
    breaks = c(0, 0.01, 0.3, 3.5, 500, 1000, 2000, 3000),
    limits = c(0, 3000),
    expand = expansion(0)
  ) +
  theme(
    # ===== 新增背景设置 =====
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    # ======================
    legend.position = "right",
    axis.text.y = element_text(
      size = 10, 
      family = "Arial", 
      face = "bold",
      angle = 0,
      margin = margin(r = 10)
    ),
    axis.text.x = element_text(
      size = 12, 
      family = "Arial", 
      face = "bold"
    ),
    axis.title = element_text(
      size = 14, 
      family = "Arial", 
      face = "bold"
    ),
    plot.title = element_text(
      size = 16, 
      family = "Arial", 
      face = "bold",
      hjust = 0.5
    ),
    panel.grid.major = element_line(color = "grey90"),  # 浅灰色主网格
    panel.grid.minor = element_line(color = "grey95")   # 更浅的小网格
  ) +
  geom_hline(
    yintercept = c(0.01, 0.3, 3.5), 
    linetype = "dashed", 
    color = "gray60",
    size = 0.3
  ) +
  annotate(
    "text", 
    x = max(ARG_RI$sorted) * 0.95, 
    y = c(0.005, 0.15, 1.9, 1800), 
    label = c("0-25%", "25%-50%", "50%-75%", "75%-100%"),
    color = "gray40",
    size = 3,
    family = "Arial"
  )


p

