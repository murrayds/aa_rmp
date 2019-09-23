#!/usr/bin/env Rscript
#
# Add prefix to columns
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

input_file <- args[1]
prefix_to_add <- args[2]
output_file <- args[3]

input <- readr::read_csv(input_file)
colnames(input) <- sapply(colnames(input), function(x) { paste0(prefix_to_add, x) })
write.csv(input, output_file)
