#' Comparison between recent average mortality, OFLs,
#' and ACLs. The official recent average mortality should
#' come from the GEMM rather than a pull from PacFIN. 
#' The manage_file is a file containing management quantities
#' provided in a special pull by Rob Ames from the GMT016 table.
#' This special pull of all management quantities by species across years
#' had some issues that had to be fixed by hand:
#' 1) Many rockfish species were missing "Rockfish" in their names and
#' I had to correct them by hand due to grep issues when only the first
#' name were used (e.g., China changed to China Rockfish).
#' 2) The file does not contain OFLs or ACLs for sablefish, longspine
#' thornyhead, and shortspine thornyhead.
#' 3) Quantities (OFLs,..) were duplicated for blue rockfish and rougheye/blackspotted
#' rockfish and had to be corrected by hand.
#' 
#' 2023 Notes of GMT 015 correction
#' 1) blue rockfish in Oregon - hand deleted the blue/deacon/black complex rows
#' 2) cowcod - hand deleted the south of 4010 rows and add in the ACLs by area
#' 3) lingcod - hand deleted WA-OR and 42-4010 rows
#' 4) starry and kelp - add rockfish to each
#' 
#' 2023 future spex fixes
#' 1) delete s4010 cowcod
#' 
#' @param gemm_mortality R object created by nwfscSurvey::pull_gemm()
#' @param harvest_spex CSV file with OFLs, ABCs, and ACLs across years for West Coast groundfish
#' @param species CSV file in the data folder called "species_names.csv" that includes
#' all the species to include in this analysis.
#' @param manage_quants The names of the management quantities in the manage_file to grep.
#' This allows to easily shift between the ABC and the ACL if needed.
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' @examples
#' 
#'
#'
summarize_new_information <- function(
    species = species, 
    survey_data, 
    bio_params,
    new_research) {
  
  new_info_df <- data.frame(
    Species = species[,1], 
    Rank = NA, 
    Factor_Score = NA,
    Last_Assessed = bio_params$Last_Assess,
    Steepness_Prior = 0,
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
      # Biological parameters
      ss <- c(ss, grep(species[sp, a], bio_params$Species, ignore.case = TRUE))
      # New Research/Issues
      ff <- c(ff, grep(species[sp, a], new_research$Species, ignore.case = TRUE))
    }
    
    if(length(key) > 0){
      # The only species where a NWFS HKL index would likely be viable are:
      # bocaccio, vermilion, greenspotted, and cowcod
      key <- unique(key)
      new_info_df[sp, "Survey_Abundance"] <- 
        ifelse(
        survey_data[key, "years_since_assessment"] == max(survey_data[, "years_since_assessment"]) & survey_data[key, "ave_set_tows"] > 30, 3, 
        ifelse(
         survey_data[key, "years_since_assessment"] > 10 & survey_data[key, "years_since_assessment"] < max(survey_data[, "years_since_assessment"]) & survey_data[key, "ave_set_tows"] > 30, 2, 
         ifelse(
            survey_data[key, "years_since_assessment"] > 5 & survey_data[key, "years_since_assessment"] < 10 &
            survey_data[key, "ave_set_tows"] > 30, 1, 0
            )
          )                                                                                                     
        )
      
      new_info_df[sp, "Survey_Composition"] <- 
        ifelse(
          survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] > 20000, 3, 
          ifelse(
            survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] > 10000, 2, 
            ifelse(
              survey_data[key, "total_lengths"] + survey_data[key, "total_ages"] + survey_data[key, "total_otoliths"] > 5000, 1, 0
            )
          )                                                                                                     
        )
    }

    if(length(ss) > 0){
      ss <- unique(ss)
      new_info_df[sp, "Steepness_Prior"] <- ifelse(
        !is.na(bio_params[ss, "h"]) & bio_params[ss, "h"] < 0.60, 2, 0)
    }
    
    if(length(ff) > 0){
      new_info_df[sp, "New_Research"] <- 2
    }
    
    # Issues can be addressed to be added when there is a list available
  }
  
  new_info_df[, "Factor_Score"] <- new_info_df[, "Steepness_Prior"] + new_info_df[, "New_Research"] +
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
  
  new_info_df <- 
    new_info_df[order(new_info_df[,"Species"], decreasing = FALSE), ]
  
  write.csv(new_info_df, file.path("data-processed", "9_new_information.csv"), row.names = FALSE)

  return(new_info_df)
}