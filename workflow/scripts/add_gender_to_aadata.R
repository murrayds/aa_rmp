#!/usr/bin/env Rscript
#
# Add our own gender assignment to the aadata table
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
gender_path <- args[2]
output_path <- args[3]


# Load the custom geneder assignment data
custom_gender <- read.csv(gender_path)

# Load the aadata
aadata <- read.csv(aadata_path)


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
aadata_with_gender <- merge(aadata,
                            custom_gender,
                            by.x="AA.chosen_name",
                            by.y="OUR.Name",
                            all.x=TRUE)

# Replace some of the blank or unknown with unknown
aadata_with_gender$OUR.Gender[is.na(aadata_with_gender$OUR.Gender) | aadata_with_gender$OUR.Gender == ""] <- "UNK"


write.csv(aadata_with_gender, output_path)
