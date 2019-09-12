#!/usr/bin/env Rscript
#
# Add our own gender assignment to the aadata table
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

rmpdata_path <- args[1]
gender_path <- args[2]
output_path <- args[3]


# Load the custom geneder assignment data
custom_gender <- read.csv(gender_path)

# Load the RMP data
rmpdata <- read.csv(rmpdata_path)

# Now we continue to assign gender to the RMP data
rmpdata$RMP.Fname_lower <- tolower(rmpdata$RMP.Fname)

rmpdata_with_gender <- merge(rmpdata,
                             custom_gender,
                             by.x = "RMP.Fname_lower",
                             by.y = "OUR.Name",
                             all.x = T)

rmpdata_with_gender$OUR.Gender[is.na(rmpdata_with_gender$OUR.Gender) | rmpdata_with_gender$OUR.Gender == ""] <- "UNK"


write.csv(rmpdata_with_gender, output_path)
