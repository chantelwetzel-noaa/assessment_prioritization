library(targets)

# Create targets for all objects
# targets::tar_make(script = "_targets.R")
# Load existing targets
# targets::tar_load_everything()

# View network plots
# targets::tar_visnetwork(targets_only = TRUE)
# targets::tar_glimpse()

# Use the following commands to remove one or all files when getting errors
# targets::tar_delete("rank")
# targets::tar_destroy("all")

# Set target-specific options such as packages:
targets::tar_option_set(
  packages = c(
    "dplyr",
    "nwfscSurvey",
    "r4ss",
    "readr" #,
    #"westcoastdata"
  )
)

# Load in Rdata object for the WCGBT bio data
# Have not figured out how to load an rdata object via tar_target
load("data-raw/bio_pull_all_NWFSC.Combo_2025-09-12.rdata")

# Source all functions in the R folder because I can't get teh westcoastdata (e.g., data_summary)
# to build as a package...
targets::tar_source()
source(
  "C:/Users/chantel.wetzel/Documents/github/prioritization/data_summary/R/get_species_list.R"
)
source(
  "C:/Users/chantel.wetzel/Documents/github/prioritization/data_summary/R/clean_nwfsc_hkl.R"
)
source(
  "C:/Users/chantel.wetzel/Documents/github/prioritization/data_summary/R/clean_wcgbt_bio.R"
)
source(
  "C:/Users/chantel.wetzel/Documents/github/prioritization/data_summary/R/summarize_new_survey_information.R"
)

