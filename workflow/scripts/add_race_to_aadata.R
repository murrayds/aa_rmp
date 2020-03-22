#!/usr/bin/env Rscript
#
# Add our own ethnicity assignment to the aadata table
# Author: Dakota Murray
#

library(dplyr)

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
race_path <- args[2]
output_path <- args[3]


# Load the custom race assignment data
race <- read.csv(race_path) %>%
  mutate(name = tolower(name))

# Load the aadata
aadata <- read.csv(aadata_path)

aadata_with_race <- aadata %>%
  mutate(last_name = tolower(AA.LastName)) %>%
  left_join(race, by = ("name" = last_name)) %>%
  mutate(
    OUR.RaceIsWhite = White
  ) %>%
  select(-name, -count, -White, -Black, -Asian,
         -Hispanic, -Api, -Tworaces, -Main_race,
         -last_name)


write.csv(aadata_with_race, output_path)
