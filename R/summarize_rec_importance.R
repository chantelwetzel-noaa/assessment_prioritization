#' Calculate recreational importance
#' 
#' Summarize and format recreational catch data to be used along with recreational
#' importance scores to calculate the 'pseudo revenue' by species for the recreational fishery.  
#' The function currently uses an existing csv file with previously calculated recreational
#' importance to access existing relative weights for each species and state. In the future
#' this should be modified in the future to use a stand-alone file containing the recreational
#' species weights by state that should be saved in the "data" folder.
#'
#' @param rec_catch A dataframe created by filter_gemm function with only recreational catches
#'   by state.
#' @param species Data object read from the data folder called "species_names.csv" that includes
#'   all the species to include in this analysis.
#' @param rec_importance A CSV file with the state-specific species importance scores
#' @param frequency Suggested assessment frequency based upon biology. A csv file from 
#'   the previous assessment prioritization assessment
#'   frequency tab. The csv file to be read is found in the data folder:
#'   data-raw/species_sigmaR_catage_main.csv
#'
#' @author Chantel Wetzel
#' @export
#' 
#' @examples
#' \dontrun{
#' summarize_rec_importance(
#' 		file_name <- "CTE002-2016---2020.csv",
#' 		years <- 2016:2020,
#' 		species_file <-  "species_names.csv"
#' )
#' }
#'
#'
summarize_rec_importance <- function(
  rec_catch, 
  species, 
  rec_importance, 
  frequency) {

  data <- rec_catch
	#data <- read.csv(paste0("data-raw/", file_name)) 
	#species <-  read.csv(paste0("data/", species_file))
	#rec_score <- read.csv(file.path("doc", "tables", "recr_importance.csv"))
	rec_score <- rec_importance
	rec_score[is.na(rec_score)] <- 0

	rec_importance_df <- data.frame(
		Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Assessed_Last_Cycle = 0, 
		Pseudo_Revenue_Coastwide = NA,
		Pseudo_Revenue_CA = NA,
		Pseudo_Revenue_OR = NA,
		Pseudo_Revenue_WA = NA,
		Species_Importance_CA = NA,
		Species_Importance_OR = NA, 
		Species_Importance_WA = NA,  
		Catch_Coastwide = NA, 
		California_Recreational = NA,
		Oregon_Recreational = NA, 
		Washington_Recreational = NA
	)

	# Remove "Dogfish Shark Family" so it does not get lumped with dogfish 
	# data <- data[data$SPECIES != "Dogfish Shark Family", ]
	# Filter the data
	# data <- data[data$RECFIN_YEAR %in% years, ]
	
	for(sp in 1:nrow(species)) {

		key <- ss <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], data$species, ignore.case = TRUE)
			)

			ss <- c(ss, 
				grep(species[sp,a], rec_score$Species, ignore.case = TRUE)
			)
		}

		rec_importance_df[sp, c("California_Recreational", "Oregon_Recreational", "Washington_Recreational")] <- 0
		
		if(length(key) > 0){
		  sub_data <- data[key,]
		  catch_sum <- stats::aggregate(total_discard_with_mort_rates_applied_and_landings_mt ~ sector, sub_data, sum)
      state_vector <- gsub(" ", "_", catch_sum[,1])
		  rec_importance_df[sp, state_vector] <-
		    aggregate(total_discard_with_mort_rates_applied_and_landings_mt ~ sector, sub_data, sum)[,2]
		} 
		  
		rec_importance_df[sp, "Catch_Coastwide"] <- 
			sum(rec_importance_df[sp, c("California_Recreational", "Oregon_Recreational", "Washington_Recreational")], na.rm = TRUE)

		rec_importance_df[sp, c("Species_Importance_CA", "Species_Importance_OR", "Species_Importance_WA")] <- 
			rec_score[ss[1], c("CA", "OR", "WA")]

		rec_importance_df[sp, c("Pseudo_Revenue_CA", "Pseudo_Revenue_OR", "Pseudo_Revenue_WA")] <- 
			rec_score[ss[1], c("CA", "OR", "WA")] * 
			rec_importance_df[sp, c(c("California_Recreational", "Oregon_Recreational", "Washington_Recreational"))] 

		rec_importance_df[sp, "Pseudo_Revenue_Coastwide"] <- 
			sum(rec_importance_df[sp, c("Pseudo_Revenue_CA", "Pseudo_Revenue_OR", "Pseudo_Revenue_WA")], na.rm = TRUE)

	}

	rec_importance_df$Factor_Score <- log(rec_importance_df$Pseudo_Revenue_Coastwide + 1) #* 10 / 
		#max(log(rec_importance_df$Pseudo_Revenue_Coastwide + 1))
	
	species_just_assessed <- frequency[which(frequency$Last_Assess == (as.numeric(format(Sys.Date(), "%Y")) - 1)), "Species"]
	rec_importance_df[which(rec_importance_df$Species %in% species_just_assessed), "Assessed_Last_Cycle"] <- -2
	rec_importance_df[which(rec_importance_df$Species %in% species_just_assessed), "Factor_Score"] <- 
	  ifelse(rec_importance_df[which(rec_importance_df$Species %in% species_just_assessed), "Factor_Score"] + rec_importance_df[which(rec_importance_df$Species %in% species_just_assessed), "Assessed_Last_Cycle"] > 0,
	         rec_importance_df[which(rec_importance_df$Species %in% species_just_assessed), "Factor_Score"] + rec_importance_df[which(rec_importance_df$Species %in% species_just_assessed), "Assessed_Last_Cycle"], 0)
	rec_importance_df[, "Factor_Score"] <- 10 * rec_importance_df[, "Factor_Score"] / max(rec_importance_df[, "Factor_Score"])
	
	rec_importance_df <- 
		rec_importance_df[order(rec_importance_df[,"Factor_Score"], decreasing = TRUE), ]

	rec_importance_df$Rank <- 1:nrow(rec_importance_df)
	# Quick check to deal with 0 ties
	ind <- which(rec_importance_df$Factor_Score == 0)
	rec_importance_df$Rank[ind] = rec_importance_df$Rank[ind[1]] 
	rec_importance_df <- rec_importance_df[order(rec_importance_df[,"Species"], decreasing = FALSE),]
	colnames(rec_importance_df)[colnames(rec_importance_df) %in% c("California_Recreational", "Oregon_Recreational", "Washington_Recreational")] <-
	  c("Catch_CA", "Catch_OR", "Catch_WA")
	
	rec_importance_df[, c("Catch_Coastwide", "Catch_CA", "Catch_OR", "Catch_WA")] <- round(rec_importance_df[, c("Catch_Coastwide", "Catch_CA", "Catch_OR", "Catch_WA")], 1)
	rec_importance_df[, c("Pseudo_Revenue_Coastwide", "Pseudo_Revenue_CA", "Pseudo_Revenue_OR", "Pseudo_Revenue_WA")] <- round(rec_importance_df[, c("Pseudo_Revenue_Coastwide", "Pseudo_Revenue_CA", "Pseudo_Revenue_OR", "Pseudo_Revenue_WA")], 1)
	rec_importance_df[, "Factor_Score"] <- round(rec_importance_df[, "Factor_Score"], 2)
	
	utils::write.csv(rec_importance_df, "data-processed/4_recreational_importance.csv", row.names = FALSE)
	return(rec_importance_df)
}