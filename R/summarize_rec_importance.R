#' Calculate recreational importance
#'
#' Summarize and format recreational catch data to be used along with recreational
#' importance scores to calculate the 'pseudo revenue' by species for the recreational fishery.
#' The function currently uses an existing csv file with previously calculated recreational
#' importance to access existing relative weights for each species and state. In the future
#' this should be modified in the future to use a stand-alone file containing the recreational
#' species weights by state that should be saved in the "data" folder.
#'
#' @param rec_catch R data object created by filter_gemm function with only recreational catches
#'   by state.
#' @param species R data object that contains a list of species names to calculate
#'   assessment prioritization.  The csv file with the list of species names should be
#'   stored in the data-raw folder ("species_names.csv")
#' @param rec_importance R data object with the species importance scoring by state.
#'   A CSV file with the state-specific species importance scores
#' @param assess_year R data object with the assessment year by species from the
#'   data-processed/assess_year_ssc_rec.csv.
#' @param last_assess_year Numeric value for the most recent assessment year.
#'
#' @author Chantel Wetzel
#' @export
#'
#' @examples
#' \dontrun{
#' summarize_rec_importance(
#' 		file_name <- "CTE002-2016---2020.csv",
#' 		years <- 2016:2020,
#' 		species_file <-  "species_names.csv"
#' )
#' }
#'
#'
summarize_rec_importance <- function(
  rec_catch,
  species,
  rec_importance,
  assess_year,
  last_assess_year = 2025
) {
  data <- rec_catch
  rec_score <- rec_importance
  rec_score[is.na(rec_score)] <- 0

  rec_importance_df <- data.frame(
    Species = species[, 1],
    Rank = NA,
    Factor_Score = NA,
    Assessed_Last_Cycle = 0,
    Pseudo_Revenue_Coastwide = NA,
    Pseudo_Revenue_CA = NA,
    Pseudo_Revenue_OR = NA,
    Pseudo_Revenue_WA = NA,
    Species_Importance_CA = NA,
    Species_Importance_OR = NA,
    Species_Importance_WA = NA,
    Catch_Coastwide = NA,
    California_Recreational = NA,
    Oregon_Recreational = NA,
    Washington_Recreational = NA
  ) |>
    dplyr::rename(Species = speciesName)

  # Remove "Dogfish Shark Family" so it does not get lumped with dogfish
  # data <- data[data$SPECIES != "Dogfish Shark Family", ]
  # Filter the data
  # data <- data[data$RECFIN_YEAR %in% years, ]

  for (sp in 1:nrow(species)) {
    key <- ss <- NULL
    cols <- as.vector(species[sp, ] != -99)
    name_list <- species[sp, cols]
    for (a in 1:length(name_list)) {
      key = c(key, grep(name_list[a], data$species, ignore.case = TRUE))
      ss <- c(ss, grep(name_list[a], rec_score$Species, ignore.case = TRUE))
    }

    rec_importance_df[
      sp,
      c(
        "California_Recreational",
        "Oregon_Recreational",
        "Washington_Recreational"
      )
    ] <- 0

    if (length(key) > 0) {
      sub_data <- data[key, ]
      catch_sum <- stats::aggregate(
        total_discard_with_mort_rates_applied_and_landings_mt ~ sector,
        sub_data,
        sum
      )
      state_vector <- gsub(" ", "_", catch_sum[, 1])
      rec_importance_df[sp, state_vector] <-
        aggregate(
          total_discard_with_mort_rates_applied_and_landings_mt ~ sector,
          sub_data,
          sum
        )[, 2]
    }
    rec_importance_df[
      sp,
      c(
        "Species_Importance_CA",
        "Species_Importance_OR",
        "Species_Importance_WA"
      )
    ] <-
      rec_score[ss[1], c("CA", "OR", "WA")]
  }

  rec_importance_df <- rec_importance_df |>
    dplyr::mutate(
      Catch_Coastwide = California_Recreational +
        Oregon_Recreational +
        Washington_Recreational,
      Pseudo_Revenue_CA = Species_Importance_CA * California_Recreational,
      Pseudo_Revenue_OR = Species_Importance_OR * Oregon_Recreational,
      Pseudo_Revenue_WA = Species_Importance_WA * Washington_Recreational,
      Pseudo_Revenue_Coastwide = Pseudo_Revenue_CA +
        Pseudo_Revenue_OR +
        Pseudo_Revenue_WA,
      Assessed_Last_Cycle = dplyr::case_when(
        assess_year[["year"]] == last_assess_year ~ -2,
        .default = 0
      ),
      Factor_Score = log(Pseudo_Revenue_Coastwide + 1) + Assessed_Last_Cycle,
      Factor_Score = dplyr::case_when(
        Factor_Score > 0 ~ Factor_Score,
        .default = 0
      ),
      Factor_Score = 10 * Factor_Score / max(Factor_Score),
      Rank = rank(-Factor_Score, ties.method = "min")
    ) |>
    dplyr::arrange(Species, .locale = "en") |>
    dplyr::rename(
      Catch_CA = California_Recreational,
      Catch_OR = Oregon_Recreational,
      Catch_WA = Washington_Recreational
    )

  rec_importance_df[, c(
    "Catch_Coastwide",
    "Catch_CA",
    "Catch_OR",
    "Catch_WA",
    "Pseudo_Revenue_Coastwide",
    "Pseudo_Revenue_CA",
    "Pseudo_Revenue_OR",
    "Pseudo_Revenue_WA"
  )] <- round(
    rec_importance_df[, c(
      "Catch_Coastwide",
      "Catch_CA",
      "Catch_OR",
      "Catch_WA",
      "Pseudo_Revenue_Coastwide",
      "Pseudo_Revenue_CA",
      "Pseudo_Revenue_OR",
      "Pseudo_Revenue_WA"
    )],
    1
  )
  formatted_rec_importance <- format_all(x = rec_importance_df)
  utils::write.csv(
    formatted_rec_importance,
    "data-processed/4_recreational_importance.csv",
    row.names = FALSE
  )
  return(rec_importance_df)
}
