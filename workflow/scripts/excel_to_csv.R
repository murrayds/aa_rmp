#!/usr/bin/env Rscript
#
# Add prefix to columns
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

input_file <- args[1]
output_file <- args[2]

as_excel <- readxl::read_excel(input_file)
write.csv(as_excel, output_file)
