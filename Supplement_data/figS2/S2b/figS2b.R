rm(list = ls())

library(readr)
library(readxl)
library(tidyr)
library(dbplyr)
library(tidyverse)

result <- read_csv("Drug_class_MGE_count.csv")

result <- result %>%
  group_by(ARG_type,MGE_subtype) %>%
  summarise(size = sum(`MGE_number/kb`)) %>%
  ungroup()


p2 <- ggplot(result, 
             aes(x = reorder(Renamed_Drug_Class, -Total_normalized_MGE_count), y = Total_normalized_MGE_count)) + 
  geom_col(fill = "#8195c3", width = 0.7) +
  labs(x = "ARG Drug Class", 
       y = "Normalized count of MGEs within 5-kb flanking regions of ARGs") +
  scale_y_continuous(
    labels = function(x) format(abs(x), big.mark = ","),
    breaks = scales::pretty_breaks(n = 6)
  ) +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 90, hjust = 1, vjust = 0.5,
                               family = "Arial", size = 14),
    axis.text.y = element_text(family = "Arial", size = 14),
    axis.title.x = element_text(family = "Arial", size = 14,
                                margin = margin(t = 10)),
    axis.title.y = element_text(family = "Arial", size = 14,
                                margin = margin(r = 10)),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )

p2



