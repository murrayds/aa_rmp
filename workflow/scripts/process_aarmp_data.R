#!/usr/bin/env Rscript
#
# Process the enriched AA data, creating field-normalized and categorized versions
# of the perofrmance indicators and converting variables to reasonable alternatives
# Author: Dakota Murray
#
library(dplyr)

args = commandArgs(trailingOnly=TRUE)

aarmp_path <- args[1]
output_path <- args[2]

# Load the matched AA/RMP data
aarmp <- read.csv(aarmp_path)


# Up until this point, we have several options for assigning gender.
# These options are provided in the list below, in order of apparent reliability.
# For each indiviudal, I will select the most reliable gender assignment that is
# marked as either male or female. If none of these produce a meaningful answer,
# then the author will recieve a mark of "UNK", for "unknown".
#
# AA and RMP are both "tied" here, for different reasons. For AA we often have to
# choose a name. For RMP names are sometimes shortened or they may use a middle or
# nickname in class. Since the AA dataset seems more likely to have the name they
# use professionally and in research, then we use it first.
#
# 1 Presence of gendered pronouns in RMP reviews (for reviews with multiple pronouns)
# 2 Our custom gender assignment of AA, provided by running on assumed first name (tied)
# 2 Our custom gender assignment of RMP, provided by running on assumed first name (tied)
# 4 AA inferred assignments, provided by running genderize.io on assumed first name (I will not test this, because I do not trust genderize.io)

# First we will set up gender extracted from RMP comments
# We should be especially sure with the pronouns, so lets ensure they have a couple of reviews, and also that
# they have exponentially more of one pronoun than the other
pro_gender <- with(aarmp,
                   ifelse(OUR.total_fem_pronouns > OUR.total_masc_pronouns^2, "F",
                           ifelse(OUR.total_masc_pronouns > OUR.total_fem_pronouns^2, "M",
                                  NA) # If no obvious gender, assign NA
                              )
                      )

assignment <-  matrix(0, dim(aarmp)[1])
assign_source <-  matrix(0, dim(aarmp)[1])

# 1. Assignment through pronouns in RMP comments
pronoun_ind <- !is.na(pro_gender) & assignment == 0
assignment[pronoun_ind]  <- pro_gender[pronoun_ind]
assign_source[pronoun_ind] <- "RMP Comment pronouns"

# 1 1/2. Custom assignment on AA comments
custom_aa_ind <- with(aarmp, OUR.Gender.AA %in% c("M", "F")) & assignment == 0
assignment[custom_aa_ind] <- aarmp$OUR.Gender.AA[custom_aa_ind]
assign_source[custom_aa_ind] <- "Custom Assignment on AA First Name"

# 1 1/2. Custom assignment of RMP comments
custom_rmp_ind <- with(aarmp, OUR.Gender.RMP %in% c("M", "F")) & assignment == 0
assignment[custom_rmp_ind] <- aarmp$OUR.Gender.RMP[custom_rmp_ind]
assign_source[custom_rmp_ind] <- "Custom Assignmnt on RMP First Name"

assignment[assignment == 0] <- "UNK"
assign_source[assign_source == 0] <- "Not Assigned, Unknown"

aarmp$OUR.assigned_gender <- assignment
aarmp$OUR.assigned_gender_source <- assign_source


# Convert degree year to "scientific age". This will throw up a warning, but we can ignore it
aarmp$OUR.age <- 2016 - as.numeric(aarmp$AA.DegreeYear)
# Drop where degree year is NA or null.
aarmp <- aarmp[!is.na(aarmp$OUR.age) & aarmp$OUR.age < 100 & aarmp$OUR.age >= 0, ]

# Drop those with only a small number of reviews
aarmp <- aarmp[aarmp$OUR.numcomment > 3 & !is.na(aarmp$OUR.Overall.mean), ]

# Select randomly from those that appear as interdisciplinary
aarmp <- aarmp %>% group_by(AA_id) %>% sample_n(size = 1)

# Select onlt tenure/TT professors
aarmp <- aarmp[aarmp$AA.RankType %in% c("Assistant Professor", "Associate Professor", "Professor"), ]


write.csv(aarmp, output_path)
