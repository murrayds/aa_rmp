#!/usr/bin/env Rscript
#
# Add our own ethnicity assignment to the aadata table
# Author: Dakota Murray
#

library(dplyr)

args = commandArgs(trailingOnly=TRUE)

rmpdata_path <- args[1]
race_path <- args[2]
output_path <- args[3]

# Load the custom race assignment data
race <- read.csv(race_path) %>%
  mutate(name = tolower(name))

# Load the RMP data
rmpdata <- read.csv(rmpdata_path)

rmpdata_with_race <- rmpdata %>%
  mutate(last_name = tolower(AA.LastName)) %>%
  left_join(race, by = ("name" = AA.LastName)) %>%
  mutate(
    OUR.RaceIsWhite = White
  ) %>%
  select(-name, -count, -White, -Black, -Asian,
         -Hispanic, -Api, -Tworaces, -Main_race,
         -race)


write.csv(rmpdata_with_race, output_path)
