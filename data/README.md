This folder contains anonymized data on student evaluations, demographics, and professional characteirstics for U.S. tenure and tenure track faculty represented across both RateMyProfessor.com and Academic Analytics. This data was processed using the `snakemake` workflow in the `workflow` directory. Raw, unprocessed data cannot be provided due to privacy and sensisivity converns. 

This anonymized data contains the following fields:

- **id**: a unique identifier for each row of the data
- **overall**: the faculty's average teaching score, with 1 being worst and 5 being highest quality. Calculated from individual RateMyProfessor.com ratings from 2010 onwards
- **overall_sd_raw**: the standard deviation of the teaching scores
- **difficulty**: the faculty's average difficulty score, with 1 being most easy and 5 being most difficult. Calculated from individual RateMyProfessor.com ratings from 2010 onwards
- **difficulty_sd_raw**: the standard deviation of the difficulty scores
- **interest**: the faculty's average interest score, with 1 being lest and 5 being most interest. Calculated from individual RateMyProfessor.com ratings from 2010 onwards
- **interest_sd_raw**: the standard deviation of the interest scores
- **multi_records**: whether the faculty had multiple records in the Academic Analytics dataset, indicating multiple affiliations, or multiple disciplinary classifications
- **review_count**: the number of reviews for the faculty from 2010 onwards
- **norm_citations**: the faculty's field-normalized count of citations to recent publications
- **norm_dollars**: the faculty's field-normalized number of grant dollars attributed to recent and active grants
- **norm_artconfcount**: the faculty's field-normalized number of recent journal articles and conference proceedings published
- **norm_articlecount**: the faculty's field-normalized number of recent journal articles published
- **norm_confproc**: the faculty's field-normalized number of recent conference proceedings published
- **norm_all_pubcount**: the sum of faculty's field-normalized number of recent journal articles, conference proceedings, and books published 
- **norm_bookcount**: the faculty's field-normalized number of books published for the previous 10 years
- **norm_awardcount**: the faculty's field-normalized number of lifetime professional awards
- **norm_grantcount**: the faculty's field-normalized number of recent and active grants
- **bookiness**: Categorical variable indicating whether the faculty's field-normalized number of book publications was 0 (None), < 90th percentile (Moderate), or > 90th percnetile (High)
- **awardiness**: Categorical variable indicating whether the faculty's field-normalized number of awards was 0 (None), < 90th percentile (Moderate), or > 90th percnetile (High)
- **all_output**: Categorical variable indicating whether the faculty's field-normalized number of publicationsd (books, journal articles, and conference proceesings) was 0 (None), < 90th percentile (Moderate), or > 90th percnetile (High)
- **grantiness**: Categorical variable indicating whether the faculty's field-normalized grants was 0 (None), < 90th percentile (Moderate), or > 90th percnetile (High)
- **citedness**: Categorical variable indicating whether the faculty's field-normalized number of citations was 0 (None), < 90th percentile (Moderate), or > 90th percnetile (High)
- **output**: Categorical variable indicating whether the faculty's field-normalized number of journal articles and conference proceedings was 0 (None), < 90th percentile (Moderate), or > 90th percnetile (High)
- **mentions_accent**: whether or not the words "accent" were mentioned in any of the reviews left for the faculty on RateMyProfessor.com
- **mentions_ta**: whether or not the words "ta" or "teaching assistant" were mentioned in any of the reviews left for the faculty on RateMyProfessor.com
- **hotness**: whether the faculty was listed as having a "chili pepper" on RateMyProfessor.com, labeled on the website as "hotness" and implicitely indicating perceived attractiveness. 
- **scientific_age**: the number of years since the faculty received their terminal degree (almost always PhD)
- **rank**: The rank of the faculty, either assistant, associate, or full
- **gender**: the gender of the faculty, as inferred from their comments on RateMyProfessor.com
- **discipline**: One of Social Sciences, Humanities, Natural Sciences, Engineering, or Medical Sciences. In cases where a faculty is listed with multiple disciplines, one is selected randomly.
- **uni_type**: The type of univeristy the faculty is affiliated with, either R1, R2, R3, or other, taken from the Carnegie Classification of Higher Education Institutions.
- **uni_control**: Whether the univeristy the faculty is affiliated with is publicly or privately operated

