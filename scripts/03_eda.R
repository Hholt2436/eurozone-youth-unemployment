library(tidyverse)
library(lubridate)
library(fredr)
library(countrycode)
eurozone_macro_wide <- eurozone_macro_clean |>
  pivot_wider(names_from = Measure, values_from = epl_index) |>
  rename(epl_regular = `Individual dismissals (regular contracts)`,
         epl_temporary = `Temporary contracts`) |>
  mutate(epl_gap = epl_regular - epl_temporary)

stopifnot(sum(is.na(eurozone_macro_wide)) == 0)
  