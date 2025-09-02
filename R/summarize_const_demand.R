#' Calculations used for the "Const Demand" tab for assessment prioritization.
#' 
#' The values used in the constituent demand tab are primarily scored qualitatively.
#' This function will provide the state, gear, and sector (commercial vs. recreational)
#' differences across the states and coastwide which then can be qualitatively
#' used to input modifiers.
#'
#' @param revenue_data R data object for revenue data that has been filtered by year 
#'   using [filter_years()] from PacFIN that  
#'   includes both commercial and tribal revenue (data-raw/pacfin_revenue.csv).
#' @param rec_importance_data R data object created by [summarize_rec_importance()] for tribal catch
#'   data.
#' @param fishing_mortality R data object created by [summarize_fishing_mortality()].
#' @param future_spex R data objected created from the csv file downloaded from PacFIN
#'   APEX report table 8 that provides potential harvest specifications for the upcoming
#'   harvest specification cycle.  The csv file should be saved in the data-raw folder.
#'   Example: data-raw/GMT008-harvest specifications_alt2-2025.csv
#' @param species R data object that contains a list of species names to calculate
#'   assessment prioritization.  The csv file with the list of species names should be 
#'   stored in the data-raw folder ("species_names.csv")
#'
#' @author Chantel Wetzel
#' @export
#' 
#'
summarize_const_demand <- function(
  revenue_data, 
  rec_importance_data, 
  fishing_mortality,
  future_spex,
  species = species) {

	rec_data <- rec_importance_data 
	revenue_data$gear <- "TWL"
	revenue_data$gear[!revenue_data$PACFIN_GROUP_GEAR_CODE == "TWL"] <- "NTWL"

	rec_data <- with(rec_data, rec_data[order(rec_data[,"Species"]), ])

	data <- data.frame(
	  Species = species[,1], 
	  Commercial_Importance_Modifier = 0,
		CW = NA, 
		C = NA,
		O = NA,
		W = NA, 
		TWL = NA, 
		NTWL = NA)

	com_importance_df <- score_rank_df <- data

	rec_tmp <- rec_data[, c("Species", "Pseudo_Revenue_Coastwide", "Pseudo_Revenue_CA", "Pseudo_Revenue_OR", "Pseudo_Revenue_WA")]
	colnames(rec_tmp)[2:5] <- c("CW", "C", "O", "W")
	rec_score_df <- rec_importance_df <- rec_tmp #data[, -c(ncol(data)-1, ncol(data))]

	denominator <- 1000
	max_value <- 10

	# Calculate commercial ranking and scores first
	# This breaks things out by non-trawl and trawl but also includes both 
	# commercial and tribal revenue combined by state
	for(sp in 1:nrow(species)) {

		key <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], revenue_data$NOMINAL_TO_ACTUAL_PACFIN_SPECIES_NAME, ignore.case = TRUE)
			)
		}
		
		sub_data <- revenue_data[key,]

		tmp <- stats::aggregate(AFI_EXVESSEL_REVENUE ~ AGENCY_CODE, sub_data, function(x) sum(x) / denominator )
		data[sp, "CW"] <- sum(tmp$AFI_EXVESSEL_REVENUE) 
		for(aa in sort(unique(tmp$AGENCY_CODE))) {
			data[sp, colnames(data) == aa] <- tmp[tmp$AGENCY_CODE == aa, "AFI_EXVESSEL_REVENUE"]
		}

		tmp <- aggregate(AFI_EXVESSEL_REVENUE ~ gear, sub_data, function(x) sum(x) / denominator)
		for(gg in sort(unique(tmp$gear))) {
			data[sp, colnames(data) == gg] <- tmp[tmp$gear == gg, "AFI_EXVESSEL_REVENUE"]
		}

		find <- is.na(data[sp,])
		data[sp, find] <- 0		
	}

	for(a in 3:ncol(score_rank_df)){
		score_rank_df[, a] <- round(max_value * log(data[, a] + 1)  / max(log(data[, a] + 1)), 3)
		tmp <- score_rank_df[order(score_rank_df[, a], decreasing = TRUE), c(1, a)]
		tmp$tmp_rank <- 1:nrow(tmp)
		rank <- with(tmp, tmp[order(tmp[,"Species"]), ])
		com_importance_df[, a] <- rank$tmp_rank

		x <- 1
		for(i in sort(unique(score_rank_df[, a]), decreasing = TRUE)) {
			ties <- which(score_rank_df[, a] == i)
			if(length(ties) > 0) {
				com_importance_df[, a][ties] <- x
			}
			x <- x + length(ties)
		}
		com_importance_df[, a] <- round(1 - com_importance_df[, a]/max(com_importance_df[, a]),3)
		com_importance_df[, a] <- round(com_importance_df[, a]/max(com_importance_df[, a]),3)
	}
	com_importance_df[, "Commercial_Importance_Modifier"] <- apply(com_importance_df[,c("C", "O", "W")] - com_importance_df[, "CW"] > 0.10, 1, sum) +
	 ifelse(abs(com_importance_df[, "NTWL"] - com_importance_df[, "TWL"]) < 0.10, 1, 0)
  
	#===================================================  
  # Recreational importance
	#===================================================
	for(a in 2:ncol(rec_score_df)){
		rec_score_df[, a] <-  round(max_value * log(rec_tmp[, a] + 1)  / max(log(rec_tmp[, a] + 1)), 3)
		tmp <- rec_score_df[order(rec_score_df[, a], decreasing = TRUE), c(1, a)]
		tmp$tmp_rank <- 1:nrow(tmp)
		rank <- with(tmp, tmp[order(tmp[,"Species"]), ])
		rec_importance_df[, a] <- rank$tmp_rank

		x <- 1
		for(i in sort(unique(rec_score_df[, a]), decreasing = TRUE)) {
			ties <- which(rec_score_df[, a] == i)
			if(length(ties) > 0) {
				rec_importance_df[, a][ties] <- x
			}
			x <- x + length(ties)
		}
		rec_importance_df[, a] <- round(1 - rec_importance_df[, a]/max(rec_importance_df[, a]), 3)
		rec_importance_df[, a] <- round(rec_importance_df[, a]/max(rec_importance_df[, a]), 3)
	}
  rec_importance_df$Recreational_Importance_Modifier <- apply(rec_importance_df[,c("C", "O", "W")] - rec_importance_df[, "CW"] > 0.10, 1, sum) 
  
  #====================================================================================
  # Choke stock - Pull in the fishing mortality tab and use that information or could
  #====================================================================================
  # use only the future spex modifier section
  # Pull in rebuilding tab
  # Sum the commercial and recreational adjustments, choke stock, and rebuilding
  # Rank the scores
  choke_df <- data.frame(
    Species = species[,1],
    Average_Catches = fishing_mortality$Average_Catches,
    Projected_ACL_Attainment = NA,
    Choke_Stock_Score = 0
  )
  
  for(sp in 1:nrow(species)) {
    
    ff <- NULL
    name_list <- species[sp, species[sp,] != -99]
    
    for(a in 1:length(name_list)){
      ff <- c(ff, grep(species[sp, a], future_spex$STOCK_OR_COMPLEX, ignore.case = TRUE))
    }
    if (length(ff) == 0){
      for(a in 1:length(name_list)){
        init_string <- tm::removeWords(species[sp, a], " rockfish")
        ff <- c(ff, grep(init_string, future_spex$STOCK_OR_COMPLEX, ignore.case = TRUE))
      }
    }
    
    ff <- unique(ff)
    
    # Future Attainment
    choke_df$Projected_ACL_Attainment[sp] <- choke_df$Average_Catches[sp] / sum(future_spex[ff, "ACL"], na.rm = TRUE)
    
    # Calculate the adjustment based on future spex limitations
    choke_df[sp, "Choke_Stock_Score"] <-
      ifelse(choke_df$Projected_ACL_Attainment[sp] >= 1.25, 5,
             ifelse(choke_df$Projected_ACL_Attainment[sp] < 1.25 & choke_df$Projected_ACL_Attainment[sp] >= 1, 4,
             ifelse(choke_df$Projected_ACL_Attainment[sp] < 1.0  & choke_df$Projected_ACL_Attainment[sp] >= 0.90, 3,
                    ifelse(choke_df$Projected_ACL_Attainment[sp] < 0.9 & choke_df$Projected_ACL_Attainment[sp] >= 0.80, 2, 
                           ifelse(choke_df$Projected_ACL_Attainment[sp] < 0.8 & choke_df$Projected_ACL_Attainment[sp] >= 0.70, 1, 0)))))
  }
  
  
  const_importance <- data.frame(
    Species = species[,1],
    Rank = NA,
    Factor_Score = choke_df$Choke_Stock_Score + com_importance_df$Commercial_Importance_Modifier + rec_importance_df$Recreational_Importance_Modifier,
    Choke_Stock_Score = choke_df$Choke_Stock_Score,
    Commerical_Importance_Score = com_importance_df$Commercial_Importance_Modifier,
    Recreational_Importance_Score = rec_importance_df$Recreational_Importance_Modifier,
    Projected_ACL_Attainment = round(choke_df$Projected_ACL_Attainment, 2)
  )
  
  const_importance <- const_importance[order(const_importance[,"Factor_Score"], decreasing = TRUE), ]
  
  zz <- 1
  max_range <- ifelse(min(const_importance$Factor_Score) != 0, max(const_importance$Factor_Score), max(const_importance$Factor_Score) + 1)
  for(i in max_range:1) {
    if(min(const_importance$Factor_Score) == 0){
      ties <- which(const_importance$Factor_Score == (i-1))
    } else {
      ties <- which(const_importance$Factor_Score == i)
    }
    if(length(ties) > 0) {
      const_importance$Rank[ties] <- zz
    }
    zz <- zz + length(ties)
  }

  const_importance <- const_importance[order(const_importance[,"Species"], decreasing = FALSE), ]
  utils::write.csv(const_importance, file.path("data-processed", "8_constituent_demand.csv"), row.names = FALSE)
  utils::write.csv(rec_importance_df, file.path("data-processed", "_constituent_demand_rec_importance.csv"), row.names = FALSE)
  utils::write.csv(com_importance_df, file.path("data-processed", "_constituent_demand_com_importance.csv"), row.names = FALSE)
  return(const_importance)
}