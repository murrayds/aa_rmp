#!/usr/bin/env Rscript
#
# Add our own gender assignment to the aadata table
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

gender_path <- args[1]
output_path <- args[2]


# Load the custom geneder assignment data
custom_gender <- readr::read_delim(gender_path, "\t",
                            escape_double = FALSE,
                            trim_ws = TRUE,
                            na = "NULL")

# This data files contains seperate fields for country of origin—we do not have that info, so
# we should remove the country variable and remove duplicate names
custom_gender$Country <- NULL
custom_gender <- custom_gender[!duplicated(custom_gender), ]

# Add the OUR prefix here
colnames(custom_gender) <- sapply(colnames(custom_gender), function(x) { paste0("OUR.", x) })

# make everything lowercase, or else merging becomes....complicated
custom_gender$OUR.Name <- tolower(custom_gender$OUR.Name)


write.csv(custom_gender, output_path)
