library(tidyverse)
library(lubridate)
library(ggplot2)
source("00_palette_setup.R")
eurozone_macro_clean <- read_csv("data-clean/eurozone_macro_clean.csv")
eurozone_macro_wide <- eurozone_macro_clean |>
  pivot_wider(names_from = Measure, values_from = epl_index) |>
  rename(epl_regular = `Individual dismissals (regular contracts)`,
         epl_temporary = `Temporary contracts`) |>
  mutate(epl_gap = epl_regular - epl_temporary)

stopifnot(sum(is.na(eurozone_macro_wide)) == 0)

theme_nyfed<- function() {
  theme_classic() +
  theme(
    axis.line.y = element_blank(),
    axis.ticks = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.major.y = element_line(
      color = "grey90",
      linewidth = 0.5,
      linetype = "solid"
    ),
    panel.border = element_blank(),
    text = element_text(family = "sans", color = "#334B5B"),
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(
      size = 11,
      margin = margin(b=10)
    ),
    axis.title.y = element_text(margin = margin(r = 15)),
    legend.position = "top",
    legend.justification = "left",
    legend.title = element_text(face = "bold"),
    legend.background = element_blank(),
    legend.key = element_blank(),
    plot.margin = margin(t = 20, r = 20, b = 20, l = 20)
  )
}


eurozone_macro_wide |> 
  ggplot(aes(x = date, y = youth_unemp_rate)) +
  annotate("rect",
           xmin = as.Date("2008-01-01"), xmax = as.Date("2014-01-01"),
           ymin = -Inf, ymax = Inf,
           fill = "grey50", alpha = 0.12) +
  geom_vline(xintercept = as.Date("2010-01-01"),
             linetype = "dashed", linewidth = 0.4, color = "grey45") +
  geom_line(aes(color = iso2c)) +
  # the two leg labels, pinned to the top of the panel
  annotate("text", x = as.Date("2009-01-01"), y = Inf, vjust = 1.8,
           label = "GFC", size = 3, color = "grey40") +
  annotate("text", x = as.Date("2011-09-01"), y = Inf, vjust = 1.8,
           label = "Sovereign", size = 3, color = "grey40") +
  scale_colour_manual(values = country_colors) +
  labs(
    title = "Evolution of Youth Unemployment",
    x = "Date",
    y = "Youth unemployment rate (%)",
    subtitle = "Eurozone Countries",
    color = "Country",
    caption = "Source: OECD via FRED"
  ) + 
  theme_nyfed()
