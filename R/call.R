# Order of operations for the 2022 Assessment Prioritization proces

setwd("C:/Users/Chantel.Wetzel/Documents/GitHub/assessment_prioritization")
# figure out how to use here::here

# Load up the species CSV file that will be used across functions
species_file <-  "species_names.csv"
# Set the years for the revenue summary, recreational importance
years <- 2016:2020

# Commercial Revenue:
# CSV files pulled from PacFIN with
# COUNCIL_CODE == "P" and !FLEET_CODE %in% c("TI", "R")
summarize_revenue(file_name = "revenue_summarized_12052021.csv", 
	species_file = species_file, 
	years = years, 
	max_exp = 0.18)

# Tribal revenue:
# CSV files pulled from PacFIN with
# COUNCIL_CODE == "P" and FLEET_CODE == "TI"
summarize_revenue(file_name = "tribal_revenue_12062021.csv", 
	species_file = species_file, 
	years = years, 
	max_exp = 0.18)

# Recreational Importance:
# Landings data pulled from RecFIN for all states and species
summarize_rec_importance(
	file_name = "CTE002-2016---2020.csv", 
	species_file = species_file, 
	years = years, 
	max_exp = 0.18) 

# Fishing mortality:
# Large management quantity download from PacFIN (GMT016) 
# provided by Rob Ames. Only single species information 
# available for download as of December 2021

# The nwfscSurvey package is loaded in order to pull GEMM data
# which is the official mortality source
library(nwfscSurvey)
years <- 2018:2020

fish_mort <- summarize_fishing_mortality(
	manage_file = "WOC_STOCK_SUMMARY11232021.csv", 
	species_file = species_file, 
	years = years)

# Function that will clean up all folders in the "model_files"
# folder to only keep the files needed for r4ss to read model results

clean_model_files(loc = "model_files/")

# Function to grab and summarize the newest assessment results which
# will then update the abundcanc (stock status) and the assessment
# frequency csvs from last cycle
summarize_model_results(
	abundance_file = "abundance_previous_cycle.csv", 
	frequency_file = "assessment_frequency_last_cycle.csv", 
	species_file = species_file, 
	model_loc = "model_files", 
	years = 2000:2020)
