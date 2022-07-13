#' Function to create the full assessment frequency tab. This function relies on output
#' from the summarize_model_results, ecosystem, summarize_fishing_mortality, and 
#' summarize_future_spex functions. 
#' 
#'
#' @param frequency_file A csv file created by the summarize_model_results function that 
#' inlcudes summarize the recruitment variation, mean age, year of last assessment, and the SSC
#' recommendation about the next assessment being update or a full assessment.
#' @param ecosystem_file A csv file  
#' @param fishery_importance_files A list of csv files created by the summarize_revenue and 
#' summarize_recreational functions 
#' @param prioritization_year A numerical value of the current year the assessment prioritization
#' is being conducted. This value is compared to the last year assessed values to provide species
#' rotation in the ranking based on time since the last assessment.
#' @param max_age A numerical value that is used with the age_exp to transform mean catch age 
#' by creating a meaningful spread across species (MeanAge * max_age)^age_exp). Current default
#' value is set to 20. The transformed mean catch age is combined with the "total adjustment" value where
#' the "Adjusted Transformed Mean Catch Age" is equal to the sum of these two values, unless they
#' are greater than 10, which are then capped at a maximum value of 10. The total adjustments are a
#' sum of the scored from the Recruit_Adj + Importance_Adj + Eco_Adj
#' @param age_exp A numerical value applied as a exponential to calculate the transformed mean age
#' of the catch. Default value of 0.38.
#'
#' @author Chantel Wetzel
#' @export
#' @md
#'  
#' 
#' @examples
#' 
#' summarize_frequency(
#' 		frequency_file <- "frequency_partial.csv",
#' 		ecosystem_file <- "ecosystem.csv",
#' 		fishery_importance_files <- c("commercial_revenue.csv", "tribal_revenue.csv", "recreational_importance.csv"),
#' 		prioritization_year <- 2023,
#' 		max_age = 20,
#' 		age_exp = 0.38
#' )
#' 
summarize_frequency <- function(frequency_file, ecosystem_file, fishery_importance_files, 
	prioritization_year, max_age = 20, age_exp = 0.38) {
 
	frequency <- read.csv(file.path("tables", frequency_file))
	ecosystem  <- read.csv(file.path("tables", ecosystem_file))

	ecosystem <- with(ecosystem, ecosystem[order(ecosystem[, "Species"]), ])
	frequency <- with(frequency, frequency[order(frequency[, "Species"]), ])

	# Loop over files to use in scoring overall importance
	tmp <- data.frame(Species = tab$Species)
	for (a in fishery_importance_files){
		tab <- read.csv(file.path("tables", a))
		tab <- with(tab, tab[order(tab[, "Species"]), ])
		tmp <- cbind(tmp, tab$Factor_Score)
	}

	tmp[, "Total"] <- apply(tmp[, 2:ncol(tmp)], 1, sum)
	tmp <- tmp[order(tmp[,"Total"], decreasing = TRUE), ]
	tmp[, "Rank"] <- 1:nrow(tmp)
	fishery_importance <- with(tmp, tmp[order(tmp[, "Species"]), ])
	
	df <- data.frame(
		Species = frequency$Species,
		Rank = NA,
		Score = NA,
		Recruit_Var = frequency$Recruit_Var,
		MeanAge = frequency$Mean_Age,
		Trans_MeanAge = NA,
		Recruit_Adj = NA,
		Importance_Adj = NA,
		Eco_Adj = NA,
		Total_Adj = NA,
		MeanAge_Adj = NA,
		MeanAge_Adj_Round = NA,
		Last_Assess = frequency$Last_Assess,
		Years_Since_Assess = NA,
		Beyond_Target_Freq = NA,
		Adj_Negative = NA,
		Greater_Than_10 = NA,
		Less_Than_6_Update = NA,
		Greater_Than_Target_Freq = NA
	)

	df$Trans_MeanAge <- (df$MeanAge * max_age)^age_exp
	df$Years_Since_Assess <- prioritization_year - df$Last_Assess

	# The point to calculate -1, 0, +1 for overall fishery and ecosystem importance
	# Current approach cuts the species into 1/3rds to assign these values.
	change <- ceiling(nrow(df) / 3)

	for(sp in 1:nrow(df)) {

		if(!is.na(df$Recruit_Var[sp])) {
			df$Recruit_Adj[sp] <-
				ifelse(df$Recruit_Var[sp] >= 1, -1, 
				ifelse(df$Recruit_Var[sp] < 1 & df$Recruit_Var[sp] >= 0.35, 0, 
				ifelse(df$Recruit_Var[sp] < 0.35, 1))) 
		} else {
			df$Recruit_Adj[sp] <-  0
		}

		df$Importance_Adj[sp] <- 
			ifelse(fishery_importance$Rank[sp] <= change, -1, 
			ifelse(fishery_importance$Rank[sp] > change & fishery_importance$Rank[sp] < 2 * change, 0, 1))

		df$Eco_Adj[sp] <- 
			ifelse(ecosystem$Rank[sp] <= change, -1,
			ifelse(ecosystem$Rank[sp] > change & ecosystem$Rank[sp] < 2 * change, 0, 1))

		df$Total_Adj[sp] <- df$Recruit_Adj[sp] + df$Importance_Adj[sp] + df$Eco_Adj[sp]
		
		df$MeanAge_Adj[sp] <- 
			ifelse( df$Trans_MeanAge[sp] + df$Total_Adj[sp] > 10, 
				10, df$Trans_MeanAge[sp] + df$Total_Adj[sp])

		df$MeanAge_Adj_Round[sp] <- 
			ifelse(df$MeanAge_Adj[sp] < 4, 4, 2 * round(df$MeanAge_Adj[sp] / 2) )

		if(!is.na(df$Years_Since_Assess[sp])) {
			df$Beyond_Target_Freq[sp] <- 
				ifelse(df$Years_Since_Assess[sp] == 2, -2, 
					max(df$Years_Since_Assess[sp] - df$MeanAge_Adj_Round[sp], 0))
		} else {
			df$Beyond_Target_Freq[sp] <- 4
		}

		#df$Adj_Negative[sp] <- ifelse(df$Beyond_Target_Freq[sp] == 4, -1 * df$Eco_Adj, 0)
		if(is.na(df$Last_Assess[sp])) {
			df$Adj_Negative[sp] <- -1 * df$Total_Adj[sp]

		}	

		df$Greater_Than_10[sp] <- ifelse(df$Years_Since_Assess[sp] > 10, 1, 0)

		df$Less_Than_6_Update[sp] <- 
			ifelse(df$Years_Since_Assess[sp] < 6 & frequency$SSC_Rec[sp] == "Update", -1, 0)

		df$Greater_Than_Target_Freq[sp] <- 
			ifelse(df$MeanAge_Adj_Round[sp] <= df$Years_Since_Assess[sp], 1, 0)

		df$Score[sp] <- 
			sum(df$Beyond_Target_Freq[sp], 
				df$Adj_Negative[sp], 
				df$Greater_Than_10[sp], 
				df$Less_Than_6_Update[sp],
				df$Greater_Than_Target_Freq[sp],
				na.rm = TRUE)
	}

	df <- df[order(df[,"Score"], decreasing = TRUE), ]
	x <- 1
	for(i in 10:min(df$Score)) {
		ties <- which(df$Score == i)
		if(length(ties) > 0) {
			df$Rank[ties] <- x
		}
		x <- x + length(ties)
	}

	out <- with(df, df[order(df[,"Species"]), ])
	write.csv(out, file.path("tables", "assessment_frequency.csv"), row.names = FALSE)

	keep <- which(!colnames(out) %in% c("Importance_Adj", "Eco_Adj", "Adj_Negative", "Constraint_2022"))
	df <- out[, keep]
	for(sp in 1:nrow(df)) {		

		df$Total_Adj[sp] <- df$Recruit_Adj[sp] 

		df$MeanAge_Adj[sp] <- 
			ifelse( df$Trans_MeanAge[sp] + df$Total_Adj[sp] > 10, 
				10, df$Trans_MeanAge[sp] + df$Total_Adj[sp])

		df$MeanAge_Adj_Round[sp] <- 
			ifelse(df$MeanAge_Adj[sp] < 4, 4, 2 * round(df$MeanAge_Adj[sp] / 2) )

		if(!is.na(df$Years_Since_Assess[sp])) {
			df$Beyond_Target_Freq[sp] <- 
				ifelse(df$Years_Since_Assess[sp] == 2, -2, 
					max(df$Years_Since_Assess[sp] - df$MeanAge_Adj_Round[sp], 0))
		} else {
			df$Beyond_Target_Freq[sp] <- 4
		}

		df$Greater_Than_10[sp] <- ifelse(df$Years_Since_Assess[sp] > 10, 1, 0)

		df$Less_Than_6_Update[sp] <- 
			ifelse(df$Years_Since_Assess[sp] < 6 & frequency$SSC_Rec[sp] == "Update", -1, 0)

		df$Greater_Than_Target_Freq[sp] <- 
			ifelse(df$MeanAge_Adj_Round[sp] <= df$Years_Since_Assess[sp], 1, 0)

		df$Score[sp] <- 
			sum(df$Beyond_Target_Freq[sp], 
				df$Greater_Than_10[sp], 
				df$Less_Than_6_Update[sp],
				df$Greater_Than_Target_Freq[sp],
				na.rm = TRUE)
	}	

	df <- df[order(df[,"Score"], decreasing = TRUE), ]
	x <- 1
	for(i in 10:min(df$Score)) {
		ties <- which(df$Score == i)
		if(length(ties) > 0) {
			df$Rank[ties] <- x
		}
		x <- x + length(ties)
	}

	out <- with(df, df[order(df[,"Species"]), ])
	write.csv(out, file.path("tables", "assessment_frequency_simplified.csv"), row.names = FALSE)
	
}