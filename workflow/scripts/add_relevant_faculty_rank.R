#!/usr/bin/env Rscript
#
# Add relevant faculty rank to aadata
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
faculty_path <- args[2]
output_path <- args[3]


faculty <- read.csv(faculty_path)

aadata <- read.csv(aadata_path)

rank <- faculty %>%
  # get most recent rank as recorded in AA
  group_by(PersonId) %>%
  arrange(desc(ProductYear)) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(AA.PersonId = PersonId,
         AA.RankType = RankType) %>%
  select(AA.PersonId, AA.RankType)

aadata_with_rank <- merge(aadata,
                          rank,
                          by = "AA.PersonId",
                          all.x = T)

write.csv(aadata_with_rank, output_path)
