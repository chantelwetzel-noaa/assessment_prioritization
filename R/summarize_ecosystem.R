#ecosystem_data <- read.csv("data-raw/ecosystem.csv")

summarize_ecosystem <- function(ecosystem_data){
  
  colnames(ecosystem_data)[1] <- "Species"
  # Top Down is the consumption values and bottom up is the consumer values
  ecosystem_data$Factor_Score <- 10 * (ecosystem_data$prop_consumption_scaled + ecosystem_data$prop_consumer_bio_scaled) /
    max((ecosystem_data$prop_consumption_scaled + ecosystem_data$prop_consumer_bio_scaled))
  
  ecosystem_data <- with(ecosystem_data, ecosystem_data[order(ecosystem_data[, "Factor_Score"], decreasing = TRUE), ])
  ecosystem_data$Rank <- 1:nrow(ecosystem_data)
  ecosystem_data <- with(ecosystem_data, ecosystem_data[order(ecosystem_data[, "Species"], decreasing = FALSE), ])
  ecosystem_data <- ecosystem_data[,c("Species",
                                      "Rank",
                                      "Factor_Score",
                                      "functional_groups",
                                      "prop_consumption_scaled",
                                      "prop_consumer_bio_scaled")]
  colnames(ecosystem_data) <- c("Species",
                                "Rank",
                                "Factor_Score",
                                "Ecosystem_Functional_Group",
                                "Top_Down_Scaled",
                                "Bottom_Up_Scaled")
  write.csv(ecosystem_data, "data-processed/5_ecosystem.csv", row.names = FALSE)
  return(ecosystem_data)
}