#!/usr/bin/env Rscript
#
# Enrich the RMP data with custom gender assignment and with
# information extracted from comments.
# Author: Dakota Murray
#
library(stringr)
library(dplyr)


args = commandArgs(trailingOnly=TRUE)

rmpdata_path <- args[1]
gender_path <- args[2]
commentdata_path <- args[3]
output_path <- args[4]

# Load the RMP data
rmpdata <- read.csv(rmpdata_path)

# Load the custom geneder assignment data
custom_gender <- read.csv(gender_path)

# Now we continue to assign gender to the RMP data
rmpdata$RMP.Fname_lower <- tolower(rmpdata$RMP.Fname)

rmpdata <- merge(rmpdata,
                 custom_gender,
                 by.x = "RMP.Fname_lower",
                 by.y = "OUR.Name",
                 all.x = T)

rmpdata$OUR.Gender[is.na(rmpdata$OUR.Gender) | rmpdata$OUR.Gender == ""] <- "UNK"

rmpdata$RMP.Chili <- plyr::mapvalues(rmpdata$RMP.Chili,
                             c("['/assets/chilis/cold-chili.png']", "['/assets/chilis/new-hot-chili.png']"),
                             c("cold", "hot"))


# Load the data extracted from the comments
commentdata <- read.csv(commentdata_path, stringsAsFactors=FALSE)

# Merge the comment-extracted data with the RMP data
rmpdata <- merge(rmpdata, commentdata,  all.x=TRUE)

# And write the output
write.csv(rmpdata, output_path)
