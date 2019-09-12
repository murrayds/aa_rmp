#!/usr/bin/env Rscript
#
# Add our own gender assignment to the aadata table
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
carnegie_path <- args[2]
output_path <- args[3]


# Load the custom geneder assignment data
carnegie <- read.csv(carnegie_path)

# Load the aadata
aadata <- read.csv(aadata_path)

aadata <- merge(aadata,
                carnegie,
                by.x = "AA.InstitutionName",
                by.y = "AA_INST")

write.csv(aadata, output_path)
