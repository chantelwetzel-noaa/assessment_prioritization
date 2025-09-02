#' Calculate importance by revenue
#' 
#' Summarize and format commercial revenue data for insert
#' into the assessment prioritizaiton. Data are pulled from 
#' PacFIN filtering for only "P" Council records and removing
#' all tribal and research landing revenue estimates.  The data file
#' includes the following columns from PacFIN:
#' AGENCY_CODE, COUNCIL_CODE, PACFIN_SPECIES_CODE, PACFIN_SPECIES_COMMON_NAME,	
#' NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, PACFIN_YEAR, FLEET_CODE, ROUND_WEIGHT_MTONS, 	
#' AFI_EXVESSEL_REVENUE. The AFI_EXVESSEL_REVENUE column adjusts for inflation and the
#' NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE includes both nominal and species specific
#' records. Exvessel revenue is averaged over select years by species and dollar values
#' are output in the 1,000s.  
#'
#' @inheritParams summarize_stock_status
#' @param revenue R data object filtered by [filter_revenue()] that contains ex-vessel
#'   revenue from PacFIN. A csv file should be saved in data-raw that is from PacFIN 
#'   containing catch information by species (data-raw/pacfin_revenue.csv).
#' @param tribal_score R data object with tribal species importance by species if calculating
#'   revenue for the tribal fishery. The CSV should be saved in data-raw. The default is NULL
#'   which will calculate the revenue for the commercial fishery.
#' @param assess_year R data object with the assessment year by species from the 
#'   data-raw/assess_year_ssc_rec.csv.
#'
#' @author Chantel Wetzel
#' @export
#' 
#'
summarize_revenue <- function(
  revenue, 
  species, 
  tribal_score = NULL, 
  assess_year) {

  data <- revenue

	revenue_df <- data.frame(
	  Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Tribal_Score = NA,
		Assessed_Last_Cycle = 0,
		Revenue = NA,
		CA_Revenue = NA,
		OR_Revenue = NA,
		WA_Revenue = NA)

	denominator <- 1000
	if (unique(data$FLEET_CODE)[1] == "TI") {
		denominator <- 1
	}

	for(sp in 1:nrow(species)){

		key <- ss <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], data$PACFIN_SPECIES_COMMON_NAME, ignore.case = TRUE)
			)

			ss <- c(ss, 
				grep(species[sp,a], tribal_score$Species, ignore.case = TRUE)
			)
		}
		
    if(!is.null(tribal_score)){
      revenue_df$Tribal_Score[sp] <- tribal_score[ss[1], "Score"]
    }
		
		if(length(key)>0){
		  sub_data <- data[key,]
		  rev_tmp <- stats::aggregate(AFI_EXVESSEL_REVENUE~AGENCY_CODE, sub_data, function(x) sum(x) / denominator)
		  revenue_df[sp, "Revenue"] <- sum(rev_tmp[, 2])
		  if(is.na(revenue_df[sp, "Revenue"])) { 
		    revenue_df[sp, "Revenue"] <- 0 
		  }
		  if(sum(rev_tmp$AGENCY_CODE == "C") == 1) {
		    revenue_df[sp, "CA_Revenue"] <- rev_tmp[rev_tmp$AGENCY_CODE == "C", 2]
		  } else {
		    revenue_df[sp, "CA_Revenue"] <- 0
		  }
		  if(sum(rev_tmp$AGENCY_CODE == "O") == 1) {
		    revenue_df[sp, "OR_Revenue"] <- rev_tmp[rev_tmp$AGENCY_CODE == "O", 2]
		  } else {
		    revenue_df[sp, "OR_Revenue"] <- 0
		  }
		  if(sum(rev_tmp$AGENCY_CODE == "W") == 1) {
		    revenue_df[sp, "WA_Revenue"] <- rev_tmp[rev_tmp$AGENCY_CODE == "W", 2]
		  } else {
		    revenue_df[sp, "WA_Revenue"] <- 0
		  }
		} else {
		  revenue_df[sp, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")] <- 0
		}
		
	}
	revenue_df[, "Factor_Score"] <- log(as.numeric(revenue_df[, "Revenue"]) + 1)

	# Reduce the Factor Score by -1 for species that were assessed last cycle
	species_just_assessed <- assess_year[which(assess_year$Last_Assess == (as.numeric(format(Sys.Date(), "%Y")) - 1)), "Species"]
	revenue_df[which(revenue_df$Species %in% species_just_assessed), "Assessed_Last_Cycle"] <- -2
	revenue_df[which(revenue_df$Species %in% species_just_assessed), "Factor_Score"] <- 
	  ifelse(revenue_df[which(revenue_df$Species %in% species_just_assessed), "Factor_Score"] + revenue_df[which(revenue_df$Species %in% species_just_assessed), "Assessed_Last_Cycle"] > 0,
	         revenue_df[which(revenue_df$Species %in% species_just_assessed), "Factor_Score"] + revenue_df[which(revenue_df$Species %in% species_just_assessed), "Assessed_Last_Cycle"], 0)
	
	if(is.null(tribal_score)){
	  revenue_df[, "Factor_Score"] <- 10 * revenue_df[, "Factor_Score"] / max(revenue_df[, "Factor_Score"])
	} else {
	  revenue_df[, "Factor_Score"] <- revenue_df[, "Tribal_Score"] + revenue_df[, "Factor_Score"] 
	  revenue_df[, "Factor_Score"] <- 10 * revenue_df[, "Factor_Score"] / max(revenue_df[, "Factor_Score"])
	}
	
	revenue_df <- revenue_df[order(revenue_df[,"Factor_Score"], decreasing = TRUE),]
	revenue_df$Rank <- 1:nrow(revenue_df)
	revenue_df <- revenue_df[order(revenue_df[,"Species"], decreasing = FALSE),]
	revenue_df$Factor_Score <- round(revenue_df$Factor_Score, 2)
	revenue_df[, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")] <- round(revenue_df[, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")], 1)

	if(!"TI" %in% unique(data$FLEET_CODE)) {
		revenue_df <- revenue_df[, !colnames(revenue_df) %in% c("Tribal_Score")]		
		utils::write.csv(revenue_df, "data-processed/2_commercial_revenue.csv", row.names = FALSE)
	} else {
	  utils::write.csv(revenue_df, "data-processed/3_tribal_revenue.csv", row.names = FALSE)
	}
  return(revenue_df)
}