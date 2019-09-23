#!/usr/bin/env Rscript
#
# Process the enriched AA data, creating field-normalized and categorized versions
# of the perofrmance indicators and converting variables to reasonable alternatives
# Author: Dakota Murray
#

args = commandArgs(trailingOnly=TRUE)

aarmp_path <- args[1]
output_path <- args[2]

# Load the matched AA/RMP data
aarmp <- read.csv(aarmp_path)

print(dim(aarmp))
ready_data <- data.frame(id = aarmp$AA_id,
                         overall = aarmp$OUR.Overall.mean,
                         overall_sd_raw = aarmp$OUR.Overall.sd,
                         difficulty = aarmp$OUR.Easiness.mean,
                         difficulty_sd = aarmp$OUR.Easiness.sd.group,
                         difficulty_sd_raw = aarmp$OUR.Easiness.sd,
                         multi_records = aarmp$OUR.multi_records,
                         review_count = aarmp$OUR.numcomment.capped,
                         interest = aarmp$OUR.interest.mean,
                         interest_sd = aarmp$OUR.interest.sd.group,
                         interest_sd_raw = aarmp$OUR.interest.sd,
                         norm_citations = aarmp$AA.norm_CitationCount,
                         norm_dollars = aarmp$AA.norm_GrantDollars,
                         norm_artconfcount = aarmp$AA.norm_PubCount,
                         norm_articlecount = aarmp$AA.norm_ArticleCount,
                         norm_confproc = aarmp$AA.norm_ConfProcCount,
                         norm_all_pubcount = aarmp$AA.norm_AllPubCount,
                         norm_bookcount = aarmp$AA.norm_BookCount,
                         norm_awardcount = aarmp$AA.norm_AwardCount,
                         norm_grantcount = aarmp$AA.norm_GrantCount,
                         bookiness = aarmp$OUR.bookiness,
                         awardiness = aarmp$OUR.awardiness,
                         all_output = aarmp$OUR.all_output,
                         grantiness = aarmp$OUR.grantiness,
                         citedness = aarmp$OUR.citedness,
                         output = aarmp$OUR.output,
                         mentions_accent = aarmp$OUR.mentions_accent,
                         mentions_ta = aarmp$OUR.mentions_ta,
                         hotness = aarmp$RMP.Chili,
                         scientific_age = aarmp$OUR.age,
                         rank = aarmp$AA.RankType,
                         gender = aarmp$OUR.assigned_gender,
                         discipline = aarmp$`OUR.Level.4`,
                         uni_type = aarmp$CC.uni_type,
                         uni_control = aarmp$CC.CONTROL,
                         uni_locale_size = aarmp$CC.LOCALE_SIZE,
                         teaches_upper = aarmp$OUR.teaches_upper
)

# Filter to include only those for whom a gender could be identified
ready_data <- ready_data[ready_data$gender %in% c("M", "F"), ]

# Remove NA values...
ready_data <- na.omit(ready_data)

# Save a separate, non-scaled, age value
ready_data$raw_age <- ready_data$scientific_age


write.csv(ready_data, output_path)
