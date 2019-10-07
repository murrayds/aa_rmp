#!/usr/bin/env Rscript
#
# Filter to only RMP records that were not matched
#
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

rmpdata_path <- args[1]
aarmp_path <- args[2]
output_path <- args[3]

# Load the aadata
rmpdata <- read.csv(rmpdata_path)

aarmp <- read.csv(aarmp_path)

rmp_unmatched <- rmpdata %>%
  left_join(aarmp %>% select(RMP_id)
                  %>% mutate(new_id = RMP_id),
            by = c("RMP.ProfessorId" = "RMP_id"), all.x = T
  ) %>%
  filter(is.na(new_id)) %>%
  select(-new_id) %>%
  mutate(type = "unmatched")


write.csv(rmp_unmatched, output_path, row.names = FALSE)
