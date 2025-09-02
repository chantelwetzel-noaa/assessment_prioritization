library(targets)
# Create initial _targets.R script
# targets::tar_make(script = "_targets.R")
# targets::tar_visnetwork(targets_only = TRUE) 

# Set target-specific options such as packages:
targets::tar_option_set(packages = c(
  "dplyr",
  "r4ss",
  "nwfscSurvey")
)
# Source all files in the R folder
targets::tar_source()

# End this file with a list of target objects.
list(
  list(
    # List of species
    targets::tar_target(species, read.csv("data-raw/species_names.csv")),
    targets::tar_target(prev_cycle, 2024),
    # Year option:
    targets::tar_target(recent_5_years, 2020:2024),
    targets::tar_target(catage_years, 2000:2024),
    targets::tar_target(assessment_year, 2027),
    targets::tar_target(last_assess_year, read.csv("data-raw/assess_year_ssc_rec.csv"), format = "file"), 
    # Fishing Mortality
    targets::tar_target(harvest_spex_data, 
      read.csv("data-raw/GMT015-final specifications-2015 - 2023.csv"), format = "file"),
    targets::tar_target(gemm_mortality_data, nwfscSurvey::pull_gemm(years = recent_5_years)),
    # Future Spex
    targets::tar_target(future_spex_data, read.csv("data-raw/GMT008-harvest specifications_alt2-2025.csv"), format = "file"),
    # Revenue
    targets::tar_target(revenue_data, read.csv("data-raw/pacfin_revenue.csv"), format = "file"),
    targets::tar_target(tribal_score_data, read.csv("data-raw/tribal_score.csv"), format = "file"),
    # Recreational Catches
    targets::tar_target(recreational_importance_scores, read.csv(file.path("data-raw", "recr_importance.csv")), format = "file"),
    # Abundance and Assessment Frequency
    targets::tar_target(abundance, read.csv(here::here("data-processed", prev_cycle, "abundance_processed.csv")), format = "file"), 
    targets::tar_target(ecosystem_data, read.csv("data-raw/ecosystem_data.csv"), format = "file"),
    # Overfished data
    targets::tar_target(overfished_data, read.csv("data-raw/overfished_species.csv"), format = "file"),
    # Survey data summary
    targets::tar_target(survey_data, read.csv("data-raw/all_nwfsc_survey_new_information.csv")),
    targets::tar_target(new_research, read.csv("data-raw/new_research.csv"), format = "file")
  ),
  
  # Filter Data and Clean Model Files
  list(
    # Clean model files
    # tar_target(clean_files, clean_model_files()),
    # Year filters
    targets::tar_target(harvest_spex_filtered, filter_years(
      data = harvest_spex_data,
      years = recent_5_years)),
    targets::tar_target(revenue_data_filtered, filter_years(
      data = revenue_data,
      years = recent_5_years)),
    targets::tar_target(rec_catch_filtered, filter_gemm(
      data = gemm_mortality_data)),
    # Commercial or Tribal Revenue Data Filter
    targets::tar_target(commercial_revenue_filtered, filter_revenue(
      data = revenue_data_filtered,
      type = "commercial"
    )),
    targets::tar_target(tribal_revenue_filtered, filter_revenue(
      data = revenue_data_filtered,
      type = "tribal"
    ))
  ),
  
  # Calculate Factors
  list(
    # 6 Stock Status
    targets::tar_target(stock_status, summarize_stock_status(
      abundance = abundance, 
      species = species, 
      years = catage_years)),
    # Update abundance based on the new assessments
    targets::tar_target(abundance,  
      read.csv(here::here("data-processed", "abundance_processed.csv")), format = "file"),
    # 1 Fishing Mortality
    targets::tar_target(fishing_mortality, summarize_fishing_mortality(
      gemm_mortality = gemm_mortality_data,
      harvest_spex = harvest_spex_filtered,
      species = species)),
    # 2 Commercial Revenue
    targets::tar_target(commercial, summarize_revenue(
      revenue = commercial_revenue_filtered, 
      species = species,
      assess_year = last_assess_year)),
    # 3 Tribal Importance
    targets::tar_target(tribal, summarize_revenue(
      revenue = tribal_revenue_filtered, 
      species = species, 
      tribal_score = tribal_score_data,
      assess_year = last_assess_year)),
    # 4 Recreational Importance
    targets::tar_target(recreational, summarize_rec_importance(
      rec_catch = rec_catch_filtered, 
      species = species, 
      rec_importance = recreational_importance_scores,
      assess_year = last_assess_year)),
    # 5 Ecosystem
    targets::tar_target(ecosystem, summarize_ecosystem(
      ecosystem_data = ecosystem_data)),
    # 7 Assessment Frequency
    targets::tar_target(assess_frequency, summarize_frequency(
      abundance = abundance, 
      ecosystem = ecosystem, 
      commercial = commercial, 
      tribal = tribal, 
      recreational = recreational,                             
      assessment_year = assessment_year)),
    # 8 Constituent Demand
    targets::tar_target(constituent_demand, summarize_const_demand(
      revenue_data = revenue_data_filtered, 
      rec_importance_data = recreational, 
      fishing_mortality = fishing_mortality,
      future_spex = future_spex_data,
      species = species)),
    # 9 New Information
    targets::tar_target(bio_params, read.csv(here::here("data-processed/species_sigmaR_catage.csv"))),
    targets::tar_target(new_info, summarize_new_information(
      species = species, 
      survey_data = survey_data, 
      assess_year = last_assess_year,
      new_research = new_research)),
    # 10 Rebuilding
    targets::tar_target(rebuilding, summarize_rebuilding(
      species = species, 
      overfished_data = overfished_data, 
      stock_status = stock_status, 
      assessment_year = assessment_year)),
    # Calculate the overall ranks
    targets::tar_target(rank, calculate_rank(
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
    targets::tar_target(move_files, move_files_to_sap(
      dir = here::here("data-processed"), 
      move_to = "C:/Users/Chantel.Wetzel/Documents/GitHub/wcgfishSAP/tables"))
  )
)

# targets::tar_make()
# targets::tar_glimpse()
# targets::tar_visnetwork()
# targets::tar_delete("rank")
# targets::tar_load_everything()