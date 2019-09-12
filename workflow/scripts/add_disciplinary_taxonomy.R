#!/usr/bin/env Rscript
#
# Add disciplinary taxonomy to aadata
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
taxonomy_path <- args[2]
output_path <- args[3]


taxonomy <- read.csv(taxonomy_path)

aadata <- read.csv(aadata_path)

aadata_with_disc <- merge(aadata,
                          taxonomy,
                          by.x = "AA.L1Name",
                          by.y = "OUR.Level1Name",
                          all.x = T)

write.csv(aadata_with_disc, output_path)
