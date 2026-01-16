#' Calculations used for the "Const Demand" tab for assessment prioritization.
#'
#' The values used in the constituent demand tab are primarily scored qualitatively.
#' This function will provide the state, gear, and sector (commercial vs. recreational)
#' differences across the states and coastwide which then can be qualitatively
#' used to input modifiers.
#'
#' @param revenue_data R data object for revenue data that has been filtered by year
#'   using [filter_years()] from PacFIN that
#'   includes both commercial and tribal revenue (data-raw/pacfin_revenue.csv).
#' @param rec_importance_data R data object created by [summarize_rec_importance()] for tribal catch
#'   data.
#' @param fishing_mortality R data object created by [summarize_fishing_mortality()].
#' @param future_spex R data objected created from the csv file downloaded from PacFIN
#'   APEX report table 8 that provides potential harvest specifications for the upcoming
#'   harvest specification cycle.  The csv file should be saved in the data-raw folder.
#'   Example: data-raw/GMT008-harvest specifications_alt2-2025.csv
#' @param species R data object that contains a list of species names to calculate
#'   assessment prioritization.  The csv file with the list of species names should be
#'   stored in the data-raw folder ("species_names.csv")
#'
#' @author Chantel Wetzel
#' @export
#'
#'
summarize_const_demand <- function(
  revenue_data,
  rec_importance_data,
  fishing_mortality,
  future_spex,
  species = species
) {
  revenue_data$gear <- "TWL"
  revenue_data$gear[revenue_data$PACFIN_GROUP_GEAR_CODE != "TWL"] <- "NTWL"

  data <- data.frame(
    Species = species[, 1],
    Commercial_Importance_Score = 0,
    CW = NA,
    C = NA,
    O = NA,
    W = NA,
    TWL = NA,
    NTWL = NA
  ) |>
    dplyr::rename(Species = speciesName)

  com_importance_df <- score_rank_df <- data

  denominator <- 1000
  max_value <- 10

  # Calculate commercial ranking and scores first
  # This breaks things out by non-trawl and trawl but also includes both
  # commercial and tribal revenue combined by state
  for (sp in 1:nrow(species)) {
    key <- NULL
    cols <- as.vector(species[sp, ] != -99)
    name_list <- species[sp, cols]
    for (a in 1:length(name_list)) {
      key = c(
        key,
        grep(
          name_list[a],
          revenue_data$PACFIN_SPECIES_COMMON_NAME,
          ignore.case = TRUE
        )
      )
    }

    sub_data <- revenue_data[key, ]

    tmp <- stats::aggregate(
      AFI_EXVESSEL_REVENUE ~ AGENCY_CODE,
      sub_data,
      function(x) sum(x) / denominator
    )
    data[sp, "CW"] <- sum(tmp$AFI_EXVESSEL_REVENUE)
    for (aa in sort(unique(tmp$AGENCY_CODE))) {
      data[sp, colnames(data) == aa] <- tmp[
        tmp$AGENCY_CODE == aa,
        "AFI_EXVESSEL_REVENUE"
      ]
    }

    tmp <- stats::aggregate(
      AFI_EXVESSEL_REVENUE ~ gear,
      sub_data,
      function(x) sum(x) / denominator
    )
    for (gg in sort(unique(tmp$gear))) {
      data[sp, colnames(data) == gg] <- tmp[
        tmp$gear == gg,
        "AFI_EXVESSEL_REVENUE"
      ]
    }

    find <- is.na(data[sp, ])
    data[sp, find] <- 0
  }

  com_importance_df <- data |>
    dplyr::mutate(
      log_cw = round(max_value * log(CW + 1)) / max(log(CW + 1)),
      log_c = round(max_value * log(C + 1)) / max(log(C + 1)),
      log_o = round(max_value * log(O + 1)) / max(log(O + 1)),
      log_w = round(max_value * log(W + 1)) / max(log(W + 1)),
      log_twl = round(max_value * log(TWL + 1)) / max(log(TWL + 1)),
      log_ntwl = round(max_value * log(NTWL + 1)) / max(log(NTWL + 1)),
      rank_cw = rank(-log_cw, ties.method = "min"),
      rank_c = rank(-log_c, ties.method = "min"),
      rank_o = rank(-log_o, ties.method = "min"),
      rank_w = rank(-log_w, ties.method = "min"),
      rank_twl = rank(-log_twl, ties.method = "min"),
      rank_ntwl = rank(-log_ntwl, ties.method = "min"),
      scale_rank_cw = round(1 - rank_cw / max(rank_cw), 3),
      scale_rank_c = round(1 - rank_c / max(rank_c), 3),
      scale_rank_o = round(1 - rank_o / max(rank_o), 3),
      scale_rank_w = round(1 - rank_w / max(rank_w), 3),
      scale_rank_twl = round(1 - rank_twl / max(rank_twl), 3),
      scale_rank_ntwl = round(1 - rank_ntwl / max(rank_ntwl), 3),
      final_cw = round(scale_rank_cw / max(scale_rank_cw), 3),
      final_c = round(scale_rank_c / max(scale_rank_c), 3),
      final_o = round(scale_rank_o / max(scale_rank_o), 3),
      final_w = round(scale_rank_w / max(scale_rank_w), 3),
      final_twl = round(scale_rank_twl / max(scale_rank_twl), 3),
      final_ntwl = round(scale_rank_ntwl / max(scale_rank_ntwl), 3),
      modifier_c = dplyr::case_when(
        final_c - final_cw > 0.10 ~ 1,
        .default = 0
      ),
      modifier_o = dplyr::case_when(
        final_c != 0 & final_o - final_cw > 0.10 ~ 1,
        .default = 0
      ),
      modifier_w = dplyr::case_when(
        final_c != 0 & final_w - final_cw > 0.10 ~ 1,
        .default = 0
      ),
      modifier_twl = dplyr::case_when(
        abs(final_twl - final_ntwl) < 0.10 ~ 1,
        .default = 0
      ),
      Commercial_Importance_Score = modifier_c +
        modifier_o +
        modifier_w +
        modifier_twl
    ) |>
    dplyr::select(
      Species,
      final_cw,
      final_c,
      final_o,
      final_w,
      final_twl,
      final_ntwl,
      modifier_c,
      modifier_o,
      modifier_w,
      modifier_twl,
      Commercial_Importance_Score
    )

  #===================================================
  # Recreational importance
  #===================================================
  rec_tmp <- with(
    rec_importance_data,
    rec_importance_data[order(rec_importance_data[, "Species"]), ]
  )
  rec_tmp <- rec_tmp |>
    dplyr::rename(
      CW = Pseudo_Revenue_Coastwide,
      C = Pseudo_Revenue_CA,
      O = Pseudo_Revenue_OR,
      W = Pseudo_Revenue_WA
    ) |>
    dplyr::select(Species, CW, C, O, W)
  #rec_score_df <- rec_importance_df <- rec_tmp

  rec_importance_df <- rec_tmp |>
    dplyr::mutate(
      log_cw = round(max_value * log(CW + 1)) / max(log(CW + 1)),
      log_c = round(max_value * log(C + 1)) / max(log(C + 1)),
      log_o = round(max_value * log(O + 1)) / max(log(O + 1)),
      log_w = round(max_value * log(W + 1)) / max(log(W + 1)),
      rank_cw = rank(-log_cw, ties.method = "min"),
      rank_c = rank(-log_c, ties.method = "min"),
      rank_o = rank(-log_o, ties.method = "min"),
      rank_w = rank(-log_w, ties.method = "min"),
      scale_rank_cw = round(1 - rank_cw / max(rank_cw), 3),
      scale_rank_c = round(1 - rank_c / max(rank_c), 3),
      scale_rank_o = round(1 - rank_o / max(rank_o), 3),
      scale_rank_w = round(1 - rank_w / max(rank_w), 3),
      final_cw = round(scale_rank_cw / max(scale_rank_cw), 3),
      final_c = round(scale_rank_c / max(scale_rank_c), 3),
      final_o = round(scale_rank_o / max(scale_rank_o), 3),
      final_w = round(scale_rank_w / max(scale_rank_w), 3),
      modifier_c = dplyr::case_when(
        final_c - final_cw > 0.10 ~ 1,
        .default = 0
      ),
      modifier_o = dplyr::case_when(
        final_c != 0 & final_o - final_cw > 0.10 ~ 1,
        .default = 0
      ),
      modifier_w = dplyr::case_when(
        final_c != 0 & final_w - final_cw > 0.10 ~ 1,
        .default = 0
      ),
      Recreational_Importance_Score = modifier_c + modifier_o + modifier_w
    ) |>
    dplyr::select(
      Species,
      final_cw,
      final_c,
      final_o,
      final_w,
      modifier_c,
      modifier_o,
      modifier_w,
      Recreational_Importance_Score
    )

  #====================================================================================
  # Choke stock - Pull in the fishing mortality tab and use that information or could
  #====================================================================================
  # use only the future spex modifier section
  # Pull in rebuilding tab
  # Sum the commercial and recreational adjustments, choke stock, and rebuilding
  # Rank the scores
  choke_df <- data.frame(
    Species = species[, 1],
    Average_Catches = fishing_mortality$Average_Catches,
    Projected_ACL_Attainment = NA,
    Choke_Stock_Score = 0,
    sum_future_acl = NA
  ) |>
    dplyr::rename(Species = speciesName)

  for (sp in 1:nrow(species)) {
    ff <- NULL
    cols <- as.vector(species[sp, ] != -99)
    name_list <- species[sp, cols]
    for (a in 1:length(name_list)) {
      ff <- c(
        ff,
        grep(name_list[a], future_spex$STOCK_OR_COMPLEX, ignore.case = TRUE)
      )
    }
    if (length(ff) == 0) {
      for (a in 1:length(name_list)) {
        init_string <- tm::removeWords(species[sp, a], " rockfish")
        ff <- c(
          ff,
          grep(init_string, future_spex$STOCK_OR_COMPLEX, ignore.case = TRUE)
        )
      }
    }

    ff <- unique(ff)
    choke_df[sp, "sum_future_acl"] <- sum(
      future_spex[ff, "ACL"],
      na.rm = TRUE
    ) /
      2
  }

  const_importance <- choke_df |>
    dplyr::mutate(
      Projected_ACL_Attainment = Average_Catches / sum_future_acl,
      Choke_Stock_Score = dplyr::case_when(
        Projected_ACL_Attainment >= 1.25 ~ 5,
        Projected_ACL_Attainment < 1.25 &
          Projected_ACL_Attainment >= 1 ~
          4,
        Projected_ACL_Attainment < 1.0 &
          Projected_ACL_Attainment >= 0.90 ~
          3,
        Projected_ACL_Attainment < 0.9 &
          Projected_ACL_Attainment >= 0.80 ~
          2,
        Projected_ACL_Attainment < 0.8 &
          Projected_ACL_Attainment >= 0.70 ~
          1,
        .default = 0
      ),
      Choke_Stock_Score = dplyr::case_when(
        Species %in%
          c(
            "Shortspine thornyhead",
            "Yellowtail rockfish"
          ) ~
          2,
        .default = Choke_Stock_Score
      ),
      Projected_ACL_Attainment = round(Projected_ACL_Attainment, 3),
      Commercial_Importance_Score = com_importance_df$Commercial_Importance_Score,
      Recreational_Importance_Score = rec_importance_df$Recreational_Importance_Score,
      Factor_Score = Choke_Stock_Score +
        Commercial_Importance_Score +
        Recreational_Importance_Score,
      Factor_Score = round(10 * Factor_Score / max(Factor_Score), 2),
      Rank = rank(-Factor_Score, ties.method = "min")
    ) |>
    dplyr::arrange(Species, .locale = "en") |>
    dplyr::select(-sum_future_acl)

  format_const_importance <- format_all(x = const_importance)
  readr::write_csv(
    format_const_importance,
    here::here("data-processed", "8_constituent_demand.csv")
  )
  readr::write_csv(
    rec_importance_df,
    here::here("data-processed", "_constituent_demand_rec_importance.csv")
  )
  readr::write_csv(
    com_importance_df,
    here::here("data-processed", "_constituent_demand_com_importance.csv")
  )
  return(const_importance)
}
