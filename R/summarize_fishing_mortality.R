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
#' 2023 Notes of GMT 015 correction
#' 1) blue rockfish in Oregon - hand deleted the blue/deacon/black complex rows
#' 2) cowcod - hand deleted the south of 4010 rows and add in the ACLs by area
#' 3) lingcod - hand deleted WA-OR and 42-4010 rows
#' 4) starry and kelp - add rockfish to each
#' 
#' 2023 future spex fixes
#' 1) delete s4010 cowcod
#' 
#' @param gemm_mortality R object created by nwfscSurvey::pull_gemm()
#' @param harvest_spex CSV file with OFLs, ABCs, and ACLs across years for West Coast groundfish
#' @param species CSV file in the data folder called "species_names.csv" that includes
#' all the species to include in this analysis.
#' @param manage_quants The names of the management quantities in the manage_file to grep.
#' This allows to easily shift between the ABC and the ACL if needed.
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' @examples
#' 
#'
#'
summarize_fishing_mortality <- function(
  gemm_mortality,
	harvest_spex, 
	species = species, 
	manage_quants = c("OVERFISHING_LIMIT", "ANNUAL_CATCH_LIMIT")) {

  data <- gemm_mortality
  spex <- harvest_spex

	mort_df <- data.frame(
		Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Average_Catches = NA,
		Average_OFL = NA,
		Average_OFL_Attainment = NA,
		Average_ACL = NA,
		Average_ACL_Attainment = NA#,
		#Future_OFL_Attainment = NA,
		#Future_ACL_Attainment = NA
	)
	
	for(sp in 1:nrow(species)) {

		key <- ss <- ff <- NULL
		name_list <- species[sp, species[sp,] != -99]
		
		for(a in 1:length(name_list)){
			key <- c(key, grep(species[sp,a], data$species, ignore.case = TRUE))
			ss <- c(ss, grep(species[sp, a], spex$STOCK_OR_COMPLEX, ignore.case = TRUE))
			#ff <- c(ff, grep(species[sp, a], future_spex$STOCK_OR_COMPLEX, ignore.case = TRUE))
		}
		if (length(ss) == 0){
		  for(a in 1:length(name_list)){
		    init_string <- tm::removeWords(species[sp, a], " rockfish")
		    ss <- c(ss, grep(init_string, spex$STOCK_OR_COMPLEX, ignore.case = TRUE))
		  }
		}
		#if (length(ff) == 0){
		#  for(a in 1:length(name_list)){
		#    init_string <- tm::removeWords(species[sp, a], " rockfish")
		#    ff <- c(ff, grep(init_string, future_spex$STOCK_OR_COMPLEX, ignore.case = TRUE))
		#  }
		#}
		
		ss <- unique(ss)
		key <- unique(key)
		#ff <- unique(ff)

		sub_data <- data[key,]
		mort_df[sp, "Average_Catches"] <- sum(sub_data$total_discard_with_mort_rates_applied_and_landings_mt) / length(unique(data$year))
		
		if (length(ss) > 0 ) {
			temp_spex <- spex[ss,]
			ind <- which(colnames(temp_spex) %in% c("SPEX_YEAR", manage_quants)) 
			temp_spex <- temp_spex[, ind]
			
			# Need to use sum rather than mean due to OFLs and ACLs under different names (e.g. Gopher and Black and Yellow)
			value <- apply(temp_spex[,2:3], 2, sum, na.rm = TRUE) #aggregate(SPECIFICATION_VALUE ~ SPECIFICATION_NAME, temp_spex, sum)
			mort_df$Average_OFL[sp] <- value[ manage_quants[1]] / length(unique(temp_spex$SPEX_YEAR))
			mort_df$Average_ACL[sp] <- value[ manage_quants[2]] / length(unique(temp_spex$SPEX_YEAR))
		}
		
		mort_df$Average_OFL_Attainment[sp] <- mort_df$Average_Catches[sp] / mort_df$Average_OFL[sp]
		
		mort_df[sp, "Factor_Score"] <-
			ifelse(mort_df$Average_OFL_Attainment[sp] <= 0.10, 1,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.10 & mort_df$Average_OFL_Attainment[sp] <= 0.25, 2,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.25 & mort_df$Average_OFL_Attainment[sp] <= 0.50, 3,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.50 & mort_df$Average_OFL_Attainment[sp] <= 0.75, 5,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.75 & mort_df$Average_OFL_Attainment[sp] <= 0.90, 7,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 0.90 & mort_df$Average_OFL_Attainment[sp] <= 1.00, 8,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 1.00 & mort_df$Average_OFL_Attainment[sp] <= 1.10, 9,
			ifelse(mort_df$Average_OFL_Attainment[sp] > 1.10, 10))))))))
	}
	
	mort_df$Average_ACL_Attainment <- (mort_df$Average_Catches / mort_df$Average_ACL)

	mort_df[, c("Average_Catches", "Average_OFL", "Average_ACL")] <- 
	  round(mort_df[, c("Average_Catches", "Average_OFL", "Average_ACL")], 1)
	mort_df[, c("Average_OFL_Attainment", "Average_ACL_Attainment")] <-
	  round(100 * mort_df[, c("Average_OFL_Attainment", "Average_ACL_Attainment")], 1)
	
	mort_df <- mort_df[order(mort_df[,"Factor_Score"], decreasing = TRUE), ]

	x <- 1
	for(i in sort(unique(mort_df[, "Factor_Score"]), decreasing = TRUE)) {
		ties <- which(mort_df$Factor_Score == i)
		if(length(ties) > 0) {
			mort_df$Rank[ties] <- x
		}
		x <- x + length(ties)
	}

	mort_df <- 
	  mort_df[order(mort_df[,"Species"], decreasing = FALSE), ]
	
	write.csv(mort_df, file.path("data-processed", "1_fishing_mortality.csv"), row.names = FALSE)

	fish_mort <- data.frame(Species = mort_df$Species,
	                        Factor_Score = mort_df$Factor_Score,
							            Average_Catches = mort_df$Average_Catches)
	return(fish_mort)
}