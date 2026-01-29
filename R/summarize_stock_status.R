#' Calculate ranking by stock status
#'
#'
#' Function that will read output from all models in
#' the model_loc ("model_files") folder. The unfished
#' spawning biomass, final spawning biomass, sigma R,
#' assessment year, and mean age. The function then takes
#' these results and calculates a weighted depletion and
#' mean age for stocks with area based assessments. These
#' results are then added to the previous cycle's stock status
#' and assessment frequency sheets in the "data" folder. The
#' updated stock status and assessment frequency csv files are
#' then saved to the tables folder.
#'
#' @param abundance R data object that contains the estimated abundance by species.
#'   This function takes the existing values and adds the estimated abundance from
#'   new assessments. The csv file to be read is found in the data-processed folder
#'   called abundance_processed.csv
#' @param species R data object that contains a list of species names to calculate
#'   assessment prioritization.  The csv file with the list of species names should be
#'   stored in the data-raw folder ("species_names.csv")
#' @param model_loc Directory location to locate model files. The default is "model_files" in the
#'   assessment prioritization github.
#' @param catage_years Vector of specific years to calculate the mean age of the catches by species.
#'
#' @author Chantel Wetzel
#' @export
#'
#' @examples
#' \dontrun{
#'   summarize_stock_status(
#'   		abundance = abundance,
#'   		species = species,
#'   		model_loc = "model_files",
#'   		catage_years = 2000:2020 # Catch-at-Age range
#'   )
#' }
#'
summarize_stock_status <- function(
  abundance,
  species,
  catage_years,
  model_loc = "model_files"
) {
  new_models <- list.files(model_loc)
  new_results <- data.frame(
    SpeciesArea = new_models,
    Species = NA,
    AssessYear = NA,
    Mean_Catch_Age = NA,
    M = NA,
    Max_Age = NA,
    SigmaR = NA,
    SB0 = NA,
    SBfinal = NA,
    SBfinal_5 = NA,
    Status = NA,
    Status_5 = NA,
    WeightedStatus = NA,
    WeightedStatus_5 = NA,
    WeightedMeanCatchAge = NA,
    MeanMaxAge = NA,
    Mean_SigmaR = NA
  )

  for (a in 1:length(new_models)) {
    new_results[a, "Species"] <- strsplit(new_models[a], ".", fixed = TRUE)[[
      1
    ]][1]

    model <- r4ss::SS_output(
      here::here(model_loc, new_models[a]),
      verbose = FALSE,
      printstat = FALSE
    )
    find <- which(model$catage$Yr %in% catage_years)
    ncols <- dim(model$catage)[2]
    age <- 0:(ncols - 12)
    new_results[a, "Mean_Catch_Age"] <- round(
      sum(age * apply(model$catage[find, 12:ncols], 2, sum)) /
        sum(model$catage[find, 12:ncols]),
      1
    )
    if (sum(model$recruitpars[, "Value"]) != 0) {
      new_results[a, "SigmaR"] <- model$sigma_R_in
    } else {
      new_results[a, "SigmaR"] <- 0
    }
    new_results[a, "M"] <- model$parameters[
      rownames(model$parameters) %in%
        c(
          "NatM_p_1_Fem_GP_1",
          "NatM_uniform_Fem_GP_1",
          "NatM_break_1_Fem_GP_1"
        ),
      "Value"
    ]
    new_results[a, "Max_Age"] <- round(5.4 / new_results[a, "M"], 0)
    new_results[a, "SB0"] <- model$derived_quants[
      model$derived_quants$Label == "SSB_Virgin",
      "Value"
    ]
    new_results[a, "SBfinal"] <- new_results[a, "SB0"] * model$current_depletion
    new_results[a, "SBfinal_5"] <- model$derived_quants[
      model$derived_quants$Label == paste0("SSB_", model$endyr - 5),
      "Value"
    ]
    new_results[a, "Status"] <- model$current_depletion
    new_results[a, "Status_5"] <- new_results[a, "SBfinal_5"] /
      new_results[a, "SB0"]
    new_results[a, "AssessYear"] <- model$endyr + 1
  }

  unique_species <- unique(new_results$Species)
  for (b in 1:length(unique_species)) {
    group <- which(new_results$Species == unique_species[b])
    new_results[group, "WeightedStatus"] <- sum(new_results[group, "SBfinal"]) /
      sum(new_results[group, "SB0"])
    new_results[group, "WeightedStatus_5"] <- sum(new_results[
      group,
      "SBfinal_5"
    ]) /
      sum(new_results[group, "SB0"])
    prop <- new_results[group, "SBfinal"] / sum(new_results[group, "SBfinal"])
    new_results[group, "WeightedMeanCatchAge"] <- sum(
      prop * new_results[group, "Mean_Catch_Age"]
    )
    new_results[group, "MeanMaxAge"] <- mean(new_results[group, "Max_Age"])
    new_results[group, "Mean_SigmaR"] <- mean(
      new_results[group, "SigmaR"],
      na.rm = TRUE
    )
  }
  new_results[is.na(new_results[, "Mean_SigmaR"]), "Mean_SigmaR"] <- NA

  # Thread the new values into existing files
  new_abundance <- abundance
  for (b in unique_species) {
    new_results_key <- which(
      gsub("_", " ", new_results$Species) %in% tolower(gsub("_", " ", b))
    )[1]
    new_abundance_key <- which(
      gsub("_", " ", new_abundance$Species) %in% tolower(gsub("_", " ", b))
    )[1]

    if (!is.na(new_abundance_key)) {
      new_abundance[new_abundance_key, ] <- new_abundance[
        new_abundance_key,
      ] |>
        dplyr::mutate(
          Estimate = new_results[new_results_key, "WeightedStatus"],
          Trend = dplyr::case_when(
            new_abundance[new_abundance_key, "Estimate"] >=
              new_abundance[new_abundance_key, "Target"] ~
              0,
            new_results[new_results_key, "WeightedStatus"] >
              new_results[new_results_key, "WeightedStatus_5"] ~
              1,
            .default = -1
          ),
          Recruit_Var = new_results[new_results_key, "Mean_SigmaR"],
          Mean_Catch_Age = new_results[new_results_key, "WeightedMeanCatchAge"],
          Mean_Max_Age = new_results[new_results_key, "MeanMaxAge"],
          Last_Assess = new_results[new_results_key, "AssessYear"]
        )
    }
  }

  # Combine with the SSC recommendation
  ssc <- utils::read.csv(here::here("data-raw", "assess_year_ssc_rec.csv")) |>
    dplyr::select(-Last_Assess)
  new_abundance <- dplyr::left_join(
    x = new_abundance |> dplyr::select(-Last_Assess),
    y = ssc
  )

  # Rank and score the stock status sheet, delete trend column, and remove NAs.
  abundance_out <- new_abundance |>
    dplyr::mutate(
      Factor_Score = dplyr::case_when(
        Estimate > 2 * Target ~ 1,
        Estimate <= 2 * Target & Estimate > 1.5 * Target ~ 2,
        Estimate <= 1.5 * Target & Estimate > 1.1 * Target ~ 3,
        Estimate <= 1.1 * Target & Estimate > 0.9 * Target ~ 4,
        Estimate <= 0.9 * Target & Estimate > MSST & Trend == 1 ~ 5,
        Estimate <= 0.9 * Target & Estimate > MSST & Trend == 0 ~ 6,
        Estimate <= 0.9 * Target & Estimate > MSST & Trend == -1 ~ 7,
        Estimate <= MSST & Trend == 1 ~ 8,
        Estimate <= MSST & Trend == 0 ~ 9,
        Estimate <= MSST & Trend == -1 ~ 10,
        is.na(Estimate) & PSA < 1.8 ~ 3,
        is.na(Estimate) & PSA >= 1.8 & PSA < 2 ~ 5,
        is.na(Estimate) & PSA >= 2.0 ~ 7
      ),
      Factor_Score = round(10 * Factor_Score / max(Factor_Score), 1),
      Rank = rank(-Factor_Score, ties.method = "min")
    ) |>
    dplyr::arrange(Species, .locale = "en")

  abundance_out$Fraction_Unfished <- abundance_out$Estimate
  stock_status <- abundance_out[, c(
    "Species",
    "Rank",
    "Factor_Score",
    "Fraction_Unfished",
    "Target",
    "MSST",
    "PSA",
    "Trend"
  )]

  formatted_stock_status <- format_all(x = stock_status)
  readr::write_csv(
    formatted_stock_status,
    here::here("data-processed", "6_stock_status.csv")
  )
  readr::write_csv(
    abundance_out,
    here::here("data-processed", "abundance_processed.csv")
  )
  readr::write_csv(
    new_results,
    here::here("data-processed", "model_results.csv")
  )
  return(stock_status)
}
