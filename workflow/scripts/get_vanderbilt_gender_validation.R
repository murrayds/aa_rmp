#!/usr/bin/env Rscript
#
# Create gender validation file for Vanderbilt data.
#
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

vanderbilt_path <- args[1]
output_path <- args[2]

# Load the aadata
vanderbilt <- read.csv(vanderbilt_path)

van_gender <- vanderbilt %>%
  select(FirstName, SubmittedGender) %>%
  rename(first_name = FirstName,
         gender_vanderbilt_provided = SubmittedGender)

# Save the file
write.csv(van_gender, output_path)
