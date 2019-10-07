#!/usr/bin/env Rscript
#
# Process the enriched AA data, creating field-normalized and categorized versions
# of the perofrmance indicators and converting variables to reasonable alternatives
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

aarmp_path <- args[1]
output_path <- args[2]

# Load the matched AA/RMP data
aarmp <- read.csv(aarmp_path)

# split list of strings
tags <- sapply(aarmp$RMP.Tags, function(x) {
  ifelse(is.na(x), NA, stringr::str_split(x, ";"))
})

# Trim extra whitespace form tags
aarmp$tag_list <- sapply(tags, function(t) {
  sapply(t, function(x) {
    return(trimws(x, "both"))
  })
})

# get unique tags
unq <- unique(unlist(aarmp$tag_list))[1:20]

# Setup necessary variables for following loop
tag_frame <- data.frame(matrix(ncol = length(unq), nrow = 0))
colnames(tag_frame) <- unq

# Create a n X t matrix, where n is the number of records (professors) and t is the number of unique tags. Each
# cell of this matrix contains a 1 if that professor was given that tag by a user
for (i in 1:dim(aarmp)[1]) {
  tag_frame <- rbind(tag_frame, unq %in% unlist(aarmp$tag_list[i]))
}

# Now that we have these, we can rbind with the other features.
tagdata <- cbind(overall = aarmp$OUR.Overall.mean, tag_frame)

colnames(tagdata) <- c("overall", unq)
tagdata$PersonId <- aarmp$AA_id

# Write the output
write.csv(tagdata, output_path, row.names = FALSE)