# End this file with a list of target objects.
list(
  list(
    # List of species
    targets::tar_target(
      species_file,
      command = "data-raw/species_names.csv",
      format = "file"
    ),
    targets::tar_target(
      species,
      readr::read_csv(species_file)
    ),
    # List of species to pull survey data for:
    targets::tar_target(
      survey_species,
      get_species_list()
    ),
    # File to record the assessment year and the SSC recommendations.  This file should be updated
    # by hand each cycle:
    targets::tar_target(
      last_assess_year_df_file,
      command = "data-raw/assess_year_ssc_rec.csv",
      format = "file"
    ),
    targets::tar_target(
      last_assess_year_df,
      readr::read_csv(last_assess_year_df_file)
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
      harvest_spex_data_file,
      command = "data-raw/GMT015-final_specifications-2020-2024.csv",
      format = "file"
    ),
    targets::tar_target(
      harvest_spex_data,
      readr::read_csv(harvest_spex_data_file)
    ),
    # Recent GEMM data:
    targets::tar_target(
      gemm_mortality_data_raw,
      nwfscSurvey::pull_gemm(years = recent_5_years)
    ),
    # Future harvest specifications
    # downloaded from https://reports.psmfc.org/pacfin/f?p=501:530:2460998972960:INITIAL::::
    targets::tar_target(
      future_spex_data_file,
      command = "data-raw/GMT008-harvest specifications-2027-28.csv",
      format = "file"
    ),
    targets::tar_target(
      future_spex_data,
      readr::read_csv(future_spex_data_file)
    ),
    # Revenue information downloaded from PacFIN using QueryBuilder available online:
    targets::tar_target(
      revenue_data_file,
      command = "data-raw/pacfin_commercial_revenue_11172025.csv",
      format = "file"
    ),
    targets::tar_target(
      revenue_data,
      readr::read_csv(revenue_data_file)
    ),
    # Tribal importance which represents subsistence and cultural significance scoring:
    targets::tar_target(
      tribal_score_file,
      command = "data-raw/tribal_score.csv",
      format = "file"
    ),
    targets::tar_target(
      tribal_score_data,
      readr::read_csv(tribal_score_file)
    ),
    # Recreational importance by state:
    targets::tar_target(
      recreational_importance_score_file,
      command = "data-raw/recr_importance.csv",
      format = "file"
    ),
    targets::tar_target(
      recreational_importance_scores,
      readr::read_csv(recreational_importance_score_file)
    ),
    # Abundance and Assessment Frequency
    # This information is updated by summarize_stock_status() based on the most recent assessments
    targets::tar_target(
      abundance_prev_cycle_file,
      command = "data-processed/2024/abundance_processed_filtered.csv",
      format = "file"
    ),
    targets::tar_target(
      abundance_prev_cycle,
      readr::read_csv(abundance_prev_cycle_file)
    ),
    # Ecosystem top-down and bottom-up measures provided by Kristin Marshall:
    targets::tar_target(
      ecosystem_data_file,
      command = "data-raw/ecosystem_data.csv",
      format = "file"
    ),
    targets::tar_target(
      ecosystem_data,
      readr::read_csv(ecosystem_data_file)
    ),
    # Overfished Species: Data sheet that contains information about any overfished species
    targets::tar_target(
      overfished_data_file,
      command = "data-raw/overfished_species.csv",
      format = "file"
    ),
    targets::tar_target(
      overfished_data,
      readr::read_csv(overfished_data_file)
    ),
    # New research: spreadsheet that contains information about completed and in process research that
    # could be influential in a future assessment.
    # This spreadsheet needs to be updated by hand each cycle
    targets::tar_target(
      new_research_file,
      command = "data-raw/new_research.csv",
      format = "file"
    ),
    targets::tar_target(
      new_research,
      readr::read_csv(new_research_file)
    ),
    # Pull NWFSC WCGBTS data
    targets::tar_target(
      wcgbt_data,
      x,
    ),
    #targets::tar_target(
    #  wcgbt_data,
    #  westcoastdata::pull_wcgbts(
    #    dir = here::here("data-raw"),
    #    load = TRUE,
    #    species = survey_species
    #  )
    #),
    # NWFSC HKL Survey Data
    targets::tar_target(
      nwfsc_hkl_data_file,
      command = "data-raw/nwfsc_hkl_DWarehouse_version_09032025.csv",
      format = "file"
    ),
    targets::tar_target(
      nwfsc_hkl_data,
      readr::read_csv(nwfsc_hkl_data_file)
    )
  ),

  list(
    # Clean model files: only done once and then can be commented out
    #tar_target(
    #  clean_files,
    #  clean_model_files()
    #),
    # Filter and format GEMM data
    # Apply year filters
    targets::tar_target(
      harvest_spex_filtered,
      filter_years(
        data = harvest_spex_data,
        years = recent_5_years
      )
    ),
    targets::tar_target(
      revenue_data_filtered,
      filter_years(
        data = revenue_data,
        years = recent_5_years
      )
    ),
    targets::tar_target(
      gemm_mortality_filtered,
      filter_area_gemm(
        data = gemm_mortality_data_raw
      )
    ),
    targets::tar_target(
      rec_catch_filtered,
      filter_gemm(
        data = gemm_mortality_data_raw
      )
    ),
    # Commercial or Tribal Revenue Data Filter
    targets::tar_target(
      commercial_revenue_filtered,
      filter_revenue(
        data = revenue_data_filtered,
        type = "commercial"
      )
    ),
    targets::tar_target(
      tribal_revenue_filtered,
      filter_revenue(
        data = revenue_data_filtered,
        type = "tribal"
      )
    ) #,
    # Clean NWFSC WCGBT data
    #tar_target(
    #  wcgbt_bio_cleaned,
    #  clean_wcgbt_bio(
    #    dir = here::here("data-raw"),
    #    species = survey_species,
    #    data = wcgbt_data
    #  )
    #),
    # Clean NWFSC HKL data
    #tar_target(
    #  nwfsc_hkl_cleaned,
    #  clean_nwfsc_hkl(
    #    dir = here::here("data-raw"),
    #    species = survey_species,
    #    data = nwfsc_hkl_data
    #  )
    #)
  ),

  list(
    # Determine the new available survey data
    targets::tar_target(
      new_survey_data,
      read.csv(here::here(
        "data-processed",
        "all_nwfsc_survey_new_information.csv"
      ))
      #summarize_survey_new_information(
      #  dir = here::here("data-processed"),
      #  stock_year = last_assess_year_df,
      #  wcgbt = wcgbt_bio_cleaned,
      #  hkl = nwfsc_hkl_cleaned
      #)
    ),
    # 6 Stock Status
    targets::tar_target(
      stock_status,
      summarize_stock_status(
        abundance = abundance_prev_cycle,
        species = species,
        catage_years = catage_years
      )
    ),
    # Update abundance based on the new assessments
    targets::tar_target(
      abundance_updated_file,
      command = "data-processed/abundance_processed.csv",
      format = "file"
    ),
    targets::tar_target(
      abundance_updated,
      readr::read_csv(abundance_updated_file)
    ),
    # 1 Fishing Mortality
    targets::tar_target(
      fishing_mortality,
      summarize_fishing_mortality(
        gemm_mortality = gemm_mortality_filtered,
        harvest_spex = harvest_spex_filtered,
        species = species
      )
    ),
    # 2 Commercial Revenue
    targets::tar_target(
      commercial,
      summarize_revenue(
        revenue = commercial_revenue_filtered,
        species = species,
        assess_year = last_assess_year_df
      )
    ),
    # 3 Tribal Importance
    targets::tar_target(
      tribal,
      summarize_revenue(
        revenue = tribal_revenue_filtered,
        species = species,
        tribal_score = tribal_score_data,
        assess_year = last_assess_year_df
      )
    ),
    # 4 Recreational Importance
    targets::tar_target(
      recreational,
      summarize_rec_importance(
        rec_catch = rec_catch_filtered,
        species = species,
        rec_importance = recreational_importance_scores,
        assess_year = last_assess_year_df
      )
    ),
    # 5 Ecosystem
    targets::tar_target(
      ecosystem,
      summarize_ecosystem(
        ecosystem_data = ecosystem_data
      )
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
        assessment_year = assessment_year
      )
    ),
    # 8 Constituent Demand
    targets::tar_target(
      constituent_demand,
      summarize_const_demand(
        revenue_data = revenue_data_filtered,
        rec_importance_data = recreational,
        fishing_mortality = fishing_mortality,
        future_spex = future_spex_data,
        species = species
      )
    ),
    # 9 New Information
    targets::tar_target(
      new_info,
      summarize_new_information(
        species = species,
        survey_data = new_survey_data,
        assess_year = last_assess_year_df,
        new_research = new_research
      )
    ),
    # 10 Rebuilding
    targets::tar_target(
      rebuilding,
      summarize_rebuilding(
        species = species,
        overfished_data = overfished_data,
        stock_status = stock_status,
        assessment_year = assessment_year
      )
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
        rebuilding = rebuilding
      )
    )
  )
)
