#!/usr/bin/env Rscript
#
# Process the enriched AA data, creating field-normalized and categorized versions
# of the perofrmance indicators and converting variables to reasonable alternatives
# Author: Dakota Murray
#

# Percentile threshold at which to classify someone as "excellent"
EXCELLENCE_THRESHOLD <- 0.90

args = commandArgs(trailingOnly=TRUE)

aadata_path <- args[1]
output_path <- args[2]

# Load the aadata
aadata <- read.csv(aadata_path)

# Create variables that contain all forms of production
aadata$AA.PubCount <- aadata$AA.ConfProcCount + aadata$AA.ArticleCount
aadata$AA.AllPubCount <- aadata$AA.ConfProcCount + aadata$AA.ArticleCount + aadata$AA.BookCount


# In the case of duplicates randomly select one.
shuffled <- aadata[sample(nrow(aadata)), ]$AA.PersonId
aa_unique <- aadata[!duplicated(aadata$AA.PersonId), ]

# This isn't perfect, becasue records are duplicated between disciplines.
# In this case, we will normalize at the lowest level, regardless of the
# number of records for an individual that appears in the data.
aa_unique <- aa_unique %>%
  group_by(AA.L1Name) %>%
  mutate(AA.norm_CitationCount = AA.CitationCount / mean(AA.CitationCount),
         AA.norm_PubCount = AA.PubCount / mean(AA.PubCount),
         AA.norm_ArticleCount = AA.ArticleCount / mean(AA.ArticleCount),
         AA.norm_ConfProcCount = AA.ConfProcCount / mean(AA.ConfProcCount),
         AA.norm_AllPubCount = AA.AllPubCount / mean(AA.AllPubCount),
         AA.norm_GrantDollars = AA.GrantDollars / mean(AA.GrantDollars),
         AA.norm_GrantCount = AA.GrantCount / mean(AA.GrantCount),
         AA.norm_BookCount = AA.BookCount / mean(AA.BookCount),
         AA.norm_AwardCount = AA.AwardCount / mean(AA.AwardCount))

citation_threshold = quantile(subset(aa_unique, AA.norm_CitationCount > 0)$AA.norm_CitationCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.citedness = factor(with(aa_unique, ifelse(AA.CitationCount == 0, "None", ifelse(AA.norm_CitationCount <= citation_threshold, "Moderate", "High"))))

article_threshold = quantile(subset(aa_unique, AA.norm_ArticleCount > 0)$AA.norm_ArticleCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.articleness = factor(with(aa_unique, ifelse(AA.ArticleCount == 0, "None", ifelse(AA.norm_ArticleCount <= article_threshold, "Moderate", "High"))))

conference_threshold = quantile(subset(aa_unique, AA.norm_ConfProcCount > 0)$AA.norm_ConfProcCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.proceedingness = factor(with(aa_unique, ifelse(AA.ConfProcCount == 0, "None", ifelse(AA.norm_ConfProcCount <= conference_threshold, "Moderate", "High"))))

production_threshold = quantile(subset(aa_unique, AA.norm_PubCount > 0)$AA.norm_PubCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.output = factor(with(aa_unique, ifelse(AA.PubCount == 0, "None", ifelse(AA.norm_PubCount <= production_threshold, "Moderate", "High"))))

all_production_threshold = quantile(subset(aa_unique, AA.norm_AllPubCount > 0)$AA.norm_AllPubCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.all_output = factor(with(aa_unique, ifelse(AA.AllPubCount == 0, "None", ifelse(AA.norm_AllPubCount <= all_production_threshold, "Moderate", "High"))))

book_threshold = quantile(subset(aa_unique, AA.norm_BookCount > 0)$AA.norm_BookCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.bookiness = factor(with(aa_unique, ifelse(AA.norm_BookCount == 0, "None", ifelse(AA.norm_BookCount <= book_threshold, "Moderate", "High"))))

grant_threshold = quantile(subset(aa_unique, AA.norm_GrantCount > 0)$AA.norm_GrantCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.grantiness = factor(with(aa_unique, ifelse(AA.norm_GrantCount == 0, "None", ifelse(AA.norm_GrantCount <= grant_threshold, "Moderate", "High"))))

award_threshold = quantile(subset(aa_unique, AA.norm_AwardCount > 0)$AA.norm_AwardCount, EXCELLENCE_THRESHOLD)
aa_unique$OUR.awardiness = factor(with(aa_unique, ifelse(AA.norm_AwardCount == 0, "None", ifelse(AA.norm_AwardCount <= award_threshold, "Moderate", "High"))))

# Create our variable for "excellence", which is just an OR function over
# all the production indicators
aa_unique$OUR.excellence = factor(with(aa_unique, OUR.citedness == "High" | OUR.output == "High" | OUR.bookiness == "High" | OUR.grantiness == "High" | OUR.awardiness == "High"))

#Now we can merge all these performance data back into full dataframe. Select relevant columns and merge
aa_unique_relevant <- aa_unique[, c("AA.PersonId", tail(colnames(aa_unique), 19))]
aadata <- merge(aadata, aa_unique_relevant, all.x = TRUE)

# Add another variable indicating whether there exists more than a single record for an individual
aadata <- aadata %>%
  group_by(AA.PersonId) %>%
  mutate(OUR.multi_records = length(AA.PersonId) > 1)

# Change the levels of the university type to research classifications
aadata$CC.uni_type <- plyr::mapvalues(aadata$CC.BASIC2015, c(15, 16, 17), c("r1", "r2", "r3") )
aadata$CC.uni_type[!aadata$CC.uni_type %in% c("r1", "r2", "r3")] <- "other"

# Refactor the variable concerning public/private control of uniersity
aadata$CC.CONTROL <- plyr::mapvalues(aadata$CC.CONTROL, c(1, 2), c("public", "private"))

# Refactor variable concerning size of university
aadata$CC.LOCALE_SIZE <- plyr::mapvalues(aadata$CC.LOCALE,
                              c(11, 21, 31, 41, 12, 22, 32, 42, 13, 23, 33),
                              c(rep("large", 4), rep("medium", 4), rep("small", 3)))

write.csv(aadata, output_path)
