#!/usr/bin/env Rscript
#
# Add disciplinary taxonomy to aadata
# Author: Dakota Murray
#
library(stringr)
library(dplyr)


BEGIN_DATE <- "01/01/2012"


args = commandArgs(trailingOnly=TRUE)

comments_path <- args[1]
output_path <- args[2]

#This will load the comments..
comments <- read.csv(comments_path, stringsAsFactors=FALSE)

# Add propoer prefix to variable names
colnames(comments) <- sapply(colnames(comments), function(x) { paste0("RMP.", x) })

# Keep only those comments posted after a certain date
comments_new <- comments[as.Date(comments$RMP.Date, format="%m/%d/%Y") >= as.Date(BEGIN_DATE, format="%m/%d/%Y"), ]

# Clean up the namespace while removing duplicate comments
comments_new <- comments_new[!duplicated(comments_new[, -which(names(comments_new) == "RMP.Comment")]), ]


# convert to lowercase
text <- tolower(comments_new$RMP.Comment)

# Check if string contains mention of teaching assistant
comments_new$OUR.mentions_ta <- str_detect(text, "\\b((ta)[.,!' ]|(teaching assistant)|(assistant))[']?")
comments_new$OUR.mentions_accent <- str_detect(text, "\\b(accent)\\b")

# I encoutered many troubles attempting to simplify and condense these match patterns, so for the sake
# of correctness, I will use the verbose versions.
comments_new$OUR.female_pronoun <- str_count(text, "\\bshe\\b|\\bher\\b|\\bherself\\b|\\bhers\\b|\\bmrs\\b|\\bms\\b(.|'s)?")

comments_new$OUR.male_pronoun <- str_count(text, "\\bhe\\b|\\bhim\\b|\\bhimself\\b|\\bmr\\b(.|'s)?")

# Define function to check whether course number is upper level or not. Since my analysis will rely on only the
# presence of at least one upper-level course, I will enforce strict adherence to the form
# "<subject_code><course_num>". I will also enforce that the subject number is at least 2 characters, since
# that seems to be a stanrdard for most course numbers I've seen.
is_upper_level <- function(course_str) {
  detect <- str_detect(course_str, "[[:alpha:]]{2,}[[:digit:]]{3,4}")
  if (!is.na(detect) & detect) {
    extraction <- as.numeric(str_extract(course_str, "[[:digit:]]{3,}"))[1]
    return(((extraction >= 300 & extraction < 1000) | (extraction > 3000)))
  } else {
    return(FALSE)
  }
}

# keeping the heuristic that numbers starting with 1 or 2 are lower level, while those beginning with 3+ are upper level
comments_new$OUR.course_is_upper_level <- sapply(comments_new$RMP.Course, is_upper_level)

# Now lets also add an "interest measure"  for the student measure. We will give a number value to each "level"
# of the interest, and find the average of all of the comments for each professor

# Convert the interest column values into factors
comments_new$RMP.Interest <- factor(comments_new$RMP.Interest, c("N/A", "Low", "Meh", "Sorta interested", "Really into it", "It's my life"), ordered=TRUE)
# Create table linking factors to values on an ordinal scale
factor_nums <- data.frame(factor = levels(comments_new$RMP.Interest), OUR.interest_value = c(NA, 1:5))
# Merge table with comments, such that every comment has a numeric value representing the student's stated interest
comments_new <- merge(comments_new,
                      factor_nums,
                      by.x = "RMP.Interest",
                      by.y = "factor",
                      all.x = TRUE)

# Calculate summary values for each professor
professor_data <- comments_new %>%
  group_by(RMP.ProfessorId) %>%
  summarise(
    OUR.numcomment = length(RMP.ProfessorId),
    OUR.teaches_upper = sum(OUR.course_is_upper_level, na.rm = TRUE) > 0,
    OUR.interest.mean  = mean(OUR.interest_value, na.rm = TRUE),
    OUR.interest.sd = sd(OUR.interest_value, na.rm = TRUE),
    OUR.mentions_ta = sum(OUR.mentions_ta) > 1,
    OUR.mentions_accent = sum(OUR.mentions_accent, na.rm = TRUE) > 0,
    OUR.Easiness.mean = mean(RMP.Easiness),
    OUR.Easiness.sd = sd(RMP.Easiness),
    OUR.Overall.mean = mean(RMP.Overall),
    OUR.Overall.sd = sd(RMP.Overall),
    OUR.total_masc_pronouns = sum(OUR.male_pronoun, na.rm=T),
    OUR.total_fem_pronouns = sum(OUR.female_pronoun, na.rm=T)
  )

# Now create categorical variables for the sd interest and easiness
# no deviation, low deviation, high deviation
med <- median(professor_data$OUR.interest.sd, na.rm = T)
professor_data$OUR.interest.sd.group <- factor(with(professor_data, ifelse(OUR.interest.sd == 0, "None",
                            ifelse(OUR.interest.sd <= med, "Moderate", "High"))))

med <- median(professor_data$OUR.Easiness.sd, na.rm = T)
professor_data$OUR.Easiness.sd.group <- factor(with(professor_data, ifelse(OUR.Easiness.sd == 0, "None",
                            ifelse(OUR.Easiness.sd <= med, "Moderate", "High"))))


cap <- quantile(professor_data$OUR.numcomment, 0.95)
professor_data$OUR.numcomment.capped <- with(professor_data, ifelse(OUR.numcomment > cap, cap, OUR.numcomment))

# And write the output
write.csv(professor_data, output_path, row.names = FALSE)
