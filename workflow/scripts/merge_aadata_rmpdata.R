#!/usr/bin/env Rscript
#
# Merge the AA and RMP data
# Author: Dakota Murray
#
library(stringdist)
library(stringr)
library(dplyr)

# Edit this to change the threshold. 0.00 = most strict, only allows exact matches.
# 0.10 is fairly strict. A significant number of mismatches appear to occur around 0.20
SIM_THRESHOLD = 0.1

# The parameter used by the jaro-winkler distance calculation, see documentation
# for more information
JW_DISTANCE_PARAM = 0.1


args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
rmpdata_path <- args[2]
crosswalk_path <- args[3]
output_path <- args[4]

# Load the AA data
aadata <- read.csv(aadata_path)

# Load the AA data
rmpdata <- read.csv(rmpdata_path)


# The crosswalk table matching AA institutions with Carnegie
crosswalk <- read.csv(crosswalk_path)
crosswalk$OUR.uniid <- 1:dim(crosswalk)[1]

# Merge crosswalk with AA data
aadata <- merge(aadata, crosswalk, by.x = "AA.InstitutionName", by.y = "AA")

# Merge crosswalk with RMP data
rmpdata <- merge(rmpdata, crosswalk, by.x = "RMP.School", by.y = "RMP", all.x = T)

# Get only those with a university that also appears in AA
rmp_selected <- rmpdata[!is.na(rmpdata$OUR.uniid), ]

# Remove the boilerplate text appears in the RMP department text
rmp_selected$RMP.Department <- gsub("(Professor in the) | (department)",
                                    "",
                                    rmp_selected$RMP.Department)

# remove punctiation from the AA data names and convert to lowercase
aadata$OUR.match_names <- gsub("[[:punct:]]", " ",
                              tolower(paste(aadata$AA.LastName,
                                            aadata$AA.FirstName,
                                            aadata$AA.ProgramName
                                            )
                                      )
                              )

# Convert all to lowercase
rmp_selected$OUR.match_names <- tolower(paste(rmp_selected$RMP.Lname,
                                              rmp_selected$RMP.Fname,
                                              rmp_selected$RMP.Department
                                              )
                                        )

# setup frame to hold matches
frame <- data.frame(AA = integer(), RMP = integer(), SIM = numeric())

# Get list of unique university ids
unis <- unique(aadata$OUR.uniid)

# Loop through each university
for (i in unis) {
  # select AA nad RMP professors for current university
  aa_uni <- aadata[aadata$OUR.uniid == i, ]
  rmp_uni <- rmp_selected[rmp_selected$OUR.uniid == i, ]

  # End if none are found for current uniid
  if(dim(aa_uni)[1] == 0 | dim(rmp_uni)[1] == 0) { next }

  # calculate string distances within university
  per_matrix <- stringdistmatrix(aa_uni$OUR.match_names,
                                 rmp_uni$OUR.match_names,
                                 method = "jw", p = JW_DISTANCE_PARAM)

  # Add ids and reshape matrix that results from the stringdist function into a dataframe
  rownames(per_matrix) <- aa_uni$AA.PersonId
  colnames(per_matrix) <- rmp_uni$RMP.ProfessorId
  per_df <- reshape2::melt(per_matrix)
  colnames(per_df) <- c("AA_id", "RMP_id", "SIM")

  # Sort and filter into most similar matches
  per_df <- per_df %>%
    group_by(AA_id) %>%
    arrange(SIM) %>%
    filter(SIM < SIM_THRESHOLD)

  # Finally, add to frame
  if(dim(per_df)[1] > 0) {
    frame <- rbind(frame, as.data.frame(per_df))
  }
}

# Merge together data based on the matched ids between AA and RMP
aa_temp <- merge(frame[!duplicated(frame$AA_id), ], aadata, by.x = "AA_id", by.y = "AA.PersonId", all.x=T)
aarmp <- merge(aa_temp, rmp_selected, by.x="RMP_id", by.y = "RMP.ProfessorId", all.x=T, suffixes = c(".AA", ".RMP"))

# If more than one AA record is matched to a single RMP record, keep only the record with the greatest similarity.
# In the case of a tie, randomly select. This code is run twice, once for each possible "direction" of
# multi-match/duplication. In most cases, the data will only change in one of these cases; for the sake of
# being exhaustive, running both is a good idea.
aarmp <- aarmp %>%
  group_by(RMP_id) %>%
  mutate(has_duplicate = length(unique(AA_id)) > 1) %>%
  arrange(SIM) %>%
  filter(!has_duplicate | (has_duplicate & row_number() == 1))

aarmp <- aarmp %>%
  group_by(AA_id) %>%
  mutate(has_duplicate = length(unique(RMP_id)) > 1) %>%
  arrange(SIM) %>%
  filter(!has_duplicate | (has_duplicate & row_number() == 1))


write.csv(aarmp, output_path, row.names = FALSE)
