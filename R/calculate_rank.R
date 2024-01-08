#'  
#'
#' @param fishing_mortality,
#' @param commercial_revenue,
#' @param tribal_importance,
#' @param recreational_importance,
#' @param ecosystem,
#' @param stock_status,
#' @param assessment_frequency,
#' @param constituent_demand,
#' @param new_information,
#' @param rebuilding
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#'
calculate_rank <- function(
  fishing_mortality,
  commercial_revenue,
  tribal_importance,
  recreational_importance,
  ecosystem,
  stock_status,
  assessment_frequency,
  constituent_demand,
  new_information,
  rebuilding) {
  
  # 1 Fishing Mortality
  # 2 Commercial Revenue
  # 3 Tribal Importance
  # 4 Recreational Importance
  # 5 Ecosystem
  # 6 Stock Status
  # 7 Assessment Frequency
  # 8 Constituent Demand
  # 9 New Information
  # 10 Rebuilding
  
  overall_rank <- data.frame(
    Species = fishing_mortality$Species,
    Overall_Rank = NA,
    Total_Score = NA,
    fishing_mortality = fishing_mortality$Factor_Score,
    commercial_revenue = commercial_revenue$Factor_Score,
    tribal_importance = tribal_importance$Factor_Score,
    recreational_importance = recreational_importance$Factor_Score,
    ecosystem = ecosystem$Factor_Score,
    stock_status = stock_status$Factor_Score,
    assessment_frequency = assessment_frequency$Factor_Score,
    constituent_demand = constituent_demand$Factor_Score,
    new_information = new_information$Factor_Score,
    rebuilding = rebuilding$Factor_Score
  )
  
  overall_rank$Total_Score <- round(
    fishing_mortality$Factor_Score * 0.08 +
    commercial_revenue$Factor_Score * 0.21 +
    tribal_importance$Factor_Score * 0.05 +
    recreational_importance$Factor_Score * 0.09 +
    ecosystem$Factor_Score * 0.05 +
    stock_status$Factor_Score * 0.08 +
    assessment_frequency$Factor_Score * 0.18 +
    constituent_demand$Factor_Score * 0.11 +
    new_information$Factor_Score * 0.05 +
    rebuilding$Factor_Score * 0.10, 2)
  
  overall_rank <- with(overall_rank, overall_rank[order(overall_rank[, "Total_Score"], decreasing = TRUE), ])
  x <- 1
  for(i in sort(unique(overall_rank[, "Total_Score"]), decreasing = TRUE)) {
    ties <- which(overall_rank$Total_Score == i)
    if(length(ties) > 0) {
      overall_rank$Overall_Rank[ties] <- x
    }
    x <- x + length(ties)
  }
  overall_rank <- with(overall_rank, overall_rank[order(overall_rank[, "Species"], decreasing = FALSE), ])
  
  write.csv(overall_rank, "data-processed/11_overall_rank.csv", row.names = FALSE)
  return(overall_rank)
}