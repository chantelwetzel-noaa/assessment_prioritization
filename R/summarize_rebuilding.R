#' Calculate score based upon rebuilding
#' 
#' @param species R data object that contains a list of species names to calculate
#'   assessment prioritization.  The csv file with the list of species names should be 
#'   stored in the data-raw folder ("species_names.csv")
#' @param overfished_data R data object of overfished species from data-raw/overfished_species.csv
#' @param stock_status R data object by the [summarize_stock_status()]
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
  assessment_year = 2027){
  
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
  overfished_df <- replace(overfished_df, overfished_df == "", NA)
  
  utils::write.csv(overfished_df, "data-processed/10_rebuilding.csv", row.names = FALSE)
  
  return(overfished_df)
}