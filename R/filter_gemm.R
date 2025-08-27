#' Filter the GEMM data
#'
#' @param data Dataframe created by nwfscSurvey::pull_gemm
#' @param sector List of sectors to retain
#'
#' @author Chantel Wetzel
#' @export
#'
filter_gemm <- function(
  data, 
  sector = c("California Recreational", "Oregon Recreational", "Washington Recreational")){
  data_filtered <- data[data$sector %in% sector, ]
  return(data_filtered)
}