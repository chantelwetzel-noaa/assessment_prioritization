library(targets)
# Set target-specific options such as packages:
# tar_option_set(packages = "utils") # nolint
tar_option_set(packages = c(
  "dplyr"
#  "r4ss",
#  "nwfscSurvey"
))

# tar_make() to rebuild target

#summarize_data <- function(dataset){
#  summarize(dataset, mean_x = mean(x))
#}

# tar_source() to source all files in the R folder
source("R/summarize_fishing_mortality.R")
source("R/summarize_revenue.R")
source("R/summarize_rec_importance.R")
#source("R/clean_model_files.R")
source("R/summarize_stock_status.R")
source("R/summarize_ecosystem.R")
source("R/summarize_frequency.R")
source("R/summarize_const_demand.R")
source("R/summarize_rebuilding.R")
source("R/summarize_new_information.R")
source("R/filter_years.R")
source("R/filter_revenue.R")
source("R/filter_gemm.R")
source("R/calculate_rank.R")
source("R/move_files_to_sap.R")


# End this file with a list of target objects.
list(
  list(
    # List of species
    tar_target(species, read.csv("data-raw/species_names.csv")),
    # Year options
    #tar_target(recent_3_years, 2020:2022),
    tar_target(recent_5_years, 2018:2022),
    tar_target(catage_years, 2000:2022),
    tar_target(assessment_year, 2025),
    # Fishing Mortality
    tar_target(harvest_spex_data, read.csv("data-raw/GMT015-final specifications-2015 - 2023.csv")),
    tar_target(gemm_mortality_data, nwfscSurvey::pull_gemm(years = recent_5_years)),
    # Future Spex
    tar_target(future_spex_data, read.csv("data-raw/GMT008-harvest specifications_alt2-2025.csv")),
    # Revenue
    tar_target(revenue_data, read.csv("data-raw/pacfin_revenue.csv")),
    tar_target(tribal_score_data, read.csv("doc/tables/tribal_score.csv")),
    # Recreational Catches
    tar_target(recreational_importance_scores, read.csv(file.path("doc", "tables", "recr_importance.csv"))),
    # Abundance and Assessment Frequency
    tar_target(abundance, read.csv("data-raw/abundance_historical.csv")), 
    tar_target(frequency, read.csv("data-raw/species_sigmaR_catage_main.csv")),
    tar_target(ecosystem_data, read.csv("data-raw/ecosystem_data.csv")),#, format = "file"),
    # Overfished data
    tar_target(overfished_data, read.csv("data-raw/overfished_species.csv")),
    # Survey data summary
    tar_target(survey_data, read.csv("data-processed/all_nwfsc_survey_new_information.csv")),
    tar_target(new_research, read.csv("data-raw/new_research.csv"))
  ),
  
  # Filter Data and Clean Model Files
  list(
    # Clean model files
    # tar_target(clean_files, clean_model_files()),
    # Year filters
    tar_target(harvest_spex_filtered, filter_years(
      data = harvest_spex_data,
      years = recent_5_years)),
    tar_target(revenue_data_filtered, filter_years(
      data = revenue_data,
      years = recent_5_years)),
    tar_target(rec_catch_filtered, filter_gemm(
      data = gemm_mortality_data)),
    # Commercial or Tribal Revenue Data Filter
    tar_target(commercial_revenue_filtered, filter_revenue(
      data = revenue_data_filtered,
      type = "commercial"
    )),
    tar_target(tribal_revenue_filtered, filter_revenue(
      data = revenue_data_filtered,
      type = "tribal"
    ))
  ),
  
  # Calculate Factors
  list(
    # 1 Fishing Mortality
    tar_target(fishing_mortality, summarize_fishing_mortality(
      gemm_mortality = gemm_mortality_data,
      harvest_spex = harvest_spex_filtered,
      species = species)),
    # 2 Commercial Revenue
    tar_target(commercial, summarize_revenue(
      revenue = commercial_revenue_filtered, 
      species = species,
      frequency = frequency)),
    # 3 Tribal Importance
    tar_target(tribal, summarize_revenue(
      revenue = tribal_revenue_filtered, 
      species = species, 
      tribal_score = tribal_score_data,
      frequency = frequency)),
    # 4 Recreational Importance
    tar_target(recreational, summarize_rec_importance(
      rec_catch = rec_catch_filtered, 
      species = species, 
      rec_importance = recreational_importance_scores,
      frequency = frequency)),
    # 5 Ecosystem
    tar_target(ecosystem, summarize_ecosystem(
      ecosystem_data = ecosystem_data)),
    # 6 Stock Status
    tar_target(stock_status, summarize_stock_status(
      abundance = abundance, 
      frequency = frequency, 
      species = species, 
      years = catage_years)),
    # 7 Assessment Frequency
    tar_target(assess_frequency, summarize_frequency(
      frequency = frequency, 
      ecosystem = ecosystem, 
      commercial = commercial, 
      tribal = tribal, 
      recreational = recreational,                             
      assessment_year = assessment_year)),
    # 8 Constituent Demand
    tar_target(constituent_demand, summarize_const_demand(
      revenue_data = revenue_data_filtered, 
      rec_importance_data = recreational, 
      fishing_mortality = fishing_mortality,
      future_spex = future_spex_data,
      species = species)),
    # 9 New Information
    tar_target(bio_params, read.csv(here::here("data-processed/species_sigmaR_catage.csv"))),
    tar_target(new_info, summarize_new_information(
      species = species, 
      survey_data = survey_data, 
      bio_params = bio_params,
      new_research = new_research)),
    # 10 Rebuilding
    tar_target(rebuilding, summarize_rebuilding(
      species = species, 
      overfished_data = overfished_data, 
      stock_status = stock_status, 
      assessment_year = assessment_year)),
    # Calculate the overall ranks
    tar_target(rank, calculate_rank(
      fishing_mortality = fishing_mortality,
      commercial_importance = commercial,
      tribal_importance = tribal,
      recreational_importance = recreational,
      ecosystem = ecosystem,
      stock_status = stock_status,
      assessment_frequency = assess_frequency,
      constituent_demand = constituent_demand,
      new_information = new_info,
      rebuilding = rebuilding)),
    tar_target(move_files, move_files_to_sap(
      dir = here::here("data-processed"), 
      move_to = "C:/Users/Chantel.Wetzel/Documents/GitHub/wcgfishSAP/tables"))
  )
)

# targets::tar_make()
# targets::tar_glimpse()
# targets::tar_visnetwork()
# targets::tar_delete("rank")
# targets::tar_load_everything()