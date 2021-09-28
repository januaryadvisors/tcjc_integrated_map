#Make data
library(tidyverse)
library(tigris)
options(tigris_use_cache=TRUE)
library(sf)
library(geojsonio)
library(rmapshaper)
library(here)

# Pull county data -----------------------------------------------
wgs84<-st_crs("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

tx_counties <- tigris::counties(cb=T, state="TX") %>% st_as_sf() %>% st_transform(., wgs84)


# Set links -----------------------------------------------
harris_link <- "https://tcjedashboard.org/harris/"
dallas_link <- "https://tcjedashboard.org/dallas/"
bexar_link <- "https://tcjedashboard.org/bexar/"
travis_link <- "https://tcjedashboard.org/travis-county-dashboard/"

# Combine and export data ---------------------------------------
df <- tx_counties %>% 
  mutate(
    LINK = case_when(
      NAME == "Harris" ~ harris_link,
      NAME == "Dallas" ~ dallas_link,
      NAME == "Bexar" ~ bexar_link,
      NAME == "Travis" ~ travis_link,
      TRUE ~ "NA"
    ),
    GROUP = ifelse(LINK=="NA", 1, 2),
    MESSAGE = ifelse(LINK=="NA", "No data yet!", "Click to explore the data!")
  ) %>% 
  dplyr::select(GEOID, NAME, LINK, GROUP, MESSAGE) %>% 
  as(., "Spatial") %>% 
  geojson_json(.) %>% ms_simplify(.)

geojson_write(df, file = here::here("data", paste0("mapdata", ".json")))
geojson_write(df, file = here::here(paste0("mapdata", ".json")))

