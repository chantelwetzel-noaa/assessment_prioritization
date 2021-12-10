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
#' file_name <- "revenue_summarized_12052021.csv"
#' file_name <- "tribal_revenue_12062021.csv"
#' species_file <-  "species_names.csv"
#' years <- 2016:2020
#'
#'
summarize_revenue <- function(file_name, species_file, years, max_exp = 0.18) {

	data <- read.csv(paste0("data/", file_name)) 
	species <-  read.csv(paste0("data/", species_file))
	subsistence_score <- read.csv(file.path("doc", "tables", "subsistence_score.csv"))

	revenue_df <- data.frame(Species = species[,1], 
							 Rank = NA, 
							 Factor_Score = NA,
							 Subsitence_Score = NA,
							 Initial_Factor_Score = NA, 
							 Interum_Value = NA, 
							 Revenue = NA)

	denominator <- 1000
	max <- 10
	if (unique(data$FLEET_CODE) == "TI") {
		denominator <- 1
		max <- 7
	}

	for(sp in 1:nrow(species)){

		key <- ss <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], data$PACFIN_SPECIES_COMMON_NAME, ignore.case = TRUE)
			)

			ss <- c(ss, 
				grep(species[sp,a], subsistence_score$Species, ignore.case = TRUE)
			)
		}

		revenue_df$Subsitence_Score[sp] <- subsistence_score[ss[1], "Score"]

		
		sub_data <- data[key,]
		find <- which(sub_data$PACFIN_YEAR %in% years) 

		revenue_df[sp, "Revenue"] <- round(sum(sub_data[find, "AFI_EXVESSEL_REVENUE"]) / denominator, 0)
		if(is.na(revenue_df[sp, "Revenue"])) { 
			revenue_df[sp, "Revenue"] <- 0 
		}
		revenue_df[sp, "Interum_Value"] <- as.numeric(revenue_df[sp, "Revenue"]) ^ max_exp
	}

	temp <- revenue_df$Interum_Value * max / max(revenue_df$Interum_Value) 	

	if(unique(data$FLEET_CODE) == "TI") {	
		revenue_df$Initial_Factor_Score <- temp	
		revenue_df$Factor_Score <- revenue_df$Initial_Factor_Score + revenue_df$Subsitence_Score
		revenue_df <- revenue_df[order(revenue_df[,"Factor_Score"], decreasing = TRUE),]
		revenue_df$Rank <- 1:nrow(revenue_df)
		write.csv(revenue_df, paste0("tables/", "tribal_revenue.csv"), row.names = FALSE)
	}

	if(!"TI" %in% unique(data$FLEET_CODE)) {
		revenue_df$Factor_Score <- temp
		revenue_df <- revenue_df[order(revenue_df[,"Factor_Score"], decreasing = TRUE),]
		revenue_df$Rank <- 1:nrow(revenue_df)
		revenue_df <- revenue_df[, !colnames(revenue_df) %in% c("Initial_Factor_Score", "Subsitence_Score")]
		write.csv(revenue_df, paste0("tables/", "commercial_revenue.csv"), row.names = FALSE)
	}

}