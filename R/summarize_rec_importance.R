#' Summarize and format recreational catch data to be used
#' along with recreational importance scores to calculate the 
#' 'revenue' by species for the recreational fishery.  
#'
#' @param file_name CSV file pulled from PacFIN with commerical revenue
#' data
#' @param species_file
#' @param years
#' @param max_exp
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' file_name <- "CTE002-2016---2020.csv"
#' year <- 2016:2020
#' 
#' 
#'
#'
summarize_rec_importance <- function(file_name, species_file, years, max_exp = 0.18) {

	data <- read.csv(paste0("data/", file_name)) 
	species <-  read.csv(paste0("data/", species_file))
	rec_score <- read.csv(file.path("doc", "tables", "recr_importance.csv"))

	rec_importance_df <- data.frame(
		Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Initial_Factor_Score = NA, 
		Pseudo_CW = NA,
		Pseudo_CA = NA,
		Pseudo_OR = NA,
		Pseudo_WA = NA,
		Rel_Weight_CA = NA,
		Rel_Weight_OR = NA, 
		Rel_Weight_WA = NA,  
		Ret_Catch_CW = NA, 
		Ret_Catch_CA = NA,
		Ret_Catch_OR = NA, 
		Ret_Catch_WA = NA
	)

	# Remove "Dogfish Shark Family" so it does not get lumped with dogfish 
	data <- data[data$SPECIES != "Dogfish Shark Family", ]
	
	for(sp in 1:nrow(species)) {

		key <- ss <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], data$SPECIES, ignore.case = TRUE)
			)

			ss <- c(ss, 
				grep(species[sp,a], rec_score$Species, ignore.case = TRUE)
			)
		}

		sub_data <- data[key,]
		find <- which(sub_data$RECFIN_YEAR %in% years) 
		sub_data <- sub_data[find, ]

		rec_importance_df[sp, c("Ret_Catch_CA", "Ret_Catch_OR", "Ret_Catch_WA")] <-
			c(sum(sub_data[key, "CALIFORNIA_RETAINED_MT"], na.rm = TRUE), 
			  sum(sub_data[key, "OREGON_RETAINED_MT"], na.rm = TRUE), 
			  sum(sub_data[key, "WASHINGTON_RETAINED_MT"], na.rm = TRUE) )

		rec_importance_df[sp, "Ret_Catch_CW"] <- 
			sum(rec_importance_df[sp, c("Ret_Catch_CA", "Ret_Catch_OR", "Ret_Catch_WA")], na.rm = TRUE)

		rec_importance_df[sp, c("Rel_Weight_CA", "Rel_Weight_OR", "Rel_Weight_WA")] <- 
			rec_score[ss[1], c("CA", "OR", "WA")]

		rec_importance_df[sp, c("Pseudo_CA", "Pseudo_OR", "Pseudo_WA")] <- 
			rec_score[ss[1], c("CA", "OR", "WA")] * 
			rec_importance_df[sp, c("Ret_Catch_CA", "Ret_Catch_OR", "Ret_Catch_WA")] 

		rec_importance_df[sp, "Pseudo_CW"] <- 
			sum(rec_importance_df[sp, c("Pseudo_CA", "Pseudo_OR", "Pseudo_WA")], na.rm = TRUE)

	}

	rec_importance_df$Initial_Factor_Score <- rec_importance_df$Pseudo_CW ^ max_exp
	rec_importance_df$Factor_Score <- rec_importance_df$Initial_Factor_Score * 10 / 
		max(rec_importance_df$Initial_Factor_Score)

	rec_importance_df <- 
		rec_importance_df[order(rec_importance_df[,"Factor_Score"], decreasing = TRUE), ]

	rec_importance_df$Rank <- 1:nrow(rec_importance_df)
	# Quick check to deal with 0 ties
	ind <- which(rec_importance_df$Factor == 0)
	rec_importance_df$Rank[ind] = rec_importance_df$Rank[ind[1]] 

	write.csv(rec_importance_df, paste0("tables/", "recreational_importance.csv"), row.names = FALSE)
}