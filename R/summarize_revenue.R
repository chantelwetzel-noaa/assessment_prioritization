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
#' @param revenue CSV file pulled from PacFIN with commerical revenue
#' data
#' @param species_file A csv file will all species name to summarize
#' @param years A vector of years to calculate the average revenue across (e.g. 2016:2020)
#' @param max_exp Deprecated: A numerical value to assume as the exponent to create a reasonable
#' spread across rankings by species.
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' @examples
#' summarize_revenue(
#' 		file_name <- "revenue_summarized_12052021.csv",
#' 		species_file <-  "species_names.csv",
#' 		years <- 2016:2020
#' )
#'
#' summarize_revenue(
#' 		file_name <- "tribal_revenue_12062021.csv",
#' 		species_file <-  "species_names.csv",
#' 		years <- 2016:2020
#' )
#' 
#'
summarize_revenue <- function(revenue, species, subsistence_score = NULL, max_exp = 0.18) {

  data <- revenue
	#data <- read.csv(paste0("data-raw/", file_name)) 
	#species <-  read.csv(paste0("data-raw/", species_file))
	#subsistence_score <- read.csv(file.path("doc", "tables", "subsistence_score.csv"))
  
  #data <- data[data$PACFIN_YEAR %in% years, ]

	revenue_df <- data.frame(Species = species[,1], 
							 Rank = NA, 
							 Factor_Score = NA,
							 Subsistence_Score = NA,
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
				grep(species[sp,a], subsistence_score$Species, ignore.case = TRUE)
			)
		}
		
    if(!is.null(subsistence_score)){
      revenue_df$Subsistence_Score[sp] <- subsistence_score[ss[1], "Score"]
    }
		
		if(length(key)>0){
		  sub_data <- data[key,]
		  #find <- which(sub_data$PACFIN_YEAR %in% years) 
		  rev_tmp <- aggregate(AFI_EXVESSEL_REVENUE~AGENCY_CODE, sub_data, function(x) sum(x) / denominator)
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

	if(is.null(subsistence_score)){
	  revenue_df[, "Factor_Score"] <- 10 * log(as.numeric(revenue_df[, "Revenue"]) + 1) / max(log(as.numeric(revenue_df[, "Revenue"]) + 1))
	} else {
	  revenue_df[, "Factor_Score"] <- revenue_df[, "Subsistence_Score"] + 7 * log(as.numeric(revenue_df[, "Revenue"]) + 1) / 
	    max(log(as.numeric(revenue_df[, "Revenue"]) +  1))
	}
	
	revenue_df <- revenue_df[order(revenue_df[,"Factor_Score"], decreasing = TRUE),]
	revenue_df$Rank <- 1:nrow(revenue_df)
	revenue_df <- revenue_df[order(revenue_df[,"Species"], decreasing = FALSE),]
	revenue_df$Factor_Score <- round(revenue_df$Factor_Score, 2)
	revenue_df[, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")] <- round(revenue_df[, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")], 1)

	if(!"TI" %in% unique(data$FLEET_CODE)) {
		revenue_df <- revenue_df[, !colnames(revenue_df) %in% c("Subsistence_Score")]		
		write.csv(revenue_df, "data-processed/2_commercial_revenue.csv", row.names = FALSE)
	} else {
	  write.csv(revenue_df, "data-processed/3_tribal_revenue.csv", row.names = FALSE)
	}
  return(revenue_df)
}