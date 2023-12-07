summarize_rebuilding <- function(species, overfished_data, stock_status, assessment_year){
  
  overfished_df <- data.frame(
    Species = species[,1], 
    Factor_Score = 0,
    Rebuilding_Target = NA
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
    overfished_df[find, "Rebuilding_Target"] <- target
  }
  
  write.csv(overfished_df, "data-processed/10_rebuilding.csv", row.names = FALSE)
}