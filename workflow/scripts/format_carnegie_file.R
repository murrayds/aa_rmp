#!/usr/bin/env Rscript
#
# Add our own gender assignment to the aadata table
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

carnegie_path <- args[1]
crosswalk_path <- args[2]
output_path <- args[3]


# Load data
carnegie <- readxl::read_excel(carnegie_path, sheet = "Data")

# The crosswalk, matching AA institutions with Carnegie
crosswalk <- readr::read_csv(crosswalk_path)

# Add prefix to help specify these data points in final data file
colnames(carnegie) <- sapply(colnames(carnegie), function(x) { paste0("CC.", x) })

# Merge crosswalk with carnegie data
carnegie <- merge(carnegie,
                  crosswalk,
                  by.x = "CC.NAME",
                  by.y = "CARNEGIE")

write.csv(carnegie, output_path)
