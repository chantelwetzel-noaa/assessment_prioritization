#' Calculate score based upon rebuilding
#' 
#' @param species CSV file in the data folder called "species_names.csv" that includes
#'   all the species to include in this analysis.
#' @param overfished_data Data frame of overfished species from data-raw/overfished_species.csv
#' @param stock_status Data frame created by the summarize_stock_status function
#' @param assessment_year The year for which species to be assessed are being selected based
#'   upon the prioritization process
#'
#' @author Chantel Wetzel
#' @export
#'
#'
summarize_rebuilding <- function(
  species, 
  overfished_data, 
  stock_status, 
  assessment_year){
  
  overfished_df <- data.frame(
    Species = species[,1], 
    Rank = NA,
    Factor_Score = 0,
    Rebuilding_Target_Year = NA
  )
  
  for(a in 1:nrow(overfished_data)){
    
    find <- grep(overfished_data[a, "Species"], overfished_df[,"Species", ], ignore.case = TRUE)
    target <- overfished_data[a, "Ttarget"]
    score_based_on_time <- ifelse(
      target - assessment_year > 20, 4,
      ifelse(
        target - assessment_year <= 20 & target - assessment_year > 4, 6, 9)
    )
    
    score <- ifelse(stock_status[find, "Trend"] == -1, 10, score_based_on_time)
    overfished_df[find, "Factor_Score"] <- score
    overfished_df[find, "Rebuilding_Target_Year"] <- target
  }
  
  x <- 1
  for(i in sort(unique(overfished_df[, "Factor_Score"]), decreasing = TRUE)) {
    ties <- which(overfished_df$Factor_Score == i)
    if(length(ties) > 0) {
      overfished_df$Rank[ties] <- x
    }
    x <- x + length(ties)
  }
  
  overfished_df <- 
    overfished_df[order(overfished_df[,"Species"], decreasing = FALSE), ]
  
  utils::write.csv(overfished_df, "data-processed/10_rebuilding.csv", row.names = FALSE)
  
  return(overfished_df)
}