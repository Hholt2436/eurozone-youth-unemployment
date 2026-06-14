library(tidyverse)
library(lubridate)
library(fredr)
library(countrycode)
#Data Harmonization
#EPL Data
processed_epl <- raw_epl |> 
  mutate(
    iso2c = countrycode(REF_AREA, 
                        origin = "iso3c",
                        destination = "iso2c"),
    join_year = as.integer(TIME_PERIOD)
  ) |> 
  select(iso2c, join_year, Measure, epl_index = OBS_VALUE)
#Quarterly Data (Real GDP Growth & Youth Unemployment)
processed_youth_unemp <- raw_youth_unemp |> 
  mutate(
    join_year = year(date),
    iso2c = countrycode(country_code,
                        origin = "iso3c",
                        destination = "iso2c")
  ) |> 
  select(iso2c, date, 
         join_year, region, 
         youth_unemp_rate = value)
processed_gdp_growth <- raw_gdp |> 
  arrange(country_code, date) |> 
  group_by(country_code) |> 
  mutate(
    real_gdp_growth = 100 * (
      log(value) - log(lag(value))
    )
  ) |> 
  ungroup() |> 
  mutate(
    join_year = year(date),
    iso2c = countrycode(country_code,
                        origin = "iso3c",
                        destination = "iso2c")
  ) |> 
  select(iso2c, date,
         join_year, real_gdp_growth)
#Joining Quarterly Data Sets with EPL Data
eurozone_macro_clean <- processed_youth_unemp |> 
  left_join(processed_gdp_growth, 
            by = c("iso2c", "date", "join_year")
  ) |>
  left_join(processed_epl,
            by = c("iso2c", "join_year")
  ) |> 
  filter(
    between(date,
            as.Date("2005-01-01"),
            as.Date("2019-10-01"))
  ) |> 
  drop_na(epl_index)
#Saving Cleaned Data
write.csv(
  eurozone_macro_clean,
  file = "data-clean/eurozone_macro_clean.csv",
  row.names = FALSE
)
