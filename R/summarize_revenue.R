#' Calculate importance by revenue
#'
#' Summarize and format commercial revenue data for insert
#' into the assessment prioritizaiton. Data are pulled from
#' PacFIN filtering for only "P" Council records and removing
#' all tribal and research landing revenue estimates.  The data file
#' includes the following columns from PacFIN:
#' AGENCY_CODE, COUNCIL_CODE, PACFIN_SPECIES_CODE, PACFIN_SPECIES_COMMON_NAME,
#' NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE, PACFIN_YEAR, FLEET_CODE, ROUND_WEIGHT_MTONS,
#' AFI_EXVESSEL_REVENUE. The AFI_EXVESSEL_REVENUE column adjusts for inflation and the
#' NOMINAL_TO_ACTUAL_PACFIN_SPECIES_CODE includes both nominal and species specific
#' records. Exvessel revenue is averaged over select years by species and dollar values
#' are output in the 1,000s.
#'
#' @inheritParams summarize_stock_status
#' @param revenue R data object filtered by [filter_revenue()] that contains ex-vessel
#'   revenue from PacFIN. A csv file should be saved in data-raw that is from PacFIN
#'   containing catch information by species (data-raw/pacfin_revenue.csv).
#' @param tribal_score R data object with tribal species importance by species if calculating
#'   revenue for the tribal fishery. The CSV should be saved in data-raw. The default is NULL
#'   which will calculate the revenue for the commercial fishery.
#' @param assess_year R data object with the assessment year by species from the
#'   data-raw/assess_year_ssc_rec.csv.
#' @param last_assess_year Numeric value for the most recent assessment year.
#'
#' @author Chantel Wetzel
#' @export
#'
#'
summarize_revenue <- function(
  revenue,
  species,
  tribal_score = NULL,
  assess_year,
  last_assess_year = 2025
) {
  data <- revenue

  revenue_df <- data.frame(
    Species = species[, 1],
    Rank = NA,
    Factor_Score = NA,
    Tribal_Score = NA,
    Revenue = NA,
    CA_Revenue = NA,
    OR_Revenue = NA,
    WA_Revenue = NA
  )

  denominator <- 1000
  if (unique(data$FLEET_CODE)[1] == "TI") {
    denominator <- 1
    revenue_df[, "Tribal_Score"] <- tribal_score[, "Score"]
  }

  for (sp in 1:nrow(species)) {
    key <- ss <- NULL
    cols <- as.vector(species[sp, ] != -99)
    name_list <- species[sp, cols]
    for (a in 1:length(name_list)) {
      key <- c(
        key,
        grep(
          name_list[a],
          data$PACFIN_SPECIES_COMMON_NAME,
          ignore.case = TRUE
        )
      )
    }

    if (length(key) > 0) {
      sub_data <- data[key, ]
      rev_tmp <- stats::aggregate(
        AFI_EXVESSEL_REVENUE ~ AGENCY_CODE,
        sub_data,
        function(x) sum(x) / denominator
      )
      revenue_df[sp, "Revenue"] <- sum(rev_tmp[, 2])
      if (is.na(revenue_df[sp, "Revenue"])) {
        revenue_df[sp, "Revenue"] <- 0
      }
      if (sum(rev_tmp$AGENCY_CODE == "C") == 1) {
        revenue_df[sp, "CA_Revenue"] <- rev_tmp[rev_tmp$AGENCY_CODE == "C", 2]
      } else {
        revenue_df[sp, "CA_Revenue"] <- 0
      }
      if (sum(rev_tmp$AGENCY_CODE == "O") == 1) {
        revenue_df[sp, "OR_Revenue"] <- rev_tmp[rev_tmp$AGENCY_CODE == "O", 2]
      } else {
        revenue_df[sp, "OR_Revenue"] <- 0
      }
      if (sum(rev_tmp$AGENCY_CODE == "W") == 1) {
        revenue_df[sp, "WA_Revenue"] <- rev_tmp[rev_tmp$AGENCY_CODE == "W", 2]
      } else {
        revenue_df[sp, "WA_Revenue"] <- 0
      }
    } else {
      revenue_df[
        sp,
        c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")
      ] <- 0
    }
  }
  revenue_df[, "Factor_Score"] <- log(as.numeric(revenue_df[, "Revenue"]) + 1)
  revenue_df <- as.data.frame(revenue_df)

  # Reduce the Factor Score by -1 for species that were assessed last cycle
  revenue_df <- revenue_df |>
    dplyr::rename(Species = speciesName) |>
    dplyr::mutate(
      Assessed_Last_Cycle = dplyr::case_when(
        assess_year[, "Last_Assess"] == last_assess_year ~ -2,
        .default = 0
      ),
      Factor_Score = log(Revenue + 1) + Assessed_Last_Cycle,
      Factor_Score = dplyr::case_when(
        Factor_Score > 0 ~ Factor_Score,
        .default = 0
      ),
      Factor_Score = dplyr::case_when(
        !is.na(Tribal_Score) ~ Factor_Score + Tribal_Score,
        .default = Factor_Score
      ),
      Factor_Score = 10 * Factor_Score / max(Factor_Score),
      Rank = rank(-Factor_Score, ties.method = "min")
    ) |>
    dplyr::arrange(Species, .locale = "en")

  revenue_df[, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")] <- round(
    revenue_df[, c("Revenue", "CA_Revenue", "OR_Revenue", "WA_Revenue")],
    1
  )

  if (!"TI" %in% unique(data$FLEET_CODE)) {
    revenue_df <- revenue_df |>
      dplyr::select(-Tribal_Score)
    formatted_revenue_df <- format_all(x = revenue_df)
    utils::write.csv(
      formatted_revenue_df,
      "data-processed/2_commercial_revenue.csv",
      row.names = FALSE
    )
  } else {
    formatted_revenue_df <- format_all(x = revenue_df)
    utils::write.csv(
      formatted_revenue_df,
      "data-processed/3_tribal_revenue.csv",
      row.names = FALSE
    )
  }
  return(revenue_df)
}
