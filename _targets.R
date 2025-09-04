library(targets)

# Useful targets commands
# targets::tar_make(script = "_targets.R")
# targets::tar_visnetwork(targets_only = TRUE) 
# targets::tar_glimpse()
# targets::tar_delete("rank")
# targets::tar_load_everything()

# Set target-specific options such as packages:
targets::tar_option_set(packages = c(
  "dplyr",
  "r4ss",
  "nwfscSurvey",
  "westcoastdatasummary")
)
# Source all functions in the R folder
targets::tar_source()

# End this file with a list of target objects.
list(
  list(
    # List of species
    targets::tar_target(
      species, 
      readr::read_csv("data-raw/species_names.csv")
    ),
    # List of species to pull survey data for:
    tar_target(
      survey_species, 
      westcoastdatasummary::get_species_list()
    ),
    # File to record the assessment year and the SSC recommendations.  This file should be updated
    # by hand each cycle:
    targets::tar_target(
      last_assess_year, 
      readr::read_csv("data-raw/assess_year_ssc_rec.csv"), format = "file"
    ), 
    # prev_cycle used to reach into the archived folder for last cycle output
    targets::tar_target(
      prev_cycle, 
      2024
    ),
    # Year option:
    # These years will be used to filter data to calculate recent averages for
    # GEMM data and fisheries revenue.
    targets::tar_target(
      recent_5_years, 
      2020:2024
    ),
    # Range of years to calculate the average age of catch based upon recent 
    # assessments:
    targets::tar_target(
      catage_years, 
      2000:2024
    ),
    # Next assessment year:
    targets::tar_target(
      assessment_year, 
      2027
    ),
    # Recent harvest specifications:
    # downloaded from: https://reports.psmfc.org/pacfin/f?p=501:5301:2460998972960:::::
    targets::tar_target(
      harvest_spex_data, 
      readr::read_csv("data-raw/GMT015-final specifications-2020 - 2025.csv"), 
      format = "file"
    ),
    # Recent GEMM data:
    targets::tar_target(
      gemm_mortality_data, 
      nwfscSurvey::pull_gemm(years = recent_5_years)
    ),
    # Future harvest specifications
    # downloaded from https://reports.psmfc.org/pacfin/f?p=501:530:2460998972960:INITIAL::::
    targets::tar_target(
      future_spex_data, 
      readr::read_csv("data-raw/GMT008-harvest specifications_alt2-2025.csv"), 
      format = "file"
    ),
    # Revenue information downloaded from PacFIN using QueryBuilder available online:
    targets::tar_target(
      revenue_data, 
      readr::read_csv("data-raw/pacfin_revenue.csv"), 
      format = "file"
    ),
    # Tribal importance which represents subsistence and cultural significance scoring:
    targets::tar_target(
      tribal_score_data, 
      readr::read_csv("data-raw/tribal_score.csv"), 
      format = "file"
    ),
    # Recreational importance by state:
    targets::tar_target(
      recreational_importance_scores, 
      readr::read_csv(file.path("data-raw", "recr_importance.csv")), 
      format = "file"
    ),
    # Abundance and Assessment Frequency
    # This information is updated by summarize_stock_status() based on the most recent assessments
    targets::tar_target(
      abundance_prev_cycle, 
      readr::read_csv(here::here("data-processed", prev_cycle, "abundance_processed.csv")), 
      format = "file"
    ), 
    # Ecosystem top-down and bottom-up measures provided by Kristin Marshall:
    targets::tar_target(
      ecosystem_data, 
      readr::read_csv("data-raw/ecosystem_data.csv"), 
      format = "file"
    ),
    # Overfished Species: Data sheet that contains information about any overfished species 
    targets::tar_target(
      overfished_data, 
      readr::read_csv("data-raw/overfished_species.csv"), 
      format = "file"
    ),
    # New research: spreadsheet that contains information about completed and in process research that 
    # could be influential in a future assessment.
    # This spreadsheet needs to be updated by hand each cycle
    targets::tar_target(
      new_research, 
      readr::read_csv("data-raw/new_research.csv"), 
      format = "file"
    ),
    # Pull NWFSC WCGBTS data
    tar_target(
      wcgbt_data, 
      pull_wcgbts(
        dir = here::here("data-raw"), 
        load = TRUE,
        species = survey_species)
    ),
    # NWFSC HKL Survey Data
    tar_target(
      nwfsc_hkl_data, 
      readr::read_csv(here::here("data-raw", "nwfsc_hkl_DWarehouse version_09032025.csv"))
    )
  ),
  
  # Filter Data and Clean Model Files
  list(
    # Clean model files: only done once and then can be commented out
    tar_target(
      clean_files, 
      clean_model_files()
    ),
    # Apply year filters
    targets::tar_target(
      harvest_spex_filtered, 
      filter_years(
        data = harvest_spex_data,
        years = recent_5_years)
    ),
    targets::tar_target(
      revenue_data_filtered, 
      filter_years(
        data = revenue_data,
        years = recent_5_years)
    ),
    targets::tar_target(
      rec_catch_filtered, 
      filter_gemm(
        data = gemm_mortality_data)
    ),
    # Commercial or Tribal Revenue Data Filter
    targets::tar_target(
      commercial_revenue_filtered, 
      filter_revenue(
        data = revenue_data_filtered,
        type = "commercial")
    ),
    targets::tar_target(
      tribal_revenue_filtered, 
      filter_revenue(
        data = revenue_data_filtered,
        type = "tribal")
    ),
    # Clean NWFSC WCGBT data
    tar_target(
      wcgbt_bio_cleaned, 
      westcoastdatasummary::clean_wcgbt_bio(
        dir = here::here("data-raw"), 
        species = survey_species, 
        data = wcgbt_data)
    ), 
    # Clean NWFSC HKL data
    tar_target(
      nwfsc_hkl_cleaned, 
      westcoastdatasummary::clean_nwfsc_hkl(
        dir = here::here("data-raw"),
        species = survey_species, 
        data = nwfsc_hkl_data)
    )
  ),
  
  # Calculate Factors
  list(
    # Determine the new available survey data
    tar_target(
      new_survey_data, 
      westcoastdatasummary::summarize_survey_new_information(
        dir = here::here("data-processed"), 
        stock_year = last_assess_year, 
        wcgbt = wcgbt_bio_cleaned, 
        hkl = nwfsc_hkl_cleaned)
    ),
    # 6 Stock Status
    targets::tar_target(
      stock_status, 
      summarize_stock_status(
        abundance = abundance_prev_cycle, 
        species = species, 
        years = catage_years)
    ),
    # Update abundance based on the new assessments
    targets::tar_target(
      abundance_updated,  
      readr::read_csv(here::here("data-processed", "abundance_processed.csv")), 
      format = "file"
    ),
    # 1 Fishing Mortality
    targets::tar_target(
      fishing_mortality, 
      summarize_fishing_mortality(
        gemm_mortality = gemm_mortality_data,
        harvest_spex = harvest_spex_filtered,
        species = species)
    ),
    # 2 Commercial Revenue
    targets::tar_target(
      commercial, 
      summarize_revenue(
        revenue = commercial_revenue_filtered, 
        species = species,
        assess_year = last_assess_year)
    ),
    # 3 Tribal Importance
    targets::tar_target(
      tribal, 
      summarize_revenue(
        revenue = tribal_revenue_filtered, 
        species = species, 
        tribal_score = tribal_score_data,
        assess_year = last_assess_year)
    ),
    # 4 Recreational Importance
    targets::tar_target(
      recreational, 
      summarize_rec_importance(
        rec_catch = rec_catch_filtered, 
        species = species, 
        rec_importance = recreational_importance_scores,
        assess_year = last_assess_year)
    ),
    # 5 Ecosystem
    targets::tar_target(
      ecosystem, 
      summarize_ecosystem(
        ecosystem_data = ecosystem_data)
    ),
    # 7 Assessment Frequency
    targets::tar_target(
      assess_frequency, 
      summarize_frequency(
        abundance = abundance_updated, 
        ecosystem = ecosystem, 
        commercial = commercial, 
        tribal = tribal, 
        recreational = recreational,                             
        assessment_year = assessment_year)
    ),
    # 8 Constituent Demand
    targets::tar_target(
      constituent_demand, 
      summarize_const_demand(
        revenue_data = revenue_data_filtered, 
        rec_importance_data = recreational, 
        fishing_mortality = fishing_mortality,
        future_spex = future_spex_data,
        species = species)
    ),
    # 9 New Information
    #targets::tar_target(
    #  bio_params, 
    #  readr::read_csv(here::here("data-processed/species_sigmaR_catage.csv")),
    #  format = "file"
    #),
    targets::tar_target(
      new_info, 
      summarize_new_information(
        species = species, 
        survey_data = new_survey_data, 
        assess_year = last_assess_year,
        new_research = new_research)
    ),
    # 10 Rebuilding
    targets::tar_target(
      rebuilding, 
      summarize_rebuilding(
        species = species, 
        overfished_data = overfished_data, 
        stock_status = stock_status, 
        assessment_year = assessment_year)
    ),
    # Calculate the overall ranks
    targets::tar_target(
      rank, 
      calculate_rank(
        fishing_mortality = fishing_mortality,
        commercial_importance = commercial,
        tribal_importance = tribal,
        recreational_importance = recreational,
        ecosystem = ecosystem,
        stock_status = stock_status,
        assessment_frequency = assess_frequency,
        constituent_demand = constituent_demand,
        new_information = new_info,
        rebuilding = rebuilding)
    ),
    targets::tar_target(
      move_files, 
      move_files_to_sap(
        dir = here::here("data-processed"), 
        move_to = "C:/Users/Chantel.Wetzel/Documents/GitHub/wcgfishSAP/tables")
    )
  )
)
