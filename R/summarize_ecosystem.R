#' Calculate ecosystem rank based upon Atlantis/Ecosim output
#' 
#'
#' @param ecosystem_data A csv file with ecosystem scores by species based on Atlantis/Ecosim
#'
#' @author Chantel Wetzel
#' @export
#' 
#' 
summarize_ecosystem <- function(
  ecosystem_data){
  
  colnames(ecosystem_data)[1] <- "Species"
  # Top Down is the consumption values and bottom up is the consumer values
  ecosystem_data$Factor_Score <- round(10 * (ecosystem_data$prop_consumption_scaled + ecosystem_data$prop_consumer_bio_scaled) /
    max((ecosystem_data$prop_consumption_scaled + ecosystem_data$prop_consumer_bio_scaled)), 2)
  
  ecosystem_data <- with(ecosystem_data, ecosystem_data[order(ecosystem_data[, "Factor_Score"], decreasing = TRUE), ])
  ecosystem_data$Rank <- 1:nrow(ecosystem_data)
  ecosystem_data <- with(ecosystem_data, ecosystem_data[order(ecosystem_data[, "Species"], decreasing = FALSE), ])
  ecosystem_data <- ecosystem_data[,c("Species",
                                      "Rank",
                                      "Factor_Score",
                                      "prop_consumption_scaled",
                                      "prop_consumer_bio_scaled")]
  colnames(ecosystem_data) <- c("Species",
                                "Rank",
                                "Factor_Score",
                                "Top_Down_Scaled",
                                "Bottom_Up_Scaled")
  ecosystem_data[, c("Top_Down_Scaled", "Bottom_Up_Scaled")] <- round(ecosystem_data[, c("Top_Down_Scaled", "Bottom_Up_Scaled")], 2)
  utils::write.csv(ecosystem_data, "data-processed/5_ecosystem.csv", row.names = FALSE)
  return(ecosystem_data)
}