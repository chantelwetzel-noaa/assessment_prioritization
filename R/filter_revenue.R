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
      data$PACFIN_SPECIES_COMMON_NAME == "BLACK ROCKFISH" &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "BLUE ROCKFISH" &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "DEACON ROCKFISH" &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "CABEZON" &
        data$AGENCY_CODE %in% c("C", "O")
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "CHINA ROCKFISH" &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "COPPER ROCKFISH" &
        data$AGENCY_CODE == "C"
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "KELP GREENLING" &
        data$AGENCY_CODE %in% c("C", "O")
    ),
    which(
      data$PACFIN_SPECIES_COMMON_NAME == "QUILLBACK ROCKFISH" &
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
