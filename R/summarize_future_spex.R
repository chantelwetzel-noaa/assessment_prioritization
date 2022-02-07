#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#' 
#'
#' @param manage_file CSV file with OFLs and ABCs across years
#' @param fishing_mort_file 
#' @param species_file CSV file in the data folder called "species_names.csv"
#' @param years the specific year to summarize
#' @param low_f_species summarize for species with low Fs and low OFLs that
#' are excluded from analysis
#'
#' @author Chantel Wetzel
#' @export
#' @md
#' 
#' manage_file <- "GMT008-harvest specifications-2024.csv"
#' fishing_mort_file <- "fishing_mortality.csv"
#' freq_file <- "assessment_frequency.csv"
#' species_file <-  "species_names.csv"
#' years <- c(2019, 2021)
#' low_f_species <- TRUE
#' 
#' species_file <- "species_names_not_included.csv"
#' low_f_species = FALSE
#'
summarize_future_spex <- function(manage_file, fishing_mort_file, freq_file, species_file, years, 
	low_f_species = TRUE
) {

	targets <- read.csv(file.path("data", manage_file)) 
	fmort_data <- read.csv(file.path("tables", fishing_mort_file))
	species <-  read.csv(paste0("data/", species_file))
	freq_data <- read.csv(file.path("tables", freq_file))

	fmort_data <- with(fmort_data, fmort_data[order(fmort_data[,"Species"]), ])
	freq_data <- with(freq_data, freq_data[order(freq_data[,"Species"]), ])
	
	mort_df <- data.frame(
		Species = species[,1], 
		Rank = NA, 
		Factor_Score = NA,
		Modifier = NA,
		Fishing_Mortality = NA,
		OFL = NA,
		ACL = NA,
		ACL_Attain_Percent = NA,
		Last_Assessed = NA 
	)
	
	for(sp in 1:nrow(species)) {

		key <- ss <- NULL
		name_list <- species[sp, species[sp,] != -99]
		for(a in 1:length(name_list)){
			key = c(key,
				grep(species[sp,a], fmort_data$Species, ignore.case = TRUE)
			)

			ss <- c(ss, 
				grep(species[sp, a], targets$STOCK_OR_COMPLEX, ignore.case = TRUE)
			)
		}

		mort_df[sp, "OFL"] <- sum(targets[ss, "OFL"], na.rm = TRUE)
		mort_df[sp, "ACL"] <- sum(targets[ss, "ACL"], na.rm = TRUE) 

		mort_df[sp, "Fishing_Mortality"] <- fmort_data[key[1], "Fishing_Mortality"]
	}

	mort_df[, "ACL_Attain_Percent"] <- mort_df[, "Fishing_Mortality"] / mort_df[, "ACL"]
	mort_df[, "Last_Assessed"] <- freq_data[, "Last_Assess"]

	for(sp in 1:nrow(species)){
		score <-
			ifelse(mort_df$ACL_Attain_Percent[sp] <= 0.10, 1,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 0.10 & mort_df$ACL_Attain_Percent[sp] <= 0.25, 2,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 0.25 & mort_df$ACL_Attain_Percent[sp] <= 0.50, 3,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 0.50 & mort_df$ACL_Attain_Percent[sp] <= 0.75, 5,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 0.75 & mort_df$ACL_Attain_Percent[sp] <= 0.90, 7,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 0.90 & mort_df$ACL_Attain_Percent[sp] <= 1.00, 8,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 1.00 & mort_df$ACL_Attain_Percent[sp] <= 1.10, 9,
			ifelse(mort_df$ACL_Attain_Percent[sp] > 1.10, 10))))))))

		#score <- ifelse(mort_df[sp, "Last_Assessed"] %in% years, 1, score)
		mort_df$Factor_Score[sp] <- score
	}

	mort_df <- 
		mort_df[order(mort_df[,"Factor_Score"], decreasing = TRUE), ]

	x <- 1
	for(i in 10:1) {
		ties <- which(mort_df$Factor_Score == i)
		if(length(ties) > 0) {
			mort_df$Rank[ties] <- x
		}
		x <- x + length(ties)
	}

	# Modifier scores ranging from +4 to -2 where highest attainment would equal 4
	for(sp in 1:nrow(species)){
		mort_df[sp, "Modifier"] <-
			ifelse(mort_df$Factor_Score[sp] == 10, 4, 
			ifelse(mort_df$Factor_Score[sp] == 9, 3, 
			ifelse(mort_df$Factor_Score[sp] == 8, 2, 
			ifelse(mort_df$Factor_Score[sp] == 7, 1,
			ifelse(mort_df$Factor_Score[sp] == 5, 0,
			ifelse(mort_df$Factor_Score[sp] >  4 & mort_df$Factor_Score[sp] <= 2, -1, -2))))))
	}

	mort_df <- with(mort_df, mort_df[order(mort_df[,"Species"]), ])

	write.csv(mort_df, file.path("tables", "future_spex.csv"), row.names = FALSE)
}