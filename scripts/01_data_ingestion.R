library(tidyverse)
library(lubridate)
library(fredr)
library(countrycode)
#Harmonized Quarterly Youth Unemployment Rate (Outcome Variable: Y)
target_series <- tibble(
  series_id = c("LRUN24TTESQ156S", 
                "LRUN24TTDEQ156S", 
                "LRUN24TTFRQ156S", 
                "LRUN24TTITQ156S"),
  country_code = c("ESP", "DEU", 
                   "FRA", "ITA" 
                   ),
  region = c("Periphery", "Core", 
             "Core", "Periphery")
)
raw_youth_unemp <- 
  target_series$series_id |> 
  map_df(function(id) {
    fredr(
      series_id = id,
      observation_start = as.Date("1995-01-01"),
      observation_end   = as.Date("2025-12-31")
    )
  }) |> 
  left_join(target_series, by = "series_id")
#Real GDP (Exogenous Confounder: X)
target_series_2 <- tibble(
  series_id = c("CLVMNACSCAB1GQES", 
                "CLVMNACSCAB1GQDE", 
                "CLVMNACSCAB1GQFR", 
                "CLVMNACSCAB1GQIT"),
  country_code = c("ESP", "DEU", 
                   "FRA", "ITA" 
  ),
  region = c("Periphery", "Core", 
             "Core", "Periphery")
)
raw_gdp_growth <- 
  target_series_2$series_id |> 
  map_df(function(id) {
    fredr(
      series_id = id,
      observation_start = as.Date("1995-01-01"),
      observation_end   = as.Date("2025-12-31")
    )
  }) |> 
  left_join(target_series_2, by = "series_id")
#OECD EPL Indexes
raw_epl <- read_csv("data-raw/raw_epl.csv")
#Data Harmonization
#EPL Data
processed_epl <- raw_epl |> 
  mutate(
    iso2c = countrycode(REF_AREA, 
                        origin = "iso3c",
                        destination = "iso2c"),
    join_year = as.integer(TIME_PERIOD)
  ) |> 
  select(iso2c, join_year, Measure, OBS_VALUE)
#Quarterly Data (Real GDP Growth & Youth Unemployment)
processed_youth_unemp <- raw_youth_unemp |> 
  mutate(
    join_year = year(date),
    iso2c = country_code
  ) |> 
  select(iso2c, date, 
         join_year, region, 
         youth_unemp_rate = value)
processed_gdp_growth <- raw_gdp_growth |> 
  mutate(
    join_year = year(date),
    iso2c = country_code
  ) |> 
  select(iso2c, date,
         join_year, gdp_growth_rate = value)
