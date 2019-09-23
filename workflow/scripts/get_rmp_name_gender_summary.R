#!/usr/bin/env Rscript
#
# Generate a summary file containing the summary of gender assignments/pronouns
# used in comments associated with each name, where names are just things like
# "John" and "Anne". This is intended to serve as a validation set for our
# customized gender-assignment algortihm.
#
# Author: Dakota Murray
#
library(stringr)
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

rmpdata_path <- args[1]
output_path <- args[2]

# Load the data
rmpdata <- read.csv(rmpdata_path)

# Summarize the total number of male and female instances in the RMP data
# based on the first name of the individual. This is used for validating the
# gender assignment algortihm
rmp_gender_info <- rmpdata %>%
  mutate(fname = word(RMP.Fname_lower, 1),
         fname = gsub("[[:punct:][:blank:]]+", "", fname)) %>%
  group_by(fname) %>%
  summarize(
    total_instances = n(),
    total_female_pronouns = sum(OUR.total_fem_pronouns, na.rm = T),
    total_male_pronouns = sum(OUR.total_masc_pronouns, na.rm = T),
    vincent_gender <- OUR.Gender[1]
  )

# And write the output
write.csv(rmp_gender_info, output_path)
