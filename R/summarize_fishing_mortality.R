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
#' @param manage_file CSV file with OFLs, ABCs, and ACLs across years for West Coast groundfish
#' @param species_file CSV file in the data folder called "species_names.csv" that includes
#' all the species to include in this analysis.
#' @param years The specific year to summarize the management quantities (OFLs, ABCs, ACLs).
#' @param manage_quants The names of the management quantities in the manage_file to grep.
#' This allows to easily shift between the ABC and the ACL if needed.
#'
#' @author Chantel Wetzel
#' @import nwfscSurvey
#' @export
#' @md
#' 
#' @examples
#' library(nwfscSurvey)
#' 
#' summarize_fishing_mortality(
#' 		file_name <- "commercial_mortality.csv"
#' 		manage_file <- "WOC_STOCK_SUMMARY11232021.csv"
#' 		species_file <-  "species_names.csv"
#' 		years <- 2018:2020
#' )
#'
#'
summarize_fishing_mortality <- function(
	manage_file, 
	species_file, 
	years, 
	manage_quants = c("Overfishing Limit", "Annual Catch Limit")) {

	data <- nwfscSurvey::pull_gemm(years = years)
	targets <- read.csv(file.path("data", manage_file)) 
	species <-  read.csv(paste0("data/", species_file))

	mort_df <- data.frame(
		Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Average_Removals = NA,
		Average_OFL = NA,
		Average_OFL_Attainment = NA,
		Average_ACL = NA,
		Average_ACL_Attainment = NA 
	)
	
	for(sp in 1:nrow(species)) {

		key <- ss <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], data$species, ignore.case = TRUE)
			)

			#first_name <- strsplit(species[sp, a], split = " rockfish")
			ss <- c(ss, 
				grep(species[sp, a], targets$STOCK_NAME, ignore.case = TRUE)
			)
		}
		ss <- unique(ss)
		key <- unique(key)

		sub_data <- data[key,]
		mort_df[sp, "Average_Removals"] <- sum(sub_data$total_discard_with_mort_rates_applied_and_landings_mt) / length(years)
		
		if (length(ss) > 0 ) {
			temp_targ <- targets[ss,]
			ind <- which(temp_targ$SPECIFICATION_NAME %in% manage_quants & temp_targ$YEAR %in% years) 
			temp_targ <- temp_targ[ind, ]
			
			# Need to use sum rather than mean due to OFLs and ACLs under different names (e.g. Gopher and Black and Yellow)
			value <- aggregate(SPECIFICATION_VALUE ~ SPECIFICATION_NAME, temp_targ, sum)
			mort_df$Average_OFL[sp] <- 
				value[value$SPECIFICATION_NAME == manage_quants[1], "SPECIFICATION_VALUE"] /
				length(years)
			mort_df$Average_ACL[sp] <- 
				value[value$SPECIFICATION_NAME == manage_quants[2], "SPECIFICATION_VALUE"] /
				length(years)
		}
		

		mort_df$Average_OFL_Attainment[sp] <- mort_df$Average_Removals[sp] / mort_df$Average_OFL[sp]
		score <-
			ifelse(mort_df$Average_OFL_Attainment[sp] <= 0.10, 1,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.10 & mort_df$Average_OFL_Attainment[sp] <= 0.25, 2,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.25 & mort_df$Average_OFL_Attainment[sp] <= 0.50, 3,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.50 & mort_df$Average_OFL_Attainment[sp] <= 0.75, 5,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.75 & mort_df$Average_OFL_Attainment[sp] <= 0.90, 7,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.90 & mort_df$Average_OFL_Attainment[sp] <= 1.00, 8,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 1.00 & mort_df$Average_OFL_Attainment[sp] <= 1.10, 9,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 1.10, 10))))))))

		mort_df$Factor_Score[sp] <- score
	}

	mort_df$Average_ACL_Attainment <- (mort_df$Average_Removasl / mort_df$Average_ACL)

	mort_df <- 
		mort_df[order(mort_df[,"Average_OFL_Attainment"], decreasing = TRUE), ]

	x <- 1
	for(i in 10:1) {
		ties <- which(mort_df$Factor_Score == i)
		if(length(ties) > 0) {
			mort_df$Rank[ties] <- x
		}
		x <- x + length(ties)
	}


	write.csv(mort_df, file.path("tables", "fishing_mortality.csv"), row.names = FALSE)

	fish_mort <- data.frame(Species = mort_df$Species,
							Average_Removals = mort_df$Average_Removals)
	return(fish_mort)
}