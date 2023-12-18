#' Function to create the full assessment frequency tab. 
#'
#' @param frequency
#' @param ecosystem
#' @param frequency
#' @param commercial
#' @param tribal
#' @param recreational
#' @param assessment_year A numerical value of the current year the assessment prioritization
#' is being conducted. This value is compared to the last year assessed values to provide species
#' rotation in the ranking based on time since the last assessment.
#'
#' @author Chantel Wetzel
#' @export
#' @md
#'  
#' 
#' @examples
#' 
#' summarize_frequency(
#'   frequency = frequency, # read.csv("data-processed/species_sigmaR_catage.csv")
#'   ecosystem = ecosystem, # output from the summarize_ecosystem()
#'   commercial = commercial, # output from the summarize_revenue()
#'   tribal = tribal, # output from the summarize_revenue()
#'   recreational = recreational, # output from the summarize_rec_importance()                              
#'   assessment_year = assessment_year
#' )
#' 
summarize_frequency <- function(
  frequency, 
  ecosystem, 
  commercial, 
  tribal, 
  recreational,                             
	assessment_year) {

	ecosystem <- with(ecosystem, ecosystem[order(ecosystem[, "Species"]), ])
	frequency <- with(frequency, frequency[order(frequency[, "Species"]), ])

	# Loop over files to use in scoring overall importance
	commercial <- with(commercial, commercial[order(commercial[, "Species"]), ])
	tribal <- with(tribal, tribal[order(tribal[, "Species"]), ])
	recreational <- with(recreational, recreational[order(recreational[, "Species"]), ])
	fishery_importance <- data.frame(
	  Species = frequency$Species,
	  Rank = NA,
	  Commercial = commercial$Factor_Score,
	  Tribal = tribal$Factor_Score,
	  Recreational = recreational$Factor_Score,
	  Total = commercial$Factor_Score + tribal$Factor_Score + recreational$Factor_Score
	  )
  
	fishery_importance <- fishery_importance[order(fishery_importance[,"Total"], decreasing = TRUE), ]
	fishery_importance[, "Rank"] <- 1:nrow(fishery_importance)
	fishery_importance <- with(fishery_importance, fishery_importance[order(fishery_importance[, "Species"]), ])
	
	df <- data.frame(
		Species = commercial$Species,
		Rank = NA,
		Score = NA,
		Recruit_Variation = frequency$Recruit_Var,
		Mean_Catch_Age = round(frequency$Mean_Catch_Age, 1),
		Mean_Maximum_Age = frequency$Mean_Max_Age,
		Initial_Target_Frequency = NA,
		Recruit_Adjustment = NA,
		Importance_Adjustment = NA,
		Ecosystem_Adjustment = NA,
		Total_Adjustment = NA,
		Adjusted_Maximum_Age = NA,
		Target_Assessment_Frequency = NA, 
		Last_Assessment_Year = frequency$Last_Assess,
		Years_Since_Assessment = NA,
		Years_Past_Target_Frequency = NA,
		Ten_Years_or_Greater = NA,
		Less_Than_6_Years_Update = NA
	)

	# Revise this because it does not make sense
	#df$Transformed_Mean_Age <- (df$Mean_Catch_Age * max_age)^age_exp
	#df$Transformed_Mean_Age <- df$Mean_Catch_Age / 2
	age_metric <- quantile(
	  df$Mean_Maximum_Age,
	  seq(0, 1, 0.25)
	)
	df$Initial_Target_Frequency <- ifelse(
	  df$Mean_Maximum_Age <= age_metric[2], 4,
	  ifelse(
	    df$Mean_Maximum_Age > age_metric[2] & df$Mean_Maximum_Age < age_metric[3], 6,
	    ifelse(
	      df$Mean_Maximum_Age >= age_metric[3] & df$Mean_Maximum_Age < age_metric[4], 8, 10)))
	
	df$Years_Since_Assessment <- assessment_year - df$Last_Assessment

	# The point to calculate -1, 0, +1 for overall fishery and ecosystem importance
	# Current approach cuts the species into 1/3rds to assign these values.
	change <- ceiling(nrow(df) / 3)

	for(sp in 1:nrow(df)) {

	  # SigmaR >= 1 = -1
	  # SigmaR < 1 & >= 0.30 = 0 or never has been assessed
	  # Sigma$ < 0.30 = +1
		if(!is.na(df$Recruit_Variation[sp])) {
			df$Recruit_Adjustment[sp] <-
				ifelse(df$Recruit_Variation[sp] >= 1, -0.2, 
				ifelse(df$Recruit_Variation[sp] < 1 & df$Recruit_Variation[sp] >= 0.35, 0, 
				ifelse(df$Recruit_Variation[sp] < 0.35, 0.2))) 
		} else {
			df$Recruit_Adjustment[sp] <-  0
		}
    
	  # Score based on rank of tribal+commercial+recreational importance
	  # Top 1/3 = -1, Lower 1/3 = +1, otherwise = 0
		df$Importance_Adjustment[sp] <- 
			ifelse(fishery_importance$Rank[sp] <= change, -0.2, 
			ifelse(fishery_importance$Rank[sp] > change & fishery_importance$Rank[sp] < 2 * change, 0, 0.2))

		# Score based on the ecosystem importance
		# Top 1/3 = +1, Lower 1/3 = -1, otherwise = 0
		df$Ecosystem_Adjustment[sp] <- 
			ifelse(ecosystem$Rank[sp] <= change, -0.2,
			ifelse(ecosystem$Rank[sp] > change & ecosystem$Rank[sp] < 2 * change, 0, 0.2))

		df$Total_Adjustment[sp] <- df$Recruit_Adjustment[sp] + 
			df$Importance_Adjustment[sp] + df$Ecosystem_Adjustment[sp]
		
		df$Adjusted_Maximum_Age[sp] <- ifelse(
		  df$Total_Adjustment[sp] == 0, df$Mean_Maximum_Age[sp],
		  df$Mean_Maximum_Age[sp] * (1 + df$Total_Adjustment[sp])
		)
	}
	
	age_metric_2 <- quantile(
	  df$Adjusted_Maximum_Age,
	  seq(0, 1, 0.25)
	)
	
	for(sp in 1:nrow(df)){	 
	  df$Target_Assessment_Frequency[sp] <- ifelse(
	    df$Adjusted_Maximum_Age[sp] <= age_metric_2[2], 4,
	    ifelse(
	      df$Adjusted_Maximum_Age[sp] > age_metric_2[2] & df$Adjusted_Maximum_Age[sp] < age_metric_2[3], 6,
	      ifelse(
	        df$Adjusted_Maximum_Age[sp] >= age_metric_2[3] & df$Adjusted_Maximum_Age[sp] < age_metric_2[4], 8, 10 
	      )
	    )
	  )

		# Removed to simplify the factor scoring
		#df$Adj_Negative[sp] <- ifelse(df$Years_Past_Target_Frequency[sp] == 4, -1 * df$Ecosystem_Adjustment, 0)
		#if(is.na(df$Last_Assessment_Year[sp])) {
		#	df$Years_Past_Target_Frequency[sp] <- -1 * df$Total_Adjustment[sp]
    #
		#}
	  df$Years_Past_Target_Frequency[sp] <- ifelse(
	    is.na(df$Last_Assessment_Year[sp]), 4, ifelse(
	      df$Years_Since_Assessment[sp] - df$Target_Assessment_Frequency[sp] > 0, 
	      df$Years_Since_Assessment[sp] - df$Target_Assessment_Frequency[sp], 0
	    )
	  )

		# If we are at or more than 10 years since last assessment add +1
		df$Ten_Years_or_Greater[sp] <- ifelse(df$Years_Since_Assessment[sp] >= 10, 3, 0)

		# If we are less than 6 years & SSC said the next assessment could be an update minus -1 (changed to +1)
		# Do we need this?
		df$Less_Than_6_Years_Update[sp] <- 
			ifelse(df$Years_Since_Assessment[sp] <= 6 & frequency$SSC_Rec[sp] == "Update", 1, 0)

		# If we are at or past the target frequency add +1
		#df$At_or_Beyond_Target_Frequency[sp] <- 
		#	ifelse(df$Target_Assessment_Frequency[sp] <= df$Years_Since_Assessment[sp], 1, 0)

		df$Score[sp] <- 
			sum(
			  df$Years_Past_Target_Frequency[sp], 
				df$Ten_Years_or_Greater[sp], 
				df$Less_Than_6_Years_Update[sp],
				na.rm = TRUE)
	}

	if(max(df$Score) > 10){
	  df$Score <- round(10 * df$Score / max(df$Score), 1)
	} 
	
	df <- df[order(df[,"Score"], decreasing = TRUE), ]
	x <- 1
	for(i in sort(unique(df$Score), decreasing = TRUE)) {
		ties <- which(df$Score == i)
		if(length(ties) > 0) {
			df$Rank[ties] <- x
		}
		x <- x + length(ties)
	}

	df <- with(df, df[order(df[,"Species"]), ])
	write.csv(df, file.path("data-processed", "7_assessment_frequency.csv"), row.names = FALSE)
	
}