#!/usr/bin/env Rscript
#
# Add disciplinary taxonomy to aadata
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

vanderbilt_path <- args[1]
gender_path <- args[2]
output_path <- args[3]


vanderbilt <- read.csv(vanderbilt_path)
custom_gender <- read.csv(gender_path)


vanderbilt$FirstName <- tolower(vanderbilt$FirstName)

vanderbilt_assigned <- merge(vanderbilt,
                             custom_gender,
                             by.x = "FirstName",
                             by.y = "OUR.Name",
                             all.x = T)

write.csv(vanderbilt_assigned, output_path)
