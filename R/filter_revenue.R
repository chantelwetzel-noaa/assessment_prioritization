#' Filter out and identify tribal and non-tribal records
#'
#' @param data PacFIN CompFT data table
#' @param type Default NULL. To filter and mark tribal records type = "tribal"
#'
#' @author Chantel Wetzel
#' @export
#'
filter_revenue <- function(data, type = NULL) {
  remove <- c(
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("BLACK ROCKFISH", "NOM. BLACK ROCKFISH") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("BLUE ROCKFISH", "NOM. BLUE ROCKFISH") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("DEACON ROCKFISH", "NOM. DEACON ROCKFISH") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("CABEZON", "NOM. CABEZON") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("CABEZON", "NOM. CABEZON") &
        data$AGENCY_CODE == "O"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("CHINA ROCKFISH", "NOM. CHINA ROCKFISH") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("COPPER ROCKFISH", "NOM. CHINA ROCKFISH") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("KELP GREENLING", "NOM. KELP GREENLING") &
        data$AGENCY_CODE == "O"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("KELP GREENLING", "NOM. KELP GREENLING") &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME %in%
        c("QUILLBACK ROCKFISH", "NOM. QUILLBACK ROCKFISH") &
        data$AGENCY_CODE == "C"
    )
  )
  data_filtered <- data[-remove, ]

  if (type == "tribal") {
    data_filtered <- data_filtered |>
      dplyr::filter(FLEET_CODE == "TI")
  } else {
    data_filtered <- data_filtered |>
      dplyr::filter(FLEET_CODE != "TI")
  }

  return(data_filtered)
}
