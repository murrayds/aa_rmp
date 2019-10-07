#!/usr/bin/env Rscript
#
# Filter to only AA records that were not matched
#
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
aarmp_path <- args[2]
output_path <- args[3]

# Load the aadata
aadata <- read.csv(aadata_path)

aarmp <- read.csv(aarmp_path)

# While we are here, create unmatched datasets for the AA and the RMP datasets to be used for later
aa_unmatched <- aadata %>%
  left_join(aarmp %>% select(AA_id) %>%
                      mutate(new_id = AA_id),
            by = c("AA.PersonId" = "AA_id"), all.x = T
  ) %>%
  filter(is.na(new_id)) %>%
  select(-new_id) %>%
  mutate(type = "unmatched") %>%
  group_by(AA.PersonId) %>% # also filter out dupicates
  slice(1)


write.csv(aa_unmatched, output_path, row.names = FALSE)
