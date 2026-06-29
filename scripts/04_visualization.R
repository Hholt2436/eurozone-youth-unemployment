library(tidyverse)
library(lubridate)
library(ggplot2)
library(broom)
library(patchwork)
source("00_palette_setup.R")
eurozone_macro_clean <- read_csv("data-clean/eurozone_macro_clean.csv")
eurozone_macro_wide <- eurozone_macro_clean |>
  pivot_wider(names_from = Measure, values_from = epl_index) |>
  rename(epl_regular = `Individual dismissals (regular contracts)`,
         epl_temporary = `Temporary contracts`) |>
  mutate(epl_gap = epl_regular - epl_temporary)

stopifnot(sum(is.na(eurozone_macro_wide)) == 0)

# Theme Infrastructure
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

# Unemployment Over Time Graph
p_youth <- eurozone_macro_wide |> 
  ggplot(aes(x = date, y = youth_unemp_rate)) +
  annotate("rect",
           xmin = as.Date("2008-01-01"), xmax = as.Date("2014-01-01"),
           ymin = -Inf, ymax = Inf,
           fill = "grey50", alpha = 0.12) +
  geom_vline(xintercept = as.Date("2010-01-01"),
             linetype = "dashed", linewidth = 0.4, color = "grey45") +
  geom_line(aes(color = iso2c)) +
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

#Analytical Core Panel 
eurozone_macro_wide <- eurozone_macro_wide |>
  mutate(crisis = if_else(between(year(date), 2008, 2013),
                          "Crisis (2008–2013)", "Other"))

slopes <- eurozone_macro_wide |>
  group_by(iso2c) |>
  group_modify(~ tidy(lm(youth_unemp_rate ~ real_gdp_growth, data = .x))) |>
  filter(term == "real_gdp_growth") |>
  mutate(lab = paste0("slope = ", round(estimate, 2)))

p_core <- eurozone_macro_wide |> 
  ggplot(aes(x = real_gdp_growth, y = youth_unemp_rate)) +
  geom_point(aes(color = iso2c, alpha = crisis), size = 2) +
  geom_text(data = slopes, aes(x = Inf, y = -Inf, label = lab),
            inherit.aes = FALSE, hjust = 1.1, vjust = -0.6,
            size = 3.4, color = "grey25") +
  scale_alpha_manual(values = c("Crisis (2008–2013)" = 1, "Other" = 0.25),
                     name = NULL) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
              color = "#334B5B", fill = "grey75", linewidth = 0.7) +
  facet_wrap(~iso2c, scales = "free_y") +
  scale_colour_manual(values = country_colors) +
  labs(
    title = "Youth unemployment vs. quarterly GDP growth, by country",
    subtitle = "Raw, contemporaneous, bivariate comparison",
    x = "Quarterly GDP Growth Rate (%)",
    y = "Youth unemployment rate (%)",
    color = "Country",
    caption = "Source: OECD via FRED"
  ) + 
  theme_nyfed() +
  guides(color = "none")

ggsave("outputs/headline_figure.png", p_core, width = 15, height = 10)

#GDP growth over time
p_gdp <- eurozone_macro_wide |> 
  ggplot(aes(x = date, y = real_gdp_growth)) +
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
    title = "Evolution of GDP Growth",
    x = "Date",
    y = "QoQ real GDP growth rate (%)",
    subtitle = "Eurozone Countries",
    color = "Country",
    caption = "Source: OECD via FRED"
  ) + 
  theme_nyfed()

#EPL indices over time
epl_long <- eurozone_macro_wide |>
  select(iso2c, date, epl_regular, epl_temporary) |>
  pivot_longer(
    cols = c(epl_regular, epl_temporary),
    names_to  = "contract_type",
    values_to = "epl_value"
  ) |>
  mutate(contract_type = recode(contract_type,
                                epl_regular   = "Regular contracts",
                                epl_temporary = "Temporary contracts"))

p_epl <- epl_long |> 
  ggplot(aes(x = date, y = epl_value)) +
  annotate("rect",
           xmin = as.Date("2008-01-01"), xmax = as.Date("2014-01-01"),
           ymin = -Inf, ymax = Inf,
           fill = "grey50", alpha = 0.12) +
  geom_vline(xintercept = as.Date("2010-01-01"),
             linetype = "dashed", linewidth = 0.4, color = "grey45") +
  geom_line(aes(color = iso2c)) +
  scale_colour_manual(values = country_colors) +
  theme_nyfed() +
  facet_wrap(~contract_type) +
  labs(title = "Evolution of EPL Indices", subtitle = "Eurozone Countries",
       x = "Date", y = "EPL Index", color = "Country",
       caption = "Source: OECD Data Explorer")

#Dashboard Construction
p_core2 <- p_core + labs(caption = NULL) 
p_gdp2   <- p_gdp   + labs(subtitle = NULL, caption = NULL)
p_youth2 <- p_youth + labs(subtitle = NULL, caption = NULL)
p_epl2   <- p_epl   + labs(subtitle = NULL, caption = NULL)

strip_x <- theme(axis.title.x = element_blank(),
                 axis.text.x  = element_blank(),
                 axis.ticks.x = element_blank(),
                 axis.line.x  = element_blank())

p_gdp3   <- p_gdp2   + strip_x
p_youth3 <- p_youth2 + strip_x
p_epl3 <- p_epl2 +
  scale_x_date(date_breaks = "4 years", date_labels = "%Y") +
  theme(panel.spacing.x = unit(1.2, "lines"))

right_col <- p_gdp3 / p_youth3 / p_epl3 +
  plot_layout(heights = c(1, 1, 1.35))

dashboard <- (p_core2 | right_col) +
  plot_layout(widths = c(1.5, 1.2), guides = "collect") +
  plot_annotation(
    title   = "Growth, employment protection, and youth unemployment in four Eurozone economies, 2005–2019",
    caption = "Sources: FRED (youth unemployment rate, real GDP); OECD (EPL, version 1). Quarterly, 2005Q1–2019Q4. Shaded band: 2008–2013 crisis window; dashed line marks the 2010 GFC / sovereign-debt split.",
    theme = theme_nyfed()
  ) &
  theme(legend.position = "bottom")

ggsave("outputs/dashboard.png", dashboard, width = 15, height = 10, dpi = 300)
ggsave("outputs/dashboard.pdf", dashboard, width = 15, height = 10)
