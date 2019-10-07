#!/usr/bin/env Rscript
#
# Create gender validation file for AA data.
#
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
output_path <- args[2]

# Load the aadata
aadata <- read.csv(aadata_path)

aa_gender <- aadata %>%
  select(AA.FirstName, AA.Gender) %>%
  rename(first_name = AA.FirstName,
         gender_aa_assigned = AA.Gender) %>%
  # remove names containing punctuation
  filter(!grepl("[[:punct:]]", first_name)) %>%
  # remove missing names
  filter(!is.na(first_name)) %>%
  mutate(first_name = tolower(first_name)) %>%
  group_by(first_name) %>%
  summarize(
    num_instances = n(),
    prop_male = sum(gender_aa_assigned == "M") / n(),
    prop_female = sum(gender_aa_assigned == "F") / n(),
    prop_unk = sum(gender_aa_assigned == "U" ) / n(),
    gender_aa_assigned = c("Male", "Female", "Unknown")[which.max(c(prop_male, prop_female, prop_unk))]
  )

# Save the file
write.csv(aa_gender, output_path, row.names = FALSE)
