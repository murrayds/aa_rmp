#!/usr/bin/env Rscript
#
# Add our own gender assignment to the aadata table
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
taxonomy_path <- args[2]
carnegie_path <- args[3]
faculty_path <- args[4]
gender_path <- args[5]
output_path <- args[6]

# Load the aadata
aadata <- read.csv(aadata_path)

#
# First, add the disciplinary taxonomy to the aadata
#
taxonomy <- read.csv(taxonomy_path) %>%
  select(OUR.Level1Name,	OUR.Level.3.CLEAN,	OUR.Level.4)

aadata <- merge(aadata,
                taxonomy,
                by.x = "AA.L1Name",
                by.y = "OUR.Level1Name",
                all.x = T)

#
# Next, add the carnegie classifications...
#
# Load the custom geneder assignment data
carnegie <- read.csv(carnegie_path) %>%
  select(
    CC.NAME, AA_INST, CC.CONTROL, CC.BASIC2015
  )

aadata <- merge(aadata,
                carnegie,
                by.x = "AA.InstitutionName",
                by.y = "AA_INST",
                all.x = T)

#
# Next, select the most recent faculty rank for each person
#
faculty <- read.csv(faculty_path) %>%
  select(
    PersonId, ProductYear, RankType
  )

rank <- faculty %>%
  # get most recent rank as recorded in AA
  group_by(PersonId) %>%
  arrange(desc(ProductYear)) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(AA.PersonId = PersonId,
         AA.RankType = RankType) %>%
  select(AA.PersonId, AA.RankType)

aadata <- merge(aadata,
                rank,
                by = "AA.PersonId",
                all.x = T)

#
# Next assign gender information based on first names
#
# Load the custom geneder assignment data
custom_gender <- read.csv(gender_path) %>%
  select(OUR.Name, OUR.Gender)

# check first name, if single-character or punctuation, then continue to middle name
# if middle name is invalid, then don't include it...
aadata$AA.chosen_name <- apply(aadata, 1, function(row) {
 first_name <- tolower(row[['AA.FirstName']])
 middle_name <- tolower(row[['AA.MidName']])
 # If the first name is not NA, contains greater than 1 character, and does not have strange punctuation, use it
 if (!is.na(first_name) & nchar(first_name) > 1 & !grepl("[.:,\"#]", first_name)) {
   return(first_name)
 # Otherwise use the stated middle name
 } else if (!is.na(middle_name) & nchar(middle_name) > 1 & !grepl("[.:,\"#]", middle_name)) {
   return(middle_name)
 }
 # otherwise, we will have to exclude that row
 return(NA)
})


# now that we have selected which name we care about, we can merge with
# Vincent's gendered-name list.
aadata <- merge(aadata,
               custom_gender,
               by.x="AA.chosen_name",
               by.y="OUR.Name",
               all.x=TRUE)

# Replace some of the blank or unknown with unknown
aadata$OUR.Gender[is.na(aadata$OUR.Gender) | aadata$OUR.Gender == ""] <- "UNK"


write.csv(aadata, output_path)
