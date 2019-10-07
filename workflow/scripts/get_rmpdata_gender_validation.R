#!/usr/bin/env Rscript
#
# Create gender validation file for RMP data.
#
# Author: Dakota Murray
#
library(dplyr)
library(stringr)

args = commandArgs(trailingOnly=TRUE)

rmpdata_path <- args[1]
output_path <- args[2]

# Load the aadata
rmpdata <- read.csv(rmpdata_path)

# First count the number of pronouns in the data
rmp_gender_info <- rmpdata %>%
  mutate(fname = word(RMP.Fname_lower, 1),
         fname = gsub("[[:punct:][:blank:]]+", "", fname)) %>%
  group_by(fname) %>%
  summarize(
    total_instances = n(),
    total_female_pronouns = sum(OUR.total_fem_pronouns, na.rm = T),
    total_male_pronouns = sum(OUR.total_masc_pronouns, na.rm = T),
)


rmp_gender <- rmp_gender_info %>%
    mutate(our_gender = ifelse(total_male_pronouns > (2 * total_female_pronouns), "M",
                               ifelse(total_female_pronouns > (2 * total_male_pronouns), "F", "UNK"))) %>%
    rename(first_name = fname,
           gender_we_assigned = our_gender,
           num_instances = total_instances) %>%
    filter(!grepl("[[:punct:]]", first_name)) %>%
    # remove missing names
    filter(!is.na(first_name)) %>%
    filter(first_name != "") %>%
    filter(grepl("[[:alpha:]]", first_name))


# Save the file
write.csv(rmp_gender, output_path, row.names = FALSE)
