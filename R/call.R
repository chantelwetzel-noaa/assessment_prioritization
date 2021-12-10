

setwd("C:\Users\Chantel.Wetzel\Documents\GitHub\assessment_prioritization")
# figure out how to use here

# CSV files pulled from PacFIN with
# COUNCIL_CODE == "P" and !FLEET_CODE %in% c("TI", "R")
com_rev <- "revenue_summarized_12052021.csv"
# CSV files pulled from PacFIN with
# COUNCIL_CODE == "P" and FLEET_CODE == "TI"
tribal_rev <- "tribal_revenue_12062021.csv"

species_file <-  "species_names.csv"
years <- 2016:2020

summarize_revenue(file_name = com_rev, 
	species_file = species_file, 
	years = years, 
	max_exp = 0.18)

summarize_revenue(file_name = tribal_rev, 
	species_file = species_file, 
	years = years, 
	max_exp = 0.18)

rec_import <- "CTE002-2016---2020.csv"

summarize_rec_importance(
	file_name = rec_import, 
	species_file = species_file, 
	years = years, 
	max_exp = 0.18) 

library(nwfscSurvey)
manage_file <- "WOC_STOCK_SUMMARY11232021.csv"
years <- 2018:2020

summarize_fishing_mortality(
	manage_file = manage_file, 
	species_file = species_file, 
	years = years)
