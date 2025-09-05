#' Calculate score based upon new information and research
#' 
#' @param species CSV file in the data folder called "species_names.csv" that includes
#'   all the species to include in this analysis.
#' @param survey_data Data frame of WCGBTS bds data from data-processed/all_nwfsc_survey_new_information.csv
#' @param assess_year R data object with the assessment year by species from the 
#'   data-processed/assess_year_ssc_rec.csv
#' @param new_research R data object that contains new research to be considered 
#'   scoring. New research by species contained in data-raw/new_research.csv.
#'
#' @author Chantel Wetzel
#' @export
#' 
#'
#'
summarize_new_information <- function(
  species, 
  survey_data, 
  assess_year,
  new_research) {
  
  new_info_df <- data.frame(
    Species = species[,1], 
    Rank = NA, 
    Factor_Score = NA,
    Last_Assessed = assess_year$Last_Assess,
    New_Research = 0,
    Issues_Can_be_Addressed = 0,
    Survey_Abundance = 0,
    Survey_Composition = 0
  )
  
  for(sp in 1:nrow(species)) {
    
    key <- ss <- ff <- NULL
    name_list <- species[sp, species[sp,] != -99]
    
    for(a in 1:length(name_list)){
      # Survey data
      key <- c(key, grep(species[sp,a], survey_data$Common_name, ignore.case = TRUE))

      # New Research/Issues
      ff <- c(ff, grep(species[sp, a], new_research$Species, ignore.case = TRUE))
    }
    
    if(length(key) > 0){
      # Add point for increase in the time series length
      # The only species where a NWFS HKL index would likely be viable are:
      # bocaccio, vermilion, greenspotted, and cowcod
      key <- unique(key)
      new_info_df[sp, "Survey_Abundance"] <- 
        ifelse(
        survey_data[key, "years_since_assessment"] == max(survey_data[, "years_since_assessment"]) & survey_data[key, "ave_set_tows"] > 30, 3, 
        ifelse(
         survey_data[key, "years_since_assessment"] >= 10 & survey_data[key, "years_since_assessment"] < max(survey_data[, "years_since_assessment"]) & survey_data[key, "ave_set_tows"] > 30, 2, 
         ifelse(
            survey_data[key, "years_since_assessment"] >= 5 & survey_data[key, "years_since_assessment"] < 10 &
            survey_data[key, "ave_set_tows"] > 30, 1, 0
            )
          )                                                                                                     
        )
      
      # Add point for lots of lengths/ages/otoliths available
      new_info_df[sp, "Survey_Composition"] <- 
        ifelse(
          survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] >= 20000, 3, 
          ifelse(
            survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] >= 10000 & 
            survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] < 20000, 2, 
            ifelse(
              survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] >= 5000 &
              survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] < 10000, 1, 0
            )
          )                                                                                                     
        )
    }
    
    if(length(ff) > 0){
      new_info_df[sp, "New_Research"] <- sum(new_research[ff, "Score"])
    }
    
    # Issues can be addressed to be added when there is a list available
    # Assign a value of +5
  }
  
  new_info_df[, "Factor_Score"] <- new_info_df[, "New_Research"] +
    new_info_df[, "Issues_Can_be_Addressed"] + new_info_df[, "Survey_Abundance"] + new_info_df[, "Survey_Composition"]
   
  if(max(new_info_df$Factor_Score) > 10){
    new_info_df$Factor_Score <- round(10 * new_info_df$Factor_Score / max(new_info_df$Factor_Score), 1)
  } 
  
  x <- 1
  for(i in sort(unique(new_info_df[, "Factor_Score"]), decreasing = TRUE)) {
    ties <- which(new_info_df$Factor_Score == i)
    if(length(ties) > 0) {
      new_info_df$Rank[ties] <- x
    }
    x <- x + length(ties)
  }
  

  new_info_df <- replace(new_info_df, new_info_df == "", NA)
  formatted_new_info <- format_all(x = new_info_df)
  readr::write_csv(formatted_new_info, here::here("data-processed", "9_new_information.csv"))
  return(formatted_new_info)
}