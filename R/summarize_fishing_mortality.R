#' Comparison between recent average mortality, OFLs,
#' and ABCs. The official recent average mortality should
#' come from the GEMM rather than a pull from PacFIN. 
#' The manage_file is a file containing management quantities
#' provided in a special pull by Rob Ames from the GMT016 table.
#' This special pull of all management quantities by species across years
#' had some issues that had to be fixed by hand:
#' 1) Many rockfish species were missing "Rockfish" in their names and
#' I had to correct them by hand due to grep issues when only the first
#' name were used (e.g., China changed to China Rockfish).
#' 2) The file does not contain OFLs or ABCs for sablefish, longspine
#' thornyhead, and shortspine thornyhead.
#' 3) Quantities (OFLs,..) were duplicated for blue rockfish and rougheye/blackspotted
#' rockfish and had to be corrected by hand.
#'
#' @param manage_file CSV file with OFLs and ABCs across years
#' @param species_file CSV file in the data folder called "species_names.csv"
#' @param years the specific year to summarize
#'
#' @author Chantel Wetzel
#' @import nwfscSurvey
#' @export
#' @md
#' 
#' library(nwfscSurvey)
#' file_name <- "commercial_mortality.csv"
#' manage_file <- "WOC_STOCK_SUMMARY11232021.csv"
#' species_file <-  "species_names.csv"
#' years <- 2018:2020
#' 
#' 
#'
#'
summarize_fishing_mortality <- function(manage_file, species_file, years) {

	data <- nwfscSurvey::pull_gemm(years = years)
	targets <- read.csv(file.path("data", manage_file)) 
	species <-  read.csv(paste0("data/", species_file))

	mort_df <- data.frame(
		Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Fishing_Mortality = NA,
		OFL = NA,
		OFL_Attain_Percent = NA,
		Total_Below_OFL = NA, 
		ABC = NA,
		ABC_Attain_Percent = NA 
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

		sub_data <- data[key,]
		mort_df[sp, "Fishing_Mortality"] <- sum(sub_data$total_discard_with_mort_rates_applied_and_landings_mt) / length(years)
		
		temp_targ <- targets[ss,]
		ind <- which(temp_targ$SPECIFICATION_NAME %in% c("Overfishing Limit", "Acceptable Bio Catch") & temp_targ$YEAR %in% years) 
		temp_targ <- temp_targ[ind, ]
		
		# Need to use sum rather than mean due to OFLs and ABCs under different names (e.g. Gopher and Black and Yellow)
		value <- aggregate(SPECIFICATION_VALUE ~ SPECIFICATION_NAME, temp_targ, sum)
		mort_df$OFL[sp] <- 
			value[value$SPECIFICATION_NAME == "Overfishing Limit", "SPECIFICATION_VALUE"] /
			length(years)
		mort_df$ABC[sp] <- 
			value[value$SPECIFICATION_NAME == "Acceptable Bio Catch", "SPECIFICATION_VALUE"] /
			length(years)
		

		mort_df$OFL_Attain_Percent[sp] <- mort_df$Fishing_Mortality[sp] / mort_df$OFL[sp]
		score <-
			ifelse(mort_df$OFL_Attain_Percent[sp] <= 0.10, 1,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 0.10 & mort_df$OFL_Attain_Percent[sp] <= 0.25, 2,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 0.25 & mort_df$OFL_Attain_Percent[sp] <= 0.50, 3,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 0.50 & mort_df$OFL_Attain_Percent[sp] <= 0.75, 5,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 0.75 & mort_df$OFL_Attain_Percent[sp] <= 0.90, 7,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 0.90 & mort_df$OFL_Attain_Percent[sp] <= 1.00, 8,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 1.00 & mort_df$OFL_Attain_Percent[sp] <= 1.10, 9,
			ifelse(mort_df$OFL_Attain_Percent[sp] > 1.10, 10))))))))

		mort_df$Factor_Score[sp] <- score
	}

	mort_df$Total_Below_OFL <-  mort_df$OFL - mort_df$Fishing_Mortality 
	mort_df$ABC_Attain_Percent <- 100 * (mort_df$Fishing_Mortality / mort_df$ABC)
	mort_df$OFL_Attain_Percent <- 100 * mort_df$OFL_Attain_Percent

	mort_df <- 
		mort_df[order(mort_df[,"OFL_Attain_Percent"], decreasing = TRUE), ]

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
							Fishing_Mortality = mort_df$Fishing_Mortality)
	return(fish_mort)
}